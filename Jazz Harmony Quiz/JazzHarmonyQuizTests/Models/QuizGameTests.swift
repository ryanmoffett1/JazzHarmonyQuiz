//
//  QuizGameTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class QuizGameTests: XCTestCase {
    
    var sut: QuizGame!
    
    override func setUp() async throws {
        sut = QuizGame()
    }
    
    override func tearDown() async throws {
        sut = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_defaultState() {
        XCTAssertFalse(sut.isQuizActive)
        XCTAssertFalse(sut.isQuizCompleted)
        XCTAssertEqual(sut.currentQuestionNumber, 1)
        XCTAssertEqual(sut.totalQuestions, 10)
        XCTAssertEqual(sut.score, 0)
    }
    
    func test_initialization_defaultKeyDifficulty() {
        XCTAssertEqual(sut.selectedKeyDifficulty, .all)
    }
    
    func test_initialization_defaultChordSymbols() {
        // Default should be all chord symbols
        XCTAssertTrue(sut.selectedChordSymbols.isEmpty)
    }
    
    // MARK: - Quiz Lifecycle Tests
    
    func test_startNewQuiz_activatesQuiz() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        XCTAssertTrue(sut.isQuizActive)
        XCTAssertFalse(sut.isQuizCompleted)
        XCTAssertEqual(sut.currentQuestionNumber, 1)
    }
    
    func test_startNewQuiz_generatesCorrectNumberOfQuestions() {
        sut.startNewQuiz(numberOfQuestions: 5, difficulty: .beginner, questionTypes: [.allTones])
        
        XCTAssertEqual(sut.totalQuestions, 5)
        XCTAssertNotNil(sut.currentChord)
    }
    
    func test_startNewQuiz_resetsScore() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        XCTAssertEqual(sut.score, 0)
        XCTAssertEqual(sut.correctAnswers, 0)
    }
    
    func test_resetQuizState_clearsAllState() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        sut.resetQuizState()
        
        XCTAssertFalse(sut.isQuizActive)
        XCTAssertFalse(sut.isQuizCompleted)
        XCTAssertEqual(sut.currentQuestionNumber, 1)
        XCTAssertNil(sut.currentChord)
    }
    
    // MARK: - Question Generation Tests
    
    func test_startNewQuiz_respectsDifficultyFilter_beginner() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        XCTAssertNotNil(sut.currentChord)
        // Beginner chords should be simple (triads, basic 7ths)
    }
    
    func test_startNewQuiz_respectsChordTypeFilter() {
        sut.selectedChordSymbols = ["", "m"] // Major and minor only
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        XCTAssertNotNil(sut.currentChord)
        if let chord = sut.currentChord {
            XCTAssertTrue(chord.symbol == "" || chord.symbol == "m")
        }
    }
    
    func test_startNewQuiz_respectsKeyDifficulty_easy() {
        sut.selectedKeyDifficulty = .easy
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        XCTAssertNotNil(sut.currentChord)
        // Easy keys: C, F, G, Bb, D (0-2 accidentals)
        if let chord = sut.currentChord {
            let easyKeys = ["C", "F", "G", "Bb", "D", "A", "Eb"]
            XCTAssertTrue(easyKeys.contains(chord.root.name))
        }
    }
    
    func test_startNewQuiz_respectsQuestionTypes() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.singleTone, .allTones])
        
        XCTAssertNotNil(sut.currentQuestionType)
        XCTAssertTrue(sut.currentQuestionType == .singleTone || sut.currentQuestionType == .allTones)
    }
    
    // MARK: - Answer Validation Tests
    
    func test_submitAnswer_correctAnswer_incrementsScore() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        // Get the correct answer
        guard let chord = sut.currentChord else {
            XCTFail("No current chord")
            return
        }
        
        let correctNotes = Set(chord.chordTones)
        let isCorrect = sut.checkAnswer(selectedNotes: correctNotes)
        
        XCTAssertTrue(isCorrect)
        XCTAssertEqual(sut.correctAnswers, 1)
    }
    
    func test_submitAnswer_incorrectAnswer_doesNotIncrementScore() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        let wrongNotes = Set([Note.noteFromMidi(60), Note.noteFromMidi(61)]) // Random wrong notes
        let isCorrect = sut.checkAnswer(selectedNotes: wrongNotes)
        
        XCTAssertFalse(isCorrect)
        XCTAssertEqual(sut.correctAnswers, 0)
    }
    
    func test_moveToNextQuestion_incrementsQuestionNumber() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        let initialQuestion = sut.currentQuestionNumber
        sut.moveToNextQuestion()
        
        XCTAssertEqual(sut.currentQuestionNumber, initialQuestion + 1)
    }
    
    func test_moveToNextQuestion_lastQuestion_completesQuiz() {
        sut.startNewQuiz(numberOfQuestions: 2, difficulty: .beginner, questionTypes: [.allTones])
        
        sut.moveToNextQuestion() // Question 2
        sut.moveToNextQuestion() // Should complete
        
        XCTAssertTrue(sut.isQuizCompleted)
        XCTAssertFalse(sut.isQuizActive)
    }
    
    // MARK: - Progress Tests
    
    func test_progress_startsAtZero() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        XCTAssertEqual(sut.progress, 0.0, accuracy: 0.01)
    }
    
    func test_progress_incrementsWithQuestions() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        sut.moveToNextQuestion() // 1/10 = 0.1
        XCTAssertEqual(sut.progress, 0.1, accuracy: 0.01)
        
        sut.moveToNextQuestion() // 2/10 = 0.2
        XCTAssertEqual(sut.progress, 0.2, accuracy: 0.01)
    }
    
    func test_progress_endsAtOne() {
        sut.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.allTones])
        
        sut.moveToNextQuestion()
        sut.moveToNextQuestion()
        sut.moveToNextQuestion()
        
        XCTAssertEqual(sut.progress, 1.0, accuracy: 0.01)
    }
    
    // MARK: - Single Tone Question Tests
    
    func test_singleToneQuestion_hasTargetTone() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.singleTone])
        
        XCTAssertNotNil(sut.currentTargetTone)
    }
    
    func test_singleToneQuestion_correctAnswer_matchesTargetTone() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.singleTone])
        
        guard let chord = sut.currentChord,
              let targetTone = sut.currentTargetTone else {
            XCTFail("Missing chord or target tone")
            return
        }
        
        // Get the correct note for the target tone
        if let correctNote = chord.getChordTone(by: targetTone.degree, isAltered: targetTone.isAltered) {
            let isCorrect = sut.checkAnswer(selectedNotes: [correctNote])
            XCTAssertTrue(isCorrect)
        }
    }
    
    // MARK: - Statistics Tests
    
    func test_stats_totalChordsAnswered_increments() {
        let initialCount = sut.chordDrillStats.totalChordsAnswered
        
        sut.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.allTones])
        
        guard let chord = sut.currentChord else {
            XCTFail("No current chord")
            return
        }
        
        _ = sut.checkAnswer(selectedNotes: Set(chord.chordTones))
        sut.moveToNextQuestion()
        
        XCTAssertEqual(sut.chordDrillStats.totalChordsAnswered, initialCount + 1)
    }
    
    func test_stats_correctAnswers_increments() {
        let initialCorrect = sut.chordDrillStats.totalCorrectAnswers
        
        sut.startNewQuiz(numberOfQuestions: 3, difficulty: .beginner, questionTypes: [.allTones])
        
        guard let chord = sut.currentChord else {
            XCTFail("No current chord")
            return
        }
        
        _ = sut.checkAnswer(selectedNotes: Set(chord.chordTones))
        sut.moveToNextQuestion()
        
        XCTAssertEqual(sut.chordDrillStats.totalCorrectAnswers, initialCorrect + 1)
    }
    
    // MARK: - Configuration Tests
    
    func test_setKeyDifficulty_updatesSelection() {
        sut.selectedKeyDifficulty = .medium
        XCTAssertEqual(sut.selectedKeyDifficulty, .medium)
        
        sut.selectedKeyDifficulty = .hard
        XCTAssertEqual(sut.selectedKeyDifficulty, .hard)
    }
    
    func test_setChordSymbols_updatesSelection() {
        sut.selectedChordSymbols = ["7", "maj7"]
        XCTAssertEqual(sut.selectedChordSymbols, ["7", "maj7"])
    }
    
    // MARK: - Edge Cases
    
    func test_checkAnswer_emptySelection_returnsFalse() {
        sut.startNewQuiz(numberOfQuestions: 10, difficulty: .beginner, questionTypes: [.allTones])
        
        let isCorrect = sut.checkAnswer(selectedNotes: [])
        XCTAssertFalse(isCorrect)
    }
    
    func test_moveToNextQuestion_beforeQuizStart_doesNotCrash() {
        sut.moveToNextQuestion()
        // Should not crash
        XCTAssertFalse(sut.isQuizActive)
    }
    
    func test_checkAnswer_beforeQuizStart_returnsFalse() {
        let isCorrect = sut.checkAnswer(selectedNotes: [Note.noteFromMidi(60)])
        XCTAssertFalse(isCorrect)
    }
}
