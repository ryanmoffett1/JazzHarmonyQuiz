import Foundation

/// Unified player statistics shared across all game modes (Chord Drill and Cadence Mode)
class PlayerStats: ObservableObject {
    static let shared = PlayerStats()
    
    // MARK: - Published Properties
    @Published var currentRating: Int = 1000  // Start at "Jam Session Ready"
    @Published var peakRating: Int = 1000
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastPracticeDate: Date?
    
    // Total stats across all modes
    @Published var totalQuestionsAnswered: Int = 0
    @Published var totalCorrectAnswers: Int = 0
    @Published var totalPracticeTime: TimeInterval = 0
    
    // Achievements (shared)
    @Published var unlockedAchievements: [Achievement] = []
    @Published var newlyUnlockedAchievements: [Achievement] = []
    
    // Daily challenge tracking
    @Published var dailyChallengeLastCompleted: Date?
    @Published var dailyChallengeStreak: Int = 0
    
    // Perfect score tracking
    @Published var perfectScoreStreak: Int = 0
    
    // MARK: - UserDefaults Keys
    private let statsKey = "JazzHarmonyUnifiedPlayerStats"
    
    // MARK: - Computed Properties
    
    var currentRank: Rank {
        return Rank.forRating(currentRating)
    }
    
    var pointsToNextRank: Int? {
        guard let nextRank = Rank.nextRank(after: currentRank) else { return nil }
        return nextRank.minRating - currentRating
    }
    
    var overallAccuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered)
    }
    
    var isDailyChallengeCompletedToday: Bool {
        guard let lastCompleted = dailyChallengeLastCompleted else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    // MARK: - Initialization
    
    private init() {
        loadFromUserDefaults()
    }
    
    // MARK: - Rating Management
    
    /// Apply a rating change and return whether a rank up occurred
    @discardableResult
    func applyRatingChange(_ change: Int) -> (newRating: Int, didRankUp: Bool, previousRank: Rank) {
        let previousRank = currentRank
        currentRating = max(0, currentRating + change)
        peakRating = max(peakRating, currentRating)
        
        let didRankUp = currentRank.title != previousRank.title && change > 0
        
        saveToUserDefaults()
        return (currentRating, didRankUp, previousRank)
    }
    
    // MARK: - Stats Recording
    
    func recordPractice(questionsAnswered: Int, correctAnswers: Int, time: TimeInterval, wasPerfectScore: Bool) {
        totalQuestionsAnswered += questionsAnswered
        totalCorrectAnswers += correctAnswers
        totalPracticeTime += time
        
        // Update perfect score streak
        if wasPerfectScore {
            perfectScoreStreak += 1
        } else {
            perfectScoreStreak = 0
        }
        
        // Check achievements
        checkAchievements(wasPerfectScore: wasPerfectScore)
        
        saveToUserDefaults()
    }
    
    // MARK: - Streak Management
    
    func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastPracticeDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 1 {
                currentStreak += 1
            } else if daysDiff > 1 {
                currentStreak = 1
            }
            // daysDiff == 0 means same day, don't change streak
        } else {
            currentStreak = 1
        }
        
        longestStreak = max(longestStreak, currentStreak)
        lastPracticeDate = Date()
        
        saveToUserDefaults()
    }
    
    func completeDailyChallenge() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastCompleted = dailyChallengeLastCompleted {
            let lastDay = calendar.startOfDay(for: lastCompleted)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 1 {
                dailyChallengeStreak += 1
            } else if daysDiff > 1 {
                dailyChallengeStreak = 1
            }
        } else {
            dailyChallengeStreak = 1
        }
        
        dailyChallengeLastCompleted = Date()
        saveToUserDefaults()
    }
    
    // MARK: - Achievement System
    
    func hasAchievement(_ type: AchievementType) -> Bool {
        return unlockedAchievements.contains { $0.type == type }
    }
    
    func unlockAchievement(_ type: AchievementType) {
        guard !hasAchievement(type) else { return }
        let achievement = Achievement(type: type, unlockedDate: Date())
        unlockedAchievements.append(achievement)
        newlyUnlockedAchievements.append(achievement)
        saveToUserDefaults()
    }
    
    func clearNewAchievements() {
        newlyUnlockedAchievements.removeAll()
    }
    
    private func checkAchievements(wasPerfectScore: Bool) {
        // Chord milestones
        if totalQuestionsAnswered >= 100 { unlockAchievement(.hundredChords) }
        if totalQuestionsAnswered >= 500 { unlockAchievement(.fiveHundredChords) }
        if totalQuestionsAnswered >= 1000 { unlockAchievement(.thousandChords) }
        
        // Perfect score tracking
        if wasPerfectScore {
            if !hasAchievement(.firstPerfect) { unlockAchievement(.firstPerfect) }
            if perfectScoreStreak >= 3 { unlockAchievement(.perfectStreak3) }
            if perfectScoreStreak >= 5 { unlockAchievement(.perfectStreak5) }
        }
        
        // Accuracy achievement
        if totalQuestionsAnswered >= 50 && overallAccuracy >= 0.9 {
            unlockAchievement(.accuracy90)
        }
        
        // Streak achievements
        if currentStreak >= 3 { unlockAchievement(.streak3) }
        if currentStreak >= 7 { unlockAchievement(.streak7) }
        if currentStreak >= 14 { unlockAchievement(.streak14) }
        if currentStreak >= 30 { unlockAchievement(.streak30) }
        
        // Daily challenge achievements
        if dailyChallengeStreak >= 1 { unlockAchievement(.dailyFirst) }
        if dailyChallengeStreak >= 7 { unlockAchievement(.dailyStreak7) }
        
        // Rank achievements
        if currentRating >= 1001 { unlockAchievement(.rankGigging) }
        if currentRating >= 1501 { unlockAchievement(.rankBebop) }
        if currentRating >= 2001 { unlockAchievement(.rankWizard) }
        if currentRating >= 2751 { unlockAchievement(.rankMaster) }
    }
    
    // MARK: - Persistence
    
    func saveToUserDefaults() {
        let data = PlayerStatsData(
            currentRating: currentRating,
            peakRating: peakRating,
            currentStreak: currentStreak,
            longestStreak: longestStreak,
            lastPracticeDate: lastPracticeDate,
            totalQuestionsAnswered: totalQuestionsAnswered,
            totalCorrectAnswers: totalCorrectAnswers,
            totalPracticeTime: totalPracticeTime,
            unlockedAchievements: unlockedAchievements,
            dailyChallengeLastCompleted: dailyChallengeLastCompleted,
            dailyChallengeStreak: dailyChallengeStreak,
            perfectScoreStreak: perfectScoreStreak
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: statsKey),
              let decoded = try? JSONDecoder().decode(PlayerStatsData.self, from: data) else {
            return
        }
        
        currentRating = decoded.currentRating
        peakRating = decoded.peakRating
        currentStreak = decoded.currentStreak
        longestStreak = decoded.longestStreak
        lastPracticeDate = decoded.lastPracticeDate
        totalQuestionsAnswered = decoded.totalQuestionsAnswered
        totalCorrectAnswers = decoded.totalCorrectAnswers
        totalPracticeTime = decoded.totalPracticeTime
        unlockedAchievements = decoded.unlockedAchievements
        dailyChallengeLastCompleted = decoded.dailyChallengeLastCompleted
        dailyChallengeStreak = decoded.dailyChallengeStreak
        perfectScoreStreak = decoded.perfectScoreStreak
        
        // Check if streak should be reset (missed more than one day)
        if let lastDate = lastPracticeDate {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff > 1 {
                currentStreak = 0
            }
        }
    }
}

// MARK: - Codable Data Structure

private struct PlayerStatsData: Codable {
    let currentRating: Int
    let peakRating: Int
    let currentStreak: Int
    let longestStreak: Int
    let lastPracticeDate: Date?
    let totalQuestionsAnswered: Int
    let totalCorrectAnswers: Int
    let totalPracticeTime: TimeInterval
    let unlockedAchievements: [Achievement]
    let dailyChallengeLastCompleted: Date?
    let dailyChallengeStreak: Int
    let perfectScoreStreak: Int
}
