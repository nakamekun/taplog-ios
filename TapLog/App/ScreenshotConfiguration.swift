import Foundation

struct ScreenshotConfiguration {
    enum Kind: String {
        case today
        case history
    }

    let kind: Kind

    static var current: ScreenshotConfiguration? {
        let arguments = ProcessInfo.processInfo.arguments

        guard let flagIndex = arguments.firstIndex(of: "--app-store-screenshot"),
              arguments.indices.contains(flagIndex + 1),
              let kind = Kind(rawValue: arguments[flagIndex + 1]) else {
            return nil
        }

        return ScreenshotConfiguration(kind: kind)
    }

    var headline: String {
        switch kind {
        case .today: "Log your day in one tap"
        case .history: "See your mood at a glance"
        }
    }

    var referenceDate: Date {
        Self.calendar.date(from: DateComponents(year: 2026, month: 4, day: 2)) ?? Date()
    }

    var displayedMonth: Date {
        Self.calendar.date(from: DateComponents(year: 2026, month: 4, day: 1)) ?? Date()
    }

    var selectedDate: Date {
        Self.calendar.date(from: DateComponents(year: 2026, month: 4, day: 18)) ?? Date()
    }

    func makeStore() -> MoodStore {
        switch kind {
        case .today:
            return MoodStore(
                defaults: nil,
                seedEntries: [
                    MoodEntry(date: referenceDate, mood: .great),
                    MoodEntry(date: Self.calendar.date(byAdding: .day, value: -1, to: referenceDate) ?? referenceDate, mood: .good),
                    MoodEntry(date: Self.calendar.date(byAdding: .day, value: -3, to: referenceDate) ?? referenceDate, mood: .okay),
                    MoodEntry(date: Self.calendar.date(byAdding: .day, value: -5, to: referenceDate) ?? referenceDate, mood: .bad),
                    MoodEntry(date: Self.calendar.date(byAdding: .day, value: -7, to: referenceDate) ?? referenceDate, mood: .exhausted)
                ]
            )

        case .history:
            let month = displayedMonth
            return MoodStore(
                defaults: nil,
                seedEntries: [
                    MoodEntry(date: day(2, in: month), mood: .good),
                    MoodEntry(date: day(4, in: month), mood: .great),
                    MoodEntry(date: day(7, in: month), mood: .okay),
                    MoodEntry(date: day(10, in: month), mood: .bad),
                    MoodEntry(date: day(12, in: month), mood: .great),
                    MoodEntry(date: day(15, in: month), mood: .exhausted),
                    MoodEntry(date: day(18, in: month), mood: .okay),
                    MoodEntry(date: day(21, in: month), mood: .good),
                    MoodEntry(date: day(24, in: month), mood: .bad),
                    MoodEntry(date: day(27, in: month), mood: .great),
                    MoodEntry(date: day(29, in: month), mood: .okay)
                ]
            )
        }
    }

    private func day(_ day: Int, in month: Date) -> Date {
        var components = Self.calendar.dateComponents([.year, .month], from: month)
        components.day = day
        return Self.calendar.date(from: components) ?? month
    }

    private static let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.locale = Locale(identifier: "en_US_POSIX")
        return calendar
    }()
}
