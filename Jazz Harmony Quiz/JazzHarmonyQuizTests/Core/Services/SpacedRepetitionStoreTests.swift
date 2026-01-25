import XCTest
@testable import JazzHarmonyQuiz

final class SpacedRepetitionStoreTests: XCTestCase {
    
    var store: SpacedRepetitionStore!
    var testChordID: SRItemID!
    var testIntervalID: SRItemID!
    var testScaleID: SRItemID!
    
    override func setUp() {
        super.setUp()
        store = SpacedRepetitionStore.shared
        testChordID = SRItemID(mode: .chordDrill, topic: "maj7", key: "C")
        testIntervalID = SRItemID(mode: .intervalDrill, topic: "P5")
        testScaleID = SRItemID(mode: .scaleDrill, topic: "Major", key: "C")
        // Clear any existing data
        store.resetAll()
    }
    
    override func tearDown() {
        store.resetAll()
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialEaseFactorIsDefault() {
        let schedule = store.schedule(for: testChordID)
        XCTAssertEqual(schedule.easeFactor, 2.5, accuracy: 0.01, "Initial ease factor should be 2.5")
    }
    
    func testInitialIntervalIsOne() {
        let schedule = store.schedule(for: testChordID)
        XCTAssertEqual(schedule.intervalDays, 1.0, accuracy: 0.01, "Initial interval should be 1 day")
    }
    
    func testInitialRepetitionsIsZero() {
        let schedule = store.schedule(for: testChordID)
        XCTAssertEqual(schedule.repetitions, 0, "Initial repetitions should be 0")
    }
    
    func testNewItemIsDue() {
        let schedule = store.schedule(for: testChordID)
        XCTAssertTrue(schedule.isDue(), "New items should be due immediately")
    }
    
    // MARK: - Correct Answer Tests
    
    func testFirstCorrectResponseSetsIntervalToOne() {
        store.recordResult(itemID: testChordID, wasCorrect: true)
        let schedule = store.schedule(for: testChordID)
        XCTAssertEqual(schedule.intervalDays, 1.0, accuracy: 0.01, "First correct answer should set interval to 1")
        XCTAssertEqual(schedule.repetitions, 1, "First correct answer should set repetitions to 1")
    }
    
    func testSecondCorrectResponseSetsIntervalToSix() {
        store.recordResult(itemID: testChordID, wasCorrect: true)
        store.recordResult(itemID: testChordID, wasCorrect: true)
        let schedule = store.schedule(for: testChordID)
        XCTAssertEqual(schedule.intervalDays, 6.0, accuracy: 0.01, "Second correct answer should set interval to 6")
        XCTAssertEqual(schedule.repetitions, 2, "Second correct answer should set repetitions to 2")
    }
    
    func testConsecutiveCorrectAnswersIncreasesInterval() {
        store.recordResult(itemID: testChordID, wasCorrect: true)
        store.recordResult(itemID: testChordID, wasCorrect: true)
        let intervalAfterTwo = store.schedule(for: testChordID).intervalDays
        
        store.recordResult(itemID: testChordID, wasCorrect: true)
        let intervalAfterThree = store.schedule(for: testChordID).intervalDays
        
        XCTAssertGreaterThan(intervalAfterThree, intervalAfterTwo, "Interval should increase with each correct answer")
    }
    
    func testCorrectAnswerIncreasesEaseFactor() {
        store.recordResult(itemID: testChordID, wasCorrect: true)
        let schedule = store.schedule(for: testChordID)
        XCTAssertGreaterThanOrEqual(schedule.easeFactor, 2.5, "Correct answer should maintain or increase ease factor")
    }
    
    func testCorrectAnswerSetsNextDueDate() {
        store.recordResult(itemID: testChordID, wasCorrect: true)
        let schedule = store.schedule(for: testChordID)
        XCTAssertGreaterThan(schedule.dueDate, Date(), "Correct answer should set due date in the future")
        XCTAssertFalse(schedule.isDue(), "Item should not be due immediately after correct answer")
    }
    
    // MARK: - Incorrect Answer Tests
    
    func testIncorrectResponseResetsRepetitions() {
        // Build up some progress
        store.recordResult(itemID: testChordID, wasCorrect: true)
        store.recordResult(itemID: testChordID, wasCorrect: true)
        XCTAssertEqual(store.schedule(for: testChordID).repetitions, 2)
        
        // Fail
        store.recordResult(itemID: testChordID, wasCorrect: false)
        let schedule = store.schedule(for: testChordID)
        XCTAssertEqual(schedule.repetitions, 0, "Failure should reset repetitions")
        XCTAssertEqual(schedule.intervalDays, 1.0, accuracy: 0.01, "Failure should reset interval to 1")
    }
    
    func testIncorrectResponseDecreasesEaseFactor() {
        let initialEaseFactor = store.schedule(for: testChordID).easeFactor
        
        store.recordResult(itemID: testChordID, wasCorrect: false)
        let schedule = store.schedule(for: testChordID)
        
        XCTAssertLessThan(schedule.easeFactor, initialEaseFactor, "Incorrect response should decrease ease factor")
        XCTAssertGreaterThanOrEqual(schedule.easeFactor, 1.3, "Ease factor should not go below minimum of 1.3")
    }
    
    // MARK: - Response Time Tests
    
    func testFastResponseIncreasesEaseFactor() {
        store.recordResult(itemID: testChordID, wasCorrect: true, responseTime: 1.0) // Fast response
        let schedule = store.schedule(for: testChordID)
        XCTAssertGreaterThanOrEqual(schedule.easeFactor, 2.5, "Fast correct answer should increase ease factor")
    }
    
    func testSlowResponseDecreasesEaseFactorBoost() {
        store.recordResult(itemID: testChordID, wasCorrect: true, responseTime: 10.0) // Slow response
        let schedule = store.schedule(for: testChordID)
        XCTAssertGreaterThanOrEqual(schedule.easeFactor, 2.5, "Slow but correct answer should still increase ease factor")
    }
    
    // MARK: - Ease Factor Bounds Tests
    
    func testEaseFactorMinimumBound() {
        // Repeatedly answer incorrectly to try to push ease factor below minimum
        for _ in 0..<10 {
            store.recordResult(itemID: testChordID, wasCorrect: false)
        }
        
        let schedule = store.schedule(for: testChordID)
        XCTAssertGreaterThanOrEqual(schedule.easeFactor, 1.3, "Ease factor should not go below 1.3")
    }
    
    func testEaseFactorGrowth() {
        // Repeatedly answer correctly with fast response times
        for _ in 0..<5 {
            store.recordResult(itemID: testChordID, wasCorrect: true, responseTime: 1.0)
        }
        
        let schedule = store.schedule(for: testChordID)
        XCTAssertGreaterThan(schedule.easeFactor, 2.5, "Ease factor should increase with repeated fast correct answers")
    }
    
    // MARK: - Multiple Items Tests
    
    func testMultipleItemsIndependent() {
        // Progress one item
        store.recordResult(itemID: testChordID, wasCorrect: true)
        let chordSchedule = store.schedule(for: testChordID)
        
        // Other item should be unaffected
        let intervalSchedule = store.schedule(for: testIntervalID)
        XCTAssertEqual(intervalSchedule.repetitions, 0, "Other items should be unaffected")
        XCTAssertEqual(intervalSchedule.intervalDays, 1.0, accuracy: 0.01)
        XCTAssertEqual(intervalSchedule.easeFactor, 2.5, accuracy: 0.01)
        
        // Chord item should have progressed
        XCTAssertEqual(chordSchedule.repetitions, 1)
    }
    
    func testDifferentModesSeparate() {
        let chordID = SRItemID(mode: .chordDrill, topic: "maj7", key: "C")
        let scaleID = SRItemID(mode: .scaleDrill, topic: "maj7", key: "C") // Same topic/key but different mode
        
        store.recordResult(itemID: chordID, wasCorrect: true)
        
        let chordSchedule = store.schedule(for: chordID)
        let scaleSchedule = store.schedule(for: scaleID)
        
        XCTAssertEqual(chordSchedule.repetitions, 1)
        XCTAssertEqual(scaleSchedule.repetitions, 0, "Different modes should be independent")
    }
    
    // MARK: - Due Status Tests
    
    func testIsDueAfterIntervalPasses() {
        // Set a very short interval by manipulating the due date
        store.recordResult(itemID: testChordID, wasCorrect: true)
        
        // Get the schedule and check it's not due yet
        var schedule = store.schedule(for: testChordID)
        XCTAssertFalse(schedule.isDue(), "Item should not be due right after correct answer")
        
        // Manually adjust due date to past (simulating time passing)
        schedule.dueDate = Date().addingTimeInterval(-86400) // 1 day ago
        store.schedules[testChordID] = schedule
        
        schedule = store.schedule(for: testChordID)
        XCTAssertTrue(schedule.isDue(), "Item should be due if due date is in the past")
    }
    
    func testGetDueCount() {
        // Create several items
        let item1 = SRItemID(mode: .chordDrill, topic: "maj7", key: "C")
        let item2 = SRItemID(mode: .chordDrill, topic: "min7", key: "D")
        let item3 = SRItemID(mode: .intervalDrill, topic: "P5")
        
        // Make item1 not due (recently reviewed)
        store.recordResult(itemID: item1, wasCorrect: true)
        
        // Make item2 and item3 due (new items or manually set)
        var schedule2 = store.schedule(for: item2)
        schedule2.dueDate = Date().addingTimeInterval(-86400)
        store.schedules[item2] = schedule2
        
        // Count due items for chord drill mode
        let dueCount = store.dueCount(for: .chordDrill)
        XCTAssertGreaterThanOrEqual(dueCount, 1, "Should have at least one due item")
    }
    
    // MARK: - Statistics Tests
    
    func testAccuracyCalculation() {
        store.recordResult(itemID: testChordID, wasCorrect: true)
        store.recordResult(itemID: testChordID, wasCorrect: true)
        store.recordResult(itemID: testChordID, wasCorrect: false)
        
        let schedule = store.schedule(for: testChordID)
        let expectedAccuracy = 2.0 / 3.0 // 2 correct out of 3 total
        XCTAssertEqual(schedule.accuracy, expectedAccuracy, accuracy: 0.01, "Accuracy should be 2/3")
    }
    
    func testAccuracyForNoAttempts() {
        let schedule = store.schedule(for: testChordID)
        XCTAssertEqual(schedule.accuracy, 0.0, "Accuracy should be 0 for items with no attempts")
    }
    
    // MARK: - Reset Tests
    
    func testResetAllProgress() {
        // Create and progress multiple items
        store.recordResult(itemID: testChordID, wasCorrect: true)
        store.recordResult(itemID: testIntervalID, wasCorrect: true)
        store.recordResult(itemID: testScaleID, wasCorrect: true)
        
        // Verify they have progress
        XCTAssertGreaterThan(store.schedules.count, 0)
        
        // Reset all
        store.resetAll()
        
        // Verify reset
        XCTAssertEqual(store.schedules.count, 0, "All schedules should be cleared")
        
        let newSchedule = store.schedule(for: testChordID)
        XCTAssertEqual(newSchedule.repetitions, 0)
        XCTAssertEqual(newSchedule.intervalDays, 1.0, accuracy: 0.01)
        XCTAssertEqual(newSchedule.easeFactor, 2.5, accuracy: 0.01)
    }
}
