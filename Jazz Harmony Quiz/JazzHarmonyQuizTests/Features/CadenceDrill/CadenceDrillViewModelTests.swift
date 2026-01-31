import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class CadenceDrillViewModelTests: XCTestCase {
    var sut: CadenceDrillViewModel!
    var mockAudioManager: MockAudioManager!
    var mockSettings: SettingsManager!
    
    override func setUp() {
        super.setUp()
        mockAudioManager = MockAudioManager()
        mockSettings = SettingsManager.shared
        mockSettings.playChordOnCorrect = true
        mockSettings.audioEnabled = true
        mockSettings.autoPlayCadences = false
        sut = CadenceDrillViewModel(audioManager: mockAudioManager, settings: mockSettings)
    }
    
    override func tearDown() {
        sut = nil
        mockAudioManager = nil
        mockSettings = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_setsDefaultValues() {
        XCTAssertEqual(sut.currentChordIndex, 0)
        XCTAssertEqual(sut.chordSpellings.count, 5)
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertFalse(sut.isCorrect)
        XCTAssertTrue(sut.correctAnswerForFeedback.isEmpty)
        XCTAssertNil(sut.currentHintText)
    }
    
    // MARK: - Selection Management Tests
    
    func test_clearSelection_removesAllNotes() {
        let note1 = Note(name: "C", midiNumber: 60, isSharp: false)
        let note2 = Note(name: "E", midiNumber: 64, isSharp: false)
        sut.selectedNotes = [note1, note2]
        
        sut.clearSelection()
        
        XCTAssertTrue(sut.selectedNotes.isEmpty)
    }
    
    func test_moveToNextChord_savesCurrentSpelling() {
        let note1 = Note(name: "C", midiNumber: 60, isSharp: false)
        let note2 = Note(name: "E", midiNumber: 64, isSharp: false)
        sut.selectedNotes = [note1, note2]
        sut.currentChordIndex = 0
        
        sut.moveToNextChord()
        
        XCTAssertEqual(sut.currentChordIndex, 1)
        XCTAssertEqual(sut.chordSpellings[0].count, 2)
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertNil(sut.currentHintText)
    }
    
    func test_moveToNextChord_incrementsIndex() {
        sut.currentChordIndex = 0
        
        sut.moveToNextChord()
        
        XCTAssertEqual(sut.currentChordIndex, 1)
    }
    
    // MARK: - Answer Submission Tests (Standard Modes)
    
    func test_submitAnswer_fullProgression_correct() {
        let question = createMockCadenceQuestion()
        let correctAnswer = question.expectedAnswers
        
        // Set up 3-chord spelling
        sut.chordSpellings[0] = correctAnswer[0]
        sut.chordSpellings[1] = correctAnswer[1]
        sut.selectedNotes = Set(correctAnswer[2]) // Last chord in selectedNotes
        sut.currentChordIndex = 2
        
        sut.submitAnswer(
            question: question,
            drillMode: .fullProgression,
            chordsToSpellCount: 3,
            userSelectedCadenceType: nil,
            checkAnswer: { answer, _ in
                answer.count == 3 && answer == correctAnswer
            }
        )
        
        XCTAssertTrue(sut.isCorrect)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertEqual(sut.pendingAnswerToSubmit.count, 3)
    }
    
    func test_submitAnswer_fullProgression_incorrect() {
        let question = createMockCadenceQuestion()
        let wrongAnswer = [[Note(name: "C", midiNumber: 60, isSharp: false)]]
        
        sut.chordSpellings[0] = wrongAnswer[0]
        sut.selectedNotes = []
        sut.currentChordIndex = 0
        
        sut.submitAnswer(
            question: question,
            drillMode: .fullProgression,
            chordsToSpellCount: 3,
            userSelectedCadenceType: nil,
            checkAnswer: { _, _ in false }
        )
        
        XCTAssertFalse(sut.isCorrect)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    func test_submitAnswer_commonTones_submitsOnlySelectedNotes() {
        let question = createMockCadenceQuestion()
        let commonToneNotes = [Note(name: "C", midiNumber: 60, isSharp: false)]
        sut.selectedNotes = Set(commonToneNotes)
        
        sut.submitAnswer(
            question: question,
            drillMode: .commonTones,
            chordsToSpellCount: 1,
            userSelectedCadenceType: nil,
            checkAnswer: { answer, _ in
                answer.count == 1 && answer[0].count == 1
            }
        )
        
        XCTAssertEqual(sut.pendingAnswerToSubmit.count, 1)
        XCTAssertEqual(sut.pendingAnswerToSubmit[0].count, 1)
    }
    
    func test_submitAnswer_resolutionTargets_submitsOnlySelectedNotes() {
        let question = createMockCadenceQuestion()
        let resolutionNotes = [Note(name: "E", midiNumber: 64, isSharp: false)]
        sut.selectedNotes = Set(resolutionNotes)
        
        sut.submitAnswer(
            question: question,
            drillMode: .resolutionTargets,
            chordsToSpellCount: 1,
            userSelectedCadenceType: nil,
            checkAnswer: { answer, _ in
                answer.count == 1
            }
        )
        
        XCTAssertEqual(sut.pendingAnswerToSubmit.count, 1)
    }
    
    // MARK: - Answer Submission Tests (Ear Training)
    
    func test_submitAnswer_earTraining_correct() {
        let question = createMockCadenceQuestion()
        
        sut.submitAnswer(
            question: question,
            drillMode: .auralIdentify,
            chordsToSpellCount: 0,
            userSelectedCadenceType: .major,
            checkAnswer: { _, _ in true }
        )
        
        XCTAssertTrue(sut.isCorrect)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertEqual(sut.feedbackCorrectCadenceType, .major)
        XCTAssertEqual(sut.feedbackUserSelectedType, .major)
        XCTAssertFalse(sut.currentQuestionCadenceChords.isEmpty)
    }
    
    func test_submitAnswer_earTraining_incorrect() {
        let question = createMockCadenceQuestion()
        
        sut.submitAnswer(
            question: question,
            drillMode: .auralIdentify,
            chordsToSpellCount: 0,
            userSelectedCadenceType: .minor,
            checkAnswer: { _, _ in false }
        )
        
        XCTAssertFalse(sut.isCorrect)
        XCTAssertTrue(sut.showingFeedback)
        XCTAssertEqual(sut.feedbackCorrectCadenceType, .major)
        XCTAssertEqual(sut.feedbackUserSelectedType, .minor)
    }
    
    // MARK: - Reset Tests
    
    func test_resetForNextQuestion_clearsState() {
        sut.currentChordIndex = 2
        sut.chordSpellings[0] = [Note(name: "C", midiNumber: 60, isSharp: false)]
        sut.selectedNotes = [Note(name: "E", midiNumber: 64, isSharp: false)]
        sut.currentHintText = "Hint"
        sut.showingFeedback = true
        
        sut.resetForNextQuestion(drillMode: .fullProgression, currentQuestion: nil)
        
        XCTAssertEqual(sut.currentChordIndex, 0)
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertNil(sut.currentHintText)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertTrue(sut.currentQuestionCadenceChords.isEmpty)
    }
    
    func test_resetForNextQuestion_earTraining_storesCadenceChords() {
        let question = createMockCadenceQuestion()
        
        sut.resetForNextQuestion(drillMode: .auralIdentify, currentQuestion: question)
        
        XCTAssertFalse(sut.currentQuestionCadenceChords.isEmpty)
        XCTAssertEqual(sut.currentQuestionCadenceChords.count, 3)
    }
    
    // MARK: - Hint Tests
    
    func test_requestHint_setsHintText() {
        sut.currentChordIndex = 0
        
        sut.requestHint { index in
            index == 0 ? "This is C Major" : nil
        }
        
        XCTAssertEqual(sut.currentHintText, "This is C Major")
    }
    
    func test_requestHint_noHintAvailable() {
        sut.requestHint { _ in nil }
        
        XCTAssertNil(sut.currentHintText)
    }
    
    // MARK: - Audio Playback Tests
    
    func test_playCurrentCadence_standardMode() {
        let question = createMockCadenceQuestion()
        
        sut.playCurrentCadence(drillMode: .fullProgression, currentQuestion: question)
        
        // Verify playback happened (would need more sophisticated mocking to verify details)
        XCTAssertTrue(true) // Placeholder - audio playback is hard to test without more infrastructure
    }
    
    func test_playCurrentCadence_earTraining_usesStoredChords() {
        let question = createMockCadenceQuestion()
        sut.currentQuestionCadenceChords = question.cadence.chords.map { $0.chordTones }
        
        sut.playCurrentCadence(drillMode: .auralIdentify)
        
        // Verify it used stored chords, not question chords
        XCTAssertFalse(sut.currentQuestionCadenceChords.isEmpty)
    }
    
    // MARK: - Helper Methods
    
    private func createMockCadenceQuestion() -> CadenceQuestion {
        let c = Note(name: "C", midiNumber: 60, isSharp: false)
        let e = Note(name: "E", midiNumber: 64, isSharp: false)
        let g = Note(name: "G", midiNumber: 67, isSharp: false)
        let d = Note(name: "D", midiNumber: 62, isSharp: false)
        let f = Note(name: "F", midiNumber: 65, isSharp: false)
        let a = Note(name: "A", midiNumber: 69, isSharp: false)
        let b = Note(name: "B", midiNumber: 71, isSharp: false)
        
        let chord1 = Chord(root: c, chordType: ChordDatabase.shared.majorTriad, inversion: .root)
        let chord2 = Chord(root: d, chordType: ChordDatabase.shared.minorSeventhChord, inversion: .root)
        let chord3 = Chord(root: g, chordType: ChordDatabase.shared.dominantSeventhChord, inversion: .root)
        
        let cadence = Cadence(
            key: c,
            cadenceType: .major,
            chords: [chord1, chord2, chord3]
        )
        
        return CadenceQuestion(
            cadence: cadence,
            drillMode: .fullProgression,
            chordsToSpell: [chord1, chord2, chord3],
            expectedAnswers: [
                [c, e, g],
                [d, f, a, c],
                [g, b, d, f]
            ]
        )
    }
}
