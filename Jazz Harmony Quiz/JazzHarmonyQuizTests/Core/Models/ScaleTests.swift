import XCTest
@testable import JazzHarmonyQuiz

final class ScaleTests: XCTestCase {
    
    // MARK: - ScaleDegree Tests
    
    func testScaleDegreeBasics() {
        let root = ScaleDegree.root
        XCTAssertEqual(root.degree, 1)
        XCTAssertEqual(root.name, "Root")
        XCTAssertEqual(root.semitonesFromRoot, 0)
        XCTAssertFalse(root.isAltered)
    }
    
    func testScaleDegreeAlterations() {
        XCTAssertTrue(ScaleDegree.flatTwo.isAltered)
        XCTAssertTrue(ScaleDegree.sharpTwo.isAltered)
        XCTAssertFalse(ScaleDegree.second.isAltered)
        
        XCTAssertTrue(ScaleDegree.flatThird.isAltered)
        XCTAssertFalse(ScaleDegree.third.isAltered)
        
        XCTAssertTrue(ScaleDegree.sharpFour.isAltered)
        XCTAssertTrue(ScaleDegree.flatFive.isAltered)
        XCTAssertFalse(ScaleDegree.fifth.isAltered)
    }
    
    func testScaleDegreeIntervals() {
        XCTAssertEqual(ScaleDegree.root.semitonesFromRoot, 0)
        XCTAssertEqual(ScaleDegree.flatTwo.semitonesFromRoot, 1)
        XCTAssertEqual(ScaleDegree.second.semitonesFromRoot, 2)
        XCTAssertEqual(ScaleDegree.flatThird.semitonesFromRoot, 3)
        XCTAssertEqual(ScaleDegree.third.semitonesFromRoot, 4)
        XCTAssertEqual(ScaleDegree.fourth.semitonesFromRoot, 5)
        XCTAssertEqual(ScaleDegree.sharpFour.semitonesFromRoot, 6)
        XCTAssertEqual(ScaleDegree.fifth.semitonesFromRoot, 7)
        XCTAssertEqual(ScaleDegree.flatSix.semitonesFromRoot, 8)
        XCTAssertEqual(ScaleDegree.sixth.semitonesFromRoot, 9)
        XCTAssertEqual(ScaleDegree.flatSeven.semitonesFromRoot, 10)
        XCTAssertEqual(ScaleDegree.seventh.semitonesFromRoot, 11)
        XCTAssertEqual(ScaleDegree.octave.semitonesFromRoot, 12)
    }
    
    // MARK: - ScaleType Tests
    
    func testScaleTypeCreation() {
        let majorDegrees = [
            ScaleDegree.root,
            ScaleDegree.second,
            ScaleDegree.third,
            ScaleDegree.fourth,
            ScaleDegree.fifth,
            ScaleDegree.sixth,
            ScaleDegree.seventh,
            ScaleDegree.octave
        ]
        
        let major = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: majorDegrees,
            difficulty: .beginner,
            description: "The major scale"
        )
        
        XCTAssertEqual(major.name, "Major")
        XCTAssertEqual(major.symbol, "Maj")
        XCTAssertEqual(major.degrees.count, 8)
        XCTAssertEqual(major.difficulty, .beginner)
        XCTAssertEqual(major.description, "The major scale")
    }
    
    func testScaleDifficultyLevels() {
        XCTAssertEqual(ScaleType.ScaleDifficulty.beginner.rawValue, "Beginner")
        XCTAssertEqual(ScaleType.ScaleDifficulty.intermediate.rawValue, "Intermediate")
        XCTAssertEqual(ScaleType.ScaleDifficulty.advanced.rawValue, "Advanced")
        XCTAssertEqual(ScaleType.ScaleDifficulty.custom.rawValue, "Custom")
    }
    
    func testScaleDifficultyDescriptions() {
        XCTAssertEqual(ScaleType.ScaleDifficulty.beginner.description, "Major, Minor, Pentatonic")
        XCTAssertEqual(ScaleType.ScaleDifficulty.intermediate.description, "Modes, Blues, Melodic Minor")
        XCTAssertEqual(ScaleType.ScaleDifficulty.advanced.description, "All scale types")
        XCTAssertEqual(ScaleType.ScaleDifficulty.custom.description, "Choose your own scale types")
    }
    
    // MARK: - Scale Tests - Major Scale
    
    func testCMajorScale() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave],
            difficulty: .beginner
        )
        
        let cMajor = Scale(root: c, scaleType: majorType)
        
        XCTAssertEqual(cMajor.root.name, "C")
        XCTAssertEqual(cMajor.displayName, "C Major")
        XCTAssertEqual(cMajor.shortName, "C Maj")
        XCTAssertEqual(cMajor.scaleNotes.count, 8)
        
        let noteNames = cMajor.scaleNotes.map { $0.name }
        XCTAssertEqual(noteNames, ["C", "D", "E", "F", "G", "A", "B", "C"])
    }
    
    func testGMajorScaleUsesSharps() {
        let g = Note(name: "G", midiNumber: 67, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave],
            difficulty: .beginner
        )
        
        let gMajor = Scale(root: g, scaleType: majorType)
        let noteNames = gMajor.scaleNotes.map { $0.name }
        
        XCTAssertEqual(noteNames, ["G", "A", "B", "C", "D", "E", "F#", "G"])
        XCTAssertTrue(noteNames.contains("F#"), "G major should use F#, not Gb")
    }
    
    func testFMajorScaleUsesFlats() {
        let f = Note(name: "F", midiNumber: 65, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave],
            difficulty: .beginner
        )
        
        let fMajor = Scale(root: f, scaleType: majorType)
        let noteNames = fMajor.scaleNotes.map { $0.name }
        
        XCTAssertEqual(noteNames, ["F", "G", "A", "Bb", "C", "D", "E", "F"])
        XCTAssertTrue(noteNames.contains("Bb"), "F major should use Bb, not A#")
    }
    
    func testDbMajorScaleUsesFlats() {
        let db = Note(name: "Db", midiNumber: 61, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave],
            difficulty: .beginner
        )
        
        let dbMajor = Scale(root: db, scaleType: majorType)
        let noteNames = dbMajor.scaleNotes.map { $0.name }
        
        // Db major: Db Eb F Gb Ab Bb C Db
        XCTAssertTrue(noteNames.contains("Db"))
        XCTAssertTrue(noteNames.contains("Eb"))
        XCTAssertTrue(noteNames.contains("Gb"))
        XCTAssertTrue(noteNames.contains("Ab"))
        XCTAssertTrue(noteNames.contains("Bb"))
        XCTAssertFalse(noteNames.contains("C#"))
        XCTAssertFalse(noteNames.contains("D#"))
    }
    
    // MARK: - Scale Tests - Minor Scale
    
    func testAMinorScale() {
        let a = Note(name: "A", midiNumber: 69, isSharp: false)
        let minorType = ScaleType(
            name: "Natural Minor",
            symbol: "Min",
            degrees: [.root, .second, .flatThird, .fourth, .fifth, .flatSix, .flatSeven, .octave],
            difficulty: .beginner
        )
        
        let aMinor = Scale(root: a, scaleType: minorType)
        let noteNames = aMinor.scaleNotes.map { $0.name }
        
        XCTAssertEqual(noteNames, ["A", "B", "C", "D", "E", "F", "G", "A"])
    }
    
    func testDMinorScaleUsesFlats() {
        let d = Note(name: "D", midiNumber: 62, isSharp: false)
        let minorType = ScaleType(
            name: "Natural Minor",
            symbol: "Min",
            degrees: [.root, .second, .flatThird, .fourth, .fifth, .flatSix, .flatSeven, .octave],
            difficulty: .beginner
        )
        
        let dMinor = Scale(root: d, scaleType: minorType)
        let noteNames = dMinor.scaleNotes.map { $0.name }
        
        // D minor (relative to F major): D E F G A Bb C D
        XCTAssertTrue(noteNames.contains("Bb"), "D minor should use Bb")
        XCTAssertFalse(noteNames.contains("A#"), "D minor should not use A#")
    }
    
    func testEMinorScaleUsesSharps() {
        let e = Note(name: "E", midiNumber: 64, isSharp: false)
        let minorType = ScaleType(
            name: "Natural Minor",
            symbol: "Min",
            degrees: [.root, .second, .flatThird, .fourth, .fifth, .flatSix, .flatSeven, .octave],
            difficulty: .beginner
        )
        
        let eMinor = Scale(root: e, scaleType: minorType)
        let noteNames = eMinor.scaleNotes.map { $0.name }
        
        // E minor (relative to G major): E F# G A B C D E
        XCTAssertTrue(noteNames.contains("F#"), "E minor should use F#")
        XCTAssertFalse(noteNames.contains("Gb"), "E minor should not use Gb")
    }
    
    // MARK: - Scale Note Retrieval
    
    func testNoteForDegree() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave],
            difficulty: .beginner
        )
        
        let cMajor = Scale(root: c, scaleType: majorType)
        
        XCTAssertEqual(cMajor.note(for: .root)?.name, "C")
        XCTAssertEqual(cMajor.note(for: .second)?.name, "D")
        XCTAssertEqual(cMajor.note(for: .third)?.name, "E")
        XCTAssertEqual(cMajor.note(for: .fourth)?.name, "F")
        XCTAssertEqual(cMajor.note(for: .fifth)?.name, "G")
        XCTAssertEqual(cMajor.note(for: .sixth)?.name, "A")
        XCTAssertEqual(cMajor.note(for: .seventh)?.name, "B")
        XCTAssertEqual(cMajor.note(for: .octave)?.name, "C")
    }
    
    func testNoteForDegreeNotInScale() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave],
            difficulty: .beginner
        )
        
        let cMajor = Scale(root: c, scaleType: majorType)
        
        // flatThird is not in major scale
        XCTAssertNil(cMajor.note(for: .flatThird))
    }
    
    // MARK: - Scale Direction Methods
    
    func testNotesAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave],
            difficulty: .beginner
        )
        
        let cMajor = Scale(root: c, scaleType: majorType)
        let ascending = cMajor.notesAscending()
        let noteNames = ascending.map { $0.name }
        
        XCTAssertEqual(noteNames, ["C", "D", "E", "F", "G", "A", "B", "C"])
    }
    
    func testNotesDescending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave],
            difficulty: .beginner
        )
        
        let cMajor = Scale(root: c, scaleType: majorType)
        let descending = cMajor.notesDescending()
        let noteNames = descending.map { $0.name }
        
        XCTAssertEqual(noteNames, ["C", "B", "A", "G", "F", "E", "D", "C"])
    }
    
    func testNotesAscendingDescending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave],
            difficulty: .beginner
        )
        
        let cMajor = Scale(root: c, scaleType: majorType)
        let ascDesc = cMajor.notesAscendingDescending()
        let noteNames = ascDesc.map { $0.name }
        
        // Should go up then back down, excluding duplicate octave and ending root
        // C D E F G A B C B A G F E D
        XCTAssertEqual(noteNames.first, "C")
        XCTAssertEqual(noteNames.last, "D")
        XCTAssertTrue(noteNames.count > 8) // More than just ascending
    }
    
    // MARK: - Chromatic and Altered Scales
    
    func testChromaticScale() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let chromaticType = ScaleType(
            name: "Chromatic",
            symbol: "Chrom",
            degrees: [
                .root, .flatTwo, .second, .flatThird, .third, .fourth,
                .sharpFour, .fifth, .flatSix, .sixth, .flatSeven, .seventh, .octave
            ],
            difficulty: .advanced
        )
        
        let cChromatic = Scale(root: c, scaleType: chromaticType)
        
        XCTAssertEqual(cChromatic.scaleNotes.count, 13) // 12 semitones + octave
    }
    
    func testDorianMode() {
        let d = Note(name: "D", midiNumber: 62, isSharp: false)
        let dorianType = ScaleType(
            name: "Dorian",
            symbol: "Dor",
            degrees: [.root, .second, .flatThird, .fourth, .fifth, .sixth, .flatSeven, .octave],
            difficulty: .intermediate
        )
        
        let dDorian = Scale(root: d, scaleType: dorianType)
        let noteNames = dDorian.scaleNotes.map { $0.name }
        
        // D Dorian: D E F G A B C D (same notes as C major, starting on D)
        XCTAssertEqual(noteNames.count, 8)
        XCTAssertEqual(noteNames.first, "D")
        XCTAssertEqual(noteNames.last, "D")
    }
    
    // MARK: - Hashable & Codable
    
    func testScaleEquality() {
        // Scale uses auto-generated UUID for id, so two Scale instances are NOT equal
        // even with the same root and scaleType. This tests the actual behavior.
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third],
            difficulty: .beginner
        )
        
        let scale1 = Scale(root: c, scaleType: majorType)
        let scale2 = Scale(root: c, scaleType: majorType)
        
        // Each Scale instance has unique UUID, so they are NOT equal
        XCTAssertNotEqual(scale1, scale2, "Scale instances with different UUIDs should not be equal")
        
        // But the same instance equals itself
        XCTAssertEqual(scale1, scale1)
    }
    
    func testScaleCodable() throws {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = ScaleType(
            name: "Major",
            symbol: "Maj",
            degrees: [.root, .second, .third],
            difficulty: .beginner,
            description: "Test"
        )
        
        let original = Scale(root: c, scaleType: majorType)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Scale.self, from: data)
        
        XCTAssertEqual(decoded.root.name, original.root.name)
        XCTAssertEqual(decoded.scaleType.name, original.scaleType.name)
        XCTAssertEqual(decoded.scaleNotes.count, original.scaleNotes.count)
    }
}
