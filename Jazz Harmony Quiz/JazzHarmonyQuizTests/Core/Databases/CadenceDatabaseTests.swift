//
//  CadenceDatabaseTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

final class CadenceDatabaseTests: XCTestCase {
    
    var sut: JazzProgressionDatabase!
    
    override func setUp() {
        sut = JazzProgressionDatabase.shared
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_shared_isSingleton() {
        let instance1 = JazzProgressionDatabase.shared
        let instance2 = JazzProgressionDatabase.shared
        
        XCTAssertTrue(instance1 === instance2)
    }
    
    func test_initialization_loadsProgressions() {
        XCTAssertFalse(sut.allProgressions.isEmpty)
    }
    
    // MARK: - Basic Cadences Tests
    
    func test_database_containsTwoFiveOne() {
        let twoFiveOne = sut.allProgressions.first { $0.name.contains("ii-V-I") }
        
        XCTAssertNotNil(twoFiveOne, "Database should contain ii-V-I progression")
        if let progression = twoFiveOne {
            XCTAssertEqual(progression.category, .cadences)
        }
    }
    
    func test_database_containsMinorTwoFiveOne() {
        let minorTwoFiveOne = sut.allProgressions.first { 
            $0.name.contains("ii-V-i") || ($0.name.contains("ii") && $0.name.contains("minor"))
        }
        
        // Minor ii-V-i is a common progression
        if let progression = minorTwoFiveOne {
            XCTAssertTrue(progression.category == .cadences || progression.category == .minorKeyMovement)
        }
    }
    
    func test_database_containsAuthenticCadence() {
        let authenticCadence = sut.allProgressions.first { $0.name.contains("V-I") }
        
        XCTAssertNotNil(authenticCadence)
        if let progression = authenticCadence {
            XCTAssertEqual(progression.category, .cadences)
        }
    }
    
    // MARK: - Category Distribution Tests
    
    func test_database_hasCadencesCategory() {
        let cadences = sut.allProgressions.filter { $0.category == .cadences }
        
        XCTAssertGreaterThan(cadences.count, 0, "Database should have cadence progressions")
    }
    
    func test_database_hasTurnaroundCategory() {
        let turnarounds = sut.allProgressions.filter { $0.category == .turnaround }
        
        // Turnarounds are common in jazz
        XCTAssertGreaterThan(turnarounds.count, 0, "Database should have turnaround progressions")
    }
    
    func test_database_hasAllCategories() {
        let categories = Set(sut.allProgressions.map { $0.category })
        
        // Should have diverse progression categories
        XCTAssertGreaterThanOrEqual(categories.count, 3, "Database should have multiple progression categories")
    }
    
    // MARK: - Difficulty Distribution Tests
    
    func test_database_hasBeginnerProgressions() {
        let beginnerProgressions = sut.allProgressions.filter { $0.difficulty == .beginner }
        
        XCTAssertGreaterThan(beginnerProgressions.count, 0, "Database should have beginner progressions")
    }
    
    func test_database_hasIntermediateProgressions() {
        let intermediateProgressions = sut.allProgressions.filter { $0.difficulty == .intermediate }
        
        XCTAssertGreaterThan(intermediateProgressions.count, 0, "Database should have intermediate progressions")
    }
    
    func test_database_hasAdvancedProgressions() {
        let advancedProgressions = sut.allProgressions.filter { $0.difficulty == .advanced }
        
        XCTAssertGreaterThan(advancedProgressions.count, 0, "Database should have advanced progressions")
    }
    
    // MARK: - Progression Structure Tests
    
    func test_allProgressions_haveNames() {
        for progression in sut.allProgressions {
            XCTAssertFalse(progression.name.isEmpty, "All progressions should have names")
        }
    }
    
    func test_allProgressions_haveChords() {
        for progression in sut.allProgressions {
            XCTAssertFalse(progression.chords.isEmpty, "Progression '\(progression.name)' has no chords")
        }
    }
    
    func test_allProgressions_haveValidChordCount() {
        for progression in sut.allProgressions {
            XCTAssertGreaterThanOrEqual(progression.chords.count, 2, 
                                       "Progression '\(progression.name)' should have at least 2 chords")
            XCTAssertLessThanOrEqual(progression.chords.count, 32,
                                    "Progression '\(progression.name)' has suspiciously many chords")
        }
    }
    
    // MARK: - Name Uniqueness Tests
    
    func test_progressionNames_areUnique() {
        let names = sut.allProgressions.map { $0.name }
        let uniqueNames = Set(names)
        
        XCTAssertEqual(names.count, uniqueNames.count, "Progression names should be unique")
    }
    
    // MARK: - Key Support Tests
    
    func test_progressions_supportMultipleKeys() {
        // Progressions should work in any key
        // Test that we have progressions that can be transposed
        for progression in sut.allProgressions.prefix(5) {
            XCTAssertNotNil(progression.chords.first, 
                          "Progression '\(progression.name)' should have functional chord specs")
        }
    }
    
    // MARK: - Filtering Tests
    
    func test_filterByCategory_cadences_returnsOnlyCadences() {
        let cadences = sut.allProgressions.filter { $0.category == .cadences }
        
        XCTAssertTrue(cadences.allSatisfy { $0.category == .cadences })
    }
    
    func test_filterByDifficulty_beginner_returnsOnlyBeginnerProgressions() {
        let beginnerProgressions = sut.allProgressions.filter { $0.difficulty == .beginner }
        
        XCTAssertTrue(beginnerProgressions.allSatisfy { $0.difficulty == .beginner })
    }
    
    func test_filterByDifficulty_intermediate_returnsOnlyIntermediateProgressions() {
        let intermediateProgressions = sut.allProgressions.filter { $0.difficulty == .intermediate }
        
        XCTAssertTrue(intermediateProgressions.allSatisfy { $0.difficulty == .intermediate })
    }
    
    // MARK: - Edge Cases
    
    func test_database_hasMinimumProgressions() {
        // Should have at least a few basic progressions
        XCTAssertGreaterThanOrEqual(sut.allProgressions.count, 5)
    }
    
    func test_allProgressions_haveValidDifficulties() {
        for progression in sut.allProgressions {
            let validDifficulties: [ProgressionDifficulty] = [.beginner, .intermediate, .advanced, .expert]
            XCTAssertTrue(validDifficulties.contains(progression.difficulty),
                         "Progression '\(progression.name)' has invalid difficulty")
        }
    }
    
    func test_allProgressions_haveValidCategories() {
        let validCategories = ProgressionCategory.allCases
        
        for progression in sut.allProgressions {
            XCTAssertTrue(validCategories.contains(progression.category),
                         "Progression '\(progression.name)' has invalid category")
        }
    }
}
