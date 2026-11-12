import Foundation

/// The demo's script: where the mailbox starts, and what arrives over a ten-minute run.
///
/// It is cut from the full mock mailbox rather than written separately. Some threads are held back and
/// arrive during the run; some start a message or two short and get their latest reply during the run;
/// three of other people's commitments are delivered; one meeting is added and one is canceled.
/// By the last beat the mailbox equals the full mock mailbox plus those changes.
enum DemoScenario {
    private typealias P = MockPeople
    private typealias C = MockClock

    /// One scripted moment. `at` is in seconds from the start of a run of `length` seconds.
    nonisolated struct Beat: Sendable {
        let at: TimeInterval
        let event: ServiceEvent
    }

    static let length: TimeInterval = 600
    /// How long after its mail a commitment shows up: the slower, more careful model.
    private static let commitmentLag: TimeInterval = 5

    static func build() -> (start: MailboxSnapshot, beats: [Beat]) {
        var threads = MockThreads.all
        var commitments = MockCommitments.all
        var beats: [Beat] = []

        func full(_ id: String) -> MailThread {
            guard let thread = threads.first(where: { $0.id == id }) else { preconditionFailure("no thread \(id)") }
            return thread
        }
        /// Holds a commitment back from the start and has it found shortly after `t`.
        func find(_ ids: [String], after t: TimeInterval) {
            for id in ids {
                guard let i = commitments.firstIndex(where: { $0.id == id }) else { preconditionFailure("no commitment \(id)") }
                beats.append(Beat(at: t + commitmentLag, event: .commitmentFound(commitments.remove(at: i))))
            }
        }
        /// The whole thread arrives at `t`.
        func arrives(_ id: String, at t: TimeInterval, found: [String] = []) {
            let thread = full(id)
            threads.removeAll { $0.id == id }
            beats.append(Beat(at: t, event: .mail(thread)))
            find(found, after: t)
        }
        /// The thread starts with its first `keep` messages and `before` as its annotation.
        /// The rest of its messages, and its real annotation, arrive at `t`.
        func repliedTo(_ id: String, at t: TimeInterval, keep: Int, before: Annotation, found: [String] = []) {
            guard let i = threads.firstIndex(where: { $0.id == id }) else { preconditionFailure("no thread \(id)") }
            let thread = threads[i]
            var early = before.applied(to: thread)
            early.messages = Array(thread.messages.prefix(keep))
            early.isUnread = false
            threads[i] = early
            beats.append(Beat(at: t, event: .reply(threadID: id, messages: Array(thread.messages.dropFirst(keep)),
                                                   annotation: Annotation(thread))))
            find(found, after: t)
        }
        /// Someone delivers what they committed to: a new message on their thread, then the commitment is done.
        func delivers(_ commitmentID: String, at t: TimeInterval, body: String, oneLiner: String, stands: String, reply: String) {
            guard let commitment = commitments.first(where: { $0.id == commitmentID }) else { preconditionFailure("no commitment \(commitmentID)") }
            let message = Message(id: "\(commitment.threadID)-delivered", from: commitment.person, date: .distantPast, body: body)
            beats.append(Beat(at: t, event: .reply(
                threadID: commitment.threadID, messages: [message],
                annotation: Annotation(bucket: .updates, isImportant: true, hasAttachment: true,
                                       oneLiner: oneLiner, stands: stands, suggestedReplies: [reply]))))
            beats.append(Beat(at: t + 3, event: .commitmentDone(id: commitmentID)))
        }

        // 0:10  The day starts quietly.
        arrives("teams-missed", at: 10)

        // 0:25  The escalation lands, and half a minute later engineering reports progress.
        let escalation = full("nw-escalation")
        var firstReport = Annotation(escalation)
        firstReport.stands = "About 9,200 Android devices at Northwind stopped syncing shared mailboxes after build 4.2446 reached their ring. Robin is waiting on your approval of the customer note before it goes to Charlotte's team."
        var opening = firstReport.applied(to: escalation)
        opening.messages = Array(escalation.messages.prefix(1))
        threads.removeAll { $0.id == "nw-escalation" }
        beats.append(Beat(at: 25, event: .mail(opening)))
        find(["p-outage"], after: 25)
        arrives("teams-voicemail", at: 50)
        beats.append(Beat(at: 90, event: .reply(threadID: "nw-escalation", messages: Array(escalation.messages.dropFirst(1)),
                                                annotation: Annotation(escalation))))

        // 1:10  Debra chases the board section you said you'd send.
        repliedTo("board-deck", at: 70, keep: 2, before: Annotation(
            bucket: .waiting,
            oneLiner: "You told Patti you'd send the Sandpiper section by end of day today.",
            stands: "You told Patti and Debra you'd deliver the Sandpiper section by end of day today. The leadership review is \(C.wd(2))."))

        arrives("powerbi", at: 120)

        // 2:20  Pradeep delivers, late. His commitment closes without you doing anything.
        delivers("p-unitcost", at: 140,
                 body: "Revised cost-per-user model attached. With RC3's smaller speech model and the new usage assumption, cost per user is down 12%. Sorry this took an extra day.",
                 oneLiner: "Pradeep sent the revised cost model. Cost per user is down 12% with RC3.",
                 stands: "Delivered. Pradeep's revised model is attached, so the leadership forecast slide can use it.",
                 reply: "Thanks Pradeep, exactly what I needed.")

        // 2:50  Charlotte adds to what you already committed to.
        repliedTo("nw-pricing", at: 170, keep: 3, before: Annotation(
            bucket: .waiting,
            oneLiner: "Charlotte is waiting for the rollout plan at 5,000 and 8,000 devices by \(C.wd(2)).",
            stands: "You committed to sending Charlotte the rollout plan at both wave sizes by \(C.wd(2)), ahead of Northwind's steering committee on \(C.wd(3)). Nothing has been sent yet."))

        arrives("offer-cameron", at: 200, found: ["p-offer"])
        arrives("build-notes", at: 230)

        // 4:10  A meeting is put on your calendar. The plan for today tightens.
        beats.append(Beat(at: 250, event: .meetingAdded(
            CalendarEvent(id: "e-dryrun", title: "Leadership dry run with Patti", start: C.at(0, 16, 0), end: C.at(0, 16, 30)))))
        beats.append(Beat(at: 251, event: .mail(MockThreads.thread(
            "dry-run", "Added to your calendar: Leadership dry run, today 4:00 PM", bucket: .updates, important: true,
            oneLiner: "Debra added a 30-minute dry run with Patti today at 4:00 PM.",
            stands: "Patti wants a dry run of the Sandpiper section before the pre-read goes out. It's on your calendar, and there is nothing to reply to.",
            messages: [(P.debra, 0, "Vivek, Patti would like a 30-minute dry run of the Sandpiper section today at 4:00, before the pre-read goes out. I've put it on your calendar.")]))))

        // 4:50  Megan delivers the number your budget was waiting for.
        delivers("p-mktnumber", at: 290,
                 body: "Final number for launch marketing is $1.84M, down from $2.1M. Miriam signed off this morning.",
                 oneLiner: "Megan sent the FY27 marketing number: $1.84M.",
                 stands: "Delivered. You have what you need to finish the budget submission.",
                 reply: "Thanks Megan. Putting it in now.")

        arrives("expense-lidia", at: 320)

        // 5:50  More work arrives than Wednesday has room for.
        arrives("roadmap-h1", at: 350, found: ["p-roadmap"])

        repliedTo("ref-slide", at: 380, keep: 2, before: Annotation(
            bucket: .waiting,
            oneLiner: "You told Isaiah you'd send the Adventure Works slide today.",
            stands: "You told Isaiah you'd send the reference customer slide today, once Ray confirms the final numbers."))

        // 7:00  Erik's request brings a chain: write before the 1:1, follow up after it.
        arrives("erik-1on1", at: 420, found: ["p-risk"])

        repliedTo("comp-brief", at: 450, keep: 2, before: Annotation(
            bucket: .waiting,
            oneLiner: "You told Miriam you'd send the VanArsdel brief by \(C.wd(-1)). It's overdue.",
            stands: "You committed to sending Miriam a one-page brief on VanArsdel Mail 3 by \(C.wd(-1)), so it's overdue."))

        arrives("lucerne-brief", at: 475)

        delivers("p-sitedata", at: 500,
                 body: "Export attached: weekly use for all six pilot sites. The two canyon sites are at 61%, and the other four are above 80%.",
                 oneLiner: "Kristin sent pilot usage by site. The canyon sites are at 61% weekly use.",
                 stands: "Delivered, a day early. The site-level numbers are attached for the leadership slide.",
                 reply: "Thank you, Kristin. This is perfect.")

        // 8:40  A meeting is canceled. An hour opens up on its day.
        beats.append(Beat(at: 520, event: .meetingCanceled(id: "e-proseware")))
        beats.append(Beat(at: 521, event: .mail(MockThreads.thread(
            "proseware-canceled", "Canceled: Proseware creative review", bucket: .updates, important: true,
            oneLiner: "Serena canceled \(C.wd(2))'s creative review. That frees an hour on your calendar.",
            stands: "The review is off until you've picked a creative direction. Nothing to do, and \(C.wd(2)) afternoon has an hour back.",
            messages: [(P.serena, 0, "We're moving the creative review until after you've picked a direction, so I've canceled \(C.wd(2))'s session. Sorry for the late change.")]))))

        // 9:10  A thread you were only copied on turns into a decision for you.
        repliedTo("fab-revc", at: 550, keep: 2, before: Annotation(
            bucket: .updates,
            oneLiner: "Release candidate 2 came in at 99.1% crash-free. Lee recommends RC3.",
            stands: "Release candidate 2 came in at 99.1% crash-free sessions against a 99.6% target because of the attachment preview cache. RC3 fixes it and adds four days. Lee recommends taking it. Nobody has asked you for a decision yet."),
            found: ["p-revc"])

        arrives("vpn-maintenance", at: 580)

        beats.sort { $0.at < $1.at }
        return (MailboxSnapshot(threads: threads, commitments: commitments, events: MockCalendar.events, holds: MockCalendar.holds), beats)
    }
}
