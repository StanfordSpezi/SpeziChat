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
    
    
    func testChat() throws {
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
    
    func testChatExport() throws {
        let app = XCUIApplication()
        app.launch()
        
        // Entering dummy chat value
        XCTAssert(app.staticTexts["SpeziChat"].waitForExistence(timeout: 1))
        try app.textViews["Message Input Textfield"].enter(value: "User Message!", dismissKeyboard: false)
        XCTAssert(app.buttons["Send Message"].waitForExistence(timeout: 5))
        app.buttons["Send Message"].tap()
        
        sleep(1)
        XCTAssert(app.staticTexts["Assistant Message Response!"].waitForExistence(timeout: 5))
        
        // Export chat via share sheet button
        XCTAssert(app.buttons["Export the Chat"].waitForExistence(timeout: 2))
        app.buttons["Export the Chat"].tap()

        // Store exported chat in Files
        XCTAssert(app.staticTexts["Save to Files"].waitForExistence(timeout: 10))
        app.staticTexts["Save to Files"].tap()
        sleep(3)
        XCTAssert(app.buttons["Save"].waitForExistence(timeout: 2))
        app.buttons["Save"].tap()
        sleep(10)    // Wait until file is saved
        
        if app.staticTexts["Replace Existing Items?"].waitForExistence(timeout: 5) {
            XCTAssert(app.buttons["Replace"].waitForExistence(timeout: 2))
            app.buttons["Replace"].tap()
            sleep(3)    // Wait until file is saved
        }
        
        // Wait until share sheet closed and back on the chat screen
        XCTAssert(app.staticTexts["SpeziChat"].waitForExistence(timeout: 10))
        
        XCUIDevice.shared.press(.home)
        
        // Launch the Files app
        let filesApp = XCUIApplication(bundleIdentifier: "com.apple.DocumentsApp")
        filesApp.launch()
        
        // Handle already open files
        if filesApp.buttons["Done"].waitForExistence(timeout: 2) {
            filesApp.buttons["Done"].tap()
        }
        
        // Open File
        XCTAssert(filesApp.staticTexts["Exported Chat"].waitForExistence(timeout: 2))
        XCTAssert(filesApp.collectionViews["File View"].cells["Exported Chat, pdf"].waitForExistence(timeout: 2))
        
        XCTAssert(filesApp.collectionViews["File View"].cells["Exported Chat, pdf"].images.firstMatch.waitForExistence(timeout: 2))
        filesApp.collectionViews["File View"].cells["Exported Chat, pdf"].images.firstMatch.tap()
        
        sleep(3)    // Wait until file is opened
        
        // Check if PDF contains certain chat message
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", "User Message!")
        XCTAssert(filesApp.otherElements.containing(predicate).firstMatch.waitForExistence(timeout: 2))
        
        // Close File
        XCTAssert(filesApp.buttons["Done"].waitForExistence(timeout: 2))
        filesApp.buttons["Done"].tap()
    }
}
