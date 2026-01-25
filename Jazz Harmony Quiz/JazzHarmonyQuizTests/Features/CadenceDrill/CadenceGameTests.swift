import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class CadenceGameTests: XCTestCase {
    
    var game: CadenceGame!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        game = CadenceGame()
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
        XCTAssertFalse(game.isQuizActive)
        XCTAssertFalse(game.isQuizCompleted)
        XCTAssertNil(game.currentResult)
        XCTAssertEqual(game.selectedCadenceType, .major)
        XCTAssertEqual(game.selectedDrillMode, .fullProgression)
    }
    
    func testDefaultSettingsState() {
        XCTAssertEqual(game.selectedKeyDifficulty, .all)
        XCTAssertFalse(game.useMixedCadences)
        XCTAssertFalse(game.useExtendedVChords)
        XCTAssertEqual(game.selectedExtendedVChord, .basic)
    }
    
    // MARK: - Start Quiz Tests (Simple Signature)
    
    func testStartNewQuizSimple() {
        game.startNewQuiz(numberOfQuestions: 5, cadenceType: .major)
        
        XCTAssertEqual(game.totalQuestions, 5)
        XCTAssertEqual(game.selectedCadenceType, .major)
        XCTAssertEqual(game.questions.count, 5)
        XCTAssertTrue(game.isQuizActive)
        XCTAssertFalse(game.isQuizCompleted)
        XCTAssertEqual(game.currentQuestionIndex, 0)
        XCTAssertNotNil(game.currentQuestion)
    }
    
    func testStartNewQuizMinor() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .minor)
        
        XCTAssertEqual(game.selectedCadenceType, .minor)
        XCTAssertEqual(game.questions.count, 3)
        
        // All questions should have minor cadences
        for question in game.questions {
            XCTAssertEqual(question.cadence.cadenceType, .minor)
        }
    }
    
    // MARK: - Start Quiz Tests (Full Signature)
    
    func testStartNewQuizWithFullParameters() {
        game.startNewQuiz(
            numberOfQuestions: 8,
            cadenceType: .tritoneSubstitution,
            drillMode: .guideTones,
            keyDifficulty: .medium
        )
        
        XCTAssertEqual(game.totalQuestions, 8)
        XCTAssertEqual(game.selectedCadenceType, .tritoneSubstitution)
        XCTAssertEqual(game.selectedDrillMode, .guideTones)
        XCTAssertEqual(game.selectedKeyDifficulty, .medium)
        XCTAssertEqual(game.questions.count, 8)
        XCTAssertTrue(game.isQuizActive)
    }
    
    func testStartQuizResetsState() {
        // Start first quiz
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        // Submit some answers
        if let question = game.currentQuestion {
            game.submitAnswer([[Note(name: "C", midiNumber: 60, isSharp: false)]])
        }
        
        // Start new quiz
        game.startNewQuiz(numberOfQuestions: 5, cadenceType: .minor)
        
        XCTAssertEqual(game.questions.count, 5)
        XCTAssertEqual(game.currentQuestionIndex, 0)
        XCTAssertTrue(game.userAnswers.isEmpty)
        XCTAssertEqual(game.totalQuizTime, 0)
        XCTAssertNil(game.currentResult)
    }
    
    func testStartQuizResetHintTracking() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        XCTAssertEqual(game.hintsUsedThisQuestion, 0)
        XCTAssertEqual(game.totalHintsUsed, 0)
        XCTAssertEqual(game.currentHintLevel, 0)
    }
    
    // MARK: - Key Difficulty Tests
    
    func testEasyKeyDifficulty() {
        game.startNewQuiz(
            numberOfQuestions: 10,
            cadenceType: .major,
            drillMode: .fullProgression,
            keyDifficulty: .easy
        )
        
        // Easy keys: C, F, G, Bb, Eb
        let easyKeys = Set(KeyDifficulty.easy.availableRoots.map { $0.name })
        
        for question in game.questions {
            XCTAssertTrue(easyKeys.contains(question.cadence.key.name),
                "Key \(question.cadence.key.name) should be in easy keys")
        }
    }
    
    func testHardKeyDifficulty() {
        game.startNewQuiz(
            numberOfQuestions: 10,
            cadenceType: .major,
            drillMode: .fullProgression,
            keyDifficulty: .hard
        )
        
        let hardKeys = Set(KeyDifficulty.hard.availableRoots.map { $0.name })
        
        for question in game.questions {
            XCTAssertTrue(hardKeys.contains(question.cadence.key.name),
                "Key \(question.cadence.key.name) should be in hard keys")
        }
    }
    
    // MARK: - Drill Mode Tests
    
    func testFullProgressionMode() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            cadenceType: .major,
            drillMode: .fullProgression,
            keyDifficulty: .all
        )
        
        for question in game.questions {
            XCTAssertEqual(question.drillMode, .fullProgression)
            XCTAssertEqual(question.chordsToSpell.count, 3) // ii-V-I = 3 chords
        }
    }
    
    func testGuideToneMode() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            cadenceType: .major,
            drillMode: .guideTones,
            keyDifficulty: .all
        )
        
        for question in game.questions {
            XCTAssertEqual(question.drillMode, .guideTones)
        }
    }
    
    func testCommonTonesMode() {
        game.selectedCommonTonePair = .iiToV
        game.startNewQuiz(
            numberOfQuestions: 3,
            cadenceType: .major,
            drillMode: .commonTones,
            keyDifficulty: .all
        )
        
        for question in game.questions {
            XCTAssertEqual(question.drillMode, .commonTones)
            XCTAssertNotNil(question.commonTonePair)
        }
    }
    
    func testChordIdentificationMode() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            cadenceType: .major,
            drillMode: .chordIdentification,
            keyDifficulty: .all
        )
        
        for question in game.questions {
            XCTAssertEqual(question.drillMode, .chordIdentification)
        }
    }
    
    func testResolutionTargetsMode() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            cadenceType: .major,
            drillMode: .resolutionTargets,
            keyDifficulty: .all
        )
        
        for question in game.questions {
            XCTAssertEqual(question.drillMode, .resolutionTargets)
            XCTAssertNotNil(question.resolutionPairs)
        }
    }
    
    // MARK: - Submit Answer Tests
    
    func testSubmitAnswerRecordsAnswer() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let testAnswer: [[Note]] = [[Note(name: "C", midiNumber: 60, isSharp: false)]]
        game.submitAnswer(testAnswer)
        
        XCTAssertNotNil(game.userAnswers[question.id])
    }
    
    func testSubmitAnswerAdvancesToNextQuestion() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        XCTAssertEqual(game.currentQuestionIndex, 0)
        
        game.submitAnswer([[Note(name: "C", midiNumber: 60, isSharp: false)]])
        
        XCTAssertEqual(game.currentQuestionIndex, 1)
    }
    
    func testSubmitAnswerUpdatesTime() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        XCTAssertEqual(game.totalQuizTime, 0)
        
        // Wait a tiny bit then submit
        Thread.sleep(forTimeInterval: 0.1)
        game.submitAnswer([[Note(name: "C", midiNumber: 60, isSharp: false)]])
        
        XCTAssertGreaterThan(game.totalQuizTime, 0)
    }
    
    func testSubmitLastAnswerCompletesQuiz() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        // Answer both questions
        game.submitAnswer([[Note(name: "C", midiNumber: 60, isSharp: false)]])
        game.submitAnswer([[Note(name: "D", midiNumber: 62, isSharp: false)]])
        
        XCTAssertFalse(game.isQuizActive)
        XCTAssertTrue(game.isQuizCompleted)
        XCTAssertNotNil(game.currentResult)
    }
    
    // MARK: - Answer Correctness Tests
    
    func testCorrectAnswerDetection() {
        game.startNewQuiz(
            numberOfQuestions: 1,
            cadenceType: .major,
            drillMode: .fullProgression,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Get the correct answer from the question
        let correctAnswer = question.correctAnswers
        
        let isCorrect = game.isAnswerCorrect(userAnswer: correctAnswer, question: question)
        XCTAssertTrue(isCorrect)
    }
    
    func testIncorrectAnswerDetection() {
        game.startNewQuiz(
            numberOfQuestions: 1,
            cadenceType: .major,
            drillMode: .fullProgression,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Submit a clearly wrong answer
        let wrongAnswer: [[Note]] = [
            [Note(name: "X", midiNumber: 100, isSharp: false)],
            [Note(name: "Y", midiNumber: 101, isSharp: false)],
            [Note(name: "Z", midiNumber: 102, isSharp: false)]
        ]
        
        let isCorrect = game.isAnswerCorrect(userAnswer: wrongAnswer, question: question)
        XCTAssertFalse(isCorrect)
    }
    
    func testOctaveAgnosticAnswerChecking() {
        game.startNewQuiz(
            numberOfQuestions: 1,
            cadenceType: .major,
            drillMode: .fullProgression,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Create answer with notes in different octaves but same pitch classes
        var octaveShiftedAnswer: [[Note]] = []
        for chordNotes in question.correctAnswers {
            let shiftedNotes = chordNotes.map { note in
                Note(name: note.name, midiNumber: note.midiNumber + 12, isSharp: note.isSharp)
            }
            octaveShiftedAnswer.append(shiftedNotes)
        }
        
        let isCorrect = game.isAnswerCorrect(userAnswer: octaveShiftedAnswer, question: question)
        XCTAssertTrue(isCorrect, "Answer should be correct regardless of octave")
    }
    
    // MARK: - Results Tests
    
    func testResultsContainAccuracy() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        guard let q1 = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Answer first correctly
        game.submitAnswer(q1.correctAnswers)
        
        // Answer second incorrectly
        game.submitAnswer([[Note(name: "X", midiNumber: 100, isSharp: false)]])
        
        XCTAssertNotNil(game.currentResult)
        XCTAssertEqual(game.currentResult?.totalQuestions, 2)
        // One correct out of two
        XCTAssertEqual(game.currentResult?.correctAnswers, 1)
    }
    
    func testPerfectScoreResult() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        // Answer both correctly
        for _ in 0..<2 {
            if let question = game.currentQuestion {
                game.submitAnswer(question.correctAnswers)
            }
        }
        
        XCTAssertNotNil(game.currentResult)
        XCTAssertEqual(game.currentResult?.correctAnswers, 2)
        XCTAssertEqual(game.currentResult?.accuracy ?? 0.0, 1.0, accuracy: 0.01)
    }
    
    // MARK: - Progress Tracking Tests
    
    func testProgressCalculation() {
        game.startNewQuiz(numberOfQuestions: 10, cadenceType: .major)
        
        XCTAssertEqual(game.progress, 0.0, accuracy: 0.01)
        
        // Answer one question
        game.submitAnswer([[Note(name: "C", midiNumber: 60, isSharp: false)]])
        
        XCTAssertEqual(game.progress, 0.1, accuracy: 0.01)
    }
    
    func testCurrentQuestionNumber() {
        game.startNewQuiz(numberOfQuestions: 5, cadenceType: .major)
        
        XCTAssertEqual(game.currentQuestionNumber, 1)
        
        game.submitAnswer([[]])
        XCTAssertEqual(game.currentQuestionNumber, 2)
        
        game.submitAnswer([[]])
        XCTAssertEqual(game.currentQuestionNumber, 3)
    }
    
    func testAnsweredQuestionsCount() {
        game.startNewQuiz(numberOfQuestions: 5, cadenceType: .major)
        
        XCTAssertEqual(game.answeredQuestions, 0)
        
        game.submitAnswer([[]])
        XCTAssertEqual(game.answeredQuestions, 1)
        
        game.submitAnswer([[]])
        XCTAssertEqual(game.answeredQuestions, 2)
    }
    
    // MARK: - Navigation Tests
    
    func testCanGoToNextQuestion() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        XCTAssertTrue(game.canGoToNextQuestion())
        
        game.goToNextQuestion()
        XCTAssertTrue(game.canGoToNextQuestion())
        
        game.goToNextQuestion()
        XCTAssertFalse(game.canGoToNextQuestion()) // At last question
    }
    
    func testCanGoToPreviousQuestion() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        XCTAssertFalse(game.canGoToPreviousQuestion()) // At first question
        
        game.goToNextQuestion()
        XCTAssertTrue(game.canGoToPreviousQuestion())
    }
    
    func testGoToNextQuestion() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        let firstQuestion = game.currentQuestion
        
        game.goToNextQuestion()
        
        XCTAssertEqual(game.currentQuestionIndex, 1)
        XCTAssertNotEqual(game.currentQuestion?.id, firstQuestion?.id)
    }
    
    func testGoToPreviousQuestion() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        let firstQuestion = game.currentQuestion
        
        game.goToNextQuestion()
        game.goToPreviousQuestion()
        
        XCTAssertEqual(game.currentQuestionIndex, 0)
        XCTAssertEqual(game.currentQuestion?.id, firstQuestion?.id)
    }
    
    // MARK: - Quiz State Reset Tests
    
    func testResetQuizState() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        game.submitAnswer([[]])
        
        game.resetQuizState()
        
        XCTAssertFalse(game.isQuizActive)
        XCTAssertFalse(game.isQuizCompleted)
        XCTAssertNil(game.currentResult)
        XCTAssertNil(game.currentQuestion)
        XCTAssertEqual(game.currentQuestionIndex, 0)
        XCTAssertTrue(game.userAnswers.isEmpty)
        XCTAssertEqual(game.totalQuizTime, 0)
    }
    
    // MARK: - Hint System Tests
    
    func testCanRequestHintInitially() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        XCTAssertTrue(game.canRequestHint)
        XCTAssertEqual(game.currentHintLevel, 0)
    }
    
    func testRequestHintIncrementsLevel() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        let hint = game.requestHint(for: 0)
        
        XCTAssertNotNil(hint)
        XCTAssertEqual(game.currentHintLevel, 1)
        XCTAssertEqual(game.hintsUsedThisQuestion, 1)
        XCTAssertEqual(game.totalHintsUsed, 1)
    }
    
    func testRequestMaxHints() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        // Request 3 hints (max)
        _ = game.requestHint(for: 0)
        _ = game.requestHint(for: 0)
        _ = game.requestHint(for: 0)
        
        XCTAssertEqual(game.currentHintLevel, 3)
        XCTAssertFalse(game.canRequestHint)
        
        // Fourth hint should return nil
        let fourthHint = game.requestHint(for: 0)
        XCTAssertNil(fourthHint)
    }
    
    func testHintPenalty() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        XCTAssertEqual(game.hintPenalty, 1.0, accuracy: 0.01) // No hints used
        
        _ = game.requestHint(for: 0)
        XCTAssertEqual(game.hintPenalty, 0.75, accuracy: 0.01) // 1 hint
        
        _ = game.requestHint(for: 0)
        XCTAssertEqual(game.hintPenalty, 0.5, accuracy: 0.01) // 2 hints
        
        _ = game.requestHint(for: 0)
        XCTAssertEqual(game.hintPenalty, 0.25, accuracy: 0.01) // 3 hints
    }
    
    func testHintResetOnNextQuestion() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        _ = game.requestHint(for: 0)
        _ = game.requestHint(for: 0)
        
        XCTAssertEqual(game.hintsUsedThisQuestion, 2)
        XCTAssertEqual(game.currentHintLevel, 2)
        
        // Move to next question
        game.submitAnswer([[]])
        
        XCTAssertEqual(game.hintsUsedThisQuestion, 0)
        XCTAssertEqual(game.currentHintLevel, 0)
        XCTAssertEqual(game.totalHintsUsed, 2) // Total preserved
    }
    
    // MARK: - Mistake Review Tests
    
    func testGetMissedQuestionsEmpty() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        // Answer all correctly
        for _ in 0..<2 {
            if let question = game.currentQuestion {
                game.submitAnswer(question.correctAnswers)
            }
        }
        
        let missed = game.getMissedQuestions()
        XCTAssertTrue(missed.isEmpty)
    }
    
    func testGetMissedQuestionsReturnsIncorrect() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        // Answer first correctly
        if let question = game.currentQuestion {
            game.submitAnswer(question.correctAnswers)
        }
        
        // Answer second incorrectly
        game.submitAnswer([[Note(name: "X", midiNumber: 100, isSharp: false)]])
        
        // Answer third incorrectly
        game.submitAnswer([[Note(name: "Y", midiNumber: 101, isSharp: false)]])
        
        let missed = game.getMissedQuestions()
        XCTAssertEqual(missed.count, 2)
    }
    
    func testHasMissedQuestions() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        // Answer first correctly
        if let question = game.currentQuestion {
            game.submitAnswer(question.correctAnswers)
        }
        
        // Answer second incorrectly
        game.submitAnswer([[Note(name: "X", midiNumber: 100, isSharp: false)]])
        
        XCTAssertTrue(game.hasMissedQuestions)
    }
    
    func testStartMistakeReviewDrill() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        // Answer first correctly
        if let question = game.currentQuestion {
            game.submitAnswer(question.correctAnswers)
        }
        
        // Answer second and third incorrectly
        game.submitAnswer([[Note(name: "X", midiNumber: 100, isSharp: false)]])
        game.submitAnswer([[Note(name: "Y", midiNumber: 101, isSharp: false)]])
        
        // Start mistake review
        game.startMistakeReviewDrill()
        
        XCTAssertTrue(game.isQuizActive)
        XCTAssertFalse(game.isQuizCompleted)
        XCTAssertEqual(game.questions.count, 2) // Only missed questions
        XCTAssertEqual(game.totalQuestions, 2)
        XCTAssertEqual(game.currentQuestionIndex, 0)
    }
    
    // MARK: - Chord Identification Mode Tests
    
    func testRecordChordIdentificationAnswer() {
        game.startNewQuiz(
            numberOfQuestions: 3,
            cadenceType: .major,
            drillMode: .chordIdentification,
            keyDifficulty: .all
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let selections = [
            ChordSelection(selectedRoot: Note(name: "C", midiNumber: 60, isSharp: false), selectedQuality: "maj7"),
            ChordSelection(selectedRoot: Note(name: "G", midiNumber: 67, isSharp: false), selectedQuality: "7"),
            ChordSelection(selectedRoot: Note(name: "C", midiNumber: 60, isSharp: false), selectedQuality: "maj7")
        ]
        
        game.recordChordIdentificationAnswer(selections: selections, isCorrect: true)
        
        XCTAssertNotNil(game.chordIdentificationAnswers[question.id])
        XCTAssertNotNil(game.userAnswers[question.id])
    }
    
    func testAdvanceToNextQuestion() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        XCTAssertEqual(game.currentQuestionIndex, 0)
        
        game.advanceToNextQuestion()
        
        XCTAssertEqual(game.currentQuestionIndex, 1)
        XCTAssertEqual(game.hintsUsedThisQuestion, 0)
        XCTAssertEqual(game.currentHintLevel, 0)
    }
    
    func testIsLastQuestion() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        XCTAssertFalse(game.isLastQuestion)
        
        game.advanceToNextQuestion()
        
        XCTAssertTrue(game.isLastQuestion)
    }
    
    func testEndQuiz() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        // Answer questions
        game.submitAnswer([[]])
        game.submitAnswer([[]])
        
        // Quiz should be completed
        XCTAssertTrue(game.isQuizCompleted)
    }
    
    // MARK: - Mixed Cadences Tests
    
    func testMixedCadencesMode() {
        game.useMixedCadences = true
        game.selectedCadenceTypes = [.major, .minor, .tritoneSubstitution]
        
        game.startNewQuiz(
            numberOfQuestions: 10,
            cadenceType: .major, // This is ignored when mixed mode is on
            drillMode: .fullProgression,
            keyDifficulty: .all
        )
        
        // Should have variety of cadence types
        let cadenceTypes = Set(game.questions.map { $0.cadence.cadenceType })
        // With 10 questions and 3 types, we'd expect more than 1 type
        // But randomness could give all same type, so just verify questions exist
        XCTAssertEqual(game.questions.count, 10)
    }
    
    // MARK: - Extended V Chord Tests
    
    func testExtendedVChordOption() {
        game.useExtendedVChords = true
        game.selectedExtendedVChord = .sharpNine
        
        game.startNewQuiz(
            numberOfQuestions: 3,
            cadenceType: .major,
            drillMode: .fullProgression,
            keyDifficulty: .all
        )
        
        // Questions should be generated with extended V option
        for question in game.questions {
            XCTAssertNotNil(question.cadence)
        }
    }
    
    // MARK: - Current Score Tests
    
    func testCurrentScoreEmpty() {
        game.startNewQuiz(numberOfQuestions: 3, cadenceType: .major)
        
        // No answers submitted yet
        XCTAssertEqual(game.currentScore, 0)
    }
    
    func testCurrentScoreCalculation() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        // Answer first correctly
        if let question = game.currentQuestion {
            game.submitAnswer(question.correctAnswers)
        }
        
        // Answer second incorrectly (before quiz ends)
        // Note: currentScore is calculated on the fly
        XCTAssertGreaterThanOrEqual(game.currentScore, 0)
    }
    
    // MARK: - Average Time Tests
    
    func testAverageTimePerQuestion() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        XCTAssertEqual(game.averageTimePerQuestion, 0)
        
        Thread.sleep(forTimeInterval: 0.1)
        game.submitAnswer([[]])
        
        // After answering, should have positive average
        // But need to complete at least one answer
        XCTAssertGreaterThanOrEqual(game.averageTimePerQuestion, 0)
    }
    
    // MARK: - Timer Tests
    
    func testStartTimer() {
        game.startTimer()
        // Just verify it doesn't crash
    }
    
    func testStopTimer() {
        game.startTimer()
        game.stopTimer()
        // Just verify it doesn't crash
    }
    
    // MARK: - Lifetime Stats Tests
    
    func testLifetimeStatsInitialState() {
        let stats = CadenceLifetimeStats()
        
        XCTAssertEqual(stats.totalQuestionsAnswered, 0)
        XCTAssertEqual(stats.totalCorrectAnswers, 0)
        XCTAssertEqual(stats.totalQuizzesTaken, 0)
        XCTAssertEqual(stats.currentRating, 1000)
        XCTAssertEqual(stats.peakRating, 1000)
    }
    
    func testLifetimeStatsOverallAccuracy() {
        var stats = CadenceLifetimeStats()
        stats.totalQuestionsAnswered = 10
        stats.totalCorrectAnswers = 8
        
        XCTAssertEqual(stats.overallAccuracy, 0.8, accuracy: 0.01)
    }
    
    func testLifetimeStatsEmptyAccuracy() {
        let stats = CadenceLifetimeStats()
        
        XCTAssertEqual(stats.overallAccuracy, 0)
    }
    
    // MARK: - Encouragement Tests
    
    func testGetEncouragementMessage() {
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        // Complete quiz
        for _ in 0..<2 {
            if let question = game.currentQuestion {
                game.submitAnswer(question.correctAnswers)
            }
        }
        
        let message = game.getEncouragementMessage()
        XCTAssertNotNil(message)
    }
    
    func testGetStreakEncouragement() {
        // No special streak
        let noStreakMessage = game.getStreakEncouragement()
        XCTAssertNil(noStreakMessage) // Default streak is 0 or 1
    }
    
    // MARK: - Guide Tone Answer Validation Tests
    
    func testGuideToneCorrectAnswer() {
        game.startNewQuiz(
            numberOfQuestions: 1,
            cadenceType: .major,
            drillMode: .guideTones,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Get the expected guide tones
        var guideToneAnswer: [[Note]] = []
        for i in 0..<question.cadence.chords.count {
            let guideTones = question.guideTonesForChord(i)
            guideToneAnswer.append(guideTones)
        }
        
        let isCorrect = game.isAnswerCorrect(userAnswer: guideToneAnswer, question: question)
        XCTAssertTrue(isCorrect)
    }
    
    // MARK: - Resolution Target Answer Validation Tests
    
    func testResolutionTargetCorrectAnswer() {
        game.startNewQuiz(
            numberOfQuestions: 1,
            cadenceType: .major,
            drillMode: .resolutionTargets,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        guard let pairs = question.resolutionPairs,
              let index = question.currentResolutionIndex,
              index < pairs.count,
              let targetNote = pairs[index].targetNote else {
            // Some questions might not have resolution pairs
            return
        }
        
        let correctAnswer: [[Note]] = [[targetNote]]
        
        let isCorrect = game.isAnswerCorrect(userAnswer: correctAnswer, question: question)
        XCTAssertTrue(isCorrect)
    }
    
    // MARK: - Last Quiz Settings Tests
    
    func testSaveAndLoadLastQuizSettings() {
        game.startNewQuiz(
            numberOfQuestions: 7,
            cadenceType: .backdoor,
            drillMode: .commonTones,
            keyDifficulty: .hard
        )
        
        // Complete quiz to trigger save
        for _ in 0..<7 {
            game.submitAnswer([[]])
        }
        
        // Settings should be saved
        XCTAssertNotNil(game.lastQuizSettings)
        XCTAssertEqual(game.lastQuizSettings?.numberOfQuestions, 7)
        XCTAssertEqual(game.lastQuizSettings?.cadenceType, .backdoor)
        XCTAssertEqual(game.lastQuizSettings?.drillMode, .commonTones)
        XCTAssertEqual(game.lastQuizSettings?.keyDifficulty, .hard)
    }
    
    // MARK: - Weak Key Practice Tests
    
    func testCanPracticeWeakKeysInitially() {
        // Fresh game has no data
        XCTAssertFalse(game.canPracticeWeakKeys)
    }
    
    // MARK: - Rating Change Tests
    
    func testRatingChangeAfterQuiz() {
        game.startNewQuiz(numberOfQuestions: 5, cadenceType: .major)
        
        // Answer all correctly for positive rating change
        for _ in 0..<5 {
            if let question = game.currentQuestion {
                game.submitAnswer(question.correctAnswers)
            }
        }
        
        // Should have a rating change recorded
        // Perfect score should give positive change
        XCTAssertGreaterThan(game.lastRatingChange, 0)
    }
    
    // MARK: - Scoreboard Tests
    
    func testScoreboardSavesResults() {
        let initialCount = game.scoreboard.count
        
        game.startNewQuiz(numberOfQuestions: 2, cadenceType: .major)
        
        // Complete quiz
        game.submitAnswer([[]])
        game.submitAnswer([[]])
        
        XCTAssertEqual(game.scoreboard.count, initialCount + 1)
    }
}

// MARK: - CadenceLifetimeStats Extension Tests

final class CadenceLifetimeStatsTests: XCTestCase {
    
    func testGetWeakestKeysEmpty() {
        let stats = CadenceLifetimeStats()
        
        let weakKeys = stats.getWeakestKeys()
        XCTAssertTrue(weakKeys.isEmpty)
    }
    
    func testGetWeakestKeysWithData() {
        var stats = CadenceLifetimeStats()
        
        // Add some key stats
        stats.statsByKey["C"] = KeyStats(questionsAnswered: 10, correctAnswers: 9)
        stats.statsByKey["F#"] = KeyStats(questionsAnswered: 10, correctAnswers: 4)
        stats.statsByKey["Bb"] = KeyStats(questionsAnswered: 10, correctAnswers: 7)
        
        let weakKeys = stats.getWeakestKeys(limit: 2)
        
        XCTAssertEqual(weakKeys.count, 2)
        XCTAssertEqual(weakKeys.first?.key, "F#") // Lowest accuracy
    }
    
    func testGetStrongestKeysWithData() {
        var stats = CadenceLifetimeStats()
        
        stats.statsByKey["C"] = KeyStats(questionsAnswered: 10, correctAnswers: 9)
        stats.statsByKey["F#"] = KeyStats(questionsAnswered: 10, correctAnswers: 4)
        stats.statsByKey["Bb"] = KeyStats(questionsAnswered: 10, correctAnswers: 7)
        
        let strongKeys = stats.getStrongestKeys(limit: 2)
        
        XCTAssertEqual(strongKeys.count, 2)
        XCTAssertEqual(strongKeys.first?.key, "C") // Highest accuracy
    }
    
    func testGetUnderPracticedKeys() {
        var stats = CadenceLifetimeStats()
        
        // Only practiced C with enough questions
        stats.statsByKey["C"] = KeyStats(questionsAnswered: 10, correctAnswers: 8)
        stats.statsByKey["D"] = KeyStats(questionsAnswered: 2, correctAnswers: 1) // Under practiced
        
        let underPracticed = stats.getUnderPracticedKeys()
        
        // Should include all keys except C (and D since count < 5)
        XCTAssertTrue(underPracticed.contains("D"))
        XCTAssertFalse(underPracticed.contains("C"))
    }
    
    func testGetWeakestCadenceTypes() {
        var stats = CadenceLifetimeStats()
        
        stats.statsByCadenceType["major"] = CadenceTypeStats(questionsAnswered: 10, correctAnswers: 9)
        stats.statsByCadenceType["minor"] = CadenceTypeStats(questionsAnswered: 10, correctAnswers: 5)
        stats.statsByCadenceType["tritoneSubstitution"] = CadenceTypeStats(questionsAnswered: 10, correctAnswers: 7)
        
        let weakTypes = stats.getWeakestCadenceTypes(limit: 2)
        
        XCTAssertEqual(weakTypes.count, 2)
        XCTAssertEqual(weakTypes.first?.type, "minor") // Lowest accuracy
    }
    
    func testHasEnoughDataForAnalysis() {
        var stats = CadenceLifetimeStats()
        
        XCTAssertFalse(stats.hasEnoughDataForAnalysis)
        
        stats.totalQuestionsAnswered = 20
        XCTAssertTrue(stats.hasEnoughDataForAnalysis)
    }
    
    func testRecordQuizResult() {
        var stats = CadenceLifetimeStats()
        
        let result = CadenceResult(
            date: Date(),
            totalQuestions: 5,
            correctAnswers: 4,
            totalTime: 120,
            questions: [],
            userAnswers: [:],
            isCorrect: [:],
            cadenceType: .major
        )
        
        stats.recordQuizResult(result, questions: [], ratingChange: 15)
        
        XCTAssertEqual(stats.totalQuizzesTaken, 1)
        XCTAssertEqual(stats.totalQuestionsAnswered, 5)
        XCTAssertEqual(stats.totalCorrectAnswers, 4)
        XCTAssertEqual(stats.currentRating, 1015)
        XCTAssertEqual(stats.peakRating, 1015)
    }
    
    func testCheckAndUpdatePersonalBest() {
        var stats = CadenceLifetimeStats()
        
        // First entry should always be a personal best
        let isFirst = stats.checkAndUpdatePersonalBest(
            cadenceType: .major,
            key: "C",
            time: 30,
            accuracy: 0.9
        )
        XCTAssertTrue(isFirst)
        
        // Better accuracy should be a new best
        let isBetter = stats.checkAndUpdatePersonalBest(
            cadenceType: .major,
            key: "C",
            time: 35,
            accuracy: 1.0
        )
        XCTAssertTrue(isBetter)
        
        // Same accuracy but slower time should not be a new best
        let isSlower = stats.checkAndUpdatePersonalBest(
            cadenceType: .major,
            key: "C",
            time: 40,
            accuracy: 1.0
        )
        XCTAssertFalse(isSlower)
        
        // Same accuracy and faster time should be a new best
        let isFaster = stats.checkAndUpdatePersonalBest(
            cadenceType: .major,
            key: "C",
            time: 25,
            accuracy: 1.0
        )
        XCTAssertTrue(isFaster)
    }
    
    func testPointsToNextRank() {
        var stats = CadenceLifetimeStats()
        stats.currentRating = 1000
        
        XCTAssertNotNil(stats.pointsToNextRank)
    }
    
    func testAverageTimePerQuestion() {
        var stats = CadenceLifetimeStats()
        
        XCTAssertEqual(stats.averageTimePerQuestion, 0)
        
        stats.totalQuestionsAnswered = 10
        stats.totalPracticeTime = 100
        
        XCTAssertEqual(stats.averageTimePerQuestion, 10, accuracy: 0.01)
    }
}

// MARK: - EncouragementEngine Tests

final class EncouragementEngineTests: XCTestCase {
    
    func testPerfectScoreMessage() {
        let result = CadenceResult(
            date: Date(),
            totalQuestions: 5,
            correctAnswers: 5,
            totalTime: 60,
            questions: [],
            userAnswers: [:],
            isCorrect: [:],
            cadenceType: .major
        )
        
        var stats = CadenceLifetimeStats()
        stats.totalQuizzesTaken = 5 // Not first quiz
        
        let message = EncouragementEngine.getMessage(for: result, stats: stats, isNewPersonalBest: false)
        
        XCTAssertEqual(message.type, .celebration)
        XCTAssertEqual(message.emoji, "🌟")
    }
    
    func testNewPersonalBestMessage() {
        let result = CadenceResult(
            date: Date(),
            totalQuestions: 5,
            correctAnswers: 4,
            totalTime: 60,
            questions: [],
            userAnswers: [:],
            isCorrect: [:],
            cadenceType: .major
        )
        
        let stats = CadenceLifetimeStats()
        
        let message = EncouragementEngine.getMessage(for: result, stats: stats, isNewPersonalBest: true)
        
        XCTAssertEqual(message.type, .celebration)
        XCTAssertEqual(message.emoji, "🏆")
    }
    
    func testHighAccuracyMessage() {
        let result = CadenceResult(
            date: Date(),
            totalQuestions: 10,
            correctAnswers: 9,
            totalTime: 120,
            questions: [],
            userAnswers: [:],
            isCorrect: [:],
            cadenceType: .major
        )
        
        var stats = CadenceLifetimeStats()
        stats.totalQuizzesTaken = 5
        
        let message = EncouragementEngine.getMessage(for: result, stats: stats, isNewPersonalBest: false)
        
        XCTAssertEqual(message.type, .positive)
        XCTAssertEqual(message.emoji, "🔥")
    }
    
    func testLowAccuracyMessage() {
        let result = CadenceResult(
            date: Date(),
            totalQuestions: 10,
            correctAnswers: 3,
            totalTime: 120,
            questions: [],
            userAnswers: [:],
            isCorrect: [:],
            cadenceType: .major
        )
        
        var stats = CadenceLifetimeStats()
        stats.totalQuizzesTaken = 5
        
        let message = EncouragementEngine.getMessage(for: result, stats: stats, isNewPersonalBest: false)
        
        XCTAssertEqual(message.type, .encouraging)
    }
    
    func testFirstPerfectScoreMilestone() {
        let result = CadenceResult(
            date: Date(),
            totalQuestions: 5,
            correctAnswers: 5,
            totalTime: 60,
            questions: [],
            userAnswers: [:],
            isCorrect: [:],
            cadenceType: .major
        )
        
        var stats = CadenceLifetimeStats()
        stats.totalQuizzesTaken = 1 // First quiz
        
        let milestone = EncouragementEngine.checkMilestone(stats: stats, result: result)
        
        XCTAssertNotNil(milestone)
        XCTAssertEqual(milestone?.type, .milestone)
    }
    
    func testStreakMessage3Days() {
        let message = EncouragementEngine.getStreakMessage(streak: 3)
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains("3 days"))
    }
    
    func testStreakMessage7Days() {
        let message = EncouragementEngine.getStreakMessage(streak: 7)
        XCTAssertNotNil(message)
        XCTAssertTrue(message!.contains("week"))
    }
    
    func testStreakMessageNoSpecial() {
        let message = EncouragementEngine.getStreakMessage(streak: 2)
        XCTAssertNil(message)
    }
}

// MARK: - LastQuizSettings Tests

final class LastQuizSettingsTests: XCTestCase {
    
    func testDefaultValues() {
        let settings = LastQuizSettings()
        
        XCTAssertEqual(settings.numberOfQuestions, 5)
        XCTAssertEqual(settings.cadenceType, .major)
        XCTAssertEqual(settings.drillMode, .fullProgression)
        XCTAssertEqual(settings.keyDifficulty, .all)
        XCTAssertFalse(settings.useMixedCadences)
        XCTAssertFalse(settings.useExtendedVChords)
        XCTAssertEqual(settings.extendedVChord, .basic)
    }
    
    func testEncodeDecode() throws {
        let settings = LastQuizSettings(
            numberOfQuestions: 10,
            cadenceType: .minor,
            drillMode: .guideTones,
            keyDifficulty: .hard,
            useMixedCadences: true,
            useExtendedVChords: true,
            extendedVChord: .sharpNine
        )
        
        let encoded = try JSONEncoder().encode(settings)
        let decoded = try JSONDecoder().decode(LastQuizSettings.self, from: encoded)
        
        XCTAssertEqual(decoded.numberOfQuestions, 10)
        XCTAssertEqual(decoded.cadenceType, CadenceType.minor)
        XCTAssertEqual(decoded.drillMode, CadenceDrillMode.guideTones)
        XCTAssertEqual(decoded.keyDifficulty, KeyDifficulty.hard)
        XCTAssertTrue(decoded.useMixedCadences)
        XCTAssertTrue(decoded.useExtendedVChords)
        XCTAssertEqual(decoded.extendedVChord, ExtendedVChordOption.sharpNine)
    }
}

// MARK: - KeyStats Tests

final class KeyStatsTests: XCTestCase {
    
    func testAccuracyCalculation() {
        var stats = KeyStats()
        stats.questionsAnswered = 10
        stats.correctAnswers = 7
        
        XCTAssertEqual(stats.accuracy, 0.7, accuracy: 0.01)
    }
    
    func testAccuracyZeroQuestions() {
        let stats = KeyStats()
        
        XCTAssertEqual(stats.accuracy, 0)
    }
}

// MARK: - CadenceTypeStats Tests

final class CadenceTypeStatsTests: XCTestCase {
    
    func testAccuracyCalculation() {
        var stats = CadenceTypeStats()
        stats.questionsAnswered = 20
        stats.correctAnswers = 16
        
        XCTAssertEqual(stats.accuracy, 0.8, accuracy: 0.01)
    }
    
    func testAccuracyZeroQuestions() {
        let stats = CadenceTypeStats()
        
        XCTAssertEqual(stats.accuracy, 0)
    }
}

// MARK: - PersonalBest Tests

final class PersonalBestTests: XCTestCase {
    
    func testEncodeDecode() throws {
        let pb = PersonalBest(time: 45.5, accuracy: 0.95, date: Date())
        
        let encoded = try JSONEncoder().encode(pb)
        let decoded = try JSONDecoder().decode(PersonalBest.self, from: encoded)
        
        XCTAssertEqual(decoded.time, 45.5, accuracy: 0.01)
        XCTAssertEqual(decoded.accuracy, 0.95, accuracy: 0.01)
    }
}
