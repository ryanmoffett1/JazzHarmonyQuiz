//
//  ProgressionGameTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class ProgressionGameTests: XCTestCase {
    
    var sut: ProgressionGame!
    
    override func setUp() async throws {
        sut = ProgressionGame()
    }
    
    override func tearDown() async throws {
        sut = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_defaultState() {
        XCTAssertFalse(sut.isQuizActive)
        XCTAssertFalse(sut.isQuizCompleted)
        XCTAssertEqual(sut.currentQuestionIndex, 0)
        XCTAssertEqual(sut.totalQuestions, 10)
    }
    
    func test_initialization_defaultConfiguration() {
        XCTAssertEqual(sut.selectedCategory, .turnaround)
        XCTAssertEqual(sut.selectedDifficulty, .beginner)
        XCTAssertEqual(sut.selectedKeyDifficulty, .all)
        XCTAssertFalse(sut.useMixedCategories)
    }
    
    // MARK: - Quiz Lifecycle Tests
    
    func test_startNewQuiz_activatesQuiz() {
        sut.startNewQuiz(
            numberOfQuestions: 5,
            category: .cadences,
            difficulty: .beginner,
            keyDifficulty: .easy,
            useMixedCategories: false,
            selectedCategories: []
        )
        
        XCTAssertTrue(sut.isQuizActive)
        XCTAssertFalse(sut.isQuizCompleted)
    }
    
    func test_startNewQuiz_generatesQuestions() {
        sut.startNewQuiz(
            numberOfQuestions: 5,
            category: .cadences,
            difficulty: .beginner,
            keyDifficulty: .easy
        )
        
        XCTAssertEqual(sut.questions.count, 5)
        XCTAssertNotNil(sut.currentQuestion)
    }
    
    func test_startNewQuiz_resetsState() {
        sut.startNewQuiz(numberOfQuestions: 5, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        XCTAssertEqual(sut.currentQuestionIndex, 0)
        XCTAssertTrue(sut.userAnswers.isEmpty)
        XCTAssertNotNil(sut.questionStartTime)
    }
    
    func test_resetQuizState_clearsAllState() {
        sut.startNewQuiz(numberOfQuestions: 5, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        sut.resetQuizState()
        
        XCTAssertFalse(sut.isQuizActive)
        XCTAssertFalse(sut.isQuizCompleted)
        XCTAssertNil(sut.currentQuestion)
    }
    
    // MARK: - Question Generation Tests
    
    func test_generateQuestions_respectsCount() {
        sut.startNewQuiz(
            numberOfQuestions: 8,
            category: .turnaround,
            difficulty: .beginner,
            keyDifficulty: .easy
        )
        
        XCTAssertEqual(sut.questions.count, 8)
    }
    
    func test_generateQuestions_respectsCategory() {
        sut.startNewQuiz(
            numberOfQuestions: 5,
            category: .cadences,
            difficulty: .beginner,
            keyDifficulty: .easy
        )
        
        XCTAssertEqual(sut.selectedCategory, .cadences)
    }
    
    func test_generateQuestions_respectsDifficulty() {
        sut.startNewQuiz(
            numberOfQuestions: 5,
            category: .turnaround,
            difficulty: .intermediate,
            keyDifficulty: .easy
        )
        
        XCTAssertEqual(sut.selectedDifficulty, .intermediate)
    }
    
    func test_generateQuestions_respectsKeyDifficulty() {
        sut.startNewQuiz(
            numberOfQuestions: 5,
            category: .turnaround,
            difficulty: .beginner,
            keyDifficulty: .medium
        )
        
        XCTAssertEqual(sut.selectedKeyDifficulty, .medium)
    }
    
    func test_mixedCategories_usesMultipleCategories() {
        sut.startNewQuiz(
            numberOfQuestions: 10,
            category: .turnaround, // Ignored when useMixedCategories = true
            difficulty: .beginner,
            keyDifficulty: .easy,
            useMixedCategories: true,
            selectedCategories: [.cadences, .turnaround]
        )
        
        XCTAssertTrue(sut.useMixedCategories)
        XCTAssertEqual(sut.selectedCategories, [.cadences, .turnaround])
    }
    
    // MARK: - Question Navigation Tests
    
    func test_moveToNextQuestion_incrementsIndex() {
        sut.startNewQuiz(numberOfQuestions: 5, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        let initialIndex = sut.currentQuestionIndex
        sut.moveToNextQuestion()
        
        XCTAssertEqual(sut.currentQuestionIndex, initialIndex + 1)
    }
    
    func test_moveToNextQuestion_updatesCurrentQuestion() {
        sut.startNewQuiz(numberOfQuestions: 5, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        sut.moveToNextQuestion()
        
        XCTAssertNotNil(sut.currentQuestion)
        if sut.currentQuestionIndex < sut.questions.count {
            XCTAssertEqual(sut.currentQuestion?.id, sut.questions[sut.currentQuestionIndex].id)
        }
    }
    
    func test_moveToNextQuestion_lastQuestion_completesQuiz() {
        sut.startNewQuiz(numberOfQuestions: 2, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        sut.moveToNextQuestion() // Move to question 2
        sut.moveToNextQuestion() // Should complete quiz
        
        XCTAssertTrue(sut.isQuizCompleted)
        XCTAssertFalse(sut.isQuizActive)
    }
    
    // MARK: - Answer Validation Tests
    
    func test_checkAnswer_storesUserAnswer() {
        sut.startNewQuiz(numberOfQuestions: 5, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        guard let question = sut.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let userChords = [[Note.noteFromMidi(60)]]
        _ = sut.checkAnswer(userChords: userChords)
        
        XCTAssertNotNil(sut.userAnswers[question.id])
    }
    
    func test_checkAnswer_correctAnswer_returnsTrue() {
        sut.startNewQuiz(numberOfQuestions: 5, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        guard let question = sut.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Use the correct answer from the question
        let correctChords = question.correctAnswer
        let isCorrect = sut.checkAnswer(userChords: correctChords)
        
        XCTAssertTrue(isCorrect)
    }
    
    func test_checkAnswer_incorrectAnswer_returnsFalse() {
        sut.startNewQuiz(numberOfQuestions: 5, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        let wrongChords = [[Note.noteFromMidi(60), Note.noteFromMidi(64)]]
        let isCorrect = sut.checkAnswer(userChords: wrongChords)
        
        XCTAssertFalse(isCorrect)
    }
    
    // MARK: - Progress Tests
    
    func test_progress_startsAtZero() {
        sut.startNewQuiz(numberOfQuestions: 10, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        XCTAssertEqual(sut.progress, 0.0, accuracy: 0.01)
    }
    
    func test_progress_incrementsWithQuestions() {
        sut.startNewQuiz(numberOfQuestions: 10, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        sut.moveToNextQuestion()
        XCTAssertEqual(sut.progress, 0.1, accuracy: 0.01)
        
        sut.moveToNextQuestion()
        XCTAssertEqual(sut.progress, 0.2, accuracy: 0.01)
    }
    
    func test_currentQuestionNumber_startsAtOne() {
        sut.startNewQuiz(numberOfQuestions: 10, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        XCTAssertEqual(sut.currentQuestionNumber, 1)
    }
    
    func test_currentQuestionNumber_incrementsCorrectly() {
        sut.startNewQuiz(numberOfQuestions: 10, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        sut.moveToNextQuestion()
        XCTAssertEqual(sut.currentQuestionNumber, 2)
        
        sut.moveToNextQuestion()
        XCTAssertEqual(sut.currentQuestionNumber, 3)
    }
    
    // MARK: - Statistics Tests
    
    func test_lifetimeStats_initialization() {
        XCTAssertNotNil(sut.lifetimeStats)
    }
    
    func test_scoreboard_initialization() {
        XCTAssertNotNil(sut.scoreboard)
    }
    
    // MARK: - Configuration Tests
    
    func test_setCategory_updatesSelection() {
        sut.selectedCategory = .rhythmChanges
        XCTAssertEqual(sut.selectedCategory, .rhythmChanges)
    }
    
    func test_setDifficulty_updatesSelection() {
        sut.selectedDifficulty = .advanced
        XCTAssertEqual(sut.selectedDifficulty, .advanced)
    }
    
    func test_setKeyDifficulty_updatesSelection() {
        sut.selectedKeyDifficulty = .hard
        XCTAssertEqual(sut.selectedKeyDifficulty, .hard)
    }
    
    // MARK: - Edge Cases
    
    func test_startNewQuiz_withZeroQuestions_doesNotCrash() {
        sut.startNewQuiz(
            numberOfQuestions: 0,
            category: .cadences,
            difficulty: .beginner,
            keyDifficulty: .easy
        )
        
        XCTAssertEqual(sut.questions.count, 0)
    }
    
    func test_moveToNextQuestion_beforeQuizStart_doesNotCrash() {
        sut.moveToNextQuestion()
        
        XCTAssertFalse(sut.isQuizActive)
    }
    
    func test_checkAnswer_beforeQuizStart_returnsFalse() {
        let result = sut.checkAnswer(userChords: [[Note.noteFromMidi(60)]])
        
        XCTAssertFalse(result)
    }
    
    func test_checkAnswer_emptyChords_returnsFalse() {
        sut.startNewQuiz(numberOfQuestions: 5, category: .cadences, difficulty: .beginner, keyDifficulty: .easy)
        
        let result = sut.checkAnswer(userChords: [])
        
        XCTAssertFalse(result)
    }
}
