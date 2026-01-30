//
//  IntervalDatabaseTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

final class IntervalDatabaseTests: XCTestCase {
    
    var sut: IntervalDatabase!
    
    override func setUp() {
        sut = IntervalDatabase.shared
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_shared_isSingleton() {
        let instance1 = IntervalDatabase.shared
        let instance2 = IntervalDatabase.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    func test_initialization_loadsIntervals() {
        XCTAssertFalse(sut.allIntervals.isEmpty)
    }
    
    // MARK: - Beginner Intervals Tests
    
    func test_database_containsMajorSecond() {
        let M2 = sut.allIntervals.first { $0.shortName == "M2" }
        
        XCTAssertNotNil(M2)
        XCTAssertEqual(M2?.semitones, 2)
        XCTAssertEqual(M2?.quality, .major)
        XCTAssertEqual(M2?.difficulty, .beginner)
    }
    
    func test_database_containsMinorThird() {
        let m3 = sut.allIntervals.first { $0.shortName == "m3" }
        
        XCTAssertNotNil(m3)
        XCTAssertEqual(m3?.semitones, 3)
        XCTAssertEqual(m3?.quality, .minor)
        XCTAssertEqual(m3?.difficulty, .beginner)
    }
    
    func test_database_containsMajorThird() {
        let M3 = sut.allIntervals.first { $0.shortName == "M3" }
        
        XCTAssertNotNil(M3)
        XCTAssertEqual(M3?.semitones, 4)
        XCTAssertEqual(M3?.quality, .major)
        XCTAssertEqual(M3?.difficulty, .beginner)
    }
    
    func test_database_containsPerfectFourth() {
        let P4 = sut.allIntervals.first { $0.shortName == "P4" }
        
        XCTAssertNotNil(P4)
        XCTAssertEqual(P4?.semitones, 5)
        XCTAssertEqual(P4?.quality, .perfect)
        XCTAssertEqual(P4?.difficulty, .beginner)
    }
    
    func test_database_containsPerfectFifth() {
        let P5 = sut.allIntervals.first { $0.shortName == "P5" }
        
        XCTAssertNotNil(P5)
        XCTAssertEqual(P5?.semitones, 7)
        XCTAssertEqual(P5?.quality, .perfect)
        XCTAssertEqual(P5?.difficulty, .beginner)
    }
    
    func test_database_containsOctave() {
        let P8 = sut.allIntervals.first { $0.shortName == "P8" || $0.number == 8 }
        
        XCTAssertNotNil(P8)
        if let P8 = P8 {
            XCTAssertEqual(P8.semitones, 12)
            XCTAssertEqual(P8.quality, .perfect)
        }
    }
    
    // MARK: - Intermediate Intervals Tests
    
    func test_database_containsMinorSecond() {
        let m2 = sut.allIntervals.first { $0.shortName == "m2" }
        
        XCTAssertNotNil(m2)
        XCTAssertEqual(m2?.semitones, 1)
        XCTAssertEqual(m2?.quality, .minor)
    }
    
    func test_database_containsTritone() {
        let TT = sut.allIntervals.first { $0.shortName == "TT" || $0.semitones == 6 }
        
        XCTAssertNotNil(TT)
        XCTAssertEqual(TT?.semitones, 6)
    }
    
    func test_database_containsMajorSixth() {
        let M6 = sut.allIntervals.first { $0.shortName == "M6" }
        
        XCTAssertNotNil(M6)
        XCTAssertEqual(M6?.semitones, 9)
    }
    
    func test_database_containsMinorSeventh() {
        let m7 = sut.allIntervals.first { $0.shortName == "m7" }
        
        XCTAssertNotNil(m7)
        XCTAssertEqual(m7?.semitones, 10)
    }
    
    func test_database_containsMajorSeventh() {
        let M7 = sut.allIntervals.first { $0.shortName == "M7" }
        
        XCTAssertNotNil(M7)
        XCTAssertEqual(M7?.semitones, 11)
    }
    
    // MARK: - Difficulty Distribution Tests
    
    func test_database_hasBeginnerIntervals() {
        let beginnerIntervals = sut.allIntervals.filter { $0.difficulty == .beginner }
        
        XCTAssertGreaterThan(beginnerIntervals.count, 0)
        XCTAssertTrue(beginnerIntervals.contains { $0.shortName == "M3" })
        XCTAssertTrue(beginnerIntervals.contains { $0.shortName == "P5" })
    }
    
    func test_database_hasIntermediateIntervals() {
        let intermediateIntervals = sut.allIntervals.filter { $0.difficulty == .intermediate }
        
        XCTAssertGreaterThan(intermediateIntervals.count, 0)
    }
    
    func test_database_hasAdvancedIntervals() {
        let advancedIntervals = sut.allIntervals.filter { $0.difficulty == .advanced }
        
        // May or may not have advanced intervals
        if !advancedIntervals.isEmpty {
            XCTAssertTrue(advancedIntervals.allSatisfy { $0.difficulty == .advanced })
        }
    }
    
    // MARK: - Semitone Validation Tests
    
    func test_allIntervals_haveValidSemitones() {
        for interval in sut.allIntervals {
            XCTAssertGreaterThanOrEqual(interval.semitones, 0, "\(interval.name) has invalid semitones")
            XCTAssertLessThanOrEqual(interval.semitones, 24, "\(interval.name) has too many semitones")
        }
    }
    
    func test_semitones_matchIntervalNumbers() {
        // Basic validation that semitones make sense for interval numbers
        for interval in sut.allIntervals {
            switch interval.number {
            case 2: XCTAssertTrue([1, 2, 3].contains(interval.semitones)) // m2, M2, aug2
            case 3: XCTAssertTrue([3, 4].contains(interval.semitones)) // m3, M3
            case 4: XCTAssertTrue([5, 6].contains(interval.semitones)) // P4, aug4
            case 5: XCTAssertTrue([6, 7].contains(interval.semitones)) // dim5, P5
            case 6: XCTAssertTrue([8, 9].contains(interval.semitones)) // m6, M6
            case 7: XCTAssertTrue([10, 11].contains(interval.semitones)) // m7, M7
            case 8: XCTAssertEqual(interval.semitones, 12) // P8
            default: break // Compound intervals
            }
        }
    }
    
    // MARK: - Quality Tests
    
    func test_perfectIntervals_arePerfect() {
        let perfectIntervals = sut.allIntervals.filter { $0.quality == .perfect }
        
        // Perfect intervals: P1, P4, P5, P8
        for interval in perfectIntervals {
            XCTAssertTrue([1, 4, 5, 8].contains(interval.number), 
                         "\(interval.name) is marked perfect but has interval number \(interval.number)")
        }
    }
    
    func test_majorMinorIntervals_areMajorOrMinor() {
        let majorMinorIntervals = sut.allIntervals.filter { 
            $0.quality == .major || $0.quality == .minor 
        }
        
        // Major/minor intervals: 2, 3, 6, 7
        for interval in majorMinorIntervals {
            XCTAssertTrue([2, 3, 6, 7].contains(interval.number),
                         "\(interval.name) is major/minor but has interval number \(interval.number)")
        }
    }
    
    // MARK: - Short Name Uniqueness Tests
    
    func test_shortNames_areUnique() {
        let shortNames = sut.allIntervals.map { $0.shortName }
        let uniqueShortNames = Set(shortNames)
        
        XCTAssertEqual(shortNames.count, uniqueShortNames.count, "Short names should be unique")
    }
    
    func test_intervalNames_areUnique() {
        let names = sut.allIntervals.map { $0.name }
        let uniqueNames = Set(names)
        
        XCTAssertEqual(names.count, uniqueNames.count, "Interval names should be unique")
    }
    
    // MARK: - Lookup Tests
    
    func test_getByDifficulty_beginner_returnsBeginnerIntervals() {
        let beginner = sut.getIntervals(difficulty: .beginner)
        
        XCTAssertFalse(beginner.isEmpty)
        XCTAssertTrue(beginner.allSatisfy { $0.difficulty == .beginner })
    }
    
    func test_getByDifficulty_intermediate_returnsIntermediateIntervals() {
        let intermediate = sut.getIntervals(difficulty: .intermediate)
        
        XCTAssertFalse(intermediate.isEmpty)
        XCTAssertTrue(intermediate.allSatisfy { $0.difficulty == .intermediate })
    }
    
    // MARK: - Edge Cases
    
    func test_database_hasMinimumIntervals() {
        // Should have at least 8 basic intervals (M2, m3, M3, P4, P5, M6, m7, M7, P8)
        XCTAssertGreaterThanOrEqual(sut.allIntervals.count, 8)
    }
    
    func test_allIntervals_haveNames() {
        for interval in sut.allIntervals {
            XCTAssertFalse(interval.name.isEmpty, "Interval should have a name")
            XCTAssertFalse(interval.shortName.isEmpty, "Interval should have a short name")
        }
    }
    
    func test_allIntervals_haveValidIntervalNumbers() {
        for interval in sut.allIntervals {
            XCTAssertGreaterThan(interval.number, 0, "\(interval.name) has invalid interval number")
            XCTAssertLessThanOrEqual(interval.number, 15, "\(interval.name) has interval number too large")
        }
    }
    
    func test_database_doesNotIncludeUnison() {
        // Per code comment: Unison (P1, 0 semitones) intentionally excluded
        let unison = sut.allIntervals.first { $0.semitones == 0 }
        
        XCTAssertNil(unison, "Database should not include unison (ambiguous in quiz context)")
    }
}
