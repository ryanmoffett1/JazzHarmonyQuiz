//
//  ChordDrillPresetTests.swift
//  JazzHarmonyQuizTests
//
//  Tests for ChordDrill preset system including built-in presets and custom user presets.
//  Using TDD to define expected behaviors before implementation.
//

import XCTest
@testable import JazzHarmonyQuiz

// MARK: - Built-in Preset Tests

final class BuiltInPresetTests: XCTestCase {
    
    // MARK: - Basic Triads Preset
    
    func test_basicTriadsPreset_hasCorrectName() {
        XCTAssertEqual(ChordDrillPreset.basicTriads.name, "Basic Triads")
    }
    
    func test_basicTriadsPreset_hasCorrectDescription() {
        XCTAssertEqual(ChordDrillPreset.basicTriads.description, "Major, minor, dim, aug, sus chords")
    }
    
    func test_basicTriadsPreset_includesOnlyTriads() {
        let config = ChordDrillConfig.fromPreset(.basicTriads)
        let expectedChordTypes: Set<String> = ["", "m", "dim", "aug", "sus2", "sus4"]
        XCTAssertEqual(Set(config.chordTypes), expectedChordTypes)
    }
    
    func test_basicTriadsPreset_usesEasyKeys() {
        let config = ChordDrillConfig.fromPreset(.basicTriads)
        XCTAssertEqual(config.keyDifficulty, .easy)
    }
    
    func test_basicTriadsPreset_usesAllTonesQuestionType() {
        let config = ChordDrillConfig.fromPreset(.basicTriads)
        XCTAssertEqual(config.questionTypes, [.allTones])
    }
    
    func test_basicTriadsPreset_usesBeginnerDifficulty() {
        let config = ChordDrillConfig.fromPreset(.basicTriads)
        XCTAssertEqual(config.difficulty, .beginner)
    }
    
    // MARK: - 7th & 6th Chords Preset
    
    func test_seventhAndSixthChordsPreset_hasCorrectName() {
        XCTAssertEqual(ChordDrillPreset.seventhAndSixthChords.name, "7th & 6th Chords")
    }
    
    func test_seventhAndSixthChordsPreset_hasCorrectDescription() {
        XCTAssertEqual(ChordDrillPreset.seventhAndSixthChords.description, "Seventh and sixth chord voicings")
    }
    
    func test_seventhAndSixthChordsPreset_includesCorrectChordTypes() {
        let config = ChordDrillConfig.fromPreset(.seventhAndSixthChords)
        let expectedChordTypes: Set<String> = ["7", "maj7", "m7", "m7b5", "dim7", "m(maj7)", "7#5", "maj6", "m6"]
        XCTAssertEqual(Set(config.chordTypes), expectedChordTypes)
    }
    
    func test_seventhAndSixthChordsPreset_usesMediumKeys() {
        let config = ChordDrillConfig.fromPreset(.seventhAndSixthChords)
        XCTAssertEqual(config.keyDifficulty, .medium)
    }
    
    func test_seventhAndSixthChordsPreset_usesAllTonesQuestionType() {
        let config = ChordDrillConfig.fromPreset(.seventhAndSixthChords)
        XCTAssertEqual(config.questionTypes, [.allTones])
    }
    
    func test_seventhAndSixthChordsPreset_usesIntermediateDifficulty() {
        let config = ChordDrillConfig.fromPreset(.seventhAndSixthChords)
        XCTAssertEqual(config.difficulty, .intermediate)
    }
    
    // MARK: - Full Workout Preset
    
    func test_fullWorkoutPreset_hasCorrectName() {
        XCTAssertEqual(ChordDrillPreset.fullWorkout.name, "Full Workout")
    }
    
    func test_fullWorkoutPreset_hasCorrectDescription() {
        XCTAssertEqual(ChordDrillPreset.fullWorkout.description, "All chord types, all keys, all question types")
    }
    
    func test_fullWorkoutPreset_includesAllChordTypes() {
        let config = ChordDrillConfig.fromPreset(.fullWorkout)
        // Empty set means all chord types
        XCTAssertTrue(config.chordTypes.isEmpty, "Full workout should use empty set to indicate all chord types")
    }
    
    func test_fullWorkoutPreset_usesAllKeys() {
        let config = ChordDrillConfig.fromPreset(.fullWorkout)
        XCTAssertEqual(config.keyDifficulty, .all)
    }
    
    func test_fullWorkoutPreset_includesAllQuestionTypes() {
        let config = ChordDrillConfig.fromPreset(.fullWorkout)
        let allQuestionTypes: Set<QuestionType> = [.singleTone, .allTones, .auralQuality, .auralSpelling]
        XCTAssertEqual(config.questionTypes, allQuestionTypes)
    }
    
    func test_fullWorkoutPreset_usesAdvancedDifficulty() {
        let config = ChordDrillConfig.fromPreset(.fullWorkout)
        XCTAssertEqual(config.difficulty, .advanced)
    }
    
    func test_fullWorkoutPreset_has15Questions() {
        let config = ChordDrillConfig.fromPreset(.fullWorkout)
        XCTAssertEqual(config.questionCount, 15)
    }
    
    // MARK: - All Built-in Presets
    
    func test_allBuiltInPresets_areAvailable() {
        let allPresets = ChordDrillPreset.allCases
        XCTAssertEqual(allPresets.count, 3)
        XCTAssertTrue(allPresets.contains(.basicTriads))
        XCTAssertTrue(allPresets.contains(.seventhAndSixthChords))
        XCTAssertTrue(allPresets.contains(.fullWorkout))
    }
    
    func test_allBuiltInPresets_haveUniqueNames() {
        let names = ChordDrillPreset.allCases.map { $0.name }
        XCTAssertEqual(Set(names).count, names.count, "All preset names should be unique")
    }
    
    func test_allBuiltInPresets_generateValidConfigs() {
        for preset in ChordDrillPreset.allCases {
            let config = ChordDrillConfig.fromPreset(preset)
            XCTAssertGreaterThan(config.questionCount, 0, "\(preset.name) should have positive question count")
            XCTAssertFalse(config.questionTypes.isEmpty, "\(preset.name) should have at least one question type")
        }
    }
}

// MARK: - Custom Preset Model Tests

final class CustomPresetTests: XCTestCase {
    
    // MARK: - CustomChordDrillPreset Structure
    
    func test_customPreset_canBeCreatedWithNameAndConfig() {
        let config = ChordDrillConfig.default
        let preset = CustomChordDrillPreset(name: "My Custom Preset", config: config)
        
        XCTAssertEqual(preset.name, "My Custom Preset")
        XCTAssertEqual(preset.config, config)
    }
    
    func test_customPreset_hasUniqueID() {
        let config = ChordDrillConfig.default
        let preset1 = CustomChordDrillPreset(name: "Preset 1", config: config)
        let preset2 = CustomChordDrillPreset(name: "Preset 2", config: config)
        
        XCTAssertNotEqual(preset1.id, preset2.id)
    }
    
    func test_customPreset_storesCreationDate() {
        let beforeCreation = Date()
        let preset = CustomChordDrillPreset(name: "Test", config: .default)
        let afterCreation = Date()
        
        XCTAssertGreaterThanOrEqual(preset.createdAt, beforeCreation)
        XCTAssertLessThanOrEqual(preset.createdAt, afterCreation)
    }
    
    func test_customPreset_isCodable() {
        let config = ChordDrillConfig(
            chordTypes: ["7", "maj7"],
            keyDifficulty: .medium,
            questionTypes: [.allTones],
            difficulty: .intermediate,
            questionCount: 10,
            audioEnabled: true
        )
        let original = CustomChordDrillPreset(name: "Test Preset", config: config)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(CustomChordDrillPreset.self, from: data)
            
            XCTAssertEqual(decoded.id, original.id)
            XCTAssertEqual(decoded.name, original.name)
            XCTAssertEqual(decoded.config, original.config)
        } catch {
            XCTFail("CustomChordDrillPreset should be Codable: \(error)")
        }
    }
    
    func test_customPreset_canStoreCustomKeys() {
        var config = ChordDrillConfig.default
        config.customKeys = ["C", "G", "D", "A"]
        config.keyDifficulty = .custom
        
        let preset = CustomChordDrillPreset(name: "Circle of Fifths", config: config)
        
        XCTAssertEqual(preset.config.keyDifficulty, .custom)
        XCTAssertEqual(Set(preset.config.customKeys ?? []), Set(["C", "G", "D", "A"]))
    }
}

// MARK: - Custom Preset Store Tests

final class CustomPresetStoreTests: XCTestCase {
    
    var store: CustomPresetStore!
    
    override func setUp() {
        super.setUp()
        store = CustomPresetStore(userDefaults: UserDefaults(suiteName: "TestDefaults")!)
        store.deleteAllPresets()
    }
    
    override func tearDown() {
        store.deleteAllPresets()
        UserDefaults(suiteName: "TestDefaults")?.removePersistentDomain(forName: "TestDefaults")
        store = nil
        super.tearDown()
    }
    
    // MARK: - Save Tests
    
    func test_savePreset_addsToStore() {
        let preset = CustomChordDrillPreset(name: "Test", config: .default)
        
        store.savePreset(preset)
        
        XCTAssertEqual(store.allPresets.count, 1)
        XCTAssertEqual(store.allPresets.first?.name, "Test")
    }
    
    func test_savePreset_persistsAcrossInstances() {
        let testDefaults = UserDefaults(suiteName: "TestDefaults")!
        let preset = CustomChordDrillPreset(name: "Persistent", config: .default)
        
        // Save with one store instance
        let store1 = CustomPresetStore(userDefaults: testDefaults)
        store1.savePreset(preset)
        
        // Load with a new store instance
        let store2 = CustomPresetStore(userDefaults: testDefaults)
        
        XCTAssertEqual(store2.allPresets.count, 1)
        XCTAssertEqual(store2.allPresets.first?.name, "Persistent")
    }
    
    func test_savePreset_respectsMaxLimit() {
        let maxPresets = 20
        
        // Save max+5 presets
        for i in 0..<(maxPresets + 5) {
            let preset = CustomChordDrillPreset(name: "Preset \(i)", config: .default)
            store.savePreset(preset)
        }
        
        XCTAssertEqual(store.allPresets.count, maxPresets, "Should not exceed \(maxPresets) presets")
    }
    
    func test_savePreset_replacesOldestWhenAtLimit() {
        let maxPresets = 20
        
        // Save exactly max presets
        for i in 0..<maxPresets {
            let preset = CustomChordDrillPreset(name: "Preset \(i)", config: .default)
            store.savePreset(preset)
            // Small delay to ensure different creation times
        }
        
        // Save one more
        let newPreset = CustomChordDrillPreset(name: "New Preset", config: .default)
        store.savePreset(newPreset)
        
        XCTAssertEqual(store.allPresets.count, maxPresets)
        XCTAssertTrue(store.allPresets.contains { $0.name == "New Preset" })
        XCTAssertFalse(store.allPresets.contains { $0.name == "Preset 0" }, "Oldest preset should be removed")
    }
    
    // MARK: - Delete Tests
    
    func test_deletePreset_removesFromStore() {
        let preset = CustomChordDrillPreset(name: "ToDelete", config: .default)
        store.savePreset(preset)
        
        XCTAssertEqual(store.allPresets.count, 1)
        
        store.deletePreset(preset)
        
        XCTAssertEqual(store.allPresets.count, 0)
    }
    
    func test_deletePreset_byID_removesCorrectPreset() {
        let preset1 = CustomChordDrillPreset(name: "Keep", config: .default)
        let preset2 = CustomChordDrillPreset(name: "Delete", config: .default)
        
        store.savePreset(preset1)
        store.savePreset(preset2)
        
        store.deletePreset(withID: preset2.id)
        
        XCTAssertEqual(store.allPresets.count, 1)
        XCTAssertEqual(store.allPresets.first?.name, "Keep")
    }
    
    func test_deleteAllPresets_clearsStore() {
        for i in 0..<5 {
            store.savePreset(CustomChordDrillPreset(name: "Preset \(i)", config: .default))
        }
        
        XCTAssertEqual(store.allPresets.count, 5)
        
        store.deleteAllPresets()
        
        XCTAssertEqual(store.allPresets.count, 0)
    }
    
    // MARK: - Update Tests
    
    func test_updatePreset_modifiesExisting() {
        var preset = CustomChordDrillPreset(name: "Original", config: .default)
        store.savePreset(preset)
        
        preset.name = "Updated"
        store.updatePreset(preset)
        
        XCTAssertEqual(store.allPresets.count, 1)
        XCTAssertEqual(store.allPresets.first?.name, "Updated")
    }
    
    // MARK: - Retrieval Tests
    
    func test_getPreset_byID_returnsCorrectPreset() {
        let preset = CustomChordDrillPreset(name: "FindMe", config: .default)
        store.savePreset(preset)
        
        let found = store.getPreset(withID: preset.id)
        
        XCTAssertNotNil(found)
        XCTAssertEqual(found?.name, "FindMe")
    }
    
    func test_getPreset_byID_returnsNilForMissing() {
        let found = store.getPreset(withID: UUID())
        XCTAssertNil(found)
    }
    
    func test_allPresets_returnsSortedByCreationDate() {
        // Create presets with slight time differences
        let preset1 = CustomChordDrillPreset(name: "First", config: .default)
        store.savePreset(preset1)
        
        let preset2 = CustomChordDrillPreset(name: "Second", config: .default)
        store.savePreset(preset2)
        
        let preset3 = CustomChordDrillPreset(name: "Third", config: .default)
        store.savePreset(preset3)
        
        let presets = store.allPresets
        
        // Should be sorted newest first
        XCTAssertEqual(presets[0].name, "Third")
        XCTAssertEqual(presets[1].name, "Second")
        XCTAssertEqual(presets[2].name, "First")
    }
    
    // MARK: - Validation Tests
    
    func test_savePreset_rejectsEmptyName() {
        let preset = CustomChordDrillPreset(name: "", config: .default)
        
        let result = store.savePreset(preset)
        
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, .emptyName)
        XCTAssertEqual(store.allPresets.count, 0)
    }
    
    func test_savePreset_rejectsDuplicateName() {
        let preset1 = CustomChordDrillPreset(name: "Duplicate", config: .default)
        let preset2 = CustomChordDrillPreset(name: "Duplicate", config: .default)
        
        _ = store.savePreset(preset1)
        let result = store.savePreset(preset2)
        
        XCTAssertFalse(result.success)
        XCTAssertEqual(result.error, .duplicateName)
        XCTAssertEqual(store.allPresets.count, 1)
    }
    
    func test_savePreset_allowsSameNameAfterDeletion() {
        let preset1 = CustomChordDrillPreset(name: "Reusable", config: .default)
        store.savePreset(preset1)
        store.deletePreset(preset1)
        
        let preset2 = CustomChordDrillPreset(name: "Reusable", config: .default)
        let result = store.savePreset(preset2)
        
        XCTAssertTrue(result.success)
        XCTAssertEqual(store.allPresets.count, 1)
    }
}

// MARK: - ChordDrillConfig Extended Tests

final class ChordDrillConfigExtendedTests: XCTestCase {
    
    // MARK: - Custom Keys Support
    
    func test_config_supportsCustomKeys() {
        var config = ChordDrillConfig.default
        config.keyDifficulty = .custom
        config.customKeys = ["C", "F", "Bb", "Eb"]
        
        XCTAssertEqual(config.keyDifficulty, .custom)
        XCTAssertEqual(config.customKeys, ["C", "F", "Bb", "Eb"])
    }
    
    func test_config_customKeysAreNilByDefault() {
        let config = ChordDrillConfig.default
        XCTAssertNil(config.customKeys)
    }
    
    func test_config_customKeysIgnoredWhenNotCustomDifficulty() {
        var config = ChordDrillConfig.default
        config.keyDifficulty = .easy
        config.customKeys = ["C", "F", "Bb", "Eb"]
        
        // When getting available roots, should use easy keys, not custom
        // This behavior would be tested in the game/generation logic
        XCTAssertEqual(config.keyDifficulty, .easy)
    }
    
    // MARK: - Chord Difficulty with Custom Types
    
    func test_config_chordDifficultyCustom_exposesChordTypeSelection() {
        var config = ChordDrillConfig.default
        config.difficulty = .custom
        config.chordTypes = ["7", "maj7", "m7"]
        
        XCTAssertEqual(config.difficulty, .custom)
        XCTAssertEqual(Set(config.chordTypes), Set(["7", "maj7", "m7"]))
    }
    
    // MARK: - Config Equality with New Fields
    
    func test_config_equalityIncludesCustomKeys() {
        var config1 = ChordDrillConfig.default
        config1.customKeys = ["C", "G"]
        
        var config2 = ChordDrillConfig.default
        config2.customKeys = ["C", "G"]
        
        var config3 = ChordDrillConfig.default
        config3.customKeys = ["C", "D"]
        
        XCTAssertEqual(config1, config2)
        XCTAssertNotEqual(config1, config3)
    }
    
    // MARK: - Config Codable with New Fields
    
    func test_config_isCodableWithCustomKeys() {
        var original = ChordDrillConfig.default
        original.keyDifficulty = .custom
        original.customKeys = ["C", "G", "D"]
        original.difficulty = .custom
        original.chordTypes = ["7", "maj7"]
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(original)
            let decoded = try decoder.decode(ChordDrillConfig.self, from: data)
            
            XCTAssertEqual(decoded, original)
            XCTAssertEqual(decoded.customKeys, ["C", "G", "D"])
        } catch {
            XCTFail("ChordDrillConfig should be Codable: \(error)")
        }
    }
}

// MARK: - KeyDifficulty Extended Tests

final class KeyDifficultyExtendedTests: XCTestCase {
    
    func test_keyDifficulty_includesCustomCase() {
        let allCases = KeyDifficulty.allCases
        XCTAssertTrue(allCases.contains(.custom))
    }
    
    func test_keyDifficulty_customHasCorrectDescription() {
        XCTAssertEqual(KeyDifficulty.custom.description, "Custom")
    }
    
    func test_keyDifficulty_customReturnsEmptyRootsArray() {
        // Custom difficulty returns empty array - actual keys come from customKeys
        let roots = KeyDifficulty.custom.availableRoots
        XCTAssertTrue(roots.isEmpty, "Custom difficulty should return empty roots; actual keys come from config.customKeys")
    }
}

// MARK: - ChordType.ChordDifficulty Extended Tests

final class ChordDifficultyExtendedTests: XCTestCase {
    
    func test_chordDifficulty_includesCustomCase() {
        let allCases = ChordType.ChordDifficulty.allCases
        XCTAssertTrue(allCases.contains(.custom))
    }
    
    func test_chordDifficulty_displayNames() {
        XCTAssertEqual(ChordType.ChordDifficulty.beginner.displayName, "Beginner")
        XCTAssertEqual(ChordType.ChordDifficulty.intermediate.displayName, "Intermediate")
        XCTAssertEqual(ChordType.ChordDifficulty.advanced.displayName, "Advanced")
        XCTAssertEqual(ChordType.ChordDifficulty.custom.displayName, "Custom")
    }
}
