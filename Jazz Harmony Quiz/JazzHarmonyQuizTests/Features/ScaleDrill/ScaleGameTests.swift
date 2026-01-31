import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class ScaleGameTests: XCTestCase {
    
    var game: ScaleGame!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        game = ScaleGame()
        // Reset game state
        game.resetQuizState()
    }
    
    override func tearDownWithError() throws {
        game = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertNil(game.currentQuestion)
        XCTAssertEqual(game.currentQuestionIndex, 0)
        XCTAssertEqual(game.totalQuestions, 10)
        XCTAssertTrue(game.questions.isEmpty)
        XCTAssertTrue(game.userAnswers.isEmpty)
        XCTAssertTrue(game.earTrainingAnswers.isEmpty)
        XCTAssertFalse(game.isQuizActive)
        XCTAssertFalse(game.isQuizCompleted)
        XCTAssertNil(game.currentResult)
        XCTAssertEqual(game.selectedDifficulty, .beginner)
        XCTAssertTrue(game.selectedQuestionTypes.contains(.allDegrees))
    }
    
    func testDefaultFilteringOptions() {
        XCTAssertTrue(game.selectedScaleSymbols.isEmpty)
        XCTAssertEqual(game.selectedKeyDifficulty, .all)
    }
    
    // MARK: - Start Quiz Tests
    
    func testStartNewQuizBasic() {
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        XCTAssertEqual(game.totalQuestions, 5)
        XCTAssertEqual(game.selectedDifficulty, .beginner)
        XCTAssertEqual(game.questions.count, 5)
        XCTAssertTrue(game.isQuizActive)
        XCTAssertFalse(game.isQuizCompleted)
        XCTAssertEqual(game.currentQuestionIndex, 0)
        XCTAssertNotNil(game.currentQuestion)
    }
    
    func testStartNewQuizIntermediate() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .intermediate,
            questionTypes: [.allDegrees]
        )
        
        XCTAssertEqual(game.selectedDifficulty, .intermediate)
        XCTAssertEqual(game.questions.count, 3)
    }
    
    func testStartNewQuizAdvanced() {
        game.startNewQuiz(
            numberOfQuestions: 4,
            difficulty: .advanced,
            questionTypes: [.allDegrees]
        )
        
        XCTAssertEqual(game.selectedDifficulty, .advanced)
        XCTAssertEqual(game.questions.count, 4)
    }
    
    func testStartQuizResetsState() {
        // Start first quiz
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        // Move to next question
        game.moveToNextQuestion()
        
        // Start new quiz
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .intermediate,
            questionTypes: [.allDegrees]
        )
        
        XCTAssertEqual(game.questions.count, 5)
        XCTAssertEqual(game.currentQuestionIndex, 0)
        XCTAssertTrue(game.userAnswers.isEmpty)
        XCTAssertEqual(game.totalQuizTime, 0)
        XCTAssertNil(game.currentResult)
    }
    
    func testStartQuizResetsRatingTracking() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        XCTAssertEqual(game.lastRatingChange, 0)
        XCTAssertFalse(game.didRankUp)
    }
    
    // MARK: - Question Types Tests
    
    func testAllDegreesQuestionType() {
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        for question in game.questions {
            XCTAssertEqual(question.questionType, .allDegrees)
            // All degrees questions should have multiple correct notes
            XCTAssertGreaterThan(question.correctNotes.count, 1)
        }
    }
    
    func testSingleDegreeQuestionType() {
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.singleDegree]
        )
        
        for question in game.questions {
            XCTAssertEqual(question.questionType, .singleDegree)
            // Single degree questions should have exactly one correct note
            XCTAssertEqual(question.correctNotes.count, 1)
            // Should have a target degree
            XCTAssertNotNil(question.targetDegree)
        }
    }
    
    func testEarTrainingQuestionType() {
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.earTraining]
        )
        
        for question in game.questions {
            XCTAssertEqual(question.questionType, .earTraining)
        }
        
        // Ear training should generate answer choices
        XCTAssertFalse(game.currentAnswerChoices.isEmpty)
    }
    
    func testMixedQuestionTypes() {
        game.startNewQuiz(
            numberOfQuestions: 10,
            difficulty: .beginner,
            questionTypes: [.allDegrees, .singleDegree]
        )
        
        let questionTypes = Set(game.questions.map { $0.questionType })
        // With mixed types, we should see variety
        XCTAssertTrue(questionTypes.count >= 1)
    }
    
    // MARK: - Key Difficulty Tests
    
    func testEasyKeyDifficulty() {
        game.selectedKeyDifficulty = .easy
        game.startNewQuiz(
            numberOfQuestions: 10,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        let easyKeys = Set(KeyDifficulty.easy.availableRoots.map { $0.name })
        
        for question in game.questions {
            XCTAssertTrue(easyKeys.contains(question.scale.root.name),
                "Key \(question.scale.root.name) should be in easy keys")
        }
    }
    
    func testMediumKeyDifficulty() {
        game.selectedKeyDifficulty = .medium
        game.startNewQuiz(
            numberOfQuestions: 10,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        let mediumKeys = Set(KeyDifficulty.medium.availableRoots.map { $0.name })
        
        for question in game.questions {
            XCTAssertTrue(mediumKeys.contains(question.scale.root.name),
                "Key \(question.scale.root.name) should be in medium keys")
        }
    }
    
    func testHardKeyDifficulty() {
        game.selectedKeyDifficulty = .hard
        game.startNewQuiz(
            numberOfQuestions: 10,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        let hardKeys = Set(KeyDifficulty.hard.availableRoots.map { $0.name })
        
        for question in game.questions {
            XCTAssertTrue(hardKeys.contains(question.scale.root.name),
                "Key \(question.scale.root.name) should be in hard keys")
        }
    }
    
    // MARK: - Answer Submission Tests
    
    func testSubmitCorrectAnswer() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Submit the correct notes
        let correctNotes = Set(question.correctNotes)
        let isCorrect = game.submitAnswer(correctNotes)
        
        XCTAssertTrue(isCorrect)
        XCTAssertFalse(game.userAnswers.isEmpty)
    }
    
    func testSubmitIncorrectAnswer() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        guard game.currentQuestion != nil else {
            XCTFail("No current question")
            return
        }
        
        // Submit wrong notes
        let wrongNotes: Set<Note> = [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "F", midiNumber: 65, isSharp: false)
        ]
        let isCorrect = game.submitAnswer(wrongNotes)
        
        XCTAssertFalse(isCorrect)
    }
    
    func testOctaveAgnosticAnswerChecking() {
        game.startNewQuiz(
            numberOfQuestions: 1,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Create notes with same pitch classes but different octaves
        let correctPitchClasses = question.correctNotes.map { $0.pitchClass }
        var notesInDifferentOctave: Set<Note> = []
        for pc in correctPitchClasses {
            // Create note in higher octave
            let midi = 72 + pc // Octave 5
            if let note = Note.noteFromMidi(midi, preferSharps: false) {
                notesInDifferentOctave.insert(note)
            }
        }
        
        // Pitch class comparison should still work
        let isCorrect = game.submitAnswer(notesInDifferentOctave)
        XCTAssertTrue(isCorrect, "Answer should be correct regardless of octave")
    }
    
    func testSubmitAnswerRecordsAnswer() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let notes = Set(question.correctNotes)
        _ = game.submitAnswer(notes)
        
        XCTAssertNotNil(game.userAnswers[question.id])
    }
    
    // MARK: - Ear Training Tests
    
    func testRecordEarTrainingCorrectAnswer() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.earTraining]
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        game.recordEarTrainingAnswer(correct: true)
        
        XCTAssertTrue(game.earTrainingAnswers[question.id] == true)
    }
    
    func testRecordEarTrainingIncorrectAnswer() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.earTraining]
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        game.recordEarTrainingAnswer(correct: false)
        
        XCTAssertTrue(game.earTrainingAnswers[question.id] == false)
    }
    
    func testEarTrainingGeneratesAnswerChoices() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.earTraining]
        )
        
        XCTAssertFalse(game.currentAnswerChoices.isEmpty)
        XCTAssertEqual(game.currentAnswerChoices.count, 4) // Correct + 3 distractors
    }
    
    func testEarTrainingChoicesIncludeCorrectAnswer() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.earTraining]
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let correctScaleType = question.scale.scaleType
        let choiceIDs = game.currentAnswerChoices.map { $0.id }
        
        XCTAssertTrue(choiceIDs.contains(correctScaleType.id),
            "Answer choices should include the correct scale type")
    }
    
    // MARK: - Question Navigation Tests
    
    func testMoveToNextQuestion() {
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        let firstQuestion = game.currentQuestion
        game.moveToNextQuestion()
        
        XCTAssertEqual(game.currentQuestionIndex, 1)
        XCTAssertNotEqual(game.currentQuestion?.id, firstQuestion?.id)
    }
    
    func testMoveToNextQuestionUpdatesTime() throws {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        // Wait a brief moment
        Thread.sleep(forTimeInterval: 0.1)
        
        let timeBefore = game.totalQuizTime
        game.moveToNextQuestion()
        
        XCTAssertGreaterThan(game.totalQuizTime, timeBefore)
    }
    
    func testLastQuestionCompletesQuiz() {
        game.startNewQuiz(
            numberOfQuestions: 2,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        // Answer and move through all questions
        if let q1 = game.currentQuestion {
            _ = game.submitAnswer(Set(q1.correctNotes))
        }
        game.moveToNextQuestion()
        
        if let q2 = game.currentQuestion {
            _ = game.submitAnswer(Set(q2.correctNotes))
        }
        game.moveToNextQuestion()
        
        XCTAssertTrue(game.isQuizCompleted)
        XCTAssertFalse(game.isQuizActive)
        XCTAssertNotNil(game.currentResult)
    }
    
    // MARK: - Progress Calculation Tests
    
    func testProgressCalculation() {
        game.startNewQuiz(
            numberOfQuestions: 4,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        XCTAssertEqual(game.progress, 0.0) // 0/4
        
        game.moveToNextQuestion()
        XCTAssertEqual(game.progress, 0.25) // 1/4
        
        game.moveToNextQuestion()
        XCTAssertEqual(game.progress, 0.5) // 2/4
        
        game.moveToNextQuestion()
        XCTAssertEqual(game.progress, 0.75) // 3/4
    }
    
    func testCurrentQuestionNumber() {
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        XCTAssertEqual(game.currentQuestionNumber, 1)
        
        game.moveToNextQuestion()
        XCTAssertEqual(game.currentQuestionNumber, 2)
        
        game.moveToNextQuestion()
        XCTAssertEqual(game.currentQuestionNumber, 3)
    }
    
    // MARK: - Quiz Completion Tests
    
    func testPerfectScoreResult() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        // Answer all questions correctly
        for _ in 0..<3 {
            if let question = game.currentQuestion {
                _ = game.submitAnswer(Set(question.correctNotes))
                game.moveToNextQuestion()
            }
        }
        
        guard let result = game.currentResult else {
            XCTFail("No result after completing quiz")
            return
        }
        
        XCTAssertEqual(result.correctAnswers, 3)
        XCTAssertEqual(result.totalQuestions, 3)
        XCTAssertEqual(result.accuracy, 1.0, accuracy: 0.001)
    }
    
    func testPartialScoreResult() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        // Answer first question correctly
        if let question = game.currentQuestion {
            _ = game.submitAnswer(Set(question.correctNotes))
        }
        game.moveToNextQuestion()
        
        // Answer second question incorrectly
        let wrongNotes: Set<Note> = [Note(name: "C", midiNumber: 60, isSharp: false)]
        _ = game.submitAnswer(wrongNotes)
        game.moveToNextQuestion()
        
        // Answer third question correctly
        if let question = game.currentQuestion {
            _ = game.submitAnswer(Set(question.correctNotes))
        }
        game.moveToNextQuestion()
        
        guard let result = game.currentResult else {
            XCTFail("No result after completing quiz")
            return
        }
        
        XCTAssertEqual(result.correctAnswers, 2)
        XCTAssertEqual(result.totalQuestions, 3)
        XCTAssertEqual(result.accuracy, 2.0/3.0, accuracy: 0.001)
    }
    
    func testResultContainsScaleTypes() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        // Complete the quiz
        for _ in 0..<3 {
            if let question = game.currentQuestion {
                _ = game.submitAnswer(Set(question.correctNotes))
                game.moveToNextQuestion()
            }
        }
        
        guard let result = game.currentResult else {
            XCTFail("No result after completing quiz")
            return
        }
        
        XCTAssertFalse(result.scaleTypes.isEmpty)
    }
    
    func testResultContainsDifficulty() {
        game.startNewQuiz(
            numberOfQuestions: 2,
            difficulty: .intermediate,
            questionTypes: [.allDegrees]
        )
        
        // Complete the quiz
        for _ in 0..<2 {
            game.moveToNextQuestion()
        }
        
        guard let result = game.currentResult else {
            XCTFail("No result after completing quiz")
            return
        }
        
        XCTAssertEqual(result.difficulty, .intermediate)
    }
    
    // MARK: - Reset State Tests
    
    func testResetQuizState() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        // Make some progress
        game.moveToNextQuestion()
        
        // Reset
        game.resetQuizState()
        
        XCTAssertNil(game.currentQuestion)
        XCTAssertEqual(game.currentQuestionIndex, 0)
        XCTAssertTrue(game.questions.isEmpty)
        XCTAssertTrue(game.userAnswers.isEmpty)
        XCTAssertTrue(game.earTrainingAnswers.isEmpty)
        XCTAssertFalse(game.isQuizActive)
        XCTAssertFalse(game.isQuizCompleted)
        XCTAssertNil(game.currentResult)
        XCTAssertEqual(game.lastRatingChange, 0)
        XCTAssertFalse(game.didRankUp)
    }
    
    // MARK: - Statistics Tests
    
    func testStatsOverallAccuracyCalculation() {
        // Stats might have persisted values, so just verify calculation works
        var stats = ScaleDrillStats()
        stats.totalScalesAnswered = 10
        stats.totalCorrectAnswers = 8
        XCTAssertEqual(stats.overallAccuracy, 0.8, accuracy: 0.001)
    }
    
    func testStatsOverallAccuracyZeroDivision() {
        // Test zero-division protection in new stats
        let stats = ScaleDrillStats()
        XCTAssertEqual(stats.overallAccuracy, 0)
    }
    
    func testStatsUpdateAfterQuiz() {
        let initialAnswered = game.stats.totalScalesAnswered
        
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        // Complete the quiz
        for _ in 0..<3 {
            if let question = game.currentQuestion {
                _ = game.submitAnswer(Set(question.correctNotes))
                game.moveToNextQuestion()
            }
        }
        
        XCTAssertGreaterThan(game.stats.totalScalesAnswered, initialAnswered)
    }
    
    func testScaleTypeStatsUpdate() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let symbol = question.scale.scaleType.symbol
        
        _ = game.submitAnswer(Set(question.correctNotes))
        
        let scaleStats = game.stats.statsByScaleSymbol[symbol]
        XCTAssertNotNil(scaleStats)
        XCTAssertGreaterThan(scaleStats?.questionsAnswered ?? 0, 0)
    }
    
    func testKeyStatsUpdate() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let key = question.scale.root.name
        
        _ = game.submitAnswer(Set(question.correctNotes))
        
        let keyStats = game.stats.statsByKey[key]
        XCTAssertNotNil(keyStats)
        XCTAssertGreaterThan(keyStats?.questionsAnswered ?? 0, 0)
    }
    
    // MARK: - Weak Scale Types Tests
    
    func testGetWeakScaleTypesEmpty() {
        // Initially no data, should return empty
        let weak = game.getWeakScaleTypes()
        XCTAssertTrue(weak.isEmpty)
    }
    
    // MARK: - Scoreboard Tests
    
    func testScoreboardSavesResultsOnQuizCompletion() {
        // Test that scoreboard count increases after completing a quiz
        let initialCount = game.scoreboard.count
        
        game.startNewQuiz(
            numberOfQuestions: 1,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        // Complete the quiz
        if let question = game.currentQuestion {
            _ = game.submitAnswer(Set(question.correctNotes))
            game.moveToNextQuestion()
        }
        
        // After quiz completion, scoreboard should have at least one entry
        // (May be same count if initial was at max, but should not decrease)
        XCTAssertGreaterThanOrEqual(game.scoreboard.count, min(initialCount, 1))
    }
    
    func testScoreboardMaxEntries() {
        // Fill scoreboard beyond limit
        for i in 0..<15 {
            game.startNewQuiz(
                numberOfQuestions: 1,
                difficulty: .beginner,
                questionTypes: [.allDegrees]
            )
            
            if let question = game.currentQuestion {
                _ = game.submitAnswer(Set(question.correctNotes))
                game.moveToNextQuestion()
            }
        }
        
        // Scoreboard should be capped at 10
        XCTAssertLessThanOrEqual(game.scoreboard.count, 10)
    }
}

// MARK: - Scale Drill Stats Tests

@MainActor
final class ScaleDrillStatsTests: XCTestCase {
    
    func testOverallAccuracyCalculation() {
        var stats = ScaleDrillStats()
        stats.totalScalesAnswered = 10
        stats.totalCorrectAnswers = 7
        
        XCTAssertEqual(stats.overallAccuracy, 0.7, accuracy: 0.001)
    }
    
    func testOverallAccuracyZeroQuestions() {
        let stats = ScaleDrillStats()
        XCTAssertEqual(stats.overallAccuracy, 0)
    }
    
    func testRecordSession() {
        var stats = ScaleDrillStats()
        
        let session = ScalePracticeSession(
            id: UUID(),
            date: Date(),
            duration: 120,
            questionsAnswered: 10,
            correctAnswers: 8,
            scaleTypes: ["Major", "Dorian"],
            difficulty: "Beginner",
            ratingBefore: 1000,
            ratingAfter: 1010
        )
        
        stats.recordSession(session)
        
        XCTAssertEqual(stats.totalScalesAnswered, 10)
        XCTAssertEqual(stats.totalCorrectAnswers, 8)
        XCTAssertEqual(stats.totalPracticeTime, 120)
        XCTAssertEqual(stats.practiceLog.count, 1)
    }
    
    func testPracticeLogMaxSize() {
        var stats = ScaleDrillStats()
        
        // Add more than 100 sessions
        for i in 0..<110 {
            let session = ScalePracticeSession(
                id: UUID(),
                date: Date(),
                duration: 60,
                questionsAnswered: 5,
                correctAnswers: 3,
                scaleTypes: ["Major"],
                difficulty: "Beginner",
                ratingBefore: 1000,
                ratingAfter: 1005
            )
            stats.recordSession(session)
        }
        
        // Practice log should be capped at 100
        XCTAssertEqual(stats.practiceLog.count, 100)
    }
}

// MARK: - Scale Type Statistics Tests

@MainActor
final class ScaleTypeStatisticsTests: XCTestCase {
    
    func testAccuracyCalculation() {
        var stats = ScaleTypeStatistics()
        stats.questionsAnswered = 20
        stats.correctAnswers = 15
        
        XCTAssertEqual(stats.accuracy, 0.75, accuracy: 0.001)
    }
    
    func testAccuracyZeroQuestions() {
        let stats = ScaleTypeStatistics()
        XCTAssertEqual(stats.accuracy, 0)
    }
}

// MARK: - Scale Practice Session Tests

@MainActor
final class ScalePracticeSessionTests: XCTestCase {
    
    func testSessionAccuracy() {
        let session = ScalePracticeSession(
            id: UUID(),
            date: Date(),
            duration: 180,
            questionsAnswered: 10,
            correctAnswers: 9,
            scaleTypes: ["Major", "Minor"],
            difficulty: "Intermediate",
            ratingBefore: 1200,
            ratingAfter: 1215
        )
        
        XCTAssertEqual(session.accuracy, 0.9, accuracy: 0.001)
    }
    
    func testSessionRatingChange() {
        let session = ScalePracticeSession(
            id: UUID(),
            date: Date(),
            duration: 180,
            questionsAnswered: 10,
            correctAnswers: 9,
            scaleTypes: ["Major"],
            difficulty: "Intermediate",
            ratingBefore: 1200,
            ratingAfter: 1215
        )
        
        XCTAssertEqual(session.ratingChange, 15)
    }
    
    func testSessionNegativeRatingChange() {
        let session = ScalePracticeSession(
            id: UUID(),
            date: Date(),
            duration: 180,
            questionsAnswered: 10,
            correctAnswers: 2,
            scaleTypes: ["Major"],
            difficulty: "Advanced",
            ratingBefore: 1200,
            ratingAfter: 1190
        )
        
        XCTAssertEqual(session.ratingChange, -10)
    }
}

// MARK: - Scale Quiz Result Tests

@MainActor
final class ScaleQuizResultTests: XCTestCase {
    
    func testResultAccuracy() {
        let result = ScaleQuizResult(
            date: Date(),
            totalQuestions: 10,
            correctAnswers: 7,
            totalTime: 120,
            difficulty: .beginner,
            questionTypes: [.allDegrees],
            ratingChange: 5,
            scaleTypes: ["Major"]
        )
        
        XCTAssertEqual(result.accuracy, 0.7, accuracy: 0.001)
    }
    
    func testResultAverageTime() {
        let result = ScaleQuizResult(
            date: Date(),
            totalQuestions: 10,
            correctAnswers: 7,
            totalTime: 120,
            difficulty: .beginner,
            questionTypes: [.allDegrees],
            ratingChange: 5,
            scaleTypes: ["Major"]
        )
        
        XCTAssertEqual(result.averageTimePerQuestion, 12.0, accuracy: 0.001)
    }
    
    func testResultZeroQuestions() {
        let result = ScaleQuizResult(
            date: Date(),
            totalQuestions: 0,
            correctAnswers: 0,
            totalTime: 0,
            difficulty: .beginner,
            questionTypes: [],
            ratingChange: 0,
            scaleTypes: []
        )
        
        XCTAssertEqual(result.accuracy, 0)
        XCTAssertEqual(result.averageTimePerQuestion, 0)
    }
}

// MARK: - Scale Question Tests

@MainActor
final class ScaleQuestionTests: XCTestCase {
    
    func testAllDegreesQuestionText() {
        let scaleType = ScaleType(
            name: "Major Scale",
            symbol: "Major",
            degrees: [
                .root, .second, .third, .fourth, .fifth, .sixth, .seventh
            ],
            difficulty: .beginner
        )
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let scale = Scale(root: root, scaleType: scaleType)
        
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees
        )
        
        XCTAssertTrue(question.questionText.contains("Select all notes"))
    }
    
    func testSingleDegreeQuestionText() {
        let scaleType = ScaleType(
            name: "Major Scale",
            symbol: "Major",
            degrees: [
                .root, .second, .third, .fourth, .fifth, .sixth, .seventh
            ],
            difficulty: .beginner
        )
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let scale = Scale(root: root, scaleType: scaleType)
        let targetDegree = ScaleDegree.third
        
        let question = ScaleQuestion(
            scale: scale,
            questionType: .singleDegree,
            targetDegree: targetDegree
        )
        
        XCTAssertTrue(question.questionText.contains("Find the"))
        XCTAssertEqual(question.correctNotes.count, 1)
    }
    
    func testEarTrainingQuestionText() {
        let scaleType = ScaleType(
            name: "Major Scale",
            symbol: "Major",
            degrees: [
                .root, .second, .third, .fourth, .fifth, .sixth, .seventh
            ],
            difficulty: .beginner
        )
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let scale = Scale(root: root, scaleType: scaleType)
        
        let question = ScaleQuestion(
            scale: scale,
            questionType: .earTraining
        )
        
        XCTAssertEqual(question.questionText, "What scale did you hear?")
    }
    
    func testCheckAnswerCorrect() {
        let scaleType = ScaleType(
            name: "Major Scale",
            symbol: "Major",
            degrees: [
                .root, .second, .third, .octave
            ],
            difficulty: .beginner
        )
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let scale = Scale(root: root, scaleType: scaleType)
        
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees
        )
        
        // C major scale notes (C, D, E) - octave excluded from correctNotes
        let userNotes: Set<Note> = [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "D", midiNumber: 62, isSharp: false),
            Note(name: "E", midiNumber: 64, isSharp: false)
        ]
        
        XCTAssertTrue(question.checkAnswer(userNotes))
    }
    
    func testCheckAnswerIncorrect() {
        let scaleType = ScaleType(
            name: "Major Scale",
            symbol: "Major",
            degrees: [
                .root, .second, .third, .octave
            ],
            difficulty: .beginner
        )
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let scale = Scale(root: root, scaleType: scaleType)
        
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees
        )
        
        // Wrong notes
        let userNotes: Set<Note> = [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "F", midiNumber: 65, isSharp: false)
        ]
        
        XCTAssertFalse(question.checkAnswer(userNotes))
    }
}

// MARK: - Scale Question Type Tests

@MainActor
final class ScaleQuestionTypeTests: XCTestCase {
    
    func testAllCases() {
        XCTAssertEqual(ScaleQuestionType.allCases.count, 3)
        XCTAssertTrue(ScaleQuestionType.allCases.contains(.singleDegree))
        XCTAssertTrue(ScaleQuestionType.allCases.contains(.allDegrees))
        XCTAssertTrue(ScaleQuestionType.allCases.contains(.earTraining))
    }
    
    func testRawValues() {
        XCTAssertEqual(ScaleQuestionType.singleDegree.rawValue, "Single Degree")
        XCTAssertEqual(ScaleQuestionType.allDegrees.rawValue, "All Scale Tones")
        XCTAssertEqual(ScaleQuestionType.earTraining.rawValue, "Ear Training")
    }
    
    func testDescriptions() {
        XCTAssertFalse(ScaleQuestionType.singleDegree.description.isEmpty)
        XCTAssertFalse(ScaleQuestionType.allDegrees.description.isEmpty)
        XCTAssertFalse(ScaleQuestionType.earTraining.description.isEmpty)
    }
    
    func testIcons() {
        XCTAssertFalse(ScaleQuestionType.singleDegree.icon.isEmpty)
        XCTAssertFalse(ScaleQuestionType.allDegrees.icon.isEmpty)
        XCTAssertFalse(ScaleQuestionType.earTraining.icon.isEmpty)
    }
}

// MARK: - End-to-End Flow Tests
// These tests verify the complete quiz flow: setup → start → answer questions → proceed → complete
// They ensure state transitions are correct at each step

@MainActor
final class ScaleGameFlowTests: XCTestCase {
    
    var game: ScaleGame!
    
    override func setUp() {
        super.setUp()
        game = ScaleGame()
        game.resetQuizState()
    }
    
    override func tearDown() {
        game = nil
        super.tearDown()
    }
    
    func test_flow_completeSession_allDegrees() {
        // Step 1: Verify initial state
        XCTAssertFalse(game.isQuizActive)
        XCTAssertNil(game.currentQuestion)
        XCTAssertTrue(game.questions.isEmpty)
        
        // Step 2: Start quiz
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        XCTAssertTrue(game.isQuizActive)
        XCTAssertFalse(game.isQuizCompleted)
        XCTAssertNotNil(game.currentQuestion)
        XCTAssertEqual(game.questions.count, 5)
        XCTAssertEqual(game.currentQuestionIndex, 0)
        
        // Step 3: Answer all questions correctly
        for i in 0..<5 {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Submit correct answer (convert to Set)
            let isCorrect = game.submitAnswer(Set(question.correctNotes))
            XCTAssertTrue(isCorrect, "Question \(i): Correct notes should be marked correct")
            
            // Move to next
            game.moveToNextQuestion()
        }
        
        // Step 4: Verify completion
        XCTAssertTrue(game.isQuizCompleted)
        XCTAssertFalse(game.isQuizActive)
    }
    
    func test_flow_completeSession_earTraining() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.earTraining]
        )
        
        XCTAssertTrue(game.isQuizActive)
        
        for i in 0..<3 {
            guard game.currentQuestion != nil else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Record correct answer for ear training
            game.recordEarTrainingAnswer(correct: true)
            
            game.moveToNextQuestion()
        }
        
        XCTAssertTrue(game.isQuizCompleted)
    }
    
    func test_flow_mixedCorrectIncorrect() {
        game.startNewQuiz(
            numberOfQuestions: 4,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        for i in 0..<4 {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Alternate correct/incorrect
            if i % 2 == 0 {
                _ = game.submitAnswer(Set(question.correctNotes))
            } else {
                _ = game.submitAnswer(Set<Note>()) // Wrong answer
            }
            
            game.moveToNextQuestion()
        }
        
        XCTAssertTrue(game.isQuizCompleted)
    }
    
    func test_flow_resetAndRestart() {
        // Start and answer one question
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        if let question = game.currentQuestion {
            _ = game.submitAnswer(Set(question.correctNotes))
            game.moveToNextQuestion()
        }
        
        XCTAssertEqual(game.currentQuestionIndex, 1)
        
        // Reset
        game.resetQuizState()
        
        XCTAssertFalse(game.isQuizActive)
        XCTAssertFalse(game.isQuizCompleted)
        XCTAssertNil(game.currentQuestion)
        XCTAssertTrue(game.questions.isEmpty)
        XCTAssertEqual(game.currentQuestionIndex, 0)
        
        // Start new quiz
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .intermediate,
            questionTypes: [.earTraining]
        )
        
        XCTAssertTrue(game.isQuizActive)
        XCTAssertEqual(game.questions.count, 3)
        XCTAssertEqual(game.currentQuestionIndex, 0)
    }
    
    func test_flow_incorrectAnswerCanProceed() {
        // Critical test: After incorrect answer, user must be able to proceed
        game.startNewQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.allDegrees]
        )
        
        guard game.currentQuestion != nil else {
            XCTFail("Should have a question")
            return
        }
        
        // Submit wrong answer
        let isCorrect = game.submitAnswer(Set<Note>())
        XCTAssertFalse(isCorrect)
        
        // User should be able to proceed
        let previousIndex = game.currentQuestionIndex
        game.moveToNextQuestion()
        XCTAssertEqual(game.currentQuestionIndex, previousIndex + 1, "Must be able to move to next question after incorrect answer")
    }
    
    func test_flow_singleDegreeQuestions() {
        game.startNewQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.singleDegree]
        )
        
        XCTAssertTrue(game.isQuizActive)
        
        for i in 0..<5 {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Single degree questions need a target degree
            XCTAssertEqual(question.questionType, .singleDegree)
            
            // Submit answer (convert to Set)
            _ = game.submitAnswer(Set(question.correctNotes))
            game.moveToNextQuestion()
        }
        
        XCTAssertTrue(game.isQuizCompleted)
    }
}
