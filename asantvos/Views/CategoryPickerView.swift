//
//  CategoryPickerView.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import SwiftUI

struct CategoryPickerView: View {
    let players: [Player]
    var onPick: (QuizCategory) -> Void

    var body: some View {
        ZStack {
            AnimatedBackground()

            VStack(spacing: 60) {
                VStack(spacing: 16) {
                    Text("Pick a category")
                        .font(.system(size: 72, weight: .heavy, design: .rounded))
                    Text(players.map { "\($0.avatar.emoji) \($0.name)" }.joined(separator: "   "))
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }

                HStack(spacing: 50) {
                    ForEach(QuizCategory.allCases) { category in
                        Button { onPick(category) } label: {
                            CategoryTile(category: category)
                        }
                        // .card gives the native tvOS lift + parallax on focus.
                        .buttonStyle(.card)
                        .accessibilityIdentifier("category-\(category.rawValue)")
                    }
                }
            }
            .padding(60)
        }
    }
}

struct CategoryTile: View {
    let category: QuizCategory

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: category.symbol)
                .font(.system(size: 90, weight: .bold))
            Text(category.title)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
        }
        .foregroundStyle(.white)
        .frame(width: 340, height: 340)
        .background(LinearGradient(colors: category.gradient, startPoint: .topLeading, endPoint: .bottomTrailing))
    }
}

#Preview {
    CategoryPickerView(players: [Player(name: "Asan", avatar: .fox), Player(name: "Nimal", avatar: .owl)]) { _ in }
}
