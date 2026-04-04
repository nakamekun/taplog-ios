import SwiftUI
import UIKit

struct HomeView: View {
    @EnvironmentObject private var moodStore: MoodStore

    @State private var savedVisible = false
    @State private var lastSavedMood: Mood?
    @State private var saveFeedbackToken = UUID()

    private let referenceDate: Date
    private let showsSavedFeedbackByDefault: Bool

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter
    }()

    init(
        referenceDate: Date = Date(),
        showsSavedFeedbackByDefault: Bool = false
    ) {
        self.referenceDate = referenceDate
        self.showsSavedFeedbackByDefault = showsSavedFeedbackByDefault
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text(dateFormatter.string(from: referenceDate))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text("How do you feel today?")
                        .font(.largeTitle.bold())
                        .foregroundStyle(.primary)

                    Text("Log your day in one tap.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                VStack(spacing: 14) {
                    ForEach(Mood.allCases) { mood in
                        MoodButtonView(
                            mood: mood,
                            isSelected: moodStore.entry(for: referenceDate)?.mood == mood,
                            action: { save(mood) }
                        )
                    }
                }
                .overlay(alignment: .bottom) {
                    if savedVisible || showsSavedFeedbackByDefault {
                        HStack(spacing: 6) {
                            Text("Saved")
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                        }
                        .font(.footnote.weight(.semibold))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial, in: Capsule())
                        .shadow(color: .black.opacity(0.10), radius: 16, y: 10)
                        .transition(.scale(scale: 0.94).combined(with: .opacity))
                        .offset(y: 52)
                    }
                }

                if let todayEntry = moodStore.entry(for: referenceDate) {
                    HStack(spacing: 8) {
                        Text(todayEntry.mood.emoji)
                        Text("Today: \(todayEntry.mood.title)")
                            .font(.subheadline.weight(.medium))
                    }
                    .foregroundStyle(.secondary)
                    .padding(.top, 18)
                }

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 20)
            .padding(.top, 24)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Today")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save(_ mood: Mood) {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        moodStore.saveMood(mood, for: referenceDate)
        lastSavedMood = mood

        let token = UUID()
        saveFeedbackToken = token
        savedVisible = false

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.24) {
            guard saveFeedbackToken == token, lastSavedMood == mood else { return }
            withAnimation(.spring(response: 0.34, dampingFraction: 0.82)) {
                savedVisible = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.24) {
            guard saveFeedbackToken == token, lastSavedMood == mood else { return }
            withAnimation(.easeOut(duration: 0.22)) {
                savedVisible = false
            }
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            HomeView()
                .environmentObject(MoodStore.preview)
        }
    }
}
