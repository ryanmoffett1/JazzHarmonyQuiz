import Foundation

// MARK: - Interval Quality

/// The quality of a musical interval
enum IntervalQuality: String, Codable, CaseIterable {
    case perfect = "Perfect"
    case major = "Major"
    case minor = "Minor"
    case augmented = "Augmented"
    case diminished = "Diminished"
    
    var abbreviation: String {
        switch self {
        case .perfect: return "P"
        case .major: return "M"
        case .minor: return "m"
        case .augmented: return "A"
        case .diminished: return "d"
        }
    }
}

// MARK: - Interval Difficulty

/// Difficulty levels for interval questions
enum IntervalDifficulty: String, Codable, CaseIterable, Comparable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    static func < (lhs: IntervalDifficulty, rhs: IntervalDifficulty) -> Bool {
        let order: [IntervalDifficulty] = [.beginner, .intermediate, .advanced]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Interval Type

/// Represents a musical interval with its properties
struct IntervalType: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String           // "Minor Third", "Perfect Fifth"
    let shortName: String      // "m3", "P5"
    let semitones: Int         // Distance in semitones
    let quality: IntervalQuality
    let number: Int            // Interval number (1-13)
    let difficulty: IntervalDifficulty
    
    init(
        id: UUID = UUID(),
        name: String,
        shortName: String,
        semitones: Int,
        quality: IntervalQuality,
        number: Int,
        difficulty: IntervalDifficulty
    ) {
        self.id = id
        self.name = name
        self.shortName = shortName
        self.semitones = semitones
        self.quality = quality
        self.number = number
        self.difficulty = difficulty
    }
    
    static func == (lhs: IntervalType, rhs: IntervalType) -> Bool {
        lhs.semitones == rhs.semitones
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(semitones)
    }
}

// MARK: - Interval Direction

/// Direction of an interval (ascending or descending)
enum IntervalDirection: String, Codable, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
    case both = "Both"
    
    var icon: String {
        switch self {
        case .ascending: return "arrow.up"
        case .descending: return "arrow.down"
        case .both: return "arrow.up.arrow.down"
        }
    }
}

// MARK: - Interval Instance

/// A specific interval between two notes
struct Interval: Identifiable {
    let id = UUID()
    let rootNote: Note
    let intervalType: IntervalType
    let direction: IntervalDirection
    
    /// The second note of the interval
    var targetNote: Note {
        let semitoneOffset = direction == .descending ? -intervalType.semitones : intervalType.semitones
        let targetMidi = rootNote.midiNumber + semitoneOffset
        return Note.noteFromMidi(targetMidi) ?? rootNote
    }
    
    /// Display name (e.g., "C to E - Major Third")
    var displayName: String {
        "\(rootNote.name) to \(targetNote.name) - \(intervalType.name)"
    }
    
    /// Short display (e.g., "C → E")
    var shortDisplay: String {
        let arrow = direction == .descending ? "↓" : "↑"
        return "\(rootNote.name) \(arrow) \(targetNote.name)"
    }
}

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
