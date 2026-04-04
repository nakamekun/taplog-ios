import SwiftUI

@main
struct TapLogApp: App {
    @StateObject private var moodStore = MoodStore()

    var body: some Scene {
        WindowGroup {
            if let screenshotConfiguration = ScreenshotConfiguration.current {
                AppStoreScreenshotView(configuration: screenshotConfiguration)
            } else {
                MainTabView()
                    .environmentObject(moodStore)
            }
        }
    }
}
