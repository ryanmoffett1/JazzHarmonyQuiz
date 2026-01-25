import Foundation

// Core model imports
// Note: IntervalQuality, IntervalDifficulty, IntervalType, IntervalDirection, and Interval 
// have been moved to Core/Models/Interval.swift

// MARK: - Question Types

/// Types of interval questions
enum IntervalQuestionType: String, Codable, CaseIterable {
    case identifyInterval = "Identify Interval"    // See two notes, name the interval
    case buildInterval = "Build Interval"          // Given root + interval, find the note
    case auralIdentify = "Ear Training"            // Hear interval, identify it
    
    var description: String {
        switch self {
        case .identifyInterval:
            return "Name the interval between two notes"
        case .buildInterval:
            return "Find the note that creates the interval"
        case .auralIdentify:
            return "Identify the interval by ear"
        }
    }
    
    var icon: String {
        switch self {
        case .identifyInterval: return "eyes"
        case .buildInterval: return "hammer"
        case .auralIdentify: return "ear"
        }
    }
}

// MARK: - Interval Question

/// A quiz question about intervals
struct IntervalQuestion: Identifiable {
    let id = UUID()
    let interval: Interval
    let questionType: IntervalQuestionType
    
    /// The correct answer note (for build questions)
    var correctNote: Note {
        interval.targetNote
    }
    
    /// Check if user's answer is correct (pitch-class comparison)
    func isCorrect(userAnswer: Note) -> Bool {
        userAnswer.pitchClass == correctNote.pitchClass
    }
    
    /// Check if user identified the correct interval type
    func isCorrect(userAnswer: IntervalType) -> Bool {
        userAnswer.semitones == interval.intervalType.semitones
    }
    
    /// Question text based on type
    var questionText: String {
        let directionText = interval.direction == .descending ? "below" : "above"
        let directionArrow = interval.direction == .descending ? "↓" : "↑"
        
        switch questionType {
        case .identifyInterval:
            // Show direction clearly so user knows which way to count
            return "What interval is \(interval.rootNote.name) \(directionArrow) \(interval.targetNote.name)?"
        case .buildInterval:
            return "Find the \(interval.intervalType.name) \(directionText) \(interval.rootNote.name)"
        case .auralIdentify:
            return "What interval did you hear?"
        }
    }
    
    /// Hint text for the question
    var hintText: String {
        switch questionType {
        case .identifyInterval:
            return "Count the semitones between the two notes"
        case .buildInterval:
            return "\(interval.intervalType.shortName) = \(interval.intervalType.semitones) semitones"
        case .auralIdentify:
            return "Listen carefully to the distance between the notes"
        }
    }
}

// MARK: - Quiz Result

/// Results from an interval quiz session
struct IntervalQuizResult: Identifiable, Codable {
    let id: UUID
    let date: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let totalTime: TimeInterval
    let difficulty: IntervalDifficulty
    let questionTypes: [IntervalQuestionType]
    let ratingChange: Int
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    var averageTimePerQuestion: TimeInterval {
        guard totalQuestions > 0 else { return 0 }
        return totalTime / Double(totalQuestions)
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalQuestions: Int,
        correctAnswers: Int,
        totalTime: TimeInterval,
        difficulty: IntervalDifficulty,
        questionTypes: [IntervalQuestionType],
        ratingChange: Int = 0
    ) {
        self.id = id
        self.date = date
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.totalTime = totalTime
        self.difficulty = difficulty
        self.questionTypes = questionTypes
        self.ratingChange = ratingChange
    }
}

// MARK: - Answered Question (for review)

/// Stores a question and the user's answer for review
struct AnsweredIntervalQuestion: Identifiable {
    let id = UUID()
    let question: IntervalQuestion
    let userAnswer: Note?           // For build questions
    let userIntervalAnswer: IntervalType?  // For identify questions
    let wasCorrect: Bool
    let timeTaken: TimeInterval
}
