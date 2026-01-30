//
//  CurriculumModuleTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

final class CurriculumModuleTests: XCTestCase {
    
    // MARK: - Initialization Tests
    
    func test_initialization_withAllParameters() {
        let config = ModuleConfig(
            chordTypes: ["", "m"],
            questionType: "allTones",
            totalQuestions: 10,
            difficulty: .beginner,
            keyDifficulty: .easy
        )
        
        let criteria = CompletionCriteria(
            minimumAccuracy: 0.8,
            requiredAttempts: 1
        )
        
        let module = CurriculumModule(
            title: "Test Module",
            description: "Test Description",
            emoji: "🎵",
            pathway: .harmonyFoundations,
            level: 1,
            mode: .chords,
            recommendedConfig: config,
            prerequisiteModuleIDs: [],
            completionCriteria: criteria
        )
        
        XCTAssertEqual(module.title, "Test Module")
        XCTAssertEqual(module.description, "Test Description")
        XCTAssertEqual(module.emoji, "🎵")
        XCTAssertEqual(module.pathway, .harmonyFoundations)
        XCTAssertEqual(module.level, 1)
        XCTAssertEqual(module.mode, .chords)
        XCTAssertTrue(module.prerequisiteModuleIDs.isEmpty)
    }
    
    func test_initialization_generatesUUID() {
        let config = ModuleConfig(chordTypes: [], questionType: "allTones", totalQuestions: 10, difficulty: .beginner, keyDifficulty: .easy)
        let criteria = CompletionCriteria(minimumAccuracy: 0.8, requiredAttempts: 1)
        
        let module1 = CurriculumModule(
            title: "Module 1",
            description: "Description",
            emoji: "🎵",
            pathway: .harmonyFoundations,
            level: 1,
            mode: .chords,
            recommendedConfig: config,
            completionCriteria: criteria
        )
        
        let module2 = CurriculumModule(
            title: "Module 2",
            description: "Description",
            emoji: "🎵",
            pathway: .harmonyFoundations,
            level: 1,
            mode: .chords,
            recommendedConfig: config,
            completionCriteria: criteria
        )
        
        XCTAssertNotEqual(module1.id, module2.id)
    }
    
    // MARK: - Equatable Tests
    
    func test_equatable_sameID_isEqual() {
        let id = UUID()
        let config = ModuleConfig(chordTypes: [], questionType: "allTones", totalQuestions: 10, difficulty: .beginner, keyDifficulty: .easy)
        let criteria = CompletionCriteria(minimumAccuracy: 0.8, requiredAttempts: 1)
        
        let module1 = CurriculumModule(
            id: id,
            title: "Module",
            description: "Description",
            emoji: "🎵",
            pathway: .harmonyFoundations,
            level: 1,
            mode: .chords,
            recommendedConfig: config,
            completionCriteria: criteria
        )
        
        let module2 = CurriculumModule(
            id: id,
            title: "Different Title",
            description: "Different Description",
            emoji: "🎸",
            pathway: .earTraining,
            level: 2,
            mode: .intervals,
            recommendedConfig: config,
            completionCriteria: criteria
        )
        
        XCTAssertEqual(module1, module2) // Same ID means equal
    }
    
    // MARK: - Hashable Tests
    
    func test_hashable_canBeUsedInSet() {
        let config = ModuleConfig(chordTypes: [], questionType: "allTones", totalQuestions: 10, difficulty: .beginner, keyDifficulty: .easy)
        let criteria = CompletionCriteria(minimumAccuracy: 0.8, requiredAttempts: 1)
        
        let module1 = CurriculumModule(
            title: "Module 1",
            description: "Description",
            emoji: "🎵",
            pathway: .harmonyFoundations,
            level: 1,
            mode: .chords,
            recommendedConfig: config,
            completionCriteria: criteria
        )
        
        let module2 = CurriculumModule(
            title: "Module 2",
            description: "Description",
            emoji: "🎵",
            pathway: .harmonyFoundations,
            level: 2,
            mode: .chords,
            recommendedConfig: config,
            completionCriteria: criteria
        )
        
        let set: Set<CurriculumModule> = [module1, module2]
        XCTAssertEqual(set.count, 2)
    }
    
    // MARK: - Pathway Tests
    
    func test_pathway_allCasesExist() {
        XCTAssertEqual(CurriculumPathway.allCases.count, 4)
        XCTAssertTrue(CurriculumPathway.allCases.contains(.harmonyFoundations))
        XCTAssertTrue(CurriculumPathway.allCases.contains(.functionalHarmony))
        XCTAssertTrue(CurriculumPathway.allCases.contains(.earTraining))
        XCTAssertTrue(CurriculumPathway.allCases.contains(.advancedTopics))
    }
    
    func test_pathway_hasDescriptions() {
        for pathway in CurriculumPathway.allCases {
            XCTAssertFalse(pathway.description.isEmpty)
        }
    }
    
    func test_pathway_hasIcons() {
        for pathway in CurriculumPathway.allCases {
            XCTAssertFalse(pathway.icon.isEmpty)
        }
    }
    
    func test_pathway_hasThemeColors() {
        for pathway in CurriculumPathway.allCases {
            _ = pathway.themeColor // Just ensure it doesn't crash
        }
    }
    
    // MARK: - Practice Mode Tests
    
    func test_practiceMode_allCasesExist() {
        XCTAssertGreaterThanOrEqual(CurriculumPracticeMode.allCases.count, 4)
        XCTAssertTrue(CurriculumPracticeMode.allCases.contains(.chords))
        XCTAssertTrue(CurriculumPracticeMode.allCases.contains(.scales))
        XCTAssertTrue(CurriculumPracticeMode.allCases.contains(.intervals))
        XCTAssertTrue(CurriculumPracticeMode.allCases.contains(.cadences))
    }
    
    func test_practiceMode_hasIcons() {
        for mode in CurriculumPracticeMode.allCases {
            XCTAssertFalse(mode.icon.isEmpty)
        }
    }
    
    // MARK: - Prerequisites Tests
    
    func test_prerequisites_canBeEmpty() {
        let config = ModuleConfig(chordTypes: [], questionType: "allTones", totalQuestions: 10, difficulty: .beginner, keyDifficulty: .easy)
        let criteria = CompletionCriteria(minimumAccuracy: 0.8, requiredAttempts: 1)
        
        let module = CurriculumModule(
            title: "First Module",
            description: "No prerequisites",
            emoji: "🎵",
            pathway: .harmonyFoundations,
            level: 1,
            mode: .chords,
            recommendedConfig: config,
            prerequisiteModuleIDs: [],
            completionCriteria: criteria
        )
        
        XCTAssertTrue(module.prerequisiteModuleIDs.isEmpty)
    }
    
    func test_prerequisites_canContainMultipleIDs() {
        let config = ModuleConfig(chordTypes: [], questionType: "allTones", totalQuestions: 10, difficulty: .beginner, keyDifficulty: .easy)
        let criteria = CompletionCriteria(minimumAccuracy: 0.8, requiredAttempts: 1)
        
        let prereq1 = UUID()
        let prereq2 = UUID()
        
        let module = CurriculumModule(
            title: "Advanced Module",
            description: "Has prerequisites",
            emoji: "🎵",
            pathway: .harmonyFoundations,
            level: 3,
            mode: .chords,
            recommendedConfig: config,
            prerequisiteModuleIDs: [prereq1, prereq2],
            completionCriteria: criteria
        )
        
        XCTAssertEqual(module.prerequisiteModuleIDs.count, 2)
        XCTAssertTrue(module.prerequisiteModuleIDs.contains(prereq1))
        XCTAssertTrue(module.prerequisiteModuleIDs.contains(prereq2))
    }
    
    // MARK: - Codable Tests
    
    func test_codable_encodesAndDecodes() throws {
        let config = ModuleConfig(
            chordTypes: ["", "m"],
            questionType: "allTones",
            totalQuestions: 15,
            difficulty: .intermediate,
            keyDifficulty: .medium
        )
        
        let criteria = CompletionCriteria(
            minimumAccuracy: 0.85,
            requiredAttempts: 2
        )
        
        let original = CurriculumModule(
            title: "Test Module",
            description: "Test Description",
            emoji: "🎸",
            pathway: .functionalHarmony,
            level: 2,
            mode: .cadences,
            recommendedConfig: config,
            prerequisiteModuleIDs: [UUID()],
            completionCriteria: criteria
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(CurriculumModule.self, from: data)
        
        XCTAssertEqual(decoded.id, original.id)
        XCTAssertEqual(decoded.title, original.title)
        XCTAssertEqual(decoded.description, original.description)
        XCTAssertEqual(decoded.emoji, original.emoji)
        XCTAssertEqual(decoded.pathway, original.pathway)
        XCTAssertEqual(decoded.level, original.level)
        XCTAssertEqual(decoded.mode, original.mode)
    }
}
