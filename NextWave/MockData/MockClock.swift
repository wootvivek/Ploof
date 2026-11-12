import Foundation

/// Relative dates for the demo mailbox, so it always looks current.
/// Day offsets are in business days (weekends are skipped), which keeps
/// "by Thursday" in an email in step with the due label on its commitment.
enum MockClock {
    static func ago(_ hours: Double) -> Date {
        AppClock.now.addingTimeInterval(-hours * 3600)
    }

    /// 5 PM on the day `n` business days from today. Negative values are in the past.
    static func biz(_ n: Int) -> Date {
        let cal = Calendar.current
        var day = cal.startOfDay(for: AppClock.now)
        var left = abs(n)
        let step = n < 0 ? -1 : 1
        while left > 0 {
            day = cal.date(byAdding: .day, value: step, to: day) ?? day
            if !cal.isDateInWeekend(day) { left -= 1 }
        }
        return cal.date(byAdding: .hour, value: 17, to: day) ?? day
    }

    /// A clock time on the day `n` business days from today, for the mock calendar.
    static func at(_ n: Int, _ hour: Int, _ minute: Int = 0) -> Date {
        Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: biz(n)) ?? biz(n)
    }

    /// Weekday name of that business day, e.g. "Thursday". Use for days within a week.
    static func wd(_ n: Int) -> String {
        biz(n).formatted(.dateTime.weekday(.wide))
    }

    /// Short date of that business day, e.g. "Nov 19". Use for days further out.
    static func md(_ n: Int) -> String {
        biz(n).formatted(.dateTime.month(.abbreviated).day())
    }
}
