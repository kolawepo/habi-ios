import Foundation
import FirebaseFirestore

struct DayCount: Identifiable {
    let id = UUID()
    let day: Date
    let label: String
    let count: Int
}

struct WeeklyWrappedData {
    var totalPosts: Int
    var topSkill: String?
    var streak: Int
    var postsByDay: [DayCount] // oldest -> newest, last 7 days inclusive of today
}

enum WeeklyWrappedService {
    // Requires a composite index on posts(userId ASC, createdAt ASC) — if it's
    // missing, Firestore throws FAILED_PRECONDITION with a console link to
    // create it. Surfaced as a friendly message in WeeklyWrappedView rather
    // than a raw error code.
    static func fetch(uid: String, streak: Int) async throws -> WeeklyWrappedData {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: startOfToday) ?? startOfToday

        let snapshot = try await Firestore.firestore()
            .collection("posts")
            .whereField("userId", isEqualTo: uid)
            .whereField("createdAt", isGreaterThanOrEqualTo: Timestamp(date: sevenDaysAgo))
            .getDocuments()

        let posts = snapshot.documents.compactMap { doc -> (date: Date, skill: String, isTutorial: Bool)? in
            guard let ts = doc.data()["createdAt"] as? Timestamp else { return nil }
            let skill = doc.data()["skill"] as? String ?? "Skill"
            let postType = doc.data()["postType"] as? String ?? "progress"
            return (ts.dateValue(), skill, postType == "tutorial")
        }.filter { !$0.isTutorial }

        let skillCounts = Dictionary(grouping: posts, by: { $0.skill }).mapValues(\.count)
        let topSkill = skillCounts.max(by: { $0.value < $1.value })?.key

        let dayFormatter = DateFormatter()
        dayFormatter.dateFormat = "EEE"
        dayFormatter.locale = Locale(identifier: "en_US")

        var postsByDay: [DayCount] = []
        for offset in (0..<7).reversed() {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: startOfToday) else { continue }
            let count = posts.filter { calendar.isDate($0.date, inSameDayAs: day) }.count
            postsByDay.append(DayCount(day: day, label: dayFormatter.string(from: day), count: count))
        }

        return WeeklyWrappedData(totalPosts: posts.count, topSkill: topSkill, streak: streak, postsByDay: postsByDay)
    }
}
