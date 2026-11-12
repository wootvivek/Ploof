import Foundation

// MARK: - Time

/// How long a commitment is expected to take: a range, and the evidence for it.
/// Leave it off a commitment when there is no basis. A blank is better than a wrong number.
nonisolated struct Effort: Hashable, Sendable {
    let lowMinutes: Int
    let highMinutes: Int
    /// Where the range comes from, e.g. "your last four board decks".
    let basis: String

    init(_ lowMinutes: Int, _ highMinutes: Int, _ basis: String) {
        self.lowMinutes = lowMinutes
        self.highMinutes = highMinutes
        self.basis = basis
    }

    /// "15–20 min", "1.5–2.5 h".
    var label: String {
        if highMinutes <= 60 {
            return lowMinutes == highMinutes ? "\(lowMinutes) min" : "\(lowMinutes)–\(highMinutes) min"
        }
        let low = Self.hours(lowMinutes), high = Self.hours(highMinutes)
        return low == high ? "\(low) h" : "\(low)–\(high) h"
    }

    private static func hours(_ minutes: Int) -> String {
        let value = Double(minutes) / 60
        return value == value.rounded() ? "\(Int(value))" : String(format: "%.1f", value)
    }

    /// A single amount of time: "45 min", "2.5 h", "1 h 15 min".
    static func text(_ minutes: Int) -> String {
        if minutes < 60 { return "\(minutes) min" }
        if minutes % 30 == 0 { return "\(hours(minutes)) h" }
        return "\(minutes / 60) h \(minutes % 60) min"
    }

    /// A total, rounded to the nearest half hour: "13 h", "10.5 h".
    static func total(_ minutes: Int) -> String {
        text(Int((Double(minutes) / 30).rounded()) * 30)
    }
}

/// One step in the chain of work behind a commitment. Steps run in order.
/// "Before" steps must finish by the deadline (the due date, or the meeting the work is for).
/// "After" steps can only start once that meeting or deadline has passed.
nonisolated struct Step: Hashable, Sendable {
    let title: String
    let minutes: Int
    var isAfter = false

    init(_ title: String, _ minutes: Int, after: Bool = false) {
        self.title = title
        self.minutes = minutes
        self.isAfter = after
    }
}

/// A stretch of time the planner has given to one step: already held, or only planned.
nonisolated struct PlannedBlock: Identifiable, Hashable, Sendable {
    let commitmentID: String
    let stepIndex: Int
    let stepCount: Int
    let title: String
    let interval: DateInterval
    let isHeld: Bool
    let isAfter: Bool

    var id: String { "\(commitmentID)-\(stepIndex)-\(interval.start.timeIntervalSinceReferenceDate)" }
    var minutes: Int { Int(interval.duration / 60) }
}

nonisolated struct CalendarEvent: Identifiable, Hashable, Sendable {
    let id: String
    let title: String
    let start: Date
    let end: Date

    var interval: DateInterval { DateInterval(start: start, end: max(start, end)) }
}

/// Time set aside for one commitment. Private: other people see it as busy.
nonisolated struct Hold: Identifiable, Hashable, Sendable {
    let id: String
    let commitmentID: String
    let start: Date
    let end: Date

    var interval: DateInterval { DateInterval(start: start, end: max(start, end)) }
    var minutes: Int { Int(interval.duration / 60) }
}

/// One working day, split three ways.
nonisolated struct DayLoad: Identifiable, Hashable, Sendable {
    let day: Date
    let bookedMinutes: Int
    let heldMinutes: Int
    let openMinutes: Int

    var id: Date { day }
}

/// Whether the time for a commitment exists before it is due.
nonisolated enum Fit: Hashable, Sendable {
    /// No estimate, no date, or due beyond the days in view. Never flagged.
    case notAssessed
    case fits
    /// `openMinutes` is what is left before the due date once earlier commitments have their time.
    case atRisk(openMinutes: Int, shortMinutes: Int)

    var isAtRisk: Bool {
        if case .atRisk = self { return true }
        return false
    }
}

nonisolated struct WeekPlan: Sendable {
    let days: [DayLoad]
    let fits: [String: Fit]
    /// Every stretch of time given to a step, held or planned, in time order.
    let blocks: [PlannedBlock]
    /// Minutes that could not be placed, per commitment and step index.
    let shortfalls: [String: [Int: Int]]
    /// Commitment ids, soonest due first.
    let atRisk: [String]
    let openMinutes: Int
    let neededMinutes: Int

    func fit(_ commitmentID: String) -> Fit { fits[commitmentID] ?? .notAssessed }

    func blocks(for commitmentID: String) -> [PlannedBlock] { blocks.filter { $0.commitmentID == commitmentID } }

    /// The planned time for a commitment that is not held yet.
    func slots(for commitmentID: String) -> [DateInterval] {
        blocks.filter { $0.commitmentID == commitmentID && !$0.isHeld }.map(\.interval)
    }
}

// MARK: - Planner

/// Works out whether your commitments fit in the time you have. Pure functions, no UI.
///
/// The rule, in order:
/// 1. Open time is working hours minus meetings minus held time. Gaps between meetings under 30 minutes don't count.
/// 2. Each of your open commitments with an estimate and a due date in view becomes a chain of steps.
///    A commitment with no steps is a chain of one.
/// 3. "Before" steps must finish by the deadline: the due date, or the start of the meeting the work is
///    for, whichever is earlier. "After" steps start once that meeting (or the due date) has passed and
///    have until the end of the next working day.
/// 4. Steps are placed soonest deadline first, each one after the step before it in its own chain.
///    Time already held for the commitment is used first.
/// 5. If a "before" step cannot be placed in full, the commitment is at risk and the shortfall is reported.
///
/// Time already gone today is not open: planning starts from `now`, rounded up to the next five minutes.
nonisolated enum WeekPlanner {
    static let workdayStartHour = 9
    static let workdayEndHour = 17
    static let minimumGapMinutes = 30
    static let daysInView = 5

    /// Today and the next four working days.
    static func days(from now: Date) -> [Date] {
        let cal = Calendar.current
        var day = cal.startOfDay(for: now)
        var result = [day]
        while result.count < daysInView {
            day = cal.date(byAdding: .day, value: 1, to: day) ?? day.addingTimeInterval(86_400)
            if !cal.isDateInWeekend(day) { result.append(day) }
        }
        return result
    }

    static func workWindow(_ day: Date) -> DateInterval {
        let cal = Calendar.current
        let start = cal.date(bySettingHour: workdayStartHour, minute: 0, second: 0, of: day) ?? day
        let end = cal.date(bySettingHour: workdayEndHour, minute: 0, second: 0, of: day) ?? day
        return DateInterval(start: start, end: max(start, end))
    }

    static func minutes(_ intervals: [DateInterval]) -> Int {
        intervals.reduce(0) { $0 + Int($1.duration / 60) }
    }

    /// `now` rounded up to the next five minutes.
    static func planningStart(_ now: Date) -> Date {
        let step: TimeInterval = 300
        return Date(timeIntervalSinceReferenceDate: (now.timeIntervalSinceReferenceDate / step).rounded(.up) * step)
    }

    /// Stretches of at least 30 minutes between meetings inside one working day, keeping only what is
    /// still ahead of `notBefore`.
    static func openIntervals(on day: Date, busy: [DateInterval], notBefore: Date = .distantPast) -> [DateInterval] {
        let window = workWindow(day)
        let blocks = busy
            .compactMap { $0.intersection(with: window) }
            .filter { $0.duration > 0 }
            .sorted { $0.start < $1.start }
        var result: [DateInterval] = []
        var cursor = window.start
        for block in blocks {
            if block.start > cursor { result.append(DateInterval(start: cursor, end: block.start)) }
            cursor = max(cursor, block.end)
        }
        if cursor < window.end { result.append(DateInterval(start: cursor, end: window.end)) }
        return result
            .filter { $0.duration >= Double(minimumGapMinutes * 60) }
            .compactMap { gap in
                if gap.end <= notBefore { return nil }
                return gap.start < notBefore ? DateInterval(start: notBefore, end: gap.end) : gap
            }
    }

    /// Takes blocks out of open stretches and keeps whatever is left, however short.
    /// (The 30-minute rule is about gaps between meetings, not about time you chose to hold.)
    static func subtract(_ blocks: [DateInterval], from gaps: [DateInterval]) -> [DateInterval] {
        var result = gaps
        for block in blocks.sorted(by: { $0.start < $1.start }) {
            result = result.flatMap { gap -> [DateInterval] in
                guard let overlap = gap.intersection(with: block), overlap.duration > 0 else { return [gap] }
                var pieces: [DateInterval] = []
                if overlap.start > gap.start { pieces.append(DateInterval(start: gap.start, end: overlap.start)) }
                if overlap.end < gap.end { pieces.append(DateInterval(start: overlap.end, end: gap.end)) }
                return pieces
            }
        }
        return result
    }

    /// Takes up to `need` minutes from open time between `notBefore` and `deadline`, earliest first.
    static func take(_ need: Int, from open: inout [DateInterval], notBefore: Date, deadline: Date) -> [DateInterval] {
        var need = need
        var pieces: [DateInterval] = []
        var i = 0
        while need > 0, i < open.count {
            let gap = open[i]
            if gap.start >= deadline { break }
            let start = max(gap.start, notBefore)
            let end = min(gap.end, deadline)
            let usable = Int(end.timeIntervalSince(start) / 60)
            guard usable > 0 else { i += 1; continue }
            let piece = DateInterval(start: start, duration: Double(min(usable, need) * 60))
            pieces.append(piece)
            need -= Int(piece.duration / 60)
            var rest: [DateInterval] = []
            if start > gap.start { rest.append(DateInterval(start: gap.start, end: start)) }
            if piece.end < gap.end { rest.append(DateInterval(start: piece.end, end: gap.end)) }
            open.replaceSubrange(i...i, with: rest)
            if start > gap.start { i += 1 }
        }
        return pieces
    }

    /// The working day after the one containing `date`, at closing time.
    static func endOfNextWorkingDay(after date: Date) -> Date {
        let cal = Calendar.current
        var day = cal.startOfDay(for: date)
        repeat {
            day = cal.date(byAdding: .day, value: 1, to: day) ?? day.addingTimeInterval(86_400)
        } while cal.isDateInWeekend(day)
        return workWindow(day).end
    }

    private struct Item {
        let commitment: Commitment
        let index: Int
        let count: Int
        let step: Step
        let deadline: Date
        /// What it is sorted by. Overdue work keeps its original (past) due date, so it goes first.
        let priority: Date
        /// For "after" steps: when the meeting or deadline has passed.
        let notBefore: Date?
        let flagsRisk: Bool
    }

    static func plan(now: Date, commitments: [Commitment], events: [CalendarEvent], holds: [Hold]) -> WeekPlan {
        let days = days(from: now)
        let firstStart = workWindow(days[0]).start
        let lastEnd = workWindow(days[days.count - 1]).end
        let eventBlocks = events.map(\.interval)
        let holdBlocks = holds.map(\.interval)

        var loads: [DayLoad] = []
        var open: [DateInterval] = []
        for day in days {
            let window = workWindow(day)
            let gaps = subtract(holdBlocks, from: openIntervals(on: day, busy: eventBlocks, notBefore: planningStart(now)))
            open += gaps
            loads.append(DayLoad(
                day: day,
                bookedMinutes: minutes(eventBlocks.compactMap { $0.intersection(with: window) }),
                heldMinutes: minutes(holdBlocks.compactMap { $0.intersection(with: window) }),
                openMinutes: minutes(gaps)
            ))
        }
        let openTotal = minutes(open)

        // Turn each commitment into its chain of steps, each with a deadline.
        var items: [Item] = []
        var order: [String] = []
        for commitment in commitments {
            guard commitment.direction == .yours, commitment.status == .open,
                  let effort = commitment.effort, let due = commitment.due else { continue }
            let anchor = commitment.anchorEventID.flatMap { id in events.first { $0.id == id } }
            let isOverdue = due < firstStart
            let before = isOverdue ? lastEnd : min(due, anchor?.start ?? due)
            guard before <= lastEnd else { continue }
            let steps = commitment.steps.isEmpty ? [Step(commitment.title, effort.lowMinutes)] : commitment.steps
            let passed = anchor?.end ?? due
            for (index, step) in steps.enumerated() {
                if step.isAfter {
                    guard passed < lastEnd else { continue }
                    items.append(Item(commitment: commitment, index: index, count: steps.count, step: step,
                                      deadline: min(endOfNextWorkingDay(after: passed), lastEnd),
                                      priority: min(endOfNextWorkingDay(after: passed), lastEnd),
                                      notBefore: passed, flagsRisk: false))
                } else {
                    items.append(Item(commitment: commitment, index: index, count: steps.count, step: step,
                                      deadline: before, priority: isOverdue ? due : before,
                                      notBefore: nil, flagsRisk: !isOverdue))
                }
            }
            order.append(commitment.id)
        }
        // Soonest deadline first; on a tie the quicker commitment first; steps keep their order.
        items.sort { a, b in
            (a.priority, a.commitment.effort?.lowMinutes ?? 0, a.commitment.id, a.index)
                < (b.priority, b.commitment.effort?.lowMinutes ?? 0, b.commitment.id, b.index)
        }

        // Time already held for a commitment is used before any open time.
        var pool: [String: [DateInterval]] = [:]
        for hold in holds.sorted(by: { $0.start < $1.start }) { pool[hold.commitmentID, default: []].append(hold.interval) }
        var cursor: [String: Date] = [:]
        var blocks: [PlannedBlock] = []
        var shortfalls: [String: [Int: Int]] = [:]
        var placedOpen: [String: Int] = [:]
        var needed = 0

        for item in items {
            let id = item.commitment.id
            var need = item.step.minutes
            needed += need
            var chainEnd = cursor[id] ?? firstStart

            func add(_ interval: DateInterval, held: Bool) {
                blocks.append(PlannedBlock(commitmentID: id, stepIndex: item.index, stepCount: item.count,
                                           title: item.step.title, interval: interval, isHeld: held, isAfter: item.step.isAfter))
                chainEnd = max(chainEnd, interval.end)
            }

            while need > 0, let held = pool[id]?.first {
                let take = min(Int(held.duration / 60), need)
                guard take > 0 else { pool[id]?.removeFirst(); continue }
                let piece = DateInterval(start: held.start, duration: Double(take * 60))
                add(piece, held: true)
                need -= take
                if piece.end >= held.end { pool[id]?.removeFirst() } else { pool[id]?[0] = DateInterval(start: piece.end, end: held.end) }
            }
            if need > 0 {
                let notBefore = max(item.notBefore ?? firstStart, chainEnd)
                let pieces = take(need, from: &open, notBefore: notBefore, deadline: item.deadline)
                for piece in pieces { add(piece, held: false) }
                let placed = minutes(pieces)
                need -= placed
                if item.flagsRisk { placedOpen[id, default: 0] += placed }
            }
            cursor[id] = chainEnd
            if need > 0, item.flagsRisk { shortfalls[id, default: [:]][item.index] = need }
        }
        // Held time that no step needed still shows on the calendar.
        for (id, rest) in pool {
            for interval in rest where interval.duration > 0 {
                let title = commitments.first { $0.id == id }?.title ?? "Held"
                blocks.append(PlannedBlock(commitmentID: id, stepIndex: 0, stepCount: 1, title: title,
                                           interval: interval, isHeld: true, isAfter: false))
            }
        }
        blocks.sort { $0.interval.start < $1.interval.start }

        var fits: [String: Fit] = [:]
        var atRisk: [String] = []
        for id in order {
            let short = shortfalls[id]?.values.reduce(0, +) ?? 0
            if short > 0 {
                fits[id] = .atRisk(openMinutes: placedOpen[id] ?? 0, shortMinutes: short)
                atRisk.append(id)
            } else {
                fits[id] = .fits
            }
        }
        let dueOf = Dictionary(uniqueKeysWithValues: commitments.map { ($0.id, $0.due ?? .distantFuture) })
        atRisk.sort { (dueOf[$0] ?? .distantFuture, $0) < (dueOf[$1] ?? .distantFuture, $1) }

        return WeekPlan(days: loads, fits: fits, blocks: blocks, shortfalls: shortfalls, atRisk: atRisk,
                        openMinutes: openTotal, neededMinutes: needed)
    }

    /// The earliest due date (end of a working day) at which this commitment would fit.
    /// Beyond the days in view there is no calendar yet, so the day after them is assumed to work.
    static func earliestWorkableDue(for commitment: Commitment, now: Date, commitments: [Commitment],
                                    events: [CalendarEvent], holds: [Hold]) -> Date {
        let days = days(from: now)
        let cal = Calendar.current
        for day in days {
            let end = workWindow(day).end
            guard let due = commitment.due, end > due else { continue }
            let moved = commitments.map { c -> Commitment in
                var copy = c
                if c.id == commitment.id { copy.due = end }
                return copy
            }
            if plan(now: now, commitments: moved, events: events, holds: holds).fit(commitment.id) == .fits {
                return end
            }
        }
        var next = days[days.count - 1]
        repeat {
            next = cal.date(byAdding: .day, value: 1, to: next) ?? next.addingTimeInterval(86_400)
        } while cal.isDateInWeekend(next)
        return workWindow(next).end
    }
}
