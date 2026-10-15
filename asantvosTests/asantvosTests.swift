//
//  asantvosTests.swift
//  Family Quiz Night – unit tests
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import Testing
import Foundation
@testable import asantvos

/// Deterministic generator so shuffling can be tested.
struct SeededGenerator: RandomNumberGenerator {
    var state: UInt64
    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}

@MainActor
struct QuizGameTests {
    private let start = Date(timeIntervalSince1970: 1_000)

    private func makeGame(players: Int = 2, questions: Int = 4) -> QuizGame {
        let people = PlayerAvatar.allCases.prefix(players).map { Player(name: "\($0)", avatar: $0) }
        let qs = (0..<questions).map {
            Question(id: $0, category: .general, text: "Q\($0)", options: ["A", "B", "C", "D"], correctIndex: 0)
        }
        return QuizGame(players: people, questions: qs, timeLimit: 10, now: start)
    }

    @Test func turnsRotateBetweenPlayers() {
        let game = makeGame(players: 3, questions: 6)
        var order: [Int] = []
        for _ in 0..<6 {
            order.append(game.currentPlayerIndex)
            game.answer(1, at: start)
            game.next(at: start)
        }
        #expect(order == [0, 1, 2, 0, 1, 2])
    }

    @Test func fastCorrectAnswerEarnsFullBonus() {
        let game = makeGame()
        game.answer(0, at: start)
        #expect(game.players[0].score == QuizGame.basePoints + QuizGame.maxSpeedBonus)
        #expect(game.players[0].correctAnswers == 1)
    }

    @Test func slowerCorrectAnswerEarnsLess() {
        let game = makeGame()
        game.answer(0, at: start + 5)   // half the time left
        #expect(game.players[0].score == 125)
    }

    @Test func wrongAnswerAndTimeoutScoreZero() {
        let game = makeGame()
        game.answer(2, at: start)
        #expect(game.players[0].score == 0)
        #expect(game.phase == .revealed(selected: 2, pointsEarned: 0))
        game.next(at: start)
        game.timeUp(at: start + 10)
        #expect(game.players[1].score == 0)
        #expect(game.phase == .revealed(selected: nil, pointsEarned: 0))
    }

    @Test func secondPressOnSameQuestionIsIgnored() {
        let game = makeGame()
        game.answer(0, at: start)
        game.answer(0, at: start)
        game.timeUp(at: start + 20)
        #expect(game.players[0].score == 150)
    }

    @Test func nextOnlyWorksAfterAnswering() {
        let game = makeGame()
        game.next(at: start)
        #expect(game.currentIndex == 0)
    }

    @Test func gameFinishesAfterLastQuestion() {
        let game = makeGame(players: 2, questions: 2)
        game.answer(0, at: start); game.next(at: start)
        #expect(game.isLastQuestion)
        game.answer(0, at: start); game.next(at: start)
        #expect(game.phase == .finished)
    }

    @Test func rankingsAndDraws() {
        let game = makeGame(players: 2, questions: 2)
        game.answer(0, at: start); game.next(at: start)       // P1 +150
        game.answer(0, at: start); game.next(at: start)       // P2 +150
        #expect(game.winners.count == 2)                      // draw

        let game2 = makeGame(players: 2, questions: 2)
        game2.answer(1, at: start); game2.next(at: start)     // P1 wrong
        game2.answer(0, at: start); game2.next(at: start)     // P2 right
        #expect(game2.rankings.first?.name == game2.players[1].name)
        #expect(game2.winners.count == 1)
    }

    @Test func pointsAreClampedToValidRange() {
        #expect(QuizGame.points(isCorrect: true, timeRemaining: 99, timeLimit: 10) == 150)
        #expect(QuizGame.points(isCorrect: true, timeRemaining: -5, timeLimit: 10) == 100)
        #expect(QuizGame.points(isCorrect: false, timeRemaining: 10, timeLimit: 10) == 0)
    }
}

@MainActor
struct QuestionBankTests {
    @Test(arguments: [QuizCategory.general, .science, .sriLanka])
    func everyCategoryHasEnoughForFourPlayers(category: QuizCategory) {
        #expect(QuestionBank.all.filter { $0.category == category }.count >= 12)
    }

    @Test func questionsAreWellFormed() {
        for q in QuestionBank.all {
            #expect(q.options.count == 4)
            #expect(Set(q.options).count == 4, "Duplicate options in: \(q.text)")
            #expect(q.options.indices.contains(q.correctIndex))
        }
    }

    @Test func shufflingKeepsTheCorrectAnswer() {
        var rng = SeededGenerator(state: 42)
        let picked = QuestionBank.questions(for: .general, count: 12, using: &rng)
        #expect(picked.count == 12)
        #expect(Set(picked.map(\.id)).count == 12, "No repeated questions in one game")
        for q in picked {
            let original = QuestionBank.all.first { $0.id == q.id }!
            #expect(q.options[q.correctIndex] == original.options[original.correctIndex])
        }
    }

    @Test func mixedDrawsFromSeveralCategories() {
        var rng = SeededGenerator(state: 7)
        let picked = QuestionBank.questions(for: .mixed, count: 12, using: &rng)
        #expect(Set(picked.map(\.category)).count > 1)
    }
}
