import Foundation

/// A concrete progression instance generated from a template in a specific key
struct ProgressionProgression: Identifiable, Codable {
    let id: UUID
    let template: ProgressionTemplate
    let key: Note
    let chords: [Chord]

    init(key: Note, template: ProgressionTemplate) {
        self.id = UUID()
        self.template = template
        self.key = key

        // Generate chords from template specifications
        var generatedChords: [Chord] = []
        let database = JazzChordDatabase.shared

        for spec in template.chords {
            // Calculate chord root from roman numeral
            let chordRoot = Self.calculateRomanNumeralRoot(spec.romanNumeral, inKey: key)

            // Get chord type from database
            if let chordType = database.chordTypes.first(where: { $0.symbol == spec.quality }) {
                let chord = Chord(root: chordRoot, chordType: chordType)
                generatedChords.append(chord)
            }
        }

        self.chords = generatedChords
    }

    /// Convert roman numeral to chord root in given key
    /// Examples: "ii" in C = D, "V" in F = C, "VI" in Bb = G
    private static func calculateRomanNumeralRoot(_ numeral: String, inKey key: Note) -> Note {
        // Map roman numerals to scale degrees (semitone intervals from root)
        let baseIntervals: [String: Int] = [
            "i": 0, "I": 0,
            "ii": 2, "II": 2,
            "iii": 4, "III": 4,
            "iv": 5, "IV": 5,
            "v": 7, "V": 7,
            "vi": 9, "VI": 9,
            "vii": 11, "VII": 11
        ]

        // Get semitone offset
        let semitones = baseIntervals[numeral] ?? 0

        // Calculate target MIDI number
        let targetMidi = key.midiNumber + semitones

        // Determine if we should prefer sharps or flats based on key
        let preferSharps = key.isSharp

        return Note.noteFromMidi(targetMidi, preferSharps: preferSharps) ?? key
    }
}
