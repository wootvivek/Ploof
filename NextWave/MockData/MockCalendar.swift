import Foundation

/// A synthetic calendar for today and the next four working days, built from the same story as the
/// mailbox. Tuned with the estimates in `MockCommitments` so that exactly two commitments come out
/// at risk (the FY27 budget and the manager assessments). The data check asserts that.
enum MockCalendar {
    private typealias C = MockClock

    private static func event(_ id: String, _ title: String, day: Int, _ startHour: Int, _ startMinute: Int,
                              _ endHour: Int, _ endMinute: Int) -> CalendarEvent {
        CalendarEvent(id: id, title: title, start: C.at(day, startHour, startMinute), end: C.at(day, endHour, endMinute))
    }

    static var events: [CalendarEvent] {
        [
            // Today: 2.5 h open, plus the 90 minutes already held for the leadership review
            event("e-sync", "Sandpiper release sync", day: 0, 9, 0, 10, 0),
            event("e-preread", "Leadership pre-read review with Patti", day: 0, 10, 30, 12, 0),
            event("e-412", "Northwind: shared mailbox sync call", day: 0, 13, 0, 14, 0),
            event("e-debrief", "Interview debrief: Cameron Evans", day: 0, 15, 30, 16, 0),

            // Tomorrow: 2 h open
            event("e-lidia", "1:1 with Lidia", day: 1, 9, 0, 10, 0),
            event("e-gonogo", "Build 4.2447 go / no-go", day: 1, 10, 0, 11, 30),
            event("e-miriam", "Lunch with Miriam: field kickoff", day: 1, 12, 0, 13, 0),
            event("e-fy27", "FY27 planning workshop", day: 1, 13, 0, 15, 0),
            event("e-fabrikam", "Fabrikam: RC3 lab schedule", day: 1, 15, 45, 16, 15),

            // Day 2: 2.5 h open
            event("e-standup", "Release readiness stand-up", day: 2, 9, 30, 10, 0),
            event("e-pilot", "Adventure Works pilot review", day: 2, 10, 0, 11, 0),
            event("e-erik", "1:1 with Erik", day: 2, 11, 0, 12, 0),
            event("e-lucerne", "Lucerne Business Weekly interview", day: 2, 13, 0, 14, 0),
            event("e-trey", "Trey Research user study readout", day: 2, 14, 0, 15, 0),
            event("e-proseware", "Proseware creative review", day: 2, 15, 0, 16, 0),

            // Day 3: 2 h open
            event("e-steerprep", "Northwind steering committee prep", day: 3, 9, 0, 10, 30),
            event("e-gate", "Security release review", day: 3, 11, 0, 12, 0),
            event("e-steering", "Northwind steering committee", day: 3, 12, 45, 14, 30),
            event("e-wingtip", "Wingtip Toys kickoff", day: 3, 14, 30, 15, 0),
            event("e-review", "Product review", day: 3, 15, 0, 16, 15),

            // Day 4: 4 h open
            event("e-staff", "Staff meeting", day: 4, 9, 0, 10, 0),
            event("e-lunch", "Team lunch", day: 4, 12, 0, 13, 0),
            event("e-tailspin", "Tailspin Toys demo prep", day: 4, 13, 0, 14, 0),
            event("e-status", "Sandpiper weekly status", day: 4, 16, 0, 17, 0),
        ]
    }

    /// Time already held when the demo starts.
    static var holds: [Hold] {
        [
            Hold(id: "h-board", commitmentID: "p-board", start: C.at(0, 14, 0), end: C.at(0, 15, 30)),
        ]
    }
}
