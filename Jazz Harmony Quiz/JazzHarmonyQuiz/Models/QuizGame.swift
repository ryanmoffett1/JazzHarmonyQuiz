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
    var perfectScoreStreak: Int = 0  // Track consecutive perfect scores
    
    // Achievements
    var unlockedAchievements: [Achievement] = []
    var newlyUnlockedAchievements: [Achievement] = []  // For showing celebration
    
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
    
    func hasAchievement(_ type: AchievementType) -> Bool {
        return unlockedAchievements.contains { $0.type == type }
    }
    
    mutating func unlockAchievement(_ type: AchievementType) {
        guard !hasAchievement(type) else { return }
        let achievement = Achievement(type: type, unlockedDate: Date())
        unlockedAchievements.append(achievement)
        newlyUnlockedAchievements.append(achievement)
    }
    
    mutating func clearNewAchievements() {
        newlyUnlockedAchievements.removeAll()
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
    
    /// Check and unlock any newly earned achievements
    mutating func checkAchievements(wasPerfectScore: Bool) {
        // First quiz
        if practiceLog.count == 1 {
            unlockAchievement(.firstQuiz)
        }
        
        // Chord milestones
        if totalChordsAnswered >= 100 { unlockAchievement(.hundredChords) }
        if totalChordsAnswered >= 500 { unlockAchievement(.fiveHundredChords) }
        if totalChordsAnswered >= 1000 { unlockAchievement(.thousandChords) }
        
        // Perfect score tracking
        if wasPerfectScore {
            perfectScoreStreak += 1
            if !hasAchievement(.firstPerfect) { unlockAchievement(.firstPerfect) }
            if perfectScoreStreak >= 3 { unlockAchievement(.perfectStreak3) }
            if perfectScoreStreak >= 5 { unlockAchievement(.perfectStreak5) }
        } else {
            perfectScoreStreak = 0
        }
        
        // Accuracy achievement
        if totalChordsAnswered >= 50 && overallAccuracy >= 0.9 {
            unlockAchievement(.accuracy90)
        }
        
        // Streak achievements
        if currentStreak >= 3 { unlockAchievement(.streak3) }
        if currentStreak >= 7 { unlockAchievement(.streak7) }
        if currentStreak >= 14 { unlockAchievement(.streak14) }
        if currentStreak >= 30 { unlockAchievement(.streak30) }
        
        // Rank achievements
        if currentRating >= 1001 { unlockAchievement(.rankGigging) }
        if currentRating >= 1501 { unlockAchievement(.rankBebop) }
        if currentRating >= 2001 { unlockAchievement(.rankWizard) }
        if currentRating >= 2751 { unlockAchievement(.rankMaster) }
        
        // Mastery achievements
        let triadSymbols = ["", "m"]
        let triadStats = triadSymbols.compactMap { statsByChordSymbol[$0] }
        let totalTriadAttempts = triadStats.reduce(0) { $0 + $1.questionsAnswered }
        let totalTriadCorrect = triadStats.reduce(0) { $0 + $1.correctAnswers }
        if totalTriadAttempts >= 50 && Double(totalTriadCorrect) / Double(totalTriadAttempts) >= 0.95 {
            unlockAchievement(.masterTriads)
        }
        
        let seventhSymbols = ["7", "maj7", "m7", "m7b5", "dim7"]
        let seventhStats = seventhSymbols.compactMap { statsByChordSymbol[$0] }
        let totalSeventhAttempts = seventhStats.reduce(0) { $0 + $1.questionsAnswered }
        let totalSeventhCorrect = seventhStats.reduce(0) { $0 + $1.correctAnswers }
        if totalSeventhAttempts >= 50 && Double(totalSeventhCorrect) / Double(totalSeventhAttempts) >= 0.95 {
            unlockAchievement(.masterSevenths)
        }
        
        // All keys played
        let allKeys = ["C", "Db", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
        let playedKeys = statsByKey.keys
        if allKeys.allSatisfy({ key in playedKeys.contains(key) || playedKeys.contains(enharmonicKey(key)) }) {
            unlockAchievement(.allKeysPlayed)
        }
    }
    
    private func enharmonicKey(_ key: String) -> String {
        switch key {
        case "Db": return "C#"
        case "C#": return "Db"
        case "Eb": return "D#"
        case "D#": return "Eb"
        case "F#": return "Gb"
        case "Gb": return "F#"
        case "Ab": return "G#"
        case "G#": return "Ab"
        case "Bb": return "A#"
        case "A#": return "Bb"
        default: return key
        }
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

// MARK: - Achievement System

enum AchievementType: String, CaseIterable, Codable {
    // Practice milestones
    case firstQuiz = "first_quiz"
    case hundredChords = "hundred_chords"
    case fiveHundredChords = "five_hundred_chords"
    case thousandChords = "thousand_chords"
    
    // Accuracy achievements
    case firstPerfect = "first_perfect"
    case perfectStreak3 = "perfect_streak_3"
    case perfectStreak5 = "perfect_streak_5"
    case accuracy90 = "accuracy_90"
    
    // Streak achievements
    case streak3 = "streak_3"
    case streak7 = "streak_7"
    case streak14 = "streak_14"
    case streak30 = "streak_30"
    
    // Rank achievements
    case rankGigging = "rank_gigging"
    case rankBebop = "rank_bebop"
    case rankWizard = "rank_wizard"
    case rankMaster = "rank_master"
    
    // Mastery
    case masterTriads = "master_triads"
    case masterSevenths = "master_sevenths"
    case allKeysPlayed = "all_keys_played"
    
    var title: String {
        switch self {
        case .firstQuiz: return "First Steps"
        case .hundredChords: return "Getting Started"
        case .fiveHundredChords: return "Dedicated Student"
        case .thousandChords: return "Chord Connoisseur"
        case .firstPerfect: return "Perfect Score!"
        case .perfectStreak3: return "Hat Trick"
        case .perfectStreak5: return "On Fire"
        case .accuracy90: return "Sharp Ears"
        case .streak3: return "Three-Peat"
        case .streak7: return "Week Warrior"
        case .streak14: return "Fortnight Fighter"
        case .streak30: return "Monthly Master"
        case .rankGigging: return "Ready to Gig"
        case .rankBebop: return "Bebop Scholar"
        case .rankWizard: return "Chord Wizard"
        case .rankMaster: return "Harmony Master"
        case .masterTriads: return "Triad Tamer"
        case .masterSevenths: return "Seventh Heaven"
        case .allKeysPlayed: return "Key Explorer"
        }
    }
    
    var description: String {
        switch self {
        case .firstQuiz: return "Complete your first quiz"
        case .hundredChords: return "Answer 100 chord questions"
        case .fiveHundredChords: return "Answer 500 chord questions"
        case .thousandChords: return "Answer 1,000 chord questions"
        case .firstPerfect: return "Get a perfect score on any quiz"
        case .perfectStreak3: return "Get 3 perfect scores in a row"
        case .perfectStreak5: return "Get 5 perfect scores in a row"
        case .accuracy90: return "Maintain 90%+ overall accuracy"
        case .streak3: return "Practice 3 days in a row"
        case .streak7: return "Practice 7 days in a row"
        case .streak14: return "Practice 14 days in a row"
        case .streak30: return "Practice 30 days in a row"
        case .rankGigging: return "Reach Gigging Musician rank"
        case .rankBebop: return "Reach Bebop Scholar rank"
        case .rankWizard: return "Reach Chord Wizard rank"
        case .rankMaster: return "Reach Harmony Master rank"
        case .masterTriads: return "Get 95%+ accuracy on triads (50+ attempts)"
        case .masterSevenths: return "Get 95%+ accuracy on 7th chords (50+ attempts)"
        case .allKeysPlayed: return "Practice chords in all 12 keys"
        }
    }
    
    var emoji: String {
        switch self {
        case .firstQuiz: return "🎵"
        case .hundredChords: return "💯"
        case .fiveHundredChords: return "📚"
        case .thousandChords: return "🏆"
        case .firstPerfect: return "⭐"
        case .perfectStreak3: return "🎩"
        case .perfectStreak5: return "🔥"
        case .accuracy90: return "🎯"
        case .streak3: return "3️⃣"
        case .streak7: return "📅"
        case .streak14: return "💪"
        case .streak30: return "🌟"
        case .rankGigging: return "🎷"
        case .rankBebop: return "📚"
        case .rankWizard: return "🧙"
        case .rankMaster: return "👑"
        case .masterTriads: return "🔺"
        case .masterSevenths: return "7️⃣"
        case .allKeysPlayed: return "🗝️"
        }
    }
}

struct Achievement: Codable, Identifiable, Equatable {
    let type: AchievementType
    let unlockedDate: Date
    
    var id: String { type.rawValue }
    var title: String { type.title }
    var description: String { type.description }
    var emoji: String { type.emoji }
}

// MARK: - Quiz Game

class QuizGame: ObservableObject {
    @Published var currentQuestion: QuizQuestion?
    @Published var currentQuestionIndex: Int = 0
    @Published var totalQuestions: Int = 10
    @Published var questions: [QuizQuestion] = []
    @Published var userAnswers: [UUID: [Note]] = [:]
    @Published var userChordTypeAnswers: [UUID: ChordType] = [:]  // For aural quality questions
    @Published var questionStartTime: Date?
    @Published var totalQuizTime: TimeInterval = 0
    @Published var isQuizActive: Bool = false
    @Published var isQuizCompleted: Bool = false
    @Published var currentResult: QuizResult?
    @Published var selectedDifficulty: ChordType.ChordDifficulty = .beginner
    @Published var selectedQuestionTypes: Set<QuestionType> = [.singleTone, .allTones]
    
    // MARK: - Stats & Rating (uses shared PlayerStats for unified rating)
    @Published var stats: ChordDrillStats = ChordDrillStats()  // Mode-specific stats
    @Published var lastRatingChange: Int = 0
    @Published var didRankUp: Bool = false
    @Published var previousRank: Rank?
    
    // Shared player stats (rating, streaks, achievements)
    var playerStats: PlayerStats { PlayerStats.shared }
    
    // MARK: - Filtering Options
    @Published var selectedRoots: Set<Note> = []  // Empty means all roots
    @Published var selectedChordSymbols: Set<String> = []  // Empty means all chord types
    @Published var selectedKeyDifficulty: KeyDifficulty = .all  // Key difficulty tier
    
    private let chordDatabase = JazzChordDatabase.shared
    private var quizStartTime: Date?
    private var timer: Timer?
    
    // MARK: - Answer Choices (for ear training)
    @Published var currentAnswerChoices: [ChordType] = []
    
    // MARK: - UserDefaults Keys
    private let statsKey = "JazzHarmonyChordDrillStats"
    
    // MARK: - Quiz Management
    
    func startNewQuiz(numberOfQuestions: Int, difficulty: ChordType.ChordDifficulty, questionTypes: Set<QuestionType>) {
        totalQuestions = numberOfQuestions
        selectedDifficulty = difficulty
        selectedQuestionTypes = questionTypes
        
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
    
    private func generateQuestions() {
        questions = []
        
        for _ in 0..<totalQuestions {
            // Determine which roots to use based on key difficulty or explicit selection
            let rootNames: Set<String>?
            if !selectedRoots.isEmpty {
                rootNames = Set(selectedRoots.map { $0.name })
            } else if selectedKeyDifficulty != .all {
                rootNames = Set(selectedKeyDifficulty.availableRoots.map { $0.name })
            } else {
                rootNames = nil
            }
            
            // Use filtered chord selection
            let symbols = selectedChordSymbols.isEmpty ? nil : selectedChordSymbols
            let chord = chordDatabase.getRandomFilteredChord(
                difficulty: selectedDifficulty,
                chordSymbols: symbols,
                rootNames: rootNames
            )
            
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
                
            case .auralQuality:
                question = QuizQuestion(chord: chord, questionType: .auralQuality)
                
            case .auralSpelling:
                question = QuizQuestion(chord: chord, questionType: .auralSpelling)
            }
            
            questions.append(question)
        }
        
        // Generate answer choices for first question if aural quality question
        if let firstQuestion = questions.first,
           firstQuestion.questionType == .auralQuality {
            currentAnswerChoices = generateAnswerChoices(for: firstQuestion.chord.chordType)
        }
    }
    
    /// Generate answer choices for ear training (chord quality recognition)
    func generateAnswerChoices(for correctChord: ChordType) -> [ChordType] {
        // Get all chord types for current difficulty
        var pool = chordDatabase.chordTypes.filter { $0.difficulty == selectedDifficulty }
        
        // If not enough for variety, include adjacent difficulties
        if pool.count < 6 {
            if selectedDifficulty == .intermediate {
                pool += chordDatabase.chordTypes.filter { $0.difficulty == .beginner || $0.difficulty == .advanced }
            } else if selectedDifficulty == .beginner {
                pool += chordDatabase.chordTypes.filter { $0.difficulty == .intermediate }
            } else if selectedDifficulty == .advanced {
                pool += chordDatabase.chordTypes.filter { $0.difficulty == .intermediate }
            }
        }
        
        // Remove the correct answer from pool
        pool = pool.filter { $0.id != correctChord.id }
        
        // Calculate similarity scores for each chord type
        let scoredChoices = pool.map { chordType -> (ChordType, Int) in
            let similarity = calculateChordSimilarity(correctChord, chordType)
            return (chordType, similarity)
        }
        
        // Sort by similarity (most similar first) and take top 3
        let distractors = scoredChoices
            .sorted { $0.1 > $1.1 }
            .prefix(3)
            .map { $0.0 }
        
        // Combine correct answer with distractors and shuffle
        var choices = Array(distractors) + [correctChord]
        choices.shuffle()
        
        return choices
    }
    
    /// Calculate similarity between two chord types (higher = more similar)
    private func calculateChordSimilarity(_ chord1: ChordType, _ chord2: ChordType) -> Int {
        var score = 0
        
        // Same number of tones = more similar
        if chord1.chordTones.count == chord2.chordTones.count {
            score += 3
        }
        
        // Check for common chord tones
        let tones1 = Set(chord1.chordTones.map { $0.semitonesFromRoot })
        let tones2 = Set(chord2.chordTones.map { $0.semitonesFromRoot })
        let commonTones = tones1.intersection(tones2).count
        score += commonTones * 2
        
        // Major vs minor quality (both have natural 3rd or both have b3)
        let has3rd1 = chord1.chordTones.contains { $0.semitonesFromRoot == 4 }
        let has3rd2 = chord2.chordTones.contains { $0.semitonesFromRoot == 4 }
        let hasb3_1 = chord1.chordTones.contains { $0.semitonesFromRoot == 3 }
        let hasb3_2 = chord2.chordTones.contains { $0.semitonesFromRoot == 3 }
        if (has3rd1 && has3rd2) || (hasb3_1 && hasb3_2) {
            score += 4
        }
        
        // Dominant vs non-dominant (b7 presence)
        let hasb7_1 = chord1.chordTones.contains { $0.semitonesFromRoot == 10 }
        let hasb7_2 = chord2.chordTones.contains { $0.semitonesFromRoot == 10 }
        if hasb7_1 == hasb7_2 {
            score += 2
        }
        
        return score
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
    
    /// Submit chord type answer for aural quality questions
    func submitChordTypeAnswer(_ chordType: ChordType) {
        guard let question = currentQuestion else { return }
        
        // Record the chord type answer
        userChordTypeAnswers[question.id] = chordType
        
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
            
            // Generate answer choices for aural quality questions
            if let question = currentQuestion,
               question.questionType == .auralQuality {
                currentAnswerChoices = generateAnswerChoices(for: question.chord.chordType)
            }
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
            let isCorrect: Bool
            
            // Check based on question type
            if question.questionType == .auralQuality {
                // For aural quality, check chord type answer
                if let userChordType = userChordTypeAnswers[question.id] {
                    isCorrect = userChordType.id == question.chord.chordType.id
                } else {
                    isCorrect = false
                }
            } else {
                // For note-based questions, check notes
                let userAnswer = userAnswers[question.id] ?? []
                isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
            }
            
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
        
        // Save to scoreboard
        if let result = currentResult {
            saveToScoreboard(result)
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
            ratingBefore: playerStats.currentRating,
            ratingAfter: playerStats.currentRating + ratingChange
        )
        
        // Update mode-specific stats
        stats.recordSession(session)
        
        // Update shared player stats (rating, streak, achievements)
        let wasPerfectScore = correctAnswers == totalQuestions
        let ratingResult = playerStats.applyRatingChange(ratingChange)
        playerStats.updateStreak()
        playerStats.recordPractice(
            questionsAnswered: totalQuestions,
            correctAnswers: correctAnswers,
            time: totalQuizTime,
            wasPerfectScore: wasPerfectScore
        )
        
        // Record to PlayerProfile for RPG stats
        PlayerProfile.shared.recordPractice(
            mode: .chordDrill,
            questions: totalQuestions,
            correct: correctAnswers,
            time: totalQuizTime
        )
        PlayerProfile.shared.addXP(ratingChange, from: .chordDrill)
        
        // Record curriculum progress if there's an active module
        Task { @MainActor in
            if let activeModuleID = CurriculumManager.shared.activeModuleID {
                CurriculumManager.shared.recordModuleAttempt(
                    moduleID: activeModuleID,
                    questionsAnswered: totalQuestions,
                    correctAnswers: correctAnswers,
                    wasPerfectSession: wasPerfectScore
                )
                // Clear active module after recording
                CurriculumManager.shared.setActiveModule(nil)
            }
        }
        
        // Update per-chord and per-key stats (mode-specific)
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
        
        // Check for rank up (using shared stats)
        didRankUp = ratingResult.didRankUp
        previousRank = ratingResult.previousRank
        
        // Save mode-specific stats
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
        
        let finalPoints = points * difficultyMultiplier * questionBonus * speedBonus
        
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
    
    // MARK: - Scoreboard Management
    
    @Published var scoreboard: [QuizResult] = []
    
    private func saveToScoreboard(_ result: QuizResult) {
        scoreboard.append(result)
        scoreboard.sort { first, second in
            // Sort by accuracy first, then by time
            if first.accuracy != second.accuracy {
                return first.accuracy > second.accuracy
            }
            return first.totalTime < second.totalTime
        }
        
        // Keep only top 10
        if scoreboard.count > 10 {
            scoreboard = Array(scoreboard.prefix(10))
        }
        
        // Save to UserDefaults
        saveScoreboardToUserDefaults()
    }
    
    func saveScoreboardToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(scoreboard) {
            UserDefaults.standard.set(encoded, forKey: "JazzHarmonyScoreboard")
        }
    }
    
    func loadScoreboardFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "JazzHarmonyScoreboard"),
           let decoded = try? JSONDecoder().decode([QuizResult].self, from: data) {
            scoreboard = decoded
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
    
    // MARK: - Spaced Repetition Integration
    
    /// Record spaced repetition results for all questions in the quiz
    private func recordSpacedRepetitionResults() {
        let srStore = SpacedRepetitionStore.shared
        
        print("🔄 SR: Recording \(questions.count) chord drill questions")
        
        for question in questions {
            let userAnswer = userAnswers[question.id] ?? []
            let wasCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
            
            // Calculate time spent on this question (estimate based on total quiz time)
            let avgTimePerQuestion = totalQuizTime / Double(totalQuestions)
            
            // Create SR item ID for the chord
            let chord = question.chord
            let questionType = question.questionType
            
            // Determine variant based on question type
            let variant: String
            switch questionType {
            case .singleTone:
                // For single tone questions, include the specific tone being asked
                if let tone = question.targetTone {
                    variant = "single-\(tone.name)"
                } else {
                    variant = "single"
                }
            case .allTones:
                variant = "all-tones"
            case .auralQuality:
                variant = "ear-training"
            case .auralSpelling:
                variant = "ear-spelling"
            }
            
            let itemID = SRItemID(
                mode: .chordDrill,
                topic: chord.chordType.symbol,
                key: chord.root.name,
                variant: variant
            )
            
            print("  📝 SR Item: \(itemID.displayName) - \(wasCorrect ? "✅" : "❌")")
            
            // Record result
            srStore.recordResult(
                itemID: itemID,
                wasCorrect: wasCorrect,
                responseTime: avgTimePerQuestion
            )
        }
        
        let stats = srStore.statistics()
        print("✅ SR: Total items tracked: \(stats.totalItems), Due: \(srStore.totalDueCount())")
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
        loadScoreboardFromUserDefaults()
        loadStatsFromUserDefaults()
        // Reset quiz state on app launch
        resetQuizState()
    }
    
    deinit {
        timer?.invalidate()
    }
}

