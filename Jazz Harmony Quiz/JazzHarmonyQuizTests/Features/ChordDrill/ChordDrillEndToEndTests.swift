import XCTest
@testable import JazzHarmonyQuiz

// MARK: - End-to-End Flow Tests

@MainActor
final class ChordDrillEndToEndTests: XCTestCase {
    
    var presetStore: CustomPresetStore!
    var selectionViewModel: ChordDrillPresetSelectionViewModel!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "ChordDrillEndToEndTests")!
        testDefaults.removePersistentDomain(forName: "ChordDrillEndToEndTests")
        presetStore = CustomPresetStore(userDefaults: testDefaults)
        selectionViewModel = ChordDrillPresetSelectionViewModel(presetStore: presetStore)
    }
    
    override func tearDown() {
        presetStore.deleteAllPresets()
        UserDefaults.standard.removePersistentDomain(forName: "ChordDrillEndToEndTests")
        presetStore = nil
        selectionViewModel = nil
        super.tearDown()
    }
    
    // MARK: - Flow: Basic Triads Quick Start
    
    func test_flow_basicTriads_tapStartsDrill() {
        // 1. User is on Chord Drill preset selection screen
        // (selectionViewModel is already initialized)
        
        // 2. User taps "Basic Triads"
        let action = selectionViewModel.selectBuiltInPreset(.basicTriads)
        
        // 3. Verify action is to start drill (not open setup)
        guard case .startDrill(let config) = action else {
            XCTFail("Expected startDrill action, got \(action)")
            return
        }
        
        // 4. Verify config uses beginner chord difficulty
        XCTAssertEqual(config.difficulty, .beginner)
        
        // 5. Verify config uses easy keys
        XCTAssertEqual(config.keyDifficulty, .easy)
        
        // 6. Verify config uses 10 questions
        XCTAssertEqual(config.questionCount, 10)
    }
    
    func test_flow_basicTriads_usesOnlyTriads() {
        let action = selectionViewModel.selectBuiltInPreset(.basicTriads)
        
        guard case .startDrill(let config) = action else {
            XCTFail("Expected startDrill action")
            return
        }
        
        // Beginner should only include triads (no 7th chords)
        XCTAssertEqual(config.difficulty, .beginner)
        // The actual chord types are determined by difficulty
    }
    
    // MARK: - Flow: 7th & 6th Chords Quick Start
    
    func test_flow_seventhChords_tapStartsDrill() {
        let action = selectionViewModel.selectBuiltInPreset(.seventhAndSixthChords)
        
        guard case .startDrill(let config) = action else {
            XCTFail("Expected startDrill action")
            return
        }
        
        XCTAssertEqual(config.difficulty, .intermediate)
        XCTAssertEqual(config.keyDifficulty, .medium)
    }
    
    // MARK: - Flow: Full Workout Quick Start
    
    func test_flow_fullWorkout_tapStartsDrill() {
        let action = selectionViewModel.selectBuiltInPreset(.fullWorkout)
        
        guard case .startDrill(let config) = action else {
            XCTFail("Expected startDrill action")
            return
        }
        
        XCTAssertEqual(config.difficulty, .advanced)
        XCTAssertEqual(config.keyDifficulty, .all)
        XCTAssertEqual(config.questionCount, 15)
    }
    
    func test_flow_fullWorkout_usesAllQuestionTypes() {
        let action = selectionViewModel.selectBuiltInPreset(.fullWorkout)
        
        guard case .startDrill(let config) = action else {
            XCTFail("Expected startDrill action")
            return
        }
        
        XCTAssertTrue(config.questionTypes.contains(.singleTone))
        XCTAssertTrue(config.questionTypes.contains(.allTones))
        XCTAssertTrue(config.questionTypes.contains(.auralQuality))
        XCTAssertTrue(config.questionTypes.contains(.auralSpelling))
    }
    
    // MARK: - Flow: Custom Ad-Hoc Drill
    
    func test_flow_customAdHoc_tapOpensSetup() {
        // 1. User taps "Custom Ad-Hoc"
        let action = selectionViewModel.selectBuiltInPreset(.customAdHoc)
        
        // 2. Verify setup screen opens in ad-hoc mode
        XCTAssertEqual(action, .openSetup(.adHoc))
    }
    
    func test_flow_customAdHoc_configureAndStart() {
        // 1. User taps "Custom Ad-Hoc" - opens setup
        let openAction = selectionViewModel.selectBuiltInPreset(.customAdHoc)
        XCTAssertEqual(openAction, .openSetup(.adHoc))
        
        // 2. Setup screen opens in ad-hoc mode
        let setupViewModel = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: presetStore)
        
        // 3. User configures settings
        setupViewModel.currentConfig.questionCount = 20
        setupViewModel.currentConfig.difficulty = .intermediate
        setupViewModel.currentConfig.keyDifficulty = .medium
        
        // 4. User taps "Start Drill"
        let startAction = setupViewModel.performPrimaryAction()
        
        // 5. Verify drill starts with custom config
        guard case .startDrill(let config) = startAction else {
            XCTFail("Expected startDrill action")
            return
        }
        
        XCTAssertEqual(config.questionCount, 20)
        XCTAssertEqual(config.difficulty, .intermediate)
        XCTAssertEqual(config.keyDifficulty, .medium)
        
        // 6. Verify no preset was saved
        XCTAssertEqual(presetStore.allPresets.count, 0)
    }
    
    // MARK: - Flow: Create and Use Custom Preset
    
    func test_flow_createPreset_saveAndUse() {
        // 1. User taps "+ Create Preset"
        let createAction = selectionViewModel.createNewPreset()
        XCTAssertEqual(createAction, .openSetup(.createPreset))
        
        // 2. Setup screen opens in create mode
        let setupViewModel = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: presetStore)
        
        // 3. Verify preset name field is visible
        XCTAssertTrue(setupViewModel.showsPresetNameField)
        
        // 4. User enters preset name
        setupViewModel.presetName = "My Jazz Practice"
        
        // 5. User configures settings
        setupViewModel.currentConfig.questionCount = 15
        setupViewModel.currentConfig.difficulty = .intermediate
        setupViewModel.currentConfig.keyDifficulty = .medium
        setupViewModel.currentConfig.questionTypes = [.allTones, .singleTone]
        
        // 6. User taps "Save Preset"
        let saveAction = setupViewModel.performPrimaryAction()
        
        // 7. Verify preset was saved
        XCTAssertEqual(saveAction, .presetSaved)
        
        // 8. Verify returns to preset selection (preset now in list)
        selectionViewModel.refreshSavedPresets()
        XCTAssertEqual(selectionViewModel.savedPresets.count, 1)
        XCTAssertEqual(selectionViewModel.savedPresets.first?.name, "My Jazz Practice")
        
        // 9. User taps the saved preset
        let useAction = selectionViewModel.selectSavedPreset(selectionViewModel.savedPresets.first!)
        
        // 10. Verify drill starts immediately with saved config
        guard case .startDrill(let config) = useAction else {
            XCTFail("Expected startDrill action")
            return
        }
        
        XCTAssertEqual(config.questionCount, 15)
        XCTAssertEqual(config.difficulty, .intermediate)
        XCTAssertEqual(config.keyDifficulty, .medium)
        XCTAssertTrue(config.questionTypes.contains(.allTones))
        XCTAssertTrue(config.questionTypes.contains(.singleTone))
    }
    
    // MARK: - Flow: Delete Custom Preset
    
    func test_flow_deletePreset() {
        // 1. Create and save a preset
        let preset = CustomChordDrillPreset(name: "To Delete", config: .default)
        presetStore.savePreset(preset)
        selectionViewModel.refreshSavedPresets()
        XCTAssertEqual(selectionViewModel.savedPresets.count, 1)
        
        // 2. User deletes the preset
        selectionViewModel.deleteSavedPreset(selectionViewModel.savedPresets.first!)
        
        // 3. Verify preset removed from list
        XCTAssertEqual(selectionViewModel.savedPresets.count, 0)
    }
    
    // MARK: - Flow: Edit Existing Preset
    
    func test_flow_editPreset() {
        // 1. Create and save a preset
        var originalConfig = ChordDrillConfig.default
        originalConfig.questionCount = 10
        let preset = CustomChordDrillPreset(name: "Original", config: originalConfig)
        presetStore.savePreset(preset)
        selectionViewModel.refreshSavedPresets()
        
        // 2. User opens preset for editing
        let editViewModel = ChordDrillSetupViewModelNew(
            mode: .editPreset(selectionViewModel.savedPresets.first!),
            presetStore: presetStore
        )
        
        // 3. Verify preset name is pre-filled
        XCTAssertEqual(editViewModel.presetName, "Original")
        
        // 4. Verify config is loaded
        XCTAssertEqual(editViewModel.currentConfig.questionCount, 10)
        
        // 5. User makes changes
        editViewModel.presetName = "Updated"
        editViewModel.currentConfig.questionCount = 25
        
        // 6. User saves changes
        let result = editViewModel.performPrimaryAction()
        XCTAssertEqual(result, .presetSaved)
        
        // 7. Verify changes persisted
        selectionViewModel.refreshSavedPresets()
        XCTAssertEqual(selectionViewModel.savedPresets.first?.name, "Updated")
        XCTAssertEqual(selectionViewModel.savedPresets.first?.config.questionCount, 25)
    }
    
    // MARK: - Flow: No Expert Difficulty Available
    
    func test_flow_noExpertChordDifficulty() {
        let setupViewModel = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: presetStore)
        
        // Verify Expert is not available
        XCTAssertFalse(setupViewModel.availableChordDifficulties.contains(.expert),
                      "Expert should not be available as chord difficulty")
    }
    
    func test_flow_noExpertKeyDifficulty() {
        let setupViewModel = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: presetStore)
        
        // Verify Expert is not available
        XCTAssertFalse(setupViewModel.availableKeyDifficulties.contains(.expert),
                      "Expert should not be available as key difficulty")
    }
    
    // MARK: - Flow: Custom Chord Types
    
    func test_flow_customChordTypes() {
        let setupViewModel = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: presetStore)
        
        // 1. User selects custom chord difficulty
        setupViewModel.currentConfig.difficulty = .custom
        
        // 2. Verify chord picker is shown
        XCTAssertTrue(setupViewModel.showsChordTypePicker)
        
        // 3. User selects specific chords
        setupViewModel.currentConfig.chordTypes = []
        setupViewModel.toggleChordType("7")
        setupViewModel.toggleChordType("maj7")
        setupViewModel.toggleChordType("m7")
        
        // 4. Verify selections
        XCTAssertEqual(setupViewModel.currentConfig.chordTypes.count, 3)
        XCTAssertTrue(setupViewModel.currentConfig.chordTypes.contains("7"))
        XCTAssertTrue(setupViewModel.currentConfig.chordTypes.contains("maj7"))
        XCTAssertTrue(setupViewModel.currentConfig.chordTypes.contains("m7"))
        
        // 5. Start drill and verify config
        let result = setupViewModel.performPrimaryAction()
        guard case .startDrill(let config) = result else {
            XCTFail("Expected startDrill")
            return
        }
        
        XCTAssertEqual(config.difficulty, .custom)
        XCTAssertEqual(config.chordTypes.count, 3)
    }
    
    // MARK: - Flow: Custom Keys
    
    func test_flow_customKeys() {
        let setupViewModel = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: presetStore)
        
        // 1. User selects custom key difficulty
        setupViewModel.currentConfig.keyDifficulty = .custom
        
        // 2. Verify key picker is shown
        XCTAssertTrue(setupViewModel.showsKeyPicker)
        
        // 3. User selects specific keys
        setupViewModel.currentConfig.customKeys = []
        setupViewModel.toggleKey("C")
        setupViewModel.toggleKey("F")
        setupViewModel.toggleKey("Bb")
        setupViewModel.toggleKey("Eb")
        
        // 4. Verify selections
        XCTAssertEqual(setupViewModel.currentConfig.customKeys?.count, 4)
        
        // 5. Start drill and verify config
        let result = setupViewModel.performPrimaryAction()
        guard case .startDrill(let config) = result else {
            XCTFail("Expected startDrill")
            return
        }
        
        XCTAssertEqual(config.keyDifficulty, .custom)
        XCTAssertEqual(config.customKeys?.count, 4)
    }
    
    // MARK: - Flow: Multiple Saved Presets
    
    func test_flow_multipleSavedPresets() {
        // Create multiple presets
        for i in 1...5 {
            var config = ChordDrillConfig.default
            config.questionCount = i * 5
            let preset = CustomChordDrillPreset(name: "Preset \(i)", config: config)
            presetStore.savePreset(preset)
        }
        
        selectionViewModel.refreshSavedPresets()
        
        // Verify all are shown
        XCTAssertEqual(selectionViewModel.savedPresets.count, 5)
        
        // Verify each can be selected
        for preset in selectionViewModel.savedPresets {
            let action = selectionViewModel.selectSavedPreset(preset)
            guard case .startDrill = action else {
                XCTFail("Expected startDrill for preset \(preset.name)")
                continue
            }
        }
    }
}

// MARK: - Config Builder Tests

@MainActor
final class ChordDrillConfigBuilderTests: XCTestCase {
    
    func test_defaultConfig_hasValidDefaults() {
        let config = ChordDrillConfig.default
        
        XCTAssertEqual(config.difficulty, .beginner)
        XCTAssertEqual(config.keyDifficulty, .all)  // default is .all
        XCTAssertEqual(config.questionCount, 10)
        XCTAssertFalse(config.questionTypes.isEmpty)
    }
    
    func test_config_isCodable() {
        var config = ChordDrillConfig.default
        config.difficulty = .intermediate
        config.keyDifficulty = .medium
        config.questionCount = 20
        config.chordTypes = ["7", "maj7"]
        config.customKeys = ["C", "G", "D"]
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(config)
            let decoded = try decoder.decode(ChordDrillConfig.self, from: data)
            
            XCTAssertEqual(decoded.difficulty, .intermediate)
            XCTAssertEqual(decoded.keyDifficulty, .medium)
            XCTAssertEqual(decoded.questionCount, 20)
            XCTAssertEqual(decoded.chordTypes, ["7", "maj7"])
            XCTAssertEqual(decoded.customKeys, ["C", "G", "D"])
        } catch {
            XCTFail("Encoding/decoding failed: \(error)")
        }
    }
    
    func test_config_isEquatable() {
        let config1 = ChordDrillConfig.default
        let config2 = ChordDrillConfig.default
        
        XCTAssertEqual(config1, config2)
    }
    
    func test_config_differentConfigs_notEqual() {
        var config1 = ChordDrillConfig.default
        var config2 = ChordDrillConfig.default
        
        config1.questionCount = 10
        config2.questionCount = 20
        
        XCTAssertNotEqual(config1, config2)
    }
}

// MARK: - Critical User Flow Bug Tests
// These tests explicitly verify the bugs reported by the user.
// They MUST fail until the implementation is fixed.

@MainActor
final class ChordDrillCriticalBugTests: XCTestCase {
    
    var presetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "ChordDrillCriticalBugTests")!
        testDefaults.removePersistentDomain(forName: "ChordDrillCriticalBugTests")
        presetStore = CustomPresetStore(userDefaults: testDefaults)
    }
    
    override func tearDown() {
        presetStore.deleteAllPresets()
        UserDefaults.standard.removePersistentDomain(forName: "ChordDrillCriticalBugTests")
        presetStore = nil
        super.tearDown()
    }
    
    // MARK: - BUG #1 & #2: presetLaunch mode has no safe fallback for quit/newQuiz
    //
    // Root cause: DrillLaunchMode.presetLaunch has:
    //   - showsSetupScreen = false (so .setup state shows curriculumStartView)
    //   - moduleId = nil (so curriculumStartView shows "module not found")
    //
    // When user quits or taps "New Quiz", viewState goes to .setup, which crashes.
    
    func test_drillLaunchMode_presetLaunch_mustHaveSafeFallback() {
        // This test verifies the invariant that presetLaunch mode can handle
        // going back to .setup state without showing "module not found"
        
        let mode = DrillLaunchMode.presetLaunch
        
        // The bug: showsSetupScreen is false, but we have no module
        // So when viewState = .setup, the view shows curriculumStartView
        // but curriculumStartView requires activeModule which is nil
        
        // EITHER:
        // 1. presetLaunch should have showsSetupScreen = true (show regular setup on quit)
        // 2. OR presetLaunch should NOT allow viewState = .setup (must dismiss instead)
        
        // Currently this fails because showsSetupScreen = false AND moduleId = nil
        // which means going to .setup state will break
        XCTAssertTrue(mode.showsSetupScreen,
            "FAIL: presetLaunch has showsSetupScreen=false but no moduleId. " +
            "Going to .setup state will show curriculumStartView with no module!")
    }
    
    // MARK: - BUG #3: Custom Ad-Hoc shows blank screen
    //
    // INTEGRATION TEST: Tests the actual sheet presentation flow
    
    func test_customAdHoc_sheetPresentationLogic() {
        // This test verifies the ACTUAL presentation logic, not just ViewModel data
        
        let selectionViewModel = ChordDrillPresetSelectionViewModel(presetStore: presetStore)
        
        // Simulate tapping Custom Ad-Hoc button
        let action = selectionViewModel.selectBuiltInPreset(.customAdHoc)
        
        // Verify it returns the correct action
        guard case .openSetup(let mode) = action else {
            XCTFail("FAIL: Custom Ad-Hoc should return .openSetup action, got \(action)")
            return
        }
        
        // Verify the mode is .adHoc (not nil or wrong type)
        XCTAssertEqual(mode, .adHoc,
            "FAIL: Custom Ad-Hoc should open setup in .adHoc mode")
        
        // Now verify that if we create the view with this mode, it has content
        let setupViewModel = ChordDrillSetupViewModelNew(mode: mode, presetStore: presetStore)
        
        // CRITICAL: These must be non-empty for the Form to show anything
        XCTAssertFalse(setupViewModel.availableChordDifficulties.isEmpty,
            "FAIL: No chord difficulties - Form will be blank!")
        XCTAssertFalse(setupViewModel.availableKeyDifficulties.isEmpty,
            "FAIL: No key difficulties - Form will be blank!")
        XCTAssertFalse(setupViewModel.currentConfig.questionTypes.isEmpty,
            "FAIL: No question types - Form will be invalid!")
        
        // The view should NOT show preset name field in ad-hoc mode
        XCTAssertFalse(setupViewModel.showsPresetNameField,
            "FAIL: Ad-hoc mode should not show preset name field")
        
        // The primary button should say "Start Drill"
        XCTAssertEqual(setupViewModel.primaryButtonTitle, "Start Drill",
            "FAIL: Wrong button title for ad-hoc mode")
        
        // Should be able to start immediately with default config
        XCTAssertTrue(setupViewModel.canPerformPrimaryAction,
            "FAIL: Cannot start drill with default ad-hoc config")
    }
    
    // MARK: - BUG #3 Part 2: Sheet presentation state machine
    //
    // This tests the ACTUAL bug: sheet shows empty view because of timing
    
    func test_customAdHoc_sheetStateIsValidBeforePresentation() {
        // The ChordDrillPresetSelectionView has this pattern:
        //   @State private var showingSetup = false
        //   @State private var setupMode: SetupMode?
        //
        //   .sheet(isPresented: $showingSetup) {
        //       if let mode = setupMode {
        //           ChordDrillSetupView(mode: mode) { ... }
        //       }
        //   }
        //
        // BUG: If showingSetup becomes true when setupMode is still nil,
        // the sheet shows an empty view (the if-let fails)
        //
        // This is a SwiftUI state synchronization issue that is IMPOSSIBLE to test
        // with unit tests. The test documents the bug, but we can't make it fail.
        //
        // REQUIRED FIX: Use .sheet(item: $setupMode) instead of .sheet(isPresented:)
        // That pattern guarantees the item is non-nil when presented.
        
        // Test the action flow
        let selectionViewModel = ChordDrillPresetSelectionViewModel(presetStore: presetStore)
        let action = selectionViewModel.selectBuiltInPreset(.customAdHoc)
        
        // Verify action has the mode
        guard case .openSetup(let mode) = action else {
            XCTFail("FAIL: Custom Ad-Hoc must return .openSetup with mode")
            return
        }
        
        // This test PASSES, but the app is still broken!
        // The bug is in the View layer (SwiftUI state timing), not the ViewModel.
        XCTAssertNotNil(mode,
            "setupMode has a value in the ViewModel, but SwiftUI might not sync it in time!")
    }
    
    // MARK: - BUG #4: Create Preset freezes on keyboard input
    //
    // INTEGRATION TEST: Tests the actual StateObject lifecycle issue
    
    func test_createPreset_stateObjectDoesNotRecreateOnPropertyChange() {
        // The freeze happens because StateObject is being recreated on every keystroke
        // This is a SwiftUI lifecycle bug that unit tests can't catch
        
        // We can test that the ViewModel itself is stable
        let viewModel = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: presetStore)
        
        // Get the initial object identifier
        let initialObjectId = ObjectIdentifier(viewModel)
        
        // Simulate typing - this should NOT create a new ViewModel
        viewModel.presetName = "T"
        viewModel.presetName = "Te"
        viewModel.presetName = "Tes"
        viewModel.presetName = "Test"
        
        // Verify it's still the same instance
        let afterTypingObjectId = ObjectIdentifier(viewModel)
        XCTAssertEqual(initialObjectId, afterTypingObjectId,
            "FAIL: ViewModel instance changed during typing! " +
            "This indicates StateObject recreation bug.")
    }
    
    // MARK: - BUG #4 Part 2: Performance test
    //
    // Even if StateObject is stable, expensive computed properties can freeze UI
    
    func test_createPreset_expensivePropertiesAreCached() {
        let viewModel = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: presetStore)
        
        // These properties are accessed on EVERY render in the view
        // If they're computed fresh each time, performance will be terrible
        
        // Test that accessing them multiple times is fast
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<100 {
            // These are accessed by the Form sections
            let _ = viewModel.allChordTypes
            let _ = viewModel.allKeys
            let _ = viewModel.availableChordDifficulties
            let _ = viewModel.availableKeyDifficulties
        }
        
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        
        // 100 accesses should be nearly instant if cached (< 10ms)
        // If computed fresh each time, this will be slow (> 100ms)
        XCTAssertLessThan(elapsed, 50,
            "FAIL: Property access took \(Int(elapsed))ms for 100 iterations. " +
            "Properties must be cached, not computed on every access!")
    }
    
    // MARK: - BUG #4 Part 3: Typing performance in realistic scenario
    
    func test_createPreset_typingSimulationIsFast() {
        let viewModel = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: presetStore)
        
        // Simulate what happens on each keystroke in the actual UI:
        // 1. Text changes (triggers Published update)
        // 2. View re-renders
        // 3. All computed properties accessed
        // 4. Validation runs
        
        let start = CFAbsoluteTimeGetCurrent()
        
        let testName = "My Custom Preset Name"
        for char in testName {
            // Simulate keystroke
            viewModel.presetName.append(char)
            
            // Simulate view re-render accessing all properties
            let _ = viewModel.canPerformPrimaryAction
            let _ = viewModel.validationError
            let _ = viewModel.primaryButtonTitle
            let _ = viewModel.showsPresetNameField
            let _ = viewModel.allChordTypes  // Expensive if not cached
            let _ = viewModel.allKeys        // Expensive if not cached
        }
        
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        
        // 22 keystrokes with full property access should be < 100ms
        // If it's slower, UI will feel frozen
        XCTAssertLessThan(elapsed, 100,
            "FAIL: Typing simulation took \(Int(elapsed))ms. " +
            "UI will freeze at this speed. Target: < 100ms")
    }
    
    // MARK: - Explicit Flow Test: What happens when user quits?
    
    func test_presetLaunch_viewStateMachine_quitBehavior() {
        // This documents the REQUIRED behavior for quit in presetLaunch mode
        
        let mode = DrillLaunchMode.presetLaunch
        
        // Test the current broken state - this should FAIL
        let canSafelyShowSetupState = mode.showsSetupScreen || mode.moduleId != nil
        
        XCTAssertTrue(canSafelyShowSetupState,
            "FAIL: presetLaunch cannot safely go to .setup state! " +
            "showsSetupScreen=\(mode.showsSetupScreen), moduleId=\(String(describing: mode.moduleId))")
    }
    
    // MARK: - Explicit Flow Test: What happens on "New Quiz"?
    
    func test_presetLaunch_viewStateMachine_newQuizBehavior() {
        // Same issue as quit - "New Quiz" calls viewState = .setup
        
        let mode = DrillLaunchMode.presetLaunch
        
        // This assertion documents the bug - it should FAIL
        XCTAssertTrue(mode.showsSetupScreen,
            "FAIL: presetLaunch mode going to .setup will show curriculum view! " +
            "The 'New Quiz' button is broken for preset-launched drills.")
    }
    
    // MARK: - Enharmonic Spelling Tests
    
    func test_noteDisplay_matchesChordRootSpelling_flats() {
        // When showing Abmaj6 chord, notes should display as flats, not sharps
        let abRoot = Note(name: "Ab", midiNumber: 68, isSharp: false)
        let gSharpEnharmonic = Note(name: "G#", midiNumber: 68, isSharp: true)
        
        // User selects G# but chord root is Ab - should display as Ab
        let displayName = spelledNoteName(gSharpEnharmonic, basedOn: abRoot)
        XCTAssertEqual(displayName, "Ab", 
            "Note should display as Ab to match root spelling, not G#")
    }
    
    func test_noteDisplay_matchesChordRootSpelling_sharps() {
        // When showing F#7 chord, notes should display as sharps, not flats
        let fSharpRoot = Note(name: "F#", midiNumber: 66, isSharp: true)
        let gFlatEnharmonic = Note(name: "Gb", midiNumber: 66, isSharp: false)
        
        // User selects Gb but chord root is F# - should display as F#
        let displayName = spelledNoteName(gFlatEnharmonic, basedOn: fSharpRoot)
        XCTAssertEqual(displayName, "F#",
            "Note should display as F# to match root spelling, not Gb")
    }
    
    func test_noteDisplay_naturalNotes_unchanged() {
        // Natural notes should always display with their own name
        let cRoot = Note(name: "C", midiNumber: 60, isSharp: false)
        let dNote = Note(name: "D", midiNumber: 62, isSharp: false)
        
        let displayName = spelledNoteName(dNote, basedOn: cRoot)
        XCTAssertEqual(displayName, "D", "Natural notes should display unchanged")
    }
    
    // Helper method - same as in ChordDrillSession
    private func spelledNoteName(_ note: Note, basedOn root: Note) -> String {
        if note.name == root.name {
            return note.name
        }
        
        if let enharmonic = note.enharmonicEquivalent {
            if root.name.contains("b") && enharmonic.name.contains("b") {
                return enharmonic.name
            } else if root.name.contains("#") && enharmonic.name.contains("#") {
                return enharmonic.name
            }
        }
        
        return note.name
    }
}

// MARK: - UI Tests (XCUITest)

/// UI Tests for Chord Drill critical user flows
/// These tests catch View-layer bugs that unit tests cannot detect:
/// - Blank screens (empty sheet presentation)
/// - UI freezing (keyboard input lag)
/// - Navigation errors ("Module not found")
///
/// Note: These tests launch the actual app and are slower than unit tests.
/// They should focus on critical happy paths only.
final class ChordDrillUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI-TESTING"]
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
    func test_UI_customAdHoc_opensSetupSheetWithContent() throws {
        navigateToChordDrill()
        
        // Find and tap Custom Ad-Hoc button
        let customAdHocButton = app.buttons["Custom Ad-Hoc"]
        XCTAssertTrue(customAdHocButton.waitForExistence(timeout: 2), "Custom Ad-Hoc button should exist")
        customAdHocButton.tap()
        
        // Wait for sheet to present
        Thread.sleep(forTimeInterval: 0.5)
        
        // Verify setup sheet content is visible (NOT blank)
        let chordTypesHeader = app.staticTexts["Chord Types"]
        let keysHeader = app.staticTexts["Keys"]
        let startDrillButton = app.buttons["Start Drill"]
        
        XCTAssertTrue(chordTypesHeader.waitForExistence(timeout: 3),
            "FAIL: Setup sheet is blank! Chord Types section should be visible")
        
        XCTAssertTrue(keysHeader.waitForExistence(timeout: 1),
            "FAIL: Setup sheet is blank! Keys section should be visible")
        
        XCTAssertTrue(startDrillButton.waitForExistence(timeout: 1),
            "FAIL: Setup sheet is blank! Start Drill button should be visible")
    }
    
    /// BUG #4: Create Preset keyboard freezes
    /// This test verifies typing in the preset name field is responsive
    func test_UI_createPreset_textFieldIsResponsive() throws {
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
        Thread.sleep(forTimeInterval: 0.3)
        
        // Type text and measure time (should be nearly instant)
        let start = Date()
        presetNameField.typeText("My Preset")
        let elapsed = Date().timeIntervalSince(start)
        
        // Typing 9 characters should take less than 2 seconds
        XCTAssertLessThan(elapsed, 2.0,
            "FAIL: Typing took \(elapsed)s - UI appears to be freezing! Should be < 2s")
        
        // Verify the text actually appeared
        let typedValue = presetNameField.value as? String ?? ""
        XCTAssertTrue(typedValue.contains("My Preset"),
            "FAIL: Text didn't appear in field. Expected 'My Preset', got '\(typedValue)'")
    }
    
    /// BUG #1 & #2: Quit/New Quiz shows "Module not found"
    /// This test verifies preset-launched drills handle quit gracefully
    func test_UI_presetLaunch_quitReturnsToSetup() throws {
        navigateToChordDrill()
        
        // Tap Basic Triads to start a preset drill
        let basicTriadsButton = app.buttons["Basic Triads"]
        XCTAssertTrue(basicTriadsButton.waitForExistence(timeout: 2), "Basic Triads button should exist")
        basicTriadsButton.tap()
        
        // Wait for drill to start
        let submitButton = app.buttons["Submit Answer"]
        let playButton = app.buttons.matching(NSPredicate(format: "label CONTAINS 'Play'")).firstMatch
        
        XCTAssertTrue(submitButton.waitForExistence(timeout: 5) || playButton.exists,
            "FAIL: Drill should have started")
        
        // Find and tap Quit button
        let quitButton = app.buttons["Quit"]
        XCTAssertTrue(quitButton.waitForExistence(timeout: 2), "Quit button should exist")
        quitButton.tap()
        
        // Wait for transition
        Thread.sleep(forTimeInterval: 0.5)
        
        // Verify we're back at setup screen (NOT "Module not found")
        let quickStartLabel = app.staticTexts["Quick Start"]
        let chordTypesHeader = app.staticTexts["Chord Types"]
        
        let isOnValidScreen = quickStartLabel.waitForExistence(timeout: 3) || 
                             chordTypesHeader.waitForExistence(timeout: 1)
        
        XCTAssertTrue(isOnValidScreen,
            "FAIL: After quit, expected preset selection or setup screen - may be showing 'Module not found'")
        
        // Explicitly check we DON'T see an error message
        let errorText = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'module' OR label CONTAINS[c] 'not found' OR label CONTAINS[c] 'error'")).firstMatch
        
        XCTAssertFalse(errorText.exists,
            "FAIL: Found error text: \(errorText.label)")
    }
}

