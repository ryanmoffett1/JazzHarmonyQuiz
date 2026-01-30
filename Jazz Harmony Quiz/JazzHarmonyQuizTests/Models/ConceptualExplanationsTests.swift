//
//  ConceptualExplanationsTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

final class ConceptualExplanationsTests: XCTestCase {
    
    var sut: ConceptualExplanations!
    
    override func setUp() {
        sut = ConceptualExplanations.shared
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Singleton Tests
    
    func test_shared_isSingleton() {
        let instance1 = ConceptualExplanations.shared
        let instance2 = ConceptualExplanations.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    // MARK: - Chord Explanation Tests
    
    func test_chordExplanation_majorChord_returnsExplanation() {
        let majorType = ChordType(
            name: "Major",
            symbol: "",
            chordTones: [],
            difficulty: .beginner
        )
        
        let explanation = sut.chordExplanation(for: majorType)
        
        XCTAssertNotNil(explanation)
        XCTAssertFalse(explanation.theory.isEmpty)
    }
    
    func test_chordExplanation_minorChord_returnsExplanation() {
        let minorType = ChordType(
            name: "Minor",
            symbol: "m",
            chordTones: [],
            difficulty: .beginner
        )
        
        let explanation = sut.chordExplanation(for: minorType)
        
        XCTAssertNotNil(explanation)
        XCTAssertFalse(explanation.theory.isEmpty)
    }
    
    func test_chordExplanation_dominant7_returnsExplanation() {
        let dom7Type = ChordType(
            name: "Dominant 7th",
            symbol: "7",
            chordTones: [],
            difficulty: .beginner
        )
        
        let explanation = sut.chordExplanation(for: dom7Type)
        
        XCTAssertNotNil(explanation)
        XCTAssertFalse(explanation.theory.isEmpty)
    }
    
    func test_chordExplanation_unknownChord_returnsDefaultConcept() {
        let unknownType = ChordType(
            name: "Unknown",
            symbol: "UNKNOWN123",
            chordTones: [],
            difficulty: .advanced
        )
        
        let explanation = sut.chordExplanation(for: unknownType)
        
        // Should return default concept, not crash
        XCTAssertNotNil(explanation)
    }
    
    // MARK: - Contextual Chord Explanation Tests
    
    func test_contextualExplanation_majorKeyTonic_mentionsTonicFunction() {
        let chord = Chord(root: Note.noteFromMidi(60), chordType: ChordType(name: "Major 7th", symbol: "maj7", chordTones: [], difficulty: .beginner))
        let context = HarmonicContext.majorKey(.tonic)
        
        let explanation = sut.contextualChordExplanation(chord: chord, context: context)
        
        XCTAssertTrue(explanation.lowercased().contains("tonic") || explanation.lowercased().contains("home"))
    }
    
    func test_contextualExplanation_majorKeyDominant_mentionsTension() {
        let chord = Chord(root: Note.noteFromMidi(67), chordType: ChordType(name: "Dominant 7th", symbol: "7", chordTones: [], difficulty: .beginner))
        let context = HarmonicContext.majorKey(.dominant)
        
        let explanation = sut.contextualChordExplanation(chord: chord, context: context)
        
        XCTAssertTrue(explanation.lowercased().contains("tension") || explanation.lowercased().contains("dominant"))
    }
    
    func test_contextualExplanation_minorKeyTonic_mentionsMinor() {
        let chord = Chord(root: Note.noteFromMidi(60), chordType: ChordType(name: "Minor 7th", symbol: "m7", chordTones: [], difficulty: .beginner))
        let context = HarmonicContext.minorKey(.tonic)
        
        let explanation = sut.contextualChordExplanation(chord: chord, context: context)
        
        XCTAssertTrue(explanation.lowercased().contains("minor") || explanation.lowercased().contains("tonic"))
    }
    
    func test_contextualExplanation_standalone_returnsGeneralTheory() {
        let chord = Chord(root: Note.noteFromMidi(60), chordType: ChordType(name: "Major 7th", symbol: "maj7", chordTones: [], difficulty: .beginner))
        let context = HarmonicContext.standalone
        
        let explanation = sut.contextualChordExplanation(chord: chord, context: context)
        
        XCTAssertFalse(explanation.isEmpty)
    }
    
    // MARK: - Scale Explanation Tests
    
    func test_scaleExplanation_major_returnsExplanation() {
        let majorScale = ScaleType(
            name: "Major",
            symbol: "Major",
            degrees: [],
            difficulty: .beginner,
            description: "The foundation scale"
        )
        
        let explanation = sut.scaleExplanation(for: majorScale)
        
        XCTAssertNotNil(explanation)
        XCTAssertFalse(explanation.theory.isEmpty)
    }
    
    func test_scaleExplanation_minor_returnsExplanation() {
        let minorScale = ScaleType(
            name: "Natural Minor",
            symbol: "Minor",
            degrees: [],
            difficulty: .beginner,
            description: "Minor scale"
        )
        
        let explanation = sut.scaleExplanation(for: minorScale)
        
        XCTAssertNotNil(explanation)
        XCTAssertFalse(explanation.theory.isEmpty)
    }
    
    func test_scaleExplanation_unknownScale_returnsDefaultConcept() {
        let unknownScale = ScaleType(
            name: "Unknown Scale 123",
            symbol: "Unknown",
            degrees: [],
            difficulty: .advanced,
            description: ""
        )
        
        let explanation = sut.scaleExplanation(for: unknownScale)
        
        XCTAssertNotNil(explanation)
    }
    
    // MARK: - Interval Explanation Tests
    
    func test_intervalExplanation_perfectFifth_returnsExplanation() {
        let P5 = IntervalType(
            name: "Perfect Fifth",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            number: 5,
            difficulty: .beginner
        )
        
        let explanation = sut.intervalExplanation(for: P5)
        
        XCTAssertNotNil(explanation)
        XCTAssertFalse(explanation.theory.isEmpty)
    }
    
    func test_intervalExplanation_majorThird_returnsExplanation() {
        let M3 = IntervalType(
            name: "Major Third",
            shortName: "M3",
            semitones: 4,
            quality: .major,
            number: 3,
            difficulty: .beginner
        )
        
        let explanation = sut.intervalExplanation(for: M3)
        
        XCTAssertNotNil(explanation)
        XCTAssertFalse(explanation.theory.isEmpty)
    }
    
    func test_intervalExplanation_unknownInterval_returnsDefaultConcept() {
        let unknownInterval = IntervalType(
            name: "Unknown Interval",
            shortName: "??",
            semitones: 99,
            quality: .perfect,
            number: 99,
            difficulty: .advanced
        )
        
        let explanation = sut.intervalExplanation(for: unknownInterval)
        
        XCTAssertNotNil(explanation)
    }
    
    // MARK: - Progression Explanation Tests
    
    func test_progressionExplanation_twoFiveOne_returnsExplanation() {
        let explanation = sut.progressionExplanation(for: "ii-V-I")
        
        XCTAssertNotNil(explanation)
        XCTAssertFalse(explanation.theory.isEmpty)
    }
    
    func test_progressionExplanation_turnaround_returnsExplanation() {
        let explanation = sut.progressionExplanation(for: "I-vi-ii-V")
        
        XCTAssertNotNil(explanation)
        XCTAssertFalse(explanation.theory.isEmpty)
    }
    
    func test_progressionExplanation_unknownProgression_returnsDefaultConcept() {
        let explanation = sut.progressionExplanation(for: "UNKNOWN_PROGRESSION_123")
        
        XCTAssertNotNil(explanation)
    }
    
    // MARK: - Explanation Content Tests
    
    func test_allExplanations_provideEducationalValue() {
        // Test that explanations are educational (not just empty strings)
        let chord = Chord(root: Note.noteFromMidi(60), chordType: ChordType(name: "Major 7th", symbol: "maj7", chordTones: [], difficulty: .beginner))
        let context = HarmonicContext.majorKey(.tonic)
        
        let explanation = sut.contextualChordExplanation(chord: chord, context: context)
        
        // Educational explanations should be reasonably detailed
        XCTAssertGreaterThan(explanation.count, 20, "Explanation should be detailed enough to be educational")
    }
    
    func test_explanations_areConsistent() {
        // Getting the same explanation twice should return the same result
        let chord = Chord(root: Note.noteFromMidi(60), chordType: ChordType(name: "Dominant 7th", symbol: "7", chordTones: [], difficulty: .beginner))
        let context = HarmonicContext.majorKey(.dominant)
        
        let explanation1 = sut.contextualChordExplanation(chord: chord, context: context)
        let explanation2 = sut.contextualChordExplanation(chord: chord, context: context)
        
        XCTAssertEqual(explanation1, explanation2)
    }
    
    // MARK: - Edge Cases
    
    func test_explanations_handleAllChordFunctions() {
        let chord = Chord(root: Note.noteFromMidi(60), chordType: ChordType(name: "Major 7th", symbol: "maj7", chordTones: [], difficulty: .beginner))
        
        let functions: [ChordFunction] = [.tonic, .subdominant, .dominant, .submediant, .mediant]
        
        for function in functions {
            let context = HarmonicContext.majorKey(function)
            let explanation = sut.contextualChordExplanation(chord: chord, context: context)
            
            XCTAssertFalse(explanation.isEmpty, "Should have explanation for \(function)")
        }
    }
    
    func test_explanations_handleBothKeyTypes() {
        let chord = Chord(root: Note.noteFromMidi(60), chordType: ChordType(name: "Minor 7th", symbol: "m7", chordTones: [], difficulty: .beginner))
        
        let majorContext = HarmonicContext.majorKey(.tonic)
        let minorContext = HarmonicContext.minorKey(.tonic)
        
        let majorExplanation = sut.contextualChordExplanation(chord: chord, context: majorContext)
        let minorExplanation = sut.contextualChordExplanation(chord: chord, context: minorContext)
        
        XCTAssertFalse(majorExplanation.isEmpty)
        XCTAssertFalse(minorExplanation.isEmpty)
        // Explanations should differ between major and minor contexts
        XCTAssertNotEqual(majorExplanation, minorExplanation)
    }
}
