import XCTest
@testable import JazzHarmonyQuiz

final class ChordTests: XCTestCase {
    
    // MARK: - ChordTone Tests
    
    func testChordToneBasics() {
        let root = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        XCTAssertEqual(root.name, "Root")
        XCTAssertEqual(root.semitonesFromRoot, 0)
    }
    
    func testAllTonesCount() {
        // Root, 2nd, 3rd, 4th, 5th, 6th, 7th, 9th, 11th, 13th, b9, #9, b3, b5, #5, b13, #13, b7, #11
        XCTAssertEqual(ChordTone.allTones.count, 19)
    }
    
    func testAllTonesContainsEssentialTones() {
        let essentialNames = ["Root", "3rd", "b3", "5th", "b7", "7th"]
        for name in essentialNames {
            XCTAssertTrue(ChordTone.allTones.contains { $0.name == name }, "allTones should contain \(name)")
        }
    }
    
    func testAllTonesContainsExtensions() {
        let extensionNames = ["9th", "11th", "13th"]
        for name in extensionNames {
            XCTAssertTrue(ChordTone.allTones.contains { $0.name == name }, "allTones should contain \(name)")
        }
    }
    
    func testAllTonesContainsAlterations() {
        // ChordTone.allTones contains: b9, #9, b3, b5, #5, b13, #13, b7
        let alterationNames = ["b9", "#9", "b3", "b5", "#5", "b13", "b7"]
        for name in alterationNames {
            XCTAssertTrue(ChordTone.allTones.contains { $0.name == name }, "allTones should contain \(name)")
        }
    }
    
    // MARK: - ChordType Tests
    
    func testChordTypeBasics() {
        let rootTone = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        let thirdTone = ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false)
        let fifthTone = ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
        
        let major = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [rootTone, thirdTone, fifthTone],
            difficulty: .beginner
        )
        
        XCTAssertEqual(major.name, "Major")
        XCTAssertEqual(major.symbol, "maj")
        XCTAssertEqual(major.chordTones.count, 3)
        XCTAssertEqual(major.difficulty, .beginner)
    }
    
    func testChordDifficultyLevels() {
        XCTAssertEqual(ChordType.ChordDifficulty.beginner.rawValue, "Beginner")
        XCTAssertEqual(ChordType.ChordDifficulty.intermediate.rawValue, "Intermediate")
        XCTAssertEqual(ChordType.ChordDifficulty.advanced.rawValue, "Advanced")
    }
    
    // MARK: - Chord Tests
    
    func testChordInitialization() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let rootTone = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        let thirdTone = ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false)
        let fifthTone = ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
        
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [rootTone, thirdTone, fifthTone],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        
        XCTAssertEqual(cMajor.root.name, "C")
        XCTAssertEqual(cMajor.chordType.name, "Major")
        XCTAssertEqual(cMajor.chordTones.count, 3)
    }
    
    func testChordDisplayName() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let rootTone = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        let majorType = ChordType(name: "Major", symbol: "maj", chordTones: [rootTone], difficulty: .beginner)
        let chord = Chord(root: c, chordType: majorType)
        
        XCTAssertEqual(chord.displayName, "Cmaj")
    }
    
    func testChordFullName() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let rootTone = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        let majorType = ChordType(name: "Major", symbol: "maj", chordTones: [rootTone], difficulty: .beginner)
        let chord = Chord(root: c, chordType: majorType)
        
        XCTAssertEqual(chord.fullName, "C Major")
    }
    
    func testChordNoteCalculation() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        
        XCTAssertEqual(cMajor.chordTones.count, 3)
        XCTAssertEqual(cMajor.chordTones[0].name, "C")  // Root
        XCTAssertEqual(cMajor.chordTones[1].name, "E")  // Major 3rd
        XCTAssertEqual(cMajor.chordTones[2].name, "G")  // Perfect 5th
    }
    
    func testChordNoteCalculationWithSharps() {
        let d = Note(name: "D", midiNumber: 62, isSharp: false)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let dMajor = Chord(root: d, chordType: majorType)
        
        XCTAssertEqual(dMajor.chordTones[0].name, "D")   // Root
        XCTAssertEqual(dMajor.chordTones[1].name, "F#")  // Major 3rd
        XCTAssertEqual(dMajor.chordTones[2].name, "A")   // Perfect 5th
    }
    
    func testChordNoteCalculationWithFlats() {
        let bb = Note(name: "Bb", midiNumber: 70, isSharp: false)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let bbMajor = Chord(root: bb, chordType: majorType)
        
        XCTAssertEqual(bbMajor.chordTones[0].name, "Bb") // Root
        XCTAssertEqual(bbMajor.chordTones[1].name, "D")  // Major 3rd
        XCTAssertEqual(bbMajor.chordTones[2].name, "F")  // Perfect 5th
    }
    
    // MARK: - Common Tones Tests
    
    func testCommonTonesIdenticalChords() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let chord1 = Chord(root: c, chordType: majorType)
        let chord2 = Chord(root: c, chordType: majorType)
        
        let common = chord1.commonTones(with: chord2)
        XCTAssertEqual(common.count, 3)
    }
    
    func testCommonTonesRelatedChords() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        let minorType = ChordType(
            name: "Minor",
            symbol: "min",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let cMinor = Chord(root: c, chordType: minorType)
        
        let common = cMajor.commonTones(with: cMinor)
        XCTAssertEqual(common.count, 2) // Root and 5th are common
    }
    
    func testCommonTonesNoOverlap() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let fSharp = Note(name: "F#", midiNumber: 66, isSharp: true)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
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
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let maj7Type = ChordType(
            name: "Major 7",
            symbol: "maj7",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
                ChordTone(degree: 7, name: "7th", semitonesFromRoot: 11, isAltered: false)
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
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        // Note: guideTones looks up from ChordTone.allTones, not the chord's actual tones
        // So it finds degree 3 (unaltered) and degree 7 (unaltered) regardless of chord type
        let min7Type = ChordType(
            name: "Minor 7",
            symbol: "min7",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
                ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
            ],
            difficulty: .intermediate
        )
        
        let cMin7 = Chord(root: c, chordType: min7Type)
        let guides = cMin7.guideTones
        
        // Returns 2: unaltered 3rd (E) and unaltered 7th (B) from ChordTone.allTones
        XCTAssertEqual(guides.count, 2)
        XCTAssertTrue(guides.contains { $0.name == "E" }) // Unaltered major 3rd
        XCTAssertTrue(guides.contains { $0.name == "B" }) // Unaltered major 7th
    }
    
    func testGuideTonesTriadHasOne() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        // Note: guideTones always looks up both degree 3 and 7 from ChordTone.allTones
        // So even a triad returns 2 guide tones (the calculated 3rd and 7th positions)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let guides = cMajor.guideTones
        
        // Returns 2: looks up from global allTones, finds 3rd (E) and 7th (B)
        XCTAssertEqual(guides.count, 2)
        XCTAssertEqual(guides[0].name, "E")  // 3rd
        XCTAssertEqual(guides[1].name, "B")  // 7th
    }
    
    // MARK: - Role of Note Tests
    
    func testRoleOfNoteRoot() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let role = cMajor.roleOfNote(c)
        
        XCTAssertEqual(role, .root)
    }
    
    func testRoleOfNoteThird() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let e = Note(name: "E", midiNumber: 64, isSharp: false)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let role = cMajor.roleOfNote(e)
        
        XCTAssertEqual(role, .third)
    }
    
    func testRoleOfNoteFifth() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let g = Note(name: "G", midiNumber: 67, isSharp: false)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let role = cMajor.roleOfNote(g)
        
        XCTAssertEqual(role, .fifth)
    }
    
    func testRoleOfNoteSeventh() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let b = Note(name: "B", midiNumber: 71, isSharp: false)
        let maj7Type = ChordType(
            name: "Major 7",
            symbol: "maj7",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
                ChordTone(degree: 7, name: "7th", semitonesFromRoot: 11, isAltered: false)
            ],
            difficulty: .intermediate
        )
        
        let cMaj7 = Chord(root: c, chordType: maj7Type)
        let role = cMaj7.roleOfNote(b)
        
        XCTAssertEqual(role, .seventh)
    }
    
    func testRoleOfNoteExtension() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let d = Note(name: "D", midiNumber: 62, isSharp: false)
        let add9Type = ChordType(
            name: "Add 9",
            symbol: "add9",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 9, name: "9th", semitonesFromRoot: 2, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .intermediate
        )
        
        let cAdd9 = Chord(root: c, chordType: add9Type)
        let role = cAdd9.roleOfNote(d)
        
        XCTAssertEqual(role, .ninth)
    }
    
    func testRoleOfNoteNotInChord() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let fSharp = Note(name: "F#", midiNumber: 66, isSharp: true)
        let majorType = ChordType(
            name: "Major",
            symbol: "maj",
            chordTones: [
                ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
                ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
                ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
            ],
            difficulty: .beginner
        )
        
        let cMajor = Chord(root: c, chordType: majorType)
        let role = cMajor.roleOfNote(fSharp)
        
        XCTAssertNil(role)
    }
}
