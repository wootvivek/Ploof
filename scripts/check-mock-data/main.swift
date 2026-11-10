// Stand-alone check for the mock mailbox. Not part of the app target.
//
//   swiftc -o /tmp/check-mock-data NextWave/Models/Models.swift NextWave/MockData/*.swift scripts/check-mock-data/main.swift \
//     && /tmp/check-mock-data
import Foundation

let threads = MockThreads.all
let commitments = MockCommitments.all
var problems: [String] = []

var threadsByID: [String: MailThread] = [:]
for t in threads {
    if threadsByID[t.id] != nil { problems.append("duplicate thread id \(t.id)") }
    threadsByID[t.id] = t
    if t.messages.isEmpty { problems.append("\(t.id): no messages") }
    if t.messages.map(\.date) != t.messages.map(\.date).sorted() { problems.append("\(t.id): messages out of order") }
    if t.folder == .inbox, t.bucket == .waiting, !t.messages.contains(where: { $0.from.isMe }) {
        problems.append("\(t.id): Waiting thread without a message from me")
    }
    if (t.oneLiner + t.stands + t.messages.map(\.body).joined()).contains("Ploof") {
        problems.append("\(t.id): text mentions the retired name")
    }
}

var commitmentIDs = Set<String>()
for p in commitments {
    if !commitmentIDs.insert(p.id).inserted { problems.append("duplicate commitment id \(p.id)") }
    guard let t = threadsByID[p.threadID] else { problems.append("\(p.id): no thread \(p.threadID)"); continue }
    if t.folder != .inbox { problems.append("\(p.id): thread \(t.id) is not in the inbox") }
    guard let m = t.messages.first(where: { $0.body.contains(p.evidence) }) else {
        problems.append("\(p.id): evidence is not an exact quote from \(t.id)"); continue
    }
    let saidBy = m.from.isMe ? "You" : m.from.firstName
    if saidBy != p.evidenceBy { problems.append("\(p.id): evidenceBy is \(p.evidenceBy), but \(saidBy) said it") }
    if !m.from.isMe, m.from.id != p.person.id { problems.append("\(p.id): person is \(p.person.name), but \(m.from.name) said it") }
}

for q in MockAsk.suggestions {
    let a = MockAsk.answer(for: q)
    if a.citations.isEmpty { problems.append("Ask suggestion has no scripted answer: \(q)") }
    for c in a.citations where threadsByID[c] == nil { problems.append("Ask '\(q)': missing thread \(c)") }
}

func count(_ folder: Folder, _ bucket: TriageBucket? = nil) -> Int {
    threads.filter { $0.folder == folder && (bucket == nil || $0.bucket == bucket) }.count
}
print("""
threads: \(threads.count)  (inbox \(count(.inbox)): needs you \(count(.inbox, .needsYou)), waiting \(count(.inbox, .waiting)), \
updates \(count(.inbox, .updates)), notifications \(count(.inbox, .notifications)); archive \(count(.archive)), sent \(count(.sent)), \
drafts \(count(.drafts)), junk \(count(.junk)), deleted \(count(.deleted)))
commitments: \(commitments.count)  (yours \(commitments.filter { $0.direction == .yours }.count), theirs \(commitments.filter { $0.direction == .theirs }.count))
senders: \(Set(threads.flatMap { $0.messages.map(\.from.id) }).count)
""")
if problems.isEmpty {
    print("OK")
} else {
    print("PROBLEMS:\n" + problems.joined(separator: "\n"))
    exit(1)
}
