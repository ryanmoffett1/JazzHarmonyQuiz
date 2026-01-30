import Foundation

// MARK: - Drill Launch Mode

/// Per DESIGN.md Appendix C: Every drill renders in one of three explicit modes
/// This determines configuration source and UI behavior
enum DrillLaunchMode: Equatable {
    /// Launched from Curriculum tab or Continue Learning - config is locked
    case curriculum(moduleId: UUID)
    
    /// Launched from Quick Practice - mixed session, no setup
    case quickPractice
    
    /// Launched from Practice tab - full customization allowed
    case freePractice
    
    var isConfigLocked: Bool {
        switch self {
        case .curriculum, .quickPractice:
            return true
        case .freePractice:
            return false
        }
    }
    
    var showsSetupScreen: Bool {
        switch self {
        case .curriculum:
            return false  // Skip directly to drill with module config
        case .quickPractice:
            return false  // Skip directly to mixed session
        case .freePractice:
            return true   // Show full setup
        }
    }
    
    var moduleId: UUID? {
        switch self {
        case .curriculum(let id):
            return id
        case .quickPractice, .freePractice:
            return nil
        }
    }
}

// MARK: - Drill State

/// Represents the current state of any drill session
/// Used by all drill modules (Chord, Cadence, Scale, Interval)
enum DrillState: Equatable, CaseIterable {
    case setup      // Configuring drill options
    case active     // Answering questions
    case results    // Reviewing session results
}

// MARK: - Drill Session Result

/// Generic result for any drill session
struct DrillSessionResult: Identifiable {
    let id = UUID()
    let drillType: PracticeMode
    let startTime: Date
    let endTime: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let missedItems: [MissedItem]
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions)
    }
    
    var duration: TimeInterval {
        endTime.timeIntervalSince(startTime)
    }
    
    var formattedDuration: String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var accuracyPercentage: Int {
        Int(accuracy * 100)
    }
}

// MARK: - Missed Item

/// Represents a question that was answered incorrectly
struct MissedItem: Identifiable {
    let id = UUID()
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let category: String?  // e.g., "Chord", "Interval", "Scale"
}

// MARK: - Quick Start Preset

/// A predefined configuration for quick-starting a drill
protocol DrillPreset {
    var name: String { get }
    var description: String { get }
    var icon: String { get }
}

// MARK: - Chord Drill Presets

enum ChordDrillPreset: String, CaseIterable, DrillPreset {
    case basicTriads = "Basic Triads"
    case seventhChords = "7th Chords"
    case fullWorkout = "Full Workout"
    
    var name: String { rawValue }
    
    var description: String {
        switch self {
        case .basicTriads:
            return "Major and minor triads"
        case .seventhChords:
            return "7, maj7, m7, m7b5, dim7"
        case .fullWorkout:
            return "All chord types, random keys"
        }
    }
    
    var icon: String {
        switch self {
        case .basicTriads:
            return "1.circle"
        case .seventhChords:
            return "7.circle"
        case .fullWorkout:
            return "flame"
        }
    }
}

// MARK: - Cadence Drill Presets

enum CadenceDrillPreset: String, CaseIterable, DrillPreset {
    case majorIIVI = "Major ii-V-I"
    case minorIIVI = "Minor ii-V-i"
    case mixedCadences = "Mixed Cadences"
    
    var name: String { rawValue }
    
    var description: String {
        switch self {
        case .majorIIVI:
            return "Practice major key cadences"
        case .minorIIVI:
            return "Practice minor key cadences"
        case .mixedCadences:
            return "Both major and minor"
        }
    }
    
    var icon: String {
        switch self {
        case .majorIIVI:
            return "music.note"
        case .minorIIVI:
            return "music.note.list"
        case .mixedCadences:
            return "shuffle"
        }
    }
}

// MARK: - Scale Drill Presets

enum ScaleDrillPreset: String, CaseIterable, DrillPreset {
    case majorModes = "Major Modes"
    case minorScales = "Minor Scales"
    case allScales = "All Scales"
    
    var name: String { rawValue }
    
    var description: String {
        switch self {
        case .majorModes:
            return "Ionian, Dorian, Mixolydian"
        case .minorScales:
            return "Natural, harmonic, melodic"
        case .allScales:
            return "Complete scale workout"
        }
    }
    
    var icon: String {
        switch self {
        case .majorModes:
            return "music.quarternote.3"
        case .minorScales:
            return "music.mic"
        case .allScales:
            return "flame"
        }
    }
}

// MARK: - Interval Drill Presets

enum IntervalDrillPreset: String, CaseIterable, DrillPreset {
    case basicIntervals = "Basic Intervals"
    case allIntervals = "All Intervals"
    case earTraining = "Ear Training"
    
    var name: String { rawValue }
    
    var description: String {
        switch self {
        case .basicIntervals:
            return "2nds, 3rds, 5ths, octaves"
        case .allIntervals:
            return "All intervals including tritones"
        case .earTraining:
            return "Identify intervals by ear"
        }
    }
    
    var icon: String {
        switch self {
        case .basicIntervals:
            return "arrow.up.arrow.down"
        case .allIntervals:
            return "arrow.up.and.down.and.arrow.left.and.right"
        case .earTraining:
            return "ear"
        }
    }
}
