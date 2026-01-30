import Foundation

/// Generates intelligent Quick Practice sessions per DESIGN.md Section 6.2
/// Combines spaced repetition, weak areas, and recent learning
class QuickPracticeGenerator {
    
    // MARK: - Singleton
    
    static let shared = QuickPracticeGenerator()
    
    // MARK: - Dependencies
    
    private let spacedRepetitionStore: SpacedRepetitionStore
    private let chordDatabase: JazzChordDatabase
    
    // MARK: - Configuration
    
    private let targetItemCount = 15
    private let dueItemsPercentage = 0.6  // 60% of session
    private let weakAreasPercentage = 0.25 // 25% of session
    private let recentLearningPercentage = 0.15 // 15% of session
    
    // MARK: - Initialization
    
    init(
        spacedRepetitionStore: SpacedRepetitionStore = .shared,
        chordDatabase: JazzChordDatabase = .shared
    ) {
        self.spacedRepetitionStore = spacedRepetitionStore
        self.chordDatabase = chordDatabase
    }
    
    // MARK: - Session Generation
    
    /// Generates a Quick Practice session per DESIGN.md algorithm
    /// Priority 1: Spaced repetition due items (60%)
    /// Priority 2: Weak areas (25%)
    /// Priority 3: Recent learning (15%)
    /// Fills remainder with general practice
    func generateSession() -> [QuickPracticeItem] {
        var items: [QuickPracticeItem] = []
        
        // Priority 1: Spaced repetition due items (up to 60%)
        let dueItemsLimit = Int(Double(targetItemCount) * dueItemsPercentage)
        let dueItems = getDueItems(limit: dueItemsLimit)
        items.append(contentsOf: dueItems)
        
        // Priority 2: Weak areas (up to 25%)
        let weakAreasLimit = Int(Double(targetItemCount) * weakAreasPercentage)
        let weakAreaItems = getWeakAreaItems(limit: weakAreasLimit)
        items.append(contentsOf: weakAreaItems)
        
        // Priority 3: Recent learning (up to 15%)
        let recentLearningLimit = Int(Double(targetItemCount) * recentLearningPercentage)
        let recentItems = getRecentLearningItems(limit: recentLearningLimit)
        items.append(contentsOf: recentItems)
        
        // Fill remainder with general practice
        while items.count < targetItemCount {
            items.append(generateRandomChordItem())
        }
        
        return items.shuffled()
    }
    
    // MARK: - Item Generation
    
    /// Gets due items from spaced repetition, sorted by overdue days
    private func getDueItems(limit: Int) -> [QuickPracticeItem] {
        var items: [QuickPracticeItem] = []
        
        // Get due counts by mode
        let chordsDue = spacedRepetitionStore.dueCount(for: .chordDrill)
        let scalesDue = spacedRepetitionStore.dueCount(for: .scaleDrill)
        let intervalsDue = spacedRepetitionStore.dueCount(for: .intervalDrill)
        let cadencesDue = spacedRepetitionStore.dueCount(for: .cadenceDrill)
        
        // Generate items proportionally
        var remaining = limit
        
        if chordsDue > 0 && remaining > 0 {
            let count = min(chordsDue, remaining / 2 + 1)
            items.append(contentsOf: generateChordItems(count: count, difficulty: .beginner))
            remaining -= count
        }
        
        if scalesDue > 0 && remaining > 0 {
            let count = min(scalesDue, remaining / 2 + 1)
            items.append(contentsOf: generateScaleItems(count: count))
            remaining -= count
        }
        
        if intervalsDue > 0 && remaining > 0 {
            let count = min(intervalsDue, remaining / 2 + 1)
            items.append(contentsOf: generateIntervalItems(count: count))
            remaining -= count
        }
        
        return items
    }
    
    /// Gets items from weak areas identified in statistics
    private func getWeakAreaItems(limit: Int) -> [QuickPracticeItem] {
        // Generate from intermediate level chords (likely weak areas for most users)
        return generateChordItems(count: limit, difficulty: .intermediate)
    }
    
    /// Gets items from recently learned curriculum modules
    /// Note: For simplicity, generates beginner-level mixed items
    /// In a future enhancement, this could track recent module activity
    private func getRecentLearningItems(limit: Int) -> [QuickPracticeItem] {
        // Generate a mix of beginner items to reinforce recent learning
        var items: [QuickPracticeItem] = []
        let chordsCount = max(1, limit / 2)
        let scalesCount = limit - chordsCount
        
        items.append(contentsOf: generateChordItems(count: chordsCount, difficulty: .beginner))
        items.append(contentsOf: generateScaleItems(count: scalesCount))
        
        return items
    }
    
    /// Generates a random chord practice item
    private func generateRandomChordItem() -> QuickPracticeItem {
        return generateChordItems(count: 1, difficulty: nil).first ?? makeDefaultChordItem()
    }
    
    // MARK: - Specific Item Generators
    
    private func generateChordItems(count: Int, difficulty: ChordType.ChordDifficulty?) -> [QuickPracticeItem] {
        var items: [QuickPracticeItem] = []
        let rootNotes = ["C", "D", "E", "F", "G", "A", "B", "Db", "Eb", "Gb", "Ab", "Bb"]
        
        let eligibleChords: [ChordType]
        if let diff = difficulty {
            eligibleChords = chordDatabase.chordTypes.filter { $0.difficulty == diff }
        } else {
            eligibleChords = chordDatabase.chordTypes
        }
        
        for _ in 0..<count {
            guard let chordType = eligibleChords.randomElement(),
                  let rootString = rootNotes.randomElement(),
                  let rootNote = Note.noteFromName(rootString) else { continue }
            
            // Create a Chord to get the correct notes
            let chord = Chord(root: rootNote, chordType: chordType)
            let symbol = rootString + chordType.symbol
            
            items.append(QuickPracticeItem(
                id: UUID(),
                type: .chordSpelling,
                question: "Spell: \(symbol)",
                displayName: symbol,
                correctNotes: chord.chordTones,
                difficulty: difficulty ?? .beginner,
                category: "Chord"
            ))
        }
        
        return items
    }
    
    private func generateScaleItems(count: Int) -> [QuickPracticeItem] {
        var items: [QuickPracticeItem] = []
        let scaleDatabase = JazzScaleDatabase.shared
        let rootNotes: [(name: String, midi: Int, isSharp: Bool)] = [
            ("C", 60, false),
            ("D", 62, false),
            ("E", 64, false),
            ("F", 65, false),
            ("G", 67, false),
            ("A", 69, false),
            ("B", 71, false)
        ]
        let scaleTypeNames = ["Major", "Dorian", "Mixolydian"]
        
        for _ in 0..<count {
            guard let root = rootNotes.randomElement(),
                  let scaleTypeName = scaleTypeNames.randomElement(),
                  let scaleType = scaleDatabase.scaleTypes.first(where: { $0.name == scaleTypeName }) else { continue }
            
            let rootNote = Note(name: root.name, midiNumber: root.midi, isSharp: root.isSharp)
            let scale = Scale(root: rootNote, scaleType: scaleType)
            
            // Map ScaleDifficulty to ChordType.ChordDifficulty
            let chordDifficulty: ChordType.ChordDifficulty
            switch scaleType.difficulty {
            case .beginner:
                chordDifficulty = .beginner
            case .intermediate:
                chordDifficulty = .intermediate
            case .advanced, .custom:
                chordDifficulty = .advanced
            }
            
            items.append(QuickPracticeItem(
                id: UUID(),
                type: .scaleSpelling,
                question: "Spell: \(root.name) \(scaleType.name)",
                displayName: "\(root.name) \(scaleType.name)",
                correctNotes: scale.scaleNotes,
                difficulty: chordDifficulty,
                category: "Scale"
            ))
        }
        
        return items
    }
    
    private func generateIntervalItems(count: Int) -> [QuickPracticeItem] {
        var items: [QuickPracticeItem] = []
        
        // Define intervals with their semitone distances
        let intervals: [(name: String, semitones: Int)] = [
            ("Minor 2nd", 1),
            ("Major 2nd", 2),
            ("Minor 3rd", 3),
            ("Major 3rd", 4),
            ("Perfect 4th", 5),
            ("Perfect 5th", 7),
            ("Minor 6th", 8),
            ("Major 6th", 9),
            ("Minor 7th", 10),
            ("Major 7th", 11)
        ]
        
        let rootNotes: [(name: String, midi: Int, isSharp: Bool)] = [
            ("C", 60, false),
            ("D", 62, false),
            ("E", 64, false),
            ("F", 65, false),
            ("G", 67, false),
            ("A", 69, false),
            ("B", 71, false)
        ]
        
        for _ in 0..<count {
            guard let interval = intervals.randomElement(),
                  let root = rootNotes.randomElement() else { continue }
            
            // Calculate the target note
            let targetMidi = root.midi + interval.semitones
            let targetPitchClass = targetMidi % 12
            
            // Determine the target note name
            let noteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]
            let targetName = noteNames[targetPitchClass]
            let targetIsSharp = targetName.contains("#")
            
            items.append(QuickPracticeItem(
                id: UUID(),
                type: .intervalBuilding,
                question: "\(interval.name) from \(root.name)",
                displayName: "\(interval.name) from \(root.name)",
                correctNotes: [
                    Note(name: root.name, midiNumber: root.midi, isSharp: root.isSharp),
                    Note(name: targetName, midiNumber: targetMidi, isSharp: targetIsSharp)
                ],
                difficulty: .beginner,
                category: "Interval"
            ))
        }
        
        return items
    }
    
    private func makeDefaultChordItem() -> QuickPracticeItem {
        QuickPracticeItem(
            id: UUID(),
            type: .chordSpelling,
            question: "Spell: Cmaj7",
            displayName: "Cmaj7",
            correctNotes: [
                Note(name: "C", midiNumber: 60, isSharp: false),
                Note(name: "E", midiNumber: 64, isSharp: false),
                Note(name: "G", midiNumber: 67, isSharp: false),
                Note(name: "B", midiNumber: 71, isSharp: false)
            ],
            difficulty: .beginner,
            category: "Chord"
        )
    }
}

// MARK: - Quick Practice Item Model

/// Represents a single practice question in Quick Practice session
struct QuickPracticeItem: Identifiable, Equatable {
    let id: UUID
    let type: QuickPracticeType
    let question: String
    let displayName: String
    let correctNotes: [Note]
    let difficulty: ChordType.ChordDifficulty
    let category: String
    
    enum QuickPracticeType: Equatable {
        case chordSpelling
        case cadenceProgression
        case scaleSpelling
        case intervalBuilding
    }
    
    static func == (lhs: QuickPracticeItem, rhs: QuickPracticeItem) -> Bool {
        lhs.id == rhs.id
    }
}
