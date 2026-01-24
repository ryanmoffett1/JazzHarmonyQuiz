import Foundation

// MARK: - Progression Categories

enum ProgressionCategory: String, CaseIterable, Codable {
    case turnaround = "Turnarounds"
    case rhythmChanges = "Rhythm Changes"
    case secondaryDominants = "Secondary Dominants"
    case minorKeyMovement = "Minor Key Movement"
    case standardFragment = "Standard Fragments"

    var icon: String {
        switch self {
        case .turnaround: return "arrow.triangle.2.circlepath"
        case .rhythmChanges: return "music.quarternote.3"
        case .secondaryDominants: return "arrow.up.right"
        case .minorKeyMovement: return "arrow.down"
        case .standardFragment: return "music.note.list"
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

    init(romanNumeral: String, quality: String, durationBars: Int = 1) {
        self.romanNumeral = romanNumeral
        self.quality = quality
        self.durationBars = durationBars
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
