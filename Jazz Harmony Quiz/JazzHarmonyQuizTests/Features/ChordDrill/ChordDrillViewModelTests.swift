import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class ChordDrillViewModelTests: XCTestCase {
    var sut: ChordDrillViewModel!
    
    override func setUp() {
        super.setUp()
        sut = ChordDrillViewModel()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_setsDefaultValues() {
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertNil(sut.selectedChordType)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertFalse(sut.isCorrect)
        XCTAssertNil(sut.currentQuestionForFeedback)
        XCTAssertTrue(sut.correctAnswerForFeedback.isEmpty)
        XCTAssertFalse(sut.isLastQuestion)
        XCTAssertEqual(sut.feedbackPhase, .showingUserAnswer)
        XCTAssertTrue(sut.userAnswerForFeedback.isEmpty)
        XCTAssertNil(sut.selectedChordTypeForFeedback)
    }
    
    // MARK: - Can Submit Tests
    
    func test_canSubmit_withNilQuestion_returnsFalse() {
        XCTAssertFalse(sut.canSubmit(for: nil))
    }
    
    func test_canSubmit_withAuralQuality_requiresChordTypeSelection() {
        let question = createAuralQualityQuestion()
        
        // Without selection
        XCTAssertFalse(sut.canSubmit(for: question))
        
        // With chord type selection
        sut.selectedChordType = JazzChordDatabase.shared.chordTypes.first
        XCTAssertTrue(sut.canSubmit(for: question))
    }
    
    func test_canSubmit_withAuralSpelling_requiresNotesSelection() {
        let question = createAuralSpellingQuestion()
        
        // Without selection
        XCTAssertFalse(sut.canSubmit(for: question))
        
        // With notes selection
        sut.selectedNotes.insert(Note.C)
        XCTAssertTrue(sut.canSubmit(for: question))
    }
    
    func test_canSubmit_withSingleTone_requiresNotesSelection() {
        let question = createSingleToneQuestion()
        
        // Without selection
        XCTAssertFalse(sut.canSubmit(for: question))
        
        // With notes selection
        sut.selectedNotes.insert(Note.C)
        XCTAssertTrue(sut.canSubmit(for: question))
    }
    
    func test_canSubmit_withAllTones_requiresNotesSelection() {
        let question = createAllTonesQuestion()
        
        // Without selection
        XCTAssertFalse(sut.canSubmit(for: question))
        
        // With notes selection
        sut.selectedNotes.insert(Note.C)
        XCTAssertTrue(sut.canSubmit(for: question))
    }
    
    // MARK: - Question Prompt Tests
    
    func test_questionPrompt_forSingleTone() {
        let question = createSingleToneQuestion()
        let prompt = sut.questionPrompt(for: question)
        XCTAssertEqual(prompt, "Select the chord tone shown above")
    }
    
    func test_questionPrompt_forAllTones() {
        let question = createAllTonesQuestion()
        let prompt = sut.questionPrompt(for: question)
        XCTAssertEqual(prompt, "Select all the chord tones for this chord")
    }
    
    func test_questionPrompt_forAuralQuality() {
        let question = createAuralQualityQuestion()
        let prompt = sut.questionPrompt(for: question)
        XCTAssertEqual(prompt, "Identify the chord quality by ear")
    }
    
    func test_questionPrompt_forAuralSpelling() {
        let question = createAuralSpellingQuestion()
        let prompt = sut.questionPrompt(for: question)
        XCTAssertEqual(prompt, "Hear the quality, spell from the root")
    }
    
    // MARK: - Submit Answer Tests - Aural Quality
    
    func test_submitAnswer_withCorrectAuralQuality_marksCorrect() {
        let question = createAuralQualityQuestion()
        sut.selectedChordType = question.chord.chordType
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertTrue(sut.isCorrect)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertEqual(sut.selectedChordTypeForFeedback?.id, question.chord.chordType.id)
        XCTAssertEqual(sut.currentQuestionForFeedback?.id, question.id)
        XCTAssertEqual(sut.correctAnswerForFeedback, question.correctAnswer)
    }
    
    func test_submitAnswer_withIncorrectAuralQuality_marksIncorrect() {
        let question = createAuralQualityQuestion()
        let wrongChordType = JazzChordDatabase.shared.chordTypes.first { $0.id != question.chord.chordType.id }
        sut.selectedChordType = wrongChordType
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertFalse(sut.isCorrect)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertEqual(sut.selectedChordTypeForFeedback?.id, wrongChordType?.id)
    }
    
    func test_submitAnswer_withNoChordTypeSelected_marksIncorrect() {
        let question = createAuralQualityQuestion()
        sut.selectedChordType = nil
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertFalse(sut.isCorrect)
        XCTAssertNil(sut.selectedChordTypeForFeedback)
    }
    
    // MARK: - Submit Answer Tests - Aural Spelling
    
    func test_submitAnswer_withCorrectAuralSpelling_marksCorrect() {
        let question = createAuralSpellingQuestion()
        // Add all correct notes (pitch class matching)
        for note in question.correctAnswer {
            sut.selectedNotes.insert(note)
        }
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertTrue(sut.isCorrect)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    func test_submitAnswer_withIncorrectAuralSpelling_marksIncorrect() {
        let question = createAuralSpellingQuestion()
        sut.selectedNotes = [Note.C, Note.E] // Missing notes
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertFalse(sut.isCorrect)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    // MARK: - Submit Answer Tests - Single Tone
    
    func test_submitAnswer_withCorrectSingleTone_marksCorrect() {
        let question = createSingleToneQuestion()
        let correctNote = question.correctAnswer.first!
        sut.selectedNotes.insert(correctNote)
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertTrue(sut.isCorrect)
    }
    
    func test_submitAnswer_withCorrectSingleTone_differentOctave_marksCorrect() {
        let question = createSingleToneQuestion()
        let correctNote = question.correctAnswer.first!
        // Create same pitch class in different octave
        let differentOctave = Note(name: correctNote.name, midiNumber: correctNote.midiNumber + 12, isSharp: correctNote.isSharp)
        sut.selectedNotes.insert(differentOctave)
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertTrue(sut.isCorrect)
    }
    
    func test_submitAnswer_withIncorrectSingleTone_marksIncorrect() {
        let question = createSingleToneQuestion()
        let wrongNote = Note.D // Assuming this is not the correct answer
        sut.selectedNotes.insert(wrongNote)
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertFalse(sut.isCorrect)
    }
    
    func test_submitAnswer_withMultipleNotesForSingleTone_marksIncorrect() {
        let question = createSingleToneQuestion()
        sut.selectedNotes = [Note.C, Note.E]
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertFalse(sut.isCorrect)
    }
    
    // MARK: - Submit Answer Tests - All Tones
    
    func test_submitAnswer_withAllCorrectTones_marksCorrect() {
        let question = createAllTonesQuestion()
        for note in question.correctAnswer {
            sut.selectedNotes.insert(note)
        }
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertTrue(sut.isCorrect)
    }
    
    func test_submitAnswer_withAllCorrectTones_differentOctaves_marksCorrect() {
        let question = createAllTonesQuestion()
        // Add notes in different octaves
        for note in question.correctAnswer {
            let differentOctave = Note(name: note.name, midiNumber: note.midiNumber + 12, isSharp: note.isSharp)
            sut.selectedNotes.insert(differentOctave)
        }
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertTrue(sut.isCorrect)
    }
    
    func test_submitAnswer_withMissingTones_marksIncorrect() {
        let question = createAllTonesQuestion()
        // Only add first note
        if let firstNote = question.correctAnswer.first {
            sut.selectedNotes.insert(firstNote)
        }
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertFalse(sut.isCorrect)
    }
    
    func test_submitAnswer_withExtraTones_marksIncorrect() {
        let question = createAllTonesQuestion()
        for note in question.correctAnswer {
            sut.selectedNotes.insert(note)
        }
        // Add extra wrong note
        sut.selectedNotes.insert(Note.Db)
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertFalse(sut.isCorrect)
    }
    
    // MARK: - Feedback Phase Tests
    
    func test_submitAnswer_setsFeedbackPhaseToShowingUserAnswer() {
        let question = createAllTonesQuestion()
        sut.selectedNotes.insert(Note.C)
        
        sut.submitAnswer(question: question, audioEnabled: false)
        
        XCTAssertEqual(sut.feedbackPhase, .showingUserAnswer)
    }
    
    func test_showCorrectAnswer_changesFeedbackPhase() {
        sut.feedbackPhase = .showingUserAnswer
        
        sut.showCorrectAnswer(audioEnabled: false)
        
        XCTAssertEqual(sut.feedbackPhase, .showingCorrectAnswer)
    }
    
    // MARK: - Last Question Tests
    
    func test_checkIfLastQuestion_withLastQuestion_setsTrue() {
        sut.checkIfLastQuestion(currentIndex: 9, totalQuestions: 10)
        XCTAssertTrue(sut.isLastQuestion)
    }
    
    func test_checkIfLastQuestion_withNotLastQuestion_setsFalse() {
        sut.checkIfLastQuestion(currentIndex: 5, totalQuestions: 10)
        XCTAssertFalse(sut.isLastQuestion)
    }
    
    // MARK: - Clear Selection Tests
    
    func test_clearSelection_removesAllSelections() {
        sut.selectedNotes = [Note.C, Note.E, Note.G]
        sut.selectedChordType = JazzChordDatabase.shared.chordTypes.first
        
        sut.clearSelection()
        
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertNil(sut.selectedChordType)
    }
    
    // MARK: - Reset For Next Question Tests
    
    func test_resetForNextQuestion_clearsAllState() {
        // Set up state
        sut.selectedNotes = [Note.C, Note.E]
        sut.selectedChordType = JazzChordDatabase.shared.chordTypes.first
        sut.selectedChordTypeForFeedback = JazzChordDatabase.shared.chordTypes.first
        sut.userAnswerForFeedback = [Note.C]
        sut.feedbackPhase = .showingCorrectAnswer
        sut.showingFeedback = true
        
        sut.resetForNextQuestion()
        
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertNil(sut.selectedChordType)
        XCTAssertNil(sut.selectedChordTypeForFeedback)
        XCTAssertTrue(sut.userAnswerForFeedback.isEmpty)
        XCTAssertEqual(sut.feedbackPhase, .showingUserAnswer)
        XCTAssertFalse(sut.showingFeedback)
    }
    
    // MARK: - Chord Tone Label Tests
    
    func test_getChordToneLabel_forRoot_returnsRoot() {
        let question = createAllTonesQuestion()
        let rootNote = question.chord.root
        
        let label = sut.getChordToneLabel(for: rootNote, in: question)
        
        XCTAssertTrue(label == "Root" || label == "1")
    }
    
    func test_getChordToneLabel_forThird_returnsThird() {
        let question = createMajor7Question()
        // C major 7: C E G B, third is E
        let thirdNote = Note(name: "E", midiNumber: 64, isSharp: false)
        
        let label = sut.getChordToneLabel(for: thirdNote, in: question)
        
        XCTAssertTrue(label.contains("3"))
    }
    
    func test_getChordToneLabel_forFifth_returnsFifth() {
        let question = createMajor7Question()
        // C major 7: C E G B, fifth is G
        let fifthNote = Note(name: "G", midiNumber: 67, isSharp: false)
        
        let label = sut.getChordToneLabel(for: fifthNote, in: question)
        
        XCTAssertTrue(label.contains("5"))
    }
    
    func test_getChordToneLabel_forSeventh_returnsSeventh() {
        let question = createMajor7Question()
        // C major 7: C E G B, seventh is B
        let seventhNote = Note(name: "B", midiNumber: 71, isSharp: false)
        
        let label = sut.getChordToneLabel(for: seventhNote, in: question)
        
        XCTAssertTrue(label.contains("7"))
    }
    
    // MARK: - Audio Tests (no-crash verification)
    
    func test_playCurrentChord_doesNotCrash() {
        let question = createAllTonesQuestion()
        
        XCTAssertNoThrow {
            self.sut.playCurrentChord(question: question, style: .block, tempo: 120)
        }
    }
    
    func test_playChordWithStyle_doesNotCrash() {
        let question = createAllTonesQuestion()
        
        XCTAssertNoThrow {
            self.sut.playChordWithStyle(.arpeggioUp, question: question, tempo: 120)
        }
    }
    
    func test_playUserAnswer_doesNotCrash() {
        let question = createAuralQualityQuestion()
        sut.selectedChordType = question.chord.chordType
        
        XCTAssertNoThrow {
            self.sut.playUserAnswer(question: question)
        }
    }
    
    func test_playCorrectAnswerChord_doesNotCrash() {
        sut.correctAnswerForFeedback = [Note.C, Note.E, Note.G]
        
        XCTAssertNoThrow {
            self.sut.playCorrectAnswerChord()
        }
    }
    
    // MARK: - Helper Methods
    
    private func createAuralQualityQuestion() -> QuizQuestion {
        let chord = Chord(root: Note.C, chordType: JazzChordDatabase.shared.chordTypes.first!)
        return QuizQuestion(
            chord: chord,
            questionType: .auralQuality,
            targetTone: nil
        )
    }
    
    private func createAuralSpellingQuestion() -> QuizQuestion {
        let chord = Chord(root: Note.C, chordType: JazzChordDatabase.shared.chordTypes.first!)
        return QuizQuestion(
            chord: chord,
            questionType: .auralSpelling,
            targetTone: nil
        )
    }
    
    private func createSingleToneQuestion() -> QuizQuestion {
        let chordType = JazzChordDatabase.shared.chordTypes.first!
        let chord = Chord(root: Note.C, chordType: chordType)
        let targetTone = chordType.chordTones.first
        
        return QuizQuestion(
            chord: chord,
            questionType: .singleTone,
            targetTone: targetTone
        )
    }
    
    private func createAllTonesQuestion() -> QuizQuestion {
        let chord = Chord(root: Note.C, chordType: JazzChordDatabase.shared.chordTypes.first!)
        return QuizQuestion(
            chord: chord,
            questionType: .allTones,
            targetTone: nil
        )
    }
    
    private func createMajor7Question() -> QuizQuestion {
        // Find major 7 chord type
        let chordTypes = JazzChordDatabase.shared.chordTypes
        let major7Type = chordTypes.first { type in
            type.symbol == "maj7" || type.symbol == "M7" || type.symbol == "Δ"
        } ?? chordTypes.first!
        let chord = Chord(root: Note.C, chordType: major7Type)
        return QuizQuestion(
            chord: chord,
            questionType: .allTones,
            targetTone: nil
        )
    }
    
    // MARK: - End-to-End Flow Tests
    // These tests verify the complete user flow: answer → submit → feedback → next question
    // They ensure the UI button states are correct at each step
    
    func test_flow_answerThenProceed_allTones() {
        // Flow: Select notes → Submit → Feedback shows → Can still interact → Reset
        let question = createAllTonesQuestion()
        let correctNotes = question.correctAnswer
        
        // Step 1: Initial state - can't submit without selection
        XCTAssertFalse(sut.canSubmit(for: question), "Should NOT be able to submit without selection")
        
        // Step 2: Select notes - can now submit
        for note in correctNotes {
            sut.selectedNotes.insert(note)
        }
        XCTAssertTrue(sut.canSubmit(for: question), "Should be able to submit with notes selected")
        
        // Step 3: Submit answer - feedback is shown
        sut.submitAnswer(question: question, audioEnabled: false)
        XCTAssertTrue(sut.showingFeedback, "Feedback should be shown after submit")
        XCTAssertTrue(sut.isCorrect, "Answer should be correct")
        
        // Step 4: Reset for next - state is clean
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.showingFeedback, "Feedback should be hidden after reset")
        XCTAssertTrue(sut.selectedNotes.isEmpty, "Selected notes should be cleared after reset")
        XCTAssertFalse(sut.canSubmit(for: question), "Should NOT be able to submit after reset")
    }
    
    func test_flow_answerThenProceed_singleTone() {
        // Flow: Select single note → Submit → Feedback shows → Reset
        let question = createSingleToneQuestion()
        let correctNote = question.correctAnswer.first!
        
        // Step 1: Initial state
        XCTAssertFalse(sut.canSubmit(for: question))
        
        // Step 2: Select note
        sut.selectedNotes.insert(correctNote)
        XCTAssertTrue(sut.canSubmit(for: question))
        
        // Step 3: Submit
        sut.submitAnswer(question: question, audioEnabled: false)
        XCTAssertTrue(sut.showingFeedback)
        
        // Step 4: Reset
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertTrue(sut.selectedNotes.isEmpty)
    }
    
    func test_flow_answerThenProceed_auralQuality() {
        // Flow: Select chord type → Submit → Feedback shows → Reset
        let question = createAuralQualityQuestion()
        
        // Step 1: Initial state
        XCTAssertFalse(sut.canSubmit(for: question))
        
        // Step 2: Select chord type
        sut.selectedChordType = question.chord.chordType
        XCTAssertTrue(sut.canSubmit(for: question))
        
        // Step 3: Submit
        sut.submitAnswer(question: question, audioEnabled: false)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertTrue(sut.isCorrect)
        
        // Step 4: Reset
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertNil(sut.selectedChordType)
    }
    
    func test_flow_answerThenProceed_auralSpelling() {
        // Flow: Select notes → Submit → Feedback shows → Reset
        let question = createAuralSpellingQuestion()
        let correctNotes = question.correctAnswer
        
        // Step 1: Initial state
        XCTAssertFalse(sut.canSubmit(for: question))
        
        // Step 2: Select notes
        for note in correctNotes {
            sut.selectedNotes.insert(note)
        }
        XCTAssertTrue(sut.canSubmit(for: question))
        
        // Step 3: Submit
        sut.submitAnswer(question: question, audioEnabled: false)
        XCTAssertTrue(sut.showingFeedback)
        
        // Step 4: Reset
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertTrue(sut.selectedNotes.isEmpty)
    }
    
    func test_flow_incorrectAnswer_canProceedAfterFeedback() {
        // Critical test: After incorrect answer, user must be able to proceed to next question
        let question = createAllTonesQuestion()
        
        // Select wrong note
        sut.selectedNotes.insert(Note(name: "F#", midiNumber: 66, isSharp: true))
        XCTAssertTrue(sut.canSubmit(for: question))
        
        // Submit wrong answer
        sut.submitAnswer(question: question, audioEnabled: false)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertFalse(sut.isCorrect, "Answer should be incorrect")
        
        // User should be able to proceed (resetForNextQuestion should be callable)
        sut.resetForNextQuestion()
        XCTAssertFalse(sut.showingFeedback, "Must be able to move to next question after incorrect answer")
    }
    
    func test_flow_multipleQuestionsSequence() {
        // Simulate answering multiple questions in a row
        for i in 0..<3 {
            let question = createAllTonesQuestion()
            
            // Answer
            for note in question.correctAnswer {
                sut.selectedNotes.insert(note)
            }
            
            // Submit
            sut.submitAnswer(question: question, audioEnabled: false)
            XCTAssertTrue(sut.showingFeedback, "Question \(i): Feedback should show")
            
            // Next
            sut.resetForNextQuestion()
            XCTAssertFalse(sut.showingFeedback, "Question \(i): Should be reset for next")
            XCTAssertTrue(sut.selectedNotes.isEmpty, "Question \(i): Selection should be cleared")
        }
    }
}
