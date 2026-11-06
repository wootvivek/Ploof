import Foundation

/// Scripted "Ask Ploof" answers for the UX prototype.
enum MockAsk {
    struct Script {
        let keywords: [String]
        let answer: String
        let citations: [String]
    }

    static let suggestions = [
        "When's my flight to Boston?",
        "What do I owe Priya?",
        "Who's late on me?",
        "What did Marcus say about the lease?",
        "Summarize my day",
    ]

    private static let scripts: [Script] = [
        Script(keywords: ["flight", "boston", "fly", "trip"],
               answer: "Your Northwind Air flight NW 482 leaves Seattle (SEA) on Monday, Dec 21 at 7:05 AM and lands in Boston at 3:32 PM. You're in seat 14A, and your confirmation code is K7XQ2P.",
               citations: ["flight"]),
        Script(keywords: ["priya", "deck"],
               answer: "You owe Priya one thing: the Q4 planning deck. You told her you'd send it before the review, which makes it due today. In her latest note she also asked you to include the hiring numbers.",
               citations: ["q4-deck"]),
        Script(keywords: ["late", "owe me", "owed", "waiting"],
               answer: "Two people are late on you. Alex owes you $85 for the concert tickets (3 days overdue), and Hannah's reference-letter draft is a day late. Brightline's $23.40 outage credit is still on time.",
               citations: ["concert", "reference", "refund"]),
        Script(keywords: ["lease", "marcus", "rent"],
               answer: "Marcus sent the renewal for Unit 4B. Rent goes up 3% starting in January, and he needs it signed and returned by the 10th to hold the unit.",
               citations: ["lease"]),
        Script(keywords: ["summar", "my day", "my week", "today", "brief"],
               answer: "Today you owe 2 things: the Q4 deck for Priya, and your Thanksgiving flight details for Mom (overdue). 7 emails need you, including the lease renewal and the kitchen quote. Alex and Hannah are both late on things they promised you.",
               citations: ["q4-deck", "thanksgiving", "lease", "kitchen"]),
    ]

    static func answer(for question: String) -> AskAnswer {
        let q = question.lowercased()
        if let script = scripts.first(where: { s in s.keywords.contains(where: { q.contains($0) }) }) {
            return AskAnswer(question: question, text: script.answer, citations: script.citations)
        }
        return AskAnswer(
            question: question,
            text: "I couldn't find a confident answer to \"\(question)\" in this demo mailbox. In the real app, I'd search your Outlook.com mail and your promises. Try one of the suggestions.",
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
