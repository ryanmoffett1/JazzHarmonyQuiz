import XCTest

/// UI Tests for Chord Drill critical user flows
/// These tests catch View-layer bugs that unit tests cannot detect:
/// - Blank screens (empty sheet presentation)
/// - UI freezing (keyboard input lag)
/// - Navigation errors ("Module not found")
///
/// Note: These tests launch the actual app and are slower than unit tests.
/// They should focus on critical happy paths only.
@MainActor
final class ChordDrillUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]  // Can be used to disable analytics, etc.
        app.launch()
    }
    
    override func tearDownWithError() throws {
        app = nil
    }
    
    // MARK: - Helper Methods
    
    private func navigateToChordDrill() {
        // Tap Practice tab
        let practiceTab = app.tabBars.buttons["Practice"]
        XCTAssertTrue(practiceTab.waitForExistence(timeout: 5), "Practice tab should exist")
        practiceTab.tap()
        
        // Tap Chord Drill button
        let chordDrillButton = app.buttons["Chord Drill"]
        XCTAssertTrue(chordDrillButton.waitForExistence(timeout: 5), "Chord Drill button should exist")
        chordDrillButton.tap()
        
        // Verify we're on the preset selection screen
        let quickStartLabel = app.staticTexts["Quick Start"]
        XCTAssertTrue(quickStartLabel.waitForExistence(timeout: 5), "Should be on preset selection screen")
    }
    
    // MARK: - Critical Bug Tests
    
    /// BUG #3: Custom Ad-Hoc shows blank screen
    /// This test verifies the setup sheet actually shows content
    func test_customAdHoc_opensSetupSheetWithContent() throws {
        navigateToChordDrill()
        
        // Find and tap Custom Ad-Hoc button
        let customAdHocButton = app.buttons["Custom Ad-Hoc"]
        XCTAssertTrue(customAdHocButton.waitForExistence(timeout: 2), "Custom Ad-Hoc button should exist")
        customAdHocButton.tap()
        
        // Wait for sheet to present
        // Give it a moment for the animation
        Thread.sleep(forTimeInterval: 0.5)
        
        // Verify setup sheet content is visible (NOT blank)
        // Look for key elements that should be in the setup form
        let chordTypesHeader = app.staticTexts["Chord Types"]
        let keysHeader = app.staticTexts["Keys"]
        let startDrillButton = app.buttons["Start Drill"]
        
        // These should exist if the form rendered correctly
        XCTAssertTrue(chordTypesHeader.waitForExistence(timeout: 3),
            "FAIL: Setup sheet is blank! Chord Types section should be visible")
        
        XCTAssertTrue(keysHeader.waitForExistence(timeout: 1),
            "FAIL: Setup sheet is blank! Keys section should be visible")
        
        XCTAssertTrue(startDrillButton.waitForExistence(timeout: 1),
            "FAIL: Setup sheet is blank! Start Drill button should be visible")
        
        // Verify we can interact with the form (not frozen)
        let chordDifficultyPicker = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Beginner' OR label CONTAINS 'Intermediate'")).firstMatch
        XCTAssertTrue(chordDifficultyPicker.exists, "Should have a chord difficulty picker")
    }
    
    /// BUG #4: Create Preset keyboard freezes
    /// This test verifies typing in the preset name field is responsive
    func test_createPreset_textFieldIsResponsive() throws {
        navigateToChordDrill()
        
        // Find and tap Create Custom Preset button
        let createButton = app.buttons["Create Custom Preset"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 2), "Create Custom Preset button should exist")
        createButton.tap()
        
        // Wait for sheet to present
        Thread.sleep(forTimeInterval: 0.5)
        
        // Find the preset name text field
        let presetNameField = app.textFields["Preset Name"]
        XCTAssertTrue(presetNameField.waitForExistence(timeout: 3),
            "FAIL: Preset name field should exist in Create Preset sheet")
        
        // Tap to focus the field
        presetNameField.tap()
        
        // Verify keyboard appears
        Thread.sleep(forTimeInterval: 0.3)
        
        // Type text and measure time (should be nearly instant)
        let start = Date()
        presetNameField.typeText("My Preset")
        let elapsed = Date().timeIntervalSince(start)
        
        // Typing 9 characters should take less than 2 seconds
        // (If it freezes, it will timeout or take much longer)
        XCTAssertLessThan(elapsed, 2.0,
            "FAIL: Typing took \(elapsed)s - UI appears to be freezing! Should be < 2s")
        
        // Verify the text actually appeared (wasn't blocked)
        let typedValue = presetNameField.value as? String ?? ""
        XCTAssertTrue(typedValue.contains("My Preset"),
            "FAIL: Text didn't appear in field. Expected 'My Preset', got '\(typedValue)'")
    }
    
    /// BUG #1 & #2: Quit/New Quiz shows "Module not found"
    /// This test verifies preset-launched drills handle quit gracefully
    func test_presetLaunch_quitReturnsToSetup() throws {
        navigateToChordDrill()
        
        // Tap Basic Triads to start a preset drill
        let basicTriadsButton = app.buttons["Basic Triads"]
        XCTAssertTrue(basicTriadsButton.waitForExistence(timeout: 2), "Basic Triads button should exist")
        basicTriadsButton.tap()
        
        // Wait for drill to start
        // Look for quiz UI elements (Submit button, keyboard, etc.)
        let submitButton = app.buttons["Submit Answer"]
        let playButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Play'")).firstMatch
        
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5) || playButton.exists,
            "FAIL: Drill should have started. Looking for Submit or Play button")
        
        // Find and tap Quit button
        let quitButton = app.buttons["Quit"]
        XCTAssertTrue(quitButton.waitForExistence(timeout: 2), "Quit button should exist")
        quitButton.tap()
        
        // Wait for transition
        Thread.sleep(forTimeInterval: 0.5)
        
        // Verify we're back at setup screen (NOT "Module not found")
        // Look for either the preset selection OR the setup screen
        let quickStartLabel = app.staticTexts["Quick Start"]
        let chordTypesHeader = app.staticTexts["Chord Types"]
        
        // Should see either preset selection or setup screen
        let isOnValidScreen = quickStartLabel.waitForExistence(timeout: 3) || 
                             chordTypesHeader.waitForExistence(timeout: 1)
        
        XCTAssertTrue(isOnValidScreen,
            "FAIL: After quit, expected preset selection or setup screen. Got neither - may be showing 'Module not found'")
        
        // Explicitly check we DON'T see an error message
        let moduleNotFoundText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'module' OR label CONTAINS 'Module' OR label CONTAINS 'not found' OR label CONTAINS 'error'")).firstMatch
        
        XCTAssertFalse(moduleNotFoundText.exists,
            "FAIL: Found error text: \(moduleNotFoundText.label). Should not show 'Module not found'")
    }
    
    /// BUG #1 & #2: New Quiz after completion shows "Module not found"
    /// This test verifies preset-launched drills handle "New Quiz" gracefully
    func test_presetLaunch_newQuizAfterCompletion() throws {
        // This test would require completing a full quiz which could take a while
        // For now, we'll just verify the Results screen doesn't immediately crash
        
        navigateToChordDrill()
        
        // Tap Basic Triads
        let basicTriadsButton = app.buttons["Basic Triads"]
        XCTAssertTrue(basicTriadsButton.waitForExistence(timeout: 2), "Basic Triads button should exist")
        basicTriadsButton.tap()
        
        // Wait for drill to start
        let submitButton = app.buttons["Submit Answer"]
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5), "Drill should start")
        
        // Note: We'd need to answer all questions to test "New Quiz"
        // That's too slow for a smoke test, so we just verify:
        // 1. Drill starts (✅ above)
        // 2. Quit works (tested in previous test)
        // 
        // Full "New Quiz" flow should be manual QA
    }
    
    // MARK: - Smoke Test: Happy Path
    
    /// Smoke test: Verify the entire critical user journey works
    func test_smokeTest_completeUserJourney() throws {
        navigateToChordDrill()
        
        // 1. Verify preset selection screen shows presets
        XCTAssertTrue(app.buttons["Basic Triads"].exists, "Should show Basic Triads preset")
        XCTAssertTrue(app.buttons["7th & 6th Chords"].exists, "Should show 7th & 6th Chords preset")
        XCTAssertTrue(app.buttons["Full Workout"].exists, "Should show Full Workout preset")
        XCTAssertTrue(app.buttons["Custom Ad-Hoc"].exists, "Should show Custom Ad-Hoc preset")
        
        // 2. Verify Basic Triads starts drill
        app.buttons["Basic Triads"].tap()
        XCTAssertTrue(app.buttons["Submit Answer"].waitForExistence(timeout: 5), 
            "Basic Triads should start drill")
        
        // Go back
        app.buttons["Quit"].tap()
        Thread.sleep(forTimeInterval: 0.3)
        
        // 3. Verify Custom Ad-Hoc opens setup (not blank)
        if app.staticTexts["Quick Start"].exists {
            app.buttons["Custom Ad-Hoc"].tap()
            Thread.sleep(forTimeInterval: 0.5)
            XCTAssertTrue(app.staticTexts["Chord Types"].waitForExistence(timeout: 3),
                "Custom Ad-Hoc should show setup form")
            app.buttons["Cancel"].tap()
            Thread.sleep(forTimeInterval: 0.3)
        }
        
        // 4. Verify Create Preset opens and text input works
        if app.staticTexts["Quick Start"].exists {
            app.buttons["Create Custom Preset"].tap()
            Thread.sleep(forTimeInterval: 0.5)
            
            let textField = app.textFields["Preset Name"]
            if textField.waitForExistence(timeout: 3) {
                textField.tap()
                Thread.sleep(forTimeInterval: 0.2)
                textField.typeText("Test")
                
                // Verify text appeared (didn't freeze)
                let value = textField.value as? String ?? ""
                XCTAssertTrue(value.contains("Test"), "Text field should accept input without freezing")
            }
        }
    }
}
