import XCTest
@testable import JazzHarmonyQuiz

final class ChordTypeTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_initialization_createsValidChordType() {
        let root = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        let third = ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false)
        let fifth = ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
        
        let chordType = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: [root, third, fifth],
            difficulty: .beginner
        )
        
        XCTAssertEqual(chordType.name, "Major Triad")
        XCTAssertEqual(chordType.symbol, "")
        XCTAssertEqual(chordType.chordTones.count, 3)
        XCTAssertEqual(chordType.difficulty, .beginner)
        XCTAssertNotNil(chordType.id)
    }
    
    func test_initialization_withSymbol() {
        let root = ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
        let flatThird = ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true)
        let fifth = ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
        let flatSeventh = ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
        
        let chordType = ChordType(
            name: "Minor Seventh",
            symbol: "m7",
            chordTones: [root, flatThird, fifth, flatSeventh],
            difficulty: .intermediate
        )
        
        XCTAssertEqual(chordType.name, "Minor Seventh")
        XCTAssertEqual(chordType.symbol, "m7")
        XCTAssertEqual(chordType.chordTones.count, 4)
        XCTAssertEqual(chordType.difficulty, .intermediate)
    }
    
    // MARK: - Difficulty Level Tests
    
    func test_difficulty_beginnerLevel() {
        let chordType = ChordType(
            name: "Major",
            symbol: "",
            chordTones: [],
            difficulty: .beginner
        )
        
        XCTAssertEqual(chordType.difficulty, .beginner)
        XCTAssertEqual(chordType.difficulty.rawValue, "Beginner")
    }
    
    func test_difficulty_intermediateLevel() {
        let chordType = ChordType(
            name: "Dominant 7th",
            symbol: "7",
            chordTones: [],
            difficulty: .intermediate
        )
        
        XCTAssertEqual(chordType.difficulty, .intermediate)
        XCTAssertEqual(chordType.difficulty.rawValue, "Intermediate")
    }
    
    func test_difficulty_advancedLevel() {
        let chordType = ChordType(
            name: "Altered Dominant",
            symbol: "7alt",
            chordTones: [],
            difficulty: .advanced
        )
        
        XCTAssertEqual(chordType.difficulty, .advanced)
        XCTAssertEqual(chordType.difficulty.rawValue, "Advanced")
    }
    
    func test_difficulty_expertLevel() {
        let chordType = ChordType(
            name: "Lydian Dominant",
            symbol: "7#11",
            chordTones: [],
            difficulty: .expert
        )
        
        XCTAssertEqual(chordType.difficulty, .expert)
        XCTAssertEqual(chordType.difficulty.rawValue, "Expert")
    }
    
    func test_difficulty_allCasesContainsFourLevels() {
        let allDifficulties = ChordType.ChordDifficulty.allCases
        XCTAssertEqual(allDifficulties.count, 4)
        XCTAssertTrue(allDifficulties.contains(.beginner))
        XCTAssertTrue(allDifficulties.contains(.intermediate))
        XCTAssertTrue(allDifficulties.contains(.advanced))
        XCTAssertTrue(allDifficulties.contains(.expert))
    }
    
    // MARK: - Chord Tones Tests
    
    func test_chordTones_emptyArray() {
        let chordType = ChordType(
            name: "Test",
            symbol: "test",
            chordTones: [],
            difficulty: .beginner
        )
        
        XCTAssertEqual(chordType.chordTones.count, 0)
        XCTAssertTrue(chordType.chordTones.isEmpty)
    }
    
    func test_chordTones_triad() {
        let tones = [
            ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
            ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
            ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
        ]
        
        let chordType = ChordType(
            name: "Major Triad",
            symbol: "",
            chordTones: tones,
            difficulty: .beginner
        )
        
        XCTAssertEqual(chordType.chordTones.count, 3)
        XCTAssertEqual(chordType.chordTones[0].name, "Root")
        XCTAssertEqual(chordType.chordTones[1].name, "3rd")
        XCTAssertEqual(chordType.chordTones[2].name, "5th")
    }
    
    func test_chordTones_seventh() {
        let tones = [
            ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
            ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
            ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
            ChordTone(degree: 7, name: "7th", semitonesFromRoot: 11, isAltered: false)
        ]
        
        let chordType = ChordType(
            name: "Major 7th",
            symbol: "maj7",
            chordTones: tones,
            difficulty: .intermediate
        )
        
        XCTAssertEqual(chordType.chordTones.count, 4)
    }
    
    func test_chordTones_extended() {
        let tones = [
            ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
            ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
            ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
            ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true),
            ChordTone(degree: 9, name: "9th", semitonesFromRoot: 2, isAltered: false),
            ChordTone(degree: 13, name: "13th", semitonesFromRoot: 9, isAltered: false)
        ]
        
        let chordType = ChordType(
            name: "Dominant 13th",
            symbol: "13",
            chordTones: tones,
            difficulty: .advanced
        )
        
        XCTAssertEqual(chordType.chordTones.count, 6)
        XCTAssertEqual(chordType.chordTones.last?.name, "13th")
    }
    
    func test_chordTones_withAlteredTones() {
        let tones = [
            ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
            ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
            ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true),
            ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true),
            ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true)
        ]
        
        let chordType = ChordType(
            name: "Altered Dominant",
            symbol: "7alt",
            chordTones: tones,
            difficulty: .expert
        )
        
        let alteredTones = chordType.chordTones.filter { $0.isAltered }
        XCTAssertEqual(alteredTones.count, 3)
    }
    
    // MARK: - Identifiable Tests
    
    func test_identifiable_eachInstanceHasUniqueID() {
        let chord1 = ChordType(name: "Test", symbol: "T", chordTones: [], difficulty: .beginner)
        let chord2 = ChordType(name: "Test", symbol: "T", chordTones: [], difficulty: .beginner)
        
        XCTAssertNotEqual(chord1.id, chord2.id)
    }
    
    func test_identifiable_idPersistsAcrossReads() {
        let chordType = ChordType(name: "Test", symbol: "T", chordTones: [], difficulty: .beginner)
        let id1 = chordType.id
        let id2 = chordType.id
        
        XCTAssertEqual(id1, id2)
    }
    
    // MARK: - Hashable Tests
    
    func test_hashable_canBeUsedInSet() {
        let chord1 = ChordType(name: "Major", symbol: "", chordTones: [], difficulty: .beginner)
        let chord2 = ChordType(name: "Minor", symbol: "m", chordTones: [], difficulty: .beginner)
        
        let set: Set<ChordType> = [chord1, chord2]
        XCTAssertEqual(set.count, 2)
    }
    
    func test_hashable_canBeUsedAsDictionaryKey() {
        let major = ChordType(name: "Major", symbol: "", chordTones: [], difficulty: .beginner)
        let minor = ChordType(name: "Minor", symbol: "m", chordTones: [], difficulty: .beginner)
        
        var dict: [ChordType: String] = [:]
        dict[major] = "Happy"
        dict[minor] = "Sad"
        
        XCTAssertEqual(dict.count, 2)
        XCTAssertEqual(dict[major], "Happy")
        XCTAssertEqual(dict[minor], "Sad")
    }
    
    // MARK: - Codable Tests
    
    func test_codable_encodesAndDecodesChordType() throws {
        let tones = [
            ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
            ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false)
        ]
        
        let original = ChordType(
            name: "Test Chord",
            symbol: "test",
            chordTones: tones,
            difficulty: .intermediate
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ChordType.self, from: data)
        
        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.symbol, original.symbol)
        XCTAssertEqual(decoded.chordTones.count, original.chordTones.count)
        XCTAssertEqual(decoded.difficulty, original.difficulty)
    }
    
    func test_codable_encodesArrayOfChordTypes() throws {
        let major = ChordType(name: "Major", symbol: "", chordTones: [], difficulty: .beginner)
        let minor = ChordType(name: "Minor", symbol: "m", chordTones: [], difficulty: .beginner)
        
        let chords = [major, minor]
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(chords)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode([ChordType].self, from: data)
        
        XCTAssertEqual(decoded.count, 2)
        XCTAssertEqual(decoded[0].name, "Major")
        XCTAssertEqual(decoded[1].name, "Minor")
    }
    
    func test_codable_preservesDifficulty() throws {
        let chord = ChordType(name: "Test", symbol: "T", chordTones: [], difficulty: .expert)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(chord)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ChordType.self, from: data)
        
        XCTAssertEqual(decoded.difficulty, .expert)
        XCTAssertEqual(decoded.difficulty.rawValue, "Expert")
    }
    
    // MARK: - Edge Case Tests
    
    func test_edgeCase_emptyName() {
        let chord = ChordType(name: "", symbol: "?", chordTones: [], difficulty: .beginner)
        XCTAssertEqual(chord.name, "")
        XCTAssertEqual(chord.symbol, "?")
    }
    
    func test_edgeCase_emptySymbol() {
        let chord = ChordType(name: "No Symbol", symbol: "", chordTones: [], difficulty: .beginner)
        XCTAssertEqual(chord.name, "No Symbol")
        XCTAssertEqual(chord.symbol, "")
    }
    
    func test_edgeCase_veryLongName() {
        let longName = String(repeating: "A", count: 1000)
        let chord = ChordType(name: longName, symbol: "L", chordTones: [], difficulty: .beginner)
        XCTAssertEqual(chord.name.count, 1000)
    }
    
    func test_edgeCase_specialCharactersInName() {
        let chord = ChordType(name: "C#m7♭5", symbol: "ø", chordTones: [], difficulty: .advanced)
        XCTAssertEqual(chord.name, "C#m7♭5")
        XCTAssertEqual(chord.symbol, "ø")
    }
}
