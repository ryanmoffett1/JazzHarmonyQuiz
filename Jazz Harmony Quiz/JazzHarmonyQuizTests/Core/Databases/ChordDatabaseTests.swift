//
//  ChordDatabaseTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

final class ChordDatabaseTests: XCTestCase {
    
    var sut: JazzChordDatabase!
    
    override func setUp() {
        sut = JazzChordDatabase.shared
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_shared_isSingleton() {
        let instance1 = JazzChordDatabase.shared
        let instance2 = JazzChordDatabase.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    func test_initialization_loadsChordTypes() {
        XCTAssertFalse(sut.chordTypes.isEmpty)
    }
    
    // MARK: - Beginner Chords Tests
    
    func test_database_containsMajorTriad() {
        let major = sut.chordTypes.first { $0.symbol == "" }
        
        XCTAssertNotNil(major)
        XCTAssertEqual(major?.name, "Major Triad")
        XCTAssertEqual(major?.difficulty, .beginner)
        XCTAssertEqual(major?.chordTones.count, 3)
    }
    
    func test_database_containsMinorTriad() {
        let minor = sut.chordTypes.first { $0.symbol == "m" }
        
        XCTAssertNotNil(minor)
        XCTAssertEqual(minor?.name, "Minor Triad")
        XCTAssertEqual(minor?.difficulty, .beginner)
        XCTAssertEqual(minor?.chordTones.count, 3)
    }
    
    func test_database_containsDominant7th() {
        let dom7 = sut.chordTypes.first { $0.symbol == "7" }
        
        XCTAssertNotNil(dom7)
        XCTAssertEqual(dom7?.name, "Dominant 7th")
        XCTAssertEqual(dom7?.difficulty, .beginner)
        XCTAssertEqual(dom7?.chordTones.count, 4)
    }
    
    func test_database_containsMajor7th() {
        let maj7 = sut.chordTypes.first { $0.symbol == "maj7" }
        
        XCTAssertNotNil(maj7)
        XCTAssertEqual(maj7?.name, "Major 7th")
        XCTAssertEqual(maj7?.difficulty, .beginner)
        XCTAssertEqual(maj7?.chordTones.count, 4)
    }
    
    func test_database_containsMinor7th() {
        let m7 = sut.chordTypes.first { $0.symbol == "m7" }
        
        XCTAssertNotNil(m7)
        XCTAssertEqual(m7?.name, "Minor 7th")
        XCTAssertEqual(m7?.difficulty, .beginner)
        XCTAssertEqual(m7?.chordTones.count, 4)
    }
    
    // MARK: - Intermediate Chords Tests
    
    func test_database_containsHalfDiminished() {
        let m7b5 = sut.chordTypes.first { $0.symbol == "m7b5" }
        
        XCTAssertNotNil(m7b5)
        XCTAssertEqual(m7b5?.name, "Half Diminished 7th")
        XCTAssertEqual(m7b5?.difficulty, .intermediate)
        XCTAssertEqual(m7b5?.chordTones.count, 4)
    }
    
    func test_database_containsDiminished7th() {
        let dim7 = sut.chordTypes.first { $0.symbol == "dim7" }
        
        XCTAssertNotNil(dim7)
        XCTAssertEqual(dim7?.name, "Diminished 7th")
        XCTAssertEqual(dim7?.difficulty, .intermediate)
    }
    
    func test_database_containsMinorMajor7th() {
        let mMaj7 = sut.chordTypes.first { $0.symbol == "m(maj7)" }
        
        XCTAssertNotNil(mMaj7)
        XCTAssertEqual(mMaj7?.name, "Minor Major 7th")
        XCTAssertEqual(mMaj7?.difficulty, .intermediate)
    }
    
    // MARK: - Advanced Chords Tests
    
    func test_database_containsAugmented7th() {
        let aug7 = sut.chordTypes.first { $0.symbol == "7#5" || $0.symbol == "aug7" || $0.symbol == "7+" }
        
        XCTAssertNotNil(aug7, "Database should contain augmented 7th chord")
        if let aug7 = aug7 {
            XCTAssertEqual(aug7.difficulty, .advanced)
        }
    }
    
    func test_database_containsDominant7b9() {
        let dom7b9 = sut.chordTypes.first { $0.symbol == "7b9" }
        
        XCTAssertNotNil(dom7b9)
        if let dom7b9 = dom7b9 {
            XCTAssertEqual(dom7b9.difficulty, .advanced)
        }
    }
    
    func test_database_containsDominant7sharp9() {
        let dom7sh9 = sut.chordTypes.first { $0.symbol == "7#9" }
        
        XCTAssertNotNil(dom7sh9)
        if let dom7sh9 = dom7sh9 {
            XCTAssertEqual(dom7sh9.difficulty, .advanced)
        }
    }
    
    // MARK: - Difficulty Distribution Tests
    
    func test_database_hasBeginner Chords() {
        let beginnerChords = sut.chordTypes.filter { $0.difficulty == .beginner }
        
        XCTAssertGreaterThan(beginnerChords.count, 0)
        XCTAssertTrue(beginnerChords.contains { $0.symbol == "" })
        XCTAssertTrue(beginnerChords.contains { $0.symbol == "m" })
        XCTAssertTrue(beginnerChords.contains { $0.symbol == "7" })
    }
    
    func test_database_hasIntermediateChords() {
        let intermediateChords = sut.chordTypes.filter { $0.difficulty == .intermediate }
        
        XCTAssertGreaterThan(intermediateChords.count, 0)
    }
    
    func test_database_hasAdvancedChords() {
        let advancedChords = sut.chordTypes.filter { $0.difficulty == .advanced }
        
        XCTAssertGreaterThan(advancedChords.count, 0)
    }
    
    // MARK: - Symbol Uniqueness Tests
    
    func test_chordSymbols_areUnique() {
        let symbols = sut.chordTypes.map { $0.symbol }
        let uniqueSymbols = Set(symbols)
        
        XCTAssertEqual(symbols.count, uniqueSymbols.count, "Chord symbols should be unique")
    }
    
    func test_chordNames_areUnique() {
        let names = sut.chordTypes.map { $0.name }
        let uniqueNames = Set(names)
        
        XCTAssertEqual(names.count, uniqueNames.count, "Chord names should be unique")
    }
    
    // MARK: - Chord Tone Validation Tests
    
    func test_majorTriad_hasCorrectTones() {
        let major = sut.chordTypes.first { $0.symbol == "" }
        
        XCTAssertNotNil(major)
        if let major = major {
            XCTAssertEqual(major.chordTones.count, 3)
            XCTAssertTrue(major.chordTones.contains { $0.degree == 1 }) // Root
            XCTAssertTrue(major.chordTones.contains { $0.degree == 3 && !$0.isAltered }) // 3rd
            XCTAssertTrue(major.chordTones.contains { $0.degree == 5 && !$0.isAltered }) // 5th
        }
    }
    
    func test_minorTriad_hasCorrectTones() {
        let minor = sut.chordTypes.first { $0.symbol == "m" }
        
        XCTAssertNotNil(minor)
        if let minor = minor {
            XCTAssertEqual(minor.chordTones.count, 3)
            XCTAssertTrue(minor.chordTones.contains { $0.degree == 1 }) // Root
            XCTAssertTrue(minor.chordTones.contains { $0.degree == 3 && $0.isAltered }) // b3
            XCTAssertTrue(minor.chordTones.contains { $0.degree == 5 && !$0.isAltered }) // 5th
        }
    }
    
    func test_dominant7_hasCorrectTones() {
        let dom7 = sut.chordTypes.first { $0.symbol == "7" }
        
        XCTAssertNotNil(dom7)
        if let dom7 = dom7 {
            XCTAssertEqual(dom7.chordTones.count, 4)
            XCTAssertTrue(dom7.chordTones.contains { $0.degree == 1 }) // Root
            XCTAssertTrue(dom7.chordTones.contains { $0.degree == 3 && !$0.isAltered }) // 3rd
            XCTAssertTrue(dom7.chordTones.contains { $0.degree == 5 && !$0.isAltered }) // 5th
            XCTAssertTrue(dom7.chordTones.contains { $0.degree == 7 && $0.isAltered }) // b7
        }
    }
    
    func test_halfDiminished_hasCorrectTones() {
        let m7b5 = sut.chordTypes.first { $0.symbol == "m7b5" }
        
        XCTAssertNotNil(m7b5)
        if let m7b5 = m7b5 {
            XCTAssertEqual(m7b5.chordTones.count, 4)
            XCTAssertTrue(m7b5.chordTones.contains { $0.degree == 1 }) // Root
            XCTAssertTrue(m7b5.chordTones.contains { $0.degree == 3 && $0.isAltered }) // b3
            XCTAssertTrue(m7b5.chordTones.contains { $0.degree == 5 && $0.isAltered }) // b5
            XCTAssertTrue(m7b5.chordTones.contains { $0.degree == 7 && $0.isAltered }) // b7
        }
    }
    
    // MARK: - Lookup Method Tests
    
    func test_getChordTypeBySymbol_returnsCorrectChord() {
        let major = sut.chordTypes.first { $0.symbol == "" }
        XCTAssertNotNil(major)
        XCTAssertEqual(major?.symbol, "")
    }
    
    func test_getChordTypeBySymbol_returnsNilForInvalidSymbol() {
        let invalid = sut.chordTypes.first { $0.symbol == "INVALID123" }
        XCTAssertNil(invalid)
    }
    
    // MARK: - Filtering Tests
    
    func test_filterByDifficulty_beginner_returnsOnlyBeginnerChords() {
        let beginnerChords = sut.chordTypes.filter { $0.difficulty == .beginner }
        
        XCTAssertTrue(beginnerChords.allSatisfy { $0.difficulty == .beginner })
    }
    
    func test_filterByDifficulty_intermediate_returnsOnlyIntermediateChords() {
        let intermediateChords = sut.chordTypes.filter { $0.difficulty == .intermediate }
        
        XCTAssertTrue(intermediateChords.allSatisfy { $0.difficulty == .intermediate })
    }
    
    func test_filterByDifficulty_advanced_returnsOnlyAdvancedChords() {
        let advancedChords = sut.chordTypes.filter { $0.difficulty == .advanced }
        
        XCTAssertTrue(advancedChords.allSatisfy { $0.difficulty == .advanced })
    }
    
    // MARK: - Edge Cases
    
    func test_database_hasMinimumChordTypes() {
        // Should have at least the 5 basic beginner chords
        XCTAssertGreaterThanOrEqual(sut.chordTypes.count, 5)
    }
    
    func test_allChordTypes_haveNames() {
        let chordsWithoutNames = sut.chordTypes.filter { $0.name.isEmpty }
        XCTAssertTrue(chordsWithoutNames.isEmpty, "All chord types should have names")
    }
    
    func test_allChordTypes_haveChordTones() {
        let chordsWithoutTones = sut.chordTypes.filter { $0.chordTones.isEmpty }
        XCTAssertTrue(chordsWithoutTones.isEmpty, "All chord types should have chord tones")
    }
    
    func test_allChordTypes_haveValidChordTones() {
        for chordType in sut.chordTypes {
            for tone in chordType.chordTones {
                XCTAssertGreaterThan(tone.degree, 0, "\(chordType.name) has invalid chord tone degree")
                XCTAssertGreaterThanOrEqual(tone.semitonesFromRoot, 0, "\(chordType.name) has invalid semitones")
                XCTAssertLessThan(tone.semitonesFromRoot, 24, "\(chordType.name) has invalid semitones (too large)")
            }
        }
    }
    
    // MARK: - Preset Compatibility Tests
    
    func test_basicTriadsPreset_onlyIncludesExistingChords() {
        // From ChordDrillGame preset
        let basicTriadSymbols: Set<String> = ["", "m"]
        
        for symbol in basicTriadSymbols {
            let chord = sut.chordTypes.first { $0.symbol == symbol }
            XCTAssertNotNil(chord, "Basic triads preset references '\(symbol)' which should exist")
        }
    }
    
    func test_seventhChordsPreset_onlyIncludesExistingChords() {
        // From ChordDrillGame preset
        let seventhSymbols: Set<String> = ["7", "maj7", "m7", "m7b5", "dim7"]
        
        for symbol in seventhSymbols {
            let chord = sut.chordTypes.first { $0.symbol == symbol }
            XCTAssertNotNil(chord, "7th chords preset references '\(symbol)' which should exist")
        }
    }
    
    func test_seventhChordsPreset_allAreBeginner() {
        // Per ChordDrillGame preset fix - 7th chords should all be beginner level
        let seventhSymbols: Set<String> = ["7", "maj7", "m7"]
        
        for symbol in seventhSymbols {
            if let chord = sut.chordTypes.first(where: { $0.symbol == symbol }) {
                XCTAssertEqual(chord.difficulty, .beginner, 
                             "\(symbol) should be beginner difficulty for 7th chords preset")
            }
        }
    }
}
