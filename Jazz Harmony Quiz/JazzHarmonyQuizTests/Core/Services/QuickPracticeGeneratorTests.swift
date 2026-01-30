import XCTest
@testable import JazzHarmonyQuiz

/// Tests for QuickPracticeGenerator
/// Target: 90%+ coverage per IMPLEMENTATION_PLAN.md Phase 4
final class QuickPracticeGeneratorTests: XCTestCase {
    
    var generator: QuickPracticeGenerator!
    
    override func setUp() {
        super.setUp()
        generator = QuickPracticeGenerator()
    }
    
    override func tearDown() {
        generator = nil
        super.tearDown()
    }
    
    // MARK: - Session Generation Tests
    
    func test_generateSession_returnsCorrectCount() {
        // When
        let session = generator.generateSession()
        
        // Then
        XCTAssertEqual(session.count, 15, "Session should contain exactly 15 items")
    }
    
    func test_generateSession_returnsUniqueItems() {
        // When
        let session = generator.generateSession()
        let uniqueIDs = Set(session.map { $0.id })
        
        // Then
        XCTAssertEqual(uniqueIDs.count, session.count, "All items should have unique IDs")
    }
    
    func test_generateSession_itemsAreShuffled() {
        // Given
        let session1 = generator.generateSession()
        let session2 = generator.generateSession()
        
        // Then
        // Since items are shuffled, two sessions should not be identical
        // (Note: This test has a small chance of false failure if shuffle produces same order)
        let ids1 = session1.map { $0.id }
        let ids2 = session2.map { $0.id }
        
        // At least one ID should be in a different position
        var hasDifferentOrder = false
        for i in 0..<ids1.count {
            if ids1[i] != ids2[i] {
                hasDifferentOrder = true
                break
            }
        }
        
        XCTAssertTrue(hasDifferentOrder || ids1 != ids2, "Sessions should be shuffled")
    }
    
    func test_generateSession_containsPracticeItems() {
        // When
        let session = generator.generateSession()
        
        // Then
        for item in session {
            XCTAssertFalse(item.question.isEmpty, "Each item should have a question")
        }
    }
    
    // MARK: - QuickPracticeItem Tests
    
    func test_quickPracticeItem_hasValidID() {
        // Given
        let item = QuickPracticeItem(
            id: UUID(),
            type: .chordSpelling,
            question: "Spell Cmaj7",
            displayName: "Cmaj7",
            correctNotes: [],
            difficulty: .beginner,
            category: "Chord"
        )
        
        // Then
        XCTAssertNotNil(item.id, "Practice item should have a valid UUID")
    }
    
    func test_quickPracticeItem_hasType() {
        // Given
        let types: [QuickPracticeItem.QuickPracticeType] = [
            .chordSpelling,
            .cadenceProgression,
            .scaleSpelling,
            .intervalBuilding
        ]
        
        // Then
        for type in types {
            let item = QuickPracticeItem(
                id: UUID(),
                type: type,
                question: "Test",
                displayName: "Test",
                correctNotes: [],
                difficulty: .beginner,
                category: "Test"
            )
            XCTAssertEqual(item.type, type, "Item should retain its type")
        }
    }
    
    func test_quickPracticeItem_hasDifficulty() {
        // Given
        let difficulties: [ChordType.ChordDifficulty] = [
            .beginner,
            .intermediate,
            .advanced
        ]
        
        // Then
        for difficulty in difficulties {
            let item = QuickPracticeItem(
                id: UUID(),
                type: .chordSpelling,
                question: "Test",
                displayName: "Test",
                correctNotes: [],
                difficulty: difficulty,
                category: "Chord"
            )
            
            XCTAssertEqual(item.difficulty, difficulty, "Item should retain its difficulty")
        }
    }
    
    func test_quickPracticeItem_hasCategory() {
        // Given
        let item = QuickPracticeItem(
            id: UUID(),
            type: .chordSpelling,
            question: "Test",
            displayName: "Test",
            correctNotes: [],
            difficulty: .beginner,
            category: "Chord"
        )
        
        // Then
        XCTAssertEqual(item.category, "Chord")
    }
    
    // MARK: - Algorithm Distribution Tests
    
    func test_generateSession_distribution() {
        // When
        let session = generator.generateSession()
        
        // Then
        // Session should have 15 items distributed across different types
        // Exact distribution depends on available due items, weak areas, etc.
        XCTAssertEqual(session.count, 15)
        
        // Verify we have at least one item (since we're generating random items)
        XCTAssertGreaterThan(session.count, 0)
    }
    
    func test_generateSession_consistency() {
        // When - Generate multiple sessions
        let session1 = generator.generateSession()
        let session2 = generator.generateSession()
        
        // Then - Both should have correct count
        XCTAssertEqual(session1.count, 15)
        XCTAssertEqual(session2.count, 15)
    }
    
    // MARK: - Integration Placeholder Tests
    
    func test_generateSession_withSpacedRepetition() {
        // TODO: Test integration with SpacedRepetitionStore
        // When store has due items, they should comprise up to 60% of session
        
        // For now, verify session generation works
        let session = generator.generateSession()
        XCTAssertEqual(session.count, 15)
    }
    
    func test_generateSession_withWeakAreas() {
        // TODO: Test integration with StatisticsManager
        // When weak areas exist (accuracy < 75%), they should comprise up to 25% of session
        
        // For now, verify session generation works
        let session = generator.generateSession()
        XCTAssertEqual(session.count, 15)
    }
    
    func test_generateSession_withRecentLearning() {
        // TODO: Test integration with CurriculumManager
        // When recent modules exist, they should comprise up to 15% of session
        
        // For now, verify session generation works
        let session = generator.generateSession()
        XCTAssertEqual(session.count, 15)
    }
    
    // MARK: - Performance Tests
    
    func test_generateSession_performance() {
        measure {
            _ = generator.generateSession()
        }
    }
    
    // MARK: - Interval Item Validation Tests
    
    func test_intervalItems_haveCorrectNotes() {
        // When
        let session = generator.generateSession()
        let intervalItems = session.filter { $0.type == .intervalBuilding }
        
        // Then - Every interval item must have exactly 2 correct notes (root + target)
        for item in intervalItems {
            XCTAssertEqual(item.correctNotes.count, 2, 
                          "Interval item '\(item.question)' should have exactly 2 correct notes (root + target)")
            
            // Verify the notes are different
            let note1 = item.correctNotes[0]
            let note2 = item.correctNotes[1]
            XCTAssertNotEqual(note1.midiNumber, note2.midiNumber,
                            "Interval notes should be different")
        }
    }
    
    func test_intervalItems_calculateCorrectSemitones() {
        // When
        let session = generator.generateSession()
        let intervalItems = session.filter { $0.type == .intervalBuilding }
        
        // Then - Verify interval calculations are correct
        for item in intervalItems {
            guard item.correctNotes.count == 2 else {
                XCTFail("Interval item should have 2 notes")
                continue
            }
            
            let semitones = abs(item.correctNotes[1].midiNumber - item.correctNotes[0].midiNumber) % 12
            let question = item.question
            
            // Verify semitone count matches interval name
            if question.contains("Minor 2nd") {
                XCTAssertEqual(semitones, 1)
            } else if question.contains("Major 2nd") {
                XCTAssertEqual(semitones, 2)
            } else if question.contains("Minor 3rd") {
                XCTAssertEqual(semitones, 3)
            } else if question.contains("Major 3rd") {
                XCTAssertEqual(semitones, 4)
            } else if question.contains("Perfect 4th") {
                XCTAssertEqual(semitones, 5)
            } else if question.contains("Perfect 5th") {
                XCTAssertEqual(semitones, 7)
            } else if question.contains("Minor 6th") {
                XCTAssertEqual(semitones, 8)
            } else if question.contains("Major 6th") {
                XCTAssertEqual(semitones, 9)
            } else if question.contains("Minor 7th") {
                XCTAssertEqual(semitones, 10)
            } else if question.contains("Major 7th") {
                XCTAssertEqual(semitones, 11)
            }
        }
    }
    
    // MARK: - Scale Item Validation Tests
    
    // MARK: - Scale Generation Tests
    
    func test_scaleGeneration_createsCorrectNotes() {
        // Test that the Scale model generates correct notes
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let scaleDatabase = JazzScaleDatabase.shared
        guard let majorScaleType = scaleDatabase.scaleTypes.first(where: { $0.name == "Major" }) else {
            XCTFail("Could not find Major scale type")
            return
        }
        
        let scale = Scale(root: rootNote, scaleType: majorScaleType)
        
        // Verify the Scale model generates correct notes
        XCTAssertEqual(scale.scaleNotes.count, 8, "C Major should have 8 notes (including octave)")
        XCTAssertEqual(scale.scaleNotes.first?.name, "C", "First note should be C")
        XCTAssertEqual(scale.scaleNotes.last?.midiNumber, 72, "Last note should be C an octave higher (MIDI 72)")
    }
}
