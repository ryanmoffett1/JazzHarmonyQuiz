import SwiftUI
import Combine

/// ViewModel for Quick Practice Session - contains all testable business logic
/// Extracted from QuickPracticeSession for unit testing
@MainActor
class QuickPracticeViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var items: [QuickPracticeItem] = []
    @Published var currentIndex = 0
    @Published var selectedNotes: Set<Note> = []
    @Published var showingFeedback = false
    @Published var isCorrect = false
    @Published var correctCount = 0
    @Published var missedItems: [MissedItem] = []
    @Published var sessionComplete = false
    @Published var sessionStartTime = Date()
    
    // MARK: - Dependencies
    
    private let generator: QuickPracticeGenerator
    private let audioManager: AudioManager
    
    // MARK: - Computed Properties
    
    var currentItem: QuickPracticeItem? {
        guard currentIndex < items.count else { return nil }
        return items[currentIndex]
    }
    
    var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(currentIndex) / Double(items.count)
    }
    
    var accuracy: Int {
        guard !items.isEmpty else { return 0 }
        return Int((Double(correctCount) / Double(items.count)) * 100)
    }
    
    var canSubmitAnswer: Bool {
        !showingFeedback && !selectedNotes.isEmpty
    }
    
    // MARK: - Initialization
    
    init(
        generator: QuickPracticeGenerator = .shared,
        audioManager: AudioManager = .shared
    ) {
        self.generator = generator
        self.audioManager = audioManager
    }
    
    // MARK: - Session Lifecycle
    
    func startSession() {
        items = generator.generateSession()
        currentIndex = 0
        correctCount = 0
        missedItems = []
        selectedNotes = []
        showingFeedback = false
        sessionComplete = false
        sessionStartTime = Date()
    }
    
    func restartSession() {
        startSession()
    }
    
    // MARK: - Answer Validation
    
    func checkAnswer() {
        guard let item = currentItem else { return }
        
        // Validate answer based on item type
        switch item.type {
        case .chordSpelling:
            isCorrect = validateChordAnswer(item: item)
        case .intervalBuilding:
            isCorrect = validateIntervalAnswer(item: item)
        case .scaleSpelling:
            isCorrect = validateScaleAnswer(item: item)
        case .cadenceProgression:
            isCorrect = false  // Not yet implemented
        }
        
        if isCorrect {
            correctCount += 1
            // Play correct chord/interval as audio feedback
            if !item.correctNotes.isEmpty {
                playCorrectAnswer(item.correctNotes)
            }
        } else {
            // Record missed item
            recordMissedItem(item: item)
            // Play correct answer so user can hear it
            if !item.correctNotes.isEmpty {
                playCorrectAnswer(item.correctNotes)
            }
        }
        
        showingFeedback = true
    }
    
    func validateChordAnswer(item: QuickPracticeItem) -> Bool {
        // Compare pitch classes (ignore octave)
        let selectedPitchClasses = Set(selectedNotes.map { $0.midiNumber % 12 })
        let correctPitchClasses = Set(item.correctNotes.map { $0.midiNumber % 12 })
        return selectedPitchClasses == correctPitchClasses
    }
    
    func validateIntervalAnswer(item: QuickPracticeItem) -> Bool {
        // For intervals, we need the correct number of semitones
        let sortedSelected = selectedNotes.sorted { $0.midiNumber < $1.midiNumber }
        guard sortedSelected.count == 2, item.correctNotes.count == 2 else {
            return false
        }
        let selectedInterval = abs(sortedSelected[1].midiNumber - sortedSelected[0].midiNumber) % 12
        let correctInterval = abs(item.correctNotes[1].midiNumber - item.correctNotes[0].midiNumber) % 12
        return selectedInterval == correctInterval
    }
    
    func validateScaleAnswer(item: QuickPracticeItem) -> Bool {
        // Scale validation - compare pitch classes
        guard selectedNotes.count == item.correctNotes.count else {
            return false
        }
        let selectedPitchClasses = Set(selectedNotes.map { $0.midiNumber % 12 })
        let correctPitchClasses = Set(item.correctNotes.map { $0.midiNumber % 12 })
        return selectedPitchClasses == correctPitchClasses
    }
    
    // MARK: - Navigation
    
    func nextQuestion() {
        selectedNotes = []
        showingFeedback = false
        
        if currentIndex < items.count - 1 {
            currentIndex += 1
        } else {
            sessionComplete = true
            recordSessionResults()
        }
    }
    
    func clearSelection() {
        selectedNotes = []
    }
    
    // MARK: - Statistics
    
    func formatDuration() -> String {
        let duration = Date().timeIntervalSince(sessionStartTime)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    func formatDuration(from startTime: Date, to endTime: Date) -> String {
        let duration = endTime.timeIntervalSince(startTime)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // MARK: - Audio
    
    func playCorrectAnswer(_ notes: [Note]) {
        // Play notes as a chord (simultaneously)
        audioManager.playChord(notes)
    }
    
    func playNote(_ note: Note) {
        audioManager.playNote(UInt8(note.midiNumber))
    }
    
    // MARK: - Private Helpers
    
    private func recordMissedItem(item: QuickPracticeItem) {
        missedItems.append(MissedItem(
            question: item.question,
            userAnswer: selectedNotes.map { $0.name }.joined(separator: ", "),
            correctAnswer: item.correctNotes.map { $0.name }.joined(separator: ", "),
            category: item.category
        ))
    }
    
    private func recordSessionResults() {
        // Record to spaced repetition
        // Record to statistics
        // (Integration with existing systems)
    }
}
