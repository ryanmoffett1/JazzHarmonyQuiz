import XCTest
@testable import JazzHarmonyQuiz

// MARK: - Setup View Tests

@MainActor
final class ChordDrillSetupViewModelModeTests: XCTestCase {
    
    var sut: ChordDrillSetupViewModelNew!
    var mockPresetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "SetupViewModelModeTests")!
        testDefaults.removePersistentDomain(forName: "SetupViewModelModeTests")
        mockPresetStore = CustomPresetStore(userDefaults: testDefaults)
    }
    
    override func tearDown() {
        mockPresetStore.deleteAllPresets()
        UserDefaults.standard.removePersistentDomain(forName: "SetupViewModelModeTests")
        sut = nil
        mockPresetStore = nil
        super.tearDown()
    }
    
    // MARK: - Mode Tests
    
    func test_adHocMode_hidesPresetNameField() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        
        XCTAssertFalse(sut.showsPresetNameField)
    }
    
    func test_adHocMode_showsStartDrillButton() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        
        XCTAssertEqual(sut.primaryButtonTitle, "Start Drill")
    }
    
    func test_adHocMode_primaryAction_returnsDrillConfig() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        sut.currentConfig.questionCount = 15
        
        let result = sut.performPrimaryAction()
        
        if case .startDrill(let config) = result {
            XCTAssertEqual(config.questionCount, 15)
        } else {
            XCTFail("Expected startDrill result")
        }
    }
    
    func test_adHocMode_primaryAction_doesNotSavePreset() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        sut.currentConfig.questionCount = 20
        
        _ = sut.performPrimaryAction()
        
        XCTAssertEqual(mockPresetStore.allPresets.count, 0)
    }
    
    func test_createMode_showsPresetNameField() {
        sut = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: mockPresetStore)
        
        XCTAssertTrue(sut.showsPresetNameField)
    }
    
    func test_createMode_showsSavePresetButton() {
        sut = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: mockPresetStore)
        
        XCTAssertEqual(sut.primaryButtonTitle, "Save Preset")
    }
    
    func test_createMode_primaryAction_savesPreset() {
        sut = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: mockPresetStore)
        sut.presetName = "My New Preset"
        sut.currentConfig.questionCount = 20
        
        let result = sut.performPrimaryAction()
        
        if case .presetSaved = result {
            XCTAssertEqual(mockPresetStore.allPresets.count, 1)
            XCTAssertEqual(mockPresetStore.allPresets.first?.name, "My New Preset")
            XCTAssertEqual(mockPresetStore.allPresets.first?.config.questionCount, 20)
        } else {
            XCTFail("Expected presetSaved result")
        }
    }
    
    func test_createMode_primaryAction_returnsToSelection() {
        sut = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: mockPresetStore)
        sut.presetName = "Test Preset"
        
        let result = sut.performPrimaryAction()
        
        XCTAssertEqual(result, .presetSaved)
    }
    
    func test_editMode_showsPresetNameField() {
        let existingPreset = CustomChordDrillPreset(name: "Existing", config: .default)
        mockPresetStore.savePreset(existingPreset)
        sut = ChordDrillSetupViewModelNew(mode: .editPreset(existingPreset), presetStore: mockPresetStore)
        
        XCTAssertTrue(sut.showsPresetNameField)
    }
    
    func test_editMode_prefilledPresetName() {
        let existingPreset = CustomChordDrillPreset(name: "Original Name", config: .default)
        mockPresetStore.savePreset(existingPreset)
        sut = ChordDrillSetupViewModelNew(mode: .editPreset(existingPreset), presetStore: mockPresetStore)
        
        XCTAssertEqual(sut.presetName, "Original Name")
    }
    
    func test_editMode_showsSaveChangesButton() {
        let existingPreset = CustomChordDrillPreset(name: "Existing", config: .default)
        mockPresetStore.savePreset(existingPreset)
        sut = ChordDrillSetupViewModelNew(mode: .editPreset(existingPreset), presetStore: mockPresetStore)
        
        XCTAssertEqual(sut.primaryButtonTitle, "Save Changes")
    }
    
    func test_editMode_primaryAction_updatesExistingPreset() {
        var existingPreset = CustomChordDrillPreset(name: "Original", config: .default)
        existingPreset.config.questionCount = 10
        mockPresetStore.savePreset(existingPreset)
        
        sut = ChordDrillSetupViewModelNew(mode: .editPreset(existingPreset), presetStore: mockPresetStore)
        sut.presetName = "Updated Name"
        sut.currentConfig.questionCount = 25
        
        _ = sut.performPrimaryAction()
        
        let updated = mockPresetStore.getPreset(withID: existingPreset.id)
        XCTAssertEqual(updated?.name, "Updated Name")
        XCTAssertEqual(updated?.config.questionCount, 25)
    }
}

// MARK: - Chord Difficulty Tests (NO EXPERT)

@MainActor
final class ChordDrillSetupChordDifficultyTests: XCTestCase {
    
    var sut: ChordDrillSetupViewModelNew!
    var mockPresetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "SetupChordDifficultyTests")!
        testDefaults.removePersistentDomain(forName: "SetupChordDifficultyTests")
        mockPresetStore = CustomPresetStore(userDefaults: testDefaults)
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
    }
    
    override func tearDown() {
        mockPresetStore.deleteAllPresets()
        sut = nil
        mockPresetStore = nil
        super.tearDown()
    }
    
    func test_chordDifficulty_hasNoExpertOption() {
        let availableDifficulties = sut.availableChordDifficulties
        
        XCTAssertFalse(availableDifficulties.contains(.expert))
    }
    
    func test_chordDifficulty_hasBeginnerOption() {
        XCTAssertTrue(sut.availableChordDifficulties.contains(.beginner))
    }
    
    func test_chordDifficulty_hasIntermediateOption() {
        XCTAssertTrue(sut.availableChordDifficulties.contains(.intermediate))
    }
    
    func test_chordDifficulty_hasAdvancedOption() {
        XCTAssertTrue(sut.availableChordDifficulties.contains(.advanced))
    }
    
    func test_chordDifficulty_hasCustomOption() {
        XCTAssertTrue(sut.availableChordDifficulties.contains(.custom))
    }
    
    func test_chordDifficulty_hasExactlyFourOptions() {
        XCTAssertEqual(sut.availableChordDifficulties.count, 4)
    }
    
    func test_chordDifficulty_beginner_includesBasicTriads() {
        sut.currentConfig.difficulty = .beginner
        let chords = sut.chordsForCurrentDifficulty
        
        XCTAssertTrue(chords.contains(""))    // Major
        XCTAssertTrue(chords.contains("m"))   // Minor
        XCTAssertTrue(chords.contains("dim")) // Diminished
        XCTAssertTrue(chords.contains("aug")) // Augmented
    }
    
    func test_chordDifficulty_intermediate_includesSeventhChords() {
        sut.currentConfig.difficulty = .intermediate
        let chords = sut.chordsForCurrentDifficulty
        
        XCTAssertTrue(chords.contains("7"))     // Dom7
        XCTAssertTrue(chords.contains("maj7"))  // Maj7
        XCTAssertTrue(chords.contains("m7"))    // Min7
        XCTAssertTrue(chords.contains("6"))     // 6th
    }
    
    func test_chordDifficulty_advanced_includesAlteredChords() {
        sut.currentConfig.difficulty = .advanced
        let chords = sut.chordsForCurrentDifficulty
        
        // Advanced should include complex altered chords
        XCTAssertTrue(chords.contains("7b9") || chords.count > 15, "Advanced should have many chord types")
    }
    
    func test_chordDifficulty_custom_showsChordPicker() {
        sut.currentConfig.difficulty = .custom
        
        XCTAssertTrue(sut.showsChordTypePicker)
    }
    
    func test_chordDifficulty_notCustom_hidesChordPicker() {
        sut.currentConfig.difficulty = .beginner
        XCTAssertFalse(sut.showsChordTypePicker)
        
        sut.currentConfig.difficulty = .intermediate
        XCTAssertFalse(sut.showsChordTypePicker)
        
        sut.currentConfig.difficulty = .advanced
        XCTAssertFalse(sut.showsChordTypePicker)
    }
    
    func test_chordDifficulty_selectCustom_allowsIndividualChordSelection() {
        sut.currentConfig.difficulty = .custom
        sut.currentConfig.chordTypes = []
        
        sut.toggleChordType("7")
        sut.toggleChordType("maj7")
        
        XCTAssertTrue(sut.currentConfig.chordTypes.contains("7"))
        XCTAssertTrue(sut.currentConfig.chordTypes.contains("maj7"))
    }
}

// MARK: - Key Difficulty Tests (NO EXPERT)

@MainActor
final class ChordDrillSetupKeyDifficultyTests: XCTestCase {
    
    var sut: ChordDrillSetupViewModelNew!
    var mockPresetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "SetupKeyDifficultyTests")!
        testDefaults.removePersistentDomain(forName: "SetupKeyDifficultyTests")
        mockPresetStore = CustomPresetStore(userDefaults: testDefaults)
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
    }
    
    override func tearDown() {
        mockPresetStore.deleteAllPresets()
        sut = nil
        mockPresetStore = nil
        super.tearDown()
    }
    
    func test_keyDifficulty_hasNoExpertOption() {
        let availableDifficulties = sut.availableKeyDifficulties
        
        XCTAssertFalse(availableDifficulties.contains(.expert))
    }
    
    func test_keyDifficulty_hasEasyOption() {
        XCTAssertTrue(sut.availableKeyDifficulties.contains(.easy))
    }
    
    func test_keyDifficulty_hasMediumOption() {
        XCTAssertTrue(sut.availableKeyDifficulties.contains(.medium))
    }
    
    func test_keyDifficulty_hasAllOption() {
        XCTAssertTrue(sut.availableKeyDifficulties.contains(.all))
    }
    
    func test_keyDifficulty_hasCustomOption() {
        XCTAssertTrue(sut.availableKeyDifficulties.contains(.custom))
    }
    
    func test_keyDifficulty_hasExactlyFourOptions() {
        XCTAssertEqual(sut.availableKeyDifficulties.count, 4)
    }
    
    func test_keyDifficulty_easy_uses5Keys() {
        sut.currentConfig.keyDifficulty = .easy
        let keys = sut.keysForCurrentDifficulty
        
        XCTAssertEqual(keys.count, 5)
        XCTAssertTrue(keys.contains("C"))
        XCTAssertTrue(keys.contains("G"))
        XCTAssertTrue(keys.contains("D"))
        XCTAssertTrue(keys.contains("F"))
        XCTAssertTrue(keys.contains("Bb"))
    }
    
    func test_keyDifficulty_medium_uses9Keys() {
        sut.currentConfig.keyDifficulty = .medium
        let keys = sut.keysForCurrentDifficulty
        
        XCTAssertEqual(keys.count, 9)
        // Should include easy keys plus more
        XCTAssertTrue(keys.contains("C"))
        XCTAssertTrue(keys.contains("A"))
        XCTAssertTrue(keys.contains("E"))
        XCTAssertTrue(keys.contains("Eb"))
        XCTAssertTrue(keys.contains("Ab"))
    }
    
    func test_keyDifficulty_all_uses12Keys() {
        sut.currentConfig.keyDifficulty = .all
        let keys = sut.keysForCurrentDifficulty
        
        XCTAssertEqual(keys.count, 12)
    }
    
    func test_keyDifficulty_custom_showsKeyPicker() {
        sut.currentConfig.keyDifficulty = .custom
        
        XCTAssertTrue(sut.showsKeyPicker)
    }
    
    func test_keyDifficulty_notCustom_hidesKeyPicker() {
        sut.currentConfig.keyDifficulty = .easy
        XCTAssertFalse(sut.showsKeyPicker)
        
        sut.currentConfig.keyDifficulty = .medium
        XCTAssertFalse(sut.showsKeyPicker)
        
        sut.currentConfig.keyDifficulty = .all
        XCTAssertFalse(sut.showsKeyPicker)
    }
    
    func test_keyDifficulty_selectCustom_allowsIndividualKeySelection() {
        sut.currentConfig.keyDifficulty = .custom
        sut.currentConfig.customKeys = []
        
        sut.toggleKey("C")
        sut.toggleKey("G")
        sut.toggleKey("F#")
        
        XCTAssertTrue(sut.currentConfig.customKeys?.contains("C") ?? false)
        XCTAssertTrue(sut.currentConfig.customKeys?.contains("G") ?? false)
        XCTAssertTrue(sut.currentConfig.customKeys?.contains("F#") ?? false)
    }
}

// MARK: - Question Type Tests

@MainActor
final class ChordDrillSetupQuestionTypeTests: XCTestCase {
    
    var sut: ChordDrillSetupViewModelNew!
    var mockPresetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "SetupQuestionTypeTests")!
        testDefaults.removePersistentDomain(forName: "SetupQuestionTypeTests")
        mockPresetStore = CustomPresetStore(userDefaults: testDefaults)
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
    }
    
    override func tearDown() {
        mockPresetStore.deleteAllPresets()
        sut = nil
        mockPresetStore = nil
        super.tearDown()
    }
    
    func test_questionTypes_allowsMultipleSelection() {
        sut.currentConfig.questionTypes = [.allTones]
        
        sut.toggleQuestionType(.singleTone)
        
        XCTAssertTrue(sut.currentConfig.questionTypes.contains(.allTones))
        XCTAssertTrue(sut.currentConfig.questionTypes.contains(.singleTone))
    }
    
    func test_questionTypes_requiresAtLeastOne() {
        sut.currentConfig.questionTypes = [.allTones]
        
        // Try to remove the last one
        sut.toggleQuestionType(.allTones)
        
        // Should still have at least one
        XCTAssertFalse(sut.currentConfig.questionTypes.isEmpty)
    }
    
    func test_questionTypes_defaultsToAllTones() {
        // Default config should include allTones
        let defaultConfig = ChordDrillConfig.default
        XCTAssertTrue(defaultConfig.questionTypes.contains(.allTones) || defaultConfig.questionTypes.contains(.singleTone))
    }
    
    func test_questionTypes_canToggleOff() {
        sut.currentConfig.questionTypes = [.allTones, .singleTone]
        
        sut.toggleQuestionType(.singleTone)
        
        XCTAssertFalse(sut.currentConfig.questionTypes.contains(.singleTone))
        XCTAssertTrue(sut.currentConfig.questionTypes.contains(.allTones))
    }
}

// MARK: - Validation Tests

@MainActor
final class ChordDrillSetupValidationTests: XCTestCase {
    
    var sut: ChordDrillSetupViewModelNew!
    var mockPresetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "SetupValidationTests")!
        testDefaults.removePersistentDomain(forName: "SetupValidationTests")
        mockPresetStore = CustomPresetStore(userDefaults: testDefaults)
    }
    
    override func tearDown() {
        mockPresetStore.deleteAllPresets()
        sut = nil
        mockPresetStore = nil
        super.tearDown()
    }
    
    func test_createMode_requiresPresetName() {
        sut = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: mockPresetStore)
        sut.presetName = ""
        
        XCTAssertFalse(sut.canPerformPrimaryAction)
    }
    
    func test_createMode_validWithPresetName() {
        sut = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: mockPresetStore)
        sut.presetName = "Valid Name"
        
        XCTAssertTrue(sut.canPerformPrimaryAction)
    }
    
    func test_createMode_preventsDuplicatePresetName() {
        let existing = CustomChordDrillPreset(name: "Existing", config: .default)
        mockPresetStore.savePreset(existing)
        
        sut = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: mockPresetStore)
        sut.presetName = "Existing"
        
        XCTAssertFalse(sut.canPerformPrimaryAction)
        XCTAssertEqual(sut.validationError, "A preset with this name already exists")
    }
    
    func test_adHocMode_doesNotRequirePresetName() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        sut.presetName = ""
        
        XCTAssertTrue(sut.canPerformPrimaryAction)
    }
    
    func test_customChordDifficulty_requiresAtLeastOneChord() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        sut.currentConfig.difficulty = .custom
        sut.currentConfig.chordTypes = []
        
        XCTAssertFalse(sut.canPerformPrimaryAction)
    }
    
    func test_customChordDifficulty_validWithChords() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        sut.currentConfig.difficulty = .custom
        sut.currentConfig.chordTypes = ["7", "maj7"]
        
        XCTAssertTrue(sut.canPerformPrimaryAction)
    }
    
    func test_customKeyDifficulty_requiresAtLeastOneKey() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        sut.currentConfig.keyDifficulty = .custom
        sut.currentConfig.customKeys = []
        
        XCTAssertFalse(sut.canPerformPrimaryAction)
    }
    
    func test_customKeyDifficulty_validWithKeys() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        sut.currentConfig.keyDifficulty = .custom
        sut.currentConfig.customKeys = ["C", "G"]
        
        XCTAssertTrue(sut.canPerformPrimaryAction)
    }
    
    func test_requiresAtLeastOneQuestionType() {
        sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        sut.currentConfig.questionTypes = []
        
        XCTAssertFalse(sut.canPerformPrimaryAction)
    }
}

// MARK: - ViewModel Performance & Stability Tests

@MainActor
final class ChordDrillSetupViewModelPerformanceTests: XCTestCase {
    
    var mockPresetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "SetupPerformanceTests")!
        testDefaults.removePersistentDomain(forName: "SetupPerformanceTests")
        mockPresetStore = CustomPresetStore(userDefaults: testDefaults)
    }
    
    override func tearDown() {
        mockPresetStore.deleteAllPresets()
        mockPresetStore = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Speed Tests
    
    func test_viewModel_initializesQuickly() {
        // ViewModel should initialize in under 50ms
        // This catches issues with heavy initialization
        let start = CFAbsoluteTimeGetCurrent()
        
        let _ = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000 // milliseconds
        XCTAssertLessThan(elapsed, 50, "ViewModel initialization took \(elapsed)ms, should be < 50ms")
    }
    
    func test_viewModel_multipleInitializationsAreFast() {
        // Simulates what happens if SwiftUI re-creates ViewModel
        // This should still be fast due to cached data
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<10 {
            let _ = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        }
        
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        XCTAssertLessThan(elapsed, 200, "10 ViewModel initializations took \(elapsed)ms, should be < 200ms")
    }
    
    // MARK: - Computed Property Performance
    
    func test_allChordTypes_accessIsFast() {
        let sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        
        let start = CFAbsoluteTimeGetCurrent()
        
        // Simulate multiple accesses during render
        for _ in 0..<100 {
            let _ = sut.allChordTypes
        }
        
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        XCTAssertLessThan(elapsed, 50, "100 allChordTypes accesses took \(elapsed)ms, should be < 50ms")
    }
    
    func test_allKeys_accessIsFast() {
        let sut = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: mockPresetStore)
        
        let start = CFAbsoluteTimeGetCurrent()
        
        for _ in 0..<100 {
            let _ = sut.allKeys
        }
        
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        XCTAssertLessThan(elapsed, 10, "100 allKeys accesses took \(elapsed)ms, should be < 10ms")
    }
    
    // MARK: - Text Input Responsiveness Tests
    
    func test_presetNameChange_doesNotTriggerExpensiveRecomputation() {
        let sut = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: mockPresetStore)
        
        // Warm up
        let _ = sut.allChordTypes
        
        let start = CFAbsoluteTimeGetCurrent()
        
        // Simulate rapid typing
        for i in 0..<50 {
            sut.presetName = "Test\(i)"
            // Access properties that the view would access
            let _ = sut.canPerformPrimaryAction
            let _ = sut.showsPresetNameField
        }
        
        let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
        XCTAssertLessThan(elapsed, 100, "50 name changes with property access took \(elapsed)ms, should be < 100ms")
    }
    
    // MARK: - Memory Stability Tests
    
    func test_viewModel_stateIsPreservedAcrossPropertyAccess() {
        let sut = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: mockPresetStore)
        sut.presetName = "My Preset"
        sut.currentConfig.questionCount = 25
        
        // Access all computed properties (simulating view render)
        let _ = sut.allChordTypes
        let _ = sut.allKeys
        let _ = sut.availableChordDifficulties
        let _ = sut.availableKeyDifficulties
        let _ = sut.canPerformPrimaryAction
        
        // State should be preserved
        XCTAssertEqual(sut.presetName, "My Preset")
        XCTAssertEqual(sut.currentConfig.questionCount, 25)
    }
}

// MARK: - Setup Mode Enum Tests

final class SetupModeTests: XCTestCase {
    
    func test_adHocMode_isEquatable() {
        XCTAssertEqual(SetupMode.adHoc, SetupMode.adHoc)
    }
    
    func test_createPresetMode_isEquatable() {
        XCTAssertEqual(SetupMode.createPreset, SetupMode.createPreset)
    }
    
    func test_editPresetMode_isEquatable() {
        let preset = CustomChordDrillPreset(name: "Test", config: .default)
        XCTAssertEqual(SetupMode.editPreset(preset), SetupMode.editPreset(preset))
    }
    
    func test_differentModes_areNotEqual() {
        XCTAssertNotEqual(SetupMode.adHoc, SetupMode.createPreset)
    }
}

// MARK: - Setup Action Result Tests

final class SetupActionResultTests: XCTestCase {
    
    func test_startDrill_isEquatable() {
        XCTAssertEqual(SetupActionResult.startDrill(.default), SetupActionResult.startDrill(.default))
    }
    
    func test_presetSaved_isEquatable() {
        XCTAssertEqual(SetupActionResult.presetSaved, SetupActionResult.presetSaved)
    }
    
    func test_validationFailed_isEquatable() {
        XCTAssertEqual(SetupActionResult.validationFailed("error"), SetupActionResult.validationFailed("error"))
    }
}

