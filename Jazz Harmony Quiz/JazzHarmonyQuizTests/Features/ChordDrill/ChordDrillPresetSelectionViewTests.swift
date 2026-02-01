import XCTest
@testable import JazzHarmonyQuiz

// MARK: - Preset Selection View Model Tests

@MainActor
final class ChordDrillPresetSelectionViewModelTests: XCTestCase {
    
    var sut: ChordDrillPresetSelectionViewModel!
    var mockPresetStore: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        let testDefaults = UserDefaults(suiteName: "PresetSelectionViewModelTests")!
        testDefaults.removePersistentDomain(forName: "PresetSelectionViewModelTests")
        mockPresetStore = CustomPresetStore(userDefaults: testDefaults)
        sut = ChordDrillPresetSelectionViewModel(presetStore: mockPresetStore)
    }
    
    override func tearDown() {
        mockPresetStore.deleteAllPresets()
        UserDefaults.standard.removePersistentDomain(forName: "PresetSelectionViewModelTests")
        sut = nil
        mockPresetStore = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func test_initialState_showsFourBuiltInPresets() {
        XCTAssertEqual(sut.builtInPresets.count, 4)
    }
    
    func test_initialState_builtInPresetsInCorrectOrder() {
        XCTAssertEqual(sut.builtInPresets[0], .basicTriads)
        XCTAssertEqual(sut.builtInPresets[1], .seventhAndSixthChords)
        XCTAssertEqual(sut.builtInPresets[2], .fullWorkout)
        XCTAssertEqual(sut.builtInPresets[3], .customAdHoc)
    }
    
    func test_initialState_showsNoSavedPresetsWhenEmpty() {
        XCTAssertTrue(sut.savedPresets.isEmpty)
    }
    
    func test_initialState_showsSavedPresetsWhenPresent() {
        // Given
        let preset = CustomChordDrillPreset(name: "My Preset", config: .default)
        mockPresetStore.savePreset(preset)
        
        // When
        sut.refreshSavedPresets()
        
        // Then
        XCTAssertEqual(sut.savedPresets.count, 1)
        XCTAssertEqual(sut.savedPresets.first?.name, "My Preset")
    }
    
    // MARK: - Built-In Preset Tests
    
    func test_basicTriads_hasCorrectName() {
        XCTAssertEqual(BuiltInChordDrillPreset.basicTriads.name, "Basic Triads")
    }
    
    func test_basicTriads_hasCorrectDescription() {
        XCTAssertEqual(BuiltInChordDrillPreset.basicTriads.description, "Perfect for beginners. Basic triads in common keys.")
    }
    
    func test_basicTriads_doesNotOpenSetup() {
        XCTAssertFalse(BuiltInChordDrillPreset.basicTriads.opensSetup)
    }
    
    func test_basicTriads_hasConfig() {
        XCTAssertNotNil(BuiltInChordDrillPreset.basicTriads.config)
    }
    
    func test_seventhAndSixthChords_hasCorrectName() {
        XCTAssertEqual(BuiltInChordDrillPreset.seventhAndSixthChords.name, "7th & 6th Chords")
    }
    
    func test_seventhAndSixthChords_hasCorrectDescription() {
        XCTAssertEqual(BuiltInChordDrillPreset.seventhAndSixthChords.description, "Jazz essentials. Seventh and sixth chords.")
    }
    
    func test_seventhAndSixthChords_doesNotOpenSetup() {
        XCTAssertFalse(BuiltInChordDrillPreset.seventhAndSixthChords.opensSetup)
    }
    
    func test_fullWorkout_hasCorrectName() {
        XCTAssertEqual(BuiltInChordDrillPreset.fullWorkout.name, "Full Workout")
    }
    
    func test_fullWorkout_hasCorrectDescription() {
        XCTAssertEqual(BuiltInChordDrillPreset.fullWorkout.description, "Complete challenge. All chords, all keys.")
    }
    
    func test_fullWorkout_doesNotOpenSetup() {
        XCTAssertFalse(BuiltInChordDrillPreset.fullWorkout.opensSetup)
    }
    
    func test_customAdHoc_hasCorrectName() {
        XCTAssertEqual(BuiltInChordDrillPreset.customAdHoc.name, "Custom Ad-Hoc")
    }
    
    func test_customAdHoc_hasCorrectDescription() {
        XCTAssertEqual(BuiltInChordDrillPreset.customAdHoc.description, "Configure a custom drill without saving.")
    }
    
    func test_customAdHoc_opensSetup() {
        XCTAssertTrue(BuiltInChordDrillPreset.customAdHoc.opensSetup)
    }
    
    func test_customAdHoc_hasNoConfig() {
        XCTAssertNil(BuiltInChordDrillPreset.customAdHoc.config)
    }
    
    // MARK: - Built-In Preset Tap Tests
    
    func test_selectBuiltInPreset_basicTriads_startsDrillImmediately() {
        // When
        let action = sut.selectBuiltInPreset(.basicTriads)
        
        // Then
        XCTAssertEqual(action, .startDrill(BuiltInChordDrillPreset.basicTriads.config!))
    }
    
    func test_selectBuiltInPreset_seventhAndSixthChords_startsDrillImmediately() {
        let action = sut.selectBuiltInPreset(.seventhAndSixthChords)
        XCTAssertEqual(action, .startDrill(BuiltInChordDrillPreset.seventhAndSixthChords.config!))
    }
    
    func test_selectBuiltInPreset_fullWorkout_startsDrillImmediately() {
        let action = sut.selectBuiltInPreset(.fullWorkout)
        XCTAssertEqual(action, .startDrill(BuiltInChordDrillPreset.fullWorkout.config!))
    }
    
    func test_selectBuiltInPreset_customAdHoc_opensSetupScreen() {
        let action = sut.selectBuiltInPreset(.customAdHoc)
        XCTAssertEqual(action, .openSetup(.adHoc))
    }
    
    // MARK: - Built-In Preset Config Tests
    
    func test_basicTriads_config_usesBeginnerChords() {
        let config = BuiltInChordDrillPreset.basicTriads.config!
        XCTAssertEqual(config.difficulty, .beginner)
    }
    
    func test_basicTriads_config_usesEasyKeys() {
        let config = BuiltInChordDrillPreset.basicTriads.config!
        XCTAssertEqual(config.keyDifficulty, .easy)
    }
    
    func test_basicTriads_config_uses10Questions() {
        let config = BuiltInChordDrillPreset.basicTriads.config!
        XCTAssertEqual(config.questionCount, 10)
    }
    
    func test_basicTriads_config_usesAllTonesQuestionType() {
        let config = BuiltInChordDrillPreset.basicTriads.config!
        XCTAssertTrue(config.questionTypes.contains(.allTones))
    }
    
    func test_seventhAndSixthChords_config_usesIntermediateChords() {
        let config = BuiltInChordDrillPreset.seventhAndSixthChords.config!
        XCTAssertEqual(config.difficulty, .intermediate)
    }
    
    func test_seventhAndSixthChords_config_usesMediumKeys() {
        let config = BuiltInChordDrillPreset.seventhAndSixthChords.config!
        XCTAssertEqual(config.keyDifficulty, .medium)
    }
    
    func test_fullWorkout_config_usesAdvancedChords() {
        let config = BuiltInChordDrillPreset.fullWorkout.config!
        XCTAssertEqual(config.difficulty, .advanced)
    }
    
    func test_fullWorkout_config_usesAllKeys() {
        let config = BuiltInChordDrillPreset.fullWorkout.config!
        XCTAssertEqual(config.keyDifficulty, .all)
    }
    
    func test_fullWorkout_config_uses15Questions() {
        let config = BuiltInChordDrillPreset.fullWorkout.config!
        XCTAssertEqual(config.questionCount, 15)
    }
    
    func test_fullWorkout_config_usesAllQuestionTypes() {
        let config = BuiltInChordDrillPreset.fullWorkout.config!
        XCTAssertTrue(config.questionTypes.contains(.singleTone))
        XCTAssertTrue(config.questionTypes.contains(.allTones))
        XCTAssertTrue(config.questionTypes.contains(.auralQuality))
        XCTAssertTrue(config.questionTypes.contains(.auralSpelling))
    }
    
    // MARK: - Saved Preset Tests
    
    func test_selectSavedPreset_startsDrillImmediately() {
        // Given
        let preset = CustomChordDrillPreset(name: "My Preset", config: .default)
        mockPresetStore.savePreset(preset)
        sut.refreshSavedPresets()
        
        // When
        let action = sut.selectSavedPreset(sut.savedPresets.first!)
        
        // Then
        if case .startDrill(let config) = action {
            XCTAssertEqual(config, preset.config)
        } else {
            XCTFail("Expected startDrill action")
        }
    }
    
    func test_selectSavedPreset_usesCorrectConfig() {
        // Given
        var customConfig = ChordDrillConfig.default
        customConfig.questionCount = 25
        customConfig.difficulty = .advanced
        let preset = CustomChordDrillPreset(name: "Advanced Practice", config: customConfig)
        mockPresetStore.savePreset(preset)
        sut.refreshSavedPresets()
        
        // When
        let action = sut.selectSavedPreset(sut.savedPresets.first!)
        
        // Then
        if case .startDrill(let config) = action {
            XCTAssertEqual(config.questionCount, 25)
            XCTAssertEqual(config.difficulty, .advanced)
        } else {
            XCTFail("Expected startDrill action")
        }
    }
    
    func test_deleteSavedPreset_removesFromList() {
        // Given
        let preset = CustomChordDrillPreset(name: "To Delete", config: .default)
        mockPresetStore.savePreset(preset)
        sut.refreshSavedPresets()
        XCTAssertEqual(sut.savedPresets.count, 1)
        
        // When
        sut.deleteSavedPreset(preset)
        
        // Then
        XCTAssertEqual(sut.savedPresets.count, 0)
    }
    
    func test_tapCreatePreset_opensSetupScreen() {
        let action = sut.createNewPreset()
        XCTAssertEqual(action, .openSetup(.createPreset))
    }
}

// MARK: - Preset Selection Action Tests

final class PresetSelectionActionTests: XCTestCase {
    
    func test_action_startDrill_isEquatable() {
        let config1 = ChordDrillConfig.default
        let config2 = ChordDrillConfig.default
        
        XCTAssertEqual(PresetSelectionAction.startDrill(config1), PresetSelectionAction.startDrill(config2))
    }
    
    func test_action_openSetup_adHoc_isEquatable() {
        XCTAssertEqual(PresetSelectionAction.openSetup(.adHoc), PresetSelectionAction.openSetup(.adHoc))
    }
    
    func test_action_openSetup_createPreset_isEquatable() {
        XCTAssertEqual(PresetSelectionAction.openSetup(.createPreset), PresetSelectionAction.openSetup(.createPreset))
    }
    
    func test_action_startDrill_notEqualToOpenSetup() {
        let action1 = PresetSelectionAction.startDrill(.default)
        let action2 = PresetSelectionAction.openSetup(.adHoc)
        
        XCTAssertNotEqual(action1, action2)
    }
}

// MARK: - Built-In Preset Enum Tests

final class BuiltInChordDrillPresetTests: XCTestCase {
    
    func test_allCases_hasFourPresets() {
        XCTAssertEqual(BuiltInChordDrillPreset.allCases.count, 4)
    }
    
    func test_allCases_containsExpectedPresets() {
        let cases = BuiltInChordDrillPreset.allCases
        XCTAssertTrue(cases.contains(.basicTriads))
        XCTAssertTrue(cases.contains(.seventhAndSixthChords))
        XCTAssertTrue(cases.contains(.fullWorkout))
        XCTAssertTrue(cases.contains(.customAdHoc))
    }
    
    func test_onlyCustomAdHoc_opensSetup() {
        for preset in BuiltInChordDrillPreset.allCases {
            if preset == .customAdHoc {
                XCTAssertTrue(preset.opensSetup, "\(preset) should open setup")
            } else {
                XCTAssertFalse(preset.opensSetup, "\(preset) should NOT open setup")
            }
        }
    }
    
    func test_allExceptCustomAdHoc_haveConfig() {
        for preset in BuiltInChordDrillPreset.allCases {
            if preset == .customAdHoc {
                XCTAssertNil(preset.config, "\(preset) should have nil config")
            } else {
                XCTAssertNotNil(preset.config, "\(preset) should have a config")
            }
        }
    }
}
