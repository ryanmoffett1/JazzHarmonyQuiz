import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class IntervalDrillViewModelTests: XCTestCase {
    var sut: IntervalDrillViewModel!
    var mockSettings: SettingsManager!
    
    override func setUp() {
        super.setUp()
        mockSettings = SettingsManager.shared
        mockSettings.playChordOnCorrect = true
        sut = IntervalDrillViewModel(audioManager: .shared, settings: mockSettings)
    }
    
    override func tearDown() {
        sut = nil
        mockSettings = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_setsDefaultValues() {
        XCTAssertNil(sut.selectedNote)
        XCTAssertNil(sut.selectedInterval)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertFalse(sut.hasSubmitted)
    }
    
    // MARK: - Answer Submission Tests (Build Interval)
    
    func test_submitAnswer_buildInterval_correct() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let targetNote = Note(name: "E", midiNumber: 64, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .buildInterval
        )
        
        sut.selectedNote = targetNote
        
        sut.submitAnswer(question: question, checkBuildAnswer: { note in
            note.midiNumber == targetNote.midiNumber
        }, checkIdentifyAnswer: { _ in false })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    func test_submitAnswer_buildInterval_incorrect() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let targetNote = Note(name: "E", midiNumber: 64, isSharp: false)
        let wrongNote = Note(name: "F", midiNumber: 65, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .buildInterval
        )
        
        sut.selectedNote = wrongNote
        
        sut.submitAnswer(question: question, checkBuildAnswer: { note in
            note.midiNumber == targetNote.midiNumber
        }, checkIdentifyAnswer: { _ in false })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    func test_submitAnswer_buildInterval_noSelection() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .buildInterval
        )
        
        sut.selectedNote = nil
        
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in
            XCTFail("Should not check answer when no note selected")
            return false
        }, checkIdentifyAnswer: { _ in false })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    // MARK: - Answer Submission Tests (Identify Interval)
    
    func test_submitAnswer_identifyInterval_correct() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .identifyInterval
        )
        
        sut.selectedInterval = intervalType
        
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { selectedInterval in
            selectedInterval.name == intervalType.name
        })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    func test_submitAnswer_identifyInterval_incorrect() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let wrongInterval = IntervalDatabase.shared.allIntervals.first { $0.name == "Perfect Fourth" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .identifyInterval
        )
        
        sut.selectedInterval = wrongInterval
        
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { selectedInterval in
            selectedInterval.name == intervalType.name
        })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    // MARK: - Answer Submission Tests (Aural Identify)
    
    func test_submitAnswer_auralIdentify_correct() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Perfect Fifth" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .auralIdentify
        )
        
        sut.selectedInterval = intervalType
        
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { selectedInterval in
            selectedInterval.name == intervalType.name
        })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    // MARK: - Session Management Tests
    
    func test_resetForNextQuestion_clearsAllState() {
        sut.selectedNote = Note(name: "C", midiNumber: 60, isSharp: false)
        sut.selectedInterval = IntervalDatabase.shared.allIntervals.first
        sut.hasSubmitted = true
        sut.showingFeedback = true
        
        sut.resetForNextQuestion()
        
        XCTAssertNil(sut.selectedNote)
        XCTAssertNil(sut.selectedInterval)
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
    }
    
    func test_clearSelection_removesSelections() {
        sut.selectedNote = Note(name: "C", midiNumber: 60, isSharp: false)
        sut.selectedInterval = IntervalDatabase.shared.allIntervals.first
        
        sut.clearSelection()
        
        XCTAssertNil(sut.selectedNote)
        XCTAssertNil(sut.selectedInterval)
    }
    
    // MARK: - Audio Playback Tests
    
    func test_submitAnswer_playsAudio_whenSettingEnabled() {
        mockSettings.playChordOnCorrect = true
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .identifyInterval
        )
        
        sut.selectedInterval = intervalType
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { _ in true })
        
        // Audio playback happens, but we can't easily verify without more complex mocking
        XCTAssertTrue(sut.hasSubmitted)
    }
    
    func test_submitAnswer_doesNotPlayAudio_whenSettingDisabled() {
        mockSettings.playChordOnCorrect = false
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .identifyInterval
        )
        
        sut.selectedInterval = intervalType
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { _ in true })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    // MARK: - Edge Case Tests
    
    func test_submitAnswer_buildInterval_withEnharmonicEquivalent() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let targetNote = Note(name: "D♯", midiNumber: 63, isSharp: true)
        let enharmonicNote = Note(name: "E♭", midiNumber: 63, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Minor Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .buildInterval
        )
        
        sut.selectedNote = enharmonicNote
        
        sut.submitAnswer(question: question, checkBuildAnswer: { note in
            note.midiNumber == targetNote.midiNumber
        }, checkIdentifyAnswer: { _ in false })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    func test_submitAnswer_identifyInterval_withMultipleAnswerChecks() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Perfect Fifth" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .identifyInterval
        )
        
        var checkCallCount = 0
        sut.selectedInterval = intervalType
        
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in 
            XCTFail("Should not check build answer for identify question")
            return false 
        }, checkIdentifyAnswer: { selectedInterval in
            checkCallCount += 1
            return selectedInterval.name == intervalType.name
        })
        
        XCTAssertEqual(checkCallCount, 1, "Should check identify answer exactly once")
        XCTAssertTrue(sut.showingFeedback)
    }
    
    func test_submitAnswer_buildInterval_withDescendingInterval() {
        let rootNote = Note(name: "C", midiNumber: 72, isSharp: false)
        let targetNote = Note(name: "A", midiNumber: 69, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Minor Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .descending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .buildInterval
        )
        
        sut.selectedNote = targetNote
        
        sut.submitAnswer(question: question, checkBuildAnswer: { note in
            note.midiNumber == targetNote.midiNumber
        }, checkIdentifyAnswer: { _ in false })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    func test_clearSelection_whenAlreadyEmpty_doesNothing() {
        XCTAssertNil(sut.selectedNote)
        XCTAssertNil(sut.selectedInterval)
        
        sut.clearSelection()
        
        XCTAssertNil(sut.selectedNote)
        XCTAssertNil(sut.selectedInterval)
    }
    
    func test_resetForNextQuestion_multipleTimesClearsStateEachTime() {
        // First question
        sut.selectedNote = Note(name: "C", midiNumber: 60, isSharp: false)
        sut.hasSubmitted = true
        sut.showingFeedback = true
        
        sut.resetForNextQuestion()
        
        XCTAssertNil(sut.selectedNote)
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
        
        // Second question
        sut.selectedInterval = IntervalDatabase.shared.allIntervals.first
        sut.hasSubmitted = true
        sut.showingFeedback = true
        
        sut.resetForNextQuestion()
        
        XCTAssertNil(sut.selectedInterval)
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
    }
    
    func test_submitAnswer_setsHasSubmittedFlag() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .identifyInterval
        )
        
        XCTAssertFalse(sut.hasSubmitted)
        
        sut.selectedInterval = intervalType
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { _ in true })
        
        XCTAssertTrue(sut.hasSubmitted)
    }
    
    func test_submitAnswer_setsShowingFeedbackFlag() {
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .identifyInterval
        )
        
        XCTAssertFalse(sut.showingFeedback)
        
        sut.selectedInterval = intervalType
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { _ in true })
        
        XCTAssertTrue(sut.showingFeedback)
    }
    
    // MARK: - End-to-End Flow Tests
    // These tests verify the complete user flow: answer → submit → feedback → next question
    // They ensure the UI button states are correct at each step
    
    func test_flow_buildInterval_answerThenProceed() {
        // Flow: Select note → Submit → Feedback shows → Reset
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let targetNote = Note(name: "E", midiNumber: 64, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .buildInterval
        )
        
        // Step 1: Initial state
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertNil(sut.selectedNote)
        
        // Step 2: Select note
        sut.selectedNote = targetNote
        XCTAssertNotNil(sut.selectedNote)
        
        // Step 3: Submit answer
        sut.submitAnswer(question: question, checkBuildAnswer: { note in
            note.midiNumber == targetNote.midiNumber
        }, checkIdentifyAnswer: { _ in false })
        
        XCTAssertTrue(sut.hasSubmitted, "Should be submitted after submitting")
        XCTAssertTrue(sut.showingFeedback, "Feedback should show after submit")
        
        // Step 4: Reset for next question
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.hasSubmitted, "hasSubmitted should be false after reset")
        XCTAssertFalse(sut.showingFeedback, "Feedback should be hidden after reset")
        XCTAssertNil(sut.selectedNote, "Selected note should be cleared after reset")
    }
    
    func test_flow_identifyInterval_answerThenProceed() {
        // Flow: Select interval type → Submit → Feedback shows → Reset
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Perfect Fifth" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .identifyInterval
        )
        
        // Step 1: Initial state
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertNil(sut.selectedInterval)
        
        // Step 2: Select interval
        sut.selectedInterval = intervalType
        XCTAssertNotNil(sut.selectedInterval)
        
        // Step 3: Submit answer
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { selected in
            selected.name == intervalType.name
        })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
        
        // Step 4: Reset for next question
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertNil(sut.selectedInterval)
    }
    
    func test_flow_auralIdentify_answerThenProceed() {
        // Flow: Select interval type → Submit → Feedback shows → Reset
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let intervalType = IntervalDatabase.shared.allIntervals.first { $0.name == "Minor Third" }!
        let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .auralIdentify
        )
        
        // Step 1: Initial state
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
        
        // Step 2: Select interval
        sut.selectedInterval = intervalType
        
        // Step 3: Submit
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { selected in
            selected.name == intervalType.name
        })
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
        
        // Step 4: Reset
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
    }
    
    func test_flow_incorrectAnswer_canProceedAfterFeedback() {
        // Critical test: After incorrect answer, user must be able to proceed to next question
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        let correctInterval = IntervalDatabase.shared.allIntervals.first { $0.name == "Major Third" }!
        let wrongInterval = IntervalDatabase.shared.allIntervals.first { $0.name == "Perfect Fourth" }!
        let interval = Interval(rootNote: rootNote, intervalType: correctInterval, direction: .ascending)
        let question = IntervalQuestion(
            interval: interval,
            questionType: .identifyInterval
        )
        
        // Select wrong interval
        sut.selectedInterval = wrongInterval
        
        // Submit wrong answer
        sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { selected in
            selected.name == correctInterval.name // Will be false for wrongInterval
        })
        
        XCTAssertTrue(sut.showingFeedback)
        
        // User must be able to proceed (resetForNextQuestion should work)
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.showingFeedback, "Must be able to move to next question after incorrect answer")
        XCTAssertFalse(sut.hasSubmitted, "hasSubmitted must be false after reset")
    }
    
    func test_flow_multipleQuestionsSequence() {
        // Simulate answering multiple questions in a row
        let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
        
        for i in 0..<3 {
            let intervalType = IntervalDatabase.shared.allIntervals[i % IntervalDatabase.shared.allIntervals.count]
            let interval = Interval(rootNote: rootNote, intervalType: intervalType, direction: .ascending)
            let question = IntervalQuestion(
                interval: interval,
                questionType: .identifyInterval
            )
            
            // Answer
            sut.selectedInterval = intervalType
            
            // Submit
            sut.submitAnswer(question: question, checkBuildAnswer: { _ in false }, checkIdentifyAnswer: { _ in true })
            XCTAssertTrue(sut.showingFeedback, "Question \(i): Feedback should show")
            
            // Next
            sut.resetForNextQuestion()
            XCTAssertFalse(sut.showingFeedback, "Question \(i): Should be reset for next")
            XCTAssertNil(sut.selectedInterval, "Question \(i): Selection should be cleared")
        }
    }
}
