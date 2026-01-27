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
    @Published var scoreboard: [IntervalQuizResult] = []
    @Published var lastRatingChange: Int = 0
    @Published var previousLevel: Int?
    @Published var didRankUp: Bool = false
    
    // MARK: - Quiz Configuration
    
    var selectedDifficulty: IntervalDifficulty = .beginner
    var selectedQuestionTypes: Set<IntervalQuestionType> = [.buildInterval]
    var selectedDirection: IntervalDirection = .ascending
    var selectedKeyDifficulty: KeyDifficulty = .easy
    
    // MARK: - Private Properties
    
    private var questions: [IntervalQuestion] = []
    private var answeredQuestions: [AnsweredIntervalQuestion] = []
    private var questionStartTime: Date?
    private var quizStartTime: Date?
    private var timer: Timer?
    private let database = IntervalDatabase.shared
    
    // MARK: - Persistence Keys
    
    private let scoreboardKey = "intervalScoreboard"
    
    // MARK: - Initialization
    
    init() {
        loadScoreboard()
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
        
        // Store previous level for comparison
        previousLevel = PlayerLevel(xp: PlayerStats.shared.currentRating).level
        
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
        let ratingChange = calculateRatingChange(correctAnswers: correctAnswers, totalQuestions: totalQuestions)
        
        // Apply to shared player stats
        let wasPerfectScore = correctAnswers == totalQuestions
        let ratingResult = PlayerStats.shared.applyRatingChange(ratingChange)
        PlayerStats.shared.updateStreak()
        PlayerStats.shared.recordPractice(
            questionsAnswered: totalQuestions,
            correctAnswers: correctAnswers,
            time: elapsedTime,
            wasPerfectScore: wasPerfectScore
        )
        
        // Record to PlayerProfile for RPG stats
        PlayerProfile.shared.recordPractice(
            mode: .intervalDrill,
            questions: totalQuestions,
            correct: correctAnswers,
            time: elapsedTime
        )
        PlayerProfile.shared.addXP(ratingChange, from: .intervalDrill)
        
        // Record curriculum progress if there's an active module
        Task { @MainActor in
            if let activeModuleID = CurriculumManager.shared.activeModuleID {
                let wasPerfectScore = correctAnswers == totalQuestions
                CurriculumManager.shared.recordModuleAttempt(
                    moduleID: activeModuleID,
                    questionsAnswered: totalQuestions,
                    correctAnswers: correctAnswers,
                    wasPerfectSession: wasPerfectScore
                )
                CurriculumManager.shared.setActiveModule(nil)
            }
        }
        
        lastRatingChange = ratingChange
        didRankUp = ratingResult.didRankUp
        previousLevel = ratingResult.previousLevel
        
        // Save result
        let result = IntervalQuizResult(
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            totalTime: elapsedTime,
            difficulty: selectedDifficulty,
            questionTypes: Array(selectedQuestionTypes),
            ratingChange: ratingChange
        )
        
        addToScoreboard(result)
        
        // Spaced Repetition: Record results for each question
        recordSpacedRepetitionResults()
    }
    
    /// Calculate rating change based on performance
    private func calculateRatingChange(correctAnswers: Int, totalQuestions: Int) -> Int {
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        
        // Base points from accuracy
        var points: Double = 0
        
        if accuracy >= 1.0 {
            points = 30  // Perfect score bonus
        } else if accuracy >= 0.9 {
            points = 22
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
            difficultyMultiplier = 0.8
        case .intermediate:
            difficultyMultiplier = 1.0
        case .advanced:
            difficultyMultiplier = 1.3
        }
        
        // Question count bonus (more questions = more points)
        let questionMultiplier = 1.0 + (Double(totalQuestions - 5) * 0.02)
        
        return Int(points * difficultyMultiplier * questionMultiplier)
    }
    
    private var difficultyMultiplier: Double {
        switch selectedDifficulty {
        case .beginner: return 0.8
        case .intermediate: return 1.0
        case .advanced: return 1.3
        }
    }
    
    // MARK: - Scoreboard
    
    private func addToScoreboard(_ result: IntervalQuizResult) {
        scoreboard.append(result)
        scoreboard.sort {
            $0.accuracy > $1.accuracy ||
            ($0.accuracy == $1.accuracy && $0.totalTime < $1.totalTime)
        }
        scoreboard = Array(scoreboard.prefix(10))
        saveScoreboard()
    }
    
    // MARK: - Persistence
    
    private func loadScoreboard() {
        if let data = UserDefaults.standard.data(forKey: scoreboardKey),
           let decoded = try? JSONDecoder().decode([IntervalQuizResult].self, from: data) {
            scoreboard = decoded
        }
    }
    
    // MARK: - Spaced Repetition Integration
    
    /// Record spaced repetition results for answered questions
    private func recordSpacedRepetitionResults() {
        let srStore = SpacedRepetitionStore.shared
        let avgTimePerQuestion = elapsedTime / Double(totalQuestions)
        
        for answeredQ in answeredQuestions {
            // Determine variant based on question type
            let variant: String
            switch answeredQ.question.questionType {
            case .identifyInterval:
                variant = "identify"
            case .buildInterval:
                variant = "build"
            case .auralIdentify:
                variant = "ear"
            }
            
            let itemID = SRItemID(
                mode: .intervalDrill,
                topic: answeredQ.question.interval.intervalType.shortName,
                key: answeredQ.question.interval.rootNote.name,
                variant: variant
            )
            
            // Record result
            srStore.recordResult(
                itemID: itemID,
                wasCorrect: answeredQ.wasCorrect,
                responseTime: avgTimePerQuestion
            )
        }
    }
    
    private func saveScoreboard() {
        if let encoded = try? JSONEncoder().encode(scoreboard) {
            UserDefaults.standard.set(encoded, forKey: scoreboardKey)
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
        previousLevel = nil
    }
    
    // MARK: - Review Access
    
    func getAnsweredQuestions() -> [AnsweredIntervalQuestion] {
        answeredQuestions
    }
    
    func getMissedQuestions() -> [AnsweredIntervalQuestion] {
        answeredQuestions.filter { !$0.wasCorrect }
    }
}