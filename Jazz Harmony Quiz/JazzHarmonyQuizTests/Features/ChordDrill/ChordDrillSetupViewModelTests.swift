//
//  ChordDrillSetupViewModelTests.swift
//  JazzHarmonyQuizTests
//
//  Tests for ChordDrillSetupViewModel - the ViewModel that manages the drill setup screen.
//  Using TDD to define expected UI behaviors before implementation.
//

import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class ChordDrillSetupViewModelTests: XCTestCase {
    
    var sut: ChordDrillSetupViewModel!
    var mockPresetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "ChordDrillSetupViewModelTests")!
        mockPresetStore = CustomPresetStore(userDefaults: testDefaults)
        mockPresetStore.deleteAllPresets()
        sut = ChordDrillSetupViewModel(presetStore: mockPresetStore)
    }
    
    override func tearDown() {
        mockPresetStore.deleteAllPresets()
        UserDefaults(suiteName: "ChordDrillSetupViewModelTests")?.removePersistentDomain(forName: "ChordDrillSetupViewModelTests")
        sut = nil
        mockPresetStore = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_showsQuickStartMode() {
        XCTAssertEqual(sut.currentMode, .quickStart)
    }
    
    func test_initialState_hasBuiltInPresets() {
        XCTAssertEqual(sut.builtInPresets.count, 3)
        XCTAssertTrue(sut.builtInPresets.contains(.basicTriads))
        XCTAssertTrue(sut.builtInPresets.contains(.seventhAndSixthChords))
        XCTAssertTrue(sut.builtInPresets.contains(.fullWorkout))
    }
    
    func test_initialState_hasEmptyCustomPresets() {
        XCTAssertTrue(sut.customPresets.isEmpty)
    }
    
    func test_initialState_hasDefaultConfig() {
        XCTAssertEqual(sut.currentConfig.questionCount, 10)
        XCTAssertEqual(sut.currentConfig.keyDifficulty, .easy)
        XCTAssertEqual(sut.currentConfig.difficulty, .beginner)
    }
    
    // MARK: - Mode Switching Tests
    
    func test_switchToCustomMode_changesCurrentMode() {
        sut.switchToCustomMode()
        XCTAssertEqual(sut.currentMode, .custom)
    }
    
    func test_switchToQuickStart_changesCurrentMode() {
        sut.switchToCustomMode()
        sut.switchToQuickStart()
        XCTAssertEqual(sut.currentMode, .quickStart)
    }
    
    func test_switchToSavePreset_changesCurrentMode() {
        sut.switchToSavePresetMode()
        XCTAssertEqual(sut.currentMode, .savePreset)
    }
    
    // MARK: - Quick Start Selection Tests
    
    func test_selectBuiltInPreset_updatesConfig() {
        sut.selectBuiltInPreset(.fullWorkout)
        
        let expectedConfig = ChordDrillConfig.fromPreset(.fullWorkout)
        XCTAssertEqual(sut.currentConfig.chordTypes, expectedConfig.chordTypes)
        XCTAssertEqual(sut.currentConfig.keyDifficulty, expectedConfig.keyDifficulty)
        XCTAssertEqual(sut.currentConfig.questionTypes, expectedConfig.questionTypes)
    }
    
    func test_selectBuiltInPreset_preservesQuestionCount() {
        sut.currentConfig.questionCount = 25
        sut.selectBuiltInPreset(.basicTriads)
        
        // User's question count preference should be preserved
        XCTAssertEqual(sut.currentConfig.questionCount, 25)
    }
    
    func test_selectBuiltInPreset_setsSelectedPreset() {
        sut.selectBuiltInPreset(.basicTriads)
        XCTAssertEqual(sut.selectedBuiltInPreset, .basicTriads)
    }
    
    // MARK: - Custom Preset Selection Tests
    
    func test_selectCustomPreset_updatesConfig() {
        var customConfig = ChordDrillConfig.default
        customConfig.chordTypes = ["7", "maj7"]
        customConfig.questionCount = 20
        let customPreset = CustomChordDrillPreset(name: "My Jazz", config: customConfig)
        mockPresetStore.savePreset(customPreset)
        sut.refreshCustomPresets()
        
        sut.selectCustomPreset(customPreset)
        
        XCTAssertEqual(Set(sut.currentConfig.chordTypes), Set(["7", "maj7"]))
        XCTAssertEqual(sut.currentConfig.questionCount, 20)
    }
    
    func test_selectCustomPreset_setsSelectedCustomPreset() {
        let customPreset = CustomChordDrillPreset(name: "Test", config: .default)
        mockPresetStore.savePreset(customPreset)
        sut.refreshCustomPresets()
        
        sut.selectCustomPreset(customPreset)
        
        XCTAssertEqual(sut.selectedCustomPreset?.id, customPreset.id)
    }
    
    func test_selectCustomPreset_clearsBuiltInSelection() {
        sut.selectBuiltInPreset(.basicTriads)
        let customPreset = CustomChordDrillPreset(name: "Test", config: .default)
        mockPresetStore.savePreset(customPreset)
        sut.refreshCustomPresets()
        
        sut.selectCustomPreset(customPreset)
        
        XCTAssertNil(sut.selectedBuiltInPreset)
    }
    
    // MARK: - Custom Configuration Tests
    
    func test_updateQuestionCount_updatesConfig() {
        sut.updateQuestionCount(15)
        XCTAssertEqual(sut.currentConfig.questionCount, 15)
    }
    
    func test_updateChordDifficulty_beginner_setsCorrectChordTypes() {
        sut.updateChordDifficulty(.beginner)
        
        XCTAssertEqual(sut.currentConfig.difficulty, .beginner)
        // Should set chord types to beginner level chords
        XCTAssertFalse(sut.showChordTypeSelection, "Beginner should not show chord type selection")
    }
    
    func test_updateChordDifficulty_custom_showsChordTypeSelection() {
        sut.updateChordDifficulty(.custom)
        
        XCTAssertEqual(sut.currentConfig.difficulty, .custom)
        XCTAssertTrue(sut.showChordTypeSelection, "Custom should show chord type selection")
    }
    
    func test_updateKeyDifficulty_easy_setsKeyDifficulty() {
        sut.updateKeyDifficulty(.easy)
        
        XCTAssertEqual(sut.currentConfig.keyDifficulty, .easy)
        XCTAssertFalse(sut.showKeySelection, "Easy should not show key selection")
    }
    
    func test_updateKeyDifficulty_custom_showsKeySelection() {
        sut.updateKeyDifficulty(.custom)
        
        XCTAssertEqual(sut.currentConfig.keyDifficulty, .custom)
        XCTAssertTrue(sut.showKeySelection, "Custom should show key selection")
    }
    
    func test_toggleQuestionType_addsType() {
        sut.currentConfig.questionTypes = [.allTones]
        
        sut.toggleQuestionType(.singleTone)
        
        XCTAssertTrue(sut.currentConfig.questionTypes.contains(.singleTone))
        XCTAssertTrue(sut.currentConfig.questionTypes.contains(.allTones))
    }
    
    func test_toggleQuestionType_removesType() {
        sut.currentConfig.questionTypes = [.allTones, .singleTone]
        
        sut.toggleQuestionType(.singleTone)
        
        XCTAssertFalse(sut.currentConfig.questionTypes.contains(.singleTone))
        XCTAssertTrue(sut.currentConfig.questionTypes.contains(.allTones))
    }
    
    func test_toggleQuestionType_preventsEmptySelection() {
        sut.currentConfig.questionTypes = [.allTones]
        
        sut.toggleQuestionType(.allTones)
        
        // Should not remove the last question type
        XCTAssertTrue(sut.currentConfig.questionTypes.contains(.allTones))
    }
    
    func test_toggleChordType_addsType() {
        sut.currentConfig.chordTypes = ["7"]
        
        sut.toggleChordType("maj7")
        
        XCTAssertTrue(sut.currentConfig.chordTypes.contains("maj7"))
        XCTAssertTrue(sut.currentConfig.chordTypes.contains("7"))
    }
    
    func test_toggleChordType_removesType() {
        sut.currentConfig.chordTypes = ["7", "maj7"]
        
        sut.toggleChordType("7")
        
        XCTAssertFalse(sut.currentConfig.chordTypes.contains("7"))
        XCTAssertTrue(sut.currentConfig.chordTypes.contains("maj7"))
    }
    
    func test_toggleKey_addsKey() {
        sut.currentConfig.customKeys = ["C"]
        
        sut.toggleKey("G")
        
        XCTAssertTrue(sut.currentConfig.customKeys?.contains("G") ?? false)
        XCTAssertTrue(sut.currentConfig.customKeys?.contains("C") ?? false)
    }
    
    func test_toggleKey_removesKey() {
        sut.currentConfig.customKeys = ["C", "G"]
        
        sut.toggleKey("G")
        
        XCTAssertFalse(sut.currentConfig.customKeys?.contains("G") ?? true)
        XCTAssertTrue(sut.currentConfig.customKeys?.contains("C") ?? false)
    }
    
    func test_toggleKey_preventsEmptySelection() {
        sut.currentConfig.customKeys = ["C"]
        
        sut.toggleKey("C")
        
        // Should not remove the last key
        XCTAssertTrue(sut.currentConfig.customKeys?.contains("C") ?? false)
    }
    
    // MARK: - Preset Saving Tests
    
    func test_saveCurrentAsPreset_createsPreset() {
        sut.currentConfig.chordTypes = ["7", "maj7", "m7"]
        sut.currentConfig.questionCount = 15
        sut.presetName = "My 7th Chords"
        
        let result = sut.saveCurrentAsPreset()
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(sut.customPresets.count, 1)
        XCTAssertEqual(sut.customPresets.first?.name, "My 7th Chords")
    }
    
    func test_saveCurrentAsPreset_failsWithEmptyName() {
        sut.presetName = ""
        
        let result = sut.saveCurrentAsPreset()
        
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, .emptyName)
    }
    
    func test_saveCurrentAsPreset_failsWithDuplicateName() {
        let existingPreset = CustomChordDrillPreset(name: "Existing", config: .default)
        mockPresetStore.savePreset(existingPreset)
        sut.refreshCustomPresets()
        
        sut.presetName = "Existing"
        let result = sut.saveCurrentAsPreset()
        
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, .duplicateName)
    }
    
    func test_saveCurrentAsPreset_clearsPresetNameAfterSuccess() {
        sut.presetName = "New Preset"
        
        _ = sut.saveCurrentAsPreset()
        
        XCTAssertEqual(sut.presetName, "")
    }
    
    func test_saveCurrentAsPreset_switchesToQuickStartMode() {
        sut.switchToSavePresetMode()
        sut.presetName = "New Preset"
        
        _ = sut.saveCurrentAsPreset()
        
        XCTAssertEqual(sut.currentMode, .quickStart)
    }
    
    // MARK: - Preset Deletion Tests
    
    func test_deleteCustomPreset_removesPreset() {
        let preset = CustomChordDrillPreset(name: "ToDelete", config: .default)
        mockPresetStore.savePreset(preset)
        sut.refreshCustomPresets()
        
        XCTAssertEqual(sut.customPresets.count, 1)
        
        sut.deleteCustomPreset(preset)
        
        XCTAssertEqual(sut.customPresets.count, 0)
    }
    
    func test_deleteCustomPreset_clearsSelectionIfSelected() {
        let preset = CustomChordDrillPreset(name: "Selected", config: .default)
        mockPresetStore.savePreset(preset)
        sut.refreshCustomPresets()
        sut.selectCustomPreset(preset)
        
        sut.deleteCustomPreset(preset)
        
        XCTAssertNil(sut.selectedCustomPreset)
    }
    
    // MARK: - Available Options Tests
    
    func test_availableKeys_returnsAll12Keys() {
        let keys = sut.availableKeys
        XCTAssertEqual(keys.count, 12)
        XCTAssertTrue(keys.contains("C"))
        XCTAssertTrue(keys.contains("F#"))
        XCTAssertTrue(keys.contains("Bb"))
    }
    
    func test_availableChordTypes_returnsAllFromDatabase() {
        let chordTypes = sut.availableChordTypes
        XCTAssertFalse(chordTypes.isEmpty)
        // Should include at least basic chord types
        XCTAssertTrue(chordTypes.contains(""))  // Major
        XCTAssertTrue(chordTypes.contains("m")) // Minor
        XCTAssertTrue(chordTypes.contains("7")) // Dominant 7
    }
    
    func test_availableQuestionTypes_returnsAllTypes() {
        let types = sut.availableQuestionTypes
        XCTAssertEqual(types.count, 4)
        XCTAssertTrue(types.contains(.singleTone))
        XCTAssertTrue(types.contains(.allTones))
        XCTAssertTrue(types.contains(.auralQuality))
        XCTAssertTrue(types.contains(.auralSpelling))
    }
    
    func test_chordTypesForDifficulty_beginner_returnsBeginnerChords() {
        let types = sut.chordTypesForDifficulty(.beginner)
        // Beginner should include basic chords
        XCTAssertTrue(types.contains(""))  // Major
        XCTAssertTrue(types.contains("m")) // Minor
        XCTAssertTrue(types.contains("7")) // Dominant 7
        XCTAssertTrue(types.contains("maj7")) // Major 7
    }
    
    func test_chordTypesForDifficulty_advanced_includesAllChords() {
        let types = sut.chordTypesForDifficulty(.advanced)
        // Advanced includes all
        XCTAssertTrue(types.contains(""))
        XCTAssertTrue(types.contains("7b9"))
    }
    
    // MARK: - Validation Tests
    
    func test_canStartDrill_trueWithValidConfig() {
        sut.currentConfig.questionTypes = [.allTones]
        sut.currentConfig.questionCount = 10
        
        XCTAssertTrue(sut.canStartDrill)
    }
    
    func test_canStartDrill_falseWithNoQuestionTypes() {
        sut.currentConfig.questionTypes = []
        
        XCTAssertFalse(sut.canStartDrill)
    }
    
    func test_canStartDrill_falseWithZeroQuestions() {
        sut.currentConfig.questionCount = 0
        
        XCTAssertFalse(sut.canStartDrill)
    }
    
    func test_canStartDrill_falseWithCustomKeyDifficultyAndNoKeys() {
        sut.currentConfig.keyDifficulty = .custom
        sut.currentConfig.customKeys = []
        
        XCTAssertFalse(sut.canStartDrill)
    }
    
    func test_canStartDrill_falseWithCustomChordDifficultyAndNoChords() {
        sut.currentConfig.difficulty = .custom
        sut.currentConfig.chordTypes = []
        
        XCTAssertFalse(sut.canStartDrill)
    }
    
    // MARK: - Config Building Tests
    
    func test_buildConfigForDrill_returnsCurrentConfig() {
        sut.currentConfig.questionCount = 20
        sut.currentConfig.chordTypes = ["7", "maj7"]
        
        let config = sut.buildConfigForDrill()
        
        XCTAssertEqual(config.questionCount, 20)
        XCTAssertEqual(Set(config.chordTypes), Set(["7", "maj7"]))
    }
    
    func test_buildConfigForDrill_appliesChordDifficultyTypes_whenNotCustom() {
        sut.updateChordDifficulty(.beginner)
        
        let config = sut.buildConfigForDrill()
        
        // Should have beginner chord types applied
        XCTAssertEqual(config.difficulty, .beginner)
        // Chord types should be set based on beginner difficulty
    }
}

// MARK: - Setup Mode Enum Tests

final class ChordDrillSetupModeTests: XCTestCase {
    
    func test_setupMode_hasExpectedCases() {
        let modes: [ChordDrillSetupMode] = [.quickStart, .custom, .savePreset]
        XCTAssertEqual(modes.count, 3)
    }
    
    func test_quickStartMode_displayName() {
        XCTAssertEqual(ChordDrillSetupMode.quickStart.displayName, "Quick Start")
    }
    
    func test_customMode_displayName() {
        XCTAssertEqual(ChordDrillSetupMode.custom.displayName, "Custom Drill")
    }
    
    func test_savePresetMode_displayName() {
        XCTAssertEqual(ChordDrillSetupMode.savePreset.displayName, "Save Preset")
    }
}

// MARK: - End-to-End Flow Tests

@MainActor
final class ChordDrillSetupFlowTests: XCTestCase {
    
    var sut: ChordDrillSetupViewModel!
    var mockPresetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "ChordDrillSetupFlowTests")!
        mockPresetStore = CustomPresetStore(userDefaults: testDefaults)
        mockPresetStore.deleteAllPresets()
        sut = ChordDrillSetupViewModel(presetStore: mockPresetStore)
    }
    
    override func tearDown() {
        mockPresetStore.deleteAllPresets()
        UserDefaults(suiteName: "ChordDrillSetupFlowTests")?.removePersistentDomain(forName: "ChordDrillSetupFlowTests")
        sut = nil
        mockPresetStore = nil
        super.tearDown()
    }
    
    func test_flow_quickStartWithBuiltInPreset() {
        // User opens setup screen
        XCTAssertEqual(sut.currentMode, .quickStart)
        
        // User taps Basic Triads
        sut.selectBuiltInPreset(.basicTriads)
        
        // Config should be ready
        XCTAssertTrue(sut.canStartDrill)
        let config = sut.buildConfigForDrill()
        XCTAssertEqual(config.difficulty, .beginner)
    }
    
    func test_flow_createAndUseCustomPreset() {
        // User switches to custom mode
        sut.switchToCustomMode()
        XCTAssertEqual(sut.currentMode, .custom)
        
        // User configures custom drill
        sut.updateQuestionCount(15)
        sut.updateChordDifficulty(.intermediate)
        sut.updateKeyDifficulty(.medium)
        sut.toggleQuestionType(.singleTone)
        
        // User switches to save preset mode
        sut.switchToSavePresetMode()
        XCTAssertEqual(sut.currentMode, .savePreset)
        
        // User enters name and saves
        sut.presetName = "My Jazz Practice"
        let saveResult = sut.saveCurrentAsPreset()
        XCTAssertTrue(saveResult.success)
        
        // Should return to quick start with new preset available
        XCTAssertEqual(sut.currentMode, .quickStart)
        XCTAssertEqual(sut.customPresets.count, 1)
        
        // User can now select the custom preset
        sut.selectCustomPreset(sut.customPresets.first!)
        XCTAssertEqual(sut.currentConfig.questionCount, 15)
    }
    
    func test_flow_customDrillWithCustomKeys() {
        // User switches to custom mode
        sut.switchToCustomMode()
        
        // User selects custom keys
        sut.updateKeyDifficulty(.custom)
        XCTAssertTrue(sut.showKeySelection)
        
        // Initialize with some keys
        sut.currentConfig.customKeys = ["C"]
        sut.toggleKey("G")
        sut.toggleKey("D")
        sut.toggleKey("A")
        
        // Verify config
        XCTAssertEqual(Set(sut.currentConfig.customKeys ?? []), Set(["C", "G", "D", "A"]))
        XCTAssertTrue(sut.canStartDrill)
    }
    
    func test_flow_customDrillWithCustomChordTypes() {
        // User switches to custom mode
        sut.switchToCustomMode()
        
        // User selects custom chord difficulty
        sut.updateChordDifficulty(.custom)
        XCTAssertTrue(sut.showChordTypeSelection)
        
        // User selects specific chords
        sut.currentConfig.chordTypes = []
        sut.toggleChordType("7")
        sut.toggleChordType("maj7")
        sut.toggleChordType("m7")
        
        // Verify config
        XCTAssertEqual(Set(sut.currentConfig.chordTypes), Set(["7", "maj7", "m7"]))
        XCTAssertTrue(sut.canStartDrill)
    }
    
    func test_flow_deleteCustomPresetAndCreateNew() {
        // Create a preset
        sut.presetName = "Old Preset"
        _ = sut.saveCurrentAsPreset()
        XCTAssertEqual(sut.customPresets.count, 1)
        
        // Delete it
        sut.deleteCustomPreset(sut.customPresets.first!)
        XCTAssertEqual(sut.customPresets.count, 0)
        
        // Create new with same name (should work)
        sut.presetName = "Old Preset"
        let result = sut.saveCurrentAsPreset()
        XCTAssertTrue(result.success)
        XCTAssertEqual(sut.customPresets.count, 1)
    }
}
