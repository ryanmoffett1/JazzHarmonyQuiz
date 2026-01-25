import Foundation

// Core model imports
// Note: Note, ChordTone, ChordType, and Chord have been moved to Core/Models/

// MARK: - Question Types
enum QuestionType: String, CaseIterable, Codable, Equatable {
    case singleTone = "Single Tone"
    case allTones = "All Tones"
    case auralQuality = "Identify Quality by Ear"
    case auralSpelling = "Spell Chord by Ear"

    var description: String {
        switch self {
        case .singleTone:
            return "Identify a specific chord tone"
        case .allTones:
            return "Play all chord tones"
        case .auralQuality:
            return "Hear a chord and identify its quality"
        case .auralSpelling:
            return "Given the root, hear quality and spell"
        }
    }

    var icon: String {
        switch self {
        case .singleTone: return "music.note"
        case .allTones: return "pianokeys"
        case .auralQuality, .auralSpelling: return "ear"
        }
    }
    
    /// Returns true if this is an aural (ear training) question type
    var isAural: Bool {
        switch self {
        case .auralQuality, .auralSpelling:
            return true
        case .singleTone, .allTones:
            return false
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
        case .allTones, .auralSpelling:
            self.correctAnswer = chord.chordTones
        case .auralQuality:
            // For quality recognition, the "answer" is the chord type
            // We store chord tones for display purposes after submission
            self.correctAnswer = chord.chordTones
        }

        // Longer time limit for aural questions
        self.timeLimit = questionType.isAural ? 45.0 : 30.0
    }
}

// MARK: - Cadence Models

/// Drill mode determines how the cadence quiz is structured
/// Simplified from 9 to 6 modes per DESIGN.md Section 7.5.2
enum CadenceDrillMode: String, CaseIterable, Codable, Equatable {
    case chordIdentification = "Chord Identification"
    case fullProgression = "Full Progression"
    case commonTones = "Common Tones"
    case auralIdentify = "Ear Training"
    case guideTones = "Guide Tones"
    case resolutionTargets = "Resolution Targets"
    
    // Removed modes (per DESIGN.md):
    // - isolatedChord: Consolidated into fullProgression with focus indicator
    // - speedRound: Integrated as timed option in any mode
    // - smoothVoicing: Moved to future Voice Leading module

    var description: String {
        switch self {
        case .chordIdentification:
            return "Identify chords by root and quality (e.g., F#m7 → B7 → Emaj7)"
        case .fullProgression:
            return "Spell all 3 chords in the ii-V-I"
        case .commonTones:
            return "Identify notes shared between adjacent chords"
        case .auralIdentify:
            return "Identify cadence by ear"
        case .guideTones:
            return "Play only the guide tones (3rd and 7th) for each chord"
        case .resolutionTargets:
            return "Find where guide tones resolve in the next chord"
        }
    }

    var icon: String {
        switch self {
        case .chordIdentification: return "music.note.list"
        case .fullProgression: return "pianokeys"
        case .commonTones: return "link"
        case .auralIdentify: return "ear"
        case .guideTones: return "circle.hexagongrid.fill"
        case .resolutionTargets: return "arrow.triangle.branch"
        }
    }
    
    /// Whether this mode uses chord selection (root+quality) instead of note spelling
    var usesChordSelection: Bool {
        return self == .chordIdentification
    }
    
    /// Icon for the drill mode button
    var iconName: String {
        switch self {
        case .chordIdentification: return "textformat.abc"
        case .fullProgression: return "music.note.list"
        case .commonTones: return "link"
        case .auralIdentify: return "ear"
        case .guideTones: return "circle.hexagongrid.fill"
        case .resolutionTargets: return "arrow.triangle.branch"
        }
    }

    /// Short name for compact display
    var shortName: String {
        switch self {
        case .chordIdentification: return "Chord ID"
        case .fullProgression: return "Full"
        case .commonTones: return "Common"
        case .auralIdentify: return "Ear"
        case .guideTones: return "Guides"
        case .resolutionTargets: return "Resolution"
        }
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

/// Voice motion for smooth voicing drills
enum VoiceMotion: String, CaseIterable, Codable, Equatable {
    case halfStepUp = "↑½"
    case halfStepDown = "↓½"
    case wholeStepUp = "↑1"
    case wholeStepDown = "↓1"
    case common = "="  // stays on same note
    
    var description: String {
        switch self {
        case .halfStepUp: return "Half-step up"
        case .halfStepDown: return "Half-step down"
        case .wholeStepUp: return "Whole-step up"
        case .wholeStepDown: return "Whole-step down"
        case .common: return "Common tone (no movement)"
        }
    }
    
    var semitones: Int {
        switch self {
        case .halfStepUp: return 1
        case .halfStepDown: return -1
        case .wholeStepUp: return 2
        case .wholeStepDown: return -2
        case .common: return 0
        }
    }
}

/// Voicing constraint for smooth voicing drills
struct VoicingConstraint: Codable, Equatable {
    let topVoiceMotion: VoiceMotion
    let maxTotalMotion: Int  // Maximum total semitones moved across all voices
    
    var description: String {
        "Top voice: \(topVoiceMotion.rawValue), max motion: \(maxTotalMotion) semitones"
    }
}

/// Represents a resolution pair for resolution target drills
struct ResolutionPair: Codable, Equatable, Identifiable {
    let id = UUID()
    let sourceNote: Note
    let targetNote: Note?  // nil if student needs to find it
    let sourceChordIndex: Int  // 0=ii, 1=V, 2=I
    let targetChordIndex: Int
    let sourceRole: ChordToneRole  // Is it the 3rd or 7th?
    
    var description: String {
        if let target = targetNote {
            return "\(sourceNote.name) (\(sourceRole.rawValue)) → \(target.name)"
        } else {
            return "\(sourceNote.name) (\(sourceRole.rawValue)) → ?"
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

    /// Icon for the cadence type button
    var iconName: String {
        switch self {
        case .major: return "music.note"
        case .minor: return "music.note.list"
        case .tritoneSubstitution: return "arrow.left.arrow.right"
        case .backdoor: return "arrow.uturn.backward"
        case .birdChanges: return "bird"
        }
    }

    /// Short name for compact display
    var shortName: String {
        switch self {
        case .major: return "Major"
        case .minor: return "Minor"
        case .tritoneSubstitution: return "Tritone"
        case .backdoor: return "Backdoor"
        case .birdChanges: return "Bird"
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
    
    // Guide tone drill properties
    let resolutionPairs: [ResolutionPair]?  // For resolution target drills
    let voicingConstraint: VoicingConstraint?  // For smooth voicing drills
    let currentResolutionIndex: Int?  // Which resolution pair is being asked
    
    /// The chord(s) the user needs to spell for this question
    var chordsToSpell: [Chord] {
        switch drillMode {
        case .fullProgression, .chordIdentification:
            return cadence.chords
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
        case .auralIdentify:
            // For ear training, return all chords
            return cadence.chords
        case .guideTones:
            // Return all three chords for guide tone spelling
            return cadence.chords
        case .resolutionTargets:
            // Return the two chords involved in the current resolution
            guard let pairs = resolutionPairs,
                  let index = currentResolutionIndex,
                  index < pairs.count else { return [] }
            let pair = pairs[index]
            return [cadence.chords[pair.sourceChordIndex], cadence.chords[pair.targetChordIndex]]
        }
    }
    
    /// The correct answer(s) for this question
    var expectedAnswers: [[Note]] {
        switch drillMode {
        case .fullProgression, .chordIdentification:
            return correctAnswers
        case .commonTones:
            // For common tones, correctAnswers[0] contains the common tones
            return correctAnswers.isEmpty ? [[]] : [correctAnswers[0]]
        case .auralIdentify:
            // For ear training, return all chords
            return correctAnswers
        case .guideTones:
            // For guide tones, correctAnswers contains guide tones for each chord
            return correctAnswers
        case .resolutionTargets:
            // For resolution targets, correctAnswers contains the target note
            guard let pairs = resolutionPairs,
                  let index = currentResolutionIndex,
                  index < pairs.count,
                  let targetNote = pairs[index].targetNote else { return [[]] }
            return [[targetNote]]
        }
    }
    
    /// Display text for the question
    var questionText: String {
        switch drillMode {
        case .fullProgression, .chordIdentification:
            return "Spell all chords in the progression"
        case .commonTones:
            guard let pair = commonTonePair else { return "Find the common tones" }
            let chords = chordsToSpell
            if chords.count >= 2 {
                return "Find notes shared between \(chords[0].displayName) and \(chords[1].displayName)"
            }
            return "Find the common tones between \(pair.rawValue)"
        case .auralIdentify:
            return "What cadence type did you hear?"
        case .guideTones:
            return "Play the guide tones (3rd and 7th) for each chord"
        case .resolutionTargets:
            guard let pairs = resolutionPairs,
                  let index = currentResolutionIndex,
                  index < pairs.count else { return "Find the resolution target" }
            let pair = pairs[index]
            let sourceChord = cadence.chords[pair.sourceChordIndex]
            let targetChord = cadence.chords[pair.targetChordIndex]
            return "The \(pair.sourceRole.rawValue) of \(sourceChord.displayName) is \(pair.sourceNote.name). Where does it resolve in \(targetChord.displayName)?"
        }
    }

    init(cadence: CadenceProgression) {
        self.cadence = cadence
        self.correctAnswers = cadence.chords.map { $0.chordTones }
        self.timeLimit = 60.0
        self.drillMode = .fullProgression
        self.isolatedPosition = nil
        self.commonTonePair = nil
        self.resolutionPairs = nil
        self.voicingConstraint = nil
        self.currentResolutionIndex = nil
    }
    
    init(cadence: CadenceProgression, drillMode: CadenceDrillMode, isolatedPosition: IsolatedChordPosition?) {
        self.cadence = cadence
        self.drillMode = drillMode
        self.isolatedPosition = isolatedPosition
        self.commonTonePair = nil
        self.resolutionPairs = nil
        self.voicingConstraint = nil
        self.currentResolutionIndex = nil
        
        // Calculate correct answers based on mode
        self.correctAnswers = cadence.chords.map { $0.chordTones }
        
        // Time limit based on mode
        switch drillMode {
        case .fullProgression:
            self.timeLimit = 60.0
        case .commonTones:
            self.timeLimit = 30.0
        case .chordIdentification:
            self.timeLimit = 45.0
        case .auralIdentify:
            self.timeLimit = 60.0  // More time for ear training
        case .guideTones:
            self.timeLimit = 45.0  // Time for guide tone resolution
        case .resolutionTargets:
            self.timeLimit = 45.0  // Time for resolution targets
        }
    }
    
    init(cadence: CadenceProgression, commonTonePair: CommonTonePair) {
        self.cadence = cadence
        self.drillMode = .commonTones
        self.isolatedPosition = nil
        self.commonTonePair = commonTonePair
        self.timeLimit = 30.0
        self.resolutionPairs = nil
        self.voicingConstraint = nil
        self.currentResolutionIndex = nil
        
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
    
    /// Initializer for guide tones mode
    init(cadence: CadenceProgression, guideTonesMode: Bool) {
        self.cadence = cadence
        self.drillMode = .guideTones
        self.isolatedPosition = nil
        self.commonTonePair = nil
        self.timeLimit = 45.0
        self.resolutionPairs = nil
        self.voicingConstraint = nil
        self.currentResolutionIndex = nil
        
        // Extract guide tones (3rd and 7th) for each chord
        self.correctAnswers = cadence.chords.map { chord in
            chord.guideTones
        }
    }
    
    /// Initializer for resolution targets mode
    init(cadence: CadenceProgression, resolutionPairs: [ResolutionPair], currentIndex: Int = 0) {
        self.cadence = cadence
        self.drillMode = .resolutionTargets
        self.isolatedPosition = nil
        self.commonTonePair = nil
        self.timeLimit = 30.0
        self.resolutionPairs = resolutionPairs
        self.voicingConstraint = nil
        self.currentResolutionIndex = currentIndex
        
        // The correct answer is the target note of the current resolution pair
        if currentIndex < resolutionPairs.count,
           let targetNote = resolutionPairs[currentIndex].targetNote {
            self.correctAnswers = [[targetNote]]
        } else {
            self.correctAnswers = [[]]
        }
    }
    
    // Note: Smooth voicing initializer removed - mode moved to future Voice Leading module
    
    /// Get all guide tones across all chords
    func allGuideTones() -> [Note] {
        return cadence.chords.flatMap { $0.guideTones }
    }
    
    /// Get guide tones for a specific chord index
    func guideTonesForChord(_ index: Int) -> [Note] {
        guard index >= 0 && index < cadence.chords.count else { return [] }
        return cadence.chords[index].guideTones
    }
    
    /// Find the resolution target for a note from one chord to another
    func resolutionTarget(for note: Note, fromChord fromIndex: Int, toChord toIndex: Int) -> Note? {
        guard fromIndex >= 0 && fromIndex < cadence.chords.count,
              toIndex >= 0 && toIndex < cadence.chords.count else { return nil }
        
        let sourceChord = cadence.chords[fromIndex]
        let targetChord = cadence.chords[toIndex]
        
        // Find the role of the note in the source chord
        guard let role = sourceChord.roleOfNote(note) else { return nil }
        
        // Apply voice leading rules for guide tones
        if role == .third {
            // 3rd typically moves to 7th of next chord (or stays as common tone)
            return targetChord.seventh
        } else if role == .seventh {
            // 7th typically resolves down by half or whole step to 3rd
            return targetChord.third
        }
        
        return nil
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
// MARK: - Chord Selection (for Cadence Identification Mode)

/// Represents a user's chord selection (root + quality)
struct ChordSelection: Codable, Equatable {
    var selectedRoot: Note?
    var selectedQuality: String?
    
    var isComplete: Bool {
        selectedRoot != nil && selectedQuality != nil
    }
    
    /// Display name (e.g., "F#m7")
    var displayName: String {
        guard let root = selectedRoot, let quality = selectedQuality else {
            return "—"
        }
        return "\(root.name)\(quality)"
    }
    
    /// Check if this selection matches the expected chord
    func matches(_ chord: Chord) -> Bool {
        guard let root = selectedRoot, let quality = selectedQuality else {
            return false
        }
        
        // Compare root by pitch class (octave-independent)
        let rootMatches = root.pitchClass == chord.root.pitchClass
        
        // Compare quality by symbol (handle common aliases)
        let expectedSymbol = chord.chordType.symbol
        let qualityMatches = quality == expectedSymbol ||
            (quality == "ø7" && expectedSymbol == "m7b5") ||
            (quality == "m7b5" && expectedSymbol == "ø7")
        
        return rootMatches && qualityMatches
    }
    

    /// Convert this selection to an array of Notes for audio playback
    func toNotes() -> [Note]? {
        guard let root = selectedRoot, let quality = selectedQuality else {
            return nil
        }
        
        // Get semitone offsets based on quality
        let semitones: [Int]
        switch quality {
        case "m7":
            semitones = [0, 3, 7, 10]  // root, m3, 5, m7
        case "7":
            semitones = [0, 4, 7, 10]  // root, M3, 5, m7
        case "maj7":
            semitones = [0, 4, 7, 11]  // root, M3, 5, M7
        case "ø7", "m7b5":
            semitones = [0, 3, 6, 10]  // root, m3, b5, m7
        case "7b9":
            semitones = [0, 4, 7, 10, 13]  // root, M3, 5, m7, b9
        case "dim7", "o7":
            semitones = [0, 3, 6, 9]  // root, m3, b5, dim7
        default:
            semitones = [0, 4, 7]  // default to major triad
        }
        
        // Build notes from root
        let rootMidi = root.midiNumber
        return semitones.compactMap { offset in
            Note.noteFromMidi(rootMidi + offset)
        }
    }

    /// Reset the selection
    mutating func reset() {
        selectedRoot = nil
        selectedQuality = nil
    }
}

/// Common chord qualities used in cadences
enum CadenceChordQuality: String, CaseIterable {
    case minor7 = "m7"
    case dominant7 = "7"
    case major7 = "maj7"
    case halfDiminished = "ø7"
    case dominant7b9 = "7b9"
    case dominant9 = "9"
    case dominant13 = "13"
    
    var displayName: String {
        rawValue
    }
    
    /// Qualities typically used in major ii-V-I
    static var majorCadenceQualities: [CadenceChordQuality] {
        [.minor7, .dominant7, .major7]
    }
    
    /// Qualities typically used in minor ii-V-i
    static var minorCadenceQualities: [CadenceChordQuality] {
        [.halfDiminished, .dominant7, .minor7]
    }
    
    /// All common qualities for cadence practice
    static var allCadenceQualities: [CadenceChordQuality] {
        [.minor7, .dominant7, .major7, .halfDiminished]
    }
}
