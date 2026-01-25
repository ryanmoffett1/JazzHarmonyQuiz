import Foundation

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

/// Represents a musical interval type with its properties
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
