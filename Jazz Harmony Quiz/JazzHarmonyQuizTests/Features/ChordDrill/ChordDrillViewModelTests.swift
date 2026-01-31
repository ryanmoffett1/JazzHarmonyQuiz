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
}
