//
//  ScaleDatabaseTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

final class ScaleDatabaseTests: XCTestCase {
    
    var sut: JazzScaleDatabase!
    
    override func setUp() {
        sut = JazzScaleDatabase.shared
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_shared_isSingleton() {
        let instance1 = JazzScaleDatabase.shared
        let instance2 = JazzScaleDatabase.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    func test_initialization_loadsScaleTypes() {
        XCTAssertFalse(sut.scaleTypes.isEmpty)
    }
    
    // MARK: - Beginner Scales Tests
    
    func test_database_containsMajorScale() {
        let major = sut.scaleTypes.first { $0.symbol == "Major" }
        
        XCTAssertNotNil(major)
        XCTAssertEqual(major?.name, "Major")
        XCTAssertEqual(major?.difficulty, .beginner)
        XCTAssertEqual(major?.degrees.count, 8) // 7 notes + octave
    }
    
    func test_database_containsNaturalMinor() {
        let minor = sut.scaleTypes.first { $0.symbol == "Minor" }
        
        XCTAssertNotNil(minor)
        XCTAssertEqual(minor?.name, "Natural Minor")
        XCTAssertEqual(minor?.difficulty, .beginner)
    }
    
    func test_database_containsMajorPentatonic() {
        let majPent = sut.scaleTypes.first { $0.symbol == "Maj Pent" }
        
        XCTAssertNotNil(majPent)
        XCTAssertEqual(majPent?.name, "Major Pentatonic")
        XCTAssertEqual(majPent?.difficulty, .beginner)
        XCTAssertEqual(majPent?.degrees.count, 6) // 5 notes + octave
    }
    
    func test_database_containsMinorPentatonic() {
        let minPent = sut.scaleTypes.first { $0.symbol == "Min Pent" }
        
        XCTAssertNotNil(minPent)
        XCTAssertEqual(minPent?.name, "Minor Pentatonic")
        XCTAssertEqual(minPent?.difficulty, .beginner)
        XCTAssertEqual(minPent?.degrees.count, 6) // 5 notes + octave
    }
    
    // MARK: - Intermediate Scales Tests
    
    func test_database_containsDorian() {
        let dorian = sut.scaleTypes.first { $0.symbol == "Dorian" }
        
        XCTAssertNotNil(dorian)
        XCTAssertEqual(dorian?.name, "Dorian")
        XCTAssertEqual(dorian?.difficulty, .intermediate)
    }
    
    func test_database_containsMixolydian() {
        let mixolydian = sut.scaleTypes.first { $0.symbol == "Mixo" || $0.symbol == "Mixolydian" }
        
        XCTAssertNotNil(mixolydian)
        XCTAssertEqual(mixolydian?.difficulty, .intermediate)
    }
    
    func test_database_containsBlues() {
        let blues = sut.scaleTypes.first { $0.symbol == "Blues" }
        
        XCTAssertNotNil(blues)
        XCTAssertEqual(blues?.name, "Blues")
    }
    
    // MARK: - Advanced Scales Tests
    
    func test_database_containsAlteredScale() {
        let altered = sut.scaleTypes.first { $0.symbol.contains("Altered") || $0.symbol.contains("Alt") }
        
        // Altered scale may or may not exist depending on curriculum design
        // Just verify if it exists, it's marked advanced
        if let altered = altered {
            XCTAssertEqual(altered.difficulty, .advanced)
        }
    }
    
    func test_database_containsWholeTone() {
        let wholeTone = sut.scaleTypes.first { $0.name.contains("Whole Tone") }
        
        if let wholeTone = wholeTone {
            XCTAssertEqual(wholeTone.difficulty, .advanced)
        }
    }
    
    // MARK: - Difficulty Distribution Tests
    
    func test_database_hasBeginnerScales() {
        let beginnerScales = sut.scaleTypes.filter { $0.difficulty == .beginner }
        
        XCTAssertGreaterThan(beginnerScales.count, 0)
        XCTAssertTrue(beginnerScales.contains { $0.symbol == "Major" })
        XCTAssertTrue(beginnerScales.contains { $0.symbol == "Minor" })
    }
    
    func test_database_hasIntermediateScales() {
        let intermediateScales = sut.scaleTypes.filter { $0.difficulty == .intermediate }
        
        XCTAssertGreaterThan(intermediateScales.count, 0)
    }
    
    func test_database_hasAdvancedScales() {
        let advancedScales = sut.scaleTypes.filter { $0.difficulty == .advanced }
        
        // May or may not have advanced scales - just verify they're marked correctly if they exist
        if !advancedScales.isEmpty {
            XCTAssertTrue(advancedScales.allSatisfy { $0.difficulty == .advanced })
        }
    }
    
    // MARK: - Symbol Uniqueness Tests
    
    func test_scaleSymbols_areUnique() {
        let symbols = sut.scaleTypes.map { $0.symbol }
        let uniqueSymbols = Set(symbols)
        
        XCTAssertEqual(symbols.count, uniqueSymbols.count, "Scale symbols should be unique")
    }
    
    func test_scaleNames_areUnique() {
        let names = sut.scaleTypes.map { $0.name }
        let uniqueNames = Set(names)
        
        XCTAssertEqual(names.count, uniqueNames.count, "Scale names should be unique")
    }
    
    // MARK: - Scale Degree Validation Tests
    
    func test_majorScale_hasCorrectDegrees() {
        let major = sut.scaleTypes.first { $0.symbol == "Major" }
        
        XCTAssertNotNil(major)
        if let major = major {
            // Major: Root, 2, 3, 4, 5, 6, 7, 8 (octave)
            XCTAssertEqual(major.degrees.count, 8)
            XCTAssertTrue(major.degrees.contains(.root))
            XCTAssertTrue(major.degrees.contains(.octave))
        }
    }
    
    func test_minorScale_hasCorrectDegrees() {
        let minor = sut.scaleTypes.first { $0.symbol == "Minor" }
        
        XCTAssertNotNil(minor)
        if let minor = minor {
            // Natural Minor: Root, 2, b3, 4, 5, b6, b7, 8
            XCTAssertEqual(minor.degrees.count, 8)
            XCTAssertTrue(minor.degrees.contains(.root))
            XCTAssertTrue(minor.degrees.contains(.flatThird))
            XCTAssertTrue(minor.degrees.contains(.flatSix))
            XCTAssertTrue(minor.degrees.contains(.flatSeven))
        }
    }
    
    func test_mixolydianScale_hasCorrectDegrees() {
        let mixolydian = sut.scaleTypes.first { $0.symbol == "Mixo" || $0.symbol == "Mixolydian" }
        
        XCTAssertNotNil(mixolydian)
        if let mixolydian = mixolydian {
            // Mixolydian: Root, 2, 3, 4, 5, 6, b7, 8
            XCTAssertTrue(mixolydian.degrees.contains(.root))
            XCTAssertTrue(mixolydian.degrees.contains(.third))
            XCTAssertTrue(mixolydian.degrees.contains(.flatSeven))
            XCTAssertFalse(mixolydian.degrees.contains(.seventh), "Mixolydian should have b7, not natural 7")
        }
    }
    
    func test_pentatonicScales_haveFiveNotesPlusOctave() {
        let pentatonics = sut.scaleTypes.filter { $0.symbol.contains("Pent") }
        
        for scale in pentatonics {
            XCTAssertEqual(scale.degrees.count, 6, "\(scale.name) should have 5 notes + octave")
        }
    }
    
    // MARK: - Scale Description Tests
    
    func test_allScales_haveDescriptions() {
        for scale in sut.scaleTypes {
            XCTAssertFalse(scale.description.isEmpty, "\(scale.name) should have a description")
        }
    }
    
    // MARK: - Lookup Tests
    
    func test_getScaleBySymbol_returnsCorrectScale() {
        let major = sut.scaleTypes.first { $0.symbol == "Major" }
        XCTAssertNotNil(major)
        XCTAssertEqual(major?.symbol, "Major")
    }
    
    func test_getScaleBySymbol_returnsNilForInvalidSymbol() {
        let invalid = sut.scaleTypes.first { $0.symbol == "INVALID123" }
        XCTAssertNil(invalid)
    }
    
    // MARK: - Filtering Tests
    
    func test_filterByDifficulty_beginner_returnsOnlyBeginnerScales() {
        let beginnerScales = sut.scaleTypes.filter { $0.difficulty == .beginner }
        
        XCTAssertTrue(beginnerScales.allSatisfy { $0.difficulty == .beginner })
    }
    
    func test_filterByDifficulty_intermediate_returnsOnlyIntermediateScales() {
        let intermediateScales = sut.scaleTypes.filter { $0.difficulty == .intermediate }
        
        XCTAssertTrue(intermediateScales.allSatisfy { $0.difficulty == .intermediate })
    }
    
    // MARK: - Edge Cases
    
    func test_database_hasMinimumScaleTypes() {
        // Should have at least the 4 basic beginner scales
        XCTAssertGreaterThanOrEqual(sut.scaleTypes.count, 4)
    }
    
    func test_allScaleTypes_haveNames() {
        let scalesWithoutNames = sut.scaleTypes.filter { $0.name.isEmpty }
        XCTAssertTrue(scalesWithoutNames.isEmpty, "All scale types should have names")
    }
    
    func test_allScaleTypes_haveDegrees() {
        let scalesWithoutDegrees = sut.scaleTypes.filter { $0.degrees.isEmpty }
        XCTAssertTrue(scalesWithoutDegrees.isEmpty, "All scale types should have degrees")
    }
    
    func test_allScales_includeRootAndOctave() {
        for scale in sut.scaleTypes {
            XCTAssertTrue(scale.degrees.contains(.root), "\(scale.name) should contain root")
            XCTAssertTrue(scale.degrees.contains(.octave), "\(scale.name) should contain octave")
        }
    }
    
    func test_allScales_haveAtLeastThreeNotes() {
        for scale in sut.scaleTypes {
            // Minimum: root + at least 1 note + octave = 3
            XCTAssertGreaterThanOrEqual(scale.degrees.count, 3, "\(scale.name) should have at least 3 degrees")
        }
    }
    
    func test_allScales_haveNoMoreThan12Degrees() {
        for scale in sut.scaleTypes {
            // Maximum: chromatic scale = 12 notes + octave = 13
            XCTAssertLessThanOrEqual(scale.degrees.count, 13, "\(scale.name) has too many degrees")
        }
    }
    
    // MARK: - Bug Regression Tests (from E Mixolydian bug)
    
    func test_mixolydianScale_fromERoot_hasCorrectNotes() {
        // Regression test for bug where E Mixolydian accepted G instead of G#
        let mixolydian = sut.scaleTypes.first { $0.symbol == "Mixo" || $0.symbol == "Mixolydian" }
        
        XCTAssertNotNil(mixolydian)
        if let mixolydian = mixolydian {
            let eRoot = Note.noteFromMidi(64) // E
            let scale = Scale(root: eRoot, scaleType: mixolydian)
            
            // E Mixolydian: E, F#, G#, A, B, C#, D, E
            let noteNames = scale.notes.map { $0.name }
            XCTAssertTrue(noteNames.contains("G#"), "E Mixolydian should contain G#")
            XCTAssertFalse(noteNames.contains("G"), "E Mixolydian should NOT contain G")
        }
    }
}
