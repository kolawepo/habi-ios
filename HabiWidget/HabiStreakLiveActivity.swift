import ActivityKit
import WidgetKit
import SwiftUI

struct HabiStreakLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: HabiStreakAttributes.self) { context in
            LockScreenView(state: context.state)
                .activityBackgroundTint(HabiBrand.cream)
                .activitySystemActionForegroundColor(HabiBrand.gradientEnd)
        } dynamicIsland: { context in
            // Note: the Dynamic Island's expanded presentation background is
            // controlled by the system (always dark) — Apple doesn't expose a
            // way to tint it cream like the Lock Screen banner. Icon/text
            // colors are still branded.
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    Image("Bibi")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 32, height: 32)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Day \(context.state.streak)")
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundStyle(HabiBrand.streakGradient)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    CountdownOrSecuredView(state: context.state, onDark: true)
                }
            } compactLeading: {
                Image("Bibi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
            } compactTrailing: {
                Text("\(context.state.streak)")
                    .monospacedDigit()
                    .foregroundStyle(HabiBrand.gradientEnd)
            } minimal: {
                Image("Bibi")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
        }
    }
}

private struct LockScreenView: View {
    let state: HabiStreakAttributes.ContentState

    var body: some View {
        HStack(spacing: 14) {
            Image("Bibi")
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 2) {
                Text("Day \(state.streak)")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(HabiBrand.streakGradient)

                CountdownOrSecuredView(state: state, onDark: false)
            }

            Spacer()
        }
        .padding()
    }
}

private struct CountdownOrSecuredView: View {
    let state: HabiStreakAttributes.ContentState
    // Lock Screen banner is cream (dark text reads fine); Dynamic Island's
    // expanded region is always dark (needs light/secondary text instead).
    let onDark: Bool

    var body: some View {
        if state.postedToday {
            Text("Secured for today ✅")
                .font(.caption)
                .foregroundStyle(onDark ? .white.opacity(0.8) : .secondary)
        } else if state.deadline > Date() {
            HStack(spacing: 4) {
                Text(timerInterval: Date()...state.deadline, countsDown: true)
                    .font(.caption)
                    .monospacedDigit()
                    .foregroundStyle(HabiBrand.gradientEnd)
                Text("left to post")
                    .font(.caption)
                    .foregroundStyle(onDark ? .white.opacity(0.8) : .secondary)
            }
        } else {
            Text("Streak at risk — post now!")
                .font(.caption)
                .foregroundStyle(HabiBrand.gradientEnd)
        }
    }
}
