import XCTest
@testable import JazzHarmonyQuiz

/// Tests for proper chord tone spelling based on scale degrees
/// Ensures chords like Gdim spell as G Bb Db (not G A# C#)
@MainActor
final class ChordSpellingTests: XCTestCase {
    
    // MARK: - Diminished Chords
    
    func test_Gdim_spellsWithFlats() {
        // G diminished should be G Bb Db (not G A# C#)
        // Major scale of G: G A B C D E F#
        // dim = 1 b3 b5 = G Bb(flatted B) Db(flatted D)
        
        let root = Note(name: "G", midiNumber: 67, isSharp: false)
        let dimType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "dim" }!
        
        let chord = Chord(root: root, chordType: dimType)
        
        let noteNames = chord.chordTones.map { $0.name }
        XCTAssertEqual(noteNames.count, 3, "Gdim should have 3 notes")
        XCTAssertEqual(noteNames[0], "G", "Root should be G")
        XCTAssertEqual(noteNames[1], "Bb", "Minor 3rd should be Bb (not A#)")
        XCTAssertEqual(noteNames[2], "Db", "Diminished 5th should be Db (not C#)")
    }
    
    func test_Cdim_spellsWithFlats() {
        // C diminished should be C Eb Gb
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let dimType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "dim" }!
        
        let chord = Chord(root: root, chordType: dimType)
        
        let noteNames = chord.chordTones.map { $0.name }
        XCTAssertEqual(noteNames[0], "C")
        XCTAssertEqual(noteNames[1], "Eb", "Minor 3rd should be Eb")
        XCTAssertEqual(noteNames[2], "Gb", "Diminished 5th should be Gb (not F#)")
    }
    
    func test_FSharpDim_spellsWithSharps() {
        // F# diminished should use sharps: F# A C (not F# A Cb)
        // Major scale of F#: F# G# A# B C# D# E#
        // dim = 1 b3 b5 = F# A(flatted A#) C(flatted C#)
        
        let root = Note(name: "F#", midiNumber: 66, isSharp: true)
        let dimType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "dim" }!
        
        let chord = Chord(root: root, chordType: dimType)
        
        let noteNames = chord.chordTones.map { $0.name }
        XCTAssertEqual(noteNames[0], "F#")
        XCTAssertEqual(noteNames[1], "A", "Minor 3rd should be A (flatted A#)")
        // C vs B# - in F# context, C is more common than B#
        XCTAssertTrue(noteNames[2] == "C" || noteNames[2] == "B#", "Diminished 5th should be C or B# (flatted C#)")
    }
    
    // MARK: - Minor Chords
    
    func test_Gm_spellsWithFlats() {
        // G minor should be G Bb D (not G A# D)
        let root = Note(name: "G", midiNumber: 67, isSharp: false)
        let minorType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "m" }!
        
        let chord = Chord(root: root, chordType: minorType)
        
        let noteNames = chord.chordTones.map { $0.name }
        XCTAssertEqual(noteNames[0], "G")
        XCTAssertEqual(noteNames[1], "Bb", "Minor 3rd should be Bb (not A#)")
        XCTAssertEqual(noteNames[2], "D")
    }
    
    func test_Dm_spellsWithFlats() {
        // D minor should be D F A (not D E# A)
        let root = Note(name: "D", midiNumber: 62, isSharp: false)
        let minorType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "m" }!
        
        let chord = Chord(root: root, chordType: minorType)
        
        let noteNames = chord.chordTones.map { $0.name }
        XCTAssertEqual(noteNames[0], "D")
        XCTAssertEqual(noteNames[1], "F", "Minor 3rd should be F (not E#)")
        XCTAssertEqual(noteNames[2], "A")
    }
    
    // MARK: - Augmented Chords
    
    func test_Gaug_spellsWithSharps() {
        // G augmented should be G B D# (not G B Eb)
        // Major scale of G: G A B C D E F#
        // aug = 1 3 #5 = G B D#(sharped D)
        
        let root = Note(name: "G", midiNumber: 67, isSharp: false)
        let augType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "aug" || $0.symbol == "+" }!
        
        let chord = Chord(root: root, chordType: augType)
        
        let noteNames = chord.chordTones.map { $0.name }
        XCTAssertEqual(noteNames[0], "G")
        XCTAssertEqual(noteNames[1], "B")
        XCTAssertEqual(noteNames[2], "D#", "Augmented 5th should be D# (not Eb)")
    }
    
    // MARK: - Seventh Chords
    
    func test_Gm7_spellsCorrectly() {
        // G minor 7 should be G Bb D F (not G A# D F)
        let root = Note(name: "G", midiNumber: 67, isSharp: false)
        let m7Type = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "m7" }!
        
        let chord = Chord(root: root, chordType: m7Type)
        
        let noteNames = chord.chordTones.map { $0.name }
        XCTAssertTrue(noteNames.contains("G"))
        XCTAssertTrue(noteNames.contains("Bb"), "Should use Bb not A#")
        XCTAssertTrue(noteNames.contains("D"))
        XCTAssertTrue(noteNames.contains("F"))
    }
    
    func test_Abmaj6_spellsWithFlats() {
        // Ab major 6 should be Ab C Eb F (not G# C D# F)
        let root = Note(name: "Ab", midiNumber: 68, isSharp: false)
        let maj6Type = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "maj6" || $0.symbol == "6" }!
        
        let chord = Chord(root: root, chordType: maj6Type)
        
        let noteNames = chord.chordTones.map { $0.name }
        XCTAssertTrue(noteNames.contains("Ab"), "Root should be Ab not G#")
        XCTAssertTrue(noteNames.contains("C"))
        XCTAssertTrue(noteNames.contains("Eb"), "Should use Eb not D#")
        XCTAssertTrue(noteNames.contains("F"))
    }
    
    // MARK: - Scale Degree Consistency
    
    func test_allChordsUseUniqueScaleDegrees() {
        // Each chord should use each letter name at most once
        // E.g., shouldn't have both F and F# in the same chord
        
        let roots = ["C", "G", "D", "F", "Bb", "Ab"]
        let chordSymbols = ["", "m", "dim", "aug", "7", "maj7"]
        
        for rootName in roots {
            guard let root = Note.allNotes.first(where: { $0.name == rootName }) else { continue }
            
            for symbol in chordSymbols {
                guard let chordType = JazzChordDatabase.shared.chordTypes.first(where: { $0.symbol == symbol }) else { continue }
                
                let chord = Chord(root: root, chordType: chordType)
                let letterNames = chord.chordTones.map { String($0.name.prefix(1)) }
                let uniqueLetters = Set(letterNames)
                
                XCTAssertEqual(letterNames.count, uniqueLetters.count,
                    "\(chord.displayName) has duplicate letter names: \(chord.chordTones.map { $0.name })")
            }
        }
    }
}
