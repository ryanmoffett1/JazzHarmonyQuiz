import Foundation
import SwiftUI

@MainActor
class CadenceDrillViewModel: ObservableObject {
    // MARK: - Session State
    @Published var currentChordIndex = 0
    @Published var chordSpellings: [[Note]] = [[], [], [], [], []]
    @Published var selectedNotes: Set<Note> = []
    @Published var showingFeedback = false
    @Published var isCorrect = false
    @Published var correctAnswerForFeedback: [[Note]] = []
    @Published var currentHintText: String? = nil
    @Published var pendingAnswerToSubmit: [[Note]] = []
    
    // Ear training state
    @Published var feedbackCorrectCadenceType: CadenceType? = nil
    @Published var feedbackUserSelectedType: CadenceType? = nil
    @Published var currentQuestionCadenceChords: [[Note]] = []
    
    private let audioManager: AudioManager
    private let settings: SettingsManager
    
    init(audioManager: AudioManager = .shared, settings: SettingsManager = .shared) {
        self.audioManager = audioManager
        self.settings = settings
    }
    
    // MARK: - Selection Management
    
    func clearSelection() {
        selectedNotes.removeAll()
        HapticFeedback.light()
    }
    
    func moveToNextChord() {
        chordSpellings[currentChordIndex] = Array(selectedNotes)
        currentChordIndex += 1
        selectedNotes.removeAll()
        currentHintText = nil
        HapticFeedback.medium()
    }
    
    // MARK: - Answer Submission
    
    func submitAnswer(
        question: CadenceQuestion,
        drillMode: CadenceDrillMode,
        chordsToSpellCount: Int,
        userSelectedCadenceType: CadenceType?,
        checkAnswer: ([[Note]], CadenceQuestion) -> Bool
    ) {
        // Handle ear training mode
        if drillMode == .auralIdentify {
            submitEarTrainingAnswer(
                question: question,
                userSelectedCadenceType: userSelectedCadenceType
            )
            return
        }
        
        // Save the last chord spelling
        chordSpellings[currentChordIndex] = Array(selectedNotes)
        
        // Prepare the answer based on mode
        let answerToSubmit: [[Note]]
        if drillMode == .commonTones || drillMode == .resolutionTargets {
            answerToSubmit = [Array(selectedNotes)]
        } else {
            answerToSubmit = Array(chordSpellings.prefix(chordsToSpellCount))
        }
        
        pendingAnswerToSubmit = answerToSubmit
        correctAnswerForFeedback = question.expectedAnswers
        
        // Check if answer is correct
        isCorrect = checkAnswer(answerToSubmit, question)
        
        // Haptic and audio feedback
        if isCorrect {
            HapticFeedback.success()
            if settings.playChordOnCorrect && settings.audioEnabled {
                audioManager.playCadenceProgression(answerToSubmit, bpm: 90, beatsPerChord: 2)
            }
        } else {
            HapticFeedback.error()
            if settings.audioEnabled {
                Task {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    audioManager.playCadenceProgression(
                        question.expectedAnswers,
                        bpm: 90,
                        beatsPerChord: 2
                    )
                }
            }
        }
        
        showingFeedback = true
    }
    
    private func submitEarTrainingAnswer(
        question: CadenceQuestion,
        userSelectedCadenceType: CadenceType?
    ) {
        feedbackCorrectCadenceType = question.cadence.cadenceType
        feedbackUserSelectedType = userSelectedCadenceType
        currentQuestionCadenceChords = question.cadence.chords.map { $0.chordTones }
        
        isCorrect = userSelectedCadenceType == question.cadence.cadenceType
        
        if isCorrect {
            HapticFeedback.success()
        } else {
            HapticFeedback.error()
        }
        
        if settings.audioEnabled {
            Task {
                try? await Task.sleep(nanoseconds: 300_000_000)
                playCurrentCadence(drillMode: .auralIdentify)
            }
        }
        
        showingFeedback = true
    }
    
    // MARK: - Question Navigation
    
    func resetForNextQuestion(drillMode: CadenceDrillMode, currentQuestion: CadenceQuestion?) {
        currentChordIndex = 0
        chordSpellings = [[], [], [], [], []]
        selectedNotes.removeAll()
        currentHintText = nil
        pendingAnswerToSubmit = []
        feedbackCorrectCadenceType = nil
        feedbackUserSelectedType = nil
        showingFeedback = false
        
        // For ear training, store new question chords and auto-play
        if drillMode == .auralIdentify, let question = currentQuestion {
            currentQuestionCadenceChords = question.cadence.chords.map { $0.chordTones }
            
            if settings.autoPlayCadences {
                Task {
                    try? await Task.sleep(nanoseconds: 300_000_000)
                    playCurrentCadence(drillMode: .auralIdentify)
                }
            }
        } else {
            currentQuestionCadenceChords = []
        }
    }
    
    // MARK: - Audio Playback
    
    func playCurrentCadence(drillMode: CadenceDrillMode, currentQuestion: CadenceQuestion? = nil) {
        // For ear training mode, use stored cadence chords
        if drillMode == .auralIdentify {
            guard !currentQuestionCadenceChords.isEmpty else {
                print("Warning: No stored cadence chords for ear training playback")
                return
            }
            audioManager.playCadenceProgression(
                currentQuestionCadenceChords,
                bpm: settings.cadenceBPM,
                beatsPerChord: settings.cadenceBeatsPerChord
            )
            return
        }
        
        // For other modes, use current question
        guard let question = currentQuestion else { return }
        let chords = question.cadence.chords.map { $0.chordTones }
        
        audioManager.playCadenceProgression(
            chords,
            bpm: settings.cadenceBPM,
            beatsPerChord: settings.cadenceBeatsPerChord
        )
    }
    
    // MARK: - Hint Management
    
    func requestHint(hintProvider: (Int) -> String?) {
        if let hint = hintProvider(currentChordIndex) {
            currentHintText = hint
        }
    }
}

// MARK: - Haptic Feedback

enum HapticFeedback {
    static func success() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
    }
    
    static func error() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
        #endif
    }
    
    static func light() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
        #endif
    }
    
    static func medium() {
        #if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        #endif
    }
}
