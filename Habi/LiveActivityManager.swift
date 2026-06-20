import ActivityKit
import Foundation

@MainActor
enum LiveActivityManager {
    static func startOrUpdate(username: String, streak: Int, deadline: Date, postedToday: Bool) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities are disabled in Settings — skipping.")
            return
        }

        let state = HabiStreakAttributes.ContentState(streak: streak, deadline: deadline, postedToday: postedToday)

        if let existing = Activity<HabiStreakAttributes>.activities.first {
            Task {
                await existing.update(ActivityContent(state: state, staleDate: nil))
            }
            return
        }

        let attributes = HabiStreakAttributes(username: username)
        do {
            _ = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: state, staleDate: nil)
            )
        } catch {
            print("Failed to start Live Activity: \(error)")
        }
    }

    static func endAll() {
        Task {
            for activity in Activity<HabiStreakAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
        }
    }
}
