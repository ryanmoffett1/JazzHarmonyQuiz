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
    
    // MARK: - Ear Training Answer Choices
    @Published var currentAnswerChoices: [ScaleType] = []
    
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
    
    // MARK: - Scoreboard
    @Published var scoreboard: [ScaleQuizResult] = []
    
    private let scaleDatabase = JazzScaleDatabase.shared
    private var quizStartTime: Date?
    
    // MARK: - UserDefaults Keys
    private let statsKey = "JazzHarmonyScaleDrillStats"
    private let scoreboardKey = "JazzHarmonyScaleScoreboard"
    
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
        
        // Generate answer choices for first question if ear training
        if let firstQuestion = questions.first, firstQuestion.questionType == .earTraining {
            currentAnswerChoices = generateAnswerChoices(for: firstQuestion.scale.scaleType)
        }
    }
    
    // MARK: - Ear Training Answer Choices
    
    /// Generate answer choices for ear training (scale type recognition)
    func generateAnswerChoices(for correctScale: ScaleType) -> [ScaleType] {
        // Get all scale types for current difficulty
        var pool = scaleDatabase.scaleTypes.filter { $0.difficulty == selectedDifficulty }
        
        // If not enough for variety, include adjacent difficulties
        if pool.count < 6 {
            if selectedDifficulty == .intermediate {
                pool += scaleDatabase.scaleTypes.filter { $0.difficulty == .beginner || $0.difficulty == .advanced }
            } else if selectedDifficulty == .beginner {
                pool += scaleDatabase.scaleTypes.filter { $0.difficulty == .intermediate }
            } else if selectedDifficulty == .advanced {
                pool += scaleDatabase.scaleTypes.filter { $0.difficulty == .intermediate }
            }
        }
        
        // Remove the correct answer from pool
        pool = pool.filter { $0.id != correctScale.id }
        
        // Calculate similarity scores for each scale type
        let scoredChoices = pool.map { scaleType -> (ScaleType, Int) in
            let similarity = calculateScaleSimilarity(correctScale, scaleType)
            return (scaleType, similarity)
        }
        
        // Sort by similarity (most similar first) and take top 3
        let distractors = scoredChoices
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { $0.0 }
        
        // Combine correct answer with distractors and shuffle
        var choices = Array(distractors) + [correctScale]
        choices.shuffle()
        
        return choices
    }
    
    /// Calculate similarity between two scale types (higher = more similar)
    private func calculateScaleSimilarity(_ scale1: ScaleType, _ scale2: ScaleType) -> Int {
        var score = 0
        
        // Same number of notes = more similar
        if scale1.degrees.count == scale2.degrees.count {
            score += 3
        }
        
        // Check for common intervals
        let intervals1 = Set(scale1.degrees.map { $0.semitonesFromRoot })
        let intervals2 = Set(scale2.degrees.map { $0.semitonesFromRoot })
        let commonIntervals = intervals1.intersection(intervals2).count
        score += commonIntervals * 2
        
        // Major vs minor quality (both have natural 3rd or both have b3)
        let hasMajor3_1 = scale1.degrees.contains { $0.semitonesFromRoot == 4 }
        let hasMajor3_2 = scale2.degrees.contains { $0.semitonesFromRoot == 4 }
        let hasMinor3_1 = scale1.degrees.contains { $0.semitonesFromRoot == 3 }
        let hasMinor3_2 = scale2.degrees.contains { $0.semitonesFromRoot == 3 }
        if (hasMajor3_1 && hasMajor3_2) || (hasMinor3_1 && hasMinor3_2) {
            score += 4
        }
        
        // Same 7th type (major 7 vs minor 7)
        let hasMajor7_1 = scale1.degrees.contains { $0.semitonesFromRoot == 11 }
        let hasMajor7_2 = scale2.degrees.contains { $0.semitonesFromRoot == 11 }
        let hasMinor7_1 = scale1.degrees.contains { $0.semitonesFromRoot == 10 }
        let hasMinor7_2 = scale2.degrees.contains { $0.semitonesFromRoot == 10 }
        if (hasMajor7_1 && hasMajor7_2) || (hasMinor7_1 && hasMinor7_2) {
            score += 3
        }
        
        return score
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
    
    /// Record answer for ear training question (no notes, just scale type identification)
    func recordEarTrainingAnswer(correct: Bool) {
        guard let question = currentQuestion else { return }
        
        // Update stats for this scale type
        let symbol = question.scale.scaleType.symbol
        var scaleStats = stats.statsByScaleSymbol[symbol] ?? ScaleTypeStatistics()
        scaleStats.questionsAnswered += 1
        if correct { scaleStats.correctAnswers += 1 }
        stats.statsByScaleSymbol[symbol] = scaleStats
        
        // Update stats for this key
        let key = question.scale.root.name
        var keyStats = stats.statsByKey[key] ?? KeyStatistics()
        keyStats.questionsAnswered += 1
        if correct { keyStats.correctAnswers += 1 }
        stats.statsByKey[key] = keyStats
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
            
            // Generate new answer choices if ear training
            if let question = currentQuestion, question.questionType == .earTraining {
                currentAnswerChoices = generateAnswerChoices(for: question.scale.scaleType)
            }
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
        
        // Record to PlayerProfile for RPG stats
        PlayerProfile.shared.recordPractice(
            mode: .scaleDrill,
            questions: totalQuestions,
            correct: correctCount,
            time: totalQuizTime
        )
        PlayerProfile.shared.addXP(ratingChange, from: .scaleDrill)
        
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
        
        // Add to scoreboard
        if let result = currentResult {
            addToScoreboard(result)
        }
        
        saveToUserDefaults()
        
        // Spaced Repetition: Record results for each question
        recordSpacedRepetitionResults()
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
        case .custom: basePoints = 15  // Variable difficulty
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
    
    // MARK: - Scoreboard
    
    private func addToScoreboard(_ result: ScaleQuizResult) {
        scoreboard.append(result)
        scoreboard.sort { 
            $0.accuracy > $1.accuracy || 
            ($0.accuracy == $1.accuracy && $0.totalTime < $1.totalTime) 
        }
        scoreboard = Array(scoreboard.prefix(10))
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
    
    // MARK: - Spaced Repetition Integration
    
    /// Record spaced repetition results for all questions in the quiz
    private func recordSpacedRepetitionResults() {
        let srStore = SpacedRepetitionStore.shared
        
        for question in questions {
            guard let userAnswer = userAnswers[question.id] else { continue }
            let wasCorrect = question.checkAnswer(Set(userAnswer))
            
            // Calculate time spent on this question (estimate based on total quiz time)
            let avgTimePerQuestion = totalQuizTime / Double(totalQuestions)
            
            // Determine variant based on question type
            let variant: String
            switch question.questionType {
            case .singleDegree:
                // Include the specific degree being tested
                if let degree = question.targetDegree {
                    variant = "degree-\(degree.degree)"
                } else {
                    variant = "single"
                }
            case .allDegrees:
                variant = "all-degrees"
            case .earTraining:
                variant = "ear-training"
            }
            
            let itemID = SRItemID(
                mode: .scaleDrill,
                topic: question.scale.scaleType.symbol,
                key: question.scale.root.name,
                variant: variant
            )
            
            // Record result
            srStore.recordResult(
                itemID: itemID,
                wasCorrect: wasCorrect,
                responseTime: avgTimePerQuestion
            )
        }
    }
    
    // MARK: - Persistence
    
    func saveToUserDefaults() {
        // Save stats
        if let encodedStats = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encodedStats, forKey: statsKey)
        }
        
        // Save scoreboard
        if let encodedScoreboard = try? JSONEncoder().encode(scoreboard) {
            UserDefaults.standard.set(encodedScoreboard, forKey: scoreboardKey)
        }
    }
    
    func loadFromUserDefaults() {
        // Load stats
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(ScaleDrillStats.self, from: data) {
            stats = decoded
        }
        
        // Load scoreboard
        if let data = UserDefaults.standard.data(forKey: scoreboardKey),
           let decoded = try? JSONDecoder().decode([ScaleQuizResult].self, from: data) {
            scoreboard = decoded
        }
    }
}
