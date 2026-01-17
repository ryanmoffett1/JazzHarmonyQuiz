import Foundation

// MARK: - Note and Chord Tone Models
struct Note: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    let midiNumber: Int
    let isSharp: Bool
    
    /// Returns the pitch class (0-11) for octave-agnostic comparison
    var pitchClass: Int {
        return midiNumber % 12
    }
    
    // Custom hash implementation based on MIDI number only
    func hash(into hasher: inout Hasher) {
        hasher.combine(midiNumber)
    }
    
    // Custom equality based on MIDI number only
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.midiNumber == rhs.midiNumber
    }
    
    static let allNotes: [Note] = [
        Note(name: "C", midiNumber: 60, isSharp: false),
        Note(name: "C#", midiNumber: 61, isSharp: true),
        Note(name: "Db", midiNumber: 61, isSharp: false),
        Note(name: "D", midiNumber: 62, isSharp: false),
        Note(name: "D#", midiNumber: 63, isSharp: true),
        Note(name: "Eb", midiNumber: 63, isSharp: false),
        Note(name: "E", midiNumber: 64, isSharp: false),
        Note(name: "F", midiNumber: 65, isSharp: false),
        Note(name: "F#", midiNumber: 66, isSharp: true),
        Note(name: "Gb", midiNumber: 66, isSharp: false),
        Note(name: "G", midiNumber: 67, isSharp: false),
        Note(name: "G#", midiNumber: 68, isSharp: true),
        Note(name: "Ab", midiNumber: 68, isSharp: false),
        Note(name: "A", midiNumber: 69, isSharp: false),
        Note(name: "A#", midiNumber: 70, isSharp: true),
        Note(name: "Bb", midiNumber: 70, isSharp: false),
        Note(name: "B", midiNumber: 71, isSharp: false)
    ]
    
    static func noteFromMidi(_ midiNumber: Int, preferSharps: Bool = true) -> Note? {
        // Handle octave wrapping - map to the base octave (60-71)
        let baseMidiNumber = ((midiNumber - 60) % 12) + 60
        
        // For black keys (enharmonic notes), choose based on tonality preference
        let candidates = allNotes.filter { $0.midiNumber == baseMidiNumber }
        
        if candidates.count == 1 {
            return candidates.first
        } else if candidates.count > 1 {
            // Multiple enharmonic options - choose based on preference
            if preferSharps {
                return candidates.first { $0.isSharp } ?? candidates.first
            } else {
                return candidates.first { !$0.isSharp } ?? candidates.first
            }
        }
        
        return nil
    }
}

struct ChordTone: Identifiable, Hashable, Codable {
    let id = UUID()
    let degree: Int
    let name: String
    let semitonesFromRoot: Int
    let isAltered: Bool
    
    static let allTones: [ChordTone] = [
        ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
        ChordTone(degree: 2, name: "2nd", semitonesFromRoot: 2, isAltered: false),
        ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
        ChordTone(degree: 4, name: "4th", semitonesFromRoot: 5, isAltered: false),
        ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
        ChordTone(degree: 6, name: "6th", semitonesFromRoot: 9, isAltered: false),
        ChordTone(degree: 7, name: "7th", semitonesFromRoot: 11, isAltered: false),
        ChordTone(degree: 9, name: "9th", semitonesFromRoot: 2, isAltered: false),
        ChordTone(degree: 11, name: "11th", semitonesFromRoot: 5, isAltered: false),
        ChordTone(degree: 13, name: "13th", semitonesFromRoot: 9, isAltered: false),
        
        // Altered tones
        ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true),
        ChordTone(degree: 2, name: "#9", semitonesFromRoot: 3, isAltered: true),
        ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true),
        ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true),
        ChordTone(degree: 5, name: "#5", semitonesFromRoot: 8, isAltered: true),
        ChordTone(degree: 6, name: "b13", semitonesFromRoot: 8, isAltered: true),
        ChordTone(degree: 6, name: "#13", semitonesFromRoot: 10, isAltered: true),
        ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
    ]
}

// MARK: - Chord Type Model
struct ChordType: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let symbol: String
    let chordTones: [ChordTone]
    let difficulty: ChordDifficulty
    
    init(name: String, symbol: String, chordTones: [ChordTone], difficulty: ChordDifficulty) {
        self.id = UUID()
        self.name = name
        self.symbol = symbol
        self.chordTones = chordTones
        self.difficulty = difficulty
    }
    
    enum ChordDifficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
    }
}

// MARK: - Chord Model
struct Chord: Identifiable, Hashable, Codable {
    let id = UUID()
    let root: Note
    let chordType: ChordType
    let chordTones: [Note]
    
    var displayName: String {
        return "\(root.name)\(chordType.symbol)"
    }
    
    var fullName: String {
        return "\(root.name) \(chordType.name)"
    }
    
    init(root: Note, chordType: ChordType) {
        self.root = root
        self.chordType = chordType
        
        // Determine tonality preference based on root note
        // Sharp roots (C#, D#, F#, G#, A#) and sharp-friendly keys (B, E, A, D, G) prefer sharps
        // Flat roots (Db, Eb, Gb, Ab, Bb) and flat-friendly keys (F, C) prefer flats
        let preferSharps = root.isSharp || ["B", "E", "A", "D", "G"].contains(root.name)
        
        // Calculate chord tones based on root and chord type
        var tones: [Note] = []
        for chordTone in chordType.chordTones {
            let midiNumber = root.midiNumber + chordTone.semitonesFromRoot
            if let note = Note.noteFromMidi(midiNumber, preferSharps: preferSharps) {
                tones.append(note)
            }
        }
        self.chordTones = tones
    }
    
    func getChordTone(by degree: Int, isAltered: Bool = false) -> Note? {
        let targetTone = ChordTone.allTones.first {
            $0.degree == degree && $0.isAltered == isAltered
        }
        
        guard let tone = targetTone else { return nil }
        
        let preferSharps = root.isSharp || ["B", "E", "A", "D", "G"].contains(root.name)
        let midiNumber = root.midiNumber + tone.semitonesFromRoot
        return Note.noteFromMidi(midiNumber, preferSharps: preferSharps)
    }
    
    func getChordTone(by name: String) -> Note? {
        let targetTone = ChordTone.allTones.first { $0.name == name }
        
        guard let tone = targetTone else { return nil }
        
        let preferSharps = root.isSharp || ["B", "E", "A", "D", "G"].contains(root.name)
        let midiNumber = root.midiNumber + tone.semitonesFromRoot
        return Note.noteFromMidi(midiNumber, preferSharps: preferSharps)
    }
    
    /// Find notes that are common between this chord and another chord (using pitch class comparison)
    func commonTones(with other: Chord) -> [Note] {
        let myNotes = self.chordTones
        let otherNotes = other.chordTones
        
        // Convert to pitch classes for comparison (0-11)
        let myPitchClasses = Set(myNotes.map { $0.pitchClass })
        let otherPitchClasses = Set(otherNotes.map { $0.pitchClass })
        
        // Find intersection
        let commonPitchClasses = myPitchClasses.intersection(otherPitchClasses)
        
        // Return the notes from this chord that have common pitch classes
        return myNotes.filter { commonPitchClasses.contains($0.pitchClass) }
    }
}

// MARK: - Question Types
enum QuestionType: String, CaseIterable, Codable, Equatable {
    case singleTone = "Single Tone"
    case allTones = "All Tones"
    
    var description: String {
        switch self {
        case .singleTone:
            return "Identify a specific chord tone"
        case .allTones:
            return "Play all chord tones"
        }
    }
}

// MARK: - Quiz Question Model
struct QuizQuestion: Identifiable, Codable, Equatable {
    let id = UUID()
    let chord: Chord
    let questionType: QuestionType
    let targetTone: ChordTone?
    let correctAnswer: [Note]
    let timeLimit: TimeInterval
    
    init(chord: Chord, questionType: QuestionType, targetTone: ChordTone? = nil) {
        self.chord = chord
        self.questionType = questionType
        self.targetTone = targetTone
        
        switch questionType {
        case .singleTone:
            if let tone = targetTone {
                self.correctAnswer = [chord.getChordTone(by: tone.name) ?? chord.root]
            } else {
                self.correctAnswer = [chord.root]
            }
        case .allTones:
            self.correctAnswer = chord.chordTones
        }
        
        self.timeLimit = 30.0 // 30 seconds default
    }
}

// MARK: - Cadence Models

/// Drill mode determines how the cadence quiz is structured
enum CadenceDrillMode: String, CaseIterable, Codable, Equatable {
    case fullProgression = "Full Progression"
    case isolatedChord = "Isolated Chord"
    case speedRound = "Speed Round"
    case commonTones = "Common Tones"
    
    var description: String {
        switch self {
        case .fullProgression:
            return "Spell all 3 chords in the ii-V-I"
        case .isolatedChord:
            return "Focus on one chord position across all keys"
        case .speedRound:
            return "Timed challenge - spell each chord before time runs out!"
        case .commonTones:
            return "Identify notes shared between adjacent chords"
        }
    }
    
    /// Whether this mode has a per-chord timer
    var hasPerChordTimer: Bool {
        return self == .speedRound
    }
}

/// Which chord pair to find common tones between
enum CommonTonePair: String, CaseIterable, Codable, Equatable {
    case iiToV = "ii → V"
    case vToI = "V → I"
    case random = "Random"
    
    var description: String {
        switch self {
        case .iiToV: return "Find notes shared between ii and V chords"
        case .vToI: return "Find notes shared between V and I chords"
        case .random: return "Randomly choose chord pairs"
        }
    }
}

/// Which chord position to drill in isolated mode
enum IsolatedChordPosition: String, CaseIterable, Codable, Equatable {
    case ii = "ii Chord"
    case V = "V Chord"
    case I = "I Chord"
    
    var index: Int {
        switch self {
        case .ii: return 0
        case .V: return 1
        case .I: return 2
        }
    }
    
    var description: String {
        switch self {
        case .ii: return "Practice the ii chord (m7 or ø7)"
        case .V: return "Practice the V chord (7 or 7b9)"
        case .I: return "Practice the I chord (maj7 or m7)"
        }
    }
}

/// Extended V chord options for more advanced practice
enum ExtendedVChordOption: String, CaseIterable, Codable, Equatable {
    case basic = "V7"
    case ninth = "V9"
    case thirteenth = "V13"
    case flatNine = "V7b9"
    case sharpNine = "V7#9"
    
    var chordSymbol: String {
        switch self {
        case .basic: return "7"
        case .ninth: return "9"
        case .thirteenth: return "13"
        case .flatNine: return "7b9"
        case .sharpNine: return "7#9"
        }
    }
    
    var description: String {
        switch self {
        case .basic: return "Standard dominant 7th"
        case .ninth: return "Dominant with added 9th"
        case .thirteenth: return "Dominant with 9th and 13th"
        case .flatNine: return "Dominant with flat 9 (minor resolution)"
        case .sharpNine: return "Dominant with sharp 9 (Hendrix chord)"
        }
    }
}

/// Key difficulty tiers based on number of accidentals
enum KeyDifficulty: String, CaseIterable, Codable, Equatable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    case expert = "Expert"
    case all = "All Keys"
    
    var description: String {
        switch self {
        case .easy: return "C, F, G (0-1 accidentals)"
        case .medium: return "Bb, Eb, D, A (2-3 accidentals)"
        case .hard: return "Ab, Db, E, B (4-5 accidentals)"
        case .expert: return "F#/Gb (6 accidentals)"
        case .all: return "All 12 keys"
        }
    }
    
    /// Returns the root notes available for this difficulty tier
    var availableRoots: [Note] {
        switch self {
        case .easy:
            return [
                Note(name: "C", midiNumber: 60, isSharp: false),
                Note(name: "F", midiNumber: 65, isSharp: false),
                Note(name: "G", midiNumber: 67, isSharp: false)
            ]
        case .medium:
            return [
                Note(name: "Bb", midiNumber: 70, isSharp: false),
                Note(name: "Eb", midiNumber: 63, isSharp: false),
                Note(name: "D", midiNumber: 62, isSharp: false),
                Note(name: "A", midiNumber: 69, isSharp: false)
            ]
        case .hard:
            return [
                Note(name: "Ab", midiNumber: 68, isSharp: false),
                Note(name: "Db", midiNumber: 61, isSharp: false),
                Note(name: "E", midiNumber: 64, isSharp: false),
                Note(name: "B", midiNumber: 71, isSharp: false)
            ]
        case .expert:
            return [
                Note(name: "F#", midiNumber: 66, isSharp: true)
            ]
        case .all:
            return [
                Note(name: "C", midiNumber: 60, isSharp: false),
                Note(name: "Db", midiNumber: 61, isSharp: false),
                Note(name: "D", midiNumber: 62, isSharp: false),
                Note(name: "Eb", midiNumber: 63, isSharp: false),
                Note(name: "E", midiNumber: 64, isSharp: false),
                Note(name: "F", midiNumber: 65, isSharp: false),
                Note(name: "F#", midiNumber: 66, isSharp: true),
                Note(name: "G", midiNumber: 67, isSharp: false),
                Note(name: "Ab", midiNumber: 68, isSharp: false),
                Note(name: "A", midiNumber: 69, isSharp: false),
                Note(name: "Bb", midiNumber: 70, isSharp: false),
                Note(name: "B", midiNumber: 71, isSharp: false)
            ]
        }
    }
}

enum CadenceType: String, CaseIterable, Codable, Equatable {
    case major = "Major ii-V-I"
    case minor = "Minor ii-V-I"
    case tritoneSubstitution = "Tritone Sub"
    case backdoor = "Backdoor ii-V"
    case birdChanges = "Bird Changes"

    var description: String {
        switch self {
        case .major:
            return "Major resolution (iim7, V7, Imaj7)"
        case .minor:
            return "Minor resolution (iiø7, V7b9, im7)"
        case .tritoneSubstitution:
            return "Tritone sub (iim7, bII7, Imaj7)"
        case .backdoor:
            return "Backdoor resolution (ivm7, bVII7, Imaj7)"
        case .birdChanges:
            return "Bird changes (iiim7, VI7, iim7, V7, Imaj7)"
        }
    }
    
    /// Returns the number of chords in this cadence type
    var chordCount: Int {
        switch self {
        case .birdChanges:
            return 5  // iiim7, VI7, iim7, V7, Imaj7
        default:
            return 3
        }
    }
}

// Represents a ii-V-I progression
struct CadenceProgression: Identifiable, Codable, Equatable {
    let id = UUID()
    let key: Note
    let cadenceType: CadenceType
    let chords: [Chord] // Array of chords in progression
    let extendedVChord: ExtendedVChordOption?

    var displayName: String {
        return "\(key.name) \(cadenceType.rawValue)"
    }
    
    init(key: Note, cadenceType: CadenceType) {
        self.init(key: key, cadenceType: cadenceType, extendedVChord: nil)
    }

    init(key: Note, cadenceType: CadenceType, extendedVChord: ExtendedVChordOption?) {
        self.key = key
        self.cadenceType = cadenceType
        self.extendedVChord = extendedVChord

        // Generate the chords based on the cadence type
        var generatedChords: [Chord] = []

        // Determine tonality preference based on key
        let preferSharps = key.isSharp || ["B", "E", "A", "D", "G"].contains(key.name)
        
        // Helper to safely get chord type with fallback
        let database = JazzChordDatabase.shared
        
        // Create fallback chord type for safety
        let fallbackChordType = ChordType(
            name: "Major",
            symbol: "",
            chordTones: [ChordTone.allTones[0], ChordTone.allTones[2], ChordTone.allTones[4]],
            difficulty: .beginner
        )
        
        // Helper to get V chord type based on extended option
        func getVChordType(forMinor: Bool = false) -> ChordType {
            if let extended = extendedVChord, extended != .basic {
                return database.getChordType(symbol: extended.chordSymbol)
                    ?? database.getChordType(symbol: "7")
                    ?? fallbackChordType
            } else if forMinor {
                // For minor, use b9 80% of the time
                let useAlteredV = Double.random(in: 0...1) < 0.8
                return useAlteredV
                    ? (database.getChordType(symbol: "7b9") ?? database.getChordType(symbol: "7") ?? fallbackChordType)
                    : (database.getChordType(symbol: "7") ?? fallbackChordType)
            } else {
                return database.getChordType(symbol: "7") ?? fallbackChordType
            }
        }

        switch cadenceType {
        case .major:
            // Major ii-V-I: iim7, V7 (or extended), Imaj7
            // ii chord: 2 semitones above tonic
            let iiRoot = Note.noteFromMidi(key.midiNumber + 2, preferSharps: preferSharps) ?? key
            let iiChordType = database.getChordType(symbol: "m7") ?? fallbackChordType
            let iiChord = Chord(root: iiRoot, chordType: iiChordType)

            // V chord: 7 semitones above tonic (uses extended option if set)
            let vRoot = Note.noteFromMidi(key.midiNumber + 7, preferSharps: preferSharps) ?? key
            let vChordType = getVChordType(forMinor: false)
            let vChord = Chord(root: vRoot, chordType: vChordType)

            // I chord: tonic
            let iChordType = database.getChordType(symbol: "maj7") ?? fallbackChordType
            let iChord = Chord(root: key, chordType: iChordType)

            generatedChords = [iiChord, vChord, iChord]

        case .minor:
            // Minor ii-V-I: iiø7 (half-diminished), V7b9 (or extended), im7
            // ii chord: 2 semitones above tonic
            let iiRoot = Note.noteFromMidi(key.midiNumber + 2, preferSharps: preferSharps) ?? key
            // Use half-diminished (ø7) for the ii chord in minor
            let iiChordType = database.getChordType(symbol: "ø7") ?? fallbackChordType
            let iiChord = Chord(root: iiRoot, chordType: iiChordType)

            // V chord: 7 semitones above tonic (uses extended option if set, otherwise b9 by default)
            let vRoot = Note.noteFromMidi(key.midiNumber + 7, preferSharps: preferSharps) ?? key
            let vChordType = getVChordType(forMinor: true)
            let vChord = Chord(root: vRoot, chordType: vChordType)

            // i chord: tonic minor 7
            let iChordType = database.getChordType(symbol: "m7") ?? fallbackChordType
            let iChord = Chord(root: key, chordType: iChordType)

            generatedChords = [iiChord, vChord, iChord]
            
        case .tritoneSubstitution:
            // Tritone Substitution: iim7, bII7 (SubV7), Imaj7
            // The bII7 is a tritone substitution for V7 - creates chromatic bass line
            
            // ii chord: 2 semitones above tonic
            let iiRoot = Note.noteFromMidi(key.midiNumber + 2, preferSharps: preferSharps) ?? key
            let iiChordType = database.getChordType(symbol: "m7") ?? fallbackChordType
            let iiChord = Chord(root: iiRoot, chordType: iiChordType)

            // bII7 chord (SubV7): 1 semitone above tonic
            // This is the tritone substitution for V7
            let subVRoot = Note.noteFromMidi(key.midiNumber + 1, preferSharps: false) ?? key
            let subVChordType = database.getChordType(symbol: "7") ?? fallbackChordType
            let subVChord = Chord(root: subVRoot, chordType: subVChordType)

            // I chord: tonic major 7
            let iChordType = database.getChordType(symbol: "maj7") ?? fallbackChordType
            let iChord = Chord(root: key, chordType: iChordType)

            generatedChords = [iiChord, subVChord, iChord]
            
        case .backdoor:
            // Backdoor ii-V: ivm7, bVII7, Imaj7
            // Alternative resolution that approaches I from a half-step above
            
            // iv chord: 5 semitones above tonic (perfect 4th)
            let ivRoot = Note.noteFromMidi(key.midiNumber + 5, preferSharps: preferSharps) ?? key
            let ivChordType = database.getChordType(symbol: "m7") ?? fallbackChordType
            let ivChord = Chord(root: ivRoot, chordType: ivChordType)

            // bVII7 chord: 10 semitones above tonic (minor 7th interval)
            let bVIIRoot = Note.noteFromMidi(key.midiNumber + 10, preferSharps: false) ?? key
            let bVIIChordType = database.getChordType(symbol: "7") ?? fallbackChordType
            let bVIIChord = Chord(root: bVIIRoot, chordType: bVIIChordType)

            // I chord: tonic major 7
            let iChordType = database.getChordType(symbol: "maj7") ?? fallbackChordType
            let iChord = Chord(root: key, chordType: iChordType)

            generatedChords = [ivChord, bVIIChord, iChord]
            
        case .birdChanges:
            // Bird Changes (Confirmation changes): iiim7, VI7, iim7, V7, Imaj7
            // Extended turnaround commonly found in jazz standards like "Confirmation"
            
            // iii chord: 4 semitones above tonic (major 3rd)
            let iiiRoot = Note.noteFromMidi(key.midiNumber + 4, preferSharps: preferSharps) ?? key
            let iiiChordType = database.getChordType(symbol: "m7") ?? fallbackChordType
            let iiiChord = Chord(root: iiiRoot, chordType: iiiChordType)
            
            // VI7 chord: 9 semitones above tonic (major 6th)
            // This is a secondary dominant (V of ii)
            let viRoot = Note.noteFromMidi(key.midiNumber + 9, preferSharps: preferSharps) ?? key
            let viChordType = database.getChordType(symbol: "7") ?? fallbackChordType
            let viChord = Chord(root: viRoot, chordType: viChordType)
            
            // ii chord: 2 semitones above tonic
            let iiRoot = Note.noteFromMidi(key.midiNumber + 2, preferSharps: preferSharps) ?? key
            let iiChordType = database.getChordType(symbol: "m7") ?? fallbackChordType
            let iiChord = Chord(root: iiRoot, chordType: iiChordType)
            
            // V7 chord: 7 semitones above tonic (uses extended option if set)
            let vRoot = Note.noteFromMidi(key.midiNumber + 7, preferSharps: preferSharps) ?? key
            let vChordType = getVChordType(forMinor: false)
            let vChord = Chord(root: vRoot, chordType: vChordType)
            
            // I chord: tonic major 7
            let iChordType = database.getChordType(symbol: "maj7") ?? fallbackChordType
            let iChord = Chord(root: key, chordType: iChordType)
            
            generatedChords = [iiiChord, viChord, iiChord, vChord, iChord]
        }

        self.chords = generatedChords
    }
}

// Cadence question for the quiz
struct CadenceQuestion: Identifiable, Codable, Equatable {
    let id = UUID()
    let cadence: CadenceProgression
    let correctAnswers: [[Note]] // Array of chord spellings (or common tones for common tones mode)
    let timeLimit: TimeInterval
    let drillMode: CadenceDrillMode
    let isolatedPosition: IsolatedChordPosition?
    let commonTonePair: CommonTonePair?  // For common tones mode
    
    /// The chord(s) the user needs to spell for this question
    var chordsToSpell: [Chord] {
        switch drillMode {
        case .fullProgression, .speedRound:
            return cadence.chords
        case .isolatedChord:
            guard let position = isolatedPosition else { return cadence.chords }
            let index = min(position.index, cadence.chords.count - 1)
            return [cadence.chords[index]]
        case .commonTones:
            // Return the two chords being compared
            guard let pair = commonTonePair, cadence.chords.count >= 3 else { return [] }
            switch pair {
            case .iiToV:
                return [cadence.chords[0], cadence.chords[1]]
            case .vToI:
                return [cadence.chords[1], cadence.chords[2]]
            case .random:
                return [cadence.chords[0], cadence.chords[1]] // Default to ii-V
            }
        }
    }
    
    /// The correct answer(s) for this question
    var expectedAnswers: [[Note]] {
        switch drillMode {
        case .fullProgression, .speedRound:
            return correctAnswers
        case .isolatedChord:
            guard let position = isolatedPosition else { return correctAnswers }
            let index = min(position.index, correctAnswers.count - 1)
            return [correctAnswers[index]]
        case .commonTones:
            // For common tones, correctAnswers[0] contains the common tones
            return correctAnswers.isEmpty ? [[]] : [correctAnswers[0]]
        }
    }
    
    /// Display text for the question
    var questionText: String {
        switch drillMode {
        case .fullProgression, .speedRound:
            return "Spell all chords in the progression"
        case .isolatedChord:
            guard let position = isolatedPosition else { return "Spell the chord" }
            return "Spell the \(position.rawValue)"
        case .commonTones:
            guard let pair = commonTonePair else { return "Find the common tones" }
            let chords = chordsToSpell
            if chords.count >= 2 {
                return "Find notes shared between \(chords[0].displayName) and \(chords[1].displayName)"
            }
            return "Find the common tones between \(pair.rawValue)"
        }
    }

    init(cadence: CadenceProgression) {
        self.cadence = cadence
        self.correctAnswers = cadence.chords.map { $0.chordTones }
        self.timeLimit = 60.0
        self.drillMode = .fullProgression
        self.isolatedPosition = nil
        self.commonTonePair = nil
    }
    
    init(cadence: CadenceProgression, drillMode: CadenceDrillMode, isolatedPosition: IsolatedChordPosition?) {
        self.cadence = cadence
        self.drillMode = drillMode
        self.isolatedPosition = isolatedPosition
        self.commonTonePair = nil
        
        // Calculate correct answers based on mode
        self.correctAnswers = cadence.chords.map { $0.chordTones }
        
        // Shorter time limit for isolated chord mode
        switch drillMode {
        case .fullProgression:
            self.timeLimit = 60.0
        case .isolatedChord:
            self.timeLimit = 20.0
        case .speedRound:
            self.timeLimit = 5.0
        case .commonTones:
            self.timeLimit = 30.0
        }
    }
    
    init(cadence: CadenceProgression, commonTonePair: CommonTonePair) {
        self.cadence = cadence
        self.drillMode = .commonTones
        self.isolatedPosition = nil
        self.commonTonePair = commonTonePair
        self.timeLimit = 30.0
        
        // Calculate common tones between the chord pair
        guard cadence.chords.count >= 3 else {
            self.correctAnswers = [[]]
            return
        }
        
        let commonTones: [Note]
        switch commonTonePair {
        case .iiToV:
            commonTones = cadence.chords[0].commonTones(with: cadence.chords[1])
        case .vToI:
            commonTones = cadence.chords[1].commonTones(with: cadence.chords[2])
        case .random:
            // Randomly pick one
            if Bool.random() {
                commonTones = cadence.chords[0].commonTones(with: cadence.chords[1])
            } else {
                commonTones = cadence.chords[1].commonTones(with: cadence.chords[2])
            }
        }
        self.correctAnswers = [commonTones]
    }
}

// Cadence quiz result
struct CadenceResult: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let totalTime: TimeInterval
    let questions: [CadenceQuestion]
    let userAnswers: [String: [[Note]]] // Question ID to array of 3 chord spellings
    let isCorrect: [String: Bool] // Question ID to correctness
    let cadenceType: CadenceType

    init(date: Date, totalQuestions: Int, correctAnswers: Int, totalTime: TimeInterval, questions: [CadenceQuestion], userAnswers: [UUID: [[Note]]], isCorrect: [UUID: Bool], cadenceType: CadenceType) {
        self.id = UUID()
        self.date = date
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.totalTime = totalTime
        self.questions = questions
        self.userAnswers = Dictionary(uniqueKeysWithValues: userAnswers.map { ($0.key.uuidString, $0.value) })
        self.isCorrect = Dictionary(uniqueKeysWithValues: isCorrect.map { ($0.key.uuidString, $0.value) })
        self.cadenceType = cadenceType
    }

    var accuracy: Double {
        return Double(correctAnswers) / Double(totalQuestions)
    }

    var averageTimePerQuestion: TimeInterval {
        return totalTime / Double(totalQuestions)
    }

    var score: Int {
        return Int(accuracy * 100)
    }

    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, date, totalQuestions, correctAnswers, totalTime, questions, userAnswers, isCorrect, cadenceType
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try container.decode(UUID.self, forKey: .id)
        self.date = try container.decode(Date.self, forKey: .date)
        self.totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        self.correctAnswers = try container.decode(Int.self, forKey: .correctAnswers)
        self.totalTime = try container.decode(TimeInterval.self, forKey: .totalTime)
        self.questions = try container.decode([CadenceQuestion].self, forKey: .questions)
        self.userAnswers = try container.decode([String: [[Note]]].self, forKey: .userAnswers)
        self.isCorrect = try container.decode([String: Bool].self, forKey: .isCorrect)
        self.cadenceType = try container.decode(CadenceType.self, forKey: .cadenceType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(totalQuestions, forKey: .totalQuestions)
        try container.encode(correctAnswers, forKey: .correctAnswers)
        try container.encode(totalTime, forKey: .totalTime)
        try container.encode(questions, forKey: .questions)
        try container.encode(userAnswers, forKey: .userAnswers)
        try container.encode(isCorrect, forKey: .isCorrect)
        try container.encode(cadenceType, forKey: .cadenceType)
    }
}

// MARK: - Quiz Result Model
struct QuizResult: Identifiable, Codable, Equatable {
    let id: UUID
    let date: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let totalTime: TimeInterval
    let questions: [QuizQuestion]
    let userAnswers: [String: [Note]] // Question ID to user's answer
    let isCorrect: [String: Bool] // Question ID to correctness
    
    init(date: Date, totalQuestions: Int, correctAnswers: Int, totalTime: TimeInterval, questions: [QuizQuestion], userAnswers: [UUID: [Note]], isCorrect: [UUID: Bool]) {
        self.id = UUID()
        self.date = date
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.totalTime = totalTime
        self.questions = questions
        self.userAnswers = Dictionary(uniqueKeysWithValues: userAnswers.map { ($0.key.uuidString, $0.value) })
        self.isCorrect = Dictionary(uniqueKeysWithValues: isCorrect.map { ($0.key.uuidString, $0.value) })
    }
    
    var accuracy: Double {
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    var averageTimePerQuestion: TimeInterval {
        return totalTime / Double(totalQuestions)
    }
    
    var score: Int {
        return Int(accuracy * 100)
    }
    
    // MARK: - Codable Implementation
    enum CodingKeys: String, CodingKey {
        case id, date, totalQuestions, correctAnswers, totalTime, questions, userAnswers, isCorrect
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.date = try container.decode(Date.self, forKey: .date)
        self.totalQuestions = try container.decode(Int.self, forKey: .totalQuestions)
        self.correctAnswers = try container.decode(Int.self, forKey: .correctAnswers)
        self.totalTime = try container.decode(TimeInterval.self, forKey: .totalTime)
        self.questions = try container.decode([QuizQuestion].self, forKey: .questions)
        self.userAnswers = try container.decode([String: [Note]].self, forKey: .userAnswers)
        self.isCorrect = try container.decode([String: Bool].self, forKey: .isCorrect)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(totalQuestions, forKey: .totalQuestions)
        try container.encode(correctAnswers, forKey: .correctAnswers)
        try container.encode(totalTime, forKey: .totalTime)
        try container.encode(questions, forKey: .questions)
        try container.encode(userAnswers, forKey: .userAnswers)
        try container.encode(isCorrect, forKey: .isCorrect)
    }
}
