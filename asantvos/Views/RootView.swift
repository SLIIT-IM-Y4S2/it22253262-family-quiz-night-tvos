//
//  RootView.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Flow: Home → Who's playing? → Pick a category → Game → Results.
//  The Siri Remote's Back/Menu button pops screens automatically.
//

import SwiftUI

enum Route: Hashable {
    case setup
    case category([Player])
    case game(GameSetup)
}

struct RootView: View {
    @State private var path: [Route] = []

    var body: some View {
        NavigationStack(path: $path) {
            HomeView { path.append(.setup) }
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .setup:
                        PlayerSetupView { players in path.append(.category(players)) }
                    case .category(let players):
                        CategoryPickerView(players: players) { category in
                            path.append(.game(GameSetup(players: players, category: category)))
                        }
                    case .game(let setup):
                        GameView(setup: setup,
                                 onPlayAgain: { replay(setup) },
                                 onHome: { path.removeAll() })
                        .id(setup.id)
                    }
                }
        }
    }

    /// Same players and category, fresh questions and scores.
    private func replay(_ setup: GameSetup) {
        guard !path.isEmpty else { return }
        path[path.count - 1] = .game(GameSetup(players: setup.players, category: setup.category))
    }
}
