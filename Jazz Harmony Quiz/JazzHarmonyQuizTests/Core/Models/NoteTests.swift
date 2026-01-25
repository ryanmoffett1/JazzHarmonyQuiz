import XCTest
@testable import JazzHarmonyQuiz

final class NoteTests: XCTestCase {
    
    // MARK: - Basic Note Properties
    
    func testNoteInitialization() {
        let cNote = Note(name: "C", midiNumber: 60, pitchClass: 0)
        XCTAssertEqual(cNote.name, "C")
        XCTAssertEqual(cNote.midiNumber, 60)
        XCTAssertEqual(cNote.pitchClass, 0)
        XCTAssertFalse(cNote.isSharp)
    }
    
    func testSharpNoteIdentification() {
        let cSharp = Note(name: "C#", midiNumber: 61, pitchClass: 1, isSharp: true)
        XCTAssertTrue(cSharp.isSharp)
        
        let dFlat = Note(name: "Db", midiNumber: 61, pitchClass: 1)
        XCTAssertFalse(dFlat.isSharp)
    }
    
    // MARK: - Enharmonic Equivalents
    
    func testEnharmonicEquivalents() {
        // C# <-> Db
        let cSharp = Note.allNotes.first { $0.name == "C#" }!
        let dFlat = Note.allNotes.first { $0.name == "Db" }!
        XCTAssertEqual(cSharp.enharmonicEquivalent, dFlat)
        XCTAssertEqual(dFlat.enharmonicEquivalent, cSharp)
        
        // F# <-> Gb
        let fSharp = Note.allNotes.first { $0.name == "F#" }!
        let gFlat = Note.allNotes.first { $0.name == "Gb" }!
        XCTAssertEqual(fSharp.enharmonicEquivalent, gFlat)
        XCTAssertEqual(gFlat.enharmonicEquivalent, fSharp)
        
        // A# <-> Bb
        let aSharp = Note.allNotes.first { $0.name == "A#" }!
        let bFlat = Note.allNotes.first { $0.name == "Bb" }!
        XCTAssertEqual(aSharp.enharmonicEquivalent, bFlat)
        XCTAssertEqual(bFlat.enharmonicEquivalent, aSharp)
    }
    
    func testNaturalNotesHaveNoEnharmonic() {
        let naturalNotes = ["C", "D", "E", "F", "G", "A", "B"]
        for noteName in naturalNotes {
            let note = Note.allNotes.first { $0.name == noteName }!
            XCTAssertNil(note.enharmonicEquivalent, "\(noteName) should have no enharmonic equivalent")
        }
    }
    
    func testIsEnharmonicWith() {
        let cSharp = Note.allNotes.first { $0.name == "C#" }!
        let dFlat = Note.allNotes.first { $0.name == "Db" }!
        let d = Note.allNotes.first { $0.name == "D" }!
        
        XCTAssertTrue(cSharp.isEnharmonicWith(dFlat))
        XCTAssertTrue(dFlat.isEnharmonicWith(cSharp))
        XCTAssertFalse(cSharp.isEnharmonicWith(d))
        XCTAssertFalse(d.isEnharmonicWith(cSharp))
    }
    
    // MARK: - MIDI Conversion
    
    func testNoteFromMidiWithSharps() {
        // C# (MIDI 61)
        let note = Note.noteFromMidi(61, preferSharps: true)
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "C#")
        XCTAssertEqual(note?.midiNumber, 61)
        XCTAssertEqual(note?.pitchClass, 1)
    }
    
    func testNoteFromMidiWithFlats() {
        // Db (MIDI 61)
        let note = Note.noteFromMidi(61, preferSharps: false)
        XCTAssertNotNil(note)
        XCTAssertEqual(note?.name, "Db")
        XCTAssertEqual(note?.midiNumber, 61)
        XCTAssertEqual(note?.pitchClass, 1)
    }
    
    func testNoteFromMidiNaturalNotes() {
        let naturalNotes = [
            (60, "C", 0),
            (62, "D", 2),
            (64, "E", 4),
            (65, "F", 5),
            (67, "G", 7),
            (69, "A", 9),
            (71, "B", 11)
        ]
        
        for (midi, expectedName, expectedPitch) in naturalNotes {
            let sharpNote = Note.noteFromMidi(midi, preferSharps: true)
            let flatNote = Note.noteFromMidi(midi, preferSharps: false)
            
            XCTAssertNotNil(sharpNote)
            XCTAssertNotNil(flatNote)
            XCTAssertEqual(sharpNote?.name, expectedName)
            XCTAssertEqual(flatNote?.name, expectedName)
            XCTAssertEqual(sharpNote?.pitchClass, expectedPitch)
        }
    }
    
    func testNoteFromMidiAllAccidentals() {
        // Test all 5 black keys with both preferences
        let blackKeys = [(61, "C#", "Db"), (63, "D#", "Eb"), (66, "F#", "Gb"), (68, "G#", "Ab"), (70, "A#", "Bb")]
        
        for (midi, sharpName, flatName) in blackKeys {
            let sharpNote = Note.noteFromMidi(midi, preferSharps: true)
            let flatNote = Note.noteFromMidi(midi, preferSharps: false)
            
            XCTAssertEqual(sharpNote?.name, sharpName, "MIDI \(midi) with preferSharps should be \(sharpName)")
            XCTAssertEqual(flatNote?.name, flatName, "MIDI \(midi) with preferFlats should be \(flatName)")
        }
    }
    
    func testNoteFromMidiOutOfRange() {
        // MIDI numbers outside allNotes range should return nil
        XCTAssertNil(Note.noteFromMidi(200, preferSharps: true))
        XCTAssertNil(Note.noteFromMidi(-10, preferSharps: false))
    }
    
    // MARK: - AllNotes Static Array
    
    func testAllNotesContainsCorrectCount() {
        // Should have 7 natural + 10 accidentals = 17 notes
        XCTAssertEqual(Note.allNotes.count, 17)
    }
    
    func testAllNotesContainsAllNaturals() {
        let naturalNames = ["C", "D", "E", "F", "G", "A", "B"]
        for name in naturalNames {
            XCTAssertTrue(Note.allNotes.contains { $0.name == name }, "allNotes should contain \(name)")
        }
    }
    
    func testAllNotesContainsAllSharps() {
        let sharpNames = ["C#", "D#", "F#", "G#", "A#"]
        for name in sharpNames {
            XCTAssertTrue(Note.allNotes.contains { $0.name == name }, "allNotes should contain \(name)")
        }
    }
    
    func testAllNotesContainsAllFlats() {
        let flatNames = ["Db", "Eb", "Gb", "Ab", "Bb"]
        for name in flatNames {
            XCTAssertTrue(Note.allNotes.contains { $0.name == name }, "allNotes should contain \(name)")
        }
    }
    
    func testAllNotesHaveUniqueMidiForNaturals() {
        let naturalNotes = Note.allNotes.filter { !$0.name.contains("#") && !$0.name.contains("b") }
        let midiNumbers = naturalNotes.map { $0.midiNumber }
        XCTAssertEqual(Set(midiNumbers).count, naturalNotes.count, "Natural notes should have unique MIDI numbers")
    }
    
    func testAllNotesEnharmonicPairsShareMidi() {
        let pairs = [("C#", "Db"), ("D#", "Eb"), ("F#", "Gb"), ("G#", "Ab"), ("A#", "Bb")]
        
        for (sharp, flat) in pairs {
            let sharpNote = Note.allNotes.first { $0.name == sharp }!
            let flatNote = Note.allNotes.first { $0.name == flat }!
            XCTAssertEqual(sharpNote.midiNumber, flatNote.midiNumber, "\(sharp) and \(flat) should share MIDI number")
            XCTAssertEqual(sharpNote.pitchClass, flatNote.pitchClass, "\(sharp) and \(flat) should share pitch class")
        }
    }
    
    // MARK: - Hashable & Equatable
    
    func testNoteEquality() {
        let c1 = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let c2 = Note(name: "C", midiNumber: 60, pitchClass: 0)
        XCTAssertEqual(c1, c2)
    }
    
    func testNoteInequality() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let d = Note(name: "D", midiNumber: 62, pitchClass: 2)
        XCTAssertNotEqual(c, d)
    }
    
    func testNoteHashable() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let d = Note(name: "D", midiNumber: 62, pitchClass: 2)
        
        let noteSet: Set<Note> = [c, d, c] // Duplicate c should be removed
        XCTAssertEqual(noteSet.count, 2)
    }
    
    // MARK: - Codable
    
    func testNoteCodable() throws {
        let original = Note(name: "C#", midiNumber: 61, pitchClass: 1, isSharp: true)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Note.self, from: data)
        
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.midiNumber, original.midiNumber)
        XCTAssertEqual(decoded.pitchClass, original.pitchClass)
        XCTAssertEqual(decoded.isSharp, original.isSharp)
    }
}
