import Foundation

/// A synthetic enterprise mailbox for the proof of concept: Vivek's inbox at Contoso
/// in the weeks before the Mark 8 launch. Times are relative to "now" so the demo always looks fresh.
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
