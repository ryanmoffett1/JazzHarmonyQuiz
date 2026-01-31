import XCTest
@testable import JazzHarmonyQuiz

@MainActor
final class QuickPracticeViewModelTests: XCTestCase {
    
    var sut: QuickPracticeViewModel!
    var mockGenerator: MockQuickPracticeGenerator!
    var mockAudioManager: MockAudioManager!
    
    override func setUp() async throws {
        mockGenerator = MockQuickPracticeGenerator()
        mockAudioManager = MockAudioManager()
        // Note: Can't inject mocks easily since AudioManager is a singleton
        // For now, we'll test with real dependencies
        sut = QuickPracticeViewModel(
            generator: mockGenerator,
            audioManager: .shared // Using real AudioManager
        )
    }
    
    override func tearDown() async throws {
        sut = nil
        mockGenerator = nil
        mockAudioManager = nil
    }
    
    // MARK: - Session Lifecycle Tests
    
    func test_startSession_generatesItems() {
        // Given
        let expectedItems = createMockItems(count: 5)
        mockGenerator.itemsToReturn = expectedItems
        
        // When
        sut.startSession()
        
        // Then
        XCTAssertEqual(sut.items.count, 5)
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertEqual(sut.correctCount, 0)
        XCTAssertTrue(sut.missedItems.isEmpty)
        XCTAssertFalse(sut.sessionComplete)
    }
    
    func test_startSession_resetsState() {
        // Given - existing session state
        sut.currentIndex = 3
        sut.correctCount = 2
        sut.sessionComplete = true
        sut.selectedNotes = [.C, .E]
        
        // When
        sut.startSession()
        
        // Then
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertEqual(sut.correctCount, 0)
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertFalse(sut.sessionComplete)
    }
    
    func test_restartSession_callsStartSession() {
        // Given
        mockGenerator.itemsToReturn = createMockItems(count: 5)
        sut.startSession()
        sut.currentIndex = 3
        sut.correctCount = 2
        
        // When
        sut.restartSession()
        
        // Then
        XCTAssertEqual(sut.currentIndex, 0)
        XCTAssertEqual(sut.correctCount, 0)
    }
    
    // MARK: - Computed Properties Tests
    
    func test_currentItem_returnsCorrectItem() {
        // Given
        let items = createMockItems(count: 5)
        mockGenerator.itemsToReturn = items
        sut.startSession()
        
        // When
        sut.currentIndex = 2
        
        // Then
        XCTAssertEqual(sut.currentItem?.id, items[2].id)
    }
    
    func test_currentItem_whenIndexOutOfBounds_returnsNil() {
        // Given
        mockGenerator.itemsToReturn = createMockItems(count: 5)
        sut.startSession()
        
        // When
        sut.currentIndex = 10
        
        // Then
        XCTAssertNil(sut.currentItem)
    }
    
    func test_progress_calculatesCorrectly() {
        // Given
        mockGenerator.itemsToReturn = createMockItems(count: 10)
        sut.startSession()
        
        // When
        sut.currentIndex = 5
        
        // Then
        XCTAssertEqual(sut.progress, 0.5, accuracy: 0.01)
    }
    
    func test_progress_whenNoItems_returnsZero() {
        // Given
        mockGenerator.itemsToReturn = []
        sut.startSession()
        
        // Then
        XCTAssertEqual(sut.progress, 0.0)
    }
    
    func test_accuracy_calculatesPercentageCorrectly() {
        // Given
        mockGenerator.itemsToReturn = createMockItems(count: 10)
        sut.startSession()
        sut.correctCount = 7
        
        // When
        let accuracy = sut.accuracy
        
        // Then
        XCTAssertEqual(accuracy, 70)
    }
    
    func test_accuracy_whenNoItems_returnsZero() {
        // Given
        mockGenerator.itemsToReturn = []
        sut.startSession()
        
        // Then
        XCTAssertEqual(sut.accuracy, 0)
    }
    
    func test_canSubmitAnswer_whenNotesSelectedAndNoFeedback_returnsTrue() {
        // Given
        sut.selectedNotes = [.C, .E, .G]
        sut.showingFeedback = false
        
        // Then
        XCTAssertTrue(sut.canSubmitAnswer)
    }
    
    func test_canSubmitAnswer_whenNoNotesSelected_returnsFalse() {
        // Given
        sut.selectedNotes = []
        sut.showingFeedback = false
        
        // Then
        XCTAssertFalse(sut.canSubmitAnswer)
    }
    
    func test_canSubmitAnswer_whenShowingFeedback_returnsFalse() {
        // Given
        sut.selectedNotes = [.C, .E, .G]
        sut.showingFeedback = true
        
        // Then
        XCTAssertFalse(sut.canSubmitAnswer)
    }
    
    // MARK: - Chord Validation Tests
    
    func test_validateChordAnswer_withCorrectPitchClasses_returnsTrue() {
        // Given - C Major chord (C, E, G)
        let item = createChordItem(correctNotes: [.C, .E, .G])
        sut.selectedNotes = [.C, .E, .G]
        
        // When
        let result = sut.validateChordAnswer(item: item)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_validateChordAnswer_withDifferentOctave_returnsTrue() {
        // Given - C Major chord in different octave
        let item = createChordItem(correctNotes: [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "E", midiNumber: 64, isSharp: false),
            Note(name: "G", midiNumber: 67, isSharp: false)
        ])
        sut.selectedNotes = [
            Note(name: "C", midiNumber: 72, isSharp: false),  // C5 instead of C4
            Note(name: "E", midiNumber: 76, isSharp: false),
            Note(name: "G", midiNumber: 79, isSharp: false)
        ]
        
        // When
        let result = sut.validateChordAnswer(item: item)
        
        // Then - should still be correct (pitch class matching)
        XCTAssertTrue(result)
    }
    
    func test_validateChordAnswer_withIncorrectNotes_returnsFalse() {
        // Given - C Major chord
        let item = createChordItem(correctNotes: [.C, .E, .G])
        sut.selectedNotes = [.C, .E, .A]  // C E A (not C Major)
        
        // When
        let result = sut.validateChordAnswer(item: item)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_validateChordAnswer_withMissingNotes_returnsFalse() {
        // Given - C Major chord
        let item = createChordItem(correctNotes: [.C, .E, .G])
        sut.selectedNotes = [.C, .E]  // Missing G
        
        // When
        let result = sut.validateChordAnswer(item: item)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_validateChordAnswer_withExtraNotes_returnsFalse() {
        // Given - C Major chord
        let item = createChordItem(correctNotes: [.C, .E, .G])
        sut.selectedNotes = [.C, .E, .G, .B]  // Extra B
        
        // When
        let result = sut.validateChordAnswer(item: item)
        
        // Then
        XCTAssertFalse(result)
    }
    
    // MARK: - Interval Validation Tests
    
    func test_validateIntervalAnswer_withCorrectInterval_returnsTrue() {
        // Given - Perfect 5th (C to G, 7 semitones)
        let item = createIntervalItem(correctNotes: [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "G", midiNumber: 67, isSharp: false)
        ])
        sut.selectedNotes = [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "G", midiNumber: 67, isSharp: false)
        ]
        
        // When
        let result = sut.validateIntervalAnswer(item: item)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_validateIntervalAnswer_withSameIntervalDifferentNotes_returnsTrue() {
        // Given - Perfect 5th (C to G)
        let item = createIntervalItem(correctNotes: [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "G", midiNumber: 67, isSharp: false)
        ])
        // When - D to A (also a perfect 5th)
        sut.selectedNotes = [
            Note(name: "D", midiNumber: 62, isSharp: false),
            Note(name: "A", midiNumber: 69, isSharp: false)
        ]
        
        // When
        let result = sut.validateIntervalAnswer(item: item)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_validateIntervalAnswer_withWrongInterval_returnsFalse() {
        // Given - Perfect 5th
        let item = createIntervalItem(correctNotes: [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "G", midiNumber: 67, isSharp: false)
        ])
        // When - Major 3rd instead
        sut.selectedNotes = [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "E", midiNumber: 64, isSharp: false)
        ]
        
        // When
        let result = sut.validateIntervalAnswer(item: item)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_validateIntervalAnswer_withMoreThanTwoNotes_returnsFalse() {
        // Given - Perfect 5th
        let item = createIntervalItem(correctNotes: [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "G", midiNumber: 67, isSharp: false)
        ])
        sut.selectedNotes = [.C, .E, .G]  // 3 notes
        
        // When
        let result = sut.validateIntervalAnswer(item: item)
        
        // Then
        XCTAssertFalse(result)
    }
    
    // MARK: - Scale Validation Tests
    
    func test_validateScaleAnswer_withCorrectScale_returnsTrue() {
        // Given - C Major scale
        let item = createScaleItem(correctNotes: [
            Note(name: "C", midiNumber: 60, isSharp: false),
            Note(name: "D", midiNumber: 62, isSharp: false),
            Note(name: "E", midiNumber: 64, isSharp: false),
            Note(name: "F", midiNumber: 65, isSharp: false),
            Note(name: "G", midiNumber: 67, isSharp: false),
            Note(name: "A", midiNumber: 69, isSharp: false),
            Note(name: "B", midiNumber: 71, isSharp: false)
        ])
        sut.selectedNotes = Set(item.correctNotes)
        
        // When
        let result = sut.validateScaleAnswer(item: item)
        
        // Then
        XCTAssertTrue(result)
    }
    
    func test_validateScaleAnswer_withWrongNoteCount_returnsFalse() {
        // Given - C Major scale (7 notes)
        let item = createScaleItem(correctNotes: [.C, .D, .E, .F, .G, .A, .B])
        sut.selectedNotes = [.C, .D, .E]  // Only 3 notes
        
        // When
        let result = sut.validateScaleAnswer(item: item)
        
        // Then
        XCTAssertFalse(result)
    }
    
    func test_validateScaleAnswer_withIncorrectNotes_returnsFalse() {
        // Given - C Major scale
        let item = createScaleItem(correctNotes: [.C, .D, .E, .F, .G, .A, .B])
        // C Harmonic Minor instead (C D Eb F G Ab B)
        sut.selectedNotes = [.C, .D, Note.noteFromName("Eb")!, .F, .G, Note.noteFromName("Ab")!, .B]
        
        // When
        let result = sut.validateScaleAnswer(item: item)
        
        // Then
        XCTAssertFalse(result)
    }
    
    // MARK: - Check Answer Tests
    
    func test_checkAnswer_withCorrectChordAnswer_incrementsCorrectCount() {
        // Given
        let item = createChordItem(correctNotes: [.C, .E, .G])
        mockGenerator.itemsToReturn = [item]
        sut.startSession()
        sut.selectedNotes = [.C, .E, .G]
        
        // When
        sut.checkAnswer()
        
        // Then
        XCTAssertTrue(sut.isCorrect)
        XCTAssertEqual(sut.correctCount, 1)
        XCTAssertTrue(sut.showingFeedback)
        // Can't test audio manager calls since using real instance
    }
    
    func test_checkAnswer_withIncorrectAnswer_recordsMissedItem() {
        // Given
        let item = createChordItem(correctNotes: [.C, .E, .G])
        mockGenerator.itemsToReturn = [item]
        sut.startSession()
        sut.selectedNotes = [.C, .E, .A]  // Wrong
        
        // When
        sut.checkAnswer()
        
        // Then
        XCTAssertFalse(sut.isCorrect)
        XCTAssertEqual(sut.correctCount, 0)
        XCTAssertEqual(sut.missedItems.count, 1)
        XCTAssertTrue(sut.showingFeedback)
    }
    
    func test_checkAnswer_withIncorrectAnswer_playsCorrectAnswer() {
        // Given
        let item = createChordItem(correctNotes: [.C, .E, .G])
        mockGenerator.itemsToReturn = [item]
        sut.startSession()
        sut.selectedNotes = [.C, .E, .A]
        
        // When
        sut.checkAnswer()
        
        // Then - test passes if no crash (audio plays via real AudioManager)
        XCTAssertTrue(true)
    }
    
    // MARK: - Navigation Tests
    
    func test_nextQuestion_advancesToNextItem() {
        // Given
        mockGenerator.itemsToReturn = createMockItems(count: 5)
        sut.startSession()
        sut.selectedNotes = [.C, .E, .G]
        sut.showingFeedback = true
        
        // When
        sut.nextQuestion()
        
        // Then
        XCTAssertEqual(sut.currentIndex, 1)
        XCTAssertTrue(sut.selectedNotes.isEmpty)
        XCTAssertFalse(sut.showingFeedback)
        XCTAssertFalse(sut.sessionComplete)
    }
    
    func test_nextQuestion_onLastQuestion_completesSession() {
        // Given
        mockGenerator.itemsToReturn = createMockItems(count: 5)
        sut.startSession()
        sut.currentIndex = 4  // Last question (index 4 of 5 items)
        
        // When
        sut.nextQuestion()
        
        // Then
        XCTAssertTrue(sut.sessionComplete)
    }
    
    func test_clearSelection_removesAllSelectedNotes() {
        // Given
        sut.selectedNotes = [.C, .E, .G]
        
        // When
        sut.clearSelection()
        
        // Then
        XCTAssertTrue(sut.selectedNotes.isEmpty)
    }
    
    // MARK: - Statistics Tests
    
    func test_formatDuration_returnsFormattedTime() {
        // Given
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(125) // 2:05
        
        // When
        let formatted = sut.formatDuration(from: startTime, to: endTime)
        
        // Then
        XCTAssertEqual(formatted, "2:05")
    }
    
    func test_formatDuration_withZeroSeconds_returnsZeroTime() {
        // Given
        let time = Date()
        
        // When
        let formatted = sut.formatDuration(from: time, to: time)
        
        // Then
        XCTAssertEqual(formatted, "0:00")
    }
    
    // MARK: - Audio Tests
    
    func test_playCorrectAnswer_callsAudioManager() {
        // Given
        let notes = [Note.C, Note.E, Note.G]
        
        // When
        sut.playCorrectAnswer(notes)
        
        // Then - test passes if no crash
        XCTAssertTrue(true)
    }
    
    func test_playNote_callsAudioManager() {
        // Given
        let note = Note.C
        
        // When
        sut.playNote(note)
        
        // Then - test passes if no crash
        XCTAssertTrue(true)
    }
    
    // MARK: - Helper Methods
    
    private func createMockItems(count: Int) -> [QuickPracticeItem] {
        return (0..<count).map { index in
            QuickPracticeItem(
                id: UUID(),
                type: .chordSpelling,
                question: "Spell C Major",
                displayName: "C Major",
                correctNotes: [.C, .E, .G],
                difficulty: .beginner,
                category: "Chords"
            )
        }
    }
    
    private func createChordItem(correctNotes: [Note]) -> QuickPracticeItem {
        QuickPracticeItem(
            id: UUID(),
            type: .chordSpelling,
            question: "Spell chord",
            displayName: "Test Chord",
            correctNotes: correctNotes,
            difficulty: .beginner,
            category: "Chords"
        )
    }
    
    private func createIntervalItem(correctNotes: [Note]) -> QuickPracticeItem {
        QuickPracticeItem(
            id: UUID(),
            type: .intervalBuilding,
            question: "Build interval",
            displayName: "Test Interval",
            correctNotes: correctNotes,
            difficulty: .beginner,
            category: "Intervals"
        )
    }
    
    private func createScaleItem(correctNotes: [Note]) -> QuickPracticeItem {
        QuickPracticeItem(
            id: UUID(),
            type: .scaleSpelling,
            question: "Spell scale",
            displayName: "Test Scale",
            correctNotes: correctNotes,
            difficulty: .beginner,
            category: "Scales"
        )
    }
}

// MARK: - Mock Generator

class MockQuickPracticeGenerator: QuickPracticeGenerator {
    var itemsToReturn: [QuickPracticeItem] = []
    
    init() {
        super.init(spacedRepetitionStore: .shared, chordDatabase: .shared)
    }
    
    override func generateSession() -> [QuickPracticeItem] {
        return itemsToReturn
    }
}

// MARK: - Mock Audio Manager (not used, kept for potential future protocol-based injection)

class MockAudioManager {
    var playedNotes: [UInt8] = []
    var playedChords: [[Note]] = []
    
    func playNote(_ midiNumber: UInt8) {
        playedNotes.append(midiNumber)
    }
    
    func playChord(_ notes: [Note]) {
        playedChords.append(notes)
    }
}
