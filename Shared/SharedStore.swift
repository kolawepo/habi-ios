import Foundation

// Bridges data from the main app (which talks to Firestore) to the widget
// extension (which can't make live Firestore calls on its own refresh budget).
enum SharedStore {
    static let appGroupId = "group.com.habi.ios"

    static func write(streak: Int) {
        let defaults = UserDefaults(suiteName: appGroupId)
        defaults?.set(streak, forKey: "streak")
        defaults?.set(Date(), forKey: "lastSyncedAt")
    }

    static func readStreak() -> Int {
        UserDefaults(suiteName: appGroupId)?.integer(forKey: "streak") ?? 0
    }
}
