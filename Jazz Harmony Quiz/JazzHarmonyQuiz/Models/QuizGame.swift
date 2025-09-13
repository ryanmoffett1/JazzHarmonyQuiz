import Foundation
import SwiftUI

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
    
    private let chordDatabase = JazzChordDatabase.shared
    private var quizStartTime: Date?
    private var timer: Timer?
    
    // MARK: - Quiz Management
    
    func startNewQuiz(numberOfQuestions: Int, difficulty: ChordType.ChordDifficulty, questionTypes: Set<QuestionType>) {
        totalQuestions = numberOfQuestions
        selectedDifficulty = difficulty
        selectedQuestionTypes = questionTypes
        
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
    }
    
    private func isAnswerCorrect(userAnswer: [Note], question: QuizQuestion) -> Bool {
        let correctAnswer = question.correctAnswer
        
        // For single tone questions, check if the user selected the correct note
        if question.questionType == .singleTone {
            guard userAnswer.count == 1, correctAnswer.count == 1 else { return false }
            // Compare MIDI numbers to handle enharmonic equivalents
            return userAnswer[0].midiNumber == correctAnswer[0].midiNumber
        }
        
        // For all tones and chord spelling, check if all correct notes are selected
        // and no incorrect notes are selected
        let userNotes = Set(userAnswer.map { $0.midiNumber })
        let correctNotes = Set(correctAnswer.map { $0.midiNumber })
        
        return userNotes == correctNotes
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
        // Reset quiz state on app launch
        resetQuizState()
    }
    
    deinit {
        stopTimer()
    }
}

