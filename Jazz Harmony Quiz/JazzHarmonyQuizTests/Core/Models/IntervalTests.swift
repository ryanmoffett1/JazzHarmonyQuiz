import XCTest
@testable import JazzHarmonyQuiz

final class IntervalTests: XCTestCase {
    
    // MARK: - IntervalQuality Tests
    
    func testIntervalQualityRawValues() {
        XCTAssertEqual(IntervalQuality.perfect.rawValue, "Perfect")
        XCTAssertEqual(IntervalQuality.major.rawValue, "Major")
        XCTAssertEqual(IntervalQuality.minor.rawValue, "Minor")
        XCTAssertEqual(IntervalQuality.augmented.rawValue, "Augmented")
        XCTAssertEqual(IntervalQuality.diminished.rawValue, "Diminished")
    }
    
    // MARK: - IntervalDifficulty Tests
    
    func testIntervalDifficultyLevels() {
        XCTAssertEqual(IntervalDifficulty.beginner.rawValue, "Beginner")
        XCTAssertEqual(IntervalDifficulty.intermediate.rawValue, "Intermediate")
        XCTAssertEqual(IntervalDifficulty.advanced.rawValue, "Advanced")
    }
    
    // MARK: - IntervalType Tests
    
    func testIntervalTypeCreation() {
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        XCTAssertEqual(perfectFifth.name, "Perfect 5th")
        XCTAssertEqual(perfectFifth.shortName, "P5")
        XCTAssertEqual(perfectFifth.semitones, 7)
        XCTAssertEqual(perfectFifth.quality, .perfect)
        XCTAssertEqual(perfectFifth.difficulty, .beginner)
    }
    
    func testIntervalTypeDisplayName() {
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        XCTAssertEqual(perfectFifth.displayName, "Perfect 5th (P5)")
    }
    
    // MARK: - IntervalDirection Tests
    
    func testIntervalDirectionValues() {
        XCTAssertEqual(IntervalDirection.ascending.rawValue, "Ascending")
        XCTAssertEqual(IntervalDirection.descending.rawValue, "Descending")
        XCTAssertEqual(IntervalDirection.harmonic.rawValue, "Harmonic")
    }
    
    // MARK: - Interval Tests - Basic Construction
    
    func testIntervalAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let interval = Interval(
            rootNote: c,
            intervalType: perfectFifth,
            direction: .ascending
        )
        
        XCTAssertEqual(interval.startNote.name, "C")
        XCTAssertEqual(interval.intervalType.name, "Perfect 5th")
        XCTAssertEqual(interval.direction, .ascending)
        XCTAssertEqual(interval.targetNote.name, "G")
    }
    
    func testIntervalDescending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let interval = Interval(
            rootNote: c,
            intervalType: perfectFifth,
            direction: .descending
        )
        
        XCTAssertEqual(interval.startNote.name, "C")
        XCTAssertEqual(interval.targetNote.name, "F")
    }
    
    func testIntervalHarmonic() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorThird = IntervalType(
            name: "Major 3rd",
            shortName: "M3",
            semitones: 4,
            quality: .major,
            difficulty: .beginner
        )
        
        let interval = Interval(
            rootNote: c,
            intervalType: majorThird,
            direction: .harmonic
        )
        
        XCTAssertEqual(interval.startNote.name, "C")
        XCTAssertEqual(interval.targetNote.name, "E")
        XCTAssertEqual(interval.direction, .harmonic)
    }
    
    // MARK: - Target Note Calculation Tests
    
    func testMajorThirdAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorThird = IntervalType(
            name: "Major 3rd",
            shortName: "M3",
            semitones: 4,
            quality: .major,
            difficulty: .beginner
        )
        
        let interval = Interval(rootNote: c, intervalType: majorThird, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "E")
    }
    
    func testMinorThirdAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let minorThird = IntervalType(
            name: "Minor 3rd",
            shortName: "m3",
            semitones: 3,
            quality: .minor,
            difficulty: .intermediate
        )
        
        let interval = Interval(rootNote: c, intervalType: minorThird, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "Eb")
    }
    
    func testPerfectFourthAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let perfectFourth = IntervalType(
            name: "Perfect 4th",
            shortName: "P4",
            semitones: 5,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let interval = Interval(rootNote: c, intervalType: perfectFourth, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "F")
    }
    
    func testTritoneAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let tritone = IntervalType(
            name: "Tritone",
            shortName: "TT",
            semitones: 6,
            quality: .augmented,
            difficulty: .advanced
        )
        
        let interval = Interval(rootNote: c, intervalType: tritone, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "F#")
    }
    
    func testOctaveAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let octave = IntervalType(
            name: "Octave",
            shortName: "P8",
            semitones: 12,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let interval = Interval(rootNote: c, intervalType: octave, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "C")
        XCTAssertEqual(interval.targetNote.midiNumber, 72)
    }
    
    func testMajorSeventhAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorSeventh = IntervalType(
            name: "Major 7th",
            shortName: "M7",
            semitones: 11,
            quality: .major,
            difficulty: .intermediate
        )
        
        let interval = Interval(rootNote: c, intervalType: majorSeventh, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "B")
    }
    
    func testMinorSeventhAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let minorSeventh = IntervalType(
            name: "Minor 7th",
            shortName: "m7",
            semitones: 10,
            quality: .minor,
            difficulty: .intermediate
        )
        
        let interval = Interval(rootNote: c, intervalType: minorSeventh, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "Bb")
    }
    
    // MARK: - Descending Interval Tests
    
    func testMajorThirdDescending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorThird = IntervalType(
            name: "Major 3rd",
            shortName: "M3",
            semitones: 4,
            quality: .major,
            difficulty: .beginner
        )
        
        let interval = Interval(rootNote: c, intervalType: majorThird, direction: .descending)
        XCTAssertEqual(interval.targetNote.name, "Ab")
    }
    
    func testPerfectFifthDescending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let interval = Interval(rootNote: c, intervalType: perfectFifth, direction: .descending)
        XCTAssertEqual(interval.targetNote.name, "F")
    }
    
    func testOctaveDescending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let octave = IntervalType(
            name: "Octave",
            shortName: "P8",
            semitones: 12,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let interval = Interval(rootNote: c, intervalType: octave, direction: .descending)
        XCTAssertEqual(interval.targetNote.name, "C")
        XCTAssertEqual(interval.targetNote.midiNumber, 48)
    }
    
    // MARK: - Sharp and Flat Root Note Tests
    
    func testIntervalFromSharpRoot() {
        let cSharp = Note(name: "C#", midiNumber: 61, isSharp: true, isSharp: true)
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let interval = Interval(rootNote: cSharp, intervalType: perfectFifth, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "G#")
    }
    
    func testIntervalFromFlatRoot() {
        let db = Note(name: "Db", midiNumber: 61, isSharp: true)
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let interval = Interval(rootNote: db, intervalType: perfectFifth, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "Ab")
    }
    
    func testIntervalPreservesAccidentalPreference() {
        // If start note is sharp, target should prefer sharps
        let fSharp = Note(name: "F#", midiNumber: 66, pitchClass: 6, isSharp: true)
        let majorSecond = IntervalType(
            name: "Major 2nd",
            shortName: "M2",
            semitones: 2,
            quality: .major,
            difficulty: .beginner
        )
        
        let interval = Interval(rootNote: fSharp, intervalType: majorSecond, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "G#")
        
        // If start note is flat, target should prefer flats
        let gb = Note(name: "Gb", midiNumber: 66, pitchClass: 6)
        let interval2 = Interval(rootNote: gb, intervalType: majorSecond, direction: .ascending)
        XCTAssertEqual(interval2.targetNote.name, "Ab")
    }
    
    // MARK: - Display Name Tests
    
    func testIntervalDisplayName() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let ascending = Interval(rootNote: c, intervalType: perfectFifth, direction: .ascending)
        XCTAssertEqual(ascending.displayName, "C → G (Perfect 5th)")
        
        let descending = Interval(rootNote: c, intervalType: perfectFifth, direction: .descending)
        XCTAssertEqual(descending.displayName, "C → F (Perfect 5th)")
        
        let harmonic = Interval(rootNote: c, intervalType: perfectFifth, direction: .harmonic)
        XCTAssertEqual(harmonic.displayName, "C + G (Perfect 5th)")
    }
    
    // MARK: - Compound Intervals
    
    func testMajorNinthAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorNinth = IntervalType(
            name: "Major 9th",
            shortName: "M9",
            semitones: 14,
            quality: .major,
            difficulty: .advanced
        )
        
        let interval = Interval(rootNote: c, intervalType: majorNinth, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "D")
        XCTAssertEqual(interval.targetNote.midiNumber, 74) // One octave + major 2nd
    }
    
    func testMajorThirteenthAscending() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorThirteenth = IntervalType(
            name: "Major 13th",
            shortName: "M13",
            semitones: 21,
            quality: .major,
            difficulty: .advanced
        )
        
        let interval = Interval(rootNote: c, intervalType: majorThirteenth, direction: .ascending)
        XCTAssertEqual(interval.targetNote.name, "A")
        XCTAssertEqual(interval.targetNote.midiNumber, 81) // One octave + major 6th
    }
    
    // MARK: - Hashable & Codable
    
    func testIntervalEquality() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let interval1 = Interval(rootNote: c, intervalType: perfectFifth, direction: .ascending)
        let interval2 = Interval(rootNote: c, intervalType: perfectFifth, direction: .ascending)
        
        XCTAssertEqual(interval1, interval2)
    }
    
    func testIntervalCodable() throws {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let perfectFifth = IntervalType(
            name: "Perfect 5th",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            difficulty: .beginner
        )
        
        let original = Interval(rootNote: c, intervalType: perfectFifth, direction: .ascending)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(Interval.self, from: data)
        
        XCTAssertEqual(decoded.startNote.name, original.startNote.name)
        XCTAssertEqual(decoded.targetNote.name, original.targetNote.name)
        XCTAssertEqual(decoded.intervalType.name, original.intervalType.name)
        XCTAssertEqual(decoded.direction, original.direction)
    }
}
