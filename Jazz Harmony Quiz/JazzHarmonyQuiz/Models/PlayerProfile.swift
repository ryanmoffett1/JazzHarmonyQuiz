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

// MARK: - Player Profile

/// The player's RPG-style profile with stats, avatar, and progression
class PlayerProfile: ObservableObject {
    static let shared = PlayerProfile()
    
    // MARK: - Published Properties
    
    @Published var playerName: String = "Jazz Student"
    @Published var avatar: PlayerAvatar = .piano
    @Published var totalXP: Int = 1000  // Global XP (same as old rating)
    @Published var peakXP: Int = 1000
    
    // Per-mode statistics for calculating stats
    @Published var modeStats: [PracticeMode: ModeStatistics] = [:]
    
    // MARK: - Computed Properties
    
    var currentLevel: Rank {
        return Rank.forRating(totalXP)
    }
    
    var xpToNextLevel: Int? {
        guard let nextRank = Rank.nextRank(after: currentLevel) else { return nil }
        return nextRank.minRating - totalXP
    }
    
    /// Calculate a specific stat value (0-100 scale)
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
    
    /// Get all stat values as a dictionary
    var allStats: [JazzStat: Int] {
        var stats: [JazzStat: Int] = [:]
        for stat in JazzStat.allCases {
            stats[stat] = statValue(for: stat)
        }
        return stats
    }
    
    /// Overall "power level" - average of all stats
    var overallPower: Int {
        let total = JazzStat.allCases.reduce(0) { $0 + statValue(for: $1) }
        return total / JazzStat.allCases.count
    }
    
    // MARK: - Private Stat Calculations
    
    private func calculateModeStat(for mode: PracticeMode) -> Int {
        guard let stats = modeStats[mode], stats.totalQuestions > 0 else { return 10 }
        
        // Base stat on accuracy (0-100), weighted by experience
        let accuracy = Double(stats.correctAnswers) / Double(stats.totalQuestions)
        let experienceBonus = min(Double(stats.totalQuestions) / 500.0, 1.0) * 20  // Up to +20 for experience
        
        return min(100, Int(accuracy * 80) + Int(experienceBonus))
    }
    
    private func calculateSpeedStat() -> Int {
        // Average response time across all modes
        // Lower time = higher stat
        var totalTime: TimeInterval = 0
        var totalQuestions = 0
        
        for (_, stats) in modeStats {
            totalTime += stats.totalTime
            totalQuestions += stats.totalQuestions
        }
        
        guard totalQuestions > 0 else { return 10 }
        
        let avgTime = totalTime / Double(totalQuestions)
        // 2 seconds = 100, 10 seconds = 20, scale between
        let speedScore = max(20, min(100, Int(120 - avgTime * 10)))
        return speedScore
    }
    
    private func calculatePrecisionStat() -> Int {
        // Overall accuracy across all modes
        var totalCorrect = 0
        var totalQuestions = 0
        
        for (_, stats) in modeStats {
            totalCorrect += stats.correctAnswers
            totalQuestions += stats.totalQuestions
        }
        
        guard totalQuestions > 0 else { return 10 }
        
        let accuracy = Double(totalCorrect) / Double(totalQuestions)
        return min(100, Int(accuracy * 100))
    }
    
    // MARK: - XP Management
    
    func addXP(_ amount: Int, from mode: PracticeMode) {
        totalXP = max(0, totalXP + amount)
        peakXP = max(peakXP, totalXP)
        saveToUserDefaults()
    }
    
    // MARK: - Mode Stats Recording
    
    func recordPractice(mode: PracticeMode, questions: Int, correct: Int, time: TimeInterval) {
        var stats = modeStats[mode] ?? ModeStatistics()
        stats.totalQuestions += questions
        stats.correctAnswers += correct
        stats.totalTime += time
        stats.sessionsCompleted += 1
        stats.lastPracticeDate = Date()
        modeStats[mode] = stats
        saveToUserDefaults()
    }
    
    // MARK: - Persistence
    
    private let profileKey = "JazzHarmonyPlayerProfile"
    
    private init() {
        loadFromUserDefaults()
    }
    
    func saveToUserDefaults() {
        let data = PlayerProfileData(
            playerName: playerName,
            avatar: avatar,
            totalXP: totalXP,
            peakXP: peakXP,
            modeStats: modeStats
        )
        
        if let encoded = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encoded, forKey: profileKey)
        }
    }
    
    func loadFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: profileKey),
              let decoded = try? JSONDecoder().decode(PlayerProfileData.self, from: data) else {
            return
        }
        
        playerName = decoded.playerName
        avatar = decoded.avatar
        totalXP = decoded.totalXP
        peakXP = decoded.peakXP
        modeStats = decoded.modeStats
    }
}

// MARK: - Supporting Data Structures

struct ModeStatistics: Codable {
    var totalQuestions: Int = 0
    var correctAnswers: Int = 0
    var totalTime: TimeInterval = 0
    var sessionsCompleted: Int = 0
    var lastPracticeDate: Date?
    var highScores: [ScoreEntry] = []  // Top 10 scores for this mode
    
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
    let totalXP: Int
    let peakXP: Int
    let modeStats: [PracticeMode: ModeStatistics]
}
