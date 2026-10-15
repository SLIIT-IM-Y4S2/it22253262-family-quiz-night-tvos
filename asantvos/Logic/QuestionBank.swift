//
//  QuestionBank.swift
//  Family Quiz Night (tvOS)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import Foundation

enum QuestionBank {
    /// Random questions for a category; "Mixed" draws from all of them.
    /// Answer order is shuffled too, so replays feel fresh.
    static func questions<G: RandomNumberGenerator>(for category: QuizCategory, count: Int,
                                                     using generator: inout G) -> [Question] {
        let pool = category == .mixed ? all : all.filter { $0.category == category }
        return pool.shuffled(using: &generator).prefix(count).map { shuffledOptions($0, using: &generator) }
    }

    static func questions(for category: QuizCategory, count: Int) -> [Question] {
        var generator = SystemRandomNumberGenerator()
        return questions(for: category, count: count, using: &generator)
    }

    private static func shuffledOptions<G: RandomNumberGenerator>(_ q: Question, using generator: inout G) -> Question {
        let order = q.options.indices.shuffled(using: &generator)
        return Question(id: q.id, category: q.category, text: q.text,
                        options: order.map { q.options[$0] },
                        correctIndex: order.firstIndex(of: q.correctIndex)!)
    }

    // Correct answer is always listed first here; it gets shuffled at runtime.
    private static let raw: [(QuizCategory, String, [String])] = [
        // General knowledge
        (.general, "How many days are in a leap year?", ["366", "365", "364", "360"]),
        (.general, "Which planet is known as the Red Planet?", ["Mars", "Venus", "Jupiter", "Saturn"]),
        (.general, "How many continents are there?", ["7", "5", "6", "8"]),
        (.general, "What is the largest ocean on Earth?", ["Pacific", "Atlantic", "Indian", "Arctic"]),
        (.general, "Which shape has three sides?", ["Triangle", "Square", "Pentagon", "Circle"]),
        (.general, "What colour do you get by mixing blue and yellow?", ["Green", "Purple", "Orange", "Brown"]),
        (.general, "How many players are in a cricket team on the field?", ["11", "9", "10", "12"]),
        (.general, "Which is the fastest land animal?", ["Cheetah", "Lion", "Horse", "Leopard"]),
        (.general, "What is the capital of Japan?", ["Tokyo", "Kyoto", "Osaka", "Seoul"]),
        (.general, "How many minutes are in two hours?", ["120", "100", "140", "90"]),
        (.general, "Which instrument has 88 keys?", ["Piano", "Guitar", "Violin", "Flute"]),
        (.general, "Who painted the Mona Lisa?", ["Leonardo da Vinci", "Picasso", "Van Gogh", "Michelangelo"]),
        // Science & nature
        (.science, "What gas do plants absorb from the air?", ["Carbon dioxide", "Oxygen", "Nitrogen", "Helium"]),
        (.science, "What is H₂O better known as?", ["Water", "Salt", "Hydrogen", "Air"]),
        (.science, "How many legs does a spider have?", ["8", "6", "10", "4"]),
        (.science, "What is the closest star to Earth?", ["The Sun", "Sirius", "Polaris", "Alpha Centauri"]),
        (.science, "Which organ pumps blood around the body?", ["Heart", "Lungs", "Liver", "Brain"]),
        (.science, "What is the hardest natural substance?", ["Diamond", "Gold", "Iron", "Quartz"]),
        (.science, "At what temperature does water boil at sea level?", ["100 °C", "90 °C", "50 °C", "120 °C"]),
        (.science, "Which animal is a mammal?", ["Whale", "Shark", "Penguin", "Crocodile"]),
        (.science, "What force keeps us on the ground?", ["Gravity", "Magnetism", "Friction", "Wind"]),
        (.science, "How many bones are in the adult human body?", ["206", "106", "306", "186"]),
        (.science, "Which planet has the most visible rings?", ["Saturn", "Mars", "Earth", "Mercury"]),
        (.science, "What do bees make?", ["Honey", "Milk", "Silk", "Wax paper"]),
        // Sri Lanka
        (.sriLanka, "What is the commercial capital of Sri Lanka?", ["Colombo", "Kandy", "Galle", "Jaffna"]),
        (.sriLanka, "Which ancient rock fortress is a UNESCO site?", ["Sigiriya", "Adam's Peak", "Ella Rock", "Pidurangala"]),
        (.sriLanka, "What is Sri Lanka's national flower?", ["Blue water lily", "Lotus", "Rose", "Orchid"]),
        (.sriLanka, "Sri Lanka is famous worldwide for exporting which drink?", ["Tea", "Coffee", "Cocoa", "Coconut water"]),
        (.sriLanka, "In which year did Sri Lanka win the Cricket World Cup?", ["1996", "2007", "1992", "2011"]),
        (.sriLanka, "Which city hosts the Temple of the Tooth?", ["Kandy", "Anuradhapura", "Matara", "Negombo"]),
        (.sriLanka, "What is the currency of Sri Lanka?", ["Rupee", "Taka", "Ringgit", "Baht"]),
        (.sriLanka, "Which is the longest river in Sri Lanka?", ["Mahaweli", "Kelani", "Kalu", "Walawe"]),
        (.sriLanka, "Which fort city is on the southern coast?", ["Galle", "Trincomalee", "Kurunegala", "Badulla"]),
        (.sriLanka, "What is Sri Lanka's national bird?", ["Sri Lanka junglefowl", "Peacock", "Parrot", "Eagle"]),
        (.sriLanka, "Which famous procession is held in Kandy?", ["Esala Perahera", "Poson Poya", "Sinhala New Year", "Deepavali"]),
        (.sriLanka, "Which hill country town is called 'Little England'?", ["Nuwara Eliya", "Ella", "Haputale", "Bandarawela"]),
    ]

    static let all: [Question] = raw.enumerated().map { index, item in
        Question(id: index, category: item.0, text: item.1, options: item.2, correctIndex: 0)
    }
}
