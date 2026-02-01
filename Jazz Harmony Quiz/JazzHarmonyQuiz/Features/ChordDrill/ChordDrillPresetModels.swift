import Foundation

// MARK: - Built-In Presets

/// The four built-in chord drill presets
/// Three start drills immediately, one opens the setup screen
enum BuiltInChordDrillPreset: String, CaseIterable, Equatable {
    case basicTriads
    case seventhAndSixthChords
    case fullWorkout
    case customAdHoc
    
    var name: String {
        switch self {
        case .basicTriads:
            return "Basic Triads"
        case .seventhAndSixthChords:
            return "7th & 6th Chords"
        case .fullWorkout:
            return "Full Workout"
        case .customAdHoc:
            return "Custom Ad-Hoc"
        }
    }
    
    var description: String {
        switch self {
        case .basicTriads:
            return "Perfect for beginners. Basic triads in common keys."
        case .seventhAndSixthChords:
            return "Jazz essentials. Seventh and sixth chords."
        case .fullWorkout:
            return "Complete challenge. All chords, all keys."
        case .customAdHoc:
            return "Configure a custom drill without saving."
        }
    }
    
    /// Whether tapping this preset opens the setup screen
    var opensSetup: Bool {
        self == .customAdHoc
    }
    
    /// The configuration for this preset (nil for customAdHoc)
    var config: ChordDrillConfig? {
        switch self {
        case .basicTriads:
            return ChordDrillConfig(
                chordTypes: ["", "m", "dim", "aug", "sus2", "sus4"],
                keyDifficulty: .easy,
                questionTypes: [.allTones],
                difficulty: .beginner,
                questionCount: 10,
                audioEnabled: true
            )
        case .seventhAndSixthChords:
            return ChordDrillConfig(
                chordTypes: ["7", "maj7", "m7", "m7b5", "dim7", "m(maj7)", "7#5", "maj6", "m6"],
                keyDifficulty: .medium,
                questionTypes: [.allTones],
                difficulty: .intermediate,
                questionCount: 10,
                audioEnabled: true
            )
        case .fullWorkout:
            return ChordDrillConfig(
                chordTypes: [],  // Empty means all types
                keyDifficulty: .all,
                questionTypes: [.singleTone, .allTones, .auralQuality, .auralSpelling],
                difficulty: .advanced,
                questionCount: 15,
                audioEnabled: true
            )
        case .customAdHoc:
            return nil  // Opens setup screen instead
        }
    }
    
    var iconName: String {
        switch self {
        case .basicTriads:
            return "music.note"
        case .seventhAndSixthChords:
            return "music.note.list"
        case .fullWorkout:
            return "figure.strengthtraining.traditional"
        case .customAdHoc:
            return "slider.horizontal.3"
        }
    }
}

// MARK: - Setup Mode

/// The mode for the setup screen
enum SetupMode: Equatable, Identifiable {
    case adHoc                           // Configure and start without saving
    case createPreset                    // Configure and save as new preset
    case editPreset(CustomChordDrillPreset)  // Edit existing preset
    
    var id: String {
        switch self {
        case .adHoc:
            return "adHoc"
        case .createPreset:
            return "createPreset"
        case .editPreset(let preset):
            return "editPreset-\(preset.id)"
        }
    }
    
    static func == (lhs: SetupMode, rhs: SetupMode) -> Bool {
        switch (lhs, rhs) {
        case (.adHoc, .adHoc):
            return true
        case (.createPreset, .createPreset):
            return true
        case (.editPreset(let lhsPreset), .editPreset(let rhsPreset)):
            return lhsPreset.id == rhsPreset.id
        default:
            return false
        }
    }
}

// MARK: - Preset Selection Action

/// Action returned when user selects a preset
enum PresetSelectionAction: Equatable {
    case startDrill(ChordDrillConfig)
    case openSetup(SetupMode)
}

// MARK: - Setup Action Result

/// Result of performing the primary action in setup
enum SetupActionResult: Equatable {
    case startDrill(ChordDrillConfig)
    case presetSaved
    case validationFailed(String)
}
