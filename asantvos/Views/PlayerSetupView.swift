//
//  PlayerSetupView.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import SwiftUI

struct PlayerSetupView: View {
    static let minPlayers = 2
    static let maxPlayers = 4

    var onContinue: ([Player]) -> Void

    @State private var players: [Player] = [
        Player(name: "Player 1", avatar: .fox),
        Player(name: "Player 2", avatar: .panda),
    ]

    private var canContinue: Bool {
        players.count >= Self.minPlayers
            && players.allSatisfy { !$0.name.trimmingCharacters(in: .whitespaces).isEmpty }
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 60) {
                Text("Who's playing?")
                    .font(.system(size: 72, weight: .heavy, design: .rounded))

                HStack(spacing: 40) {
                    ForEach($players) { $player in
                        PlayerCard(player: $player, canRemove: players.count > Self.minPlayers) {
                            withAnimation(.spring) { players.removeAll { $0.id == player.id } }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }

                HStack(spacing: 40) {
                    Button("Add Player", systemImage: "person.badge.plus", action: addPlayer)
                        .disabled(players.count >= Self.maxPlayers)
                    Button {
                        onContinue(players.map { p in
                            var p = p
                            p.name = p.name.trimmingCharacters(in: .whitespaces)
                            return p
                        })
                    } label: {
                        Label("Continue", systemImage: "arrow.right").padding(.horizontal, 30)
                    }
                    .disabled(!canContinue)
                    .accessibilityIdentifier("continueButton")
                }
                .font(.title3.bold())
            }
            .padding(60)
        }
    }

    private func addPlayer() {
        let used = Set(players.map(\.avatar))
        guard let avatar = PlayerAvatar.allCases.first(where: { !used.contains($0) }) else { return }
        withAnimation(.spring) {
            players.append(Player(name: "Player \(players.count + 1)", avatar: avatar))
        }
    }
}

struct PlayerCard: View {
    @Binding var player: Player
    var canRemove: Bool
    var onRemove: () -> Void

    var body: some View {
        VStack(spacing: 24) {
            Text(player.avatar.emoji)
                .font(.system(size: 120))
                .frame(width: 220, height: 220)
                .background(player.avatar.color.gradient, in: Circle())
                .accessibilityHidden(true)

            TextField("Name", text: $player.name)
                .font(.title3)
                .frame(width: 320)

            Button("Remove", systemImage: "trash", role: .destructive, action: onRemove)
                .labelStyle(.iconOnly)
                .opacity(canRemove ? 1 : 0)
                .disabled(!canRemove)
        }
        .padding(30)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 40, style: .continuous))
    }
}

#Preview {
    PlayerSetupView { _ in }
}
