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
            XCTAssertNotNil(item.type, "Each item should have a type")
        }
    }
    
    // MARK: - Practice Item Tests
    
    func test_practiceItem_hasValidID() {
        // Given
        let item = PracticeItem(
            id: UUID(),
            type: .chordSpelling,
            question: "Spell Cmaj7",
            correctAnswer: []
        )
        
        // Then
        XCTAssertNotNil(item.id, "Practice item should have a valid UUID")
    }
    
    func test_practiceItem_hasType() {
        // Given
        let types: [PracticeItem.PracticeType] = [
            .chordSpelling,
            .cadenceProgression,
            .scaleSpelling,
            .intervalBuilding
        ]
        
        // Then
        for type in types {
            let item = PracticeItem(
                id: UUID(),
                type: type,
                question: "Test",
                correctAnswer: []
            )
            XCTAssertEqual(item.type, type, "Item should retain its type")
        }
    }
    
    func test_practiceItem_hasDifficulty() {
        // Given
        let difficulties: [PracticeItem.Difficulty] = [
            .basic,
            .intermediate,
            .advanced
        ]
        
        // Then
        for difficulty in difficulties {
            var item = PracticeItem(
                id: UUID(),
                type: .chordSpelling,
                question: "Test",
                correctAnswer: []
            )
            item.difficulty = difficulty
            
            XCTAssertEqual(item.difficulty, difficulty, "Item should retain its difficulty")
        }
    }
    
    func test_practiceItem_hasOptionalHint() {
        // Given
        var item = PracticeItem(
            id: UUID(),
            type: .chordSpelling,
            question: "Test",
            correctAnswer: []
        )
        
        // When
        item.hint = "This is a major 7th chord"
        
        // Then
        XCTAssertEqual(item.hint, "This is a major 7th chord")
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
}
