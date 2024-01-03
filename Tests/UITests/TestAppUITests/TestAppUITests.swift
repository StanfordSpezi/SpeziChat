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
        
        XCTAssert(app.staticTexts["SpeziChat"].waitForExistence(timeout: 1))
        try app.textViews["Message Input Textfield"].enter(value: "User Message!", dismissKeyboard: false)
        XCTAssert(app.buttons["Send Message"].waitForExistence(timeout: 5))
        app.buttons["Send Message"].tap()
        
        sleep(1)
        XCTAssert(app.staticTexts["Assistant Message Response!"].waitForExistence(timeout: 5))
        
        XCTAssert(app.buttons["Export the Chat"].waitForExistence(timeout: 2))
        app.buttons["Export the Chat"].tap()
        
        // Share Sheet needs a bit to pop up
        sleep(2)
        
        print(app.staticTexts.debugDescription)
        
        XCTAssert(app.staticTexts["Save to Files"].waitForExistence(timeout: 2))
        app.staticTexts["Save to Files"].tap()
        
        XCTAssert(app.buttons["Save"].waitForExistence(timeout: 2))
        app.buttons["Save"].tap()
        
        sleep(1)
        
        if app.staticTexts["Replace Existing Items?"].waitForExistence(timeout: 2) {
            XCTAssert(app.buttons["Replace"].waitForExistence(timeout: 2))
            app.buttons["Replace"].tap()
        }
        
        // Saving takes unreasonable long sometimes
        sleep(5)
        
        // Go to home screen
        XCUIDevice.shared.press(.home)
        
        // Launch the Files app
        let filesApp = XCUIApplication(bundleIdentifier: "com.apple.DocumentsApp")
        filesApp.launch()
        
        // Handle already open PDF
        if filesApp.buttons["Done"].waitForExistence(timeout: 2) {
            filesApp.buttons["Done"].tap()
        }
        
        // Open File
        XCTAssert(filesApp.staticTexts["Exported Chat"].waitForExistence(timeout: 2))
        XCTAssert(filesApp.collectionViews["File View"].waitForExistence(timeout: 2))
        let files = filesApp.collectionViews["File View"]
        
        XCTAssert(files.cells["Exported Chat, pdf"].waitForExistence(timeout: 2))
        files.cells["Exported Chat, pdf"].images.firstMatch.tap()
        
        sleep(3)
        
        // Check if PDF contains certain user message
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", "User Message!")
        let chatEntry = filesApp.otherElements.containing(predicate).firstMatch
        XCTAssert(chatEntry.waitForExistence(timeout: 2))
        
        // Close File
        XCTAssert(filesApp.buttons["Done"].waitForExistence(timeout: 2))
        filesApp.buttons["Done"].tap()
    }
}
