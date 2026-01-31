import Foundation
import SwiftUI

@MainActor
class IntervalDrillViewModel: ObservableObject {
    // MARK: - Session State
    @Published var selectedNote: Note?
    @Published var selectedInterval: IntervalType?
    @Published var showingFeedback = false
    @Published var hasSubmitted = false
    
    private let audioManager: AudioManager
    private let settings: SettingsManager
    
    init(audioManager: AudioManager = .shared, settings: SettingsManager = .shared) {
        self.audioManager = audioManager
        self.settings = settings
    }
    
    // MARK: - Answer Submission
    
    func submitAnswer(
        question: IntervalQuestion,
        checkBuildAnswer: (Note) -> Bool,
        checkIdentifyAnswer: (IntervalType) -> Bool
    ) {
        hasSubmitted = true
        
        var isCorrect = false
        
        switch question.questionType {
        case .buildInterval:
            if let note = selectedNote {
                isCorrect = checkBuildAnswer(note)
            }
        case .identifyInterval, .auralIdentify:
            if let interval = selectedInterval {
                isCorrect = checkIdentifyAnswer(interval)
            }
        }
        
        // Haptic feedback
        if isCorrect {
            IntervalDrillHaptics.success()
        } else {
            IntervalDrillHaptics.error()
        }
        
        // Audio playback
        if settings.playChordOnCorrect {
            if isCorrect {
                playCorrectAnswer(question: question)
            } else {
                playIncorrectFeedback(question: question)
            }
        }
        
        showingFeedback = true
    }
    
    // MARK: - Audio Playback
    
    private func playCorrectAnswer(question: IntervalQuestion) {
        audioManager.playInterval(
            rootNote: question.interval.rootNote,
            targetNote: question.interval.targetNote,
            style: settings.defaultIntervalStyle,
            tempo: settings.intervalTempo
        )
    }
    
    private func playIncorrectFeedback(question: IntervalQuestion) {
        switch question.questionType {
        case .buildInterval:
            guard let userNote = selectedNote else { return }
            playUserInterval(question: question, userNote: userNote)
            
        case .identifyInterval, .auralIdentify:
            guard let userIntervalType = selectedInterval else { return }
            playUserInterval(question: question, userIntervalType: userIntervalType)
        }
    }
    
    private func playUserInterval(question: IntervalQuestion, userNote: Note) {
        let semitones = abs(userNote.midiNumber - question.interval.rootNote.midiNumber)
        let userIntervalType = IntervalDatabase.shared.interval(forSemitones: semitones) ?? question.interval.intervalType
        
        let userInterval = Interval(
            rootNote: question.interval.rootNote,
            intervalType: userIntervalType,
            direction: question.interval.direction
        )
        
        audioManager.playInterval(
            rootNote: userInterval.rootNote,
            targetNote: userInterval.targetNote,
            style: settings.defaultIntervalStyle,
            tempo: settings.intervalTempo
        )
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            playCorrectAnswer(question: question)
        }
    }
    
    private func playUserInterval(question: IntervalQuestion, userIntervalType: IntervalType) {
        let userInterval = Interval(
            rootNote: question.interval.rootNote,
            intervalType: userIntervalType,
            direction: question.interval.direction
        )
        
        audioManager.playInterval(
            rootNote: userInterval.rootNote,
            targetNote: userInterval.targetNote,
            style: settings.defaultIntervalStyle,
            tempo: settings.intervalTempo
        )
        
        Task {
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            playCorrectAnswer(question: question)
        }
    }
    
    // MARK: - Session Management
    
    func resetForNextQuestion() {
        selectedNote = nil
        selectedInterval = nil
        hasSubmitted = false
        showingFeedback = false
    }
    
    func clearSelection() {
        selectedNote = nil
        selectedInterval = nil
    }
}

// MARK: - Haptic Feedback

enum IntervalDrillHaptics {
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
}
