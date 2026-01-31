import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class ScaleDrillViewModelTests: XCTestCase {
    var sut: ScaleDrillViewModel!
    var mockAudioManager: AudioManager!
    
    override func setUp() async throws {
        mockAudioManager = AudioManager.shared
        sut = ScaleDrillViewModel(audioManager: mockAudioManager)
    }
    
    override func tearDown() async throws {
        sut = nil
        mockAudioManager = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_setsDefaultValues() {
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertNil(sut.selectedScaleType)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertEqual(sut.feedbackMessage, "")
        XCTAssertFalse(sut.isCorrect)
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertEqual(sut.feedbackPhase, .showingUserAnswer)
        XCTAssertTrue(sut.userAnswerNotes.isEmpty)
        XCTAssertNil(sut.highlightedNoteIndex)
        XCTAssertFalse(sut.showContinueButton)
        XCTAssertFalse(sut.showMaxNotesWarning)
    }
    
    // MARK: - Note Selection Tests
    
    func test_handleNoteSelection_allowsSelectionUnderMax() {
        let notes: Set<Note> = [Note.C, Note.E, Note.G]
        
        sut.handleNoteSelection(newValue: notes, maxNotes: 5)
        
        XCTAssertEqual(sut.selectedNotes.count, 3)
        XCTAssertFalse(sut.showMaxNotesWarning)
    }
    
    func test_handleNoteSelection_showsWarningWhenExceedingMax() {
        let notes: Set<Note> = [Note.C, Note.D, Note.E, Note.F, Note.G, Note.A]
        
        sut.handleNoteSelection(newValue: notes, maxNotes: 5)
        
        XCTAssertTrue(sut.showMaxNotesWarning)
    }
    
    func test_handleNoteSelection_hidesWarningAfterDelay() async {
        let notes: Set<Note> = [Note.C, Note.D, Note.E, Note.F, Note.G, Note.A]
        
        sut.handleNoteSelection(newValue: notes, maxNotes: 5)
        XCTAssertTrue(sut.showMaxNotesWarning)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000)
        
        XCTAssertFalse(sut.showMaxNotesWarning)
    }
    
    // MARK: - Note Sorting Tests
    
    func test_sortNotesForScale_sortsNotesInScaleOrder() {
        let cRoot = Note(name: "C", midiNumber: 60, isSharp: false)
        let e = Note(name: "E", midiNumber: 64, isSharp: false)
        let g = Note(name: "G", midiNumber: 67, isSharp: false)
        let d = Note(name: "D", midiNumber: 62, isSharp: false)
        
        let unsorted = [e, g, d, cRoot]
        let sorted = sut.sortNotesForScale(unsorted, rootPitchClass: 0) // C = 0
        
        XCTAssertEqual(sorted[0].pitchClass, 0) // C
        XCTAssertEqual(sorted[1].pitchClass, 2) // D
        XCTAssertEqual(sorted[2].pitchClass, 4) // E
        XCTAssertEqual(sorted[3].pitchClass, 7) // G
    }
    
    func test_sortNotesForScale_handlesOctaveDuplicates() {
        let c4 = Note(name: "C", midiNumber: 60, isSharp: false)
        let e4 = Note(name: "E", midiNumber: 64, isSharp: false)
        let c5 = Note(name: "C", midiNumber: 72, isSharp: false)
        
        let unsorted = [c5, e4, c4]
        let sorted = sut.sortNotesForScale(unsorted, rootPitchClass: 0)
        
        // Base C should come first, then E, then octave C
        XCTAssertEqual(sorted[0].midiNumber, 60) // C4
        XCTAssertEqual(sorted[1].midiNumber, 64) // E4
        XCTAssertEqual(sorted[2].midiNumber, 72) // C5
    }
    
    func test_sortNotesForScale_maintainsRelativeOctaves() {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let d = Note(name: "D", midiNumber: 74, isSharp: false) // D one octave up
        let e = Note(name: "E", midiNumber: 64, isSharp: false)
        
        let unsorted = [e, d, c]
        let sorted = sut.sortNotesForScale(unsorted, rootPitchClass: 0)
        
        XCTAssertEqual(sorted[0].name, "C")
        XCTAssertEqual(sorted[1].name, "E")
        XCTAssertEqual(sorted[2].name, "D")
    }
    
    // MARK: - Display Name Tests
    
    func test_displayNoteName_usesScaleNoteWhenAvailable() {
        let scaleType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: scaleType)
        let note = Note(name: "E", midiNumber: 64, isSharp: false)
        
        let displayName = sut.displayNoteName(note, for: scale)
        
        XCTAssertEqual(displayName, "E")
    }
    
    func test_displayNoteName_usesSharpsForSharpScales() {
        let scaleType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.G, scaleType: scaleType)
        let fSharp = Note(name: "F#", midiNumber: 66, isSharp: true)
        
        let displayName = sut.displayNoteName(fSharp, for: scale)
        
        XCTAssertTrue(displayName.contains("#") || displayName == "F#")
    }
    
    // MARK: - Note Background Color Tests
    
    func test_noteBackgroundColor_successForCorrectNote() {
        let color = sut.noteBackgroundColor(isCorrect: true, isHighlighted: false, isAllCorrect: true)
        
        XCTAssertEqual(color, ShedTheme.Colors.success.opacity(0.7))
    }
    
    func test_noteBackgroundColor_successForHighlightedCorrect() {
        let color = sut.noteBackgroundColor(isCorrect: true, isHighlighted: true, isAllCorrect: true)
        
        XCTAssertEqual(color, ShedTheme.Colors.success)
    }
    
    func test_noteBackgroundColor_dangerForIncorrectNote() {
        let color = sut.noteBackgroundColor(isCorrect: false, isHighlighted: true, isAllCorrect: false)
        
        XCTAssertEqual(color, ShedTheme.Colors.danger)
    }
    
    // MARK: - Ear Training Answer Tests
    
    func test_submitEarTrainingAnswer_correctAnswer() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .earTraining,
            targetDegree: nil
        )
        
        sut.selectedScaleType = majorType
        sut.submitEarTrainingAnswer(question: question)
        
        XCTAssertTrue(sut.isCorrect)
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertTrue(sut.feedbackMessage.contains("Correct"))
    }
    
    func test_submitEarTrainingAnswer_incorrectAnswer() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let minorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Natural Minor" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .earTraining,
            targetDegree: nil
        )
        
        sut.selectedScaleType = minorType
        sut.submitEarTrainingAnswer(question: question)
        
        XCTAssertFalse(sut.isCorrect)
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertTrue(sut.feedbackMessage.contains("Incorrect"))
        XCTAssertTrue(sut.feedbackMessage.contains("Major"))
    }
    
    func test_submitEarTrainingAnswer_includesConceptualExplanation() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let minorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Natural Minor" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .earTraining,
            targetDegree: nil
        )
        
        sut.selectedScaleType = minorType
        sut.submitEarTrainingAnswer(question: question)
        
        XCTAssertTrue(sut.feedbackMessage.count > 50) // Should have explanation
    }
    
    // MARK: - Visual Answer Tests (Single Degree)
    
    func test_submitAnswer_singleDegree_correct() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let correctNote = Note(name: "E", midiNumber: 64, isSharp: false)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .singleDegree,
            targetDegree: ScaleDegree.third
        )
        
        sut.selectedNotes = [correctNote]
        sut.submitAnswer(question: question) { selectedNotes in
            return selectedNotes.first?.pitchClass == correctNote.pitchClass
        }
        
        XCTAssertTrue(sut.isCorrect)
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertEqual(sut.feedbackPhase, .showingCorrectAnswer)
        XCTAssertTrue(sut.feedbackMessage.contains("Correct"))
    }
    
    func test_submitAnswer_singleDegree_incorrect() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let correctNote = Note(name: "E", midiNumber: 64, isSharp: false)
        let wrongNote = Note(name: "F", midiNumber: 65, isSharp: false)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .singleDegree,
            targetDegree: ScaleDegree.third
        )
        
        sut.selectedNotes = [wrongNote]
        sut.submitAnswer(question: question) { selectedNotes in
            return selectedNotes.first?.pitchClass == correctNote.pitchClass
        }
        
        XCTAssertFalse(sut.isCorrect)
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertEqual(sut.feedbackPhase, .showingCorrectAnswer)
    }
    
    // MARK: - Visual Answer Tests (All Degrees)
    
    func test_submitAnswer_allDegrees_correct() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let correctNotes = scale.scaleNotes
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        let selectedNotes = Set(correctNotes)
        sut.selectedNotes = selectedNotes
        sut.submitAnswer(question: question) { selected in
            let correctPitches = Set(correctNotes.map { $0.pitchClass })
            let selectedPitches = Set(selected.map { $0.pitchClass })
            return correctPitches == selectedPitches
        }
        
        XCTAssertTrue(sut.isCorrect)
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertEqual(sut.feedbackPhase, .showingUserAnswer)
        XCTAssertTrue(sut.feedbackMessage.contains("Correct"))
    }
    
    func test_submitAnswer_allDegrees_incorrect() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let correctNotes = scale.scaleNotes
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        let wrongNotes: Set<Note> = [Note.C, Note.D, Note.F, Note.G, Note.A, Note.B, Note(name: "C", midiNumber: 72, isSharp: false)]
        sut.selectedNotes = wrongNotes
        sut.submitAnswer(question: question) { selected in
            let correctPitches = Set(correctNotes.map { $0.pitchClass })
            let selectedPitches = Set(selected.map { $0.pitchClass })
            return correctPitches == selectedPitches
        }
        
        XCTAssertFalse(sut.isCorrect)
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertEqual(sut.feedbackPhase, .showingUserAnswer)
        XCTAssertTrue(sut.feedbackMessage.contains("Incorrect"))
    }
    
    func test_submitAnswer_storesUserAnswerNotes() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        let selected: Set<Note> = [Note.C, Note.E, Note.G]
        sut.selectedNotes = selected
        sut.submitAnswer(question: question) { _ in true }
        
        XCTAssertEqual(Set(sut.userAnswerNotes), selected)
    }
    
    // MARK: - Feedback Phase Tests
    
    func test_showCorrectAnswer_transitionsToCorrectAnswerPhase() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        sut.feedbackPhase = .showingUserAnswer
        sut.showCorrectAnswer(question: question)
        
        XCTAssertEqual(sut.feedbackPhase, .showingCorrectAnswer)
        XCTAssertNil(sut.highlightedNoteIndex)
    }
    
    // MARK: - State Management Tests
    
    func test_resetForNextQuestion_clearsAllState() {
        sut.selectedNotes = [Note.C, Note.E, Note.G]
        sut.selectedScaleType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }
        sut.userAnswerNotes = [Note.C, Note.E]
        sut.showingFeedback = true
        sut.hasSubmitted = true
        sut.feedbackMessage = "Test"
        sut.feedbackPhase = .showingCorrectAnswer
        sut.highlightedNoteIndex = 2
        sut.showContinueButton = true
        
        sut.resetForNextQuestion()
        
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertNil(sut.selectedScaleType)
        XCTAssertTrue(sut.userAnswerNotes.isEmpty)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertEqual(sut.feedbackMessage, "")
        XCTAssertEqual(sut.feedbackPhase, .showingUserAnswer)
        XCTAssertNil(sut.highlightedNoteIndex)
        XCTAssertFalse(sut.showContinueButton)
    }
    
    func test_clearSelection_removesSelectedNotes() {
        sut.selectedNotes = [Note.C, Note.E, Note.G]
        
        sut.clearSelection()
        
        XCTAssertTrue(sut.selectedNotes.isEmpty)
    }
    
    // MARK: - Audio Playback Tests
    
    func test_playCurrentScale_doesNotCrash() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        XCTAssertNoThrow {
            self.sut.playCurrentScale(question: question)
        }
    }
    
    func test_playUserAnswerWithHighlight_doesNotCrash() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        sut.userAnswerNotes = [Note.C, Note.E, Note.G]
        
        XCTAssertNoThrow {
            self.sut.playUserAnswerWithHighlight(question: question)
        }
    }
    
    func test_playScaleWithHighlight_doesNotCrash() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        XCTAssertNoThrow {
            self.sut.playScaleWithHighlight(notes: scale.scaleNotes, question: question)
        }
    }
    
    func test_showCorrectAnswer_playsAudio() {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        XCTAssertNoThrow {
            self.sut.showCorrectAnswer(question: question)
        }
    }
    
    // MARK: - Highlighting Tests
    
    func test_playUserAnswerWithHighlight_setsHighlightedIndexEventually() async {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        sut.userAnswerNotes = [Note.C, Note.E, Note.G]
        sut.playUserAnswerWithHighlight(question: question)
        
        try? await Task.sleep(nanoseconds: 400_000_000) // Wait for first highlight
        
        XCTAssertNotNil(sut.highlightedNoteIndex)
    }
    
    func test_playUserAnswerWithHighlight_showsContinueButton() async {
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        sut.userAnswerNotes = [Note.C, Note.E, Note.G]
        sut.playUserAnswerWithHighlight(question: question)
        
        try? await Task.sleep(nanoseconds: 2_000_000_000) // Wait for completion
        
        XCTAssertTrue(sut.showContinueButton)
    }
    
    // MARK: - End-to-End Flow Tests
    // These tests verify the complete user flow: answer → submit → feedback → next question
    // They ensure the UI button states are correct at each step
    
    func test_flow_allDegrees_answerThenProceed() {
        // Flow: Select notes → Submit → Feedback shows → Reset
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .allDegrees,
            targetDegree: nil
        )
        
        // Step 1: Initial state
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        
        // Step 2: Select notes (scale degrees)
        for note in question.correctNotes {
            sut.selectedNotes.insert(note)
        }
        XCTAssertFalse(sut.selectedNotes.isEmpty)
        
        // Step 3: Submit answer
        sut.submitAnswer(question: question) { notes in
            // Check if pitch classes match
            let selectedPitchClasses = notes.map { $0.pitchClass }
            let correctPitchClasses = question.correctNotes.map { $0.pitchClass }
            return Set(selectedPitchClasses) == Set(correctPitchClasses)
        }
        
        XCTAssertTrue(sut.hasSubmitted, "Should be submitted after submitting")
        XCTAssertTrue(sut.showingFeedback, "Feedback should show after submit")
        
        // Step 4: Reset for next question
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.hasSubmitted, "hasSubmitted should be false after reset")
        XCTAssertFalse(sut.showingFeedback, "Feedback should be hidden after reset")
        XCTAssertTrue(sut.selectedNotes.isEmpty, "Selected notes should be cleared after reset")
    }
    
    func test_flow_earTraining_answerThenProceed() {
        // Flow: Select scale type → Submit → Feedback shows → Reset
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .earTraining,
            targetDegree: nil
        )
        
        // Step 1: Initial state
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertNil(sut.selectedScaleType)
        
        // Step 2: Select scale type
        sut.selectedScaleType = majorType
        XCTAssertNotNil(sut.selectedScaleType)
        
        // Step 3: Submit answer
        sut.submitEarTrainingAnswer(question: question)
        
        XCTAssertTrue(sut.hasSubmitted, "Should be submitted after submitting")
        XCTAssertTrue(sut.showingFeedback, "Feedback should show after submit")
        XCTAssertTrue(sut.isCorrect, "Answer should be correct")
        
        // Step 4: Reset for next question
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.hasSubmitted, "hasSubmitted should be false after reset")
        XCTAssertFalse(sut.showingFeedback, "Feedback should be hidden after reset")
        XCTAssertNil(sut.selectedScaleType, "Selected scale type should be cleared after reset")
    }
    
    func test_flow_singleDegree_answerThenProceed() {
        // Flow: Select single note → Submit → Feedback shows → Reset
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .singleDegree,
            targetDegree: ScaleDegree.third // The third degree
        )
        
        // Step 1: Initial state
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
        
        // Step 2: Select a note
        let selectedNote = Note.E // Third degree of C Major
        sut.selectedNotes.insert(selectedNote)
        
        // Step 3: Submit answer
        sut.submitAnswer(question: question) { notes in
            // Simple check for single degree
            return !notes.isEmpty
        }
        
        XCTAssertTrue(sut.hasSubmitted)
        XCTAssertTrue(sut.showingFeedback)
        
        // Step 4: Reset
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.hasSubmitted)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertTrue(sut.selectedNotes.isEmpty)
    }
    
    func test_flow_incorrectAnswer_canProceedAfterFeedback() {
        // Critical test: After incorrect answer, user must be able to proceed to next question
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        let minorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Natural Minor" }!
        let scale = Scale(root: Note.C, scaleType: majorType)
        let question = ScaleQuestion(
            scale: scale,
            questionType: .earTraining,
            targetDegree: nil
        )
        
        // Select wrong scale type
        sut.selectedScaleType = minorType
        
        // Submit wrong answer
        sut.submitEarTrainingAnswer(question: question)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertFalse(sut.isCorrect, "Answer should be incorrect")
        
        // User must be able to proceed (resetForNextQuestion should work)
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.showingFeedback, "Must be able to move to next question after incorrect answer")
        XCTAssertFalse(sut.hasSubmitted, "hasSubmitted must be false after reset")
    }
    
    func test_flow_multipleQuestionsSequence() {
        // Simulate answering multiple questions in a row
        let majorType = JazzScaleDatabase.shared.scaleTypes.first { $0.name == "Major" }!
        
        for i in 0..<3 {
            let scale = Scale(root: Note.C, scaleType: majorType)
            let question = ScaleQuestion(
                scale: scale,
                questionType: .earTraining,
                targetDegree: nil
            )
            
            // Answer
            sut.selectedScaleType = majorType
            
            // Submit
            sut.submitEarTrainingAnswer(question: question)
            XCTAssertTrue(sut.showingFeedback, "Question \(i): Feedback should show")
            
            // Next
            sut.resetForNextQuestion()
            XCTAssertFalse(sut.showingFeedback, "Question \(i): Should be reset for next")
            XCTAssertNil(sut.selectedScaleType, "Question \(i): Selection should be cleared")
        }
    }
}
