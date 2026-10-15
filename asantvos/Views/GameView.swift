//
//  GameView.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  The shared-screen game: scoreboard, whose turn it is, timer,
//  question and four focusable answer cards.
//

import SwiftUI

struct GameView: View {
    var onPlayAgain: () -> Void
    var onHome: () -> Void

    @State private var game: QuizGame
    @State private var isConfirmingQuit = false
    @FocusState private var isNextFocused: Bool

    init(setup: GameSetup, onPlayAgain: @escaping () -> Void, onHome: @escaping () -> Void) {
        _game = State(initialValue: QuizGame(setup: setup))
        self.onPlayAgain = onPlayAgain
        self.onHome = onHome
    }

    var body: some View {
        ZStack {
            AnimatedBackground()

            if game.phase == .finished {
                ResultsView(game: game, onPlayAgain: onPlayAgain, onHome: onHome)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
            } else {
                questionLayout
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: game.phase)
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: game.currentIndex)
        .task(id: game.currentIndex) {
            // Per-question countdown; cancelled automatically when the question changes.
            try? await Task.sleep(for: .seconds(game.timeLimit))
            guard !Task.isCancelled else { return }
            game.timeUp()
        }
        .onChange(of: game.phase) { _, phase in
            if case .revealed = phase { isNextFocused = true }
        }
        .onExitCommand { isConfirmingQuit = true }   // Siri Remote Back button
        .alert("Quit this game?", isPresented: $isConfirmingQuit) {
            Button("Quit", role: .destructive, action: onHome)
            Button("Keep Playing", role: .cancel) {}
        }
    }

    private var questionLayout: some View {
        VStack(spacing: 40) {
            Scoreboard(players: game.players, currentIndex: game.currentPlayerIndex)

            HStack(alignment: .center) {
                TurnBanner(player: game.currentPlayer)
                Spacer()
                Text("Question \(game.questionNumber) of \(game.questions.count)")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                TimerRing(game: game)
                    .padding(.leading, 30)
            }

            Text(game.currentQuestion.text)
                .font(.system(size: 54, weight: .bold, design: .rounded))
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 160)
                .id(game.currentIndex)
                .transition(.push(from: .trailing))

            LazyVGrid(columns: [GridItem(.flexible(), spacing: 40), GridItem(.flexible(), spacing: 40)], spacing: 40) {
                ForEach(game.currentQuestion.options.indices, id: \.self) { index in
                    AnswerButton(letter: ["A", "B", "C", "D"][index],
                                 text: game.currentQuestion.options[index],
                                 state: answerState(for: index)) {
                        game.answer(index)
                    }
                }
            }
            .id(game.currentIndex)

            revealFooter
                .frame(height: 110)
        }
        .padding(.horizontal, 80)
        .padding(.vertical, 50)
    }

    @ViewBuilder
    private var revealFooter: some View {
        if case .revealed(let selected, let points) = game.phase {
            HStack(spacing: 40) {
                Text(resultMessage(selected: selected, points: points))
                    .font(.title.bold())
                    .foregroundStyle(points > 0 ? .green : .orange)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                Button {
                    game.next()
                } label: {
                    Label(game.isLastQuestion ? "See Results" : "Next Player",
                          systemImage: game.isLastQuestion ? "trophy.fill" : "arrow.right")
                }
                .font(.title3.bold())
                .focused($isNextFocused)
                .accessibilityIdentifier("nextButton")
            }
        }
    }

    private func resultMessage(selected: Int?, points: Int) -> String {
        if points > 0 { return "Correct! +\(points)" }
        if selected == nil { return "Time's up! ⏰" }
        return "Not quite – it was \(game.currentQuestion.options[game.currentQuestion.correctIndex])"
    }

    private func answerState(for index: Int) -> AnswerButton.AnswerState {
        guard case .revealed(let selected, _) = game.phase else { return .normal }
        if index == game.currentQuestion.correctIndex { return .correct }
        if index == selected { return .wrong }
        return .dimmed
    }
}
