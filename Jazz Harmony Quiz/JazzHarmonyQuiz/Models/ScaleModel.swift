import Foundation

// Core model imports
// Note: ScaleDegree, ScaleType, and Scale have been moved to Core/Models/Scale.swift

// MARK: - Scale Question Types

enum ScaleQuestionType: String, CaseIterable, Codable {
    case singleDegree = "Single Degree"
    case allDegrees = "All Scale Tones"
    case earTraining = "Ear Training"
    
    var description: String {
        switch self {
        case .singleDegree:
            return "Identify one specific scale degree"
        case .allDegrees:
            return "Select all notes in the scale"
        case .earTraining:
            return "Identify the scale type by ear"
        }
    }
    
    var icon: String {
        switch self {
        case .singleDegree: return "music.note"
        case .allDegrees: return "pianokeys"
        case .earTraining: return "ear"
        }
    }
}

// MARK: - Scale Question Model

struct ScaleQuestion: Identifiable, Codable, Hashable {
    let id = UUID()
    let scale: Scale
    let questionType: ScaleQuestionType
    let targetDegree: ScaleDegree?  // For singleDegree questions
    let correctNotes: [Note]
    
    init(scale: Scale, questionType: ScaleQuestionType, targetDegree: ScaleDegree? = nil) {
        self.scale = scale
        self.questionType = questionType
        self.targetDegree = targetDegree
        
        switch questionType {
        case .singleDegree:
            if let degree = targetDegree, let note = scale.note(for: degree) {
                self.correctNotes = [note]
            } else {
                self.correctNotes = []
            }
        case .allDegrees:
            // Exclude octave for "all tones" - just want the unique pitch classes
            self.correctNotes = Array(scale.scaleNotes.dropLast())
        case .earTraining:
            // For ear training, correct notes are all scale tones (for playback reference)
            self.correctNotes = scale.scaleNotes
        }
    }
    
    var questionText: String {
        switch questionType {
        case .singleDegree:
            if let degree = targetDegree {
                return "Find the \(degree.name) of \(scale.displayName)"
            }
            return "Find the note in \(scale.displayName)"
        case .allDegrees:
            return "Select all notes in \(scale.displayName)"
        case .earTraining:
            return "What scale did you hear?"
        }
    }
    
    /// Check if the user's answer is correct using pitch-class comparison
    func checkAnswer(_ userNotes: Set<Note>) -> Bool {
        let correctPitchClasses = Set(correctNotes.map { $0.pitchClass })
        let userPitchClasses = Set(userNotes.map { $0.pitchClass })
        return correctPitchClasses == userPitchClasses
    }
}

// MARK: - Scale Quiz Result

struct ScaleQuizResult: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let totalTime: TimeInterval
    let difficulty: ScaleType.ScaleDifficulty
    let questionTypes: [ScaleQuestionType]
    let ratingChange: Int
    let scaleTypes: [String]
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    var averageTimePerQuestion: TimeInterval {
        guard totalQuestions > 0 else { return 0 }
        return totalTime / Double(totalQuestions)
    }
}
