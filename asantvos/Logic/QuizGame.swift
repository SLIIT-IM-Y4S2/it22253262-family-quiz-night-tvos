//
//  QuizGame.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//
//  Game engine (the "model" in MVVM). Players take turns on one
//  shared Siri Remote ("hot seat"). No UI code here, so it is unit tested.
//

import Foundation
import Observation

@Observable
final class QuizGame {
    enum Phase: Equatable {
        case asking
        case revealed(selected: Int?, pointsEarned: Int)
        case finished
    }

    static let basePoints = 100
    static let maxSpeedBonus = 50

    private(set) var players: [Player]
    let questions: [Question]
    let timeLimit: TimeInterval
    private(set) var currentIndex = 0
    private(set) var phase: Phase = .asking
    private(set) var questionStartedAt: Date

    init(players: [Player], questions: [Question], timeLimit: TimeInterval = 15, now: Date = .now) {
        precondition(!players.isEmpty, "A game needs at least one player")
        precondition(!questions.isEmpty, "A game needs at least one question")
        self.players = players
        self.questions = questions
        self.timeLimit = timeLimit
        self.questionStartedAt = now
    }

    convenience init(setup: GameSetup) {
        let count = setup.players.count * setup.roundsPerPlayer
        self.init(players: setup.players,
                  questions: QuestionBank.questions(for: setup.category, count: count))
    }

    // MARK: - State

    var currentQuestion: Question { questions[currentIndex] }

    /// Turns rotate: question 0 → player 0, question 1 → player 1, …
    var currentPlayerIndex: Int { currentIndex % players.count }
    var currentPlayer: Player { players[currentPlayerIndex] }

    var questionNumber: Int { currentIndex + 1 }
    var isLastQuestion: Bool { currentIndex == questions.count - 1 }

    func timeRemaining(at date: Date = .now) -> TimeInterval {
        max(0, timeLimit - date.timeIntervalSince(questionStartedAt))
    }

    /// Highest score first; ties keep turn order.
    var rankings: [Player] {
        players.enumerated()
            .sorted { $0.element.score != $1.element.score ? $0.element.score > $1.element.score : $0.offset < $1.offset }
            .map(\.element)
    }

    /// Everyone sharing the top score (there can be a draw).
    var winners: [Player] {
        guard let top = rankings.first?.score else { return [] }
        return players.filter { $0.score == top }
    }

    // MARK: - Actions

    /// Faster correct answers earn a bigger bonus.
    static func points(isCorrect: Bool, timeRemaining: TimeInterval, timeLimit: TimeInterval) -> Int {
        guard isCorrect else { return 0 }
        let fraction = timeLimit > 0 ? min(max(timeRemaining / timeLimit, 0), 1) : 0
        return basePoints + Int((Double(maxSpeedBonus) * fraction).rounded())
    }

    /// `option == nil` means time ran out.
    func answer(_ option: Int?, at date: Date = .now) {
        guard phase == .asking else { return }   // ignore double presses
        let isCorrect = option == currentQuestion.correctIndex
        let earned = Self.points(isCorrect: isCorrect, timeRemaining: timeRemaining(at: date), timeLimit: timeLimit)
        players[currentPlayerIndex].score += earned
        if isCorrect { players[currentPlayerIndex].correctAnswers += 1 }
        phase = .revealed(selected: option, pointsEarned: earned)
    }

    func timeUp(at date: Date = .now) {
        answer(nil, at: date)
    }

    func next(at date: Date = .now) {
        guard case .revealed = phase else { return }
        if isLastQuestion {
            phase = .finished
        } else {
            currentIndex += 1
            questionStartedAt = date
            phase = .asking
        }
    }
}
