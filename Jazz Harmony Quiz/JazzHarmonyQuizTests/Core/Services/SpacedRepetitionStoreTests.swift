import XCTest
@testable import JazzHarmonyQuiz

final class SpacedRepetitionStoreTests: XCTestCase {
    
    var store: SpacedRepetitionStore!
    let testChordID = "Cmaj7"
    let testIntervalID = "P5"
    let testScaleID = "C_Major"
    
    override func setUp() {
        super.setUp()
        store = SpacedRepetitionStore()
        // Clear any existing data
        store.resetAllProgress()
    }
    
    override func tearDown() {
        store.resetAllProgress()
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialEaseFactorIsDefault() {
        let item = store.getItem(id: testChordID)
        XCTAssertEqual(item.easeFactor, 2.5, accuracy: 0.01, "Initial ease factor should be 2.5")
    }
    
    func testInitialIntervalIsZero() {
        let item = store.getItem(id: testChordID)
        XCTAssertEqual(item.interval, 0, "Initial interval should be 0")
    }
    
    func testInitialRepetitionsIsZero() {
        let item = store.getItem(id: testChordID)
        XCTAssertEqual(item.repetitions, 0, "Initial repetitions should be 0")
    }
    
    func testNewItemNotDueYet() {
        let item = store.getItem(id: testChordID)
        XCTAssertTrue(store.isDue(item), "New items should be due immediately")
    }
    
    // MARK: - Correct Response Tests (SM-2 Algorithm)
    
    func testCorrectResponseQuality5() {
        var item = store.getItem(id: testChordID)
        
        // First correct response (quality 5 = perfect)
        item = store.recordResponse(for: item, quality: 5)
        
        XCTAssertEqual(item.repetitions, 1)
        XCTAssertEqual(item.interval, 1, "First correct response should set interval to 1 day")
        XCTAssertGreaterThanOrEqual(item.easeFactor, 2.5, "Ease factor should increase or stay same for quality 5")
    }
    
    func testCorrectResponseQuality4() {
        var item = store.getItem(id: testChordID)
        
        // Correct response (quality 4 = correct with hesitation)
        item = store.recordResponse(for: item, quality: 4)
        
        XCTAssertEqual(item.repetitions, 1)
        XCTAssertEqual(item.interval, 1)
        XCTAssertGreaterThanOrEqual(item.easeFactor, 2.4, "Quality 4 should maintain or slightly increase ease factor")
    }
    
    func testCorrectResponseQuality3() {
        var item = store.getItem(id: testChordID)
        
        // Correct with difficulty (quality 3)
        item = store.recordResponse(for: item, quality: 3)
        
        XCTAssertEqual(item.repetitions, 1)
        XCTAssertEqual(item.interval, 1)
        XCTAssertLessThanOrEqual(item.easeFactor, 2.5, "Quality 3 should maintain or decrease ease factor")
        XCTAssertGreaterThanOrEqual(item.easeFactor, 1.3, "Ease factor should not go below minimum")
    }
    
    // MARK: - Incorrect Response Tests
    
    func testIncorrectResponseQuality2() {
        var item = store.getItem(id: testChordID)
        
        // Incorrect response (quality 2)
        item = store.recordResponse(for: item, quality: 2)
        
        XCTAssertEqual(item.repetitions, 0, "Incorrect response should reset repetitions to 0")
        XCTAssertEqual(item.interval, 0, "Incorrect response should reset interval to 0")
        XCTAssertLessThan(item.easeFactor, 2.5, "Incorrect response should decrease ease factor")
    }
    
    func testIncorrectResponseQuality0() {
        var item = store.getItem(id: testChordID)
        
        // Complete failure (quality 0)
        item = store.recordResponse(for: item, quality: 0)
        
        XCTAssertEqual(item.repetitions, 0)
        XCTAssertEqual(item.interval, 0)
        XCTAssertLessThan(item.easeFactor, 2.5)
    }
    
    // MARK: - Multiple Repetitions Tests
    
    func testMultipleCorrectResponses() {
        var item = store.getItem(id: testChordID)
        
        // First repetition
        item = store.recordResponse(for: item, quality: 5)
        XCTAssertEqual(item.repetitions, 1)
        XCTAssertEqual(item.interval, 1)
        
        // Second repetition
        item = store.recordResponse(for: item, quality: 5)
        XCTAssertEqual(item.repetitions, 2)
        XCTAssertEqual(item.interval, 6, "Second correct response should set interval to 6 days")
        
        // Third repetition (interval = previous * ease factor)
        let previousInterval = item.interval
        let previousEaseFactor = item.easeFactor
        item = store.recordResponse(for: item, quality: 5)
        XCTAssertEqual(item.repetitions, 3)
        XCTAssertGreaterThan(item.interval, previousInterval, "Interval should increase with each repetition")
    }
    
    func testIncorrectResponseResetsProgress() {
        var item = store.getItem(id: testChordID)
        
        // Build up some progress
        item = store.recordResponse(for: item, quality: 5)
        item = store.recordResponse(for: item, quality: 5)
        XCTAssertEqual(item.repetitions, 2)
        
        // Fail
        item = store.recordResponse(for: item, quality: 1)
        XCTAssertEqual(item.repetitions, 0, "Failure should reset repetitions")
        XCTAssertEqual(item.interval, 0, "Failure should reset interval")
    }
    
    // MARK: - Due Date Tests
    
    func testIsDueAfterCorrectResponse() {
        var item = store.getItem(id: testChordID)
        item = store.recordResponse(for: item, quality: 5)
        
        // Item should not be due immediately after correct response
        XCTAssertFalse(store.isDue(item), "Item should not be due immediately after correct response")
    }
    
    func testIsDueAfterIntervalPasses() {
        var item = store.getItem(id: testChordID)
        item = store.recordResponse(for: item, quality: 5)
        
        // Manually set nextReviewDate to past
        item.nextReviewDate = Date().addingTimeInterval(-86400) // 1 day ago
        
        XCTAssertTrue(store.isDue(item), "Item should be due if next review date is in the past")
    }
    
    // MARK: - Ease Factor Bounds Tests
    
    func testEaseFactorMinimum() {
        var item = store.getItem(id: testChordID)
        
        // Repeatedly answer with quality 0 to try to push ease factor below minimum
        for _ in 0..<10 {
            item = store.recordResponse(for: item, quality: 0)
        }
        
        XCTAssertGreaterThanOrEqual(item.easeFactor, 1.3, "Ease factor should not go below 1.3")
    }
    
    func testEaseFactorMaximum() {
        var item = store.getItem(id: testChordID)
        
        // Repeatedly answer with quality 5 to try to push ease factor very high
        for _ in 0..<20 {
            item = store.recordResponse(for: item, quality: 5)
        }
        
        // Ease factor can grow, but should stay reasonable (SM-2 formula)
        XCTAssertGreaterThan(item.easeFactor, 2.5)
        XCTAssertLessThan(item.easeFactor, 5.0, "Ease factor shouldn't grow unreasonably large")
    }
    
    // MARK: - Multiple Items Tests
    
    func testMultipleItemsIndependent() {
        var chordItem = store.getItem(id: testChordID)
        var intervalItem = store.getItem(id: testIntervalID)
        
        // Progress one item
        chordItem = store.recordResponse(for: chordItem, quality: 5)
        
        // Other item should be unaffected
        intervalItem = store.getItem(id: testIntervalID)
        XCTAssertEqual(intervalItem.repetitions, 0)
        XCTAssertEqual(intervalItem.interval, 0)
        XCTAssertEqual(intervalItem.easeFactor, 2.5, accuracy: 0.01)
    }
    
    func testGetAllDueItems() {
        // Create several items with different due dates
        var item1 = store.getItem(id: "item1")
        var item2 = store.getItem(id: "item2")
        var item3 = store.getItem(id: "item3")
        
        // Make item1 not due (recently reviewed)
        item1 = store.recordResponse(for: item1, quality: 5)
        store.updateItem(item1)
        
        // Make item2 due (set review date to past)
        item2.nextReviewDate = Date().addingTimeInterval(-86400)
        store.updateItem(item2)
        
        // Leave item3 as new (due by default)
        
        let dueItems = store.getAllDueItems()
        XCTAssertGreaterThanOrEqual(dueItems.count, 2, "At least 2 items should be due")
    }
    
    // MARK: - Persistence Tests
    
    func testItemPersistence() {
        var item = store.getItem(id: testChordID)
        item = store.recordResponse(for: item, quality: 5)
        store.updateItem(item)
        
        // Create new store instance
        let newStore = SpacedRepetitionStore()
        let retrievedItem = newStore.getItem(id: testChordID)
        
        XCTAssertEqual(retrievedItem.repetitions, item.repetitions)
        XCTAssertEqual(retrievedItem.interval, item.interval)
        XCTAssertEqual(retrievedItem.easeFactor, item.easeFactor, accuracy: 0.01)
    }
    
    func testResetAllProgress() {
        // Create and progress multiple items
        var item1 = store.getItem(id: "item1")
        var item2 = store.getItem(id: "item2")
        
        item1 = store.recordResponse(for: item1, quality: 5)
        item2 = store.recordResponse(for: item2, quality: 5)
        store.updateItem(item1)
        store.updateItem(item2)
        
        // Reset all
        store.resetAllProgress()
        
        // Verify reset
        let newItem1 = store.getItem(id: "item1")
        let newItem2 = store.getItem(id: "item2")
        
        XCTAssertEqual(newItem1.repetitions, 0)
        XCTAssertEqual(newItem2.repetitions, 0)
        XCTAssertEqual(newItem1.interval, 0)
        XCTAssertEqual(newItem2.interval, 0)
    }
}
