import Foundation

/// The app's one source of "now". Read the time from here, never from `Date.now`, so that mock data,
/// due labels, the planner and the calendar all agree.
///
/// Normally this is the real time. A demo can shift it (see `SyncEngine.reset`) so the day starts at
/// 9:00 AM whatever the wall clock says; the clock then keeps running in real time from there.
nonisolated enum AppClock {
    /// Seconds added to the real time. Set only from the main actor, when a demo is reset.
    nonisolated(unsafe) static var offset: TimeInterval = 0

    static var now: Date { Date.now.addingTimeInterval(offset) }
    static var today: Date { Calendar.current.startOfDay(for: now) }

    static func isToday(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: now)
    }

    static func isYesterday(_ date: Date) -> Bool {
        guard let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today) else { return false }
        return Calendar.current.isDate(date, inSameDayAs: yesterday)
    }
}
