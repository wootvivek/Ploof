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
        "Where does the Northwind deal stand?",
        "What does Patti need from me?",
        "What is overdue from other people?",
        "What's blocking the Mark 8 launch gate?",
        "What needs my approval?",
        "Summarize my day",
    ]

    /// Checked in order, so the more specific scripts come first.
    private static var scripts: [Script] {
        [
            Script(keywords: ["412", "escalation", "outage", "offline units"],
                   answer: "Nine pilot units at Northwind store #412 went offline last night after the 2.3.1 firmware push. Engineering is rolling back, and firmware 2.3.2 with the fix goes to pilot sites \(C.wd(2)). Robin is waiting for you to approve the customer note, and Charlotte left a voicemail asking for a call before noon.",
                   citations: ["nw-escalation", "teams-voicemail", "firmware-232"]),
            Script(keywords: ["northwind", "charlotte", "msa"],
                   answer: "Three things are open with Northwind. Legal needs your decision on the liability cap and SLA credits by \(C.wd(1)). You committed to sending Charlotte pricing at 5,000 and 8,000 units by \(C.wd(2)), now with a 3-year option, before her steering committee on \(C.wd(3)). Their security review of your questionnaire runs until about \(C.md(7)). Separately, store #412 had an outage this morning that is being rolled back.",
                   citations: ["nw-msa", "nw-pricing", "nw-questionnaire", "nw-escalation"]),
            Script(keywords: ["patti", "board deck", "board meeting", "pre-read"],
                   answer: "You have one commitment to Patti: the Mark 8 section of the board deck, due today. She asked for launch readiness, pilot results and the revised unit forecast. Debra wants it in the new template, five slides at most, because the pre-read goes out tonight. One dependency is late: Pradeep's revised unit cost model.",
                   citations: ["board-deck", "unit-cost"]),
            Script(keywords: ["overdue", "late on", "who's late", "whos late", "owes me", "owed to me", "waiting on"],
                   answer: "Five commitments to you are overdue: the launch dashboard link from Daisy, the 8D report for lot 2231 from Lydia at Fabrikam, a revised estimate from Miguel at Proseware, the unit cost model from Pradeep, and the freight quotes from Daichi. I've drafted a follow-up for each.",
                   citations: ["dashboard", "fab-8d", "proseware-estimate", "unit-cost", "freight"]),
            Script(keywords: ["launch gate", "blocking", "blocker", "launch risk", "readiness"],
                   answer: "Three items stand between you and the launch gate on \(C.md(9)). Battery yield: Fabrikam needs your go-ahead on Rev C by \(C.wd(1)), which costs four days. Security: three pen-test findings need owners by \(C.wd(2)), and the fix for the high one is already merged. Certification: emissions passed, and the lab's final report is due \(C.md(5)).",
                   citations: ["launch-gate", "fab-revc", "sec-review", "cert-status"]),
            Script(keywords: ["approval", "approve", "nda", "sow"],
                   answer: "Four approvals are waiting on you. Cameron Evans's Senior PM offer (a competing offer expires \(C.wd(2))), the $86,000 Southridge Video SOW, Lidia's $2,418.60 expense report, and the Wingtip Toys NDA, which needs your signature before their kickoff on \(C.wd(3)).",
                   citations: ["offer-cameron", "sow-southridge", "expense-lidia", "nda-wingtip"]),
            Script(keywords: ["pilot", "adventure works", "tanaka"],
                   answer: "The Adventure Works pilot ran 38 units for 9 weeks with 99.2% uptime, and technicians closed 17% more jobs per day. Before a full order, Ray wants offline mode for the canyon sites and a rugged case option. Elvia proposed \(C.wd(2)) at 10 for the review, and Kristin is sending uptime by site.",
                   citations: ["aw-pilot", "aw-sitedata", "customer-quote"]),
            Script(keywords: ["pricing study", "trey", "willingness", "price point"],
                   answer: "Trey Research surveyed 412 store and field managers. Willingness to pay holds up to $349 and drops sharply above $379. For context, VanArsdel just cut the V3 to $329 but charges $8 a month for its dashboard. Katri offered \(C.wd(2)) at 2 PM or \(C.wd(3)) at 11 AM for the full readout.",
                   citations: ["trey-readout", "vanarsdel-v3"]),
            Script(keywords: ["vanarsdel", "competit"],
                   answer: "VanArsdel cut the V3 to $329 and sells its dashboard separately at $8 per unit per month, which comes to $617 over three years. You committed to a one-page competitive brief on it for Miriam. That was due \(C.wd(-1)), and she presents to the sales team \(C.wd(1)).",
                   citations: ["vanarsdel-v3", "comp-brief"]),
            Script(keywords: ["flight", "chicago", "trip", "travel"],
                   answer: "You fly Blue Yonder Airlines BY 1482 from Seattle to Chicago on \(C.md(6)), departing 7:10 AM and arriving 1:05 PM, seat 12C. The confirmation code is R4TQ9M. Your hotel is two nights, a short walk from Northwind's headquarters.",
                   citations: ["itinerary", "eticket"]),
            Script(keywords: ["offsite"],
                   answer: "The leadership offsite is at Alpine Ski House, \(C.md(15)) to \(C.md(16)). You're presenting a 45-minute session, 'Mark 8: the first 100 days'. Debra needs your session title, AV needs and dietary restrictions by \(C.wd(3)).",
                   citations: ["offsite", "alpine-booking"]),
            Script(keywords: ["budget", "fy27", "emily"],
                   answer: "Your FY27 budget for cost center 4410 is due \(C.wd(1)), when Finance locks the first pass. You need Megan's final marketing number to finish it, and she committed to that for today. Carlos is also still reviewing your $310K capex request for test fixtures.",
                   citations: ["budget-fy27", "mkt-number", "capex-fixtures"]),
            Script(keywords: ["fabrikam", "battery", "rev c", "yield"],
                   answer: "Battery lot 2231 came in at 91.4% yield against a 96% target because of a weld on the tab connector. Rev C fixes it and adds four days. Lee recommends taking it, and Mauricio needs your written go-ahead by \(C.wd(1)). Lydia's 8D report on the root cause is overdue.",
                   citations: ["fab-revc", "fab-8d", "fab-po"]),
        ]
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
            answer: "\(mine.count + mailOnly) things need you, and \(dueNow) of them are due today or overdue: the Northwind outage note for Robin, the Mark 8 section for Patti's board deck, the Adventure Works slide for Isaiah, and the VanArsdel brief for Miriam, which is overdue. The outage note is the most urgent, because Robin needs it within the hour. \(late) commitments to you are overdue, and one of them, Pradeep's cost model, holds up your board deck.",
            citations: ["nw-escalation", "board-deck", "ref-slide", "comp-brief", "unit-cost"]
        )
    }

    static func answer(for question: String) -> AskAnswer {
        let q = question.lowercased()
        if let script = (scripts + [daySummary]).first(where: { s in s.keywords.contains(where: { q.contains($0) }) }) {
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
