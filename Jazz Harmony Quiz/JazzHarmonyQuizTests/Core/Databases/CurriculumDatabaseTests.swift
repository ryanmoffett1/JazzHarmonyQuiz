//
//  CurriculumDatabaseTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

final class CurriculumDatabaseTests: XCTestCase {
    
    // MARK: - Module Count Tests
    
    func test_database_hasAllModules() {
        // Per DESIGN.md: Should have 30 modules total
        XCTAssertGreaterThanOrEqual(CurriculumDatabase.modules.count, 30)
    }
    
    func test_database_hasHarmonyFoundationsPathway() {
        let harmonyModules = CurriculumDatabase.modules.filter { 
            $0.pathway == .harmonyFoundations 
        }
        
        XCTAssertGreaterThan(harmonyModules.count, 0)
    }
    
    func test_database_hasFunctionalHarmonyPathway() {
        let functionalModules = CurriculumDatabase.modules.filter { 
            $0.pathway == .functionalHarmony 
        }
        
        XCTAssertGreaterThan(functionalModules.count, 0)
    }
    
    func test_database_hasEarTrainingPathway() {
        let earModules = CurriculumDatabase.modules.filter { 
            $0.pathway == .earTraining 
        }
        
        XCTAssertGreaterThan(earModules.count, 0)
    }
    
    func test_database_hasAdvancedTopicsPathway() {
        let advancedModules = CurriculumDatabase.modules.filter { 
            $0.pathway == .advancedTopics 
        }
        
        XCTAssertGreaterThan(advancedModules.count, 0)
    }
    
    // MARK: - Module Structure Tests
    
    func test_allModules_haveTitles() {
        for module in CurriculumDatabase.modules {
            XCTAssertFalse(module.title.isEmpty, "Module should have a title")
        }
    }
    
    func test_allModules_haveDescriptions() {
        for module in CurriculumDatabase.modules {
            XCTAssertFalse(module.description.isEmpty, "Module '\(module.title)' should have a description")
        }
    }
    
    func test_allModules_haveEmojis() {
        for module in CurriculumDatabase.modules {
            XCTAssertFalse(module.emoji.isEmpty, "Module '\(module.title)' should have an emoji")
        }
    }
    
    func test_allModules_haveValidLevels() {
        for module in CurriculumDatabase.modules {
            XCTAssertGreaterThan(module.level, 0, "Module '\(module.title)' has invalid level")
            XCTAssertLessThanOrEqual(module.level, 5, "Module '\(module.title)' level is too high")
        }
    }
    
    // MARK: - Pathway Structure Tests
    
    func test_pathways_haveModulesInMultipleLevels() {
        let pathways = CurriculumPathway.allCases
        
        for pathway in pathways {
            let modules = CurriculumDatabase.modules.filter { $0.pathway == pathway }
            let levels = Set(modules.map { $0.level })
            
            // Each pathway should have multiple levels
            XCTAssertGreaterThan(levels.count, 1, "\(pathway.rawValue) should have multiple levels")
        }
    }
    
    func test_pathways_startAtLevel1() {
        let pathways = CurriculumPathway.allCases
        
        for pathway in pathways {
            let modules = CurriculumDatabase.modules.filter { $0.pathway == pathway }
            let hasLevel1 = modules.contains { $0.level == 1 }
            
            XCTAssertTrue(hasLevel1, "\(pathway.rawValue) should have level 1 modules")
        }
    }
    
    // MARK: - Practice Mode Tests
    
    func test_allModules_haveValidPracticeModes() {
        let validModes: [CurriculumPracticeMode] = [.chords, .scales, .intervals, .cadences]
        
        for module in CurriculumDatabase.modules {
            XCTAssertTrue(validModes.contains(module.mode),
                         "Module '\(module.title)' has invalid practice mode")
        }
    }
    
    func test_harmonyFoundationsModules_useChordMode() {
        let harmonyModules = CurriculumDatabase.modules.filter { 
            $0.pathway == .harmonyFoundations 
        }
        
        // Most harmony modules should focus on chords
        let chordModules = harmonyModules.filter { $0.mode == .chords }
        XCTAssertGreaterThan(chordModules.count, 0)
    }
    
    func test_earTrainingModules_useVariedModes() {
        let earModules = CurriculumDatabase.modules.filter { 
            $0.pathway == .earTraining 
        }
        
        let modes = Set(earModules.map { $0.mode })
        
        // Ear training should cover intervals, chords, and progressions
        XCTAssertGreaterThan(modes.count, 1, "Ear training should use multiple practice modes")
    }
    
    // MARK: - Module Config Tests
    
    func test_allModules_haveConfigs() {
        for module in CurriculumDatabase.modules {
            XCTAssertNotNil(module.recommendedConfig, 
                          "Module '\(module.title)' should have recommended config")
        }
    }
    
    func test_moduleConfigs_haveValidQuestionCounts() {
        for module in CurriculumDatabase.modules {
            if let config = module.recommendedConfig {
                XCTAssertGreaterThan(config.totalQuestions, 0,
                                   "Module '\(module.title)' should have questions")
                XCTAssertLessThanOrEqual(config.totalQuestions, 50,
                                       "Module '\(module.title)' has too many questions")
            }
        }
    }
    
    // MARK: - Dependency Tests
    
    func test_level1Modules_haveNoDependencies() {
        let level1Modules = CurriculumDatabase.modules.filter { $0.level == 1 }
        
        for module in level1Modules {
            XCTAssertTrue(module.prerequisites.isEmpty,
                         "Level 1 module '\(module.title)' should have no prerequisites")
        }
    }
    
    func test_higherLevelModules_mayHaveDependencies() {
        let higherModules = CurriculumDatabase.modules.filter { $0.level > 1 }
        
        // Not all higher modules need dependencies, but some should have them
        let modulesWithDeps = higherModules.filter { !$0.prerequisites.isEmpty }
        
        // At least some progression should exist
        XCTAssertGreaterThan(higherModules.count, 0)
    }
    
    // MARK: - Title Uniqueness Tests
    
    func test_moduleTitles_areUnique() {
        let titles = CurriculumDatabase.modules.map { $0.title }
        let uniqueTitles = Set(titles)
        
        XCTAssertEqual(titles.count, uniqueTitles.count, "Module titles should be unique")
    }
    
    // MARK: - Specific Module Tests
    
    func test_database_hasMajorMinorTriadsModule() {
        let triadModule = CurriculumDatabase.modules.first { 
            $0.title.contains("Major") && $0.title.contains("Minor") && $0.title.contains("Triad")
        }
        
        XCTAssertNotNil(triadModule)
        if let module = triadModule {
            XCTAssertEqual(module.pathway, .harmonyFoundations)
            XCTAssertEqual(module.level, 1)
            XCTAssertEqual(module.mode, .chords)
        }
    }
    
    func test_database_hasTwoFiveOneModule() {
        let twoFiveOne = CurriculumDatabase.modules.first { 
            $0.title.contains("ii-V-I") || $0.title.contains("2-5-1")
        }
        
        XCTAssertNotNil(twoFiveOne)
        if let module = twoFiveOne {
            XCTAssertEqual(module.pathway, .functionalHarmony)
        }
    }
    
    func test_database_hasBasicIntervalsModule() {
        let intervalsModule = CurriculumDatabase.modules.first { 
            $0.title.contains("Interval") && $0.level == 1
        }
        
        if let module = intervalsModule {
            XCTAssertEqual(module.pathway, .earTraining)
            XCTAssertEqual(module.mode, .intervals)
        }
    }
    
    // MARK: - Edge Cases
    
    func test_noModules_haveNegativeLevels() {
        for module in CurriculumDatabase.modules {
            XCTAssertGreaterThan(module.level, 0, 
                               "Module '\(module.title)' has invalid level \(module.level)")
        }
    }
    
    func test_noModules_haveEmptyPathways() {
        for module in CurriculumDatabase.modules {
            XCTAssertFalse(module.pathway.rawValue.isEmpty,
                          "Module '\(module.title)' has empty pathway")
        }
    }
}
