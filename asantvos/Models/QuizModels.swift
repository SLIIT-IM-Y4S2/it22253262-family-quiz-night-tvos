//
//  QuizModels.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import SwiftUI

struct Player: Identifiable, Hashable {
    let id: UUID
    var name: String
    var avatar: PlayerAvatar
    var score = 0
    var correctAnswers = 0

    init(id: UUID = UUID(), name: String, avatar: PlayerAvatar) {
        self.id = id
        self.name = name
        self.avatar = avatar
    }
}

/// Each player gets a distinct colour + emoji so everyone on the sofa
/// can see whose turn it is from across the room.
enum PlayerAvatar: Int, CaseIterable, Hashable {
    case fox, panda, tiger, owl

    var emoji: String {
        switch self {
        case .fox: "🦊"
        case .panda: "🐼"
        case .tiger: "🐯"
        case .owl: "🦉"
        }
    }

    var color: Color {
        switch self {
        case .fox: .orange
        case .panda: .teal
        case .tiger: .pink
        case .owl: .purple
        }
    }
}

enum QuizCategory: String, CaseIterable, Identifiable, Hashable {
    case general, science, sriLanka, mixed

    var id: String { rawValue }

    var title: String {
        switch self {
        case .general: "General Knowledge"
        case .science: "Science & Nature"
        case .sriLanka: "Sri Lanka"
        case .mixed: "Mixed Bag"
        }
    }

    var symbol: String {
        switch self {
        case .general: "lightbulb.fill"
        case .science: "atom"
        case .sriLanka: "globe.asia.australia.fill"
        case .mixed: "shuffle"
        }
    }

    var gradient: [Color] {
        switch self {
        case .general: [.orange, .red]
        case .science: [.teal, .blue]
        case .sriLanka: [.green, .mint]
        case .mixed: [.purple, .indigo]
        }
    }
}

struct Question: Identifiable, Hashable {
    let id: Int
    let category: QuizCategory
    let text: String
    let options: [String]
    let correctIndex: Int
}

/// Everything needed to start a game – passed through NavigationStack.
struct GameSetup: Hashable {
    /// New id per game so "Play Again" starts with fresh state.
    var id = UUID()
    var players: [Player]
    var category: QuizCategory
    var roundsPerPlayer = 3
}
