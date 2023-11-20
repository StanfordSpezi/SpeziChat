//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


class TestAppUITests: XCTestCase {
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        continueAfterFailure = false
    }
    
    
    func testSpeziChat() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.staticTexts["SpeziChat"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["Assistant Message!"].waitForExistence(timeout: 1))
        
        try app.textViews["Message Input Textfield"].enter(value: "User Message!", dismissKeyboard: false)
        XCTAssert(app.buttons["Send Message"].waitForExistence(timeout: 5))
        app.buttons["Send Message"].tap()
        
        XCTAssert(app.staticTexts["User Message!"].waitForExistence(timeout: 5))
        
        sleep(1)
        
        XCTAssert(app.staticTexts["Assistant Message Response!"].waitForExistence(timeout: 5))
    }
}
