import Foundation

// MARK: - Scale Degree Model

struct ScaleDegree: Identifiable, Hashable, Codable {
    let id = UUID()
    let degree: Int           // 1-8 (1 = root, 8 = octave)
    let name: String          // "Root", "2nd", "b3", "#4", etc.
    let semitonesFromRoot: Int
    let isAltered: Bool
    
    static let root = ScaleDegree(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false)
    static let flatTwo = ScaleDegree(degree: 2, name: "b2", semitonesFromRoot: 1, isAltered: true)
    static let second = ScaleDegree(degree: 2, name: "2nd", semitonesFromRoot: 2, isAltered: false)
    static let sharpTwo = ScaleDegree(degree: 2, name: "#2", semitonesFromRoot: 3, isAltered: true)
    static let flatThird = ScaleDegree(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true)
    static let third = ScaleDegree(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false)
    static let flatFour = ScaleDegree(degree: 4, name: "b4", semitonesFromRoot: 4, isAltered: true)
    static let fourth = ScaleDegree(degree: 4, name: "4th", semitonesFromRoot: 5, isAltered: false)
    static let sharpFour = ScaleDegree(degree: 4, name: "#4", semitonesFromRoot: 6, isAltered: true)
    static let flatFive = ScaleDegree(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true)
    static let fifth = ScaleDegree(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false)
    static let sharpFive = ScaleDegree(degree: 5, name: "#5", semitonesFromRoot: 8, isAltered: true)
    static let flatSix = ScaleDegree(degree: 6, name: "b6", semitonesFromRoot: 8, isAltered: true)
    static let sixth = ScaleDegree(degree: 6, name: "6th", semitonesFromRoot: 9, isAltered: false)
    static let flatSeven = ScaleDegree(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
    static let seventh = ScaleDegree(degree: 7, name: "7th", semitonesFromRoot: 11, isAltered: false)
    static let octave = ScaleDegree(degree: 8, name: "Octave", semitonesFromRoot: 12, isAltered: false)
    
    // For diminished scales
    static let dimSeven = ScaleDegree(degree: 7, name: "bb7", semitonesFromRoot: 9, isAltered: true)
}

// MARK: - Scale Type Model

struct ScaleType: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String          // "Major", "Dorian", etc.
    let symbol: String        // Short identifier for display
    let degrees: [ScaleDegree]
    let difficulty: ScaleDifficulty
    let description: String   // Brief theory description
    
    init(name: String, symbol: String, degrees: [ScaleDegree], difficulty: ScaleDifficulty, description: String = "") {
        self.id = UUID()
        self.name = name
        self.symbol = symbol
        self.degrees = degrees
        self.difficulty = difficulty
        self.description = description
    }
    
    enum ScaleDifficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case custom = "Custom"
        
        var description: String {
            switch self {
            case .beginner:
                return "Major, Minor, Pentatonic"
            case .intermediate:
                return "Modes, Blues, Melodic Minor"
            case .advanced:
                return "All scale types"
            case .custom:
                return "Choose your own scale types"
            }
        }
    }
}

// MARK: - Scale Model

struct Scale: Identifiable, Hashable, Codable {
    let id = UUID()
    let root: Note
    let scaleType: ScaleType
    let scaleNotes: [Note]
    
    var displayName: String {
        return "\(root.name) \(scaleType.name)"
    }
    
    var shortName: String {
        return "\(root.name) \(scaleType.symbol)"
    }
    
    init(root: Note, scaleType: ScaleType) {
        self.root = root
        self.scaleType = scaleType
        
        // Determine tonality preference based on root note and scale type
        // For minor scales, consider the relative major's key signature
        let preferSharps: Bool
        
        // Check if root note itself is a flat
        if root.name.contains("b") {
            preferSharps = false
        } else if root.isSharp || root.name.contains("#") {
            preferSharps = true
        } else {
            // Natural note roots - determine based on common key signatures
            // Check if this is a minor-type scale (has flat third)
            let isMinorType = scaleType.degrees.contains(where: { $0.semitonesFromRoot == 3 })
            
            if isMinorType {
                // For minor scales, use the relative major's key signature
                // Relative major is up a minor 3rd (3 semitones)
                // Minor roots and their relative majors:
                // A minor -> C major (no accidentals) - sharps OK
                // E minor -> G major (1 sharp) - prefer sharps
                // B minor -> D major (2 sharps) - prefer sharps
                // F# minor -> A major (3 sharps) - prefer sharps
                // D minor -> F major (1 flat) - prefer flats
                // G minor -> Bb major (2 flats) - prefer flats
                // C minor -> Eb major (3 flats) - prefer flats
                // F minor -> Ab major (4 flats) - prefer flats
                let flatMinorRoots = ["D", "G", "C", "F"]
                preferSharps = !flatMinorRoots.contains(root.name)
            } else {
                // For major scales and modes, use standard key signature logic
                // Sharp keys: G, D, A, E, B
                let sharpRoots = ["G", "D", "A", "E", "B"]
                preferSharps = sharpRoots.contains(root.name) || root.name == "C"
            }
        }
        
        // Calculate scale notes based on root and scale type
        var notes: [Note] = []
        for degree in scaleType.degrees {
            let midiNumber = root.midiNumber + degree.semitonesFromRoot
            if let note = Note.noteFromMidi(midiNumber, preferSharps: preferSharps) {
                notes.append(note)
            }
        }
        self.scaleNotes = notes
    }
    
    /// Returns the note for a specific scale degree, or nil if not found
    func note(for degree: ScaleDegree) -> Note? {
        guard let index = scaleType.degrees.firstIndex(where: { $0.semitonesFromRoot == degree.semitonesFromRoot }) else {
            return nil
        }
        guard index < scaleNotes.count else { return nil }
        return scaleNotes[index]
    }
    
    /// Returns all notes in ascending order, including octave
    func notesAscending() -> [Note] {
        return scaleNotes
    }
    
    /// Returns all notes in descending order (from octave back to root)
    func notesDescending() -> [Note] {
        return scaleNotes.reversed()
    }
    
    /// Returns notes ascending then descending (for scale playback)
    func notesAscendingDescending() -> [Note] {
        var notes = scaleNotes
        // Add descending, excluding the octave (already at top) and root (will end on root)
        let descending = Array(scaleNotes.dropLast().reversed().dropLast())
        notes.append(contentsOf: descending)
        return notes
    }
}

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
