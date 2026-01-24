import Foundation
import Combine

/// Manages the guided curriculum system
@MainActor
class CurriculumManager: ObservableObject {
    static let shared = CurriculumManager()
    
    @Published var moduleProgress: [UUID: ModuleProgress] = [:]
    @Published var currentPathway: CurriculumPathway?
    @Published var activeModuleID: UUID? = nil // Track currently active module
    
    private let userDefaultsKey = "CurriculumProgress"
    
    // All available modules (loaded from CurriculumDatabase)
    let allModules: [CurriculumModule]
    
    init() {
        self.allModules = CurriculumDatabase.modules
        loadProgress()
    }
    
    // MARK: - Active Module
    
    func setActiveModule(_ moduleID: UUID?) {
        activeModuleID = moduleID
    }
    
    var activeModule: CurriculumModule? {
        guard let id = activeModuleID else { return nil }
        return allModules.first(where: { $0.id == id })
    }
    
    // MARK: - Progress Tracking
    
    func getProgress(for moduleID: UUID) -> ModuleProgress {
        return moduleProgress[moduleID] ?? ModuleProgress(moduleID: moduleID)
    }
    
    func recordModuleAttempt(
        moduleID: UUID,
        questionsAnswered: Int,
        correctAnswers: Int,
        wasPerfectSession: Bool = false
    ) {
        var progress = getProgress(for: moduleID)
        
        // Record each question as an attempt
        for i in 0..<questionsAnswered {
            let wasCorrect = i < correctAnswers
            progress.recordAttempt(wasCorrect: wasCorrect, wasPerfectSession: false)
        }
        
        // Record perfect session if applicable
        if wasPerfectSession && questionsAnswered > 0 {
            progress.perfectSessions += 1
        }
        
        // Check if module is now complete
        if let module = allModules.first(where: { $0.id == moduleID }) {
            _ = progress.checkAndMarkCompletion(criteria: module.completionCriteria)
        }
        
        moduleProgress[moduleID] = progress
        saveProgress()
    }
    
    // MARK: - Module Status
    
    func isModuleUnlocked(_ module: CurriculumModule) -> Bool {
        // Check if all prerequisites are completed
        for prereqID in module.prerequisiteModuleIDs {
            let prereqProgress = getProgress(for: prereqID)
            if !prereqProgress.isCompleted {
                return false
            }
        }
        return true
    }
    
    func isModuleCompleted(_ module: CurriculumModule) -> Bool {
        return getProgress(for: module.id).isCompleted
    }
    
    func getModuleProgressPercentage(_ module: CurriculumModule) -> Double {
        let progress = getProgress(for: module.id)
        let criteria = module.completionCriteria
        
        guard criteria.minimumAttempts > 0 else { return 0.0 }
        
        // Progress is based on:
        // 1. Attempts (50% weight)
        // 2. Accuracy (50% weight)
        
        let attemptProgress = min(1.0, Double(progress.attempts) / Double(criteria.minimumAttempts))
        let accuracyProgress = min(1.0, progress.accuracy / criteria.accuracyThreshold)
        
        return (attemptProgress * 0.5 + accuracyProgress * 0.5) * 100
    }
    
    // MARK: - Pathway Navigation
    
    func getModules(for pathway: CurriculumPathway) -> [CurriculumModule] {
        return allModules
            .filter { $0.pathway == pathway }
            .sorted { $0.level < $1.level }
    }
    
    func getNextModule(in pathway: CurriculumPathway) -> CurriculumModule? {
        let pathwayModules = getModules(for: pathway)
        
        // Find first unlocked but incomplete module
        for module in pathwayModules {
            if isModuleUnlocked(module) && !isModuleCompleted(module) {
                return module
            }
        }
        
        return nil
    }
    
    // MARK: - Recommended Next
    
    var recommendedNextModule: CurriculumModule? {
        // If user has selected a pathway, recommend from that
        if let pathway = currentPathway {
            return getNextModule(in: pathway)
        }
        
        // Otherwise, find the first incomplete module across all pathways
        // Prioritize: Harmony Foundations → Functional Harmony → Ear Training → Advanced
        let pathwayOrder: [CurriculumPathway] = [
            .harmonyFoundations,
            .functionalHarmony,
            .earTraining,
            .advancedTopics
        ]
        
        for pathway in pathwayOrder {
            if let nextModule = getNextModule(in: pathway) {
                return nextModule
            }
        }
        
        return nil
    }
    
    // MARK: - Statistics
    
    func getPathwayCompletion(_ pathway: CurriculumPathway) -> Double {
        let pathwayModules = getModules(for: pathway)
        guard !pathwayModules.isEmpty else { return 0.0 }
        
        let completedCount = pathwayModules.filter { isModuleCompleted($0) }.count
        return Double(completedCount) / Double(pathwayModules.count) * 100
    }
    
    func getTotalModulesCompleted() -> Int {
        return allModules.filter { isModuleCompleted($0) }.count
    }
    
    func getTotalModules() -> Int {
        return allModules.count
    }
    
    // MARK: - Persistence
    
    private func saveProgress() {
        if let encoded = try? JSONEncoder().encode(moduleProgress) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decoded = try? JSONDecoder().decode([UUID: ModuleProgress].self, from: data) {
            moduleProgress = decoded
        }
    }
    
    func resetProgress() {
        moduleProgress = [:]
        currentPathway = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
