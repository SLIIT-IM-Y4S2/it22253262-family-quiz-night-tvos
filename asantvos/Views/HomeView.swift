//
//  HomeView.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import SwiftUI

struct HomeView: View {
    var onPlay: () -> Void

    @State private var showRules = false
    @State private var bounce = false

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 50) {
                HStack(spacing: 30) {
                    ForEach(Array(PlayerAvatar.allCases.enumerated()), id: \.offset) { index, avatar in
                        Text(avatar.emoji)
                            .font(.system(size: 110))
                            .offset(y: bounce ? -20 : 20)
                            .animation(.easeInOut(duration: 1.2).repeatForever().delay(Double(index) * 0.2),
                                       value: bounce)
                    }
                }
                .accessibilityHidden(true)

                VStack(spacing: 12) {
                    Text("Family Quiz Night")
                        .font(.system(size: 96, weight: .black, design: .rounded))
                    Text("2–4 players · one remote · pass it on!")
                        .font(.title2)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 40) {
                    Button(action: onPlay) {
                        Label("Play", systemImage: "play.fill").padding(.horizontal, 40)
                    }
                    .accessibilityIdentifier("playButton")

                    Button { showRules = true } label: {
                        Label("How to Play", systemImage: "questionmark.circle")
                    }
                }
                .font(.title2.bold())
            }
        }
        .onAppear { bounce = true }
        .sheet(isPresented: $showRules) { HowToPlayView() }
    }
}

struct HowToPlayView: View {
    private let rules: [(String, String)] = [
        ("person.3.fill", "Add 2–4 players. Everyone gets their own animal and colour."),
        ("square.grid.2x2.fill", "Pick a category. Each player gets 3 questions."),
        ("hand.point.up.left.fill", "On your turn, swipe on the remote to choose and click to answer."),
        ("timer", "You have 15 seconds. Correct = 100 points + up to 50 for speed."),
        ("arrow.triangle.2.circlepath", "Pass the remote to the next player. Highest score wins!"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 36) {
            Text("How to Play").font(.largeTitle.bold())
            ForEach(rules, id: \.1) { symbol, text in
                Label(text, systemImage: symbol).font(.title3)
            }
        }
        .padding(80)
    }
}

#Preview {
    HomeView {}
}
