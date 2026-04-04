import Foundation

struct MoodEntry: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let mood: Mood

    init(id: UUID = UUID(), date: Date, mood: Mood) {
        self.id = id
        self.date = date
        self.mood = mood
    }
}
