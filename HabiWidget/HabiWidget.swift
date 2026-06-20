import WidgetKit
import SwiftUI

struct StreakEntry: TimelineEntry {
    let date: Date
    let streak: Int
}

struct StreakProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakEntry {
        StreakEntry(date: Date(), streak: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakEntry) -> Void) {
        completion(StreakEntry(date: Date(), streak: SharedStore.readStreak()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakEntry>) -> Void) {
        let entry = StreakEntry(date: Date(), streak: SharedStore.readStreak())
        // The widget itself doesn't talk to Firestore — the main app syncs
        // the streak into the shared App Group store and reloads timelines
        // on sign-in/foreground. This is just a periodic safety-net refresh.
        let timeline = Timeline(entries: [entry], policy: .after(Date().addingTimeInterval(60 * 60)))
        completion(timeline)
    }
}

struct HabiWidgetEntryView: View {
    var entry: StreakEntry

    var body: some View {
        VStack(spacing: 6) {
            Image("Bibi")
                .resizable()
                .scaledToFit()
                .frame(width: 36, height: 36)

            Text("Day \(entry.streak)")
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(HabiBrand.streakGradient)
        }
        .containerBackground(HabiBrand.cream, for: .widget)
    }
}

struct HabiWidget: Widget {
    let kind: String = "HabiWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakProvider()) { entry in
            HabiWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Habi Streak")
        .description("Shows your current Habi streak.")
        .supportedFamilies([.systemSmall])
    }
}
