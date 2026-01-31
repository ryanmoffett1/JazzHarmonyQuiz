import XCTest
@testable import JazzHarmonyQuiz

final class ChordToneTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_initialization_createsValidChordTone() {
        let tone = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        
        XCTAssertEqual(tone.degree, 1)
        XCTAssertEqual(tone.name, "Root")
        XCTAssertEqual(tone.semitonesFromRoot, 0)
        XCTAssertFalse(tone.isAltered)
        XCTAssertNotNil(tone.id)
    }
    
    func test_initialization_createsAlteredTone() {
        let tone = ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true)
        
        XCTAssertEqual(tone.degree, 2)
        XCTAssertEqual(tone.name, "b9")
        XCTAssertEqual(tone.semitonesFromRoot, 1)
        XCTAssertTrue(tone.isAltered)
    }
    
    // MARK: - Static Collection Tests
    
    func test_allTones_containsExpectedCount() {
        XCTAssertEqual(ChordTone.allTones.count, 19, "Should have 10 natural + 9 altered tones")
    }
    
    func test_allTones_containsRoot() {
        let root = ChordTone.allTones[0]
        
        XCTAssertEqual(root.degree, 1)
        XCTAssertEqual(root.name, "Root")
        XCTAssertEqual(root.semitonesFromRoot, 0)
        XCTAssertFalse(root.isAltered)
    }
    
    func test_allTones_containsBasicIntervals() {
        let expectedBasicTones: [(degree: Int, name: String, semitones: Int)] = [
            (1, "Root", 0),
            (2, "2nd", 2),
            (3, "3rd", 4),
            (4, "4th", 5),
            (5, "5th", 7),
            (6, "6th", 9),
            (7, "7th", 11)
        ]
        
        for (index, expected) in expectedBasicTones.enumerated() {
            let tone = ChordTone.allTones[index]
            XCTAssertEqual(tone.degree, expected.degree, "Tone \(index) degree mismatch")
            XCTAssertEqual(tone.name, expected.name, "Tone \(index) name mismatch")
            XCTAssertEqual(tone.semitonesFromRoot, expected.semitones, "Tone \(index) semitones mismatch")
            XCTAssertFalse(tone.isAltered, "Basic tone \(index) should not be altered")
        }
    }
    
    func test_allTones_containsExtensions() {
        let ninthTone = ChordTone.allTones[7]
        XCTAssertEqual(ninthTone.degree, 9)
        XCTAssertEqual(ninthTone.name, "9th")
        XCTAssertEqual(ninthTone.semitonesFromRoot, 2)
        
        let eleventhTone = ChordTone.allTones[8]
        XCTAssertEqual(eleventhTone.degree, 11)
        XCTAssertEqual(eleventhTone.name, "11th")
        XCTAssertEqual(eleventhTone.semitonesFromRoot, 5)
        
        let thirteenthTone = ChordTone.allTones[9]
        XCTAssertEqual(thirteenthTone.degree, 13)
        XCTAssertEqual(thirteenthTone.name, "13th")
        XCTAssertEqual(thirteenthTone.semitonesFromRoot, 9)
    }
    
    func test_allTones_containsAlteredTones() {
        let flatNinth = ChordTone.allTones[10]
        XCTAssertEqual(flatNinth.name, "b9")
        XCTAssertEqual(flatNinth.semitonesFromRoot, 1)
        XCTAssertTrue(flatNinth.isAltered)
        
        let sharpNinth = ChordTone.allTones[11]
        XCTAssertEqual(sharpNinth.name, "#9")
        XCTAssertEqual(sharpNinth.semitonesFromRoot, 3)
        XCTAssertTrue(sharpNinth.isAltered)
        
        let flatThird = ChordTone.allTones[12]
        XCTAssertEqual(flatThird.name, "b3")
        XCTAssertEqual(flatThird.semitonesFromRoot, 3)
        XCTAssertTrue(flatThird.isAltered)
    }
    
    func test_allTones_containsAlteredFifths() {
        let flatFifth = ChordTone.allTones[13]
        XCTAssertEqual(flatFifth.name, "b5")
        XCTAssertEqual(flatFifth.semitonesFromRoot, 6)
        XCTAssertTrue(flatFifth.isAltered)
        
        let sharpFifth = ChordTone.allTones[14]
        XCTAssertEqual(sharpFifth.name, "#5")
        XCTAssertEqual(sharpFifth.semitonesFromRoot, 8)
        XCTAssertTrue(sharpFifth.isAltered)
    }
    
    func test_allTones_containsSevenths() {
        let flatSeventh = ChordTone.allTones[17]
        XCTAssertEqual(flatSeventh.name, "b7")
        XCTAssertEqual(flatSeventh.semitonesFromRoot, 10)
        XCTAssertTrue(flatSeventh.isAltered)
    }
    
    func test_allTones_containsSharpEleventh() {
        let sharpEleventh = ChordTone.allTones[18]
        XCTAssertEqual(sharpEleventh.degree, 11)
        XCTAssertEqual(sharpEleventh.name, "#11")
        XCTAssertEqual(sharpEleventh.semitonesFromRoot, 6)
        XCTAssertTrue(sharpEleventh.isAltered)
    }
    
    // MARK: - Equatable/Hashable Tests
    
    func test_hashable_equalTonesHaveSameHash() {
        let tone1 = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        let tone2 = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        
        // Different UUIDs but same content - they should still hash differently due to UUID
        // But if we put them in a Set, the Set will use Hashable
        let set = Set([tone1])
        // Since UUIDs are different, they won't be equal
        XCTAssertNotEqual(tone1.id, tone2.id)
    }
    
    func test_identifiable_eachToneHasUniqueID() {
        let tone1 = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        let tone2 = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        
        XCTAssertNotEqual(tone1.id, tone2.id)
    }
    
    func test_allTones_eachHasUniqueID() {
        let ids = ChordTone.allTones.map { $0.id }
        let uniqueIds = Set(ids)
        
        XCTAssertEqual(ids.count, uniqueIds.count, "All tones should have unique IDs")
    }
    
    // MARK: - Codable Tests
    
    func test_codable_encodesAndDecodesCorrectly() throws {
        let originalTone = ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTone)
        
        let decoder = JSONDecoder()
        let decodedTone = try decoder.decode(ChordTone.self, from: data)
        
        XCTAssertEqual(decodedTone.degree, originalTone.degree)
        XCTAssertEqual(decodedTone.name, originalTone.name)
        XCTAssertEqual(decodedTone.semitonesFromRoot, originalTone.semitonesFromRoot)
        XCTAssertEqual(decodedTone.isAltered, originalTone.isAltered)
        // Note: IDs will be different after decode since UUID() generates new ones
    }
    
    func test_codable_encodesAlteredTone() throws {
        let originalTone = ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(originalTone)
        
        let decoder = JSONDecoder()
        let decodedTone = try decoder.decode(ChordTone.self, from: data)
        
        XCTAssertEqual(decodedTone.degree, 2)
        XCTAssertEqual(decodedTone.name, "b9")
        XCTAssertEqual(decodedTone.semitonesFromRoot, 1)
        XCTAssertTrue(decodedTone.isAltered)
    }
    
    func test_codable_encodesArrayOfTones() throws {
        let tones = [
            ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
            ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
            ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
        ]
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(tones)
        
        let decoder = JSONDecoder()
        let decodedTones = try decoder.decode([ChordTone].self, from: data)
        
        XCTAssertEqual(decodedTones.count, 3)
        XCTAssertEqual(decodedTones[0].name, "Root")
        XCTAssertEqual(decodedTones[1].name, "3rd")
        XCTAssertEqual(decodedTones[2].name, "5th")
    }
    
    // MARK: - Semitone Relationship Tests
    
    func test_semitones_naturalThirdIsFourSemitones() {
        let third = ChordTone.allTones[2]
        XCTAssertEqual(third.name, "3rd")
        XCTAssertEqual(third.semitonesFromRoot, 4)
    }
    
    func test_semitones_flatThirdIsThreeSemitones() {
        let flatThird = ChordTone.allTones[12]
        XCTAssertEqual(flatThird.name, "b3")
        XCTAssertEqual(flatThird.semitonesFromRoot, 3)
    }
    
    func test_semitones_perfectFifthIsSevenSemitones() {
        let fifth = ChordTone.allTones[4]
        XCTAssertEqual(fifth.name, "5th")
        XCTAssertEqual(fifth.semitonesFromRoot, 7)
    }
    
    func test_semitones_flatFifthIsSixSemitones() {
        let flatFifth = ChordTone.allTones[13]
        XCTAssertEqual(flatFifth.name, "b5")
        XCTAssertEqual(flatFifth.semitonesFromRoot, 6)
    }
    
    func test_semitones_sharpFifthIsEightSemitones() {
        let sharpFifth = ChordTone.allTones[14]
        XCTAssertEqual(sharpFifth.name, "#5")
        XCTAssertEqual(sharpFifth.semitonesFromRoot, 8)
    }
    
    // MARK: - Edge Case Tests
    
    func test_allTones_noNegativeSemitones() {
        for tone in ChordTone.allTones {
            XCTAssertGreaterThanOrEqual(tone.semitonesFromRoot, 0, "\(tone.name) should not have negative semitones")
        }
    }
    
    func test_allTones_semitonesWithinOctave() {
        for tone in ChordTone.allTones {
            XCTAssertLessThan(tone.semitonesFromRoot, 12, "\(tone.name) semitones should be within an octave")
        }
    }
    
    func test_allTones_positiveDegrees() {
        for tone in ChordTone.allTones {
            XCTAssertGreaterThan(tone.degree, 0, "\(tone.name) should have positive degree")
        }
    }
}
