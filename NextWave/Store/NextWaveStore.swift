import SwiftUI
import AudioToolbox

/// In-memory app state for the UX prototype. Throwaway: the real app
/// replaces this with Microsoft Graph + the Next Wave service.
@Observable
final class NextWaveStore {
    var threads: [MailThread] = MockThreads.all
    var commitments: [Commitment] = MockCommitments.all
    /// The mock calendar, and time held for commitments. Held time is private to the user.
    var events: [CalendarEvent] = MockCalendar.events
    var holds: [Hold] = MockCalendar.holds
    /// The holds made by the latest "Hold time", per commitment, so Undo can release exactly those.
    private var lastHolds: [String: [String]] = [:]
    /// Other people's commitments you have already followed up on in this session.
    var followedUp: Set<String> = []
    /// State from just before the latest one-tap send, so Undo can take the message back.
    private var beforeSend: (threads: [MailThread], commitments: [Commitment], followedUp: Set<String>)?
    /// True while the sync engine is receiving events. Shown as "Live" on Today.
    var isLive = false
    /// Bumped when mail that needs you arrives, so the app can tap you on the wrist.
    var arrivalTick = 0

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
        // A thread also drops out when it carries an open commitment on the other side: it is listed there.
        let covered = Set(commitments.filter { $0.status != .dismissed && ($0.direction == direction || $0.status == .open) }.map(\.threadID))
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

    // MARK: Sync

    /// Replaces the mailbox with a snapshot from the service and clears anything left from before.
    func load(_ snapshot: MailboxSnapshot) {
        withAnimation(.snappy) {
            threads = snapshot.threads
            commitments = snapshot.commitments
            events = snapshot.events
            holds = snapshot.holds
        }
        puffing = []
        followedUp = []
        lastHolds = [:]
        beforeSend = nil
        toast = nil
        mailFolder = .inbox
        mailBucket = .needsYou
    }

    /// Applies one event from the service.
    func apply(_ event: ServiceEvent) {
        // A commitment someone else delivered plays the same puff as one you mark done yourself.
        if case let .commitmentDone(id) = event, let commitment = commitment(id) {
            complete(id, announce: false)
            show(Toast(symbol: "checkmark.seal.fill", text: "\(commitment.person.firstName) delivered: \(commitment.title)"))
            return
        }
        var mailbox = MailboxSnapshot(threads: threads, commitments: commitments, events: events, holds: holds)
        let notice = mailbox.apply(event, at: AppClock.now)
        withAnimation(.snappy) {
            threads = mailbox.threads
            commitments = mailbox.commitments
            events = mailbox.events
        }
        guard let notice else { return }
        if notice.needsYou { arrivalTick += 1 }
        if notice.needsYou || !buzzOnlyForNeedsYou || notice.symbol.hasPrefix("calendar") {
            show(Toast(symbol: notice.symbol, text: notice.text))
        }
    }

    // MARK: Time

    /// Whether your commitments fit in the days in view. Recomputed from current state.
    var weekPlan: WeekPlan {
        WeekPlanner.plan(now: AppClock.now, commitments: commitments, events: events, holds: holds)
    }

    func commitments(atRiskIn plan: WeekPlan) -> [Commitment] {
        plan.atRisk.compactMap { commitment($0) }
    }

    /// True when there is planned open time for this commitment that isn't held yet.
    func canHoldTime(for commitment: Commitment, in plan: WeekPlan) -> Bool {
        commitment.direction == .yours && plan.fit(commitment.id) == .fits && !plan.slots(for: commitment.id).isEmpty
    }

    /// Turns the open time planned for a commitment into held time on the calendar.
    func holdTime(for id: String) {
        let pieces = weekPlan.slots(for: id)
        guard let commitment = commitment(id), !pieces.isEmpty else {
            show(Toast(symbol: "calendar.badge.exclamationmark", text: "No open time to hold"))
            return
        }
        let new = pieces.map { Hold(id: UUID().uuidString, commitmentID: id, start: $0.start, end: $0.end) }
        withAnimation(.snappy) { holds += new }
        lastHolds[id] = new.map(\.id)
        let minutes = new.reduce(0) { $0 + $1.minutes }
        show(Toast(symbol: "calendar.badge.checkmark", text: "Held \(Effort.text(minutes)): \(commitment.title)", undoHoldsFor: id))
    }

    /// A reply that asks for a later date and gives the reason as a fact. Sending it moves the due date.
    func newDateDraft(for commitment: Commitment) -> ComposeDraft? {
        guard let thread = thread(commitment.threadID), let due = commitment.due else { return nil }
        let newDue = WeekPlanner.earliestWorkableDue(for: commitment, now: AppClock.now, commitments: commitments,
                                                     events: events, holds: holds)
        let oldDay = due.formatted(.dateTime.weekday(.wide))
        let newDay = newDue.formatted(.dateTime.weekday(.wide))
        var reason = "I want to do this properly and I can't by \(oldDay)."
        if let effort = commitment.effort, case let .atRisk(open, _) = weekPlan.fit(commitment.id) {
            let have = open == 0 ? "no open time" : "\(Effort.text(open)) open"
            reason = "I want to do this properly, and the time isn't there before \(oldDay): it needs \(effort.label) and I have \(have), with other work due first."
        }
        var draft = ComposeDraft.reply(
            to: thread,
            body: "Hi \(commitment.person.firstName), \(reason) Could I get it to you by end of day \(newDay) instead? Thanks!"
        )
        draft.newDueFor = commitment.id
        draft.newDue = newDue
        return draft
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
        let hour = Calendar.current.component(.hour, from: AppClock.now)
        let part = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening"
        let mine = todayItems(.needsYou)
        let theirs = todayItems(.waiting)
        let updates = todayItems(.updates)
        let plan = weekPlan
        var weekLine = "Next 5 working days: \(Effort.total(plan.openMinutes)) open, \(Effort.total(plan.neededMinutes)) of commitments."
        if !plan.atRisk.isEmpty { weekLine += " \(plan.atRisk.count) at risk." }
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
            dateLine: AppClock.now.formatted(.dateTime.weekday(.wide).month(.wide).day()),
            needsYouCount: mine.count,
            overdueCount: mine.filter(\.isLate).count,
            dueTodayCount: mine.filter { $0.commitment?.isDueToday ?? false }.count,
            waitingCount: theirs.count,
            waitingOverdueCount: theirs.filter(\.isLate).count,
            updatesCount: updates.count,
            unreadUpdatesCount: updates.filter(\.thread.isUnread).count,
            headline: headline,
            weekLine: weekLine,
            atRiskCount: plan.atRisk.count,
            worthKnowing: updates.first?.thread.oneLiner
        )
    }

    // MARK: Commitment actions

    func complete(_ id: String, announce: Bool = true) {
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
            if announce {
                show(Toast(symbol: "checkmark.seal.fill", text: "Done: \(commitment(id)?.title ?? "")", undoCommitmentID: id))
            }
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

    func undo(_ toast: Toast) {
        if let id = toast.undoHoldsFor {
            let ids = Set(lastHolds[id] ?? [])
            withAnimation(.snappy) { holds.removeAll { ids.contains($0.id) } }
            lastHolds[id] = nil
            self.toast = nil
        }
        if toast.undoSend, let before = beforeSend {
            withAnimation(.snappy) {
                threads = before.threads
                commitments = before.commitments
                followedUp = before.followedUp
            }
            beforeSend = nil
            self.toast = nil
        }
        if let id = toast.undoCommitmentID { undo(id) }
    }

    // MARK: One-tap actions

    /// Sends a drafted reply in one tap. The user sees the text on the card before tapping, and can undo.
    /// `completing` is the commitment this reply finishes, if any.
    func quickSend(_ text: String, on threadID: String, completing commitmentID: String? = nil) {
        guard let thread = thread(threadID) else { return }
        beforeSend = (threads, commitments, followedUp)
        // Name the person the reply is for, who is not always the last person to write on the thread.
        let name = commitmentID.flatMap { commitment($0)?.person.firstName } ?? thread.counterpart.firstName
        withAnimation(.snappy) { appendReply(text, to: threadID) }
        if let commitmentID { complete(commitmentID, announce: false) }
        show(Toast(symbol: "paperplane.fill", text: "Sent to \(name)", undoSend: true))
    }

    /// Sends the drafted follow-up for someone else's overdue commitment in one tap.
    func sendFollowUp(for commitment: Commitment) {
        guard let draft = followUpDraft(for: commitment), let threadID = draft.threadID else { return }
        beforeSend = (threads, commitments, followedUp)
        withAnimation(.snappy) {
            mutate(threadID) { thread in
                thread.messages.append(Message(id: UUID().uuidString, from: MockPeople.me, date: AppClock.now, body: draft.body))
                thread.oneLiner = "You followed up just now. Still waiting on \(commitment.person.firstName)."
            }
            followedUp.insert(commitment.id)
        }
        show(Toast(symbol: "paperplane.fill", text: "Follow-up sent to \(commitment.person.firstName)", undoSend: true))
    }

    private func appendReply(_ body: String, to threadID: String) {
        mutate(threadID) { thread in
            thread.messages.append(Message(id: UUID().uuidString, from: MockPeople.me, date: AppClock.now, body: body))
            // Once you've replied, the ball is in their court.
            if thread.bucket == .needsYou { thread.bucket = .waiting }
            thread.isUnread = false
            thread.suggestedReplies = []
            thread.quickReply = nil
            thread.stands = "You replied just now. The ball is in \(thread.counterpart.firstName)'s court, and Outlook will tell you if they go quiet."
            thread.oneLiner = "You replied. Waiting on \(thread.counterpart.firstName)."
        }
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
            withAnimation(.snappy) { appendReply(body, to: threadID) }
        } else {
            let thread = MailThread(
                id: UUID().uuidString,
                subject: draft.subject.isEmpty ? "(No subject)" : draft.subject,
                bucket: .waiting,
                folder: .sent,
                isUnread: false,
                oneLiner: "You wrote to \(draft.to.isEmpty ? "someone" : draft.to).",
                stands: "Waiting on a reply.",
                messages: [Message(id: UUID().uuidString, from: MockPeople.me, date: AppClock.now, body: body)]
            )
            threads.append(thread)
        }

        if let commitmentID = draft.completes {
            Task {
                try? await Task.sleep(for: .milliseconds(450))
                complete(commitmentID)
            }
        } else if let commitmentID = draft.newDueFor, let newDue = draft.newDue,
                  let i = commitments.firstIndex(where: { $0.id == commitmentID }) {
            withAnimation(.snappy) { commitments[i].due = newDue }
            show(Toast(symbol: "calendar.badge.clock", text: "New date proposed: \(newDue.formatted(.dateTime.weekday(.wide)))"))
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
