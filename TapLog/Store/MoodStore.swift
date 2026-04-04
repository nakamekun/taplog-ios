import Combine
import Foundation

@MainActor
final class MoodStore: ObservableObject {
    @Published private(set) var entries: [MoodEntry]

    private let defaults: UserDefaults?
    private let storageKey: String
    private let calendar: Calendar
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        defaults: UserDefaults? = .standard,
        storageKey: String = "mood_entries",
        calendar: Calendar = .current,
        seedEntries: [MoodEntry] = []
    ) {
        self.defaults = defaults
        self.storageKey = storageKey
        self.calendar = calendar
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder.dateDecodingStrategy = .iso8601

        if let defaults {
            self.entries = Self.loadEntries(
                defaults: defaults,
                storageKey: storageKey,
                decoder: decoder
            )
        } else {
            self.entries = seedEntries
        }

        if !seedEntries.isEmpty {
            self.entries = seedEntries
        }

        self.entries.sort { $0.date > $1.date }
    }

    var todayEntry: MoodEntry? {
        entry(for: Date())
    }

    func entry(for date: Date) -> MoodEntry? {
        let targetDate = normalized(date)
        return entries.first { calendar.isDate($0.date, inSameDayAs: targetDate) }
    }

    func saveMood(_ mood: Mood, for date: Date = Date()) {
        let normalizedDate = normalized(date)

        if let index = entries.firstIndex(where: { calendar.isDate($0.date, inSameDayAs: normalizedDate) }) {
            entries[index] = MoodEntry(id: entries[index].id, date: normalizedDate, mood: mood)
        } else {
            entries.append(MoodEntry(date: normalizedDate, mood: mood))
        }

        entries.sort { $0.date > $1.date }
        persist()
    }

    func allEntries() -> [MoodEntry] {
        entries
    }

    private func persist() {
        guard let defaults else { return }
        guard let data = try? encoder.encode(entries) else { return }
        defaults.set(data, forKey: storageKey)
    }

    private func normalized(_ date: Date) -> Date {
        calendar.startOfDay(for: date)
    }

    private static func loadEntries(
        defaults: UserDefaults,
        storageKey: String,
        decoder: JSONDecoder
    ) -> [MoodEntry] {
        guard let data = defaults.data(forKey: storageKey),
              let entries = try? decoder.decode([MoodEntry].self, from: data) else {
            return []
        }
        return entries
    }
}

extension MoodStore {
    static var preview: MoodStore {
        MoodStore(
            defaults: nil,
            seedEntries: [
                MoodEntry(date: Date(), mood: .good),
                MoodEntry(date: Calendar.current.date(byAdding: .day, value: -1, to: Date()) ?? Date(), mood: .great),
                MoodEntry(date: Calendar.current.date(byAdding: .day, value: -2, to: Date()) ?? Date(), mood: .okay),
                MoodEntry(date: Calendar.current.date(byAdding: .day, value: -4, to: Date()) ?? Date(), mood: .bad),
                MoodEntry(date: Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date(), mood: .exhausted)
            ]
        )
    }
}
