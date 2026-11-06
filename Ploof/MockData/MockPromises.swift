import Foundation

/// Promises the (pretend) AI found in the mock mailbox.
enum MockPromises {
    private typealias P = MockPeople

    /// A date `days` from today at 5 PM.
    private static func inDays(_ days: Int) -> Date {
        let cal = Calendar.current
        let start = cal.startOfDay(for: .now)
        let day = cal.date(byAdding: .day, value: days, to: start) ?? start
        return cal.date(byAdding: .hour, value: 17, to: day) ?? day
    }

    static var all: [Promise] {
        [
            // MARK: I owe
            Promise(id: "p-deck", direction: .iOwe, person: P.priya,
                    title: "Send the Q4 planning deck",
                    evidence: "I'll send the deck over before the review.",
                    evidenceBy: "You", due: inDays(0), threadID: "q4-deck"),
            Promise(id: "p-flights", direction: .iOwe, person: P.mom,
                    title: "Send Thanksgiving flight details",
                    evidence: "I'll confirm the flights by tomorrow, promise.",
                    evidenceBy: "You", due: inDays(-1), threadID: "thanksgiving"),
            Promise(id: "p-kitchen", direction: .iOwe, person: P.jordan,
                    title: "Approve the kitchen quote",
                    evidence: "If you approve by Friday we can start the week after next.",
                    evidenceBy: "Jordan", due: inDays(1), threadID: "kitchen"),
            Promise(id: "p-lease", direction: .iOwe, person: P.marcus,
                    title: "Sign the lease renewal",
                    evidence: "Please sign and return by the 10th so I can hold the unit for you.",
                    evidenceBy: "Marcus", due: inDays(5), threadID: "lease"),
            Promise(id: "p-aisha", direction: .iOwe, person: P.aisha,
                    title: "Send Aisha times for coffee",
                    evidence: "Would love to grab coffee sometime next week. What works?",
                    evidenceBy: "Aisha", due: nil, threadID: "intro"),
            Promise(id: "p-flowers", direction: .iOwe, person: P.maya,
                    title: "Pay Maya half for Grandma's flowers",
                    evidence: "You can Venmo me for half of the flowers later.",
                    evidenceBy: "Maya", due: nil, threadID: "grandma"),

            // MARK: Owed to me
            Promise(id: "p-alex", direction: .owedToMe, person: P.alex,
                    title: "Pay you back $85 for the concert",
                    evidence: "I'll Venmo you my $85 by Friday!",
                    evidenceBy: "Alex", due: inDays(-3), threadID: "concert",
                    nudge: "Hey Alex! Friendly nudge on the $85 for the concert tickets whenever you get a sec 🙂"),
            Promise(id: "p-hannah", direction: .owedToMe, person: P.hannah,
                    title: "Send the reference letter draft",
                    evidence: "I'll send you a draft Monday so you can sanity-check it.",
                    evidenceBy: "Hannah", due: inDays(-1), threadID: "reference",
                    nudge: "Hi Hannah, hope your week's going well! Just checking in on the reference letter draft. No pressure, the deadline's still two weeks out."),
            Promise(id: "p-carlos", direction: .owedToMe, person: P.carlos,
                    title: "Call when the brake pads arrive",
                    evidence: "I'll call you as soon as they arrive.",
                    evidenceBy: "Carlos", due: inDays(2), threadID: "car"),
            Promise(id: "p-refund", direction: .owedToMe, person: P.brightline,
                    title: "Credit $23.40 for the outage",
                    evidence: "A credit of $23.40 will be applied to your account within 5 business days.",
                    evidenceBy: "Brightline", due: inDays(4), threadID: "refund"),
            Promise(id: "p-photos", direction: .owedToMe, person: P.tom,
                    title: "Share the wedding album",
                    evidence: "I'll share the full album link once I pick the favorites.",
                    evidenceBy: "Tom", due: nil, threadID: "photos"),
        ]
    }
}
