import XCTest
@testable import JazzHarmonyQuiz

final class QuizGameTests: XCTestCase {
    
    var quizGame: QuizGame!
    
    override func setUp() {
        super.setUp()
        quizGame = QuizGame()
    }
    
    override func tearDown() {
        quizGame = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testQuizGameInitialization() {
        XCTAssertNotNil(quizGame)
        XCTAssertFalse(quizGame.isQuizActive)
        XCTAssertFalse(quizGame.isQuizCompleted)
        XCTAssertNil(quizGame.currentQuestion)
        XCTAssertEqual(quizGame.currentQuestionIndex, 0)
        XCTAssertEqual(quizGame.totalQuestions, 10)
    }
    
    // MARK: - Quiz Start Tests
    
    func testStartNewQuiz() {
        quizGame.startNewQuiz(numberOfQuestions: 5, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertTrue(quizGame.isQuizActive)
        XCTAssertFalse(quizGame.isQuizCompleted)
        XCTAssertEqual(quizGame.totalQuestions, 5)
        XCTAssertEqual(quizGame.questions.count, 5)
        XCTAssertNotNil(quizGame.currentQuestion)
        XCTAssertEqual(quizGame.currentQuestionIndex, 0)
        XCTAssertTrue(quizGame.userAnswers.isEmpty)
    }
    
    func testStartNewQuizGeneratesCorrectNumberOfQuestions() {
        quizGame.startNewQuiz(numberOfQuestions: 7, difficulty: .intermediate, questionTypes: [.allTones])
        
        XCTAssertEqual(quizGame.questions.count, 7)
    }
    
    func testStartNewQuizResetsState() {
        // Start a quiz and answer some questions
        quizGame.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.singleTone])
        let firstQuestion = quizGame.currentQuestion!
        quizGame.submitAnswer([firstQuestion.correctAnswer[0]])
        
        // Start a new quiz
        quizGame.startNewQuiz(numberOfQuestions: 5, difficulty: .advanced, questionTypes: [.allTones])
        
        XCTAssertEqual(quizGame.currentQuestionIndex, 0)
        XCTAssertTrue(quizGame.userAnswers.isEmpty)
        XCTAssertEqual(quizGame.totalQuestions, 5)
        XCTAssertTrue(quizGame.isQuizActive)
        XCTAssertFalse(quizGame.isQuizCompleted)
    }
    
    // MARK: - Question Generation Tests
    
    func testQuestionGenerationWithSingleToneType() {
        quizGame.startNewQuiz(numberOfQuestions: 5, difficulty: .beginner, questionTypes: [.singleTone])
        
        for question in quizGame.questions {
            XCTAssertEqual(question.questionType, .singleTone)
            XCTAssertNotNil(question.targetTone)
            XCTAssertEqual(question.correctAnswer.count, 1)
        }
    }
    
    func testQuestionGenerationWithAllTonesType() {
        quizGame.startNewQuiz(numberOfQuestions: 5, difficulty: .beginner, questionTypes: [.allTones])
        
        for question in quizGame.questions {
            XCTAssertEqual(question.questionType, .allTones)
            XCTAssertNil(question.targetTone)
            XCTAssertGreaterThan(question.correctAnswer.count, 0)
        }
    }
    
    func testQuestionGenerationWithMixedTypes() {
        quizGame.startNewQuiz(numberOfQuestions: 10, difficulty: .intermediate, questionTypes: [.singleTone, .allTones, .chordSpelling])
        
        // Should have at least one of each type (probabilistically)
        let types = Set(quizGame.questions.map { $0.questionType })
        // With 10 questions and 3 types, we should get some variety
        XCTAssertGreaterThanOrEqual(types.count, 1)
    }
    
    func testQuestionGenerationRespectsChordDifficulty() {
        quizGame.startNewQuiz(numberOfQuestions: 5, difficulty: .expert, questionTypes: [.singleTone])
        
        for question in quizGame.questions {
            XCTAssertEqual(question.chord.chordType.difficulty, .expert)
        }
    }
    
    // MARK: - Answer Submission Tests
    
    func testSubmitAnswerAdvancesQuestion() {
        quizGame.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.singleTone])
        
        let firstQuestion = quizGame.currentQuestion!
        XCTAssertEqual(quizGame.currentQuestionIndex, 0)
        
        quizGame.submitAnswer([firstQuestion.correctAnswer[0]])
        
        XCTAssertEqual(quizGame.currentQuestionIndex, 1)
        XCTAssertNotEqual(quizGame.currentQuestion?.id, firstQuestion.id)
    }
    
    func testSubmitAnswerRecordsUserAnswer() {
        quizGame.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.singleTone])
        
        let firstQuestion = quizGame.currentQuestion!
        let testAnswer = [firstQuestion.correctAnswer[0]]
        
        quizGame.submitAnswer(testAnswer)
        
        XCTAssertEqual(quizGame.userAnswers[firstQuestion.id], testAnswer)
    }
    
    func testSubmitAnswerIncreasesTotalTime() {
        quizGame.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.singleTone])
        
        let firstQuestion = quizGame.currentQuestion!
        let initialTime = quizGame.totalQuizTime
        
        // Wait a bit to ensure time passes
        Thread.sleep(forTimeInterval: 0.1)
        
        quizGame.submitAnswer([firstQuestion.correctAnswer[0]])
        
        XCTAssertGreaterThan(quizGame.totalQuizTime, initialTime)
    }
    
    func testSubmitLastAnswerCompletesQuiz() {
        quizGame.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.singleTone])
        
        // Answer first question
        let firstQuestion = quizGame.currentQuestion!
        quizGame.submitAnswer([firstQuestion.correctAnswer[0]])
        
        // Answer second question
        let secondQuestion = quizGame.currentQuestion!
        quizGame.submitAnswer([secondQuestion.correctAnswer[0]])
        
        XCTAssertFalse(quizGame.isQuizActive)
        XCTAssertTrue(quizGame.isQuizCompleted)
        XCTAssertNotNil(quizGame.currentResult)
    }
    
    // MARK: - Answer Correctness Tests
    
    func testCorrectSingleToneAnswer() {
        quizGame.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.singleTone])
        
        let firstQuestion = quizGame.currentQuestion!
        quizGame.submitAnswer([firstQuestion.correctAnswer[0]])
        
        let secondQuestion = quizGame.currentQuestion!
        quizGame.submitAnswer([secondQuestion.correctAnswer[0]])
        
        XCTAssertNotNil(quizGame.currentResult)
        XCTAssertEqual(quizGame.currentResult?.correctAnswers, 2)
        XCTAssertEqual(quizGame.currentResult?.accuracy, 1.0)
        XCTAssertEqual(quizGame.currentResult?.score, 100)
    }
    
    func testIncorrectAnswer() {
        quizGame.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.singleTone])
        
        let firstQuestion = quizGame.currentQuestion!
        // Submit wrong answer (empty array)
        quizGame.submitAnswer([])
        
        let secondQuestion = quizGame.currentQuestion!
        quizGame.submitAnswer([secondQuestion.correctAnswer[0]])
        
        XCTAssertNotNil(quizGame.currentResult)
        XCTAssertEqual(quizGame.currentResult?.correctAnswers, 1)
        XCTAssertEqual(quizGame.currentResult?.accuracy, 0.5)
        XCTAssertEqual(quizGame.currentResult?.score, 50)
    }
    
    func testAnswerCorrectnessWithOctaveWrapping() {
        quizGame.startNewQuiz(numberOfQuestions: 1, difficulty: .beginner, questionTypes: [.singleTone])
        
        let question = quizGame.currentQuestion!
        let correctNote = question.correctAnswer[0]
        
        // Create a note with the same pitch class but different octave
        let octaveUpNote = Note(name: correctNote.name, midiNumber: correctNote.midiNumber + 12, isSharp: correctNote.isSharp)
        
        quizGame.submitAnswer([octaveUpNote])
        
        // Should be marked as correct since pitch classes match
        XCTAssertNotNil(quizGame.currentResult)
        XCTAssertEqual(quizGame.currentResult?.correctAnswers, 1)
    }
    
    // MARK: - Navigation Tests
    
    func testCanGoToNextQuestion() {
        quizGame.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertTrue(quizGame.canGoToNextQuestion())
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertTrue(quizGame.canGoToNextQuestion())
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertFalse(quizGame.canGoToNextQuestion())
    }
    
    func testCanGoToPreviousQuestion() {
        quizGame.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertFalse(quizGame.canGoToPreviousQuestion())
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertTrue(quizGame.canGoToPreviousQuestion())
    }
    
    func testGoToNextQuestion() {
        quizGame.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.singleTone])
        
        let firstQuestion = quizGame.currentQuestion!
        quizGame.goToNextQuestion()
        
        XCTAssertEqual(quizGame.currentQuestionIndex, 1)
        XCTAssertNotEqual(quizGame.currentQuestion?.id, firstQuestion.id)
    }
    
    func testGoToPreviousQuestion() {
        quizGame.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.singleTone])
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        
        let secondQuestion = quizGame.currentQuestion!
        quizGame.goToPreviousQuestion()
        
        XCTAssertEqual(quizGame.currentQuestionIndex, 0)
        XCTAssertNotEqual(quizGame.currentQuestion?.id, secondQuestion.id)
    }
    
    // MARK: - Progress Tracking Tests
    
    func testProgressCalculation() {
        quizGame.startNewQuiz(numberOfQuestions: 4, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertEqual(quizGame.progress, 0.0)
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertEqual(quizGame.progress, 0.25)
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertEqual(quizGame.progress, 0.5)
    }
    
    func testCurrentQuestionNumber() {
        quizGame.startNewQuiz(numberOfQuestions: 5, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertEqual(quizGame.currentQuestionNumber, 1)
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertEqual(quizGame.currentQuestionNumber, 2)
    }
    
    func testAnsweredQuestionsCount() {
        quizGame.startNewQuiz(numberOfQuestions: 5, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertEqual(quizGame.answeredQuestions, 0)
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertEqual(quizGame.answeredQuestions, 1)
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertEqual(quizGame.answeredQuestions, 2)
    }
    
    // MARK: - Statistics Tests
    
    func testCurrentScore() {
        quizGame.startNewQuiz(numberOfQuestions: 4, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertEqual(quizGame.currentScore, 0)
        
        // Correct answer
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertEqual(quizGame.currentScore, 25)
        
        // Wrong answer
        quizGame.submitAnswer([])
        XCTAssertEqual(quizGame.currentScore, 25)
        
        // Correct answer
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        XCTAssertEqual(quizGame.currentScore, 50)
    }
    
    func testAverageTimePerQuestion() {
        quizGame.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertEqual(quizGame.averageTimePerQuestion, 0)
        
        Thread.sleep(forTimeInterval: 0.1)
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        
        XCTAssertGreaterThan(quizGame.averageTimePerQuestion, 0)
    }
    
    // MARK: - Reset Tests
    
    func testResetQuizState() {
        quizGame.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.singleTone])
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        
        quizGame.resetQuizState()
        
        XCTAssertFalse(quizGame.isQuizCompleted)
        XCTAssertFalse(quizGame.isQuizActive)
        XCTAssertNil(quizGame.currentResult)
        XCTAssertNil(quizGame.currentQuestion)
        XCTAssertEqual(quizGame.currentQuestionIndex, 0)
        XCTAssertTrue(quizGame.userAnswers.isEmpty)
        XCTAssertEqual(quizGame.totalQuizTime, 0)
    }
    
    // MARK: - Leaderboard Tests
    
    func testLeaderboardInitialization() {
        XCTAssertNotNil(quizGame.leaderboard)
    }
    
    func testLeaderboardSavesResults() {
        let initialCount = quizGame.leaderboard.count
        
        quizGame.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.singleTone])
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        
        XCTAssertEqual(quizGame.leaderboard.count, initialCount + 1)
    }
    
    func testLeaderboardSorting() {
        // Clear leaderboard for test
        quizGame.leaderboard = []
        
        // Create two quiz results with different scores
        quizGame.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.singleTone])
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        quizGame.submitAnswer([]) // Wrong answer - 50% score
        
        quizGame.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.singleTone])
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]]) // 100% score
        
        // Leaderboard should be sorted with best score first
        XCTAssertGreaterThanOrEqual(quizGame.leaderboard.count, 2)
        XCTAssertGreaterThan(quizGame.leaderboard[0].accuracy, quizGame.leaderboard[1].accuracy)
    }
    
    func testLeaderboardMaxSize() {
        // Clear leaderboard
        quizGame.leaderboard = []
        
        // Add 15 results (should keep only top 10)
        for _ in 0..<15 {
            quizGame.startNewQuiz(numberOfQuestions: 1, difficulty: .beginner, questionTypes: [.singleTone])
            quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        }
        
        XCTAssertEqual(quizGame.leaderboard.count, 10)
    }
    
    // MARK: - Edge Cases Tests
    
    func testEmptyAnswerSubmission() {
        quizGame.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.singleTone])
        
        let initialIndex = quizGame.currentQuestionIndex
        quizGame.submitAnswer([])
        
        // Should still advance to next question
        XCTAssertEqual(quizGame.currentQuestionIndex, initialIndex + 1)
    }
    
    func testQuizCompletionWithAllWrongAnswers() {
        quizGame.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.singleTone])
        
        quizGame.submitAnswer([])
        quizGame.submitAnswer([])
        
        XCTAssertTrue(quizGame.isQuizCompleted)
        XCTAssertNotNil(quizGame.currentResult)
        XCTAssertEqual(quizGame.currentResult?.correctAnswers, 0)
        XCTAssertEqual(quizGame.currentResult?.score, 0)
    }
    
    func testSingleQuestionQuiz() {
        quizGame.startNewQuiz(numberOfQuestions: 1, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertEqual(quizGame.questions.count, 1)
        XCTAssertFalse(quizGame.canGoToNextQuestion())
        
        quizGame.submitAnswer([quizGame.currentQuestion!.correctAnswer[0]])
        
        XCTAssertTrue(quizGame.isQuizCompleted)
    }
    
    func testAllTonesQuestionCorrectness() {
        quizGame.startNewQuiz(numberOfQuestions: 1, difficulty: .beginner, questionTypes: [.allTones])
        
        let question = quizGame.currentQuestion!
        let correctAnswer = question.correctAnswer
        
        quizGame.submitAnswer(correctAnswer)
        
        XCTAssertNotNil(quizGame.currentResult)
        XCTAssertEqual(quizGame.currentResult?.correctAnswers, 1)
    }
    
    func testPartialAnswerForAllTones() {
        quizGame.startNewQuiz(numberOfQuestions: 1, difficulty: .beginner, questionTypes: [.allTones])
        
        let question = quizGame.currentQuestion!
        let correctAnswer = question.correctAnswer
        
        // Submit only partial answer
        let partialAnswer = Array(correctAnswer.prefix(correctAnswer.count - 1))
        quizGame.submitAnswer(partialAnswer)
        
        XCTAssertNotNil(quizGame.currentResult)
        XCTAssertEqual(quizGame.currentResult?.correctAnswers, 0)
    }
}
