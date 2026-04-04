import SwiftUI

enum Mood: String, Codable, CaseIterable, Identifiable {
    case great
    case good
    case okay
    case bad
    case exhausted

    var id: String { rawValue }

    var title: String {
        switch self {
        case .great: "Great"
        case .good: "Good"
        case .okay: "Okay"
        case .bad: "Bad"
        case .exhausted: "Exhausted"
        }
    }

    var emoji: String {
        switch self {
        case .great: "😄"
        case .good: "🙂"
        case .okay: "😐"
        case .bad: "😔"
        case .exhausted: "😫"
        }
    }

    var color: Color {
        switch self {
        case .great: Color(red: 0.95, green: 0.63, blue: 0.24)
        case .good: Color(red: 0.34, green: 0.67, blue: 0.43)
        case .okay: Color(red: 0.43, green: 0.58, blue: 0.83)
        case .bad: Color(red: 0.56, green: 0.49, blue: 0.78)
        case .exhausted: Color(red: 0.58, green: 0.58, blue: 0.62)
        }
    }

    var tint: Color { color }
}
