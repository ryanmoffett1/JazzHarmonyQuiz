import Foundation
import SwiftUI

/// Manages the Interval Drill quiz state and logic
@MainActor
class IntervalGame: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentQuestion: IntervalQuestion?
    @Published var questionNumber: Int = 0
    @Published var totalQuestions: Int = 10
    @Published var correctAnswers: Int = 0
    @Published var hasAnswered: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var isQuizActive: Bool = false
    @Published var showingResults: Bool = false
    @Published var leaderboard: [IntervalQuizResult] = []
    @Published var lastRatingChange: Int = 0
    @Published var previousRank: Rank?
    @Published var newRank: Rank?
    
    // MARK: - Quiz Configuration
    
    var selectedDifficulty: IntervalDifficulty = .beginner
    var selectedQuestionTypes: Set<IntervalQuestionType> = [.buildInterval]
    var selectedDirection: IntervalDirection = .ascending
    var selectedKeyDifficulty: KeyDifficulty = .natural
    
    // MARK: - Private Properties
    
    private var questions: [IntervalQuestion] = []
    private var answeredQuestions: [AnsweredIntervalQuestion] = []
    private var questionStartTime: Date?
    private var quizStartTime: Date?
    private var timer: Timer?
    private let database = IntervalDatabase.shared
    
    // MARK: - Persistence Keys
    
    private let leaderboardKey = "intervalLeaderboard"
    
    // MARK: - Initialization
    
    init() {
        loadLeaderboard()
    }
    
    // MARK: - Quiz Management
    
    func startQuiz(
        numberOfQuestions: Int,
        difficulty: IntervalDifficulty,
        questionTypes: Set<IntervalQuestionType>,
        direction: IntervalDirection,
        keyDifficulty: KeyDifficulty
    ) {
        self.totalQuestions = numberOfQuestions
        self.selectedDifficulty = difficulty
        self.selectedQuestionTypes = questionTypes
        self.selectedDirection = direction
        self.selectedKeyDifficulty = keyDifficulty
        
        // Store previous rank for comparison
        previousRank = PlayerStats.shared.currentRank
        newRank = nil
        
        // Generate questions
        questions = generateQuestions(count: numberOfQuestions)
        answeredQuestions = []
        
        // Reset state
        questionNumber = 0
        correctAnswers = 0
        hasAnswered = false
        lastAnswerCorrect = false
        elapsedTime = 0
        showingResults = false
        isQuizActive = true
        quizStartTime = Date()
        
        // Start timer
        startTimer()
        
        // Load first question
        nextQuestion()
    }
    
    private func generateQuestions(count: Int) -> [IntervalQuestion] {
        var generatedQuestions: [IntervalQuestion] = []
        let availableRoots = selectedKeyDifficulty.availableRoots
        let questionTypesArray = Array(selectedQuestionTypes)
        
        for _ in 0..<count {
            let root = availableRoots.randomElement() ?? Note.allNotes[0]
            let interval = database.getRandomInterval(
                difficulty: selectedDifficulty,
                rootNote: root,
                direction: selectedDirection
            )
            
            let questionType = questionTypesArray.randomElement() ?? .buildInterval
            
            let question = IntervalQuestion(
                interval: interval,
                questionType: questionType
            )
            generatedQuestions.append(question)
        }
        
        return generatedQuestions
    }
    
    func nextQuestion() {
        guard questionNumber < questions.count else {
            endQuiz()
            return
        }
        
        currentQuestion = questions[questionNumber]
        questionNumber += 1
        hasAnswered = false
        questionStartTime = Date()
    }
    
    // MARK: - Answer Checking
    
    /// Check answer for "Build Interval" questions (user selects a note)
    func checkAnswer(selectedNote: Note) -> Bool {
        guard let question = currentQuestion, !hasAnswered else { return false }
        
        hasAnswered = true
        let isCorrect = question.isCorrect(userAnswer: selectedNote)
        lastAnswerCorrect = isCorrect
        
        if isCorrect {
            correctAnswers += 1
        }
        
        // Record answered question
        let timeTaken = questionStartTime.map { Date().timeIntervalSince($0) } ?? 0
        let answered = AnsweredIntervalQuestion(
            question: question,
            userAnswer: selectedNote,
            userIntervalAnswer: nil,
            wasCorrect: isCorrect,
            timeTaken: timeTaken
        )
        answeredQuestions.append(answered)
        
        return isCorrect
    }
    
    /// Check answer for "Identify Interval" questions (user selects interval type)
    func checkAnswer(selectedInterval: IntervalType) -> Bool {
        guard let question = currentQuestion, !hasAnswered else { return false }
        
        hasAnswered = true
        let isCorrect = question.isCorrect(userAnswer: selectedInterval)
        lastAnswerCorrect = isCorrect
        
        if isCorrect {
            correctAnswers += 1
        }
        
        // Record answered question
        let timeTaken = questionStartTime.map { Date().timeIntervalSince($0) } ?? 0
        let answered = AnsweredIntervalQuestion(
            question: question,
            userAnswer: nil,
            userIntervalAnswer: selectedInterval,
            wasCorrect: isCorrect,
            timeTaken: timeTaken
        )
        answeredQuestions.append(answered)
        
        return isCorrect
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let startTime = self.quizStartTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - End Quiz
    
    func endQuiz() {
        stopTimer()
        isQuizActive = false
        showingResults = true
        
        // Calculate rating change
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        let ratingChange = PlayerStats.shared.calculateRatingChange(
            accuracy: accuracy,
            difficulty: difficultyMultiplier,
            questionCount: totalQuestions
        )
        
        // Update player stats
        PlayerStats.shared.updateRating(change: ratingChange)
        PlayerStats.shared.recordQuizCompletion(
            mode: "interval",
            questionsAnswered: totalQuestions,
            correctAnswers: correctAnswers,
            timeSpent: elapsedTime
        )
        
        lastRatingChange = ratingChange
        
        // Check for rank change
        let currentRank = PlayerStats.shared.currentRank
        if let previous = previousRank, currentRank != previous {
            newRank = currentRank
        }
        
        // Save result
        let result = IntervalQuizResult(
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            totalTime: elapsedTime,
            difficulty: selectedDifficulty,
            questionTypes: Array(selectedQuestionTypes),
            ratingChange: ratingChange
        )
        
        addToLeaderboard(result)
    }
    
    private var difficultyMultiplier: Double {
        switch selectedDifficulty {
        case .beginner: return 0.8
        case .intermediate: return 1.0
        case .advanced: return 1.3
        }
    }
    
    // MARK: - Leaderboard
    
    private func addToLeaderboard(_ result: IntervalQuizResult) {
        leaderboard.append(result)
        leaderboard.sort {
            $0.accuracy > $1.accuracy ||
            ($0.accuracy == $1.accuracy && $0.totalTime < $1.totalTime)
        }
        leaderboard = Array(leaderboard.prefix(10))
        saveLeaderboard()
    }
    
    // MARK: - Persistence
    
    private func loadLeaderboard() {
        if let data = UserDefaults.standard.data(forKey: leaderboardKey),
           let decoded = try? JSONDecoder().decode([IntervalQuizResult].self, from: data) {
            leaderboard = decoded
        }
    }
    
    private func saveLeaderboard() {
        if let encoded = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encoded, forKey: leaderboardKey)
        }
    }
    
    func resetQuiz() {
        stopTimer()
        currentQuestion = nil
        questionNumber = 0
        correctAnswers = 0
        hasAnswered = false
        lastAnswerCorrect = false
        elapsedTime = 0
        isQuizActive = false
        showingResults = false
        questions = []
        answeredQuestions = []
        previousRank = nil
        newRank = nil
    }
    
    // MARK: - Review Access
    
    func getAnsweredQuestions() -> [AnsweredIntervalQuestion] {
        answeredQuestions
    }
    
    func getMissedQuestions() -> [AnsweredIntervalQuestion] {
        answeredQuestions.filter { !$0.wasCorrect }
    }
}
