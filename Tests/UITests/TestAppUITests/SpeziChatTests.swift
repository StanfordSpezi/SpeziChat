//
// This source file is part of the Stanford Spezi open-source project
//
// SPDX-FileCopyrightText: 2023 Stanford University and the project authors (see CONTRIBUTORS.md)
//
// SPDX-License-Identifier: MIT
//

import XCTest
import XCTestExtensions


final class SpeziChatTests: XCTestCase {
    func testSpeziChat() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssert(app.staticTexts["Spezi Chat"].waitForExistence(timeout: 2))
    }
}
