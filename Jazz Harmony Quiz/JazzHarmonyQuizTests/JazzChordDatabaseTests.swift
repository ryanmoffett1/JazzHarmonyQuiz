import XCTest
@testable import JazzHarmonyQuiz

final class JazzChordDatabaseTests: XCTestCase {
    
    var database: JazzChordDatabase!
    
    override func setUp() {
        super.setUp()
        database = JazzChordDatabase.shared
    }
    
    override func tearDown() {
        database = nil
        super.tearDown()
    }
    
    // MARK: - Database Initialization Tests
    
    func testDatabaseInitialization() {
        XCTAssertNotNil(database)
        XCTAssertFalse(database.chordTypes.isEmpty, "Database should have chord types")
    }
    
    func testChordTypesCount() {
        // Based on the implementation, there should be 30 chord types
        XCTAssertGreaterThanOrEqual(database.chordTypes.count, 30)
    }
    
    // MARK: - Chord Type Filtering Tests
    
    func testGetBeginnerChordTypes() {
        let beginnerChords = database.getChordTypes(by: .beginner)
        
        XCTAssertFalse(beginnerChords.isEmpty)
        
        // Verify all returned chords are beginner difficulty
        for chordType in beginnerChords {
            XCTAssertEqual(chordType.difficulty, .beginner)
        }
        
        // Should have at least 5 beginner chords (Major, Minor, Dom7, Maj7, Min7)
        XCTAssertGreaterThanOrEqual(beginnerChords.count, 5)
    }
    
    func testGetIntermediateChordTypes() {
        let intermediateChords = database.getChordTypes(by: .intermediate)
        
        XCTAssertFalse(intermediateChords.isEmpty)
        
        // Verify all returned chords are intermediate difficulty
        for chordType in intermediateChords {
            XCTAssertEqual(chordType.difficulty, .intermediate)
        }
    }
    
    func testGetAdvancedChordTypes() {
        let advancedChords = database.getChordTypes(by: .advanced)
        
        XCTAssertFalse(advancedChords.isEmpty)
        
        // Verify all returned chords are advanced difficulty
        for chordType in advancedChords {
            XCTAssertEqual(chordType.difficulty, .advanced)
        }
    }
    
    func testGetExpertChordTypes() {
        let expertChords = database.getChordTypes(by: .expert)
        
        XCTAssertFalse(expertChords.isEmpty)
        
        // Verify all returned chords are expert difficulty
        for chordType in expertChords {
            XCTAssertEqual(chordType.difficulty, .expert)
        }
    }
    
    // MARK: - Specific Chord Type Tests
    
    func testMajorTriadExists() {
        let majorTriad = database.chordTypes.first { $0.name == "Major Triad" }
        
        XCTAssertNotNil(majorTriad)
        XCTAssertEqual(majorTriad?.symbol, "")
        XCTAssertEqual(majorTriad?.difficulty, .beginner)
        XCTAssertEqual(majorTriad?.chordTones.count, 3)
    }
    
    func testDominant7thExists() {
        let dom7 = database.chordTypes.first { $0.name == "Dominant 7th" }
        
        XCTAssertNotNil(dom7)
        XCTAssertEqual(dom7?.symbol, "7")
        XCTAssertEqual(dom7?.difficulty, .beginner)
        XCTAssertEqual(dom7?.chordTones.count, 4)
    }
    
    func testHalfDiminishedExists() {
        let halfDim = database.chordTypes.first { $0.name == "Half Diminished 7th" }
        
        XCTAssertNotNil(halfDim)
        XCTAssertEqual(halfDim?.symbol, "m7b5")
        XCTAssertEqual(halfDim?.difficulty, .intermediate)
        XCTAssertEqual(halfDim?.chordTones.count, 4)
    }
    
    func testAlteredDominantExists() {
        let altered = database.chordTypes.first { $0.name == "Dominant 7th b9" }
        
        XCTAssertNotNil(altered)
        XCTAssertEqual(altered?.symbol, "7b9")
        XCTAssertEqual(altered?.difficulty, .advanced)
        XCTAssertEqual(altered?.chordTones.count, 5)
    }
    
    // MARK: - Chord Generation Tests
    
    func testGetAllChords() {
        let allChords = database.getAllChords()
        
        XCTAssertFalse(allChords.isEmpty)
        
        // Should have at least 17 roots * number of chord types
        let expectedMinimum = 17 * database.chordTypes.count
        XCTAssertGreaterThanOrEqual(allChords.count, expectedMinimum)
    }
    
    func testGetChordsContainsCMajor() {
        let allChords = database.getAllChords()
        
        let cMajor = allChords.first { chord in
            chord.root.name == "C" && chord.chordType.name == "Major Triad"
        }
        
        XCTAssertNotNil(cMajor)
        XCTAssertEqual(cMajor?.displayName, "C")
    }
    
    func testGetChordsContainsFSharpMinor7() {
        let allChords = database.getAllChords()
        
        let fSharpMin7 = allChords.first { chord in
            chord.root.name == "F#" && chord.chordType.name == "Minor 7th"
        }
        
        XCTAssertNotNil(fSharpMin7)
        XCTAssertEqual(fSharpMin7?.displayName, "F#m7")
    }
    
    func testGetChordsByDifficulty() {
        let beginnerChords = database.getChords(by: .beginner)
        
        XCTAssertFalse(beginnerChords.isEmpty)
        
        // All chords should have beginner difficulty
        for chord in beginnerChords {
            XCTAssertEqual(chord.chordType.difficulty, .beginner)
        }
        
        // Should have 17 roots * number of beginner chord types
        let beginnerTypes = database.getChordTypes(by: .beginner)
        XCTAssertEqual(beginnerChords.count, 17 * beginnerTypes.count)
    }
    
    // MARK: - Random Chord Tests
    
    func testGetRandomChord() {
        let randomChord = database.getRandomChord()
        
        XCTAssertNotNil(randomChord)
        XCTAssertNotNil(randomChord.root)
        XCTAssertNotNil(randomChord.chordType)
    }
    
    func testGetRandomChordWithDifficulty() {
        let randomBeginnerChord = database.getRandomChord(difficulty: .beginner)
        
        XCTAssertEqual(randomBeginnerChord.chordType.difficulty, .beginner)
    }
    
    func testGetMultipleRandomChordsAreDifferent() {
        // Get multiple random chords and verify they're not all identical
        var chords: Set<String> = []
        
        for _ in 0..<20 {
            let chord = database.getRandomChord()
            chords.insert(chord.displayName)
        }
        
        // Should have at least some variety in 20 random picks
        XCTAssertGreaterThan(chords.count, 1)
    }
    
    // MARK: - Random Chord Types Tests
    
    func testGetRandomChordTypes() {
        let randomTypes = database.getRandomChordTypes(count: 5)
        
        XCTAssertEqual(randomTypes.count, 5)
    }
    
    func testGetRandomChordTypesWithDifficulty() {
        let randomBeginnerTypes = database.getRandomChordTypes(count: 3, difficulty: .beginner)
        
        XCTAssertEqual(randomBeginnerTypes.count, 3)
        
        for chordType in randomBeginnerTypes {
            XCTAssertEqual(chordType.difficulty, .beginner)
        }
    }
    
    func testGetRandomChordTypesDoesNotExceedAvailable() {
        let beginnerTypes = database.getChordTypes(by: .beginner)
        let requestedCount = beginnerTypes.count + 10
        
        let randomTypes = database.getRandomChordTypes(count: requestedCount, difficulty: .beginner)
        
        // Should not return more than available
        XCTAssertLessThanOrEqual(randomTypes.count, beginnerTypes.count)
    }
    
    // MARK: - Chord Root Coverage Tests
    
    func testAllChordRootsCovered() {
        let allChords = database.getAllChords()
        
        // Check that we have both sharp and flat roots
        let rootNames = Set(allChords.map { $0.root.name })
        
        XCTAssertTrue(rootNames.contains("C"))
        XCTAssertTrue(rootNames.contains("C#"))
        XCTAssertTrue(rootNames.contains("Db"))
        XCTAssertTrue(rootNames.contains("F#"))
        XCTAssertTrue(rootNames.contains("Gb"))
        XCTAssertTrue(rootNames.contains("Bb"))
    }
    
    // MARK: - Chord Type Validation Tests
    
    func testAllChordTypesHaveValidStructure() {
        for chordType in database.chordTypes {
            XCTAssertFalse(chordType.name.isEmpty, "Chord type name should not be empty")
            XCTAssertFalse(chordType.chordTones.isEmpty, "Chord type should have at least one tone")
            
            // Verify first tone is always root
            XCTAssertEqual(chordType.chordTones.first?.degree, 1)
            XCTAssertEqual(chordType.chordTones.first?.semitonesFromRoot, 0)
        }
    }
    
    func testChordTypeDifficultyProgression() {
        let beginnerTypes = database.getChordTypes(by: .beginner)
        let intermediateTypes = database.getChordTypes(by: .intermediate)
        let advancedTypes = database.getChordTypes(by: .advanced)
        let expertTypes = database.getChordTypes(by: .expert)
        
        // Beginner chords should generally have fewer tones
        let avgBeginnerTones = beginnerTypes.map { $0.chordTones.count }.reduce(0, +) / max(beginnerTypes.count, 1)
        let avgExpertTones = expertTypes.map { $0.chordTones.count }.reduce(0, +) / max(expertTypes.count, 1)
        
        // Expert chords should have more tones on average
        XCTAssertGreaterThanOrEqual(avgExpertTones, avgBeginnerTones)
    }
}
