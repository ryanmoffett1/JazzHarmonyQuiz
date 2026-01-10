import Foundation
import SwiftUI

class CadenceGame: ObservableObject {
    @Published var currentQuestion: CadenceQuestion?
    @Published var currentQuestionIndex: Int = 0
    @Published var totalQuestions: Int = 10
    @Published var questions: [CadenceQuestion] = []
    @Published var userAnswers: [UUID: [[Note]]] = [:] // Question ID -> array of 3 chord spellings
    @Published var questionStartTime: Date?
    @Published var totalQuizTime: TimeInterval = 0
    @Published var isQuizActive: Bool = false
    @Published var isQuizCompleted: Bool = false
    @Published var currentResult: CadenceResult?
    @Published var selectedCadenceType: CadenceType = .major

    private var quizStartTime: Date?
    private var timer: Timer?

    // MARK: - Quiz Management

    func startNewQuiz(numberOfQuestions: Int, cadenceType: CadenceType) {
        totalQuestions = numberOfQuestions
        selectedCadenceType = cadenceType

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

        // All possible root notes for cadences (12 keys)
        let possibleRoots = [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "Db", midiNumber: 61, isSharp: false),
            Note(name: "D", midiNumber: 62, isSharp: false),
            Note(name: "Eb", midiNumber: 63, isSharp: false),
            Note(name: "E", midiNumber: 64, isSharp: false),
            Note(name: "F", midiNumber: 65, isSharp: false),
            Note(name: "F#", midiNumber: 66, isSharp: true),
            Note(name: "G", midiNumber: 67, isSharp: false),
            Note(name: "Ab", midiNumber: 68, isSharp: false),
            Note(name: "A", midiNumber: 69, isSharp: false),
            Note(name: "Bb", midiNumber: 70, isSharp: false),
            Note(name: "B", midiNumber: 71, isSharp: false)
        ]

        for _ in 0..<totalQuestions {
            // Pick a random key
            let key = possibleRoots.randomElement()!

            // Create cadence progression
            let cadence = CadenceProgression(key: key, cadenceType: selectedCadenceType)

            // Create question
            let question = CadenceQuestion(cadence: cadence)
            questions.append(question)
        }
    }

    func submitAnswer(_ chordSpellings: [[Note]]) {
        guard let question = currentQuestion else { return }

        // Record the answer
        userAnswers[question.id] = chordSpellings

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
            let userAnswer = userAnswers[question.id] ?? [[], [], []]
            let isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
            questionResults[question.id] = isCorrect

            if isCorrect {
                correctAnswers += 1
            }
        }

        currentResult = CadenceResult(
            date: Date(),
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            totalTime: totalQuizTime,
            questions: questions,
            userAnswers: userAnswers,
            isCorrect: questionResults,
            cadenceType: selectedCadenceType
        )

        // Save to leaderboard
        if let result = currentResult {
            saveToLeaderboard(result)
        }
    }

    func isAnswerCorrect(userAnswer: [[Note]], question: CadenceQuestion) -> Bool {
        let correctAnswers = question.correctAnswers

        // Helper function to normalize MIDI number to pitch class (0-11)
        func pitchClass(_ midiNumber: Int) -> Int {
            return ((midiNumber - 60) % 12 + 12) % 12
        }

        // Check all 3 chords
        guard userAnswer.count == 3, correctAnswers.count == 3 else { return false }

        for i in 0..<3 {
            let userChordNotes = userAnswer[i]
            let correctChordNotes = correctAnswers[i]

            // Convert to pitch class sets for comparison
            let userPitchClasses = Set(userChordNotes.map { pitchClass($0.midiNumber) })
            let correctPitchClasses = Set(correctChordNotes.map { pitchClass($0.midiNumber) })

            // If any chord is incorrect, the whole answer is wrong
            if userPitchClasses != correctPitchClasses {
                return false
            }
        }

        return true
    }

    // MARK: - Leaderboard Management

    @Published var leaderboard: [CadenceResult] = []

    private func saveToLeaderboard(_ result: CadenceResult) {
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
            UserDefaults.standard.set(encoded, forKey: "JazzHarmonyCadenceLeaderboard")
        }
    }

    func loadLeaderboardFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "JazzHarmonyCadenceLeaderboard"),
           let decoded = try? JSONDecoder().decode([CadenceResult].self, from: data) {
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
