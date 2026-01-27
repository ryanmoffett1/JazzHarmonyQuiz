import Foundation

// MARK: - Curriculum Module

/// Represents a single learning module in the guided curriculum
struct CurriculumModule: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    let title: String
    let description: String
    let emoji: String
    let pathway: CurriculumPathway
    let level: Int  // Order within pathway (1, 2, 3...)
    
    let mode: CurriculumPracticeMode
    let recommendedConfig: ModuleConfig
    
    let prerequisiteModuleIDs: [UUID]
    let completionCriteria: CompletionCriteria
    
    init(
        id: UUID = UUID(),
        title: String,
        description: String,
        emoji: String,
        pathway: CurriculumPathway,
        level: Int,
        mode: CurriculumPracticeMode,
        recommendedConfig: ModuleConfig,
        prerequisiteModuleIDs: [UUID] = [],
        completionCriteria: CompletionCriteria
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.emoji = emoji
        self.pathway = pathway
        self.level = level
        self.mode = mode
        self.recommendedConfig = recommendedConfig
        self.prerequisiteModuleIDs = prerequisiteModuleIDs
        self.completionCriteria = completionCriteria
    }
    
    // Hashable conformance based on id
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

// MARK: - Curriculum Pathway

/// Different learning tracks students can follow
enum CurriculumPathway: String, CaseIterable, Codable, Equatable {
    case harmonyFoundations = "Harmony Foundations"
    case functionalHarmony = "Functional Harmony"
    case earTraining = "Ear Training"
    case advancedTopics = "Advanced Topics"
    
    var description: String {
        switch self {
        case .harmonyFoundations:
            return "Master basic chord construction from triads to extensions"
        case .functionalHarmony:
            return "Understand how chords function in progressions and keys"
        case .earTraining:
            return "Develop the ability to recognize harmony by ear"
        case .advancedTopics:
            return "Voice leading, substitutions, and advanced concepts"
        }
    }
    
    var icon: String {
        switch self {
        case .harmonyFoundations: return "music.note.list"
        case .functionalHarmony: return "arrow.triangle.branch"
        case .earTraining: return "ear.fill"
        case .advancedTopics: return "wand.and.stars"
        }
    }
    
    var color: String {
        switch self {
        case .harmonyFoundations: return "blue"
        case .functionalHarmony: return "green"
        case .earTraining: return "orange"
        case .advancedTopics: return "purple"
        }
    }
}

// MARK: - Practice Mode

/// Which drill mode this module uses
enum CurriculumPracticeMode: String, Codable, Equatable, Hashable {
    case chords = "Chords"
    case scales = "Scales"
    case cadences = "Cadences"
    case intervals = "Intervals"
    case progressions = "Progressions"
    
    var icon: String {
        switch self {
        case .chords: return "music.note"
        case .scales: return "music.note.list"
        case .cadences: return "pianokeys"
        case .intervals: return "arrow.up.and.down"
        case .progressions: return "arrow.triangle.branch"
        }
    }
}

// MARK: - Module Configuration

/// Recommended drill settings for a module
struct ModuleConfig: Codable, Equatable {
    // Chord settings
    let chordTypes: [String]?  // Chord symbols to include
    let questionType: String?  // "allTones", "singleTone", etc.
    
    // Scale settings
    let scaleTypes: [String]?  // Scale names to include
    
    // Cadence settings
    let cadenceTypes: [String]?  // "major", "minor", etc.
    let drillMode: String?  // "fullProgression", "guideTones", etc.
    let keyDifficulty: String?  // "easy", "medium", "hard"
    
    // Interval settings
    let intervalTypes: [String]?  // Interval names
    let intervalMode: String?  // "visual", "aural"
    
    // General settings
    let totalQuestions: Int
    let useAudio: Bool
    
    init(
        chordTypes: [String]? = nil,
        questionType: String? = nil,
        scaleTypes: [String]? = nil,
        cadenceTypes: [String]? = nil,
        drillMode: String? = nil,
        keyDifficulty: String? = nil,
        intervalTypes: [String]? = nil,
        intervalMode: String? = nil,
        totalQuestions: Int = 10,
        useAudio: Bool = true
    ) {
        self.chordTypes = chordTypes
        self.questionType = questionType
        self.scaleTypes = scaleTypes
        self.cadenceTypes = cadenceTypes
        self.drillMode = drillMode
        self.keyDifficulty = keyDifficulty
        self.intervalTypes = intervalTypes
        self.intervalMode = intervalMode
        self.totalQuestions = totalQuestions
        self.useAudio = useAudio
    }
    
    // MARK: - Symbol Mapping
    
    /// Maps readable chord names to actual ChordType symbols
    /// Handles both readable names ("major", "minor") and actual symbols ("", "m")
    var resolvedChordSymbols: Set<String>? {
        guard let types = chordTypes, !types.isEmpty else { return nil }
        
        let nameToSymbol: [String: String] = [
            // Triads
            "major": "",
            "minor": "m",
            "dim": "dim",
            "diminished": "dim",
            "aug": "aug",
            "augmented": "aug",
            // 7th chords
            "maj7": "maj7",
            "m7": "m7",
            "min7": "m7",
            "7": "7",
            "dom7": "7",
            "m7b5": "m7b5",
            "half-dim": "m7b5",
            "dim7": "dim7",
            // Extensions
            "maj9": "maj9",
            "m9": "m9",
            "9": "9",
            "11": "11",
            "13": "13",
            "maj13": "maj13",
            "m11": "m11",
            // Altered
            "7b9": "7b9",
            "7#9": "7#9",
            "7b5": "7b5",
            "7#5": "7#5",
            "7#11": "7#11",
            "7alt": "7alt"
        ]
        
        return Set(types.map { nameToSymbol[$0.lowercased()] ?? $0 })
    }
}

// MARK: - Completion Criteria

/// Requirements to complete a module
struct CompletionCriteria: Codable, Equatable {
    let accuracyThreshold: Double  // e.g., 0.80 = 80%
    let minimumAttempts: Int  // Minimum questions to answer
    let perfectSessionsRequired: Int?  // Optional: require X 100% sessions
    
    init(
        accuracyThreshold: Double = 0.80,
        minimumAttempts: Int = 30,
        perfectSessionsRequired: Int? = nil
    ) {
        self.accuracyThreshold = accuracyThreshold
        self.minimumAttempts = minimumAttempts
        self.perfectSessionsRequired = perfectSessionsRequired
    }
}

// MARK: - Module Progress

/// Tracks a student's progress through a module
struct ModuleProgress: Codable, Equatable {
    let moduleID: UUID
    var attempts: Int = 0
    var correctAnswers: Int = 0
    var perfectSessions: Int = 0
    var lastAttemptDate: Date?
    var completedDate: Date?
    
    var accuracy: Double {
        guard attempts > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(attempts)
    }
    
    var isCompleted: Bool {
        completedDate != nil
    }
    
    mutating func recordAttempt(wasCorrect: Bool, wasPerfectSession: Bool = false) {
        attempts += 1
        if wasCorrect {
            correctAnswers += 1
        }
        if wasPerfectSession {
            perfectSessions += 1
        }
        lastAttemptDate = Date()
    }
    
    mutating func checkAndMarkCompletion(criteria: CompletionCriteria) -> Bool {
        guard !isCompleted else { return true }
        
        // Check minimum attempts
        guard attempts >= criteria.minimumAttempts else { return false }
        
        // Check accuracy threshold
        guard accuracy >= criteria.accuracyThreshold else { return false }
        
        // Check perfect sessions if required
        if let requiredPerfect = criteria.perfectSessionsRequired {
            guard perfectSessions >= requiredPerfect else { return false }
        }
        
        // All criteria met!
        completedDate = Date()
        return true
    }
}
