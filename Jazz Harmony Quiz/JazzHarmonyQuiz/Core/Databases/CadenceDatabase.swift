import Foundation

// MARK: - Progression Categories

enum ProgressionCategory: String, CaseIterable, Codable {
    case cadences = "Cadences"
    case turnaround = "Turnarounds"
    case rhythmChanges = "Rhythm Changes"
    case secondaryDominants = "Secondary Dominants"
    case minorKeyMovement = "Minor Key Movement"
    case standardFragment = "Standard Fragments"

    var icon: String {
        switch self {
        case .cadences: return "arrow.down.to.line"
        case .turnaround: return "arrow.triangle.2.circlepath"
        case .rhythmChanges: return "music.quarternote.3"
        case .secondaryDominants: return "arrow.up.right"
        case .minorKeyMovement: return "arrow.down"
        case .standardFragment: return "music.note.list"
        }
    }
    
    var description: String {
        switch self {
        case .cadences: return "Fundamental ending patterns (ii-V-I, V-I)"
        case .turnaround: return "Circular progressions that return to tonic"
        case .rhythmChanges: return "Variations on 'I Got Rhythm' changes"
        case .secondaryDominants: return "Dominant chains and secondary functions"
        case .minorKeyMovement: return "Minor key progressions and modal interchange"
        case .standardFragment: return "Common sequences from jazz standards"
        }
    }
}

// MARK: - Progression Difficulty

enum ProgressionDifficulty: String, CaseIterable, Codable, Comparable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case expert = "Expert"

    static func < (lhs: ProgressionDifficulty, rhs: ProgressionDifficulty) -> Bool {
        let order: [ProgressionDifficulty] = [.beginner, .intermediate, .advanced, .expert]
        guard let lhsIndex = order.firstIndex(of: lhs),
              let rhsIndex = order.firstIndex(of: rhs) else { return false }
        return lhsIndex < rhsIndex
    }
}

// MARK: - Functional Chord Specification

struct FunctionalChordSpec: Codable {
    let romanNumeral: String  // "I", "ii", "V", "VI7", etc.
    let quality: String       // "maj7", "m7", "7", "m7b5", etc.
    let durationBars: Int     // For rhythm awareness (future use)
    let acceptableQualities: [String]  // Alternative correct answers (e.g., ["7", "7b9"] for V in minor)
    let alternativeNote: String?       // Educational note explaining alternatives

    init(romanNumeral: String, quality: String, durationBars: Int = 1, acceptableQualities: [String]? = nil, alternativeNote: String? = nil) {
        self.romanNumeral = romanNumeral
        self.quality = quality
        self.durationBars = durationBars
        // If no alternatives specified, only the primary quality is acceptable
        self.acceptableQualities = acceptableQualities ?? [quality]
        self.alternativeNote = alternativeNote
    }
    
    /// Check if a given quality is acceptable for this chord function
    func isAcceptableQuality(_ userQuality: String) -> Bool {
        // Normalize quality strings for comparison
        let normalizedUser = normalizeQuality(userQuality)
        return acceptableQualities.contains { normalizeQuality($0) == normalizedUser }
    }
    
    /// Normalize chord quality for comparison (handles notation variants)
    private func normalizeQuality(_ q: String) -> String {
        var normalized = q.lowercased()
        // Handle common notation variants
        normalized = normalized.replacingOccurrences(of: "min", with: "m")
        normalized = normalized.replacingOccurrences(of: "-", with: "m")
        normalized = normalized.replacingOccurrences(of: "ø", with: "m7b5")
        normalized = normalized.replacingOccurrences(of: "half-dim", with: "m7b5")
        normalized = normalized.replacingOccurrences(of: "dim7", with: "°7")
        normalized = normalized.replacingOccurrences(of: "maj", with: "M")
        normalized = normalized.replacingOccurrences(of: "Δ", with: "M")
        return normalized
    }
}

// MARK: - Progression Template

struct ProgressionTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let chords: [FunctionalChordSpec]
    let difficulty: ProgressionDifficulty
    let category: ProgressionCategory
    let exampleStandards: [String]  // Jazz standards using this progression
    let pedagogicalNotes: String?   // Why this progression matters

    var chordCount: Int { chords.count }

    init(
        id: UUID = UUID(),
        name: String,
        description: String,
        chords: [FunctionalChordSpec],
        difficulty: ProgressionDifficulty,
        category: ProgressionCategory,
        exampleStandards: [String] = [],
        pedagogicalNotes: String? = nil
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.chords = chords
        self.difficulty = difficulty
        self.category = category
        self.exampleStandards = exampleStandards
        self.pedagogicalNotes = pedagogicalNotes
    }
}

// MARK: - Progression Database

class ProgressionDatabase {
    static let shared = ProgressionDatabase()

    private(set) var templates: [ProgressionTemplate] = []

    private init() {
        setupTemplates()
    }

    private func setupTemplates() {
        templates = [
            // CADENCES - Beginner
            ProgressionTemplate(
                name: "Major ii-V-I",
                description: "ii⁷ – V⁷ – Imaj⁷",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .beginner,
                category: .cadences,
                exampleStandards: ["Autumn Leaves", "All The Things You Are", "Giant Steps"],
                pedagogicalNotes: "The fundamental cadential progression in jazz. Forms the basis of most jazz harmony."
            ),
            
            ProgressionTemplate(
                name: "Minor ii-V-i",
                description: "iiø⁷ – V⁷ – i⁷",
                chords: [
                    FunctionalChordSpec(
                        romanNumeral: "ii",
                        quality: "m7b5",
                        acceptableQualities: ["m7b5", "ø7", "ø"],
                        alternativeNote: "Half-diminished is the standard ii chord in minor"
                    ),
                    FunctionalChordSpec(
                        romanNumeral: "V",
                        quality: "7",
                        acceptableQualities: ["7", "7b9", "7#9", "7alt", "7b13"],
                        alternativeNote: "V7♭9 is very common in minor - the ♭9 comes from harmonic minor"
                    ),
                    FunctionalChordSpec(
                        romanNumeral: "i",
                        quality: "m7",
                        acceptableQualities: ["m7", "m6", "mMaj7", "m9", "m"],
                        alternativeNote: "Minor 6 is often preferred as a tonic chord for its stability"
                    )
                ],
                difficulty: .beginner,
                category: .cadences,
                exampleStandards: ["Autumn Leaves", "Beautiful Love"],
                pedagogicalNotes: "Essential minor key cadence. The half-diminished ii chord creates characteristic tension."
            ),
            
            ProgressionTemplate(
                name: "Simple V-I",
                description: "V⁷ – Imaj⁷",
                chords: [
                    FunctionalChordSpec(
                        romanNumeral: "V",
                        quality: "7",
                        acceptableQualities: ["7", ""],
                        alternativeNote: "V as a triad works; V7 adds the tritone that pulls to I"
                    ),
                    FunctionalChordSpec(
                        romanNumeral: "I",
                        quality: "maj7",
                        acceptableQualities: ["maj7", "", "6", "maj6"],
                        alternativeNote: "Triads are traditional; maj7 is standard jazz voicing"
                    )
                ],
                difficulty: .beginner,
                category: .cadences,
                exampleStandards: ["Blue Bossa", "Satin Doll"],
                pedagogicalNotes: "The authentic cadence (V→I). The dominant's tritone (3rd & 7th) resolves to tonic. Triads work; adding the 7th strengthens the pull."
            ),
            
            // CADENCES - Intermediate
            ProgressionTemplate(
                name: "ii-V-I with ♭9",
                description: "ii⁷ – V⁷♭9 – Imaj⁷",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7b9"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .intermediate,
                category: .cadences,
                exampleStandards: ["Stella By Starlight"],
                pedagogicalNotes: "Adding ♭9 to the V chord creates more tension and color. The ♭9 is a half-step above the root."
            ),
            
            ProgressionTemplate(
                name: "Tritone Substitution",
                description: "ii⁷ – ♭II⁷ – Imaj⁷",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "♭II", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .advanced,
                category: .cadences,
                exampleStandards: ["Cherokee", "Have You Met Miss Jones"],
                pedagogicalNotes: "The ♭II⁷ substitutes for V⁷ via tritone relationship, creating chromatic bass motion."
            ),
            
            // TURNAROUNDS - Beginner
            ProgressionTemplate(
                name: "Simple Turnaround",
                description: "I – vi – ii – V",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "vi", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .beginner,
                category: .turnaround,
                exampleStandards: ["Blue Bossa", "Satin Doll"],
                pedagogicalNotes: "The foundational jazz turnaround. All chords are diatonic to the major scale."
            ),

            ProgressionTemplate(
                name: "Secondary Dominant Turnaround",
                description: "I – VI7 – ii – V",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .intermediate,
                category: .turnaround,
                exampleStandards: ["Autumn Leaves", "Fly Me to the Moon"],
                pedagogicalNotes: "VI7 is a secondary dominant (V7/ii) creating stronger voice leading to ii."
            ),

            // TURNAROUNDS - Intermediate
            ProgressionTemplate(
                name: "Chromatic Turnaround",
                description: "I – I7 – IV – iv",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "IV", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "iv", quality: "m7")
                ],
                difficulty: .intermediate,
                category: .turnaround,
                exampleStandards: ["I Got Rhythm", "Confirmation"],
                pedagogicalNotes: "I7 creates a chromatic bass line. The iv is borrowed from parallel minor."
            ),

            // RHYTHM CHANGES - Intermediate
            ProgressionTemplate(
                name: "Rhythm Changes A Section",
                description: "I – VI7 – ii – V (repeated)",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .intermediate,
                category: .rhythmChanges,
                exampleStandards: ["I Got Rhythm", "Oleo", "Anthropology"],
                pedagogicalNotes: "The A section of rhythm changes. Two identical turnarounds."
            ),

            ProgressionTemplate(
                name: "Rhythm Changes Bridge",
                description: "III7 – VI7 – II7 – V7 (cycle of dominants)",
                chords: [
                    FunctionalChordSpec(romanNumeral: "III", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "II", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .advanced,
                category: .rhythmChanges,
                exampleStandards: ["I Got Rhythm", "Oleo", "Moose the Mooche"],
                pedagogicalNotes: "The bridge cycles through dominant chords descending in fifths."
            ),

            // SECONDARY DOMINANTS
            ProgressionTemplate(
                name: "Diatonic Descent with Secondaries",
                description: "I – V7/IV – IV – V7/iii – iii",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "7"),  // V7/IV
                    FunctionalChordSpec(romanNumeral: "IV", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "VII", quality: "7"), // V7/iii
                    FunctionalChordSpec(romanNumeral: "iii", quality: "m7")
                ],
                difficulty: .advanced,
                category: .secondaryDominants,
                exampleStandards: ["Have You Met Miss Jones"],
                pedagogicalNotes: "Each dominant chord resolves down a fifth to its target."
            ),

            // MINOR KEY MOVEMENT
            ProgressionTemplate(
                name: "Minor ii-V-i",
                description: "iiø7 – V7alt – im7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7b5"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),  // Will use altered in practice
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7")
                ],
                difficulty: .intermediate,
                category: .minorKeyMovement,
                exampleStandards: ["Alone Together", "Beautiful Love"],
                pedagogicalNotes: "The half-diminished ii chord is the key sound of minor harmony."
            ),

            // TURNAROUNDS - Beginner (Additional)
            ProgressionTemplate(
                name: "Basic ii-V-I",
                description: "ii – V – I",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .beginner,
                category: .turnaround,
                exampleStandards: ["All of Me", "Autumn Leaves"],
                pedagogicalNotes: "The fundamental jazz cadence. Master this in all keys."
            ),

            // MINOR KEY MOVEMENT - Beginner
            ProgressionTemplate(
                name: "Simple Minor Turnaround",
                description: "im – VI7 – iiø7 – V7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7b5"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .beginner,
                category: .minorKeyMovement,
                exampleStandards: ["Summertime", "Black Orpheus"],
                pedagogicalNotes: "The basic minor key turnaround. VI7 is a secondary dominant to ii."
            ),
            
            // ============================================
            // ADDITIONAL TURNAROUNDS
            // ============================================
            
            ProgressionTemplate(
                name: "Dominant Approach Turnaround",
                description: "I – I7 – IV – iv",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "IV", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "iv", quality: "m7")
                ],
                difficulty: .intermediate,
                category: .turnaround,
                exampleStandards: ["Honeysuckle Rose", "Sweet Georgia Brown"],
                pedagogicalNotes: "I7 acts as V7/IV. The iv is borrowed from parallel minor for chromatic color."
            ),
            
            ProgressionTemplate(
                name: "Coltrane Turnaround",
                description: "I – ♭III7 – ♭VI – ♭II7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭III", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "♭VI", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭II", quality: "7")
                ],
                difficulty: .expert,
                category: .turnaround,
                exampleStandards: ["Giant Steps", "Countdown"],
                pedagogicalNotes: "Coltrane's signature harmonic movement - dividing the octave into major thirds."
            ),
            
            ProgressionTemplate(
                name: "Tadd Dameron Turnaround",
                description: "I – ♭VII7 – ♭VI – V7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭VII", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "♭VI", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .advanced,
                category: .turnaround,
                exampleStandards: ["Lady Bird", "Hot House"],
                pedagogicalNotes: "Dameron's chromatic descent from I creates beautiful voice leading."
            ),
            
            ProgressionTemplate(
                name: "Backdoor Turnaround",
                description: "I – ♭VII7 – I",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭VII", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .intermediate,
                category: .turnaround,
                exampleStandards: ["Misty", "It Could Happen to You"],
                pedagogicalNotes: "The backdoor dominant (♭VII7) resolves up by step to I, avoiding the V-I cliché."
            ),
            
            ProgressionTemplate(
                name: "Parker Turnaround",
                description: "I – ♯i° – ii – V",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♯i", quality: "dim7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .advanced,
                category: .turnaround,
                exampleStandards: ["Blues for Alice", "Confirmation"],
                pedagogicalNotes: "The ♯i° chord is a passing diminished that creates chromatic bass motion I-♯I-II."
            ),
            
            ProgressionTemplate(
                name: "Montgomery-Ward Turnaround",
                description: "I – ♭III – ♭VI – ♭II",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭III", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭VI", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭II", quality: "maj7")
                ],
                difficulty: .advanced,
                category: .turnaround,
                exampleStandards: ["Central Park West"],
                pedagogicalNotes: "All major 7th chords moving through the cycle of major thirds."
            ),
            
            // ============================================
            // ADDITIONAL RHYTHM CHANGES
            // ============================================
            
            ProgressionTemplate(
                name: "Rhythm Bridge (2-bar)",
                description: "III7 – VI7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "III", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7")
                ],
                difficulty: .intermediate,
                category: .rhythmChanges,
                exampleStandards: ["Oleo", "Rhythm-a-ning"],
                pedagogicalNotes: "The first half of the rhythm changes bridge - dominant cycle begins."
            ),
            
            ProgressionTemplate(
                name: "Rhythm Bridge (4-bar)",
                description: "II7 – V7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "II", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .intermediate,
                category: .rhythmChanges,
                exampleStandards: ["Oleo", "Anthropology"],
                pedagogicalNotes: "The second half of the bridge - leads back to the A section."
            ),
            
            ProgressionTemplate(
                name: "Bird Blues Turnaround",
                description: "I – ♭VII7 – VI7 – ♭VI7 – V7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭VII", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "♭VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .advanced,
                category: .rhythmChanges,
                exampleStandards: ["Blues for Alice"],
                pedagogicalNotes: "Parker's chromatic dominant descent - each chord a half step apart."
            ),
            
            ProgressionTemplate(
                name: "Rhythm A with Tritone Sub",
                description: "I – ♭III7 – ii – ♭II7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭III", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "♭II", quality: "7")
                ],
                difficulty: .advanced,
                category: .rhythmChanges,
                exampleStandards: ["Moose the Mooche", "Dexterity"],
                pedagogicalNotes: "♭III7 subs for VI7, ♭II7 subs for V7 - all tritone substitutions."
            ),
            
            // ============================================
            // ADDITIONAL SECONDARY DOMINANTS
            // ============================================
            
            ProgressionTemplate(
                name: "V7 of IV",
                description: "I7 – IV",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "IV", quality: "maj7")
                ],
                difficulty: .beginner,
                category: .secondaryDominants,
                exampleStandards: ["Honeysuckle Rose", "Take the A Train"],
                pedagogicalNotes: "The I chord becomes dominant to lead to IV. Most common secondary dominant."
            ),
            
            ProgressionTemplate(
                name: "V7 of ii",
                description: "VI7 – ii",
                chords: [
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7")
                ],
                difficulty: .beginner,
                category: .secondaryDominants,
                exampleStandards: ["Autumn Leaves", "Fly Me to the Moon"],
                pedagogicalNotes: "VI7 (V7/ii) pulls strongly to the ii chord. Very common in standards."
            ),
            
            ProgressionTemplate(
                name: "V7 of V",
                description: "II7 – V7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "II", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .beginner,
                category: .secondaryDominants,
                exampleStandards: ["Sweet Georgia Brown", "Satin Doll"],
                pedagogicalNotes: "II7 (V7/V) creates a dominant chain to V. Adds drive to the cadence."
            ),
            
            ProgressionTemplate(
                name: "V7 of iii",
                description: "VII7 – iii",
                chords: [
                    FunctionalChordSpec(romanNumeral: "VII", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "iii", quality: "m7")
                ],
                difficulty: .intermediate,
                category: .secondaryDominants,
                exampleStandards: ["Have You Met Miss Jones"],
                pedagogicalNotes: "VII7 (V7/iii) is less common but creates interesting color moving to iii."
            ),
            
            ProgressionTemplate(
                name: "V7 of vi",
                description: "III7 – vi",
                chords: [
                    FunctionalChordSpec(romanNumeral: "III", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "vi", quality: "m7")
                ],
                difficulty: .intermediate,
                category: .secondaryDominants,
                exampleStandards: ["All The Things You Are"],
                pedagogicalNotes: "III7 (V7/vi) leads to the relative minor. Common in AABA forms."
            ),
            
            ProgressionTemplate(
                name: "Extended Dominant Chain",
                description: "VI7 – II7 – V7 – I",
                chords: [
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "II", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .intermediate,
                category: .secondaryDominants,
                exampleStandards: ["I Got Rhythm", "Cherokee"],
                pedagogicalNotes: "A chain of dominants resolving around the cycle of fifths to I."
            ),
            
            ProgressionTemplate(
                name: "Full Cycle of Dominants",
                description: "III7 – VI7 – II7 – V7 – I",
                chords: [
                    FunctionalChordSpec(romanNumeral: "III", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "II", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .advanced,
                category: .secondaryDominants,
                exampleStandards: ["Sweet Georgia Brown"],
                pedagogicalNotes: "The complete dominant cycle - each chord is V7 of the next."
            ),
            
            ProgressionTemplate(
                name: "Related ii-V Approach",
                description: "vi – VI7 – ii – V7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "vi", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .intermediate,
                category: .secondaryDominants,
                exampleStandards: ["There Will Never Be Another You"],
                pedagogicalNotes: "vi becomes major (VI7) to approach ii, then standard ii-V follows."
            ),
            
            // ============================================
            // ADDITIONAL MINOR KEY MOVEMENT
            // ============================================
            
            ProgressionTemplate(
                name: "Minor Plagal Cadence",
                description: "iv – i",
                chords: [
                    FunctionalChordSpec(
                        romanNumeral: "iv",
                        quality: "m7",
                        acceptableQualities: ["m7", "m", "m6"],
                        alternativeNote: "Minor triads are traditional; m7 adds jazz color"
                    ),
                    FunctionalChordSpec(
                        romanNumeral: "i",
                        quality: "m7",
                        acceptableQualities: ["m7", "m", "m6", "m9"],
                        alternativeNote: "Minor triads are traditional; m7/m6 are jazz voicings"
                    )
                ],
                difficulty: .beginner,
                category: .minorKeyMovement,
                exampleStandards: ["Blue in Green"],
                pedagogicalNotes: "The minor plagal (iv→i) moves subdominant to tonic in minor. Triads give the classic dark quality; 7ths add richness."
            ),
            
            ProgressionTemplate(
                name: "Minor Line Cliché",
                description: "i – i(maj7) – i7 – i6",
                chords: [
                    FunctionalChordSpec(romanNumeral: "i", quality: "m"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "mMaj7"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "m6")
                ],
                difficulty: .intermediate,
                category: .minorKeyMovement,
                exampleStandards: ["My Funny Valentine", "Stairway to Heaven"],
                pedagogicalNotes: "Chromatic descent on the 7th: root-maj7-min7-6. Classic film noir sound."
            ),
            
            ProgressionTemplate(
                name: "Minor Deceptive Cadence",
                description: "iiø – V7 – ♭VI",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7b5"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "♭VI", quality: "maj7")
                ],
                difficulty: .intermediate,
                category: .minorKeyMovement,
                exampleStandards: ["Alone Together"],
                pedagogicalNotes: "V7 resolves to ♭VI instead of i - the minor key deceptive resolution."
            ),
            
            ProgressionTemplate(
                name: "Dorian Vamp",
                description: "i – IV7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "IV", quality: "7")
                ],
                difficulty: .beginner,
                category: .minorKeyMovement,
                exampleStandards: ["So What", "Impressions"],
                pedagogicalNotes: "The IV7 with major 3rd defines Dorian mode. Modal jazz foundation."
            ),
            
            ProgressionTemplate(
                name: "Minor Blues Turnaround",
                description: "i – ♭VI7 – iiø – V7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "♭VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7b5"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .intermediate,
                category: .minorKeyMovement,
                exampleStandards: ["Mr. P.C.", "Equinox"],
                pedagogicalNotes: "The ♭VI7 is a tritone sub for II7, creating chromatic approach to iiø."
            ),
            
            ProgressionTemplate(
                name: "Phrygian Approach",
                description: "♭II – i",
                chords: [
                    FunctionalChordSpec(romanNumeral: "♭II", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7")
                ],
                difficulty: .intermediate,
                category: .minorKeyMovement,
                exampleStandards: ["Nardis"],
                pedagogicalNotes: "♭II resolving to i has a Spanish/Phrygian flavor. Very evocative."
            ),
            
            ProgressionTemplate(
                name: "Minor with Augmented",
                description: "i – i+ – i6 – i7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "i", quality: "m"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "+"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "m6"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7")
                ],
                difficulty: .advanced,
                category: .minorKeyMovement,
                exampleStandards: ["James Bond Theme"],
                pedagogicalNotes: "Chromatic ascent on the 5th: 5-♯5-6-♭7. Tension building pattern."
            ),
            
            // ============================================
            // STANDARD FRAGMENTS
            // ============================================
            
            ProgressionTemplate(
                name: "All The Things Bridge",
                description: "IV – iv – I – I",
                chords: [
                    FunctionalChordSpec(romanNumeral: "IV", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "iv", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .beginner,
                category: .standardFragment,
                exampleStandards: ["All The Things You Are"],
                pedagogicalNotes: "IV to iv (borrowed from parallel minor) is one of jazz's most beautiful sounds."
            ),
            
            ProgressionTemplate(
                name: "Body and Soul Bridge",
                description: "ii – V – ♭VI – ♭II",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "♭VI", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭II", quality: "7")
                ],
                difficulty: .advanced,
                category: .standardFragment,
                exampleStandards: ["Body and Soul"],
                pedagogicalNotes: "Deceptive to ♭VI then tritone sub of V - sophisticated harmonic motion."
            ),
            
            ProgressionTemplate(
                name: "Stella Opening",
                description: "i – ♭VII7 – ♭VI – V7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "♭VII", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "♭VI", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .advanced,
                category: .standardFragment,
                exampleStandards: ["Stella By Starlight"],
                pedagogicalNotes: "Descending bass line from i through ♭VII and ♭VI to V creates drama."
            ),
            
            ProgressionTemplate(
                name: "Autumn Leaves A",
                description: "ii – V – I – IV",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "IV", quality: "maj7")
                ],
                difficulty: .beginner,
                category: .standardFragment,
                exampleStandards: ["Autumn Leaves"],
                pedagogicalNotes: "ii-V resolves to I, then continues to IV - descending cycle continues."
            ),
            
            ProgressionTemplate(
                name: "Autumn Leaves B",
                description: "iiø – V7 – i – i",
                chords: [
                    FunctionalChordSpec(
                        romanNumeral: "ii",
                        quality: "m7b5",
                        acceptableQualities: ["m7b5", "ø7", "ø"]
                    ),
                    FunctionalChordSpec(
                        romanNumeral: "V",
                        quality: "7",
                        acceptableQualities: ["7", "7b9", "7#9", "7alt"]
                    ),
                    FunctionalChordSpec(
                        romanNumeral: "i",
                        quality: "m7",
                        acceptableQualities: ["m7", "m6", "m9"]
                    ),
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7")
                ],
                difficulty: .beginner,
                category: .standardFragment,
                exampleStandards: ["Autumn Leaves"],
                pedagogicalNotes: "The minor ii-V-i that answers the major section. Parallel key relationship."
            ),
            
            ProgressionTemplate(
                name: "Take the A Train Opening",
                description: "I – II7 – ii – V",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "II", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .intermediate,
                category: .standardFragment,
                exampleStandards: ["Take the A Train"],
                pedagogicalNotes: "II7 (the Strayhorn chord) creates a surprising ♯IV before resolving to ii."
            ),
            
            ProgressionTemplate(
                name: "Giant Steps Pattern",
                description: "I – V7/♭VI – ♭VI – V7/III – III",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭III", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "♭VI", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "VII", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "III", quality: "maj7")
                ],
                difficulty: .expert,
                category: .standardFragment,
                exampleStandards: ["Giant Steps"],
                pedagogicalNotes: "Coltrane changes: major thirds apart with dominant approaches. The ultimate challenge."
            ),
            
            ProgressionTemplate(
                name: "Cherokee Bridge",
                description: "IV – iv – I – VI7 – II7 – V7",
                chords: [
                    FunctionalChordSpec(romanNumeral: "IV", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "iv", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "VI", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "II", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7")
                ],
                difficulty: .advanced,
                category: .standardFragment,
                exampleStandards: ["Cherokee", "Koko"],
                pedagogicalNotes: "IV-iv-I followed by a dominant chain. A test of tempo and changes."
            ),
            
            ProgressionTemplate(
                name: "Blue Bossa A",
                description: "i – i – iv – iv",
                chords: [
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "iv", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "iv", quality: "m7")
                ],
                difficulty: .beginner,
                category: .standardFragment,
                exampleStandards: ["Blue Bossa"],
                pedagogicalNotes: "Simple minor vamp between i and iv. Great for modal exploration."
            ),
            
            ProgressionTemplate(
                name: "Blue Bossa B",
                description: "iiø – V7 – i – i",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7b5"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "i", quality: "m7")
                ],
                difficulty: .beginner,
                category: .standardFragment,
                exampleStandards: ["Blue Bossa"],
                pedagogicalNotes: "Standard minor ii-V-i to close each section."
            ),
            
            ProgressionTemplate(
                name: "Blue Bossa Modulation",
                description: "ii – V – I (new key)",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .intermediate,
                category: .standardFragment,
                exampleStandards: ["Blue Bossa"],
                pedagogicalNotes: "Modulates to ♭VI (Db from Cm) - a minor third relationship."
            ),
            
            ProgressionTemplate(
                name: "Misty Opening",
                description: "I – ♭VII7 – I – I",
                chords: [
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "♭VII", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .intermediate,
                category: .standardFragment,
                exampleStandards: ["Misty"],
                pedagogicalNotes: "The backdoor dominant ♭VII7 gives that dreamy, unexpected return to I."
            ),
            
            // ============================================
            // ADDITIONAL CADENCES
            // ============================================
            
            ProgressionTemplate(
                name: "Plagal Cadence",
                description: "IV – I",
                chords: [
                    FunctionalChordSpec(
                        romanNumeral: "IV",
                        quality: "maj7",
                        acceptableQualities: ["maj7", "", "6", "maj6"],
                        alternativeNote: "Triads are traditional; 7ths are jazz voicings"
                    ),
                    FunctionalChordSpec(
                        romanNumeral: "I",
                        quality: "maj7",
                        acceptableQualities: ["maj7", "", "6", "maj6"],
                        alternativeNote: "Triads are traditional; 7ths are jazz voicings"
                    )
                ],
                difficulty: .beginner,
                category: .cadences,
                exampleStandards: ["Amen endings"],
                pedagogicalNotes: "The 'Amen' cadence (IV→I). Simple triads are historically correct; jazz adds 7ths for color. The harmonic function—subdominant resolving to tonic—is what defines the cadence."
            ),
            
            ProgressionTemplate(
                name: "Backdoor Cadence",
                description: "iv – ♭VII7 – I",
                chords: [
                    FunctionalChordSpec(romanNumeral: "iv", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "♭VII", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .intermediate,
                category: .cadences,
                exampleStandards: ["Misty", "There Will Never Be Another You"],
                pedagogicalNotes: "iv-♭VII7-I avoids V entirely. The ♭VII7 slides up a whole step to I."
            ),
            
            ProgressionTemplate(
                name: "Double Tritone Resolution",
                description: "ii – ♭II7 – I",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "♭II", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "I", quality: "maj7")
                ],
                difficulty: .advanced,
                category: .cadences,
                exampleStandards: ["Moment's Notice"],
                pedagogicalNotes: "♭II7 as tritone sub for V7 creates chromatic bass: 2-♭2-1."
            ),
            
            ProgressionTemplate(
                name: "Deceptive Cadence",
                description: "ii – V – vi",
                chords: [
                    FunctionalChordSpec(romanNumeral: "ii", quality: "m7"),
                    FunctionalChordSpec(romanNumeral: "V", quality: "7"),
                    FunctionalChordSpec(romanNumeral: "vi", quality: "m7")
                ],
                difficulty: .intermediate,
                category: .cadences,
                exampleStandards: ["All of Me", "I Remember You"],
                pedagogicalNotes: "V resolves to vi instead of I - the classic deceptive resolution."
            )
        ]
    }

    func templates(for category: ProgressionCategory) -> [ProgressionTemplate] {
        templates.filter { $0.category == category }
    }

    func templates(for difficulty: ProgressionDifficulty) -> [ProgressionTemplate] {
        templates.filter { $0.difficulty == difficulty }
    }
}
