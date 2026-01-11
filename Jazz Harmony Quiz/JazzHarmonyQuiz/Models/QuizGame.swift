import Foundation
import SwiftUI

// MARK: - Rank System

struct Rank: Equatable {
    let title: String
    let emoji: String
    let minRating: Int
    let maxRating: Int
    
    static let allRanks: [Rank] = [
        Rank(title: "Shed Rat", emoji: "🐀", minRating: 0, maxRating: 500),
        Rank(title: "Practice Room Regular", emoji: "🎹", minRating: 501, maxRating: 750),
        Rank(title: "Jam Session Ready", emoji: "🎤", minRating: 751, maxRating: 1000),
        Rank(title: "Gigging Musician", emoji: "🎷", minRating: 1001, maxRating: 1250),
        Rank(title: "Session Cat", emoji: "🐱", minRating: 1251, maxRating: 1500),
        Rank(title: "Bebop Scholar", emoji: "📚", minRating: 1501, maxRating: 1750),
        Rank(title: "Harmony Hipster", emoji: "😎", minRating: 1751, maxRating: 2000),
        Rank(title: "Chord Wizard", emoji: "🧙", minRating: 2001, maxRating: 2250),
        Rank(title: "Voicing Virtuoso", emoji: "✨", minRating: 2251, maxRating: 2500),
        Rank(title: "Jazz Elder", emoji: "🎩", minRating: 2501, maxRating: 2750),
        Rank(title: "Harmony Master", emoji: "👑", minRating: 2751, maxRating: 3000),
        Rank(title: "Living Legend", emoji: "🌟", minRating: 3001, maxRating: Int.max)
    ]
    
    static func forRating(_ rating: Int) -> Rank {
        return allRanks.first { rating >= $0.minRating && rating <= $0.maxRating } ?? allRanks[0]
    }
    
    static func nextRank(after rank: Rank) -> Rank? {
        guard let index = allRanks.firstIndex(where: { $0.title == rank.title }),
              index < allRanks.count - 1 else { return nil }
        return allRanks[index + 1]
    }
    
    var pointsToNextRank: Int? {
        guard let next = Rank.nextRank(after: self) else { return nil }
        return next.minRating - minRating
    }
}

// MARK: - Practice Session Log

struct PracticeSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let questionsAnswered: Int
    let correctAnswers: Int
    let chordTypes: [String]
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

// MARK: - Chord Drill Statistics

struct ChordDrillStats: Codable {
    var totalChordsAnswered: Int = 0
    var totalCorrectAnswers: Int = 0
    var totalPracticeTime: TimeInterval = 0
    var currentRating: Int = 1000  // Start at "Jam Session Ready"
    var peakRating: Int = 1000
    var currentStreak: Int = 0
    var longestStreak: Int = 0
    var lastPracticeDate: Date?
    var dailyChallengeLastCompleted: Date?
    var dailyChallengeStreak: Int = 0
    
    // Per-chord-type stats
    var statsByChordSymbol: [String: ChordTypeStatistics] = [:]
    
    // Per-key stats
    var statsByKey: [String: KeyStatistics] = [:]
    
    // Practice log (keep last 100 sessions)
    var practiceLog: [PracticeSession] = []
    
    var overallAccuracy: Double {
        guard totalChordsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalChordsAnswered)
    }
    
    var currentRank: Rank {
        return Rank.forRating(currentRating)
    }
    
    var pointsToNextRank: Int? {
        guard let nextRank = Rank.nextRank(after: currentRank) else { return nil }
        return nextRank.minRating - currentRating
    }
    
    mutating func recordSession(_ session: PracticeSession) {
        totalChordsAnswered += session.questionsAnswered
        totalCorrectAnswers += session.correctAnswers
        totalPracticeTime += session.duration
        currentRating = session.ratingAfter
        peakRating = max(peakRating, currentRating)
        
        // Add to practice log (keep last 100)
        practiceLog.append(session)
        if practiceLog.count > 100 {
            practiceLog.removeFirst()
        }
    }
    
    mutating func updateStreak() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let lastDate = lastPracticeDate {
            let lastDay = calendar.startOfDay(for: lastDate)
            let daysDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0
            
            if daysDiff == 1 {
                // Consecutive day - increment streak
                currentStreak += 1
            } else if daysDiff > 1 {
                // Missed a day - reset streak
                currentStreak = 1
            }
            // daysDiff == 0 means same day, don't change streak
        } else {
            // First practice ever
            currentStreak = 1
        }
        
        longestStreak = max(longestStreak, currentStreak)
        lastPracticeDate = Date()
    }
    
    func todaysPractice() -> (chords: Int, correct: Int, time: TimeInterval) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        let todaysSessions = practiceLog.filter {
            calendar.isDate($0.date, inSameDayAs: today)
        }
        
        let chords = todaysSessions.reduce(0) { $0 + $1.questionsAnswered }
        let correct = todaysSessions.reduce(0) { $0 + $1.correctAnswers }
        let time = todaysSessions.reduce(0) { $0 + $1.duration }
        
        return (chords, correct, time)
    }
    
    func thisWeeksPractice() -> (chords: Int, correct: Int, time: TimeInterval, days: Int) {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        let weekSessions = practiceLog.filter { $0.date >= weekAgo }
        
        let chords = weekSessions.reduce(0) { $0 + $1.questionsAnswered }
        let correct = weekSessions.reduce(0) { $0 + $1.correctAnswers }
        let time = weekSessions.reduce(0) { $0 + $1.duration }
        let uniqueDays = Set(weekSessions.map { calendar.startOfDay(for: $0.date) }).count
        
        return (chords, correct, time, uniqueDays)
    }
    
    /// Check if daily challenge was completed today
    var isDailyChallengeCompletedToday: Bool {
        guard let lastCompleted = dailyChallengeLastCompleted else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
    
    mutating func completeDailyChallenge() {
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
    }
}

struct ChordTypeStatistics: Codable {
    var questionsAnswered: Int = 0
    var correctAnswers: Int = 0
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
}

struct KeyStatistics: Codable {
    var questionsAnswered: Int = 0
    var correctAnswers: Int = 0
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered)
    }
}

// MARK: - Quiz Game

class QuizGame: ObservableObject {
    @Published var currentQuestion: QuizQuestion?
    @Published var currentQuestionIndex: Int = 0
    @Published var totalQuestions: Int = 10
    @Published var questions: [QuizQuestion] = []
    @Published var userAnswers: [UUID: [Note]] = [:]
    @Published var questionStartTime: Date?
    @Published var totalQuizTime: TimeInterval = 0
    @Published var isQuizActive: Bool = false
    @Published var isQuizCompleted: Bool = false
    @Published var currentResult: QuizResult?
    @Published var selectedDifficulty: ChordType.ChordDifficulty = .beginner
    @Published var selectedQuestionTypes: Set<QuestionType> = [.singleTone, .allTones]
    
    // MARK: - Stats & Rating
    @Published var stats: ChordDrillStats = ChordDrillStats()
    @Published var isDailyChallenge: Bool = false
    @Published var lastRatingChange: Int = 0
    @Published var didRankUp: Bool = false
    @Published var previousRank: Rank?
    
    // MARK: - Filtering Options
    @Published var selectedRoots: Set<Note> = []  // Empty means all roots
    @Published var selectedChordSymbols: Set<String> = []  // Empty means all chord types
    @Published var selectedQuestionTypes: Set<QuestionType> = [.singleTone, .allTones]
    
    private let chordDatabase = JazzChordDatabase.shared
    private var quizStartTime: Date?
    private var timer: Timer?
    
    // MARK: - UserDefaults Keys
    private let statsKey = "JazzHarmonyChordDrillStats"
    
    // MARK: - Quiz Management
    
    func startNewQuiz(numberOfQuestions: Int, difficulty: ChordType.ChordDifficulty, questionTypes: Set<QuestionType>, isDaily: Bool = false) {
        totalQuestions = numberOfQuestions
        selectedDifficulty = difficulty
        selectedQuestionTypes = questionTypes
        isDailyChallenge = isDaily
        
        // Reset rating tracking
        lastRatingChange = 0
        didRankUp = false
        previousRank = stats.currentRank
        
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
    
    /// Start the daily challenge with deterministic seed
    func startDailyChallenge() {
        // Generate deterministic seed from today's date
        let seed = dailyChallengeSeed()
        var rng = SeededRandomNumberGenerator(seed: UInt64(seed))
        
        // Fixed daily challenge configuration
        let difficulties: [ChordType.ChordDifficulty] = [.beginner, .intermediate, .advanced]
        let difficulty = difficulties[Int.random(in: 0..<difficulties.count, using: &rng)]
        
        isDailyChallenge = true
        totalQuestions = 10
        selectedDifficulty = difficulty
        selectedQuestionTypes = [.allTones, .chordSpelling]
        
        // Reset rating tracking
        lastRatingChange = 0
        didRankUp = false
        previousRank = stats.currentRank
        
        generateDailyChallengeQuestions(seed: seed)
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
    
    private func dailyChallengeSeed() -> Int {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: Date())
        return (components.year! * 10000) + (components.month! * 100) + components.day!
    }
    
    private func generateDailyChallengeQuestions(seed: Int) {
        var rng = SeededRandomNumberGenerator(seed: UInt64(seed))
        questions = []
        
        let allChords = chordDatabase.getAllChords(difficulty: selectedDifficulty)
        guard !allChords.isEmpty else { return }
        
        for _ in 0..<totalQuestions {
            let chord = allChords[Int.random(in: 0..<allChords.count, using: &rng)]
            let questionTypes = Array(selectedQuestionTypes)
            let questionType = questionTypes[Int.random(in: 0..<questionTypes.count, using: &rng)]
            
            let question: QuizQuestion
            switch questionType {
            case .singleTone:
                let availableTones = chord.chordType.chordTones
                let targetTone = availableTones[Int.random(in: 0..<availableTones.count, using: &rng)]
                question = QuizQuestion(chord: chord, questionType: .singleTone, targetTone: targetTone)
            case .allTones:
                question = QuizQuestion(chord: chord, questionType: .allTones)
            case .chordSpelling:
                question = QuizQuestion(chord: chord, questionType: .chordSpelling)
            }
            questions.append(question)
        }
    }
    
    private func generateQuestions() {
        questions = []
        
        for _ in 0..<totalQuestions {
            let chord = chordDatabase.getRandomChord(difficulty: selectedDifficulty)
            let questionType = selectedQuestionTypes.randomElement() ?? .singleTone
            
            let question: QuizQuestion
            
            switch questionType {
            case .singleTone:
                // Pick a random chord tone to ask about
                let availableTones = chord.chordType.chordTones
                let targetTone = availableTones.randomElement()
                question = QuizQuestion(chord: chord, questionType: .singleTone, targetTone: targetTone)
                
            case .allTones:
                question = QuizQuestion(chord: chord, questionType: .allTones)
                
            case .chordSpelling:
                question = QuizQuestion(chord: chord, questionType: .chordSpelling)
            }
            
            questions.append(question)
        }
    }
    
    func submitAnswer(_ notes: [Note]) {
        guard let question = currentQuestion else { return }
        
        // Record the answer
        userAnswers[question.id] = notes
        
        // Calculate time for this question
        if let startTime = questionStartTime {
            let questionTime = Date().timeIntervalSince(startTime)
            totalQuizTime += questionTime
        }
        
        // Move to next question
        nextQuestion()
    }
    
    private func nextQuestion() {
        currentQuestionIndex += 1
        
        if currentQuestionIndex < questions.count {
            currentQuestion = questions[currentQuestionIndex]
            questionStartTime = Date()
        } else {
            finishQuiz()
        }
    }
    
    private func finishQuiz() {
        isQuizActive = false
        isQuizCompleted = true
        
        // Calculate final results
        var correctAnswers = 0
        var questionResults: [UUID: Bool] = [:]
        
        for question in questions {
            let userAnswer = userAnswers[question.id] ?? []
            let isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
            questionResults[question.id] = isCorrect
            
            if isCorrect {
                correctAnswers += 1
            }
        }
        
        currentResult = QuizResult(
            date: Date(),
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            totalTime: totalQuizTime,
            questions: questions,
            userAnswers: userAnswers,
            isCorrect: questionResults
        )
        
        // Save to leaderboard
        if let result = currentResult {
            saveToLeaderboard(result)
        }
        
        // Calculate and apply rating change
        let ratingChange = calculateRatingChange(correctAnswers: correctAnswers, totalQuestions: totalQuestions)
        let ratingBefore = stats.currentRating
        let previousRankTitle = stats.currentRank.title
        
        // Create practice session
        let chordTypesUsed = Array(Set(questions.map { $0.chord.chordType.symbol }))
        let session = PracticeSession(
            id: UUID(),
            date: Date(),
            duration: totalQuizTime,
            questionsAnswered: totalQuestions,
            correctAnswers: correctAnswers,
            chordTypes: chordTypesUsed,
            difficulty: selectedDifficulty.rawValue,
            ratingBefore: ratingBefore,
            ratingAfter: ratingBefore + ratingChange
        )
        
        // Update stats
        stats.recordSession(session)
        stats.updateStreak()
        
        // Update per-chord and per-key stats
        for question in questions {
            let isCorrect = questionResults[question.id] ?? false
            let chordSymbol = question.chord.chordType.symbol
            let keyName = question.chord.root.name
            
            var chordStats = stats.statsByChordSymbol[chordSymbol] ?? ChordTypeStatistics()
            chordStats.questionsAnswered += 1
            if isCorrect { chordStats.correctAnswers += 1 }
            stats.statsByChordSymbol[chordSymbol] = chordStats
            
            var keyStats = stats.statsByKey[keyName] ?? KeyStatistics()
            keyStats.questionsAnswered += 1
            if isCorrect { keyStats.correctAnswers += 1 }
            stats.statsByKey[keyName] = keyStats
        }
        
        // Track rating change for UI
        lastRatingChange = ratingChange
        
        // Check for rank up
        let newRankTitle = stats.currentRank.title
        didRankUp = newRankTitle != previousRankTitle && ratingChange > 0
        
        // Handle daily challenge completion
        if isDailyChallenge && !stats.isDailyChallengeCompletedToday {
            stats.completeDailyChallenge()
        }
        
        // Save stats
        saveStatsToUserDefaults()
    }
    
    /// Calculate rating change based on performance
    private func calculateRatingChange(correctAnswers: Int, totalQuestions: Int) -> Int {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        
        // Base points from accuracy
        var points: Double = 0
        
        if accuracy >= 1.0 {
            points = 30  // Perfect score bonus
        } else if accuracy >= 0.9 {
            points = 20
        } else if accuracy >= 0.8 {
            points = 15
        } else if accuracy >= 0.7 {
            points = 10
        } else if accuracy >= 0.6 {
            points = 5
        } else if accuracy >= 0.5 {
            points = 0  // Break even
        } else if accuracy >= 0.3 {
            points = -5
        } else {
            points = -10
        }
        
        // Difficulty multiplier
        let difficultyMultiplier: Double
        switch selectedDifficulty {
        case .beginner:
            difficultyMultiplier = 0.5
        case .intermediate:
            difficultyMultiplier = 1.0
        case .advanced:
            difficultyMultiplier = 1.5
        case .expert:
            difficultyMultiplier = 2.0
        }
        
        // Question count bonus (more questions = more reliable score)
        let questionBonus = Double(totalQuestions) / 10.0  // 1.0 for 10 questions
        
        // Daily challenge bonus
        let dailyBonus: Double = isDailyChallenge ? 1.25 : 1.0
        
        // Speed bonus (if fast and accurate)
        let avgTimePerQuestion = totalQuizTime / Double(totalQuestions)
        let speedBonus: Double
        if accuracy >= 0.7 && avgTimePerQuestion < 5.0 {
            speedBonus = 1.2
        } else if accuracy >= 0.7 && avgTimePerQuestion < 10.0 {
            speedBonus = 1.1
        } else {
            speedBonus = 1.0
        }
        
        let finalPoints = points * difficultyMultiplier * questionBonus * dailyBonus * speedBonus
        
        // Ensure rating doesn't go below 0
        let newRating = max(0, stats.currentRating + Int(finalPoints.rounded()))
        return newRating - stats.currentRating
    }
    
    private func isAnswerCorrect(userAnswer: [Note], question: QuizQuestion) -> Bool {
        let correctAnswer = question.correctAnswer
        
        // Helper function to normalize MIDI number to pitch class (0-11)
        func pitchClass(_ midiNumber: Int) -> Int {
            return ((midiNumber - 60) % 12 + 12) % 12
        }
        
        // For single tone questions, check if the user selected the correct note
        if question.questionType == .singleTone {
            guard userAnswer.count == 1, correctAnswer.count == 1 else { return false }
            // Compare pitch classes to handle different octaves
            return pitchClass(userAnswer[0].midiNumber) == pitchClass(correctAnswer[0].midiNumber)
        }
        
        // For all tones and chord spelling, check if all correct notes are selected
        // and no incorrect notes are selected (comparing pitch classes)
        let userPitchClasses = Set(userAnswer.map { pitchClass($0.midiNumber) })
        let correctPitchClasses = Set(correctAnswer.map { pitchClass($0.midiNumber) })
        
        return userPitchClasses == correctPitchClasses
    }
    
    // MARK: - Leaderboard Management
    
    @Published var leaderboard: [QuizResult] = []
    
    private func saveToLeaderboard(_ result: QuizResult) {
        leaderboard.append(result)
        leaderboard.sort { first, second in
            // Sort by accuracy first, then by time
            if first.accuracy != second.accuracy {
                return first.accuracy > second.accuracy
            }
            return first.totalTime < second.totalTime
        }
        
        // Keep only top 10
        if leaderboard.count > 10 {
            leaderboard = Array(leaderboard.prefix(10))
        }
        
        // Save to UserDefaults
        saveLeaderboardToUserDefaults()
    }
    
    func saveLeaderboardToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encoded, forKey: "JazzHarmonyLeaderboard")
        }
    }
    
    func loadLeaderboardFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "JazzHarmonyLeaderboard"),
           let decoded = try? JSONDecoder().decode([QuizResult].self, from: data) {
            leaderboard = decoded
        }
    }
    
    // MARK: - Stats Persistence
    
    func saveStatsToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(encoded, forKey: statsKey)
        }
    }
    
    func loadStatsFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(ChordDrillStats.self, from: data) {
            stats = decoded
        }
    }
    
    // MARK: - Quick Practice
    
    /// Start a quick 5-question practice with current settings
    func startQuickPractice() {
        startNewQuiz(
            numberOfQuestions: 5,
            difficulty: selectedDifficulty,
            questionTypes: selectedQuestionTypes
        )
    }
    
    /// Whether user has practiced today
    var hasPracticedToday: Bool {
        guard let lastDate = stats.lastPracticeDate else { return false }
        return Calendar.current.isDateInToday(lastDate)
    }
    
    // MARK: - Weak Areas
    
    /// Get chord types with lowest accuracy (min 5 attempts)
    func getWeakChordTypes(limit: Int = 3) -> [(symbol: String, accuracy: Double)] {
        return stats.statsByChordSymbol
            .filter { $0.value.questionsAnswered >= 5 }
            .map { (symbol: $0.key, accuracy: $0.value.accuracy) }
            .sorted { $0.accuracy < $1.accuracy }
            .prefix(limit)
            .map { $0 }
    }
    
    /// Get keys with lowest accuracy (min 5 attempts)
    func getWeakKeys(limit: Int = 3) -> [(key: String, accuracy: Double)] {
        return stats.statsByKey
            .filter { $0.value.questionsAnswered >= 5 }
            .map { (key: $0.key, accuracy: $0.value.accuracy) }
            .sorted { $0.accuracy < $1.accuracy }
            .prefix(limit)
            .map { $0 }
    }
    
    // MARK: - Timer Management
    
    func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            // Update any timer-related UI if needed
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Question Navigation
    
    func canGoToNextQuestion() -> Bool {
        return currentQuestionIndex < questions.count - 1
    }
    
    func canGoToPreviousQuestion() -> Bool {
        return currentQuestionIndex > 0
    }
    
    func goToNextQuestion() {
        if canGoToNextQuestion() {
            currentQuestionIndex += 1
            currentQuestion = questions[currentQuestionIndex]
            questionStartTime = Date()
        }
    }
    
    func goToPreviousQuestion() {
        if canGoToPreviousQuestion() {
            currentQuestionIndex -= 1
            currentQuestion = questions[currentQuestionIndex]
            questionStartTime = Date()
        }
    }
    
    // MARK: - Progress Tracking
    
    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(currentQuestionIndex) / Double(totalQuestions)
    }
    
    var currentQuestionNumber: Int {
        return currentQuestionIndex + 1
    }
    
    var answeredQuestions: Int {
        return userAnswers.count
    }
    
    // MARK: - Statistics
    
    var currentScore: Int {
        guard !questions.isEmpty else { return 0 }
        
        var correct = 0
        for question in questions {
            if let userAnswer = userAnswers[question.id] {
                if isAnswerCorrect(userAnswer: userAnswer, question: question) {
                    correct += 1
                }
            }
        }
        
        return Int((Double(correct) / Double(questions.count)) * 100)
    }
    
    var averageTimePerQuestion: TimeInterval {
        guard answeredQuestions > 0 else { return 0 }
        return totalQuizTime / Double(answeredQuestions)
    }
    
    // MARK: - State Management
    
    func resetQuizState() {
        isQuizCompleted = false
        currentResult = nil
        isQuizActive = false
        currentQuestion = nil
        currentQuestionIndex = 0
        userAnswers = [:]
        totalQuizTime = 0
        questionStartTime = nil
        quizStartTime = nil
        stopTimer()
    }
    
    // MARK: - Initialization
    
    init() {
        loadLeaderboardFromUserDefaults()
        loadStatsFromUserDefaults()
        // Reset quiz state on app launch
        resetQuizState()
    }
    
    deinit {
        timer?.invalidate()
    }
}

// MARK: - Seeded Random Number Generator (for Daily Challenge)

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    var state: UInt64
    
    init(seed: UInt64) {
        self.state = seed
    }
    
    mutating func next() -> UInt64 {
        state ^= state << 13
        state ^= state >> 7
        state ^= state << 17
        return state
    }
}

