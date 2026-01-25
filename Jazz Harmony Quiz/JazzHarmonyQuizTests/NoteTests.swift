import XCTest
@testable import JazzHarmonyQuiz

/// Tests for the Note struct - the fundamental building block of the app
final class NoteTests: XCTestCase {
    
    // MARK: - Pitch Class Tests
    
    func test_pitchClass_middleC_returnsZero() {
        // Arrange
        let note = Note(name: "C", midiNumber: 60, isSharp: false)
        
        // Act
        let pitchClass = note.pitchClass
        
        // Assert
        XCTAssertEqual(pitchClass, 0, "Middle C (MIDI 60) should have pitch class 0")
    }
    
    func test_pitchClass_cSharp_returnsOne() {
        let note = Note(name: "C#", midiNumber: 61, isSharp: true)
        XCTAssertEqual(note.pitchClass, 1)
    }
    
    func test_pitchClass_octaveHigherC_returnsZero() {
        // C5 (MIDI 72) should also have pitch class 0
        let note = Note(name: "C", midiNumber: 72, isSharp: false)
        XCTAssertEqual(note.pitchClass, 0, "C in any octave should have pitch class 0")
    }
    
    func test_pitchClass_lowC_returnsZero() {
        // C2 (MIDI 36) should also have pitch class 0
        let note = Note(name: "C", midiNumber: 36, isSharp: false)
        XCTAssertEqual(note.pitchClass, 0)
    }
    
    func test_pitchClass_allChromaticNotes() {
        // Test all 12 pitch classes
        let expectedPitchClasses = [
            (60, 0),  // C
            (61, 1),  // C#/Db
            (62, 2),  // D
            (63, 3),  // D#/Eb
            (64, 4),  // E
            (65, 5),  // F
            (66, 6),  // F#/Gb
            (67, 7),  // G
            (68, 8),  // G#/Ab
            (69, 9),  // A
            (70, 10), // A#/Bb
            (71, 11)  // B
        ]
        
        for (midiNumber, expectedPitchClass) in expectedPitchClasses {
            let note = Note(name: "Test", midiNumber: midiNumber, isSharp: false)
            XCTAssertEqual(note.pitchClass, expectedPitchClass, 
                          "MIDI \(midiNumber) should have pitch class \(expectedPitchClass)")
        }
    }
    
    // MARK: - Note Equality Tests
    
    func test_equality_sameNote_isEqual() {
        let note1 = Note(name: "C", midiNumber: 60, isSharp: false)
        let note2 = Note(name: "C", midiNumber: 60, isSharp: false)
        
        XCTAssertEqual(note1, note2)
    }
    
    func test_equality_enharmonicNotes_areEqual() {
        // C# and Db at the same MIDI number should be equal
        let cSharp = Note(name: "C#", midiNumber: 61, isSharp: true)
        let dFlat = Note(name: "Db", midiNumber: 61, isSharp: false)
        
        XCTAssertEqual(cSharp, dFlat, "Enharmonic notes with same MIDI number should be equal")
    }
    
    func test_equality_differentOctaves_notEqual() {
        let middleC = Note(name: "C", midiNumber: 60, isSharp: false)
        let highC = Note(name: "C", midiNumber: 72, isSharp: false)
        
        XCTAssertNotEqual(middleC, highC, "Same note name in different octaves should not be equal")
    }
    
    func test_equality_differentNotes_notEqual() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let d = Note(name: "D", midiNumber: 62, isSharp: false)
        
        XCTAssertNotEqual(c, d)
    }
    
    // MARK: - Note Hash Tests
    
    func test_hash_enharmonicNotes_haveSameHash() {
        let cSharp = Note(name: "C#", midiNumber: 61, isSharp: true)
        let dFlat = Note(name: "Db", midiNumber: 61, isSharp: false)
        
        XCTAssertEqual(cSharp.hashValue, dFlat.hashValue, 
                      "Enharmonic notes should have the same hash")
    }
    
    func test_hash_canBeUsedInSet() {
        let cSharp = Note(name: "C#", midiNumber: 61, isSharp: true)
        let dFlat = Note(name: "Db", midiNumber: 61, isSharp: false)
        
        var noteSet: Set<Note> = []
        noteSet.insert(cSharp)
        noteSet.insert(dFlat)
        
        // Both are same MIDI number, so set should only have 1 element
        XCTAssertEqual(noteSet.count, 1, 
                      "Set should deduplicate enharmonic notes")
    }
    
    // MARK: - noteFromMidi Tests
    
    func test_noteFromMidi_validMidiNumber_returnsNote() {
        let note = Note.noteFromMidi(60)
        
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "C")
    }
    
    func test_noteFromMidi_preferSharps_returnsSharps() {
        let note = Note.noteFromMidi(61, preferSharps: true)
        
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "C#")
        XCTAssertTrue(note?.isSharp ?? false)
    }
    
    func test_noteFromMidi_preferFlats_returnsFlats() {
        let note = Note.noteFromMidi(61, preferSharps: false)
        
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "Db")
        XCTAssertFalse(note?.isSharp ?? true)
    }
    
    func test_noteFromMidi_naturalNote_ignoresPreference() {
        // Natural notes (no enharmonic equivalent) should return same note regardless
        let noteWithSharps = Note.noteFromMidi(60, preferSharps: true)
        let noteWithFlats = Note.noteFromMidi(60, preferSharps: false)
        
        XCTAssertEqual(noteWithSharps?.name, "C")
        XCTAssertEqual(noteWithFlats?.name, "C")
    }
    
    func test_noteFromMidi_highOctave_returnsCorrectPitchClass() {
        // MIDI 84 is C6
        let note = Note.noteFromMidi(84)
        
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.pitchClass, 0, "High C should have pitch class 0")
    }
    
    func test_noteFromMidi_lowOctave_returnsCorrectPitchClass() {
        // MIDI 36 is C2
        let note = Note.noteFromMidi(36)
        
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.pitchClass, 0, "Low C should have pitch class 0")
    }
    
    // MARK: - allNotes Static Property Tests
    
    func test_allNotes_hasCorrectCount() {
        // Should have 17 notes: 7 naturals + 5 sharps + 5 flats
        XCTAssertEqual(Note.allNotes.count, 17)
    }
    
    func test_allNotes_containsAllNaturals() {
        let naturalNames = ["C", "D", "E", "F", "G", "A", "B"]
        
        for name in naturalNames {
            let hasNote = Note.allNotes.contains { $0.name == name }
            XCTAssertTrue(hasNote, "allNotes should contain \(name)")
        }
    }
    
    func test_allNotes_containsAllSharps() {
        let sharpNames = ["C#", "D#", "F#", "G#", "A#"]
        
        for name in sharpNames {
            let hasNote = Note.allNotes.contains { $0.name == name }
            XCTAssertTrue(hasNote, "allNotes should contain \(name)")
        }
    }
    
    func test_allNotes_containsAllFlats() {
        let flatNames = ["Db", "Eb", "Gb", "Ab", "Bb"]
        
        for name in flatNames {
            let hasNote = Note.allNotes.contains { $0.name == name }
            XCTAssertTrue(hasNote, "allNotes should contain \(name)")
        }
    }
}
