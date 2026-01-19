import Foundation
import SwiftUI

// MARK: - Scale Drill Statistics

struct ScaleDrillStats: Codable {
    var totalScalesAnswered: Int = 0
    var totalCorrectAnswers: Int = 0
    var totalPracticeTime: TimeInterval = 0
    var perfectScoreStreak: Int = 0
    
    // Per-scale-type stats
    var statsByScaleSymbol: [String: ScaleTypeStatistics] = [:]
    
    // Per-key stats
    var statsByKey: [String: KeyStatistics] = [:]
    
    // Practice log (keep last 100 sessions)
    var practiceLog: [ScalePracticeSession] = []
    
    var overallAccuracy: Double {
        guard totalScalesAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalScalesAnswered)
    }
    
    mutating func recordSession(_ session: ScalePracticeSession) {
        totalScalesAnswered += session.questionsAnswered
        totalCorrectAnswers += session.correctAnswers
        totalPracticeTime += session.duration
        
        // Add to practice log (keep last 100)
        practiceLog.append(session)
        if practiceLog.count > 100 {
            practiceLog.removeFirst()
        }
    }
    
    func todaysPractice() -> (scales: Int, correct: Int, time: TimeInterval) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todaysSessions = practiceLog.filter {
            calendar.isDate($0.date, inSameDayAs: today)
        }
        
        let scales = todaysSessions.reduce(0) { $0 + $1.questionsAnswered }
        let correct = todaysSessions.reduce(0) { $0 + $1.correctAnswers }
        let time = todaysSessions.reduce(0) { $0 + $1.duration }
        
        return (scales, correct, time)
    }
}

struct ScaleTypeStatistics: Codable {
    var questionsAnswered: Int = 0
    var correctAnswers: Int = 0
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
}

struct ScalePracticeSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let questionsAnswered: Int
    let correctAnswers: Int
    let scaleTypes: [String]
    let difficulty: String
    let ratingBefore: Int
    let ratingAfter: Int
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
    
    var ratingChange: Int {
        return ratingAfter - ratingBefore
    }
}

// MARK: - Scale Game

class ScaleGame: ObservableObject {
    @Published var currentQuestion: ScaleQuestion?
    @Published var currentQuestionIndex: Int = 0
    @Published var totalQuestions: Int = 10
    @Published var questions: [ScaleQuestion] = []
    @Published var userAnswers: [UUID: [Note]] = [:]
    @Published var questionStartTime: Date?
    @Published var totalQuizTime: TimeInterval = 0
    @Published var isQuizActive: Bool = false
    @Published var isQuizCompleted: Bool = false
    @Published var currentResult: ScaleQuizResult?
    @Published var selectedDifficulty: ScaleType.ScaleDifficulty = .beginner
    @Published var selectedQuestionTypes: Set<ScaleQuestionType> = [.allDegrees]
    
    // MARK: - Stats & Rating (uses shared PlayerStats for unified rating)
    @Published var stats: ScaleDrillStats = ScaleDrillStats()
    @Published var lastRatingChange: Int = 0
    @Published var didRankUp: Bool = false
    @Published var previousRank: Rank?
    
    // Shared player stats (rating, streaks, achievements)
    var playerStats: PlayerStats { PlayerStats.shared }
    
    // MARK: - Filtering Options
    @Published var selectedScaleSymbols: Set<String> = []  // Empty means all scale types
    @Published var selectedKeyDifficulty: KeyDifficulty = .all
    
    // MARK: - Leaderboard
    @Published var leaderboard: [ScaleQuizResult] = []
    
    private let scaleDatabase = JazzScaleDatabase.shared
    private var quizStartTime: Date?
    
    // MARK: - UserDefaults Keys
    private let statsKey = "JazzHarmonyScaleDrillStats"
    private let leaderboardKey = "JazzHarmonyScaleLeaderboard"
    
    init() {
        loadFromUserDefaults()
    }
    
    // MARK: - Quiz Management
    
    func startNewQuiz(numberOfQuestions: Int, difficulty: ScaleType.ScaleDifficulty, questionTypes: Set<ScaleQuestionType>) {
        totalQuestions = numberOfQuestions
        selectedDifficulty = difficulty
        selectedQuestionTypes = questionTypes
        
        // Reset rating tracking
        lastRatingChange = 0
        didRankUp = false
        previousRank = playerStats.currentRank
        
        generateQuestions()
        currentQuestionIndex = 0
        userAnswers = [:]
        totalQuizTime = 0
        isQuizActive = true
        isQuizCompleted = false
        currentResult = nil
        quizStartTime = Date()
        
        if !questions.isEmpty {
            currentQuestion = questions[0]
            questionStartTime = Date()
        }
    }
    
    private func generateQuestions() {
        questions = []
        
        // Get available roots based on key difficulty (map Note objects to names)
        let availableRoots = selectedKeyDifficulty.availableRoots.map { $0.name }
        
        for _ in 0..<totalQuestions {
            guard let scale = scaleDatabase.getRandomScale(
                difficulty: selectedDifficulty,
                rootNames: availableRoots.isEmpty ? nil : availableRoots,
                scaleSymbols: selectedScaleSymbols.isEmpty ? nil : selectedScaleSymbols
            ) else { continue }
            
            // Select random question type from selected types
            guard let questionType = selectedQuestionTypes.randomElement() else { continue }
            
            var targetDegree: ScaleDegree? = nil
            
            if questionType == .singleDegree {
                // Pick a random non-root, non-octave degree
                let availableDegrees = scale.scaleType.degrees.filter { 
                    $0.degree != 1 && $0.degree != 8 
                }
                targetDegree = availableDegrees.randomElement()
            }
            
            let question = ScaleQuestion(
                scale: scale,
                questionType: questionType,
                targetDegree: targetDegree
            )
            questions.append(question)
        }
    }
    
    // MARK: - Answer Submission
    
    func submitAnswer(_ notes: Set<Note>) -> Bool {
        guard let question = currentQuestion else { return false }
        
        // Record answer
        userAnswers[question.id] = Array(notes)
        
        // Check if correct using pitch-class comparison
        let isCorrect = question.checkAnswer(notes)
        
        // Update stats for this scale type
        let symbol = question.scale.scaleType.symbol
        var scaleStats = stats.statsByScaleSymbol[symbol] ?? ScaleTypeStatistics()
        scaleStats.questionsAnswered += 1
        if isCorrect { scaleStats.correctAnswers += 1 }
        stats.statsByScaleSymbol[symbol] = scaleStats
        
        // Update stats for this key
        let key = question.scale.root.name
        var keyStats = stats.statsByKey[key] ?? KeyStatistics()
        keyStats.questionsAnswered += 1
        if isCorrect { keyStats.correctAnswers += 1 }
        stats.statsByKey[key] = keyStats
        
        return isCorrect
    }
    
    func moveToNextQuestion() {
        // Record time for current question
        if let startTime = questionStartTime {
            totalQuizTime += Date().timeIntervalSince(startTime)
        }
        
        currentQuestionIndex += 1
        
        if currentQuestionIndex < questions.count {
            currentQuestion = questions[currentQuestionIndex]
            questionStartTime = Date()
        } else {
            finishQuiz()
        }
    }
    
    // MARK: - Quiz Completion
    
    private func finishQuiz() {
        isQuizActive = false
        isQuizCompleted = true
        
        // Calculate final time if not already done
        if let startTime = questionStartTime {
            totalQuizTime += Date().timeIntervalSince(startTime)
        }
        
        // Calculate score
        let correctCount = calculateCorrectAnswers()
        let accuracy = totalQuestions > 0 ? Double(correctCount) / Double(totalQuestions) : 0
        let wasPerfectScore = correctCount == totalQuestions
        
        // Calculate rating change
        let ratingChange = calculateRatingChange(correct: correctCount, total: totalQuestions)
        lastRatingChange = ratingChange
        
        // Apply rating change via PlayerStats
        let result = playerStats.applyRatingChange(ratingChange)
        didRankUp = result.didRankUp
        previousRank = result.previousRank
        
        // Record practice in PlayerStats
        playerStats.recordPractice(
            questionsAnswered: totalQuestions,
            correctAnswers: correctCount,
            time: totalQuizTime,
            wasPerfectScore: wasPerfectScore
        )
        
        // Update streak
        playerStats.updateStreak()
        
        // Create result
        let scaleTypes = Array(Set(questions.map { $0.scale.scaleType.symbol }))
        currentResult = ScaleQuizResult(
            date: Date(),
            totalQuestions: totalQuestions,
            correctAnswers: correctCount,
            totalTime: totalQuizTime,
            difficulty: selectedDifficulty,
            questionTypes: Array(selectedQuestionTypes),
            ratingChange: ratingChange,
            scaleTypes: scaleTypes
        )
        
        // Record session in local stats
        let session = ScalePracticeSession(
            id: UUID(),
            date: Date(),
            duration: totalQuizTime,
            questionsAnswered: totalQuestions,
            correctAnswers: correctCount,
            scaleTypes: scaleTypes,
            difficulty: selectedDifficulty.rawValue,
            ratingBefore: playerStats.currentRating - ratingChange,
            ratingAfter: playerStats.currentRating
        )
        stats.recordSession(session)
        
        // Update perfect score streak
        if wasPerfectScore {
            stats.perfectScoreStreak += 1
        } else {
            stats.perfectScoreStreak = 0
        }
        
        // Add to leaderboard
        if let result = currentResult {
            addToLeaderboard(result)
        }
        
        saveToUserDefaults()
    }
    
    private func calculateCorrectAnswers() -> Int {
        var correct = 0
        for question in questions {
            if let answer = userAnswers[question.id] {
                if question.checkAnswer(Set(answer)) {
                    correct += 1
                }
            }
        }
        return correct
    }
    
    /// Rating change calculation (matches chord drill formula)
    private func calculateRatingChange(correct: Int, total: Int) -> Int {
        guard total > 0 else { return 0 }
        
        let accuracy = Double(correct) / Double(total)
        let currentRating = playerStats.currentRating
        
        // Base points depend on difficulty
        let basePoints: Double
        switch selectedDifficulty {
        case .beginner: basePoints = 8
        case .intermediate: basePoints = 12
        case .advanced: basePoints = 18
        }
        
        // Scale by number of questions (more questions = more potential change)
        let questionMultiplier = min(Double(total) / 10.0, 2.0)
        
        // Performance factor: >70% gains, <50% loses, between is reduced
        let performanceFactor: Double
        if accuracy >= 0.9 {
            performanceFactor = 1.5  // Bonus for excellence
        } else if accuracy >= 0.7 {
            performanceFactor = accuracy
        } else if accuracy >= 0.5 {
            performanceFactor = (accuracy - 0.5) * 0.5  // Reduced gains
        } else {
            performanceFactor = -(0.5 - accuracy)  // Losses for poor performance
        }
        
        // Rating adjustment (higher rated players gain less, lose more)
        let ratingFactor = max(0.5, 1.0 - (Double(currentRating) - 1000) / 2000)
        
        let change = Int(basePoints * questionMultiplier * performanceFactor * ratingFactor)
        
        return change
    }
    
    // MARK: - Leaderboard
    
    private func addToLeaderboard(_ result: ScaleQuizResult) {
        leaderboard.append(result)
        leaderboard.sort { 
            $0.accuracy > $1.accuracy || 
            ($0.accuracy == $1.accuracy && $0.totalTime < $1.totalTime) 
        }
        leaderboard = Array(leaderboard.prefix(10))
    }
    
    // MARK: - Quiz State Management
    
    func resetQuizState() {
        currentQuestion = nil
        currentQuestionIndex = 0
        questions = []
        userAnswers = [:]
        questionStartTime = nil
        totalQuizTime = 0
        isQuizActive = false
        isQuizCompleted = false
        currentResult = nil
        lastRatingChange = 0
        didRankUp = false
        previousRank = nil
    }
    
    // MARK: - Computed Properties
    
    var currentQuestionNumber: Int {
        return currentQuestionIndex + 1
    }
    
    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestionIndex) / Double(totalQuestions)
    }
    
    /// Get weak scale types for practice suggestions
    func getWeakScaleTypes(limit: Int = 3) -> [ScaleType] {
        let weakSymbols = stats.statsByScaleSymbol
            .filter { $0.value.questionsAnswered >= 5 && $0.value.accuracy < 0.7 }
            .sorted { $0.value.accuracy < $1.value.accuracy }
            .prefix(limit)
            .map { $0.key }
        
        return weakSymbols.compactMap { scaleDatabase.getScaleType(bySymbol: $0) }
    }
    
    // MARK: - Persistence
    
    func saveToUserDefaults() {
        // Save stats
        if let encodedStats = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encodedStats, forKey: statsKey)
        }
        
        // Save leaderboard
        if let encodedLeaderboard = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encodedLeaderboard, forKey: leaderboardKey)
        }
    }
    
    func loadFromUserDefaults() {
        // Load stats
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(ScaleDrillStats.self, from: data) {
            stats = decoded
        }
        
        // Load leaderboard
        if let data = UserDefaults.standard.data(forKey: leaderboardKey),
           let decoded = try? JSONDecoder().decode([ScaleQuizResult].self, from: data) {
            leaderboard = decoded
        }
    }
}
