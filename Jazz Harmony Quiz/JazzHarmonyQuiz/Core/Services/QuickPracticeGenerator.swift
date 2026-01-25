import Foundation

/// Generates intelligent Quick Practice sessions per DESIGN.md Section 6.2
/// Combines spaced repetition, weak areas, and recent learning
class QuickPracticeGenerator {
    
    // MARK: - Dependencies
    
    private let spacedRepetitionStore: SpacedRepetitionStore
    
    // TODO: Add when implemented
    // private let statisticsManager: StatisticsManager
    // private let curriculumManager: CurriculumManager
    
    // MARK: - Configuration
    
    private let targetItemCount = 15
    private let dueItemsPercentage = 0.6  // 60% of session
    private let weakAreasPercentage = 0.25 // 25% of session
    private let recentLearningPercentage = 0.15 // 15% of session
    
    // MARK: - Initialization
    
    init(spacedRepetitionStore: SpacedRepetitionStore = .shared) {
        self.spacedRepetitionStore = spacedRepetitionStore
    }
    
    // MARK: - Session Generation
    
    /// Generates a Quick Practice session per DESIGN.md algorithm
    /// Priority 1: Spaced repetition due items (60%)
    /// Priority 2: Weak areas (25%)
    /// Priority 3: Recent learning (15%)
    /// Fills remainder with general practice
    func generateSession() -> [PracticeItem] {
        var items: [PracticeItem] = []
        
        // Priority 1: Spaced repetition due items (up to 60%)
        let dueItemsLimit = Int(Double(targetItemCount) * dueItemsPercentage)
        let dueItems = getDueItems(limit: dueItemsLimit)
        items.append(contentsOf: dueItems)
        
        // Priority 2: Weak areas (up to 25%)
        let weakAreasLimit = Int(Double(targetItemCount) * weakAreasPercentage)
        let weakAreaItems = getWeakAreaItems(limit: weakAreasLimit)
        items.append(contentsOf: weakAreaItems)
        
        // Priority 3: Recent learning (up to 15%)
        let recentLearningLimit = Int(Double(targetItemCount) * recentLearningPercentage)
        let recentItems = getRecentLearningItems(limit: recentLearningLimit)
        items.append(contentsOf: recentItems)
        
        // Fill remainder with general practice
        while items.count < targetItemCount {
            items.append(generateRandomItem())
        }
        
        return items.shuffled()
    }
    
    // MARK: - Private Helpers
    
    /// Gets due items from spaced repetition, sorted by overdue days
    private func getDueItems(limit: Int) -> [PracticeItem] {
        // TODO: Get actual due items from SpacedRepetitionStore
        // For now, return empty (will be connected in integration)
        return []
    }
    
    /// Gets items from weak areas identified in statistics
    private func getWeakAreaItems(limit: Int) -> [PracticeItem] {
        // TODO: Connect to StatisticsManager
        // Will identify areas with accuracy < 75% and generate focused questions
        return []
    }
    
    /// Gets items from recently learned curriculum modules
    private func getRecentLearningItems(limit: Int) -> [PracticeItem] {
        // TODO: Connect to CurriculumManager
        // Will get items from recently completed modules for reinforcement
        return []
    }
    
    /// Generates a random practice item for filling gaps
    private func generateRandomItem() -> PracticeItem {
        // TODO: Implement random item generation
        // Will generate questions from ChordDatabase, ScaleDatabase, IntervalDatabase
        // Based on current difficulty settings
        
        // Placeholder
        return PracticeItem(
            id: UUID(),
            type: .chordSpelling,
            question: "Placeholder",
            correctAnswer: []
        )
    }
}

// MARK: - Practice Item Model

/// Represents a single practice question in Quick Practice session
struct PracticeItem: Identifiable {
    let id: UUID
    let type: PracticeType
    let question: String
    let correctAnswer: [Note]
    
    // Optional metadata
    var hint: String?
    var difficulty: Difficulty?
    
    enum PracticeType {
        case chordSpelling
        case cadenceProgression
        case scaleSpelling
        case intervalBuilding
    }
    
    enum Difficulty {
        case basic
        case intermediate
        case advanced
    }
}
