import Foundation
import SwiftUI

// MARK: - RPG Character Stats for Jazz Learning

/// The six core stats that represent a player's jazz proficiency
enum JazzStat: String, CaseIterable, Codable {
    case harmony = "Harmony"      // Chord knowledge
    case ear = "Ear"              // Interval/ear training
    case theory = "Theory"        // Scale knowledge
    case flow = "Flow"            // Cadence/progression understanding
    case speed = "Speed"          // Response time
    case precision = "Precision"  // Overall accuracy
    
    var emoji: String {
        switch self {
        case .harmony: return "🎵"
        case .ear: return "👂"
        case .theory: return "🎼"
        case .flow: return "🔄"
        case .speed: return "⚡"
        case .precision: return "🎯"
        }
    }
    
    var description: String {
        switch self {
        case .harmony: return "Chord structures and voicings"
        case .ear: return "Interval recognition and ear training"
        case .theory: return "Scales, modes, and theory"
        case .flow: return "Progressions and cadences"
        case .speed: return "Quick recognition"
        case .precision: return "Accuracy and consistency"
        }
    }
    
    var color: Color {
        switch self {
        case .harmony: return .blue
        case .ear: return .purple
        case .theory: return .green
        case .flow: return .orange
        case .speed: return .yellow
        case .precision: return .red
        }
    }
}

/// Available avatar options for the player
enum PlayerAvatar: String, CaseIterable, Codable {
    case piano = "🎹"
    case saxophone = "🎷"
    case trumpet = "🎺"
    case guitar = "🎸"
    case bass = "🎻"
    case drums = "🥁"
    case microphone = "🎤"
    case notes = "🎵"
    case headphones = "🎧"
    case conductor = "🎼"
    
    var name: String {
        switch self {
        case .piano: return "Piano"
        case .saxophone: return "Saxophone"
        case .trumpet: return "Trumpet"
        case .guitar: return "Guitar"
        case .bass: return "Bass"
        case .drums: return "Drums"
        case .microphone: return "Vocalist"
        case .notes: return "Composer"
        case .headphones: return "Producer"
        case .conductor: return "Conductor"
        }
    }
}

/// Practice mode types for per-mode scoreboards
enum PracticeMode: String, CaseIterable, Codable {
    case chordDrill = "Chord Drill"
    case scaleDrill = "Scale Drill"
    case intervalDrill = "Interval Drill"
    case cadenceDrill = "Cadence Drill"
    
    var emoji: String {
        switch self {
        case .chordDrill: return "🎹"
        case .scaleDrill: return "🎼"
        case .intervalDrill: return "👂"
        case .cadenceDrill: return "🔄"
        }
    }
    
    /// Which stats this mode primarily affects
    var primaryStats: [JazzStat] {
        switch self {
        case .chordDrill: return [.harmony, .precision]
        case .scaleDrill: return [.theory, .precision]
        case .intervalDrill: return [.ear, .speed]
        case .cadenceDrill: return [.flow, .harmony]
        }
    }
}

// MARK: - Player Profile (Consolidated from PlayerStats)

/// The player's unified profile with RPG stats, progression, achievements, and streaks
class PlayerProfile: ObservableObject {
    static let shared = PlayerProfile()
    
    // MARK: - Profile Properties
    
    @Published var playerName: String = "Jazz Student"
    @Published var avatar: PlayerAvatar = .piano
    
    // MARK: - XP/Rating Properties (formerly in PlayerStats)
    
    @Published var currentRating: Int = 1000  // Start at "Jam Session Ready"
    @Published var peakRating: Int = 1000
    
    // MARK: - Streak Properties
    
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var lastPracticeDate: Date?
    
    // MARK: - Totals Across All Modes
    
    @Published var totalQuestionsAnswered: Int = 0
    @Published var totalCorrectAnswers: Int = 0
    @Published var totalPracticeTime: TimeInterval = 0
    
    // MARK: - Achievement Properties
    
    @Published var unlockedAchievements: [Achievement] = []
    @Published var newlyUnlockedAchievements: [Achievement] = []
    
    // MARK: - Daily Challenge Properties
    
    @Published var dailyChallengeLastCompleted: Date?
    @Published var dailyChallengeStreak: Int = 0
    
    // MARK: - Perfect Score Properties
    
    @Published var perfectScoreStreak: Int = 0
    
    // MARK: - Per-Mode Statistics
    
    @Published var modeStats: [PracticeMode: ModeStatistics] = [:]
    
    // MARK: - Persistence Key
    
    private let profileKey = "JazzHarmonyPlayerProfileV2"
    
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
    
    // Aliases for compatibility
    var totalXP: Int { currentRating }
    var peakXP: Int { peakRating }
    var currentLevel: Rank { currentRank }
    
    var xpToNextLevel: Int? { pointsToNextRank }
    
    // MARK: - Stat Calculations (RPG Stats)
    
    func statValue(for stat: JazzStat) -> Int {
        switch stat {
        case .harmony:
            return calculateModeStat(for: .chordDrill)
        case .ear:
            return calculateModeStat(for: .intervalDrill)
        case .theory:
            return calculateModeStat(for: .scaleDrill)
        case .flow:
            return calculateModeStat(for: .cadenceDrill)
        case .speed:
            return calculateSpeedStat()
        case .precision:
            return calculatePrecisionStat()
        }
    }
    
    var allStats: [JazzStat: Int] {
        var stats: [JazzStat: Int] = [:]
        for stat in JazzStat.allCases {
            stats[stat] = statValue(for: stat)
        }
        return stats
    }
    
    var overallPower: Int {
        let total = JazzStat.allCases.reduce(0) { $0 + statValue(for: $1) }
        return total / JazzStat.allCases.count
    }
    
    private func calculateModeStat(for mode: PracticeMode) -> Int {
        guard let stats = modeStats[mode], stats.totalQuestions > 0 else { return 10 }
        let accuracy = Double(stats.correctAnswers) / Double(stats.totalQuestions)
        let experienceBonus = min(Double(stats.totalQuestions) / 500.0, 1.0) * 20
        return min(100, Int(accuracy * 80) + Int(experienceBonus))
    }
    
    private func calculateSpeedStat() -> Int {
        var totalTime: TimeInterval = 0
        var totalQuestions = 0
        for (_, stats) in modeStats {
            totalTime += stats.totalTime
            totalQuestions += stats.totalQuestions
        }
        guard totalQuestions > 0 else { return 10 }
        let avgTime = totalTime / Double(totalQuestions)
        return max(20, min(100, Int(120 - avgTime * 10)))
    }
    
    private func calculatePrecisionStat() -> Int {
        guard totalQuestionsAnswered > 0 else { return 10 }
        return min(100, Int(overallAccuracy * 100))
    }
    
    // MARK: - Initialization
    
    private init() {
        loadFromUserDefaults()
    }
    
    // MARK: - Rating/XP Management
    
    @discardableResult
    func applyRatingChange(_ change: Int) -> (newRating: Int, didRankUp: Bool, previousRank: Rank) {
        let previousRank = currentRank
        currentRating = max(0, currentRating + change)
        peakRating = max(peakRating, currentRating)
        
        let didRankUp = currentRank.title != previousRank.title && change > 0
        
        saveToUserDefaults()
        return (currentRating, didRankUp, previousRank)
    }
    
    func addXP(_ amount: Int, from mode: PracticeMode) {
        _ = applyRatingChange(amount)
    }
    
    // MARK: - Practice Recording
    
    func recordPractice(questionsAnswered: Int, correctAnswers: Int, time: TimeInterval, wasPerfectScore: Bool) {
        totalQuestionsAnswered += questionsAnswered
        totalCorrectAnswers += correctAnswers
        totalPracticeTime += time
        
        if wasPerfectScore {
            perfectScoreStreak += 1
        } else {
            perfectScoreStreak = 0
        }
        
        checkAchievements(wasPerfectScore: wasPerfectScore)
        saveToUserDefaults()
    }
    
    func recordPractice(mode: PracticeMode, questions: Int, correct: Int, time: TimeInterval) {
        // Update per-mode stats
        var stats = modeStats[mode] ?? ModeStatistics()
        stats.totalQuestions += questions
        stats.correctAnswers += correct
        stats.totalTime += time
        stats.sessionsCompleted += 1
        stats.lastPracticeDate = Date()
        modeStats[mode] = stats
        
        // Also update global totals
        totalQuestionsAnswered += questions
        totalCorrectAnswers += correct
        totalPracticeTime += time
        
        let wasPerfect = questions > 0 && correct == questions
        if wasPerfect {
            perfectScoreStreak += 1
        } else {
            perfectScoreStreak = 0
        }
        
        checkAchievements(wasPerfectScore: wasPerfect)
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
        // Question milestones
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
        let data = PlayerProfileData(
            playerName: playerName,
            avatar: avatar,
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
            perfectScoreStreak: perfectScoreStreak,
            modeStats: modeStats
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
    
    func loadFromUserDefaults() {
        // Try to load new format first
        if let data = UserDefaults.standard.data(forKey: profileKey),
           let decoded = try? JSONDecoder().decode(PlayerProfileData.self, from: data) {
            playerName = decoded.playerName
            avatar = decoded.avatar
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
            modeStats = decoded.modeStats
        } else {
            // Try to migrate from old PlayerStats format
            migrateFromOldPlayerStats()
        }
        
        // Check if streak should be reset
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
    
    private func migrateFromOldPlayerStats() {
        // Try to load from old PlayerStats key
        let oldKey = "JazzHarmonyUnifiedPlayerStats"
        guard let data = UserDefaults.standard.data(forKey: oldKey),
              let decoded = try? JSONDecoder().decode(OldPlayerStatsData.self, from: data) else {
            return
        }
        
        // Migrate data
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
        
        // Save in new format
        saveToUserDefaults()
    }
}

// MARK: - Supporting Data Structures

struct ModeStatistics: Codable {
    var totalQuestions: Int = 0
    var correctAnswers: Int = 0
    var totalTime: TimeInterval = 0
    var sessionsCompleted: Int = 0
    var lastPracticeDate: Date?
    var highScores: [ScoreEntry] = []
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    mutating func addHighScore(_ entry: ScoreEntry) {
        highScores.append(entry)
        highScores.sort { $0.score > $1.score }
        if highScores.count > 10 {
            highScores = Array(highScores.prefix(10))
        }
    }
}

struct ScoreEntry: Codable, Identifiable {
    let id: UUID
    let date: Date
    let score: Int
    let accuracy: Double
    let questionsAnswered: Int
    let correctAnswers: Int
    let time: TimeInterval
    let difficulty: String
    
    init(date: Date = Date(), score: Int, accuracy: Double, questionsAnswered: Int, correctAnswers: Int, time: TimeInterval, difficulty: String) {
        self.id = UUID()
        self.date = date
        self.score = score
        self.accuracy = accuracy
        self.questionsAnswered = questionsAnswered
        self.correctAnswers = correctAnswers
        self.time = time
        self.difficulty = difficulty
    }
}

private struct PlayerProfileData: Codable {
    let playerName: String
    let avatar: PlayerAvatar
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
    let modeStats: [PracticeMode: ModeStatistics]
}

// For migration from old format
private struct OldPlayerStatsData: Codable {
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

// MARK: - Type Alias for Backward Compatibility

typealias PlayerStats = PlayerProfile
