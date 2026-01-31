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
        // 10s response time falls into "okay" category (quality ~3)
        // SM-2 formula with quality 3 slightly decreases ease factor
        store.recordResult(itemID: testChordID, wasCorrect: true, responseTime: 10.0)
        let schedule = store.schedule(for: testChordID)
        // Ease factor decreases from 2.5 with slow response
        XCTAssertLessThanOrEqual(schedule.easeFactor, 2.5, "Slow response should not increase ease factor")
        XCTAssertGreaterThanOrEqual(schedule.easeFactor, 1.3, "Ease factor should not go below minimum")
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
    
    func testResetItem() {
        // Progress the item
        store.recordResult(itemID: testChordID, wasCorrect: true)
        store.recordResult(itemID: testChordID, wasCorrect: true)
        
        XCTAssertEqual(store.schedule(for: testChordID).repetitions, 2)
        
        // Reset just this item
        store.resetItem(testChordID)
        
        let schedule = store.schedule(for: testChordID)
        XCTAssertEqual(schedule.repetitions, 0, "Item should be reset")
        XCTAssertEqual(schedule.intervalDays, 1.0, accuracy: 0.01)
        XCTAssertEqual(schedule.easeFactor, 2.5, accuracy: 0.01)
    }
    
    func testRemoveItem() {
        // Create item
        store.recordResult(itemID: testChordID, wasCorrect: true)
        XCTAssertTrue(store.hasSchedule(for: testChordID))
        
        // Remove item
        store.removeItem(testChordID)
        
        XCTAssertFalse(store.hasSchedule(for: testChordID), "Item should be removed")
    }
    
    func testHasSchedule() {
        XCTAssertFalse(store.hasSchedule(for: testChordID), "New item should not have schedule")
        
        store.recordResult(itemID: testChordID, wasCorrect: true)
        
        XCTAssertTrue(store.hasSchedule(for: testChordID), "Item with progress should have schedule")
    }
    
    // MARK: - Statistics Tests
    
    func testStatistics() {
        // Create various items with different states
        store.recordResult(itemID: testChordID, wasCorrect: true)
        store.recordResult(itemID: testChordID, wasCorrect: true) // Learning state
        
        store.recordResult(itemID: testIntervalID, wasCorrect: false) // New state after failure
        
        let stats = store.statistics()
        
        XCTAssertGreaterThan(stats.totalItems, 0)
        XCTAssertGreaterThanOrEqual(stats.averageAccuracy, 0.0)
        XCTAssertLessThanOrEqual(stats.averageAccuracy, 1.0)
    }
    
    func testStatisticsWithNoItems() {
        let stats = store.statistics()
        
        XCTAssertEqual(stats.totalItems, 0)
        XCTAssertEqual(stats.dueItems, 0)
        XCTAssertEqual(stats.averageAccuracy, 0.0)
    }
    
    func testTotalDueCount() {
        // New items are due by default
        _ = store.schedule(for: testChordID)
        _ = store.schedule(for: testIntervalID)
        
        let totalDue = store.totalDueCount()
        XCTAssertEqual(totalDue, 2, "New items should be due")
    }
    
    // MARK: - SRItemID Tests
    
    func testSRItemIDDisplayName() {
        let itemWithKey = SRItemID(mode: .chordDrill, topic: "maj7", key: "C")
        XCTAssertEqual(itemWithKey.displayName, "C maj7")
        
        let itemWithVariant = SRItemID(mode: .cadenceDrill, topic: "ii-V-I", key: "F", variant: "major")
        XCTAssertEqual(itemWithVariant.displayName, "F ii-V-I (major)")
        
        let itemNoKey = SRItemID(mode: .intervalDrill, topic: "P5")
        XCTAssertEqual(itemNoKey.displayName, "P5")
    }
    
    func testSRItemIDShortName() {
        let itemWithKey = SRItemID(mode: .chordDrill, topic: "maj7", key: "C")
        XCTAssertEqual(itemWithKey.shortName, "C maj7")
        
        let itemNoKey = SRItemID(mode: .intervalDrill, topic: "P5")
        XCTAssertEqual(itemNoKey.shortName, "P5")
    }
    
    // MARK: - SRSchedule Tests
    
    func testScheduleMaturityLevelNew() {
        var schedule = SRSchedule(dueDate: Date())
        schedule.intervalDays = 0.5
        XCTAssertEqual(schedule.maturityLevel, .new)
    }
    
    func testScheduleMaturityLevelLearning() {
        var schedule = SRSchedule(dueDate: Date())
        schedule.intervalDays = 3
        XCTAssertEqual(schedule.maturityLevel, .learning)
    }
    
    func testScheduleMaturityLevelYoung() {
        var schedule = SRSchedule(dueDate: Date())
        schedule.intervalDays = 14
        XCTAssertEqual(schedule.maturityLevel, .young)
    }
    
    func testScheduleMaturityLevelMature() {
        var schedule = SRSchedule(dueDate: Date())
        schedule.intervalDays = 30
        XCTAssertEqual(schedule.maturityLevel, .mature)
    }
    
    func testScheduleDaysUntilDue() {
        var schedule = SRSchedule(dueDate: Date())
        schedule.dueDate = Calendar.current.date(byAdding: .day, value: 5, to: Date()) ?? Date()
        
        let daysUntil = schedule.daysUntilDue()
        XCTAssertEqual(daysUntil, 5, accuracy: 1)
    }
    
    func testScheduleDaysUntilDueOverdue() {
        var schedule = SRSchedule(dueDate: Date())
        schedule.dueDate = Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date()
        
        let daysUntil = schedule.daysUntilDue()
        XCTAssertEqual(daysUntil, -3, accuracy: 1)
    }
}

// MARK: - End-to-End Flow Tests
// These tests verify complete multi-step flows through the spaced repetition system
// Note: Basic SM-2 algorithm behavior is covered in SpacedRepetitionStoreTests above

final class SpacedRepetitionFlowTests: XCTestCase {
    
    var store: SpacedRepetitionStore!
    
    // Use unique IDs per test run to ensure isolation from other tests
    func uniqueItemID(topic: String) -> SRItemID {
        return SRItemID(mode: .chordDrill, topic: "\(topic)_\(UUID().uuidString.prefix(8))", key: "C")
    }
    
    override func setUp() {
        super.setUp()
        store = SpacedRepetitionStore.shared
        store.resetAll()
    }
    
    override func tearDown() {
        store.resetAll()
        super.tearDown()
    }
    
    func test_flow_correctAnswerProgressionToMature() {
        let testItemID = uniqueItemID(topic: "progressToMature")
        
        // Simulate many correct answers to reach mature status
        for i in 1...10 {
            store.recordResult(itemID: testItemID, wasCorrect: true)
            let schedule = store.schedule(for: testItemID)
            XCTAssertEqual(schedule.repetitions, i, "Repetitions should be \(i) after \(i) correct answers")
        }
        
        let finalSchedule = store.schedule(for: testItemID)
        XCTAssertGreaterThan(finalSchedule.intervalDays, 21, "After many correct answers, interval should be > 21 days")
        XCTAssertEqual(finalSchedule.maturityLevel, .mature, "Item should be mature after consistent correct answers")
    }
    
    func test_flow_dueItemsCollection() {
        let item1 = uniqueItemID(topic: "due1")
        let item2 = uniqueItemID(topic: "due2")
        let item3 = uniqueItemID(topic: "notDue")
        
        // Access items to register them
        _ = store.schedule(for: item1)
        _ = store.schedule(for: item2)
        _ = store.schedule(for: item3)
        
        // Make item3 not due
        store.recordResult(itemID: item3, wasCorrect: true)
        store.recordResult(itemID: item3, wasCorrect: true)
        
        // Get due items (returns [SRItemID])
        let dueItems = store.dueItems()
        
        XCTAssertTrue(dueItems.contains(item1))
        XCTAssertTrue(dueItems.contains(item2))
        XCTAssertFalse(dueItems.contains(item3), "Item with future due date should not be in due list")
    }
    
    func test_flow_resetAllClearsEverything() {
        // Create multiple items with progress
        let item1 = uniqueItemID(topic: "reset1")
        let item2 = SRItemID(mode: .intervalDrill, topic: "reset2_\(UUID().uuidString.prefix(8))")
        
        store.recordResult(itemID: item1, wasCorrect: true)
        store.recordResult(itemID: item1, wasCorrect: true)
        store.recordResult(itemID: item2, wasCorrect: true)
        
        XCTAssertEqual(store.schedule(for: item1).repetitions, 2)
        XCTAssertEqual(store.schedule(for: item2).repetitions, 1)
        
        // Reset all
        store.resetAll()
        
        // Verify everything is reset
        XCTAssertEqual(store.schedule(for: item1).repetitions, 0)
        XCTAssertEqual(store.schedule(for: item2).repetitions, 0)
        XCTAssertTrue(store.schedule(for: item1).isDue())
        XCTAssertTrue(store.schedule(for: item2).isDue())
    }
    
    func test_flow_easeFactorAdjustment() {
        let testItemID = uniqueItemID(topic: "easeFactor")
        
        // Ease factor should increase with correct answers
        let initialEase = store.schedule(for: testItemID).easeFactor
        
        // Multiple correct answers should increase ease
        for _ in 0..<5 {
            store.recordResult(itemID: testItemID, wasCorrect: true)
        }
        
        let afterCorrect = store.schedule(for: testItemID).easeFactor
        XCTAssertGreaterThanOrEqual(afterCorrect, initialEase, "Ease factor should not decrease with correct answers")
        
        // Incorrect answer should decrease ease
        store.recordResult(itemID: testItemID, wasCorrect: false)
        let afterIncorrect = store.schedule(for: testItemID).easeFactor
        XCTAssertLessThan(afterIncorrect, afterCorrect, "Ease factor should decrease after incorrect answer")
        
        // But not below minimum
        for _ in 0..<10 {
            store.recordResult(itemID: testItemID, wasCorrect: false)
        }
        let afterManyFailures = store.schedule(for: testItemID).easeFactor
        XCTAssertGreaterThanOrEqual(afterManyFailures, 1.3, "Ease factor should not go below minimum (1.3)")
    }
}
