// Stand-alone check for the mock mailbox. Not part of the app target.
//
//   swiftc -o /tmp/check-mock-data NextWave/Models/*.swift NextWave/MockData/*.swift scripts/check-mock-data/main.swift \
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

for t in threads {
    guard let quick = t.quickReply else { continue }
    if t.folder != .inbox || t.bucket != .needsYou { problems.append("\(t.id): one-tap replies are only for Needs you mail") }
    if quick.label.isEmpty || quick.text.isEmpty { problems.append("\(t.id): empty one-tap reply") }
    if quick.label.count > 24 { problems.append("\(t.id): one-tap label is too long for the button") }
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

// Time: meetings don't overlap, holds sit outside meetings, and the demo has exactly the intended risks.
let events = MockCalendar.events.sorted { $0.start < $1.start }
for (a, b) in zip(events, events.dropFirst()) where b.start < a.end { problems.append("meetings overlap: \(a.id) and \(b.id)") }
for h in MockCalendar.holds {
    if commitments.first(where: { $0.id == h.commitmentID }) == nil { problems.append("hold \(h.id): no commitment \(h.commitmentID)") }
    for e in events where e.interval.intersection(with: h.interval).map({ $0.duration > 0 }) ?? false { problems.append("hold \(h.id) overlaps meeting \(e.id)") }
}
for c in commitments where c.effort != nil {
    if c.direction != .yours { problems.append("\(c.id): only your own commitments get an estimate") }
    if let e = c.effort, e.lowMinutes <= 0 || e.highMinutes < e.lowMinutes || e.basis.isEmpty { problems.append("\(c.id): bad estimate") }
}
for c in commitments where !c.steps.isEmpty || c.anchorEventID != nil {
    let before = c.steps.filter { !$0.isAfter }.reduce(0) { $0 + $1.minutes }
    if !c.steps.isEmpty, before != c.effort?.lowMinutes { problems.append("\(c.id): steps before the deadline add up to \(before), not the low end of the estimate") }
    if let first = c.steps.firstIndex(where: \.isAfter), c.steps[first...].contains(where: { !$0.isAfter }) { problems.append("\(c.id): 'after' steps must come last") }
    if let id = c.anchorEventID, !MockCalendar.events.contains(where: { $0.id == id }) { problems.append("\(c.id): no meeting \(id)") }
}
// Checked as of 8:00 this morning, before the working day starts, so the result does not depend on when this runs.
let morning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: AppClock.today) ?? AppClock.today
let plan = WeekPlanner.plan(now: morning, commitments: commitments, events: MockCalendar.events, holds: MockCalendar.holds)
if plan.atRisk != ["p-budget", "p-assessments"] { problems.append("expected the budget and the assessments at risk, got \(plan.atRisk)") }
if MockAsk.answer(for: "Do I have time for everything this week?").citations.isEmpty { problems.append("no week answer in Ask") }

// The demo script: plays from its starting snapshot to the full mailbox, with the risks moving as intended.
let scenario = DemoScenario.build()
var mailbox = scenario.start
func demoRisk() -> [String] {
    WeekPlanner.plan(now: morning, commitments: mailbox.commitments, events: mailbox.events, holds: mailbox.holds).atRisk
}
if !demoRisk().isEmpty { problems.append("demo should start with nothing at risk, got \(demoRisk())") }
var mostAtRisk = 0
for beat in scenario.beats {
    if beat.at < 0 || beat.at > DemoScenario.length { problems.append("demo beat outside the run: \(beat.at)") }
    if case let .reply(id, _, _) = beat.event, !mailbox.threads.contains(where: { $0.id == id }) { problems.append("demo: reply to a thread that has not arrived: \(id)") }
    if case let .commitmentFound(c) = beat.event, !mailbox.threads.contains(where: { $0.id == c.threadID }) { problems.append("demo: commitment \(c.id) found before its mail") }
    if case let .commitmentDone(id) = beat.event, !mailbox.commitments.contains(where: { $0.id == id }) { problems.append("demo: \(id) done before it was found") }
    mailbox.apply(beat.event, at: morning.addingTimeInterval(3600 + beat.at))
    mostAtRisk = max(mostAtRisk, demoRisk().count)
}
for t in threads {
    guard let got = mailbox.threads.first(where: { $0.id == t.id }) else { problems.append("demo never delivers thread \(t.id)"); continue }
    if got.messages.count < t.messages.count { problems.append("demo leaves \(t.id) short of messages") }
}
for c in commitments where !mailbox.commitments.contains(where: { $0.id == c.id }) { problems.append("demo never finds commitment \(c.id)") }
if demoRisk() != ["p-budget"] || mostAtRisk != 2 { problems.append("demo risk arc changed: ends \(demoRisk()), peak \(mostAtRisk)") }

func count(_ folder: Folder, _ bucket: TriageBucket? = nil) -> Int {
    threads.filter { $0.folder == folder && (bucket == nil || $0.bucket == bucket) }.count
}
print("""
threads: \(threads.count)  (inbox \(count(.inbox)): needs you \(count(.inbox, .needsYou)), waiting \(count(.inbox, .waiting)), \
updates \(count(.inbox, .updates)), notifications \(count(.inbox, .notifications)); archive \(count(.archive)), sent \(count(.sent)), \
drafts \(count(.drafts)), junk \(count(.junk)), deleted \(count(.deleted)))
commitments: \(commitments.count)  (yours \(commitments.filter { $0.direction == .yours }.count), theirs \(commitments.filter { $0.direction == .theirs }.count))
senders: \(Set(threads.flatMap { $0.messages.map(\.from.id) }).count)
week: \(Effort.total(plan.openMinutes)) open, \(Effort.total(plan.neededMinutes)) of commitments, at risk \(plan.atRisk)
demo: \(scenario.beats.count) events over \(Int(DemoScenario.length / 60)) minutes, starting from \(scenario.start.threads.count) threads
""")
if problems.isEmpty {
    print("OK")
} else {
    print("PROBLEMS:\n" + problems.joined(separator: "\n"))
    exit(1)
}
