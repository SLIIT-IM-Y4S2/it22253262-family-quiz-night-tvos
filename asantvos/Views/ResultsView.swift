//
//  ResultsView.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import SwiftUI

struct ResultsView: View {
    let game: QuizGame
    var onPlayAgain: () -> Void
    var onHome: () -> Void

    @State private var raised = false
    @FocusState private var isPlayAgainFocused: Bool

    private var title: String {
        let winners = game.winners
        if winners.count > 1 { return "It's a draw! 🤝" }
        return "\(winners.first?.avatar.emoji ?? "🏆") \(winners.first?.name ?? "") wins!"
    }

    var body: some View {
        VStack(spacing: 50) {
            Text(title)
                .font(.system(size: 84, weight: .black, design: .rounded))
                .scaleEffect(raised ? 1 : 0.5)

            HStack(alignment: .bottom, spacing: 40) {
                ForEach(Array(game.rankings.enumerated()), id: \.element.id) { rank, player in
                    PodiumColumn(player: player, rank: rank,
                                 height: raised ? barHeight(for: player) : 20)
                        .animation(.spring(response: 0.8, dampingFraction: 0.7).delay(Double(rank) * 0.2),
                                   value: raised)
                }
            }
            .frame(height: 480, alignment: .bottom)

            HStack(spacing: 40) {
                Button("Play Again", systemImage: "arrow.clockwise", action: onPlayAgain)
                    .focused($isPlayAgainFocused)
                    .accessibilityIdentifier("playAgainButton")
                Button("Home", systemImage: "house.fill", action: onHome)
            }
            .font(.title3.bold())
        }
        .padding(60)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6)) { raised = true }
            isPlayAgainFocused = true
        }
    }

    private func barHeight(for player: Player) -> CGFloat {
        let top = max(game.rankings.first?.score ?? 1, 1)
        return 80 + 300 * CGFloat(player.score) / CGFloat(top)
    }
}

struct PodiumColumn: View {
    let player: Player
    let rank: Int
    let height: CGFloat

    var body: some View {
        VStack(spacing: 16) {
            Text(rank == 0 ? "👑" : " ").font(.system(size: 60))
            Text(player.avatar.emoji).font(.system(size: 80))
            Text(player.name).font(.title3.bold())
            Text("\(player.score) pts · \(player.correctAnswers) correct")
                .font(.callout)
                .foregroundStyle(.secondary)
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(player.avatar.color.gradient)
                .frame(width: 220, height: height)
                .overlay(alignment: .top) {
                    Text("#\(rank + 1)").font(.title.bold()).foregroundStyle(.white).padding(.top, 16)
                }
        }
        .accessibilityElement(children: .combine)
    }
}
