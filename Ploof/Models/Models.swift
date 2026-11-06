import Foundation

// MARK: - People

nonisolated struct Person: Identifiable, Hashable, Sendable {
    let id: String
    let name: String
    let email: String
    /// 0...1 hue used to color the avatar.
    let hue: Double

    var isMe: Bool { id == "me" }
    var displayName: String { isMe ? "You" : name }
    var firstName: String { name.split(separator: " ").first.map(String.init) ?? name }
    var initials: String {
        name.split(separator: " ")
            .prefix(2)
            .compactMap { $0.first }
            .map(String.init)
            .joined()
            .uppercased()
    }
}

// MARK: - Mail

/// AI triage buckets. These replace Focused / Other.
nonisolated enum TriageBucket: String, CaseIterable, Identifiable, Sendable {
    case needsYou, waiting, fyi, updates

    var id: String { rawValue }

    var title: String {
        switch self {
        case .needsYou: "Needs you"
        case .waiting: "Waiting"
        case .fyi: "FYI"
        case .updates: "Updates"
        }
    }

    var symbol: String {
        switch self {
        case .needsYou: "bolt.fill"
        case .waiting: "hourglass"
        case .fyi: "info.circle"
        case .updates: "newspaper"
        }
    }
}

nonisolated enum Folder: String, CaseIterable, Identifiable, Sendable {
    case inbox, drafts, sent, archive, junk, deleted

    var id: String { rawValue }

    var title: String {
        switch self {
        case .inbox: "Inbox"
        case .drafts: "Drafts"
        case .sent: "Sent"
        case .archive: "Archive"
        case .junk: "Junk"
        case .deleted: "Deleted"
        }
    }

    var symbol: String {
        switch self {
        case .inbox: "tray"
        case .drafts: "doc"
        case .sent: "paperplane"
        case .archive: "archivebox"
        case .junk: "xmark.bin"
        case .deleted: "trash"
        }
    }
}

nonisolated struct Message: Identifiable, Hashable, Sendable {
    let id: String
    let from: Person
    let date: Date
    let body: String
}

nonisolated struct MailThread: Identifiable, Hashable, Sendable {
    let id: String
    var subject: String
    var bucket: TriageBucket
    var folder: Folder = .inbox
    var isUnread: Bool
    var isFlagged: Bool = false
    var hasAttachment: Bool = false
    /// AI one-line gist shown in the list instead of the raw preview.
    var oneLiner: String
    /// AI "where this stands" summary shown at the top of the thread.
    var stands: String
    var suggestedReplies: [String] = []
    var messages: [Message]

    var lastDate: Date { messages.last?.date ?? .distantPast }

    /// The most recent person in the thread who isn't you.
    var counterpart: Person {
        messages.last(where: { !$0.from.isMe })?.from ?? messages.first!.from
    }
}

nonisolated struct ThreadRoute: Hashable, Sendable {
    let id: String
}

// MARK: - Promises

nonisolated enum PromiseDirection: String, CaseIterable, Identifiable, Sendable {
    case iOwe, owedToMe

    var id: String { rawValue }

    var title: String {
        switch self {
        case .iOwe: "I owe"
        case .owedToMe: "Owed to me"
        }
    }

    var shortLabel: String {
        switch self {
        case .iOwe: "You owe"
        case .owedToMe: "Owed to you"
        }
    }
}

nonisolated enum PromiseStatus: Sendable {
    case open, settled, snoozed, dismissed
}

nonisolated enum DueTone: Sendable {
    case overdue, today, soon, later, none
}

nonisolated struct Promise: Identifiable, Hashable, Sendable {
    let id: String
    let direction: PromiseDirection
    let person: Person
    let title: String
    /// The exact words from the email that created this promise.
    let evidence: String
    /// Who said the evidence words ("You" or the other person's first name).
    let evidenceBy: String
    var due: Date?
    let threadID: String
    var status: PromiseStatus = .open
    /// AI-drafted follow-up for promises owed to you.
    var nudge: String? = nil

    private var dayOffset: Int? {
        guard let due else { return nil }
        let cal = Calendar.current
        return cal.dateComponents([.day], from: cal.startOfDay(for: .now), to: cal.startOfDay(for: due)).day
    }

    var isOverdue: Bool { (dayOffset ?? 0) < 0 }
    var isDueTodayOrEarlier: Bool { dayOffset.map { $0 <= 0 } ?? false }

    var tone: DueTone {
        guard let days = dayOffset else { return .none }
        switch days {
        case ..<0: return .overdue
        case 0: return .today
        case 1...2: return .soon
        default: return .later
        }
    }

    var dueLabel: String {
        guard let due, let days = dayOffset else { return "No date" }
        switch days {
        case ..<(-1): return "\(-days)d overdue"
        case -1: return "Due yesterday"
        case 0: return "Today"
        case 1: return "Tomorrow"
        case 2...6: return due.formatted(.dateTime.weekday(.wide))
        default: return due.formatted(.dateTime.month(.abbreviated).day())
        }
    }
}

// MARK: - Compose

nonisolated struct ComposeDraft: Identifiable, Sendable {
    let id = UUID()
    var threadID: String?
    var to: String
    var subject: String
    var body: String
    /// The promise this message would settle, if any.
    var settles: String?
    /// An AI-drafted follow-up on something owed to you.
    var isNudge = false

    var title: String {
        if isNudge { return "Nudge" }
        return threadID == nil ? "New Message" : "Reply"
    }

    static func new() -> ComposeDraft {
        ComposeDraft(threadID: nil, to: "", subject: "", body: "", settles: nil)
    }

    static func reply(to thread: MailThread, body: String = "", settles: String? = nil) -> ComposeDraft {
        ComposeDraft(
            threadID: thread.id,
            to: thread.counterpart.name,
            subject: thread.subject.hasPrefix("Re:") ? thread.subject : "Re: \(thread.subject)",
            body: body,
            settles: settles
        )
    }

    static func forward(_ thread: MailThread) -> ComposeDraft {
        ComposeDraft(threadID: nil, to: "", subject: "Fwd: \(thread.subject)", body: "", settles: nil)
    }
}

// MARK: - Navigation

nonisolated enum AppTab: Hashable, Sendable {
    case today, mail, settings, ask
}

/// Filtered promise lists opened from the brief's stat tiles.
nonisolated enum PromiseFocus: String, Identifiable, Hashable, Sendable {
    case oweToday, lateOnYou

    var id: String { rawValue }

    var title: String {
        switch self {
        case .oweToday: "You owe"
        case .lateOnYou: "Late on you"
        }
    }

    var subtitle: String {
        switch self {
        case .oweToday: "Promises you made that are due today or already late."
        case .lateOnYou: "People who missed something they promised you. Ploof has a nudge ready for each."
        }
    }
}

// MARK: - Brief, Ask, Toast

nonisolated struct Brief: Sendable {
    let greeting: String
    let dateLine: String
    let oweCount: Int
    let lateCount: Int
    let needCount: Int
    let headline: String
}

nonisolated struct AskAnswer: Identifiable, Sendable {
    let id = UUID()
    let question: String
    let text: String
    let citations: [String]
}

nonisolated struct Toast: Identifiable, Equatable, Sendable {
    let id = UUID()
    let symbol: String
    let text: String
    var undoPromiseID: String? = nil
}
