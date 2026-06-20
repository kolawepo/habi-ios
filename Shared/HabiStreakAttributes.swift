import ActivityKit
import Foundation

struct HabiStreakAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var streak: Int
        var deadline: Date
        var postedToday: Bool
    }

    var username: String
}

// Shared so both the app (which starts/updates the Activity) and the widget
// extension (which renders it) compute the same deadline/postedToday from
// the same Firestore fields, instead of duplicating date logic twice.
enum StreakDeadline {
    // Mirrors App.jsx's toDateString()-based comparisons on the web app.
    static func todayDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.string(from: Date())
    }

    private static func parse(_ dateString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE MMM d yyyy"
        formatter.locale = Locale(identifier: "en_US")
        return formatter.date(from: dateString)
    }

    // The web app's checkStreakFreshness resets the streak once "today" is no
    // longer lastPostDate or lastPostDate + 1 day. So the streak actually
    // survives through all of (lastPostDate + 1), and the reset instant is
    // midnight starting (lastPostDate + 2) — equivalently, "midnight of the
    // day following the day after lastPostDate". That's the countdown target.
    static func computeDeadline(lastPostDate: String?) -> Date {
        let calendar = Calendar.current
        guard let lastPostDate, !lastPostDate.isEmpty, let parsed = parse(lastPostDate) else {
            // No posts yet — give a sensible default so the countdown isn't zero.
            return calendar.date(byAdding: .day, value: 2, to: calendar.startOfDay(for: Date())) ?? Date()
        }
        let startOfLastPost = calendar.startOfDay(for: parsed)
        return calendar.date(byAdding: .day, value: 2, to: startOfLastPost) ?? Date()
    }

    static func postedToday(lastPostDate: String?) -> Bool {
        lastPostDate == todayDateString()
    }
}
