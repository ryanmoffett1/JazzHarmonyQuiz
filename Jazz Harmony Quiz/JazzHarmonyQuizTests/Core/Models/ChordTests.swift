import XCTest
@testable import JazzHarmonyQuiz

final class ChordTests: XCTestCase {
    
    // MARK: - ChordTone Tests
    
    func testChordToneBasics() {
        let root = ChordTone(name: "Root", interval: 0)
        XCTAssertEqual(root.name, "Root")
        XCTAssertEqual(root.interval, 0)
    }
    
    func testAllTonesCount() {
        // Root, b9, 9, #9, 3, b3, 11, #11, b5, 5, #5, b13, 13, b7, 7
        XCTAssertEqual(ChordTone.allTones.count, 15)
    }
    
    func testAllTonesContainsEssentialTones() {
        let essentialNames = ["Root", "3", "b3", "5", "b7", "7"]
        for name in essentialNames {
            XCTAssertTrue(ChordTone.allTones.contains { $0.name == name }, "allTones should contain \(name)")
        }
    }
    
    func testAllTonesContainsExtensions() {
        let extensionNames = ["9", "11", "13"]
        for name in extensionNames {
            XCTAssertTrue(ChordTone.allTones.contains { $0.name == name }, "allTones should contain \(name)")
        }
    }
    
    func testAllTonesContainsAlterations() {
        let alterationNames = ["b9", "#9", "#11", "b5", "#5", "b13"]
        for name in alterationNames {
            XCTAssertTrue(ChordTone.allTones.contains { $0.name == name }, "allTones should contain \(name)")
        }
    }
    
    // MARK: - ChordType Tests
    
    func testChordTypeBasics() {
        let major = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [.root, .third, .fifth],
            difficulty: .beginner
        )
        
        XCTAssertEqual(major.name, "Major")
        XCTAssertEqual(major.symbol, "maj")
        XCTAssertEqual(major.tones.count, 3)
        XCTAssertEqual(major.difficulty, .beginner)
    }
    
    func testChordDifficultyLevels() {
        XCTAssertEqual(ChordType.ChordDifficulty.beginner.rawValue, "Beginner")
        XCTAssertEqual(ChordType.ChordDifficulty.intermediate.rawValue, "Intermediate")
        XCTAssertEqual(ChordType.ChordDifficulty.advanced.rawValue, "Advanced")
    }
    
    // MARK: - Chord Tests
    
    func testChordInitialization() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [.root, .third, .fifth],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        
        XCTAssertEqual(cMajor.root.name, "C")
        XCTAssertEqual(cMajor.chordType.name, "Major")
        XCTAssertEqual(cMajor.chordNotes.count, 3)
    }
    
    func testChordDisplayName() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let majorType = ChordType(name: "Major", symbol: "maj", tones: [.root], difficulty: .beginner)
        let chord = Chord(root: c, chordType: majorType)
        
        XCTAssertEqual(chord.displayName, "C Major")
    }
    
    func testChordShortName() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let majorType = ChordType(name: "Major", symbol: "maj", tones: [.root], difficulty: .beginner)
        let chord = Chord(root: c, chordType: majorType)
        
        XCTAssertEqual(chord.shortName, "Cmaj")
    }
    
    func testChordNoteCalculation() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        
        XCTAssertEqual(cMajor.chordNotes.count, 3)
        XCTAssertEqual(cMajor.chordNotes[0].name, "C")  // Root
        XCTAssertEqual(cMajor.chordNotes[1].name, "E")  // Major 3rd
        XCTAssertEqual(cMajor.chordNotes[2].name, "G")  // Perfect 5th
    }
    
    func testChordNoteCalculationWithSharps() {
        let d = Note(name: "D", midiNumber: 62, pitchClass: 2)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let dMajor = Chord(root: d, chordType: majorType)
        
        XCTAssertEqual(dMajor.chordNotes[0].name, "D")   // Root
        XCTAssertEqual(dMajor.chordNotes[1].name, "F#")  // Major 3rd
        XCTAssertEqual(dMajor.chordNotes[2].name, "A")   // Perfect 5th
    }
    
    func testChordNoteCalculationWithFlats() {
        let bb = Note(name: "Bb", midiNumber: 70, pitchClass: 10)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let bbMajor = Chord(root: bb, chordType: majorType)
        
        XCTAssertEqual(bbMajor.chordNotes[0].name, "Bb") // Root
        XCTAssertEqual(bbMajor.chordNotes[1].name, "D")  // Major 3rd
        XCTAssertEqual(bbMajor.chordNotes[2].name, "F")  // Perfect 5th
    }
    
    // MARK: - Common Tones Tests
    
    func testCommonTonesIdenticalChords() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let chord1 = Chord(root: c, chordType: majorType)
        let chord2 = Chord(root: c, chordType: majorType)
        
        let common = chord1.commonTones(with: chord2)
        XCTAssertEqual(common.count, 3)
    }
    
    func testCommonTonesRelatedChords() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        let minorType = ChordType(
            name: "Minor",
            symbol: "min",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "b3", interval: 3),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let cMinor = Chord(root: c, chordType: minorType)
        
        let common = cMajor.commonTones(with: cMinor)
        XCTAssertEqual(common.count, 2) // Root and 5th are common
    }
    
    func testCommonTonesNoOverlap() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let fSharp = Note(name: "F#", midiNumber: 66, pitchClass: 6)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let fSharpMajor = Chord(root: fSharp, chordType: majorType)
        
        let common = cMajor.commonTones(with: fSharpMajor)
        XCTAssertEqual(common.count, 0) // Tritone apart, no common tones
    }
    
    // MARK: - Guide Tones Tests
    
    func testGuideTonesMajor7() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let maj7Type = ChordType(
            name: "Major 7",
            symbol: "maj7",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7),
                ChordTone(name: "7", interval: 11)
            ],
            difficulty: .intermediate
        )
        
        let cMaj7 = Chord(root: c, chordType: maj7Type)
        let guides = cMaj7.guideTones
        
        XCTAssertEqual(guides.count, 2)
        XCTAssertTrue(guides.contains { $0.name == "E" }) // 3rd
        XCTAssertTrue(guides.contains { $0.name == "B" }) // 7th
    }
    
    func testGuideTonesMinor7() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let min7Type = ChordType(
            name: "Minor 7",
            symbol: "min7",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "b3", interval: 3),
                ChordTone(name: "5", interval: 7),
                ChordTone(name: "b7", interval: 10)
            ],
            difficulty: .intermediate
        )
        
        let cMin7 = Chord(root: c, chordType: min7Type)
        let guides = cMin7.guideTones
        
        XCTAssertEqual(guides.count, 2)
        XCTAssertTrue(guides.contains { $0.name == "Eb" }) // b3rd
        XCTAssertTrue(guides.contains { $0.name == "Bb" }) // b7th
    }
    
    func testGuideTonesTriadHasNone() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let guides = cMajor.guideTones
        
        XCTAssertEqual(guides.count, 0) // No 7th, so no guide tones
    }
    
    // MARK: - Role of Note Tests
    
    func testRoleOfNoteRoot() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let role = cMajor.roleOfNote(c)
        
        XCTAssertEqual(role, .root)
    }
    
    func testRoleOfNoteThird() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let e = Note(name: "E", midiNumber: 64, pitchClass: 4)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let role = cMajor.roleOfNote(e)
        
        XCTAssertEqual(role, .third)
    }
    
    func testRoleOfNoteFifth() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let g = Note(name: "G", midiNumber: 67, pitchClass: 7)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let role = cMajor.roleOfNote(g)
        
        XCTAssertEqual(role, .fifth)
    }
    
    func testRoleOfNoteSeventh() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let b = Note(name: "B", midiNumber: 71, pitchClass: 11)
        let maj7Type = ChordType(
            name: "Major 7",
            symbol: "maj7",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7),
                ChordTone(name: "7", interval: 11)
            ],
            difficulty: .intermediate
        )
        
        let cMaj7 = Chord(root: c, chordType: maj7Type)
        let role = cMaj7.roleOfNote(b)
        
        XCTAssertEqual(role, .seventh)
    }
    
    func testRoleOfNoteExtension() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let d = Note(name: "D", midiNumber: 62, pitchClass: 2)
        let add9Type = ChordType(
            name: "Add 9",
            symbol: "add9",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "9", interval: 2),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .intermediate
        )
        
        let cAdd9 = Chord(root: c, chordType: add9Type)
        let role = cAdd9.roleOfNote(d)
        
        XCTAssertEqual(role, .extension)
    }
    
    func testRoleOfNoteNotInChord() {
        let c = Note(name: "C", midiNumber: 60, pitchClass: 0)
        let fSharp = Note(name: "F#", midiNumber: 66, pitchClass: 6)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            tones: [
                ChordTone(name: "Root", interval: 0),
                ChordTone(name: "3", interval: 4),
                ChordTone(name: "5", interval: 7)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let role = cMajor.roleOfNote(fSharp)
        
        XCTAssertNil(role)
    }
}
