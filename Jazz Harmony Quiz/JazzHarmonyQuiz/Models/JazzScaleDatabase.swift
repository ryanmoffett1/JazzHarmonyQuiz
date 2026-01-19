import Foundation

class JazzScaleDatabase {
    static let shared = JazzScaleDatabase()
    
    var scaleTypes: [ScaleType] = []
    
    private init() {
        setupScaleTypes()
    }
    
    private func setupScaleTypes() {
        scaleTypes = [
            // MARK: - BEGINNER SCALES
            
            ScaleType(
                name: "Major",
                symbol: "Major",
                degrees: [
                    .root, .second, .third, .fourth, .fifth, .sixth, .seventh, .octave
                ],
                difficulty: .beginner,
                description: "The foundation of Western music. W-W-H-W-W-W-H pattern."
            ),
            
            ScaleType(
                name: "Natural Minor",
                symbol: "Minor",
                degrees: [
                    .root, .second, .flatThird, .fourth, .fifth, .flatSix, .flatSeven, .octave
                ],
                difficulty: .beginner,
                description: "The relative minor scale. Also called Aeolian mode."
            ),
            
            ScaleType(
                name: "Major Pentatonic",
                symbol: "Maj Pent",
                degrees: [
                    .root, .second, .third, .fifth, .sixth, .octave
                ],
                difficulty: .beginner,
                description: "Five-note scale without half steps. Great for improvisation."
            ),
            
            ScaleType(
                name: "Minor Pentatonic",
                symbol: "Min Pent",
                degrees: [
                    .root, .flatThird, .fourth, .fifth, .flatSeven, .octave
                ],
                difficulty: .beginner,
                description: "The most common scale for blues and rock."
            ),
            
            // MARK: - INTERMEDIATE SCALES
            
            ScaleType(
                name: "Dorian",
                symbol: "Dorian",
                degrees: [
                    .root, .second, .flatThird, .fourth, .fifth, .sixth, .flatSeven, .octave
                ],
                difficulty: .intermediate,
                description: "Minor scale with raised 6th. Essential for minor ii-V-I."
            ),
            
            ScaleType(
                name: "Mixolydian",
                symbol: "Mixo",
                degrees: [
                    .root, .second, .third, .fourth, .fifth, .sixth, .flatSeven, .octave
                ],
                difficulty: .intermediate,
                description: "Major scale with lowered 7th. Used over dominant 7th chords."
            ),
            
            ScaleType(
                name: "Blues",
                symbol: "Blues",
                degrees: [
                    .root, .flatThird, .fourth, .flatFive, .fifth, .flatSeven, .octave
                ],
                difficulty: .intermediate,
                description: "Minor pentatonic with added b5 (blue note)."
            ),
            
            ScaleType(
                name: "Harmonic Minor",
                symbol: "Harm Min",
                degrees: [
                    .root, .second, .flatThird, .fourth, .fifth, .flatSix, .seventh, .octave
                ],
                difficulty: .intermediate,
                description: "Natural minor with raised 7th. Creates V7 in minor keys."
            ),
            
            // MARK: - ADVANCED SCALES
            
            ScaleType(
                name: "Melodic Minor",
                symbol: "Mel Min",
                degrees: [
                    .root, .second, .flatThird, .fourth, .fifth, .sixth, .seventh, .octave
                ],
                difficulty: .advanced,
                description: "Jazz melodic minor (ascending form). Foundation for many jazz scales."
            ),
            
            ScaleType(
                name: "Lydian",
                symbol: "Lydian",
                degrees: [
                    .root, .second, .third, .sharpFour, .fifth, .sixth, .seventh, .octave
                ],
                difficulty: .advanced,
                description: "Major scale with raised 4th. Bright, floating quality."
            ),
            
            ScaleType(
                name: "Phrygian",
                symbol: "Phryg",
                degrees: [
                    .root, .flatTwo, .flatThird, .fourth, .fifth, .flatSix, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "Minor scale with lowered 2nd. Spanish/Flamenco character."
            ),
            
            ScaleType(
                name: "Locrian",
                symbol: "Locrian",
                degrees: [
                    .root, .flatTwo, .flatThird, .fourth, .flatFive, .flatSix, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "Half-diminished scale. Used over m7b5 chords."
            ),
            
            ScaleType(
                name: "Lydian Dominant",
                symbol: "Lyd Dom",
                degrees: [
                    .root, .second, .third, .sharpFour, .fifth, .sixth, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "Mixolydian with raised 4th. Great for dominant 7#11 chords."
            ),
            
            ScaleType(
                name: "Phrygian Dominant",
                symbol: "Phryg Dom",
                degrees: [
                    .root, .flatTwo, .third, .fourth, .fifth, .flatSix, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "5th mode of harmonic minor. Used over V7 in minor keys."
            ),
            
            // MARK: - EXPERT SCALES
            
            ScaleType(
                name: "Altered",
                symbol: "Altered",
                degrees: [
                    .root, .flatTwo, .sharpTwo, .third, .flatFive, .sharpFive, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "7th mode of melodic minor. Maximum tension on dominant chords."
            ),
            
            ScaleType(
                name: "Half-Whole Diminished",
                symbol: "HW Dim",
                degrees: [
                    .root, .flatTwo, .flatThird, .third, .sharpFour, .fifth, .sixth, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "Symmetrical 8-note scale. Used over dominant 7b9 chords."
            ),
            
            ScaleType(
                name: "Whole-Half Diminished",
                symbol: "WH Dim",
                degrees: [
                    .root, .second, .flatThird, .fourth, .flatFive, .flatSix, .sixth, .seventh, .octave
                ],
                difficulty: .advanced,
                description: "Symmetrical 8-note scale. Used over diminished 7th chords."
            ),
            
            ScaleType(
                name: "Whole Tone",
                symbol: "Whole",
                degrees: [
                    .root, .second, .third, .sharpFour, .sharpFive, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "All whole steps. Dreamy, ambiguous quality. Used over aug chords."
            ),
            
            ScaleType(
                name: "Bebop Dominant",
                symbol: "Bebop 7",
                degrees: [
                    .root, .second, .third, .fourth, .fifth, .sixth, .flatSeven, .seventh, .octave
                ],
                difficulty: .advanced,
                description: "Mixolydian with added natural 7. Keeps chord tones on downbeats."
            ),
            
            ScaleType(
                name: "Bebop Major",
                symbol: "Bebop Maj",
                degrees: [
                    .root, .second, .third, .fourth, .fifth, .sharpFive, .sixth, .seventh, .octave
                ],
                difficulty: .advanced,
                description: "Major scale with added #5. Classic bebop sound."
            ),
            
            ScaleType(
                name: "Bebop Dorian",
                symbol: "Bebop Dor",
                degrees: [
                    .root, .second, .flatThird, .third, .fourth, .fifth, .sixth, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "Dorian with added natural 3rd. For minor 7th chord improvisation."
            ),
            
            ScaleType(
                name: "Locrian #2",
                symbol: "Loc #2",
                degrees: [
                    .root, .second, .flatThird, .fourth, .flatFive, .flatSix, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "6th mode of melodic minor. Less harsh than pure Locrian."
            ),
            
            ScaleType(
                name: "Lydian Augmented",
                symbol: "Lyd Aug",
                degrees: [
                    .root, .second, .third, .sharpFour, .sharpFive, .sixth, .seventh, .octave
                ],
                difficulty: .advanced,
                description: "3rd mode of melodic minor. For maj7#5 chords."
            ),
            
            ScaleType(
                name: "Super Locrian",
                symbol: "Super Loc",
                degrees: [
                    .root, .flatTwo, .flatThird, .flatFour, .flatFive, .flatSix, .flatSeven, .octave
                ],
                difficulty: .advanced,
                description: "Also called the Altered scale or Diminished Whole Tone."
            )
        ]
    }
    
    // MARK: - Query Methods
    
    func getScales(by difficulty: ScaleType.ScaleDifficulty) -> [ScaleType] {
        return scaleTypes.filter { $0.difficulty == difficulty }
    }
    
    func getScales(upToDifficulty difficulty: ScaleType.ScaleDifficulty) -> [ScaleType] {
        // Custom difficulty returns all scales (filtering is done by scaleSymbols)
        if difficulty == .custom {
            return scaleTypes
        }
        
        let difficultyOrder: [ScaleType.ScaleDifficulty] = [.beginner, .intermediate, .advanced]
        guard let maxIndex = difficultyOrder.firstIndex(of: difficulty) else { return scaleTypes }
        let allowedDifficulties = Set(difficultyOrder[0...maxIndex])
        return scaleTypes.filter { allowedDifficulties.contains($0.difficulty) }
    }
    
    func getAllScaleSymbols() -> [String] {
        return scaleTypes.map { $0.symbol }
    }
    
    func getScaleType(bySymbol symbol: String) -> ScaleType? {
        return scaleTypes.first { $0.symbol == symbol }
    }
    
    /// Generate a random scale with the given filters
    func getRandomScale(difficulty: ScaleType.ScaleDifficulty, rootNames: [String]? = nil, scaleSymbols: Set<String>? = nil) -> Scale? {
        var filteredTypes = getScales(upToDifficulty: difficulty)
        
        // Filter by scale symbols if specified
        if let symbols = scaleSymbols, !symbols.isEmpty {
            filteredTypes = filteredTypes.filter { symbols.contains($0.symbol) }
        }
        
        guard let scaleType = filteredTypes.randomElement() else { return nil }
        
        // Get root notes
        var availableRoots = Note.allNotes.filter { !$0.isSharp || $0.name.contains("#") }
        // Remove duplicate enharmonic notes, preferring sharps
        let uniqueRoots = Dictionary(grouping: availableRoots, by: { $0.pitchClass })
            .compactMapValues { notes -> Note? in
                notes.first { $0.isSharp } ?? notes.first
            }
            .values
        availableRoots = Array(uniqueRoots)
        
        // Filter by root names if specified
        if let roots = rootNames, !roots.isEmpty {
            availableRoots = availableRoots.filter { roots.contains($0.name) }
        }
        
        guard let root = availableRoots.randomElement() else { return nil }
        
        return Scale(root: root, scaleType: scaleType)
    }
    
    // MARK: - Scale Categories for UI
    
    enum ScaleCategory: String, CaseIterable {
        case modes = "Modes"
        case pentatonic = "Pentatonic/Blues"
        case melodicMinorModes = "Melodic Minor Modes"
        case symmetrical = "Symmetrical"
        case bebop = "Bebop"
        
        var scaleSymbols: [String] {
            switch self {
            case .modes:
                return ["Major", "Minor", "Dorian", "Phryg", "Lydian", "Mixo", "Locrian"]
            case .pentatonic:
                return ["Maj Pent", "Min Pent", "Blues"]
            case .melodicMinorModes:
                return ["Mel Min", "Lyd Aug", "Lyd Dom", "Loc #2", "Altered"]
            case .symmetrical:
                return ["HW Dim", "WH Dim", "Whole"]
            case .bebop:
                return ["Bebop 7", "Bebop Maj", "Bebop Dor"]
            }
        }
    }
    
    func getScalesInCategory(_ category: ScaleCategory) -> [ScaleType] {
        let symbols = Set(category.scaleSymbols)
        return scaleTypes.filter { symbols.contains($0.symbol) }
    }
}
