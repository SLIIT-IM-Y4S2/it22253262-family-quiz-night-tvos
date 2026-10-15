//
//  asantvosUITests.swift
//  Family Quiz Night – UI tests (driven with the Siri Remote)
//
//  Created by Asan M A M (IT22253262) on 2026-10-15.
//

import XCTest

final class asantvosUITests: XCTestCase {
    private var app: XCUIApplication!
    private let remote = XCUIRemote.shared

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    @MainActor
    func testPlayOpensPlayerSetup() throws {
        XCTAssertTrue(app.buttons["playButton"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["playButton"].hasFocus, "Play should be focused first")
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["Who's playing?"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testReachCategoryScreen() throws {
        remote.press(.select)                                  // Play
        XCTAssertTrue(app.buttons["continueButton"].waitForExistence(timeout: 3))
        // Move focus down to the Continue button and press it.
        for _ in 0..<4 where !app.buttons["continueButton"].hasFocus {
            remote.press(.down)
            if !app.buttons["continueButton"].hasFocus { remote.press(.right) }
        }
        remote.press(.select)
        XCTAssertTrue(app.staticTexts["Pick a category"].waitForExistence(timeout: 3))
    }

    @MainActor
    func testLaunchPerformance() throws {
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
