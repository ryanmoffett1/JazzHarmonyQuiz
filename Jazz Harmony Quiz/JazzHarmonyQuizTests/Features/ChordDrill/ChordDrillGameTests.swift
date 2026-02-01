import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class ChordDrillGameTests: XCTestCase {
    
    var game: ChordDrillGame!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        game = ChordDrillGame()
    }
    
    override func tearDownWithError() throws {
        game = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState() {
        XCTAssertEqual(game.state, .setup)
        XCTAssertTrue(game.questions.isEmpty)
        XCTAssertEqual(game.currentIndex, 0)
        XCTAssertTrue(game.results.isEmpty)
        XCTAssertNil(game.session)
        XCTAssertNil(game.currentQuestion)
        XCTAssertFalse(game.showingFeedback)
    }
    
    func testDefaultConfig() {
        let config = ChordDrillConfig.default
        XCTAssertTrue(config.chordTypes.isEmpty)  // All types
        XCTAssertEqual(config.keyDifficulty, .all)
        XCTAssertEqual(config.questionCount, 10)
        XCTAssertTrue(config.audioEnabled)
    }
    
    // MARK: - Preset Configuration Tests
    
    func testBasicTriadsPreset() {
        let config = ChordDrillConfig.fromPreset(.basicTriads)
        XCTAssertEqual(Set(config.chordTypes), Set(["", "m", "dim", "aug", "sus2", "sus4"]))  // All triads
        XCTAssertEqual(config.keyDifficulty, .easy)
        XCTAssertEqual(config.difficulty, .beginner)
        XCTAssertEqual(config.questionCount, 10)
    }
    
    func testSeventhAndSixthChordsPreset() {
        let config = ChordDrillConfig.fromPreset(.seventhAndSixthChords)
        XCTAssertEqual(Set(config.chordTypes), Set(["7", "maj7", "m7", "m7b5", "dim7", "m(maj7)", "7#5", "maj6", "m6"]))  // All 7th/6th chords
        XCTAssertEqual(config.keyDifficulty, .medium)
        XCTAssertEqual(config.difficulty, .intermediate)  // Intermediate since it includes more advanced chords
    }
    
    func testFullWorkoutPreset() {
        let config = ChordDrillConfig.fromPreset(.fullWorkout)
        XCTAssertTrue(config.chordTypes.isEmpty)  // All types
        XCTAssertEqual(config.keyDifficulty, .all)
        XCTAssertEqual(config.difficulty, .advanced)
        XCTAssertEqual(config.questionCount, 15)
    }
    
    // MARK: - Preset Chord Type Validation Tests
    
    func testBasicTriadsPresetOnlyUsesExistingChordTypes() {
        // Verify that all chord symbols in the preset actually exist in the database
        let config = ChordDrillConfig.fromPreset(.basicTriads)
        let database = JazzChordDatabase.shared
        let availableSymbols = Set(database.chordTypes.map { $0.symbol })
        
        for symbol in config.chordTypes {
            XCTAssertTrue(availableSymbols.contains(symbol),
                         "Chord symbol '\(symbol)' from basicTriads preset doesn't exist in database")
        }
    }
    
    func testSeventhAndSixthChordsPresetOnlyUsesExistingChordTypes() {
        let config = ChordDrillConfig.fromPreset(.seventhAndSixthChords)
        let database = JazzChordDatabase.shared
        let availableSymbols = Set(database.chordTypes.map { $0.symbol })
        
        for symbol in config.chordTypes {
            XCTAssertTrue(availableSymbols.contains(symbol),
                         "Chord symbol '\(symbol)' from seventhAndSixthChords preset doesn't exist in database")
        }
    }
    
    func testSeventhAndSixthChordsPresetGeneratesCorrectChords() {
        // Start a drill with the 7th and 6th chords preset
        game.startDrill(preset: .seventhAndSixthChords)
        
        // Verify all generated questions use only the specified chord types
        let expectedSymbols = Set(["7", "maj7", "m7", "m7b5", "dim7", "m(maj7)", "7#5", "maj6", "m6"])
        for question in game.questions {
            XCTAssertTrue(expectedSymbols.contains(question.chord.chordType.symbol),
                         "Generated chord '\(question.chord.chordType.symbol)' not in 7th chords preset")
        }
    }
    
    // MARK: - Starting Drill Tests
    
    func testStartDrillWithConfig() {
        let config = ChordDrillConfig(
            chordTypes: ["", "m"],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 5,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        XCTAssertEqual(game.state, .active)
        XCTAssertEqual(game.questions.count, 5)
        XCTAssertEqual(game.currentIndex, 0)
        XCTAssertNotNil(game.currentQuestion)
        XCTAssertFalse(game.showingFeedback)
    }
    
    func testStartDrillWithPreset() {
        game.startDrill(preset: .basicTriads)
        
        XCTAssertEqual(game.state, .active)
        XCTAssertEqual(game.questions.count, 10)
        XCTAssertNotNil(game.currentQuestion)
    }
    
    func testQuestionsHaveCorrectTypes() {
        let config = ChordDrillConfig(
            chordTypes: ["m7"],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .intermediate,
            questionCount: 5,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        for question in game.questions {
            XCTAssertEqual(question.chord.chordType.symbol, "m7")
            XCTAssertEqual(question.questionType, .allTones)
        }
    }
    
    // MARK: - Progress Tracking Tests
    
    func testProgressCalculation() {
        game.startDrill(preset: .basicTriads)
        
        XCTAssertEqual(game.progress, 0.0, accuracy: 0.01)
        
        // Answer first question
        if let question = game.currentQuestion {
            game.submitAnswer(notes: question.correctAnswer)
            game.nextQuestion()
        }
        
        XCTAssertEqual(game.progress, 0.1, accuracy: 0.01)  // 1/10
    }
    
    func testIsLastQuestion() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 2,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        XCTAssertFalse(game.isLastQuestion)  // First question
        
        // Move to second question
        if let question = game.currentQuestion {
            game.submitAnswer(notes: question.correctAnswer)
            game.nextQuestion()
        }
        
        XCTAssertTrue(game.isLastQuestion)  // Second (last) question
    }
    
    // MARK: - Answer Submission Tests
    
    func testSubmitCorrectAnswer() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 3,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        // Submit correct answer
        game.submitAnswer(notes: question.correctAnswer)
        
        XCTAssertTrue(game.showingFeedback)
        XCTAssertTrue(game.lastAnswerCorrect)
        XCTAssertEqual(game.results.count, 1)
        XCTAssertTrue(game.results.first!.isCorrect)
    }
    
    func testSubmitIncorrectAnswer() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 3,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        // Submit wrong answer
        let wrongNotes: Set<Note> = [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "D", midiNumber: 62, isSharp: false),
            Note(name: "E", midiNumber: 64, isSharp: false)
        ]
        game.submitAnswer(notes: wrongNotes)
        
        XCTAssertTrue(game.showingFeedback)
        XCTAssertEqual(game.results.count, 1)
        // May or may not be correct depending on the random chord
        // Just verify state is updated
    }
    
    func testAccuracyCalculation() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 3,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        // Answer first correctly
        if let q1 = game.currentQuestion {
            game.submitAnswer(notes: q1.correctAnswer)
            game.nextQuestion()
        }
        
        // Answer second incorrectly
        game.submitAnswer(notes: [Note(name: "X", midiNumber: 50, isSharp: false)])
        game.nextQuestion()
        
        // Answer third correctly
        if let q3 = game.currentQuestion {
            game.submitAnswer(notes: q3.correctAnswer)
        }
        
        // 2 correct out of 3
        XCTAssertEqual(game.correctCount, 2)
        XCTAssertEqual(game.accuracy, 2.0/3.0, accuracy: 0.01)
    }
    
    // MARK: - Next Question Tests
    
    func testNextQuestionAdvancesIndex() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 5,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        XCTAssertEqual(game.currentIndex, 0)
        
        // Submit and advance
        if let question = game.currentQuestion {
            game.submitAnswer(notes: question.correctAnswer)
        }
        XCTAssertTrue(game.showingFeedback)
        
        game.nextQuestion()
        
        XCTAssertEqual(game.currentIndex, 1)
        XCTAssertFalse(game.showingFeedback)
    }
    
    func testNextQuestionOnLastFinishesDrill() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 2,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        // Answer first question
        if let q1 = game.currentQuestion {
            game.submitAnswer(notes: q1.correctAnswer)
            game.nextQuestion()
        }
        
        // Answer second (last) question
        if let q2 = game.currentQuestion {
            game.submitAnswer(notes: q2.correctAnswer)
            game.nextQuestion()
        }
        
        XCTAssertEqual(game.state, .results)
        XCTAssertNotNil(game.session)
    }
    
    // MARK: - Session Results Tests
    
    func testSessionCreatedOnFinish() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 2,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        // Complete all questions
        while let question = game.currentQuestion {
            game.submitAnswer(notes: question.correctAnswer)
            game.nextQuestion()
        }
        
        XCTAssertNotNil(game.session)
        let session = game.session!
        
        XCTAssertEqual(session.totalQuestions, 2)
        XCTAssertEqual(session.correctCount, 2)
        XCTAssertEqual(session.accuracy, 1.0, accuracy: 0.01)
        XCTAssertGreaterThan(session.duration, 0)
    }
    
    func testSessionContainsConfig() {
        let config = ChordDrillConfig(
            chordTypes: ["m7"],
            keyDifficulty: .medium,
            questionTypes: [.singleTone],
            difficulty: .intermediate,
            questionCount: 1,
            audioEnabled: false
        )
        
        game.startDrill(config: config)
        
        // Complete the single question
        if let question = game.currentQuestion {
            game.submitAnswer(notes: question.correctAnswer)
            game.nextQuestion()
        }
        
        XCTAssertEqual(game.session?.config, config)
    }
    
    func testMissedItemsTracked() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 2,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        // Answer first incorrectly
        game.submitAnswer(notes: [Note(name: "X", midiNumber: 50, isSharp: false)])
        game.nextQuestion()
        
        // Answer second correctly
        if let q2 = game.currentQuestion {
            game.submitAnswer(notes: q2.correctAnswer)
            game.nextQuestion()
        }
        
        let session = game.session!
        XCTAssertEqual(session.missedItems.count, 1)
    }
    
    // MARK: - Reset Tests
    
    func testReset() {
        game.startDrill(preset: .basicTriads)
        
        // Submit some answers
        if let question = game.currentQuestion {
            game.submitAnswer(notes: question.correctAnswer)
        }
        
        game.reset()
        
        XCTAssertEqual(game.state, .setup)
        XCTAssertTrue(game.questions.isEmpty)
        XCTAssertEqual(game.currentIndex, 0)
        XCTAssertTrue(game.results.isEmpty)
        XCTAssertNil(game.session)
        XCTAssertFalse(game.showingFeedback)
    }
    
    // MARK: - Quit Tests
    
    func testQuitWithResults() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 5,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        // Answer a few questions
        for _ in 0..<2 {
            if let question = game.currentQuestion {
                game.submitAnswer(notes: question.correctAnswer)
                game.nextQuestion()
            }
        }
        
        game.quit()
        
        // Should still create a session with partial results
        XCTAssertEqual(game.state, .results)
        XCTAssertNotNil(game.session)
        XCTAssertEqual(game.session?.totalQuestions, 2)
    }
    
    func testQuitWithoutResults() {
        game.startDrill(preset: .basicTriads)
        
        // Quit immediately without answering
        game.quit()
        
        XCTAssertEqual(game.state, .setup)
        XCTAssertNil(game.session)
    }
    
    // MARK: - Key Difficulty Tests
    
    func testEasyKeyDifficulty() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 20,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        let easyKeys = Set(["C", "F", "G", "Bb"])
        for question in game.questions {
            XCTAssertTrue(easyKeys.contains(question.chord.root.name),
                         "Expected easy key, got \(question.chord.root.name)")
        }
    }
    
    func testHardKeyDifficulty() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .hard,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 20,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        let hardKeys = Set(["Db", "F#", "Ab", "B", "E"])
        for question in game.questions {
            XCTAssertTrue(hardKeys.contains(question.chord.root.name),
                         "Expected hard key, got \(question.chord.root.name)")
        }
    }
    
    // MARK: - Question Type Tests
    
    func testSingleToneQuestions() {
        let config = ChordDrillConfig(
            chordTypes: ["7"],
            keyDifficulty: .easy,
            questionTypes: [.singleTone],
            difficulty: .intermediate,
            questionCount: 5,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        for question in game.questions {
            XCTAssertEqual(question.questionType, .singleTone)
            XCTAssertNotNil(question.targetTone)
            XCTAssertEqual(question.correctAnswer.count, 1)
        }
    }
    
    func testAllTonesQuestions() {
        let config = ChordDrillConfig(
            chordTypes: ["7"],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .intermediate,
            questionCount: 5,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        for question in game.questions {
            XCTAssertEqual(question.questionType, .allTones)
            XCTAssertNil(question.targetTone)
            XCTAssertEqual(question.correctAnswer.count, question.chord.chordTones.count)
        }
    }
    
    // MARK: - Answer Choices Tests (for Aural Questions)
    
    func testGetAnswerChoices() {
        let config = ChordDrillConfig(
            chordTypes: ["7", "maj7", "m7"],
            keyDifficulty: .easy,
            questionTypes: [.auralQuality],
            difficulty: .intermediate,
            questionCount: 1,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        guard let question = game.currentQuestion else {
            XCTFail("No current question")
            return
        }
        
        let choices = game.getAnswerChoices(for: question, count: 4)
        
        XCTAssertEqual(choices.count, 4)
        XCTAssertTrue(choices.contains { $0.id == question.chord.chordType.id },
                     "Choices should include correct answer")
    }
    
    // MARK: - DrillSessionResult Conversion Tests
    
    func testToDrillSessionResult() {
        let config = ChordDrillConfig(
            chordTypes: [""],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 2,
            audioEnabled: true
        )
        
        game.startDrill(config: config)
        
        // Complete all questions
        while let question = game.currentQuestion {
            game.submitAnswer(notes: question.correctAnswer)
            game.nextQuestion()
        }
        
        let drillResult = game.session!.toDrillSessionResult()
        
        XCTAssertEqual(drillResult.drillType, .chordDrill)
        XCTAssertEqual(drillResult.totalQuestions, 2)
        XCTAssertEqual(drillResult.correctAnswers, 2)
        XCTAssertEqual(drillResult.accuracy, 1.0, accuracy: 0.01)
    }
}

// MARK: - ChordDrillConfig Equatable Tests

final class ChordDrillConfigTests: XCTestCase {
    
    func testConfigEquality() {
        let config1 = ChordDrillConfig(
            chordTypes: ["7", "m7"],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 10,
            audioEnabled: true
        )
        
        let config2 = ChordDrillConfig(
            chordTypes: ["7", "m7"],
            keyDifficulty: .easy,
            questionTypes: [.allTones],
            difficulty: .beginner,
            questionCount: 10,
            audioEnabled: true
        )
        
        XCTAssertEqual(config1, config2)
    }
    
    func testConfigInequality() {
        let config1 = ChordDrillConfig.default
        let config2 = ChordDrillConfig.fromPreset(.basicTriads)
        
        XCTAssertNotEqual(config1, config2)
    }
}

// MARK: - ChordDrillQuestion Tests

final class ChordDrillQuestionTests: XCTestCase {
    
    func testAllTonesCorrectAnswer() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "" }!
        let chord = Chord(root: root, chordType: majorType)
        
        let question = ChordDrillQuestion(
            chord: chord,
            questionType: .allTones,
            targetTone: nil
        )
        
        // C major = C, E, G
        XCTAssertEqual(question.correctAnswer.count, chord.chordTones.count)
    }
    
    func testSingleToneCorrectAnswer() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let dom7Type = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "7" }!
        let chord = Chord(root: root, chordType: dom7Type)
        let thirdTone = dom7Type.chordTones.first { $0.degree == 3 }!
        
        let question = ChordDrillQuestion(
            chord: chord,
            questionType: .singleTone,
            targetTone: thirdTone
        )
        
        XCTAssertEqual(question.correctAnswer.count, 1)
        // The 3rd of C7 is E
        XCTAssertTrue(question.correctAnswer.contains { $0.midiNumber % 12 == 4 }) // E = 4 semitones from C
    }
    
    func testAuralQualityNoNotesAnswer() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "" }!
        let chord = Chord(root: root, chordType: majorType)
        
        let question = ChordDrillQuestion(
            chord: chord,
            questionType: .auralQuality,
            targetTone: nil
        )
        
        // Aural quality questions use ChordType, not notes
        XCTAssertTrue(question.correctAnswer.isEmpty)
    }
}

// MARK: - ChordAnswerResult Tests

final class ChordAnswerResultTests: XCTestCase {
    
    func testMissedNotes() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "" }!
        let chord = Chord(root: root, chordType: majorType)
        
        let question = ChordDrillQuestion(
            chord: chord,
            questionType: .allTones,
            targetTone: nil
        )
        
        // User only selected C and E, missing G
        let userNotes: Set<Note> = [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "E", midiNumber: 64, isSharp: false)
        ]
        
        let result = ChordAnswerResult(
            question: question,
            userNotes: userNotes,
            userChordType: nil,
            isCorrect: false,
            responseTime: 1.5
        )
        
        XCTAssertEqual(result.missedNotes.count, 1)
        XCTAssertTrue(result.extraNotes.isEmpty)
    }
    
    func testExtraNotes() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "" }!
        let chord = Chord(root: root, chordType: majorType)
        
        let question = ChordDrillQuestion(
            chord: chord,
            questionType: .allTones,
            targetTone: nil
        )
        
        // User selected C, E, G, and D (extra)
        let userNotes: Set<Note> = [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "D", midiNumber: 62, isSharp: false),
            Note(name: "E", midiNumber: 64, isSharp: false),
            Note(name: "G", midiNumber: 67, isSharp: false)
        ]
        
        let result = ChordAnswerResult(
            question: question,
            userNotes: userNotes,
            userChordType: nil,
            isCorrect: false,
            responseTime: 1.5
        )
        
        XCTAssertEqual(result.extraNotes.count, 1)
        XCTAssertTrue(result.extraNotes.contains { $0.name == "D" })
    }
}

// MARK: - ChordDrillSession Tests

final class ChordDrillSessionTests: XCTestCase {
    
    func testSessionAccuracy() {
        let root = Note(name: "C", midiNumber: 60, isSharp: false)
        let majorType = JazzChordDatabase.shared.chordTypes.first { $0.symbol == "" }!
        let chord = Chord(root: root, chordType: majorType)
        
        let question = ChordDrillQuestion(
            chord: chord,
            questionType: .allTones,
            targetTone: nil
        )
        
        let correctResult = ChordAnswerResult(
            question: question,
            userNotes: question.correctAnswer,
            userChordType: nil,
            isCorrect: true,
            responseTime: 1.0
        )
        
        let incorrectResult = ChordAnswerResult(
            question: question,
            userNotes: [],
            userChordType: nil,
            isCorrect: false,
            responseTime: 1.0
        )
        
        let session = ChordDrillSession(
            config: .default,
            startTime: Date().addingTimeInterval(-60),
            endTime: Date(),
            results: [correctResult, incorrectResult]
        )
        
        XCTAssertEqual(session.totalQuestions, 2)
        XCTAssertEqual(session.correctCount, 1)
        XCTAssertEqual(session.accuracy, 0.5, accuracy: 0.01)
        XCTAssertEqual(session.duration, 60, accuracy: 1)
    }
}

// MARK: - End-to-End Flow Tests
// These tests verify the complete drill flow: setup → start → answer questions → proceed → complete
// They ensure state transitions are correct at each step

@MainActor
final class ChordDrillGameFlowTests: XCTestCase {
    
    var game: ChordDrillGame!
    
    override func setUp() {
        super.setUp()
        game = ChordDrillGame()
    }
    
    override func tearDown() {
        game = nil
        super.tearDown()
    }
    
    func test_flow_completeSession_basicTriads() {
        // Step 1: Verify initial state
        XCTAssertEqual(game.state, .setup)
        XCTAssertTrue(game.questions.isEmpty)
        XCTAssertNil(game.currentQuestion)
        
        // Step 2: Start drill
        game.startDrill(preset: .basicTriads)
        XCTAssertEqual(game.state, .active)
        XCTAssertFalse(game.questions.isEmpty)
        XCTAssertNotNil(game.currentQuestion)
        XCTAssertEqual(game.currentIndex, 0)
        
        // Step 3: Answer all questions
        let totalQuestions = game.questions.count
        for i in 0..<totalQuestions {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Submit answer
            game.submitAnswer(notes: question.correctAnswer)
            XCTAssertTrue(game.showingFeedback, "Question \(i): Feedback should show after submit")
            XCTAssertTrue(game.lastAnswerCorrect, "Question \(i): Correct answer should be marked correct")
            
            // Move to next
            game.nextQuestion()
            XCTAssertFalse(game.showingFeedback, "Question \(i): Feedback should hide after next")
        }
        
        // Step 4: Verify completion
        XCTAssertEqual(game.state, .results)
        XCTAssertNotNil(game.session)
        XCTAssertEqual(game.session?.correctCount, totalQuestions)
        XCTAssertEqual(game.session!.accuracy, 1.0, accuracy: 0.01)
    }
    
    func test_flow_mixedCorrectIncorrect() {
        // Start drill
        game.startDrill(preset: .basicTriads)
        
        let totalQuestions = game.questions.count
        var expectedCorrect = 0
        
        for i in 0..<totalQuestions {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Alternate correct/incorrect answers
            if i % 2 == 0 {
                game.submitAnswer(notes: question.correctAnswer)
                expectedCorrect += 1
            } else {
                game.submitAnswer(notes: []) // Wrong answer
            }
            
            XCTAssertTrue(game.showingFeedback)
            game.nextQuestion()
        }
        
        // Verify completion with mixed results
        XCTAssertEqual(game.state, .results)
        XCTAssertNotNil(game.session)
        XCTAssertEqual(game.session?.correctCount, expectedCorrect)
    }
    
    func test_flow_resetAndRestart() {
        // Complete a session
        game.startDrill(preset: .basicTriads)
        _ = game.questions.count
        
        // Answer first question
        if let question = game.currentQuestion {
            game.submitAnswer(notes: question.correctAnswer)
            game.nextQuestion()
        }
        
        XCTAssertEqual(game.currentIndex, 1)
        XCTAssertEqual(game.results.count, 1)
        
        // Reset
        game.reset()
        XCTAssertEqual(game.state, .setup)
        XCTAssertTrue(game.questions.isEmpty)
        XCTAssertEqual(game.currentIndex, 0)
        XCTAssertTrue(game.results.isEmpty)
        
        // Start new session
        game.startDrill(preset: .seventhAndSixthChords)
        XCTAssertEqual(game.state, .active)
        XCTAssertFalse(game.questions.isEmpty)
        XCTAssertEqual(game.currentIndex, 0)
        XCTAssertTrue(game.results.isEmpty)
    }
    
    func test_flow_auralQualitySession() {
        // Start drill with aural questions
        let config = ChordDrillConfig(
            chordTypes: ["maj7", "7", "m7"],
            keyDifficulty: .easy,
            questionTypes: [.auralQuality],
            difficulty: .beginner,
            questionCount: 5,
            audioEnabled: false
        )
        game.startDrill(config: config)
        
        XCTAssertEqual(game.state, .active)
        
        // Answer each question with chord type
        for i in 0..<game.questions.count {
            guard let question = game.currentQuestion else {
                XCTFail("Question \(i) should exist")
                return
            }
            
            // Submit chord type answer
            game.submitAnswer(chordType: question.chord.chordType)
            XCTAssertTrue(game.showingFeedback)
            XCTAssertTrue(game.lastAnswerCorrect)
            
            game.nextQuestion()
        }
        
        XCTAssertEqual(game.state, .results)
        XCTAssertEqual(game.session!.accuracy, 1.0, accuracy: 0.01)
    }
    
    func test_flow_incorrectAnswerCanProceed() {
        // Critical test: After incorrect answer, user must be able to proceed
        game.startDrill(preset: .basicTriads)
        
        guard game.currentQuestion != nil else {
            XCTFail("Should have a question")
            return
        }
        
        // Submit wrong answer
        game.submitAnswer(notes: [])
        XCTAssertTrue(game.showingFeedback)
        XCTAssertFalse(game.lastAnswerCorrect)
        
        // User should be able to proceed
        game.nextQuestion()
        XCTAssertFalse(game.showingFeedback, "Must be able to move to next question after incorrect answer")
        XCTAssertEqual(game.currentIndex, 1, "Should advance to next question")
    }
    
    func test_flow_progressTracking() {
        game.startDrill(preset: .basicTriads)
        
        XCTAssertEqual(game.progress, 0.0, accuracy: 0.01)
        
        let totalQuestions = game.questions.count
        for i in 0..<totalQuestions {
            let expectedProgress = Double(i) / Double(totalQuestions)
            XCTAssertEqual(game.progress, expectedProgress, accuracy: 0.01, "Progress should be \(expectedProgress) at question \(i)")
            
            if let question = game.currentQuestion {
                game.submitAnswer(notes: question.correctAnswer)
                game.nextQuestion()
            }
        }
    }
}
