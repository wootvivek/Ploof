import Foundation

/// Scripted "Ask Outlook" answers for the proof of concept.
enum MockAsk {
    private typealias C = MockClock

    struct Script {
        let keywords: [String]
        let answer: String
        let citations: [String]
    }

    static let suggestions = [
        "Where does the Northwind rollout stand?",
        "What does Patti need from me?",
        "What is overdue from other people?",
        "What's blocking the Sandpiper release review?",
        "Do I have time for everything this week?",
        "Summarize my day",
    ]

    /// Checked in order, so the more specific scripts come first.
    private static var scripts: [Script] {
        [
            Script(keywords: ["escalation", "shared mailbox", "sync fault", "not syncing", "sev a"],
                   answer: "About 9,200 Android devices at Northwind stopped syncing shared mailboxes last night after build 4.2446 reached their ring. Engineering is rolling back, and build 4.2447 with the fix goes to the preview ring \(C.wd(2)). Robin is waiting for you to approve the customer note, and Charlotte left a voicemail asking for a call before noon.",
                   citations: ["nw-escalation", "teams-voicemail", "build-notes"]),
            Script(keywords: ["northwind", "charlotte", "pilot agreement"],
                   answer: "Three things are open with Northwind. Legal needs your decision on transcript retention and Sev A response time by \(C.wd(1)). You committed to sending Charlotte the rollout plan at 5,000 and 8,000 devices by \(C.wd(2)), now with delegate mailboxes, before her steering committee on \(C.wd(3)). Their security review of your questionnaire runs until about \(C.md(7)). Separately, their shared mailboxes stopped syncing this morning and the build is being rolled back.",
                   citations: ["nw-msa", "nw-pricing", "nw-questionnaire", "nw-escalation"]),
            Script(keywords: ["patti", "leadership review", "pre-read"],
                   answer: "You have one commitment to Patti: the Sandpiper section for the leadership review, due today. She asked for release readiness, pilot results and the revised adoption forecast. Debra wants it in the new template, five slides at most, because the pre-read goes out tonight. One dependency is overdue: Pradeep's revised cost model.",
                   citations: ["board-deck", "unit-cost"]),
            Script(keywords: ["overdue", "late on", "who's late", "whos late", "owes me", "owed to me", "waiting on"],
                   answer: "Five commitments to you are overdue: the release dashboard link from Daisy, the root cause report for the RC2 crash from Lydia at Fabrikam, a revised estimate from Miguel at Proseware, the cost model from Pradeep, and the localization quotes from Daichi. I've drafted a follow-up for each.",
                   citations: ["dashboard", "fab-8d", "proseware-estimate", "unit-cost", "freight"]),
            Script(keywords: ["release review", "blocking", "blocker", "release risk", "readiness", "ship"],
                   answer: "Three items stand between you and the release review on \(C.md(9)). Android crash rate: Fabrikam needs your go-ahead on RC3 by \(C.wd(1)), which costs four days. Security: three pen-test findings need owners by \(C.wd(2)), and the fix for the high one is already merged. Accessibility: the second conformance run passed, and the lab's final report is due \(C.md(5)).",
                   citations: ["launch-gate", "fab-revc", "sec-review", "cert-status"]),
            Script(keywords: ["approval", "approve", "nda", "sow"],
                   answer: "Four approvals are waiting on you. Cameron Evans's Senior PM offer (a competing offer expires \(C.wd(2))), the $86,000 Southridge Video SOW, Lidia's $2,418.60 expense report, and the Wingtip Toys NDA, which needs your signature before their kickoff on \(C.wd(3)).",
                   citations: ["offer-cameron", "sow-southridge", "expense-lidia", "nda-wingtip"]),
            Script(keywords: ["pilot", "adventure works", "tanaka", "voice"],
                   answer: "The Adventure Works pilot put voice catch-up in the hands of 380 field staff for 9 weeks, with 99.2% crash-free sessions and 17% more mail cleared before the first job of the day. Before a full rollout, Ray wants offline playback for the canyon sites and support in the truck's dashboard. Elvia proposed \(C.wd(2)) at 10 for the review, and Kristin is sending usage by site.",
                   citations: ["aw-pilot", "aw-sitedata", "customer-quote"]),
            Script(keywords: ["user study", "trey", "research"],
                   answer: "Trey Research studied 412 mobile users. People use voice catch-up for sessions of up to four minutes and drop off sharply after six. Katri offered \(C.wd(2)) at 2 PM or \(C.wd(3)) at 11 AM for the full readout, and Mona's synthesis of the frontline interviews is due \(C.wd(3)).",
                   citations: ["trey-readout", "research-synthesis"]),
            Script(keywords: ["vanarsdel", "competit"],
                   answer: "VanArsdel announced Mail 3 with AI triage and a daily summary, for a separate $8 per user per month, and only for its own mailboxes. You committed to a one-page competitive brief on it for Miriam. That was due \(C.wd(-1)), and she presents to the field \(C.wd(1)).",
                   citations: ["vanarsdel-v3", "comp-brief"]),
            Script(keywords: ["flight", "chicago", "trip", "travel"],
                   answer: "You fly Blue Yonder Airlines BY 1482 from Seattle to Chicago on \(C.md(6)), departing 7:10 AM and arriving 1:05 PM, seat 12C. The confirmation code is R4TQ9M. Your hotel is two nights, a short walk from Northwind's headquarters.",
                   citations: ["itinerary", "eticket"]),
            Script(keywords: ["offsite"],
                   answer: "The leadership offsite is at Alpine Ski House, \(C.md(15)) to \(C.md(16)). You're presenting a 45-minute session, 'Sandpiper: the first 100 days'. Debra needs your session title, AV needs and dietary restrictions by \(C.wd(3)).",
                   citations: ["offsite", "alpine-booking"]),
            Script(keywords: ["budget", "fy27", "emily"],
                   answer: "Your FY27 budget for cost center 4410 is due \(C.wd(1)), when Finance locks the first pass. You need Megan's final marketing number to finish it, and she said she would send it today. Carlos is also still reviewing your $310K capex request for the device lab.",
                   citations: ["budget-fy27", "mkt-number", "capex-fixtures"]),
            Script(keywords: ["fabrikam", "crash", "rc3", "release candidate"],
                   answer: "Release candidate 2 came in at 99.1% crash-free sessions against a 99.6% target because of the attachment preview cache on low-memory Android devices. RC3 fixes it and adds four days to the test pass. Lee recommends taking it, and Mauricio needs your written go-ahead by \(C.wd(1)). Lydia's root cause report is overdue.",
                   citations: ["fab-revc", "fab-8d", "fab-po"]),
        ]
    }

    /// Computed from the same planner Today uses, so the numbers always agree with the week screen.
    private static var weekFit: Script {
        let commitments = MockCommitments.all
        let plan = WeekPlanner.plan(now: AppClock.now, commitments: commitments, events: MockCalendar.events, holds: MockCalendar.holds)
        let atRisk = plan.atRisk.compactMap { id in commitments.first { $0.id == id } }
        let open = Effort.total(plan.openMinutes), needed = Effort.total(plan.neededMinutes)
        guard !atRisk.isEmpty else {
            return Script(keywords: ["have time", "enough time", "at risk", "this week", "capacity", "overcommitted"],
                          answer: "Yes. Over the next five working days you have \(open) open and \(needed) of commitments with an estimate, and each one has room before it's due.",
                          citations: [])
        }
        let parts = atRisk.map { c -> String in
            var short = ""
            if case let .atRisk(_, shortBy) = plan.fit(c.id) { short = ", \(Effort.text(shortBy)) short" }
            let due = c.due.map { " (due \($0.formatted(.dateTime.weekday(.wide)))\(short))" } ?? ""
            return "\(c.title.prefix(1).lowercased() + c.title.dropFirst())\(due)"
        }
        let moves = atRisk.map { c -> String in
            let to = WeekPlanner.earliestWorkableDue(for: c, now: AppClock.now, commitments: commitments,
                                                     events: MockCalendar.events, holds: MockCalendar.holds)
            return "\(c.person.firstName) for \(to.formatted(.dateTime.weekday(.wide)))"
        }
        return Script(
            keywords: ["have time", "enough time", "at risk", "this week", "capacity", "overcommitted"],
            answer: "Not all of it. Over the next five working days you have \(open) open and \(needed) of commitments, but most of the open time comes late. \(atRisk.count) are at risk: \(parts.joined(separator: "; ")). You could ask \(moves.joined(separator: " and ")).",
            citations: atRisk.map(\.threadID)
        )
    }

    private static var daySummary: Script {
        let commitments = MockCommitments.all
        let mine = commitments.filter { $0.direction == .yours }
        let dueNow = mine.filter(\.isDueTodayOrEarlier).count
        let late = commitments.filter { $0.direction == .theirs && $0.isOverdue }.count
        let committed = Set(mine.map(\.threadID))
        let mailOnly = MockThreads.all.filter { $0.folder == .inbox && $0.bucket == .needsYou && !committed.contains($0.id) }.count
        return Script(
            keywords: ["summar", "my day", "my week", "today", "brief"],
            answer: "\(mine.count + mailOnly) things need you, and \(dueNow) of them are due today or overdue: the Northwind customer note for Robin, the Sandpiper section for Patti's leadership review, the Adventure Works slide for Isaiah, and the VanArsdel brief for Miriam, which is overdue. The customer note is the most urgent, because Robin needs it within the hour. \(late) commitments to you are overdue, and one of them, Pradeep's cost model, holds up your leadership slides.",
            citations: ["nw-escalation", "board-deck", "ref-slide", "comp-brief", "unit-cost"]
        )
    }

    static func answer(for question: String) -> AskAnswer {
        let q = question.lowercased()
        if let script = (scripts + [weekFit, daySummary]).first(where: { s in s.keywords.contains(where: { q.contains($0) }) }) {
            return AskAnswer(question: question, text: script.answer, citations: script.citations)
        }
        return AskAnswer(
            question: question,
            text: "I couldn't find a confident answer to \"\(question)\" in this demo mailbox. With a real mailbox, I'd search your mail and your commitments. Try one of the suggestions.",
            citations: []
        )
    }

    /// Stand-in for the "rewrite in my voice" model.
    static func rewrite(_ body: String, to name: String) -> String {
        let core = body.trimmingCharacters(in: .whitespacesAndNewlines)
        let line = core.isEmpty ? "Quick note to follow up on this one." : core
        let greeting = name.isEmpty ? "Hi" : "Hey \(name.split(separator: " ").first.map(String.init) ?? name)"
        let signOff = line.lowercased().contains("thank") ? "Best," : "Thanks!"
        return "\(greeting),\n\n\(line)\n\n\(signOff)\nVivek"
    }
}
