import Foundation

/// A synthetic mailbox for the proof of concept: Vivek's inbox on a fictional Outlook Mobile team at
/// Microsoft, in the weeks before a fictional release called Sandpiper. Times are relative to "now" so
/// the demo always looks fresh. People, projects and numbers are invented; see `MockPeople`.
///
/// The threads live in the `MockThreads+….swift` files next to this one, grouped by triage bucket.
enum MockThreads {
    static func thread(
        _ id: String,
        _ subject: String,
        bucket: TriageBucket,
        folder: Folder = .inbox,
        important: Bool = false,
        unread: Bool = false,
        flagged: Bool = false,
        attachment: Bool = false,
        oneLiner: String,
        stands: String,
        replies: [String] = [],
        quick: QuickReply? = nil,
        messages: [(Person, Double, String)]
    ) -> MailThread {
        MailThread(
            id: id,
            subject: subject,
            bucket: bucket,
            folder: folder,
            isUnread: unread,
            isFlagged: flagged,
            hasAttachment: attachment,
            isImportant: important,
            oneLiner: oneLiner,
            stands: stands,
            suggestedReplies: replies,
            quickReply: quick,
            messages: messages.enumerated().map { index, item in
                Message(id: "\(id)-\(index)", from: item.0, date: MockClock.ago(item.1), body: item.2)
            }
        )
    }

    static var all: [MailThread] {
        needsYouDeals + needsYouLaunch + needsYouPeople
            + waitingPartners + waitingInternal
            + updatesLaunch + updatesCompany
            + notificationsCollab + notificationsWork + notificationsOutside
            + filed
    }
}
