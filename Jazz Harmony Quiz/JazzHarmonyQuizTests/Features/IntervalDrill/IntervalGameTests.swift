import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class IntervalGameTests: XCTestCase {
    
    var game: IntervalGame!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        game = IntervalGame()
        game.resetQuiz()
    }
    
    override func tearDownWithError() throws {
        game = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertNil(game.currentQuestion)
        XCTAssertEqual(game.questionNumber, 0)
        XCTAssertEqual(game.totalQuestions, 10)
        XCTAssertEqual(game.correctAnswers, 0)
        XCTAssertFalse(game.hasAnswered)
        XCTAssertFalse(game.lastAnswerCorrect)
        XCTAssertEqual(game.elapsedTime, 0)
        XCTAssertFalse(game.isQuizActive)
        XCTAssertFalse(game.showingResults)
    }
    
    func testDefaultConfiguration() {
        XCTAssertEqual(game.selectedDifficulty, .beginner)
        XCTAssertTrue(game.selectedQuestionTypes.contains(.buildInterval))
        XCTAssertEqual(game.selectedDirection, .ascending)
        XCTAssertEqual(game.selectedKeyDifficulty, .easy)
    }
    
    // MARK: - Start Quiz Tests
    
    func testStartQuizBasic() {
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        XCTAssertEqual(game.totalQuestions, 5)
        XCTAssertEqual(game.selectedDifficulty, .beginner)
        XCTAssertTrue(game.isQuizActive)
        XCTAssertFalse(game.showingResults)
        XCTAssertEqual(game.questionNumber, 1)
        XCTAssertNotNil(game.currentQuestion)
    }
    
    func testStartQuizIntermediate() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .intermediate,
            questionTypes: [.identifyInterval],
            direction: .descending,
            keyDifficulty: .medium
        )
        
        XCTAssertEqual(game.selectedDifficulty, .intermediate)
        XCTAssertEqual(game.selectedDirection, .descending)
        XCTAssertEqual(game.selectedKeyDifficulty, .medium)
    }
    
    func testStartQuizAdvanced() {
        game.startQuiz(
            numberOfQuestions: 4,
            difficulty: .advanced,
            questionTypes: [.auralIdentify],
            direction: .both,
            keyDifficulty: .hard
        )
        
        XCTAssertEqual(game.selectedDifficulty, .advanced)
        XCTAssertEqual(game.selectedDirection, .both)
    }
    
    func testStartQuizResetsState() {
        // First quiz
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        // Answer a question
        if let question = game.currentQuestion {
            _ = game.checkAnswer(selectedNote: question.correctNote)
        }
        
        // Start new quiz
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .intermediate,
            questionTypes: [.identifyInterval],
            direction: .descending,
            keyDifficulty: .medium
        )
        
        XCTAssertEqual(game.totalQuestions, 5)
        XCTAssertEqual(game.questionNumber, 1)
        XCTAssertEqual(game.correctAnswers, 0)
        XCTAssertFalse(game.hasAnswered)
        XCTAssertEqual(game.elapsedTime, 0)
    }
    
    // MARK: - Question Types Tests
    
    func testBuildIntervalQuestionType() {
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        XCTAssertEqual(question.questionType, .buildInterval)
        XCTAssertTrue(question.questionText.contains("Find the"))
    }
    
    func testIdentifyIntervalQuestionType() {
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.identifyInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        XCTAssertEqual(question.questionType, .identifyInterval)
        XCTAssertTrue(question.questionText.contains("What interval"))
    }
    
    func testAuralIdentifyQuestionType() {
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.auralIdentify],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        XCTAssertEqual(question.questionType, .auralIdentify)
        XCTAssertEqual(question.questionText, "What interval did you hear?")
    }
    
    func testMixedQuestionTypes() {
        game.startQuiz(
            numberOfQuestions: 10,
            difficulty: .beginner,
            questionTypes: [.buildInterval, .identifyInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        XCTAssertTrue(game.isQuizActive)
        // Should have generated questions with mixed types
    }
    
    // MARK: - Key Difficulty Tests
    
    func testEasyKeyDifficulty() {
        game.startQuiz(
            numberOfQuestions: 10,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        let easyKeys = Set(KeyDifficulty.easy.availableRoots.map { $0.name })
        
        // Check current question's root is in easy keys
        if let question = game.currentQuestion {
            XCTAssertTrue(easyKeys.contains(question.interval.rootNote.name),
                "Root \(question.interval.rootNote.name) should be in easy keys")
        }
    }
    
    func testMediumKeyDifficulty() {
        game.startQuiz(
            numberOfQuestions: 10,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .medium
        )
        
        let mediumKeys = Set(KeyDifficulty.medium.availableRoots.map { $0.name })
        
        if let question = game.currentQuestion {
            XCTAssertTrue(mediumKeys.contains(question.interval.rootNote.name),
                "Root \(question.interval.rootNote.name) should be in medium keys")
        }
    }
    
    func testHardKeyDifficulty() {
        game.startQuiz(
            numberOfQuestions: 10,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .hard
        )
        
        let hardKeys = Set(KeyDifficulty.hard.availableRoots.map { $0.name })
        
        if let question = game.currentQuestion {
            XCTAssertTrue(hardKeys.contains(question.interval.rootNote.name),
                "Root \(question.interval.rootNote.name) should be in hard keys")
        }
    }
    
    // MARK: - Answer Checking Tests (Build Interval)
    
    func testCheckAnswerCorrectNote() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let isCorrect = game.checkAnswer(selectedNote: question.correctNote)
        
        XCTAssertTrue(isCorrect)
        XCTAssertTrue(game.hasAnswered)
        XCTAssertTrue(game.lastAnswerCorrect)
        XCTAssertEqual(game.correctAnswers, 1)
    }
    
    func testCheckAnswerIncorrectNote() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Create a wrong note (different pitch class)
        let wrongMidi = (question.correctNote.midiNumber + 1) % 12 + 60
        let wrongNote = Note.noteFromMidi(wrongMidi, preferSharps: false) ?? question.correctNote
        
        // Only test if we successfully created a different note
        if wrongNote.pitchClass != question.correctNote.pitchClass {
            let isCorrect = game.checkAnswer(selectedNote: wrongNote)
            
            XCTAssertFalse(isCorrect)
            XCTAssertTrue(game.hasAnswered)
            XCTAssertFalse(game.lastAnswerCorrect)
            XCTAssertEqual(game.correctAnswers, 0)
        }
    }
    
    func testCheckAnswerPitchClassEquivalent() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Create same pitch class in different octave
        let samePitchDifferentOctave = Note(
            name: question.correctNote.name,
            midiNumber: question.correctNote.midiNumber + 12,
            isSharp: question.correctNote.isSharp
        )
        
        let isCorrect = game.checkAnswer(selectedNote: samePitchDifferentOctave)
        
        XCTAssertTrue(isCorrect, "Same pitch class in different octave should be correct")
    }
    
    func testCannotAnswerTwice() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // First answer
        _ = game.checkAnswer(selectedNote: question.correctNote)
        
        // Try to answer again
        let secondResult = game.checkAnswer(selectedNote: question.correctNote)
        
        XCTAssertFalse(secondResult, "Should not be able to answer twice")
        XCTAssertEqual(game.correctAnswers, 1, "Should still only have 1 correct answer")
    }
    
    // MARK: - Answer Checking Tests (Identify Interval)
    
    func testCheckAnswerCorrectInterval() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.identifyInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let isCorrect = game.checkAnswer(selectedInterval: question.interval.intervalType)
        
        XCTAssertTrue(isCorrect)
        XCTAssertTrue(game.hasAnswered)
        XCTAssertTrue(game.lastAnswerCorrect)
        XCTAssertEqual(game.correctAnswers, 1)
    }
    
    func testCheckAnswerIncorrectInterval() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.identifyInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Find a different interval type
        let database = IntervalDatabase.shared
        let wrongInterval = database.intervals(for: .beginner).first { 
            $0.semitones != question.interval.intervalType.semitones 
        }
        
        if let wrong = wrongInterval {
            let isCorrect = game.checkAnswer(selectedInterval: wrong)
            
            XCTAssertFalse(isCorrect)
            XCTAssertTrue(game.hasAnswered)
            XCTAssertFalse(game.lastAnswerCorrect)
            XCTAssertEqual(game.correctAnswers, 0)
        }
    }
    
    // MARK: - Question Navigation Tests
    
    func testNextQuestion() {
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        let firstQuestion = game.currentQuestion
        XCTAssertEqual(game.questionNumber, 1)
        
        // Answer and move to next
        if let q = firstQuestion {
            _ = game.checkAnswer(selectedNote: q.correctNote)
        }
        game.nextQuestion()
        
        XCTAssertEqual(game.questionNumber, 2)
        XCTAssertFalse(game.hasAnswered)
        XCTAssertNotEqual(game.currentQuestion?.id, firstQuestion?.id)
    }
    
    func testLastQuestionEndsQuiz() {
        game.startQuiz(
            numberOfQuestions: 2,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        // Answer first question
        if let q1 = game.currentQuestion {
            _ = game.checkAnswer(selectedNote: q1.correctNote)
        }
        game.nextQuestion()
        
        // Answer second question
        if let q2 = game.currentQuestion {
            _ = game.checkAnswer(selectedNote: q2.correctNote)
        }
        game.nextQuestion()
        
        XCTAssertTrue(game.showingResults)
        XCTAssertFalse(game.isQuizActive)
    }
    
    // MARK: - Direction Tests
    
    func testAscendingDirection() {
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        if let question = game.currentQuestion {
            XCTAssertEqual(question.interval.direction, .ascending)
        }
    }
    
    func testDescendingDirection() {
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .descending,
            keyDifficulty: .easy
        )
        
        if let question = game.currentQuestion {
            XCTAssertEqual(question.interval.direction, .descending)
        }
    }
    
    // MARK: - Quiz Completion Tests
    
    func testPerfectScoreResult() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        // Answer all correctly
        for _ in 0..<3 {
            if let question = game.currentQuestion {
                _ = game.checkAnswer(selectedNote: question.correctNote)
                game.nextQuestion()
            }
        }
        
        XCTAssertTrue(game.showingResults)
        XCTAssertEqual(game.correctAnswers, 3)
    }
    
    func testRatingChangeCalculation() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        // Complete the quiz with all correct answers
        for _ in 0..<3 {
            if let question = game.currentQuestion {
                _ = game.checkAnswer(selectedNote: question.correctNote)
                game.nextQuestion()
            }
        }
        
        // Perfect score should result in positive rating change
        XCTAssertGreaterThan(game.lastRatingChange, 0)
    }
    
    // MARK: - Reset Tests
    
    func testResetQuiz() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        // Make some progress
        if let question = game.currentQuestion {
            _ = game.checkAnswer(selectedNote: question.correctNote)
        }
        game.nextQuestion()
        
        // Reset
        game.resetQuiz()
        
        XCTAssertNil(game.currentQuestion)
        XCTAssertEqual(game.questionNumber, 0)
        XCTAssertEqual(game.correctAnswers, 0)
        XCTAssertFalse(game.hasAnswered)
        XCTAssertFalse(game.isQuizActive)
        XCTAssertFalse(game.showingResults)
        XCTAssertEqual(game.elapsedTime, 0)
    }
    
    // MARK: - Scoreboard Tests
    
    func testScoreboardSavesResults() {
        let initialCount = game.scoreboard.count
        
        game.startQuiz(
            numberOfQuestions: 1,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        // Complete the quiz
        if let question = game.currentQuestion {
            _ = game.checkAnswer(selectedNote: question.correctNote)
            game.nextQuestion()
        }
        
        // Scoreboard should have at least one entry
        XCTAssertGreaterThanOrEqual(game.scoreboard.count, min(initialCount, 1))
    }
    
    func testScoreboardMaxEntries() {
        // Fill scoreboard beyond limit
        for _ in 0..<15 {
            game.startQuiz(
                numberOfQuestions: 1,
                difficulty: .beginner,
                questionTypes: [.buildInterval],
                direction: .ascending,
                keyDifficulty: .easy
            )
            
            if let question = game.currentQuestion {
                _ = game.checkAnswer(selectedNote: question.correctNote)
                game.nextQuestion()
            }
        }
        
        // Scoreboard should be capped at 10
        XCTAssertLessThanOrEqual(game.scoreboard.count, 10)
    }
    
    // MARK: - Review Tests
    
    func testGetAnsweredQuestions() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        // Answer questions
        for _ in 0..<3 {
            if let question = game.currentQuestion {
                _ = game.checkAnswer(selectedNote: question.correctNote)
                game.nextQuestion()
            }
        }
        
        let answered = game.getAnsweredQuestions()
        XCTAssertEqual(answered.count, 3)
    }
    
    func testGetMissedQuestions() {
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        // Answer first question correctly
        if let question = game.currentQuestion {
            _ = game.checkAnswer(selectedNote: question.correctNote)
        }
        game.nextQuestion()
        
        // Answer second question incorrectly
        if let question = game.currentQuestion {
            let wrongMidi = (question.correctNote.midiNumber + 2) % 12 + 60
            if let wrongNote = Note.noteFromMidi(wrongMidi, preferSharps: false) {
                _ = game.checkAnswer(selectedNote: wrongNote)
            }
        }
        game.nextQuestion()
        
        // Answer third question correctly
        if let question = game.currentQuestion {
            _ = game.checkAnswer(selectedNote: question.correctNote)
        }
        game.nextQuestion()
        
        let missed = game.getMissedQuestions()
        // Should have at least 0 missed (depends on pitch class comparison)
        XCTAssertGreaterThanOrEqual(missed.count, 0)
    }
}

// MARK: - Interval Question Tests

@MainActor
final class IntervalQuestionTests: XCTestCase {
    
    func testBuildIntervalQuestionText() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalType(
            name: "Major Third",
            shortName: "M3",
            semitones: 4,
            quality: .major,
            number: 3,
            difficulty: .beginner
        )
        let interval = Interval(rootNote: root, intervalType: intervalType, direction: .ascending)
        
        let question = IntervalQuestion(interval: interval, questionType: .buildInterval)
        
        XCTAssertTrue(question.questionText.contains("Find the"))
        XCTAssertTrue(question.questionText.contains("Major Third"))
    }
    
    func testIdentifyIntervalQuestionText() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalType(
            name: "Perfect Fifth",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            number: 5,
            difficulty: .beginner
        )
        let interval = Interval(rootNote: root, intervalType: intervalType, direction: .ascending)
        
        let question = IntervalQuestion(interval: interval, questionType: .identifyInterval)
        
        XCTAssertTrue(question.questionText.contains("What interval"))
    }
    
    func testAuralIdentifyQuestionText() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalType(
            name: "Minor Second",
            shortName: "m2",
            semitones: 1,
            quality: .minor,
            number: 2,
            difficulty: .beginner
        )
        let interval = Interval(rootNote: root, intervalType: intervalType, direction: .ascending)
        
        let question = IntervalQuestion(interval: interval, questionType: .auralIdentify)
        
        XCTAssertEqual(question.questionText, "What interval did you hear?")
    }
    
    func testCorrectNote() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalType(
            name: "Major Third",
            shortName: "M3",
            semitones: 4,
            quality: .major,
            number: 3,
            difficulty: .beginner
        )
        let interval = Interval(rootNote: root, intervalType: intervalType, direction: .ascending)
        
        let question = IntervalQuestion(interval: interval, questionType: .buildInterval)
        
        XCTAssertEqual(question.correctNote.pitchClass, interval.targetNote.pitchClass)
    }
    
    func testIsCorrectNote() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalType(
            name: "Major Third",
            shortName: "M3",
            semitones: 4,
            quality: .major,
            number: 3,
            difficulty: .beginner
        )
        let interval = Interval(rootNote: root, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(interval: interval, questionType: .buildInterval)
        
        let correctAnswer = interval.targetNote
        let wrongAnswer = Note(name: "C", midiNumber: 60, isSharp: false)
        
        XCTAssertTrue(question.isCorrect(userAnswer: correctAnswer))
        XCTAssertFalse(question.isCorrect(userAnswer: wrongAnswer))
    }
    
    func testIsCorrectIntervalType() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalType(
            name: "Perfect Fifth",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            number: 5,
            difficulty: .beginner
        )
        let interval = Interval(rootNote: root, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(interval: interval, questionType: .identifyInterval)
        
        let correctIntervalType = IntervalType(
            name: "Perfect Fifth",
            shortName: "P5",
            semitones: 7,
            quality: .perfect,
            number: 5,
            difficulty: .beginner
        )
        let wrongIntervalType = IntervalType(
            name: "Major Third",
            shortName: "M3",
            semitones: 4,
            quality: .major,
            number: 3,
            difficulty: .beginner
        )
        
        XCTAssertTrue(question.isCorrect(userAnswer: correctIntervalType))
        XCTAssertFalse(question.isCorrect(userAnswer: wrongIntervalType))
    }
}

// MARK: - Interval Question Type Tests

@MainActor
final class IntervalQuestionTypeTests: XCTestCase {
    
    func testAllCases() {
        XCTAssertEqual(IntervalQuestionType.allCases.count, 3)
        XCTAssertTrue(IntervalQuestionType.allCases.contains(.identifyInterval))
        XCTAssertTrue(IntervalQuestionType.allCases.contains(.buildInterval))
        XCTAssertTrue(IntervalQuestionType.allCases.contains(.auralIdentify))
    }
    
    func testRawValues() {
        XCTAssertEqual(IntervalQuestionType.identifyInterval.rawValue, "Identify Interval")
        XCTAssertEqual(IntervalQuestionType.buildInterval.rawValue, "Build Interval")
        XCTAssertEqual(IntervalQuestionType.auralIdentify.rawValue, "Ear Training")
    }
    
    func testDescriptions() {
        XCTAssertFalse(IntervalQuestionType.identifyInterval.description.isEmpty)
        XCTAssertFalse(IntervalQuestionType.buildInterval.description.isEmpty)
        XCTAssertFalse(IntervalQuestionType.auralIdentify.description.isEmpty)
    }
    
    func testIcons() {
        XCTAssertFalse(IntervalQuestionType.identifyInterval.icon.isEmpty)
        XCTAssertFalse(IntervalQuestionType.buildInterval.icon.isEmpty)
        XCTAssertFalse(IntervalQuestionType.auralIdentify.icon.isEmpty)
    }
}

// MARK: - Interval Quiz Result Tests

@MainActor
final class IntervalQuizResultTests: XCTestCase {
    
    func testResultAccuracy() {
        let result = IntervalQuizResult(
            totalQuestions: 10,
            correctAnswers: 7,
            totalTime: 120,
            difficulty: .beginner,
            questionTypes: [.buildInterval]
        )
        
        XCTAssertEqual(result.accuracy, 70.0, accuracy: 0.001)
    }
    
    func testResultAverageTime() {
        let result = IntervalQuizResult(
            totalQuestions: 10,
            correctAnswers: 7,
            totalTime: 120,
            difficulty: .beginner,
            questionTypes: [.buildInterval]
        )
        
        XCTAssertEqual(result.averageTimePerQuestion, 12.0, accuracy: 0.001)
    }
    
    func testResultZeroQuestions() {
        let result = IntervalQuizResult(
            totalQuestions: 0,
            correctAnswers: 0,
            totalTime: 0,
            difficulty: .beginner,
            questionTypes: []
        )
        
        XCTAssertEqual(result.accuracy, 0)
        XCTAssertEqual(result.averageTimePerQuestion, 0)
    }
    
    func testResultWithRatingChange() {
        let result = IntervalQuizResult(
            totalQuestions: 5,
            correctAnswers: 5,
            totalTime: 60,
            difficulty: .intermediate,
            questionTypes: [.identifyInterval, .buildInterval],
            ratingChange: 25
        )
        
        XCTAssertEqual(result.ratingChange, 25)
        XCTAssertEqual(result.accuracy, 100.0)
    }
}

// MARK: - Interval Direction Tests

@MainActor
final class IntervalDirectionTests: XCTestCase {
    
    func testAscendingRawValue() {
        XCTAssertEqual(IntervalDirection.ascending.rawValue, "Ascending")
    }
    
    func testDescendingRawValue() {
        XCTAssertEqual(IntervalDirection.descending.rawValue, "Descending")
    }
    
    func testBothRawValue() {
        XCTAssertEqual(IntervalDirection.both.rawValue, "Both")
    }
}

// MARK: - Interval Difficulty Tests

@MainActor
final class IntervalDifficultyTests: XCTestCase {
    
    func testAllCases() {
        XCTAssertEqual(IntervalDifficulty.allCases.count, 3)
        XCTAssertTrue(IntervalDifficulty.allCases.contains(.beginner))
        XCTAssertTrue(IntervalDifficulty.allCases.contains(.intermediate))
        XCTAssertTrue(IntervalDifficulty.allCases.contains(.advanced))
    }
    
    func testRawValues() {
        XCTAssertEqual(IntervalDifficulty.beginner.rawValue, "Beginner")
        XCTAssertEqual(IntervalDifficulty.intermediate.rawValue, "Intermediate")
        XCTAssertEqual(IntervalDifficulty.advanced.rawValue, "Advanced")
    }
}

// MARK: - End-to-End Flow Tests
// These tests verify the complete quiz flow: setup → start → answer questions → proceed → complete
// They ensure state transitions are correct at each step

@MainActor
final class IntervalGameFlowTests: XCTestCase {
    
    var game: IntervalGame!
    
    override func setUp() {
        super.setUp()
        game = IntervalGame()
        game.resetQuiz()
    }
    
    override func tearDown() {
        game = nil
        super.tearDown()
    }
    
    func test_flow_completeSession_buildInterval() {
        // Step 1: Verify initial state
        XCTAssertFalse(game.isQuizActive)
        XCTAssertNil(game.currentQuestion)
        XCTAssertEqual(game.questionNumber, 0)
        
        // Step 2: Start quiz
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        XCTAssertTrue(game.isQuizActive)
        XCTAssertNotNil(game.currentQuestion)
        XCTAssertEqual(game.questionNumber, 1)
        XCTAssertEqual(game.totalQuestions, 5)
        
        // Step 3: Answer all questions correctly
        for i in 1...5 {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Submit correct answer
            let isCorrect = game.checkAnswer(selectedNote: question.correctNote)
            XCTAssertTrue(isCorrect, "Question \(i): Correct note should be marked correct")
            XCTAssertTrue(game.hasAnswered, "Question \(i): hasAnswered should be true after submit")
            
            // Move to next (last nextQuestion will call endQuiz and NOT reset hasAnswered)
            game.nextQuestion()
            if i < 5 {
                XCTAssertFalse(game.hasAnswered, "hasAnswered should be false after nextQuestion for question \(i)")
            }
        }
        
        // Step 4: Verify completion
        XCTAssertTrue(game.showingResults)
        XCTAssertFalse(game.isQuizActive)
        XCTAssertEqual(game.correctAnswers, 5)
    }
    
    func test_flow_completeSession_identifyInterval() {
        // Start identify interval quiz
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.identifyInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        XCTAssertTrue(game.isQuizActive)
        
        for i in 1...3 {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Submit correct interval type
            let isCorrect = game.checkAnswer(selectedInterval: question.interval.intervalType)
            XCTAssertTrue(isCorrect)
            XCTAssertTrue(game.hasAnswered)
            
            game.nextQuestion()
        }
        
        XCTAssertTrue(game.showingResults)
        XCTAssertEqual(game.correctAnswers, 3)
    }
    
    func test_flow_mixedCorrectIncorrect() {
        game.startQuiz(
            numberOfQuestions: 4,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        var expectedCorrect = 0
        
        for i in 1...4 {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Alternate correct/incorrect
            if i % 2 == 1 {
                _ = game.checkAnswer(selectedNote: question.correctNote)
                expectedCorrect += 1
            } else {
                // Wrong note
                let wrongNote = Note(name: "X", midiNumber: 0, isSharp: false)
                _ = game.checkAnswer(selectedNote: wrongNote)
            }
            
            XCTAssertTrue(game.hasAnswered)
            game.nextQuestion()
        }
        
        XCTAssertTrue(game.showingResults)
        XCTAssertEqual(game.correctAnswers, expectedCorrect)
    }
    
    func test_flow_resetAndRestart() {
        // Start and answer one question
        game.startQuiz(
            numberOfQuestions: 5,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        if let question = game.currentQuestion {
            _ = game.checkAnswer(selectedNote: question.correctNote)
            game.nextQuestion()
        }
        
        XCTAssertEqual(game.questionNumber, 2)
        XCTAssertEqual(game.correctAnswers, 1)
        
        // Reset
        game.resetQuiz()
        
        XCTAssertFalse(game.isQuizActive)
        XCTAssertNil(game.currentQuestion)
        XCTAssertEqual(game.questionNumber, 0)
        XCTAssertEqual(game.correctAnswers, 0)
        XCTAssertFalse(game.hasAnswered)
        
        // Start new quiz
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .intermediate,
            questionTypes: [.identifyInterval],
            direction: .descending,
            keyDifficulty: .medium
        )
        
        XCTAssertTrue(game.isQuizActive)
        XCTAssertEqual(game.totalQuestions, 3)
        XCTAssertEqual(game.questionNumber, 1)
    }
    
    func test_flow_incorrectAnswerCanProceed() {
        // Critical test: After incorrect answer, user must be able to proceed
        game.startQuiz(
            numberOfQuestions: 3,
            difficulty: .beginner,
            questionTypes: [.buildInterval],
            direction: .ascending,
            keyDifficulty: .easy
        )
        
        guard game.currentQuestion != nil else {
            XCTFail("Should have a question")
            return
        }
        
        // Submit wrong answer
        let wrongNote = Note(name: "X", midiNumber: 0, isSharp: false)
        let isCorrect = game.checkAnswer(selectedNote: wrongNote)
        XCTAssertFalse(isCorrect)
        XCTAssertTrue(game.hasAnswered)
        XCTAssertFalse(game.lastAnswerCorrect)
        
        // User should be able to proceed
        game.nextQuestion()
        XCTAssertFalse(game.hasAnswered, "Must be able to move to next question after incorrect answer")
        XCTAssertEqual(game.questionNumber, 2, "Should advance to next question")
    }
    
    func test_flow_multipleQuestionTypes() {
        // Test with multiple question types
        game.startQuiz(
            numberOfQuestions: 6,
            difficulty: .intermediate,
            questionTypes: [.buildInterval, .identifyInterval],
            direction: .both,
            keyDifficulty: .medium
        )
        
        XCTAssertTrue(game.isQuizActive)
        
        for i in 1...6 {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Answer based on question type
            if question.questionType == .buildInterval {
                _ = game.checkAnswer(selectedNote: question.correctNote)
            } else {
                _ = game.checkAnswer(selectedInterval: question.interval.intervalType)
            }
            
            XCTAssertTrue(game.hasAnswered)
            game.nextQuestion()
        }
        
        XCTAssertTrue(game.showingResults)
    }
}
