//
//  GameComponents.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Reusable custom components: animated mesh background, scoreboard,
//  turn banner, countdown ring, answer card and a shake effect.
//

import SwiftUI

/// Slowly moving mesh gradient used behind every screen.
struct AnimatedBackground: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 1 / 30)) { context in
            let t = Float(context.date.timeIntervalSinceReferenceDate)
            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5], [0.5 + 0.15 * sin(t * 0.4), 0.5 + 0.15 * cos(t * 0.3)], [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1],
                ],
                colors: [
                    .indigo, .purple, .blue,
                    .purple, Color(red: 0.25, green: 0.1, blue: 0.45), .indigo,
                    .black, .indigo, .black,
                ]
            )
        }
        .ignoresSafeArea()
        .accessibilityHidden(true)
    }
}

struct Scoreboard: View {
    let players: [Player]
    let currentIndex: Int
    @Namespace private var highlight

    var body: some View {
        HStack(spacing: 30) {
            ForEach(Array(players.enumerated()), id: \.element.id) { index, player in
                let isCurrent = index == currentIndex
                HStack(spacing: 14) {
                    Text(player.avatar.emoji).font(.system(size: 44))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(player.name).font(.headline).lineLimit(1)
                        Text("\(player.score)")
                            .font(.title3.monospacedDigit().bold())
                            .contentTransition(.numericText(value: Double(player.score)))
                    }
                }
                .padding(.horizontal, 26)
                .padding(.vertical, 14)
                .background {
                    if isCurrent {
                        Capsule()
                            .fill(player.avatar.color.gradient)
                            .matchedGeometryEffect(id: "turn", in: highlight)
                    } else {
                        Capsule().fill(.white.opacity(0.08))
                    }
                }
                .scaleEffect(isCurrent ? 1.08 : 1)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(isCurrent ? .isSelected : [])
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: currentIndex)
        .animation(.spring, value: players.map(\.score))
    }
}

struct TurnBanner: View {
    let player: Player

    var body: some View {
        HStack(spacing: 18) {
            Text(player.avatar.emoji).font(.system(size: 64))
            Text("\(player.name)'s turn")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(player.avatar.color)
        }
        .id(player.id)
        .transition(.asymmetric(insertion: .move(edge: .leading).combined(with: .opacity),
                                removal: .opacity))
    }
}

/// Countdown ring that turns orange then red as time runs out.
struct TimerRing: View {
    let game: QuizGame

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.1, paused: game.phase != .asking)) { context in
            let remaining = game.timeRemaining(at: context.date)
            let fraction = remaining / game.timeLimit
            let color: Color = fraction > 0.5 ? .green : (fraction > 0.2 ? .orange : .red)
            ZStack {
                Circle().stroke(.white.opacity(0.15), lineWidth: 12)
                Circle()
                    .trim(from: 0, to: fraction)
                    .stroke(color, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Text("\(Int(remaining.rounded(.up)))")
                    .font(.title2.monospacedDigit().bold())
            }
            .frame(width: 100, height: 100)
            .accessibilityLabel("\(Int(remaining.rounded(.up))) seconds left")
        }
    }
}

struct AnswerButton: View {
    enum AnswerState { case normal, correct, wrong, dimmed }

    let letter: String
    let text: String
    let state: AnswerState
    let action: () -> Void

    private var fill: Color {
        switch state {
        case .normal: Color(red: 0.2, green: 0.15, blue: 0.4)
        case .correct: .green
        case .wrong: .red
        case .dimmed: Color(red: 0.2, green: 0.15, blue: 0.4).opacity(0.4)
        }
    }

    var body: some View {
        Button(action: action) {
            HStack(spacing: 24) {
                Text(letter)
                    .font(.title2.bold())
                    .frame(width: 70, height: 70)
                    .background(.white.opacity(0.2), in: Circle())
                Text(text)
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.leading)
                Spacer(minLength: 0)
                if state == .correct {
                    Image(systemName: "checkmark.circle.fill").font(.largeTitle).transition(.scale)
                } else if state == .wrong {
                    Image(systemName: "xmark.circle.fill").font(.largeTitle).transition(.scale)
                }
            }
            .foregroundStyle(.white)
            .padding(28)
            .frame(maxWidth: .infinity, minHeight: 130)
            .background(fill)
        }
        .buttonStyle(.card)
        .modifier(ShakeEffect(shakes: state == .wrong ? 1 : 0))
        .animation(.easeInOut(duration: 0.5), value: state)
        .accessibilityLabel("\(letter): \(text)")
        .accessibilityValue(state == .correct ? "Correct answer" : state == .wrong ? "Wrong" : "")
    }
}

/// Custom animatable effect: a quick horizontal shake for wrong answers.
nonisolated struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat

    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: 18 * sin(shakes * .pi * 6), y: 0))
    }
}
