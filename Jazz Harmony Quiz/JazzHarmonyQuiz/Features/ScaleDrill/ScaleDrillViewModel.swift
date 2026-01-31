import SwiftUI
import Foundation

/// ViewModel for ScaleDrill session - handles business logic and state management
@MainActor
class ScaleDrillViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedNotes: Set<Note> = []
    @Published var selectedScaleType: ScaleType?
    @Published var showingFeedback = false
    @Published var feedbackMessage = ""
    @Published var isCorrect = false
    @Published var hasSubmitted = false
    @Published var feedbackPhase: FeedbackPhase = .showingUserAnswer
    @Published var userAnswerNotes: [Note] = []
    @Published var highlightedNoteIndex: Int?
    @Published var showContinueButton = false
    @Published var showMaxNotesWarning = false
    
    // MARK: - Types
    
    enum FeedbackPhase {
        case showingUserAnswer
        case showingCorrectAnswer
    }
    
    // MARK: - Dependencies
    
    private let audioManager: AudioManager
    
    // MARK: - Initialization
    
    init(audioManager: AudioManager = .shared) {
        self.audioManager = audioManager
    }
    
    // MARK: - Public Methods
    
    func playCurrentScale(question: ScaleQuestion) {
        audioManager.playScaleObject(question.scale, bpm: 140)
    }
    
    func displayNoteName(_ note: Note, for scale: Scale) -> String {
        if let scaleNote = scale.scaleNotes.first(where: { $0.pitchClass == note.pitchClass }) {
            return scaleNote.name
        }
        
        let preferSharps = scale.root.isSharp || ["B", "E", "A", "D", "G"].contains(scale.root.name)
        if let displayNote = Note.noteFromMidi(note.midiNumber, preferSharps: preferSharps) {
            return displayNote.name
        }
        return note.name
    }
    
    func sortNotesForScale(_ notes: [Note], rootPitchClass: Int) -> [Note] {
        return notes.sorted { $0.midiNumber < $1.midiNumber }
    }
    
    func handleNoteSelection(newValue: Set<Note>, maxNotes: Int) {
        if newValue.count > maxNotes {
            withAnimation(.easeInOut(duration: 0.2)) {
                showMaxNotesWarning = true
            }
            audioManager.playNote(50, velocity: 60)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.audioManager.stopNote(50)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    self.showMaxNotesWarning = false
                }
            }
        } else {
            showMaxNotesWarning = false
            selectedNotes = newValue
        }
    }
    
    func noteBackgroundColor(isCorrect: Bool, isHighlighted: Bool, isAllCorrect: Bool) -> Color {
        if isAllCorrect {
            return isHighlighted ? ShedTheme.Colors.success : ShedTheme.Colors.success.opacity(0.7)
        }
        if isHighlighted {
            return isCorrect ? ShedTheme.Colors.success : ShedTheme.Colors.danger
        }
        return isCorrect ? ShedTheme.Colors.success.opacity(0.7) : ShedTheme.Colors.danger.opacity(0.7)
    }
    
    func submitAnswer(question: ScaleQuestion, gameSubmit: (Set<Note>) -> Bool) {
        if question.questionType == .earTraining {
            submitEarTrainingAnswer(question: question)
            return
        }
        
        userAnswerNotes = Array(selectedNotes)
        highlightedNoteIndex = nil
        showContinueButton = false
        
        isCorrect = gameSubmit(selectedNotes)
        hasSubmitted = true
        showingFeedback = true
        
        if question.questionType == .singleDegree {
            feedbackPhase = .showingCorrectAnswer
            feedbackMessage = isCorrect ? "Correct! 🎉" : "Incorrect"
        } else {
            feedbackPhase = .showingUserAnswer
            if isCorrect {
                feedbackMessage = "Correct! 🎉"
                playScaleWithHighlight(notes: question.correctNotes, question: question)
            } else {
                feedbackMessage = "Incorrect"
                playUserAnswerWithHighlight(question: question)
            }
        }
    }
    
    func submitEarTrainingAnswer(question: ScaleQuestion) {
        guard let selected = selectedScaleType else { return }
        
        let correctScaleType = question.scale.scaleType
        isCorrect = selected.id == correctScaleType.id
        hasSubmitted = true
        showingFeedback = true
        
        if isCorrect {
            feedbackMessage = "Correct! 🎉"
        } else {
            feedbackMessage = "Incorrect - \(correctScaleType.name)"
            let concept = ConceptualExplanations.shared.scaleExplanation(for: correctScaleType)
            feedbackMessage += "\n\n" + concept.sound
        }
    }
    
    func playUserAnswerWithHighlight(question: ScaleQuestion) {
        let rootPitchClass = question.scale.root.pitchClass
        let rootMidi = question.scale.root.midiNumber
        let sortedNotes = sortNotesForScale(userAnswerNotes, rootPitchClass: rootPitchClass)
        
        var noteSequence: [Note] = []
        for note in sortedNotes {
            let interval = (note.pitchClass - rootPitchClass + 12) % 12
            let midi = rootMidi + interval
            noteSequence.append(Note(name: note.name, midiNumber: midi, isSharp: note.isSharp))
        }
        
        if sortedNotes.count == question.correctNotes.count {
            noteSequence.append(Note(name: sortedNotes[0].name, midiNumber: rootMidi + 12, isSharp: sortedNotes[0].isSharp))
            for i in stride(from: sortedNotes.count - 1, through: 0, by: -1) {
                let note = sortedNotes[i]
                let interval = (note.pitchClass - rootPitchClass + 12) % 12
                let midi = rootMidi + interval
                noteSequence.append(Note(name: note.name, midiNumber: midi, isSharp: note.isSharp))
            }
        }
        
        audioManager.playScale(noteSequence, bpm: 200, direction: .ascending)
        
        scheduleHighlighting(sortedNotes: sortedNotes, hasFullScale: sortedNotes.count == question.correctNotes.count, showContinue: true)
    }
    
    func showCorrectAnswer(question: ScaleQuestion) {
        feedbackPhase = .showingCorrectAnswer
        highlightedNoteIndex = nil
        playScaleWithHighlight(notes: question.correctNotes, question: question)
    }
    
    func playScaleWithHighlight(notes: [Note], question: ScaleQuestion) {
        let rootPitchClass = question.scale.root.pitchClass
        let rootMidi = question.scale.root.midiNumber
        let sortedNotes = sortNotesForScale(notes, rootPitchClass: rootPitchClass)
        
        var noteSequence: [Note] = []
        for note in sortedNotes {
            let interval = (note.pitchClass - rootPitchClass + 12) % 12
            let midi = rootMidi + interval
            noteSequence.append(Note(name: note.name, midiNumber: midi, isSharp: note.isSharp))
        }
        noteSequence.append(Note(name: sortedNotes[0].name, midiNumber: rootMidi + 12, isSharp: sortedNotes[0].isSharp))
        for i in stride(from: sortedNotes.count - 1, through: 0, by: -1) {
            let note = sortedNotes[i]
            let interval = (note.pitchClass - rootPitchClass + 12) % 12
            let midi = rootMidi + interval
            noteSequence.append(Note(name: note.name, midiNumber: midi, isSharp: note.isSharp))
        }
        
        audioManager.playScale(noteSequence, bpm: 200, direction: .ascending)
        
        scheduleHighlighting(sortedNotes: sortedNotes, hasFullScale: true, showContinue: false)
    }
    
    func resetForNextQuestion() {
        selectedNotes.removeAll()
        selectedScaleType = nil
        userAnswerNotes = []
        showingFeedback = false
        hasSubmitted = false
        feedbackMessage = ""
        feedbackPhase = .showingUserAnswer
        highlightedNoteIndex = nil
        showContinueButton = false
    }
    
    func clearSelection() {
        selectedNotes.removeAll()
    }
    
    // MARK: - Private Methods
    
    private func scheduleHighlighting(sortedNotes: [Note], hasFullScale: Bool, showContinue: Bool) {
        let beatDuration: TimeInterval = 0.3
        let baseTime = DispatchTime.now()
        
        var displaySequence: [Int] = []
        for i in 0..<sortedNotes.count {
            displaySequence.append(i)
        }
        if hasFullScale {
            displaySequence.append(sortedNotes.count)
            for i in stride(from: sortedNotes.count - 1, through: 0, by: -1) {
                displaySequence.append(i)
            }
        }
        
        for (index, displayIndex) in displaySequence.enumerated() {
            let delay = baseTime + .milliseconds(Int(Double(index) * beatDuration * 1000))
            DispatchQueue.main.asyncAfter(deadline: delay) {
                self.highlightedNoteIndex = displayIndex
            }
        }
        
        let endTime = baseTime + .milliseconds(Int(Double(displaySequence.count) * beatDuration * 1000 + 200))
        DispatchQueue.main.asyncAfter(deadline: endTime) {
            self.highlightedNoteIndex = nil
            if showContinue {
                self.showContinueButton = true
            }
        }
    }
}
