import Foundation
import SwiftUI

@MainActor
class ProgressionGame: ObservableObject {
    // MARK: - Question State
    @Published var currentQuestion: ProgressionQuestion?
    @Published var currentQuestionIndex: Int = 0
    @Published var totalQuestions: Int = 10
    @Published var questions: [ProgressionQuestion] = []
    @Published var userAnswers: [UUID: [[Note]]] = [:]
    @Published var questionStartTime: Date?
    @Published var totalQuizTime: TimeInterval = 0
    @Published var isQuizActive: Bool = false
    @Published var isQuizCompleted: Bool = false
    @Published var currentResult: ProgressionResult?

    // MARK: - Quiz Configuration
    @Published var selectedCategory: ProgressionCategory = .turnaround
    @Published var selectedDifficulty: ProgressionDifficulty = .beginner
    @Published var selectedKeyDifficulty: KeyDifficulty = .all
    @Published var useMixedCategories: Bool = false
    @Published var selectedCategories: Set<ProgressionCategory> = [.turnaround]

    // MARK: - Rating & Motivation
    @Published var lastRatingChange: Int = 0
    @Published var didRankUp: Bool = false
    @Published var previousLevel: Int?

    // MARK: - Statistics
    @Published var lifetimeStats: ProgressionLifetimeStats = ProgressionLifetimeStats()
    @Published var scoreboard: [ProgressionResult] = []

    init() {
        loadScoreboardFromUserDefaults()
        loadLifetimeStats()
        resetQuizState()
    }

    // MARK: - Quiz Management
    func startNewQuiz(
        numberOfQuestions: Int,
        category: ProgressionCategory,
        difficulty: ProgressionDifficulty,
        keyDifficulty: KeyDifficulty,
        useMixedCategories: Bool = false,
        selectedCategories: Set<ProgressionCategory> = []
    ) {
        self.totalQuestions = numberOfQuestions
        self.selectedCategory = category
        self.selectedDifficulty = difficulty
        self.selectedKeyDifficulty = keyDifficulty
        self.useMixedCategories = useMixedCategories
        self.selectedCategories = selectedCategories

        generateQuestions()

        isQuizActive = true
        isQuizCompleted = false
        currentQuestionIndex = 0
        userAnswers = [:]
        totalQuizTime = 0
        questionStartTime = Date()
        
        // Set the first question
        if !questions.isEmpty {
            currentQuestion = questions[0]
        }
    }

    private func generateQuestions() {
        questions = []

        let possibleRoots = selectedKeyDifficulty.availableRoots
        let database = ProgressionDatabase.shared

        // Determine which categories to use
        let categoriesToUse: [ProgressionCategory]
        if useMixedCategories && !selectedCategories.isEmpty {
            categoriesToUse = Array(selectedCategories)
        } else {
            categoriesToUse = [selectedCategory]
        }

        // Get templates for selected categories and difficulty
        var availableTemplates: [ProgressionTemplate] = []
        for category in categoriesToUse {
            let categoryTemplates = database.templates(for: category)
                .filter { $0.difficulty == selectedDifficulty }
            availableTemplates.append(contentsOf: categoryTemplates)
        }

        guard !availableTemplates.isEmpty else { return }

        for _ in 0..<totalQuestions {
            // Pick random key and template
            let key = possibleRoots.randomElement() ?? Note(name: "C", midiNumber: 60, isSharp: false)
            let template = availableTemplates.randomElement()!

            // Generate progression
            let progression = ProgressionProgression(key: key, template: template)

            // Create question
            let question = ProgressionQuestion(
                progression: progression,
                drillMode: .fullProgression,
                timeLimit: 90.0  // More time for longer progressions
            )

            questions.append(question)
        }
    }

    func submitAnswer(_ chordSpellings: [[Note]]) {
        guard let question = currentQuestion else { return }

        // Record answer
        userAnswers[question.id] = chordSpellings

        // Record time
        if let startTime = questionStartTime {
            let questionTime = Date().timeIntervalSince(startTime)
            totalQuizTime += questionTime
        }

        // Move to next
        nextQuestion()
    }

    func nextQuestion() {
        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
            currentQuestion = questions[currentQuestionIndex]
            questionStartTime = Date()
        } else {
            finishQuiz()
        }
    }

    func isAnswerCorrect(userAnswer: [[Note]], question: ProgressionQuestion) -> Bool {
        let correctAnswers = question.expectedAnswers

        guard userAnswer.count == correctAnswers.count else { return false }

        for (userChord, correctChord) in zip(userAnswer, correctAnswers) {
            let userPitchClasses = Set(userChord.map { $0.pitchClass })
            let correctPitchClasses = Set(correctChord.map { $0.pitchClass })

            if userPitchClasses != correctPitchClasses {
                return false
            }
        }

        return true
    }

    private func finishQuiz() {
        isQuizActive = false

        // NOTE: isQuizCompleted is set at the END of this method
        // to ensure currentResult is populated before the view transitions

        // Calculate results
        var correctCount = 0
        var isCorrectMap: [UUID: Bool] = [:]

        for question in questions {
            if let userAnswer = userAnswers[question.id] {
                let correct = isAnswerCorrect(userAnswer: userAnswer, question: question)
                isCorrectMap[question.id] = correct
                if correct {
                    correctCount += 1
                }
            }
        }

        // Create result
        let result = ProgressionResult(
            date: Date(),
            totalQuestions: questions.count,
            correctAnswers: correctCount,
            totalTime: totalQuizTime,
            questions: questions,
            userAnswers: userAnswers,
            isCorrect: isCorrectMap,
            category: selectedCategory,
            difficulty: selectedDifficulty
        )

        currentResult = result
        saveToScoreboard(result)

        // Update statistics
        updateLifetimeStats(with: result)

        // Record spaced repetition results
        recordSpacedRepetitionResults(result)

        // Calculate rating change
        lastRatingChange = calculateRatingChange(correctAnswers: correctCount, totalQuestions: questions.count)
        updateRating(by: lastRatingChange)
        
        // Record curriculum progress if there's an active module
        Task { @MainActor in
            if let activeModuleID = CurriculumManager.shared.activeModuleID {
                let wasPerfectScore = correctCount == questions.count
                CurriculumManager.shared.recordModuleAttempt(
                    moduleID: activeModuleID,
                    questionsAnswered: questions.count,
                    correctAnswers: correctCount,
                    wasPerfectSession: wasPerfectScore
                )
                CurriculumManager.shared.setActiveModule(nil)
            }
        }
        
        // Set completion LAST to trigger view transition AFTER currentResult is ready
        isQuizCompleted = true
    }

    private func calculateRatingChange(correctAnswers: Int, totalQuestions: Int) -> Int {
        guard totalQuestions > 0 else { return 0 }

        let accuracy = Double(correctAnswers) / Double(totalQuestions)

        // Base points
        var basePoints = 0
        if accuracy >= 1.0 { basePoints = 35 }
        else if accuracy >= 0.9 { basePoints = 25 }
        else if accuracy >= 0.8 { basePoints = 18 }
        else if accuracy >= 0.7 { basePoints = 12 }
        else if accuracy >= 0.6 { basePoints = 8 }
        else if accuracy >= 0.5 { basePoints = 5 }
        else { basePoints = -5 }

        // Category multiplier
        let categoryMultiplier: Double
        switch selectedCategory {
        case .cadences: categoryMultiplier = 0.9
        case .turnaround: categoryMultiplier = 1.0
        case .rhythmChanges: categoryMultiplier = 1.3
        case .secondaryDominants: categoryMultiplier = 1.2
        case .minorKeyMovement: categoryMultiplier = 1.1
        case .standardFragment: categoryMultiplier = 1.4
        }

        // Difficulty multiplier
        let difficultyMultiplier: Double
        switch selectedDifficulty {
        case .beginner: difficultyMultiplier = 0.8
        case .intermediate: difficultyMultiplier = 1.0
        case .advanced: difficultyMultiplier = 1.3
        case .expert: difficultyMultiplier = 1.6
        }

        // Key difficulty multiplier
        let keyMultiplier: Double
        switch selectedKeyDifficulty {
        case .easy: keyMultiplier = 0.9
        case .medium: keyMultiplier = 1.0
        case .hard: keyMultiplier = 1.2
        case .expert: keyMultiplier = 1.5
        case .all: keyMultiplier = 1.1
        }

        // Question count bonus
        let questionBonus = Double(totalQuestions) / 10.0

        let points = Double(basePoints) * categoryMultiplier * difficultyMultiplier * keyMultiplier * questionBonus

        return Int(points.rounded())
    }

    private func updateRating(by change: Int) {
        lifetimeStats.currentRating += change
        if lifetimeStats.currentRating > lifetimeStats.peakRating {
            lifetimeStats.peakRating = lifetimeStats.currentRating
        }
        saveLifetimeStats()
    }

    private func updateLifetimeStats(with result: ProgressionResult) {
        lifetimeStats.totalQuestionsAnswered += result.totalQuestions
        lifetimeStats.totalCorrectAnswers += result.correctAnswers
        lifetimeStats.totalPracticeTime += result.totalTime

        // Update category stats
        if lifetimeStats.statsByCategory[result.category] == nil {
            lifetimeStats.statsByCategory[result.category] = ProgressionCategoryStats()
        }
        lifetimeStats.statsByCategory[result.category]!.questionsAnswered += result.totalQuestions
        lifetimeStats.statsByCategory[result.category]!.correctAnswers += result.correctAnswers

        saveLifetimeStats()
    }

    private func recordSpacedRepetitionResults(_ result: ProgressionResult) {
        let srStore = SpacedRepetitionStore.shared
        let avgTime = result.averageTimePerQuestion

        for question in result.questions {
            let itemID = SRItemID(
                mode: .progressionDrill,
                topic: question.progression.template.category.rawValue,
                key: question.progression.key.name,
                variant: question.progression.template.name
            )

            let wasCorrect = result.isCorrect[question.id] ?? false
            srStore.recordResult(itemID: itemID, wasCorrect: wasCorrect, responseTime: avgTime)
        }
    }

    // MARK: - Persistence
    private func saveToScoreboard(_ result: ProgressionResult) {
        scoreboard.insert(result, at: 0)
        if scoreboard.count > 100 {
            scoreboard = Array(scoreboard.prefix(100))
        }
        saveScoreboardToUserDefaults()
    }

    private func saveScoreboardToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(scoreboard) {
            UserDefaults.standard.set(encoded, forKey: "progressionScoreboard")
        }
    }

    private func loadScoreboardFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: "progressionScoreboard"),
           let decoded = try? JSONDecoder().decode([ProgressionResult].self, from: data) {
            scoreboard = decoded
        }
    }

    private func saveLifetimeStats() {
        if let encoded = try? JSONEncoder().encode(lifetimeStats) {
            UserDefaults.standard.set(encoded, forKey: "progressionLifetimeStats")
        }
    }

    private func loadLifetimeStats() {
        if let data = UserDefaults.standard.data(forKey: "progressionLifetimeStats"),
           let decoded = try? JSONDecoder().decode(ProgressionLifetimeStats.self, from: data) {
            lifetimeStats = decoded
        }
    }

    func resetQuizState() {
        isQuizActive = false
        isQuizCompleted = false
        currentQuestionIndex = 0
        questions = []
        userAnswers = [:]
        currentQuestion = nil
        currentResult = nil
        questionStartTime = nil
        totalQuizTime = 0
        lastRatingChange = 0
        didRankUp = false
        previousLevel = nil
    }
}

// MARK: - Supporting Models

struct ProgressionQuestion: Identifiable, Codable {
    let id: UUID
    let progression: ProgressionProgression
    let drillMode: ProgressionDrillMode
    let timeLimit: TimeInterval

    var correctAnswers: [[Note]] {
        progression.chords.map { $0.chordTones }
    }

    var expectedAnswers: [[Note]] {
        correctAnswers
    }

    var questionText: String {
        "Spell the \(progression.template.name) in \(progression.key.name)"
    }

    init(progression: ProgressionProgression, drillMode: ProgressionDrillMode = .fullProgression, timeLimit: TimeInterval = 90.0) {
        self.id = UUID()
        self.progression = progression
        self.drillMode = drillMode
        self.timeLimit = timeLimit
    }
}

enum ProgressionDrillMode: String, CaseIterable, Codable {
    case fullProgression = "Full Progression"

    var icon: String {
        switch self {
        case .fullProgression: return "music.note.list"
        }
    }
}

struct ProgressionResult: Identifiable, Codable {
    let id: UUID
    let date: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let totalTime: TimeInterval
    let questions: [ProgressionQuestion]
    let userAnswers: [UUID: [[Note]]]
    let isCorrect: [UUID: Bool]
    let category: ProgressionCategory
    let difficulty: ProgressionDifficulty

    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }

    var averageTimePerQuestion: TimeInterval {
        guard totalQuestions > 0 else { return 0 }
        return totalTime / Double(totalQuestions)
    }

    init(
        id: UUID = UUID(),
        date: Date,
        totalQuestions: Int,
        correctAnswers: Int,
        totalTime: TimeInterval,
        questions: [ProgressionQuestion],
        userAnswers: [UUID: [[Note]]],
        isCorrect: [UUID: Bool],
        category: ProgressionCategory,
        difficulty: ProgressionDifficulty
    ) {
        self.id = id
        self.date = date
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.totalTime = totalTime
        self.questions = questions
        self.userAnswers = userAnswers
        self.isCorrect = isCorrect
        self.category = category
        self.difficulty = difficulty
    }
}

struct ProgressionLifetimeStats: Codable {
    var totalQuestionsAnswered: Int = 0
    var totalCorrectAnswers: Int = 0
    var totalPracticeTime: TimeInterval = 0
    var currentRating: Int = 1000
    var peakRating: Int = 1000
    var statsByCategory: [ProgressionCategory: ProgressionCategoryStats] = [:]

    var overallAccuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0 }
        return Double(totalCorrectAnswers) / Double(totalQuestionsAnswered) * 100
    }
}

struct ProgressionCategoryStats: Codable {
    var questionsAnswered: Int = 0
    var correctAnswers: Int = 0

    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered) * 100
    }
}
