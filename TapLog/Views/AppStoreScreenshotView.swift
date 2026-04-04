import SwiftUI

struct AppStoreScreenshotView: View {
    let configuration: ScreenshotConfiguration

    @StateObject private var moodStore: MoodStore

    init(configuration: ScreenshotConfiguration) {
        self.configuration = configuration
        _moodStore = StateObject(wrappedValue: configuration.makeStore())
    }

    var body: some View {
        GeometryReader { geometry in
            let isPad = geometry.size.width >= 1000
            let horizontalPadding = isPad ? 96.0 : 40.0
            let topPadding = isPad ? 76.0 : 42.0
            let spacing = isPad ? 42.0 : 26.0

            ZStack {
                LinearGradient(
                    colors: [
                        Color.white,
                        Color(red: 0.97, green: 0.97, blue: 0.99)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                VStack(alignment: .leading, spacing: spacing) {
                    Text(configuration.headline)
                        .font(.system(size: isPad ? 62 : 42, weight: .bold, design: .rounded))
                        .tracking(-0.8)
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity)

                    screenshotCard
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.top, topPadding)
                .padding(.bottom, isPad ? 56 : 34)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
        .preferredColorScheme(.light)
        .statusBar(hidden: true)
        .environmentObject(moodStore)
    }

    @ViewBuilder
    private var screenshotCard: some View {
        RoundedRectangle(cornerRadius: 36, style: .continuous)
            .fill(Color.white)
            .shadow(color: .black.opacity(0.08), radius: 28, y: 18)
            .overlay {
                Group {
                    switch configuration.kind {
                    case .today:
                        NavigationStack {
                            HomeView(
                                referenceDate: configuration.referenceDate,
                                showsSavedFeedbackByDefault: true
                            )
                        }

                    case .history:
                        NavigationStack {
                            HistoryView(
                                displayedMonth: configuration.displayedMonth,
                                selectedDate: configuration.selectedDate
                            )
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 36, style: .continuous))
            }
    }
}

struct AppStoreScreenshotView_Previews: PreviewProvider {
    static var previews: some View {
        AppStoreScreenshotView(configuration: ScreenshotConfiguration(kind: .today))
            .previewLayout(.fixed(width: 1290, height: 2796))
    }
}
