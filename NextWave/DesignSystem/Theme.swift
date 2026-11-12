import SwiftUI

/// One place to retune the app's look.
enum Theme {
    static let cardRadius: CGFloat = 22
    static let overdue = Color(hex: 0xF0506E)
    static let today = Color(hex: 0xF59E0B)
    static let soon = Color(hex: 0x6C6AF4)
    static let done = Color(hex: 0x22C55E)
}

extension Color {
    init(hex: UInt32, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255,
            opacity: opacity
        )
    }
}

extension TriageBucket {
    var tint: Color {
        switch self {
        case .needsYou: Color(hex: 0xF0506E)
        case .waiting: Color(hex: 0xF59E0B)
        case .updates: Color(hex: 0x14B8A6)
        case .notifications: Color(hex: 0x8B8FA3)
        }
    }
}

extension DueTone {
    var color: Color {
        switch self {
        case .overdue: Theme.overdue
        case .today: Theme.today
        case .soon: Theme.soon
        case .later, .none: .secondary
        }
    }
}

extension Date {
    /// Compact timestamp for mail lists: "9:41 AM", "Yesterday", "Tue", "Nov 2".
    var listLabel: String {
        let cal = Calendar.current
        if AppClock.isToday(self) { return formatted(date: .omitted, time: .shortened) }
        if AppClock.isYesterday(self) { return "Yesterday" }
        if let days = cal.dateComponents([.day], from: self, to: AppClock.now).day, days < 7 {
            return formatted(.dateTime.weekday(.abbreviated))
        }
        return formatted(.dateTime.month(.abbreviated).day())
    }
}
