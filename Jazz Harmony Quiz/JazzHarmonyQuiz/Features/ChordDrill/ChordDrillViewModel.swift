import SwiftUI
import Foundation

/// ViewModel for ChordDrill session - handles business logic and state management
@MainActor
class ChordDrillViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var selectedNotes: Set<Note> = []
    @Published var selectedChordType: ChordType?
    @Published var showingFeedback = false
    @Published var isCorrect = false
    @Published var currentQuestionForFeedback: QuizQuestion?
    @Published var correctAnswerForFeedback: [Note] = []
    @Published var isLastQuestion = false
    @Published var feedbackPhase: FeedbackPhase = .showingUserAnswer
    @Published var userAnswerForFeedback: [Note] = []
    @Published var selectedChordTypeForFeedback: ChordType?
    
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
    
    // MARK: - Computed Properties
    
    func canSubmit(for question: QuizQuestion?) -> Bool {
        guard let question else { return false }
        
        switch question.questionType {
        case .auralQuality:
            return selectedChordType != nil
        case .auralSpelling, .singleTone, .allTones:
            return !selectedNotes.isEmpty
        }
    }
    
    // MARK: - Public Methods
    
    func questionPrompt(for question: QuizQuestion) -> String {
        switch question.questionType {
        case .singleTone:
            return "Select the chord tone shown above"
        case .allTones:
            return "Select all the chord tones for this chord"
        case .auralQuality:
            return "Identify the chord quality by ear"
        case .auralSpelling:
            return "Hear the quality, spell from the root"
        }
    }
    
    func playCurrentChord(question: QuizQuestion, style: AudioManager.ChordPlaybackStyle, tempo: Double) {
        audioManager.playChord(
            question.chord.chordTones,
            style: style,
            tempo: tempo
        )
    }
    
    func playChordWithStyle(_ style: AudioManager.ChordPlaybackStyle, question: QuizQuestion, tempo: Double) {
        audioManager.playChord(
            question.chord.chordTones,
            style: style,
            tempo: tempo
        )
    }
    
    func submitAnswer(question: QuizQuestion, audioEnabled: Bool) {
        let userAnswer: [Note]
        let correctAnswer = question.correctAnswer
        
        // Handle answer based on question type
        if question.questionType == .auralQuality {
            // For aural quality recognition, check chord type selection
            if let selectedType = selectedChordType {
                isCorrect = selectedType.id == question.chord.chordType.id
                selectedChordTypeForFeedback = selectedType
            } else {
                isCorrect = false
                selectedChordTypeForFeedback = nil
            }
            userAnswer = question.chord.chordTones  // Use chord tones for display
        } else if question.questionType == .auralSpelling {
            // For aural spelling, check selected notes
            userAnswer = Array(selectedNotes)
            isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
        } else {
            // For visual questions, use selected notes
            userAnswer = Array(selectedNotes)
            isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
        }
        
        // Store current question, user's answer, and correct answer for feedback
        currentQuestionForFeedback = question
        correctAnswerForFeedback = correctAnswer
        userAnswerForFeedback = userAnswer
        feedbackPhase = .showingUserAnswer
        
        // Play audio feedback
        if isCorrect {
            if audioEnabled {
                audioManager.playChord(correctAnswer, duration: 1.0)
            }
        } else {
            // For aural questions, don't auto-play - let user control playback
            // For visual questions, play user's answer
            if audioEnabled && !question.questionType.isAural {
                if !userAnswer.isEmpty {
                    audioManager.playChord(userAnswer, duration: 1.0)
                }
            }
        }
        
        // Show feedback
        showingFeedback = true
    }
    
    func checkIfLastQuestion(currentIndex: Int, totalQuestions: Int) {
        isLastQuestion = currentIndex == totalQuestions - 1
    }
    
    func showCorrectAnswer(audioEnabled: Bool) {
        feedbackPhase = .showingCorrectAnswer
        
        // Play the correct chord
        if audioEnabled {
            audioManager.playChord(correctAnswerForFeedback, duration: 1.0)
        }
    }
    
    func clearSelection() {
        selectedNotes.removeAll()
        selectedChordType = nil
    }
    
    func resetForNextQuestion() {
        selectedNotes.removeAll()
        selectedChordType = nil
        selectedChordTypeForFeedback = nil
        userAnswerForFeedback = []
        feedbackPhase = .showingUserAnswer
        showingFeedback = false
    }
    
    func getChordToneLabel(for note: Note, in question: QuizQuestion) -> String {
        // Calculate pitch class relative to root
        let rootPitchClass = ((question.chord.root.midiNumber - 60) % 12 + 12) % 12
        let notePitchClass = ((note.midiNumber - 60) % 12 + 12) % 12
        let interval = (notePitchClass - rootPitchClass + 12) % 12
        
        // Try to match the interval to a chord tone from the chord type
        for chordTone in question.chord.chordType.chordTones {
            if chordTone.semitonesFromRoot == interval {
                return chordTone.name
            }
        }
        
        // Fallback: generic interval labels
        switch interval {
        case 0: return "Root"
        case 1: return "b9"
        case 2: return "9"
        case 3: return "b3/#9"
        case 4: return "3"
        case 5: return "4"
        case 6: return "b5"
        case 7: return "5"
        case 8: return "#5/b13"
        case 9: return "6/13"
        case 10: return "b7"
        case 11: return "7"
        default: return "?"
        }
    }
    
    func playUserAnswer(question: QuizQuestion) {
        if let selected = selectedChordType {
            let userChord = Chord(root: question.chord.root, chordType: selected)
            audioManager.playChord(userChord.chordTones, duration: 1.2)
        }
    }
    
    func playCorrectAnswerChord() {
        audioManager.playChord(correctAnswerForFeedback, duration: 1.2)
    }
    
    // MARK: - Private Methods
    
    private func isAnswerCorrect(userAnswer: [Note], question: QuizQuestion) -> Bool {
        let correctAnswer = question.correctAnswer
        
        // For single tone questions, check if the user selected the correct note
        if question.questionType == .singleTone {
            guard userAnswer.count == 1, correctAnswer.count == 1 else { return false }
            // Compare pitch classes to handle different octaves
            return pitchClass(userAnswer[0].midiNumber) == pitchClass(correctAnswer[0].midiNumber)
        }
        
        // For all tones and chord spelling, check if all correct notes are selected
        // and no incorrect notes are selected (comparing pitch classes)
        let userPitchClasses = Set(userAnswer.map { pitchClass($0.midiNumber) })
        let correctPitchClasses = Set(correctAnswer.map { pitchClass($0.midiNumber) })
        
        return userPitchClasses == correctPitchClasses
    }
    
    private func pitchClass(_ midiNumber: Int) -> Int {
        return ((midiNumber - 60) % 12 + 12) % 12
    }
}
