import SwiftUI
import AudioToolbox

/// In-memory app state for the UX prototype. Throwaway: the real app
/// replaces this with Microsoft Graph + the Next Wave service.
@Observable
final class NextWaveStore {
    var threads: [MailThread] = MockThreads.all
    var commitments: [Commitment] = MockCommitments.all

    // Navigation state that other screens can drive
    var selectedTab: AppTab = .today
    var mailBucket: TriageBucket? = .needsYou
    var mailFolder: Folder = .inbox

    /// Commitments currently playing the puff complete animation.
    var puffing: Set<String> = []
    /// Bumped on every complete so views can fire haptics.
    var doneTick = 0
    var toast: Toast?

    // Prototype settings
    var smartTriage = true
    var commitmentsOn = true
    var doneSound = true
    var buzzOnlyForNeedsYou = true
    var morningBrief = true

    // MARK: Lookups

    func thread(_ id: String) -> MailThread? {
        threads.first { $0.id == id }
    }

    func threads(in folder: Folder, bucket: TriageBucket?) -> [MailThread] {
        threads
            .filter { $0.folder == folder && (bucket == nil || $0.bucket == bucket) }
            .sorted { $0.lastDate > $1.lastDate }
    }

    func count(_ bucket: TriageBucket) -> Int {
        threads.filter { $0.folder == .inbox && $0.bucket == bucket }.count
    }

    func count(in folder: Folder) -> Int {
        threads.filter { $0.folder == folder }.count
    }

    var unreadNeedsYou: Int {
        threads.filter { $0.folder == .inbox && $0.bucket == .needsYou && $0.isUnread }.count
    }

    /// Open commitments in one direction: overdue first, then soonest due, undated last.
    func openCommitments(_ direction: CommitmentDirection) -> [Commitment] {
        commitments
            .filter { $0.direction == direction && ($0.status == .open || puffing.contains($0.id)) }
            .sorted { a, b in
                switch (a.due, b.due) {
                case let (x?, y?): x < y
                case (.some, .none): true
                case (.none, .some): false
                case (.none, .none): a.title < b.title
                }
            }
    }

    /// Today's list for one section. Needs you and Waiting merge the open commitments on that side with
    /// the inbox emails in that bucket that have no commitment attached: dated items first (overdue, then
    /// soonest), then the rest, newest mail first. Updates shows only the important ones, unread first.
    func todayItems(_ section: TriageBucket) -> [TodayItem] {
        switch section {
        case .needsYou: return actionItems(direction: .yours, bucket: .needsYou)
        case .waiting: return actionItems(direction: .theirs, bucket: .waiting)
        case .updates:
            return threads
                .filter { $0.folder == .inbox && $0.isImportant && ($0.bucket == .updates || $0.bucket == .notifications) }
                .sorted { a, b in a.isUnread != b.isUnread ? a.isUnread : a.lastDate > b.lastDate }
                .map { TodayItem(thread: $0, commitment: nil) }
        case .notifications: return []
        }
    }

    private func actionItems(direction: CommitmentDirection, bucket: TriageBucket) -> [TodayItem] {
        let committed = openCommitments(direction).compactMap { commitment in
            thread(commitment.threadID).map { TodayItem(thread: $0, commitment: commitment) }
        }
        // An email drops off this list once its commitment is done or snoozed; "not a commitment" keeps it.
        let covered = Set(commitments.filter { $0.direction == direction && $0.status != .dismissed }.map(\.threadID))
        let mailOnly = threads(in: .inbox, bucket: bucket)
            .filter { !covered.contains($0.id) }
            .map { TodayItem(thread: $0, commitment: nil) }

        return (committed + mailOnly).sorted { a, b in
            switch (a.due, b.due) {
            case let (x?, y?) where x != y: x < y
            case (.some, .none): true
            case (.none, .some): false
            default: a.thread.lastDate > b.thread.lastDate
            }
        }
    }

    /// Jump to the Mail tab with a triage filter applied.
    func openMail(_ bucket: TriageBucket?) {
        mailFolder = .inbox
        mailBucket = bucket
        selectedTab = .mail
    }

    func followUpDraft(for commitment: Commitment) -> ComposeDraft? {
        guard let thread = thread(commitment.threadID) else { return nil }
        let body = commitment.followUp
            ?? "Hi \(commitment.person.firstName), following up on this one. Thanks!"
        var draft = ComposeDraft.reply(to: thread, body: body)
        draft.isFollowUp = true
        return draft
    }

    func openCommitments(inThread threadID: String) -> [Commitment] {
        commitments.filter { $0.threadID == threadID && ($0.status == .open || puffing.contains($0.id)) }
    }

    func commitment(_ id: String) -> Commitment? {
        commitments.first { $0.id == id }
    }

    func search(_ query: String) -> [MailThread] {
        let stop: Set<String> = ["what", "when", "whos", "about", "with", "from", "that", "this", "have",
                                 "does", "said", "summarize", "where", "which", "there", "your"]
        let tokens = query.lowercased()
            .components(separatedBy: CharacterSet.alphanumerics.inverted)
            .filter { $0.count > 3 && !stop.contains($0) }
        guard !tokens.isEmpty else { return [] }
        return threads
            .filter { t in
                let haystack = ([t.subject, t.oneLiner, t.counterpart.name] + t.messages.map(\.body))
                    .joined(separator: " ")
                    .lowercased()
                return tokens.contains { haystack.contains($0) }
            }
            .sorted { $0.lastDate > $1.lastDate }
    }

    var brief: Brief {
        let hour = Calendar.current.component(.hour, from: .now)
        let part = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        let mine = todayItems(.needsYou)
        let theirs = todayItems(.waiting)
        let updates = todayItems(.updates)
        let headline: String
        if let commitment = mine.first?.commitment {
            headline = "Start with: \(commitment.title.prefix(1).lowercased() + commitment.title.dropFirst()). \(commitment.person.firstName) is waiting."
        } else if let thread = mine.first?.thread {
            headline = "Start with \(thread.counterpart.firstName)'s email: \(thread.subject)."
        } else {
            headline = "You're all caught up. Nothing needs you."
        }
        return Brief(
            greeting: "\(part), \(MockPeople.me.firstName)",
            dateLine: Date.now.formatted(.dateTime.weekday(.wide).month(.wide).day()),
            needsYouCount: mine.count,
            overdueCount: mine.filter(\.isLate).count,
            dueTodayCount: mine.filter { $0.commitment?.isDueToday ?? false }.count,
            waitingCount: theirs.count,
            waitingOverdueCount: theirs.filter(\.isLate).count,
            updatesCount: updates.count,
            unreadUpdatesCount: updates.filter(\.thread.isUnread).count,
            headline: headline,
            worthKnowing: updates.first?.thread.oneLiner
        )
    }

    // MARK: Commitment actions

    func complete(_ id: String) {
        guard commitment(id)?.status == .open, !puffing.contains(id) else { return }
        puffing.insert(id)
        doneTick += 1
        if doneSound { AudioServicesPlaySystemSound(1001) }
        Task {
            try? await Task.sleep(for: .milliseconds(520))
            withAnimation(.snappy) {
                setStatus(id, .done)
                puffing.remove(id)
            }
            show(Toast(symbol: "checkmark.seal.fill", text: "Done: \(commitment(id)?.title ?? "")", undoCommitmentID: id))
        }
    }

    func snooze(_ id: String) {
        withAnimation(.snappy) { setStatus(id, .snoozed) }
        show(Toast(symbol: "moon.zzz.fill", text: "Snoozed until tomorrow", undoCommitmentID: id))
    }

    func dismiss(_ id: String) {
        withAnimation(.snappy) { setStatus(id, .dismissed) }
        show(Toast(symbol: "hand.thumbsdown.fill", text: "Got it. Outlook will learn from this.", undoCommitmentID: id))
    }

    func undo(_ id: String) {
        withAnimation(.snappy) { setStatus(id, .open) }
        toast = nil
    }

    private func setStatus(_ id: String, _ status: CommitmentStatus) {
        guard let i = commitments.firstIndex(where: { $0.id == id }) else { return }
        commitments[i].status = status
    }

    // MARK: Mail actions

    func archive(_ id: String) {
        move(id, to: .archive)
        show(Toast(symbol: "archivebox.fill", text: "Archived"))
    }

    func delete(_ id: String) {
        move(id, to: .deleted)
        show(Toast(symbol: "trash.fill", text: "Deleted"))
    }

    func toggleFlag(_ id: String) {
        mutate(id) { $0.isFlagged.toggle() }
    }

    func toggleRead(_ id: String) {
        mutate(id) { $0.isUnread.toggle() }
    }

    func markRead(_ id: String) {
        guard thread(id)?.isUnread == true else { return }
        mutate(id) { $0.isUnread = false }
    }

    func send(_ draft: ComposeDraft) {
        let body = draft.body.trimmingCharacters(in: .whitespacesAndNewlines)
        if let threadID = draft.threadID {
            withAnimation(.snappy) {
                mutate(threadID) { thread in
                    thread.messages.append(Message(id: UUID().uuidString, from: MockPeople.me, date: .now, body: body))
                    // Once you've replied, the ball is in their court.
                    if thread.bucket == .needsYou { thread.bucket = .waiting }
                    thread.isUnread = false
                    thread.suggestedReplies = []
                    thread.stands = "You replied just now. The ball is in \(thread.counterpart.firstName)'s court, and Outlook will tell you if they go quiet."
                    thread.oneLiner = "You replied. Waiting on \(thread.counterpart.firstName)."
                }
            }
        } else {
            let thread = MailThread(
                id: UUID().uuidString,
                subject: draft.subject.isEmpty ? "(No subject)" : draft.subject,
                bucket: .waiting,
                folder: .sent,
                isUnread: false,
                oneLiner: "You wrote to \(draft.to.isEmpty ? "someone" : draft.to).",
                stands: "Waiting on a reply.",
                messages: [Message(id: UUID().uuidString, from: MockPeople.me, date: .now, body: body)]
            )
            threads.append(thread)
        }

        if let commitmentID = draft.completes {
            Task {
                try? await Task.sleep(for: .milliseconds(450))
                complete(commitmentID)
            }
        } else {
            show(Toast(symbol: "paperplane.fill", text: "Sent"))
        }
    }

    private func move(_ id: String, to folder: Folder) {
        withAnimation(.snappy) { mutate(id) { $0.folder = folder } }
    }

    private func mutate(_ id: String, _ change: (inout MailThread) -> Void) {
        guard let i = threads.firstIndex(where: { $0.id == id }) else { return }
        change(&threads[i])
    }

    // MARK: Toast

    func show(_ toast: Toast) {
        withAnimation(.snappy) { self.toast = toast }
    }
}
