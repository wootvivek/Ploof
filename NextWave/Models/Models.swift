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
/// Updates are written by people and need no action; notifications are automated.
nonisolated enum TriageBucket: String, CaseIterable, Identifiable, Sendable {
    case needsYou, waiting, updates, notifications

    /// The buckets Today shows, under the same names as the Mail chips. Notifications stay in Mail.
    static let todaySections: [TriageBucket] = [.needsYou, .waiting, .updates]

    var id: String { rawValue }

    var title: String {
        switch self {
        case .needsYou: "Needs you"
        case .waiting: "Waiting"
        case .updates: "Updates"
        case .notifications: "Notifications"
        }
    }

    var symbol: String {
        switch self {
        case .needsYou: "bolt.fill"
        case .waiting: "hourglass"
        case .updates: "newspaper"
        case .notifications: "bell"
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
    /// AI judgement that this is worth seeing today even though it needs no action.
    /// Today's Updates section shows only these.
    var isImportant: Bool = false
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

// MARK: - Commitments

nonisolated enum CommitmentDirection: String, CaseIterable, Identifiable, Sendable {
    case yours, theirs

    var id: String { rawValue }

    var title: String {
        switch self {
        case .yours: "Your commitment"
        case .theirs: "Their commitment"
        }
    }
}

nonisolated enum CommitmentStatus: Sendable {
    case open, done, snoozed, dismissed
}

nonisolated enum DueTone: Sendable {
    case overdue, today, soon, later, none
}

nonisolated struct Commitment: Identifiable, Hashable, Sendable {
    let id: String
    let direction: CommitmentDirection
    let person: Person
    let title: String
    /// The exact words from the email that created this commitment.
    let evidence: String
    /// Who said the evidence words ("You" or the other person's first name).
    let evidenceBy: String
    var due: Date?
    let threadID: String
    var status: CommitmentStatus = .open
    /// AI-drafted follow-up for someone else's overdue commitment.
    var followUp: String? = nil

    private var dayOffset: Int? {
        guard let due else { return nil }
        let cal = Calendar.current
        return cal.dateComponents([.day], from: cal.startOfDay(for: .now), to: cal.startOfDay(for: due)).day
    }

    var isOverdue: Bool { (dayOffset ?? 0) < 0 }
    var isDueTodayOrEarlier: Bool { dayOffset.map { $0 <= 0 } ?? false }
    var isDueToday: Bool { dayOffset == 0 }

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
        case ..<0: return "\(-days)d overdue"
        case 0: return "Due today"
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
    /// The commitment this message would complete, if any.
    var completes: String?
    /// An AI-drafted follow-up on someone else's commitment.
    var isFollowUp = false

    var title: String {
        if isFollowUp { return "Follow-up" }
        return threadID == nil ? "New Message" : "Reply"
    }

    static func new() -> ComposeDraft {
        ComposeDraft(threadID: nil, to: "", subject: "", body: "", completes: nil)
    }

    static func reply(to thread: MailThread, body: String = "", completes: String? = nil) -> ComposeDraft {
        ComposeDraft(
            threadID: thread.id,
            to: thread.counterpart.name,
            subject: thread.subject.hasPrefix("Re:") ? thread.subject : "Re: \(thread.subject)",
            body: body,
            completes: completes
        )
    }

    static func forward(_ thread: MailThread) -> ComposeDraft {
        ComposeDraft(threadID: nil, to: "", subject: "Fwd: \(thread.subject)", body: "", completes: nil)
    }
}

// MARK: - Navigation

nonisolated enum AppTab: Hashable, Sendable {
    case today, mail, settings, ask
}

/// One thing on Today: a commitment, or an email with no commitment attached (one that is waiting on a
/// reply, or an important update). A thread that has a commitment shows up once, as the commitment.
nonisolated struct TodayItem: Identifiable, Hashable, Sendable {
    let thread: MailThread
    let commitment: Commitment?

    var id: String { commitment?.id ?? "mail-\(thread.id)" }
    var due: Date? { commitment?.due }
    var isLate: Bool { commitment?.isOverdue ?? false }
    var isDueNow: Bool { commitment?.isDueTodayOrEarlier ?? false }
}

// MARK: - Brief, Ask, Toast

nonisolated struct Brief: Sendable {
    let greeting: String
    let dateLine: String
    /// Needs you: everything that is your move, and how much of it is overdue or due today.
    let needsYouCount: Int
    let overdueCount: Int
    let dueTodayCount: Int
    /// Waiting: everything that is someone else's move, and how much of it is overdue.
    let waitingCount: Int
    let waitingOverdueCount: Int
    /// Updates: the important ones only, and how many are unread.
    let updatesCount: Int
    let unreadUpdatesCount: Int
    let headline: String
    /// The top update, in one line.
    let worthKnowing: String?
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
    var undoCommitmentID: String? = nil
}
