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
        
        let app = XCUIApplication()
        app.launchArguments = ["--testMode"]
        app.launch()
    }
    
    
    func testChat() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.staticTexts["SpeziChat"].waitForExistence(timeout: 1))
        XCTAssert(app.staticTexts["Assistant Message!"].waitForExistence(timeout: 1))
        
        try app.textViews["Message Input Textfield"].enter(value: "User Message!", dismissKeyboard: false)
        XCTAssert(app.buttons["Send Message"].waitForExistence(timeout: 5))
        app.buttons["Send Message"].tap()
        
        XCTAssert(app.staticTexts["User Message!"].waitForExistence(timeout: 5))
        
        sleep(1)
        
        XCTAssert(app.otherElements["Typing Indicator"].waitForExistence(timeout: 2))
        
        sleep(4)
        
        XCTAssert(app.staticTexts["Assistant Message Response!"].waitForExistence(timeout: 5))
    }
    
    func testChatExport() throws {  // swiftlint:disable:this function_body_length
        let app = XCUIApplication()
        let filesApp = XCUIApplication(bundleIdentifier: "com.apple.DocumentsApp")
        let maxRetries = 10
        
        for _ in 0...maxRetries {
            app.launchArguments = ["--testMode"]
            app.launch()

            XCTAssert(app.staticTexts["SpeziChat"].waitForExistence(timeout: 1))
            
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
            #if os(visionOS)
            // On visionOS the "Save to files" button has no label
            XCTAssert(app.cells["XCElementSnapshotPrivilegedValuePlaceholder"].waitForExistence(timeout: 10))
            app.cells["XCElementSnapshotPrivilegedValuePlaceholder"].tap()
            #else
            XCTAssert(app.staticTexts["Save to Files"].waitForExistence(timeout: 10))
            app.staticTexts["Save to Files"].tap()
            #endif

            sleep(3)
            XCTAssert(app.buttons["Save"].waitForExistence(timeout: 2))
            app.buttons["Save"].tap()
            sleep(10)    // Wait until file is saved
            
            if app.staticTexts["Replace Existing Items?"].waitForExistence(timeout: 5) {
                #if os(visionOS)
                XCTFail("""
                On VisionOS, replacing files is very buggy, often leading to a complete freeze of the 'Save to Files' window.
                Please ensure that all already existing chat export files are deleted when executing the UI test.
                """)
                #endif
                XCTAssert(app.buttons["Replace"].waitForExistence(timeout: 2))
                app.buttons["Replace"].tap()
                sleep(3)    // Wait until file is saved
            }
            
            // Wait until share sheet closed and back on the chat screen
            XCTAssert(app.staticTexts["SpeziChat"].waitForExistence(timeout: 10))
            
            // Launch the Files app
            filesApp.launch()
            
            // Handle already open files
            if filesApp.buttons["Done"].waitForExistence(timeout: 2) {
                filesApp.buttons["Done"].tap()
            }
            
            // Check if file exists - If not, try the export procedure again
            // Saving to files is very flakey on the runners, needs multiple attempts to succeed
            if filesApp.staticTexts["Exported Chat"].waitForExistence(timeout: 2) {
                break
            }
        }
        
        // Open File
        XCTAssert(filesApp.staticTexts["Exported Chat"].waitForExistence(timeout: 2))
        XCTAssert(filesApp.collectionViews["File View"].cells["Exported Chat, pdf"].waitForExistence(timeout: 2))
        
        XCTAssert(filesApp.collectionViews["File View"].cells["Exported Chat, pdf"].images.firstMatch.waitForExistence(timeout: 2))
        filesApp.collectionViews["File View"].cells["Exported Chat, pdf"].images.firstMatch.tap()
        
        sleep(3)    // Wait until file is opened
        
        #if os(visionOS)
        let fileView = XCUIApplication(bundleIdentifier: "com.apple.MRQuickLook")
        #else
        let fileView = filesApp
        #endif
        
        // Check if PDF contains certain chat message
        let predicate = NSPredicate(format: "label CONTAINS[c] %@", "User Message!")
        XCTAssert(fileView.otherElements.containing(predicate).firstMatch.waitForExistence(timeout: 2))
        
        #if os(iOS)
        // Close File
        XCTAssert(fileView.buttons["Done"].waitForExistence(timeout: 2))
        fileView.buttons["Done"].tap()
        #endif
    }
    
    func testChatSpeechOutput() throws {
        let app = XCUIApplication()
        
        XCTAssert(app.staticTexts["SpeziChat"].waitForExistence(timeout: 1))
        XCTAssert(app.buttons["Speaker strikethrough"].waitForExistence(timeout: 2))
        XCTAssert(!app.buttons["Speaker"].waitForExistence(timeout: 2))
        
        app.buttons["Speaker strikethrough"].tap()
        
        XCTAssert(!app.buttons["Speaker strikethrough"].waitForExistence(timeout: 2))
        XCTAssert(app.buttons["Speaker"].waitForExistence(timeout: 2))
    }
}
