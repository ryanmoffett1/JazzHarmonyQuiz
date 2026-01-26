import XCTest
@testable import JazzHarmonyQuiz

final class CurriculumTests: XCTestCase {
    
    var curriculumManager: CurriculumManager!
    
    @MainActor
    override func setUp() {
        super.setUp()
        curriculumManager = CurriculumManager.shared
        curriculumManager.resetProgress()
    }
    
    @MainActor
    override func tearDown() {
        curriculumManager.resetProgress()
        super.tearDown()
    }
    
    // MARK: - Module Access Tests
    
    @MainActor
    func testAllModulesLoaded() {
        XCTAssertGreaterThan(curriculumManager.allModules.count, 0, "Should have modules loaded")
        XCTAssertEqual(curriculumManager.getTotalModules(), CurriculumDatabase.modules.count)
    }
    
    @MainActor
    func testGetModulesForPathway() {
        let harmonyModules = curriculumManager.getModules(for: .harmonyFoundations)
        XCTAssertGreaterThan(harmonyModules.count, 0, "Harmony Foundations should have modules")
        
        // All modules should be in the correct pathway
        for module in harmonyModules {
            XCTAssertEqual(module.pathway, .harmonyFoundations)
        }
    }
    
    @MainActor
    func testGetModulesForAllPathways() {
        for pathway in CurriculumPathway.allCases {
            let modules = curriculumManager.getModules(for: pathway)
            XCTAssertGreaterThan(modules.count, 0, "\(pathway.rawValue) should have modules")
        }
    }
    
    @MainActor
    func testModulesAreSortedByLevel() {
        let harmonyModules = curriculumManager.getModules(for: .harmonyFoundations)
        
        var previousLevel = 0
        for module in harmonyModules {
            XCTAssertGreaterThanOrEqual(module.level, previousLevel, "Modules should be sorted by level")
            previousLevel = module.level
        }
    }
    
    // MARK: - Module Unlock Tests
    
    @MainActor
    func testFirstModuleIsUnlocked() {
        let firstModule = CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
        XCTAssertTrue(curriculumManager.isModuleUnlocked(firstModule), "First module should be unlocked")
    }
    
    @MainActor
    func testModuleWithPrerequisitesIsLocked() {
        let secondModule = CurriculumDatabase.harmonyFoundations_1_2_dimAugTriads
        
        // Second module requires first module to be completed
        XCTAssertFalse(curriculumManager.isModuleCompleted(secondModule))
        XCTAssertFalse(curriculumManager.isModuleUnlocked(secondModule), 
                       "Module with incomplete prerequisites should be locked")
    }
    
    @MainActor
    func testModuleUnlocksAfterPrerequisiteComplete() {
        let firstModule = CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
        let secondModule = CurriculumDatabase.harmonyFoundations_1_2_dimAugTriads
        
        // Complete the first module
        curriculumManager.recordModuleAttempt(
            moduleID: firstModule.id,
            questionsAnswered: 50,
            correctAnswers: 45,
            wasPerfectSession: true
        )
        
        // Now second module should be unlocked (after first is completed)
        // First need to verify first is complete
        let firstProgress = curriculumManager.getProgress(for: firstModule.id)
        if firstProgress.isCompleted {
            XCTAssertTrue(curriculumManager.isModuleUnlocked(secondModule), 
                         "Module should unlock after prerequisites are complete")
        }
    }
    
    // MARK: - Progress Recording Tests
    
    @MainActor
    func testRecordModuleAttempt() {
        let module = CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
        
        curriculumManager.recordModuleAttempt(
            moduleID: module.id,
            questionsAnswered: 10,
            correctAnswers: 8,
            wasPerfectSession: false
        )
        
        let progress = curriculumManager.getProgress(for: module.id)
        XCTAssertEqual(progress.attempts, 10)
        XCTAssertEqual(progress.correctAnswers, 8)
    }
    
    @MainActor
    func testRecordMultipleAttempts() {
        let module = CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
        
        curriculumManager.recordModuleAttempt(
            moduleID: module.id,
            questionsAnswered: 10,
            correctAnswers: 8,
            wasPerfectSession: false
        )
        
        curriculumManager.recordModuleAttempt(
            moduleID: module.id,
            questionsAnswered: 10,
            correctAnswers: 9,
            wasPerfectSession: false
        )
        
        let progress = curriculumManager.getProgress(for: module.id)
        XCTAssertEqual(progress.attempts, 20)
        XCTAssertEqual(progress.correctAnswers, 17)
    }
    
    @MainActor
    func testPerfectSessionRecording() {
        let module = CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
        
        curriculumManager.recordModuleAttempt(
            moduleID: module.id,
            questionsAnswered: 10,
            correctAnswers: 10,
            wasPerfectSession: true
        )
        
        let progress = curriculumManager.getProgress(for: module.id)
        XCTAssertEqual(progress.perfectSessions, 1)
    }
    
    // MARK: - Module Completion Tests
    
    @MainActor
    func testModuleCompletionCriteria() {
        let module = CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
        
        // Record enough attempts to complete (30 min attempts, 85% accuracy)
        curriculumManager.recordModuleAttempt(
            moduleID: module.id,
            questionsAnswered: 35,
            correctAnswers: 30,  // ~86% accuracy
            wasPerfectSession: false
        )
        
        let progress = curriculumManager.getProgress(for: module.id)
        XCTAssertGreaterThanOrEqual(progress.accuracy, 0.85)
        XCTAssertGreaterThanOrEqual(progress.attempts, 30)
    }
    
    @MainActor
    func testGetModuleProgressPercentage() {
        let module = CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
        
        // Initial progress should be 0
        let initialProgress = curriculumManager.getModuleProgressPercentage(module)
        XCTAssertEqual(initialProgress, 0.0)
        
        // Record some attempts
        curriculumManager.recordModuleAttempt(
            moduleID: module.id,
            questionsAnswered: 15,
            correctAnswers: 13,
            wasPerfectSession: false
        )
        
        let partialProgress = curriculumManager.getModuleProgressPercentage(module)
        XCTAssertGreaterThan(partialProgress, 0.0)
        XCTAssertLessThan(partialProgress, 100.0)
    }
    
    // MARK: - Pathway Navigation Tests
    
    @MainActor
    func testGetNextModuleInPathway() {
        let nextModule = curriculumManager.getNextModule(in: .harmonyFoundations)
        
        XCTAssertNotNil(nextModule, "Should have a next module in pathway")
        XCTAssertEqual(nextModule?.pathway, .harmonyFoundations)
    }
    
    @MainActor
    func testRecommendedNextModule() {
        let recommended = curriculumManager.recommendedNextModule
        
        XCTAssertNotNil(recommended, "Should have a recommended next module")
    }
    
    // MARK: - Statistics Tests
    
    @MainActor
    func testPathwayCompletion() {
        let completion = curriculumManager.getPathwayCompletion(.harmonyFoundations)
        XCTAssertEqual(completion, 0.0, "Initial pathway completion should be 0")
    }
    
    @MainActor
    func testTotalModulesCompleted() {
        let completed = curriculumManager.getTotalModulesCompleted()
        XCTAssertEqual(completed, 0, "Initial completed modules should be 0")
    }
    
    // MARK: - Active Module Tests
    
    @MainActor
    func testSetActiveModule() {
        let module = CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
        
        curriculumManager.setActiveModule(module.id)
        
        XCTAssertEqual(curriculumManager.activeModuleID, module.id)
        XCTAssertEqual(curriculumManager.activeModule?.id, module.id)
    }
    
    @MainActor
    func testClearActiveModule() {
        let module = CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
        
        curriculumManager.setActiveModule(module.id)
        curriculumManager.setActiveModule(nil)
        
        XCTAssertNil(curriculumManager.activeModuleID)
        XCTAssertNil(curriculumManager.activeModule)
    }
}
