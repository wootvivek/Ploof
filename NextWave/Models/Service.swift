import Foundation

// The contract between the app and the middle tier. A real Next Wave service will push the same
// shapes; today `DemoService` plays them from a script.

/// Everything the service knows about one mailbox at a moment in time.
nonisolated struct MailboxSnapshot: Sendable {
    var threads: [MailThread]
    var commitments: [Commitment]
    var events: [CalendarEvent]
    var holds: [Hold]
}

/// What triage says about a thread. Arrives with new mail and again whenever a thread changes.
nonisolated struct Annotation: Sendable {
    var bucket: TriageBucket
    var isImportant = false
    var hasAttachment = false
    var oneLiner: String
    var stands: String
    var suggestedReplies: [String] = []
    var quickReply: QuickReply? = nil

    init(bucket: TriageBucket, isImportant: Bool = false, hasAttachment: Bool = false, oneLiner: String,
         stands: String, suggestedReplies: [String] = [], quickReply: QuickReply? = nil) {
        self.bucket = bucket
        self.isImportant = isImportant
        self.hasAttachment = hasAttachment
        self.oneLiner = oneLiner
        self.stands = stands
        self.suggestedReplies = suggestedReplies
        self.quickReply = quickReply
    }

    /// The annotation a thread already carries.
    init(_ thread: MailThread) {
        self.init(bucket: thread.bucket, isImportant: thread.isImportant, hasAttachment: thread.hasAttachment,
                  oneLiner: thread.oneLiner, stands: thread.stands, suggestedReplies: thread.suggestedReplies,
                  quickReply: thread.quickReply)
    }

    func applied(to thread: MailThread) -> MailThread {
        var copy = thread
        copy.bucket = bucket
        copy.isImportant = isImportant
        copy.hasAttachment = hasAttachment
        copy.oneLiner = oneLiner
        copy.stands = stands
        copy.suggestedReplies = suggestedReplies
        copy.quickReply = quickReply
        return copy
    }
}

/// One thing the service tells the app.
nonisolated enum ServiceEvent: Sendable {
    /// A new thread, already triaged.
    case mail(MailThread)
    /// New messages on a thread the app already has, with the thread's refreshed annotation.
    case reply(threadID: String, messages: [Message], annotation: Annotation)
    /// A commitment found in mail. Arrives a few seconds after the mail it came from.
    case commitmentFound(Commitment)
    /// A commitment the service saw fulfilled, usually by the other person delivering.
    case commitmentDone(id: String)
    case meetingAdded(CalendarEvent)
    case meetingCanceled(id: String)
}

/// Something worth telling the user about when an event lands.
nonisolated struct Notice: Sendable {
    let symbol: String
    let text: String
    /// True when it should interrupt (mail that needs you). Everything else arrives quietly.
    let needsYou: Bool
}

extension MailboxSnapshot {
    /// Applies one event. New mail is stamped with `now`, so arrival times are true to the clock.
    @discardableResult
    mutating func apply(_ event: ServiceEvent, at now: Date) -> Notice? {
        switch event {
        case .mail(var thread):
            // Keep the spacing between a thread's messages, with the newest landing now.
            let shift = now.timeIntervalSince(thread.lastDate)
            thread.messages = thread.messages.map { Message(id: $0.id, from: $0.from, date: $0.date.addingTimeInterval(shift), body: $0.body) }
            thread.isUnread = true
            threads.removeAll { $0.id == thread.id }
            threads.append(thread)
            return notice(for: thread)

        case let .reply(threadID, messages, annotation):
            guard let i = threads.firstIndex(where: { $0.id == threadID }) else { return nil }
            var thread = annotation.applied(to: threads[i])
            for (offset, message) in messages.enumerated() {
                // If several arrive together, space them a minute apart, ending now.
                let date = now.addingTimeInterval(-60 * Double(messages.count - 1 - offset))
                thread.messages.append(Message(id: message.id, from: message.from, date: date, body: message.body))
            }
            thread.isUnread = true
            thread.folder = .inbox
            threads[i] = thread
            return notice(for: thread)

        case let .commitmentFound(commitment):
            guard !commitments.contains(where: { $0.id == commitment.id }) else { return nil }
            commitments.append(commitment)
            return nil

        case let .commitmentDone(id):
            guard let i = commitments.firstIndex(where: { $0.id == id }) else { return nil }
            commitments[i].status = .done
            return Notice(symbol: "checkmark.seal.fill",
                          text: "\(commitments[i].person.firstName) delivered: \(commitments[i].title)", needsYou: false)

        case let .meetingAdded(event):
            events.removeAll { $0.id == event.id }
            events.append(event)
            return Notice(symbol: "calendar.badge.plus", text: "Added to your calendar: \(event.title)", needsYou: false)

        case let .meetingCanceled(id):
            guard let i = events.firstIndex(where: { $0.id == id }) else { return nil }
            let title = events[i].title
            events.remove(at: i)
            return Notice(symbol: "calendar.badge.minus", text: "Canceled: \(title)", needsYou: false)
        }
    }

    private func notice(for thread: MailThread) -> Notice? {
        guard thread.bucket == .needsYou else { return nil }
        return Notice(symbol: TriageBucket.needsYou.symbol, text: "Needs you: \(thread.counterpart.name)", needsYou: true)
    }
}
