import SwiftUI
import Charts

struct WeeklyWrappedView: View {
    let uid: String
    let streak: Int

    @State private var data: WeeklyWrappedData?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var renderedImage: Image?

    var body: some View {
        NavigationStack {
            Group {
                if let data {
                    ScrollView {
                        VStack(spacing: 20) {
                            WrappedCardContent(data: data)

                            if let renderedImage {
                                ShareLink(
                                    item: renderedImage,
                                    preview: SharePreview("My Habi Weekly Wrapped", image: renderedImage)
                                ) {
                                    Label("Share", systemImage: "square.and.arrow.up")
                                        .frame(maxWidth: .infinity)
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                        .padding()
                    }
                } else if isLoading {
                    ProgressView("Loading your week…")
                } else if let errorMessage {
                    VStack(spacing: 8) {
                        Text("Couldn't load Weekly Wrapped")
                            .font(.headline)
                        Text(errorMessage)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(32)
                }
            }
            .navigationTitle("Weekly Wrapped")
            .task { await load() }
        }
    }

    private func load() async {
        do {
            let result = try await WeeklyWrappedService.fetch(uid: uid, streak: streak)
            data = result
            isLoading = false
            renderCardImage(data: result)
        } catch {
            // Firestore's FAILED_PRECONDITION for a missing composite index
            // includes a console link in its message — surface it as-is since
            // it's directly actionable, rather than masking it.
            errorMessage = error.localizedDescription
            isLoading = false
        }
    }

    private func renderCardImage(data: WeeklyWrappedData) {
        let renderer = ImageRenderer(content: WrappedCardContent(data: data).frame(width: 360))
        renderer.scale = UIScreen.main.scale
        if let uiImage = renderer.uiImage {
            renderedImage = Image(uiImage: uiImage)
        }
    }
}

private struct WrappedCardContent: View {
    let data: WeeklyWrappedData

    var body: some View {
        VStack(spacing: 16) {
            Image("Bibi")
                .resizable()
                .scaledToFit()
                .frame(width: 56, height: 56)

            Text("Habi Weekly Wrapped")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(HabiBrand.streakGradient)

            HStack(spacing: 32) {
                statBlock(value: "\(data.totalPosts)", label: "Posts")
                statBlock(value: "\(data.streak)", label: "Day Streak")
            }

            if let topSkill = data.topSkill {
                Text("Top skill: \(topSkill)")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            } else if data.totalPosts == 0 {
                Text("No posts yet this week — share something to see your top skill!")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            Chart(data.postsByDay) { item in
                BarMark(
                    x: .value("Day", item.label),
                    y: .value("Posts", item.count)
                )
                .foregroundStyle(HabiBrand.streakGradient)
            }
            .frame(height: 140)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 3))
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(HabiBrand.cream)
        .clipShape(RoundedRectangle(cornerRadius: 28))
    }

    private func statBlock(value: String, label: String) -> some View {
        VStack {
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(HabiBrand.streakGradient)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
