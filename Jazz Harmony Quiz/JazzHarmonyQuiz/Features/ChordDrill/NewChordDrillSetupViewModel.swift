import Foundation
import SwiftUI

// MARK: - Setup View Model (New Implementation)

/// ViewModel for the Chord Drill Setup screen
/// Supports ad-hoc mode, create preset mode, and edit preset mode
@MainActor
class ChordDrillSetupViewModelNew: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentConfig: ChordDrillConfig
    @Published var presetName: String = ""
    @Published var validationError: String?
    
    // MARK: - Private Properties
    
    private let mode: SetupMode
    private let presetStore: CustomPresetStore
    private var editingPresetId: UUID?
    
    // MARK: - Computed Properties - Mode-Based UI
    
    /// Whether to show the preset name field
    var showsPresetNameField: Bool {
        switch mode {
        case .adHoc:
            return false
        case .createPreset, .editPreset:
            return true
        }
    }
    
    /// The title for the primary action button
    var primaryButtonTitle: String {
        switch mode {
        case .adHoc:
            return "Start Drill"
        case .createPreset:
            return "Save Preset"
        case .editPreset:
            return "Save Changes"
        }
    }
    
    /// Whether the primary action can be performed
    /// NOTE: This is a computed property - it must NOT have side effects or mutate state
    var canPerformPrimaryAction: Bool {
        // Validate preset name for create/edit modes
        if case .createPreset = mode {
            let trimmedName = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedName.isEmpty {
                return false
            }
            // Check for duplicate name
            if presetStore.allPresets.contains(where: { $0.name == trimmedName }) {
                return false
            }
        }
        
        if case .editPreset = mode {
            let trimmedName = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedName.isEmpty {
                return false
            }
        }
        
        // Validate question types
        if currentConfig.questionTypes.isEmpty {
            return false
        }
        
        // Validate custom chord types when using custom difficulty
        if currentConfig.difficulty == .custom {
            if currentConfig.chordTypes.isEmpty {
                return false
            }
        }
        
        // Validate custom keys
        if currentConfig.keyDifficulty == .custom {
            if currentConfig.customKeys?.isEmpty ?? true {
                return false
            }
        }
        
        return true
    }
    
    // MARK: - Computed Properties - Difficulty Options (NO EXPERT)
    
    /// Available chord difficulties - NO EXPERT
    var availableChordDifficulties: [ChordType.ChordDifficulty] {
        [.beginner, .intermediate, .advanced, .custom]
    }
    
    /// Available key difficulties - NO EXPERT
    var availableKeyDifficulties: [KeyDifficulty] {
        // Filter out expert and hard (keep easy, medium, all, custom)
        [.easy, .medium, .all, .custom]
    }
    
    /// Whether to show the chord type picker
    var showsChordTypePicker: Bool {
        currentConfig.difficulty == .custom
    }
    
    /// Whether to show the key picker
    var showsKeyPicker: Bool {
        currentConfig.keyDifficulty == .custom
    }
    
    /// Chord types available for the current difficulty
    var chordsForCurrentDifficulty: [String] {
        switch currentConfig.difficulty {
        case .beginner:
            return ["", "m", "dim", "aug", "sus2", "sus4"]
        case .intermediate:
            return ["", "m", "dim", "aug", "sus2", "sus4", "7", "maj7", "m7", "m7b5", "dim7", "6", "m6"]
        case .advanced, .expert:
            return JazzChordDatabase.shared.chordTypes.map { $0.symbol }
        case .custom:
            return []
        }
    }
    
    /// Keys available for the current difficulty
    var keysForCurrentDifficulty: [String] {
        switch currentConfig.keyDifficulty {
        case .easy:
            return ["C", "G", "D", "F", "Bb"]
        case .medium:
            return ["C", "G", "D", "F", "Bb", "A", "E", "Eb", "Ab"]
        case .all, .hard, .expert:
            return ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
        case .custom:
            return []
        }
    }
    
    /// All available chord types for custom selection - cached for performance
    private static let _allChordTypes: [String] = {
        JazzChordDatabase.shared.chordTypes.map { $0.symbol }
    }()
    
    var allChordTypes: [String] {
        Self._allChordTypes
    }
    
    /// All available keys for custom selection
    private static let _allKeys: [String] = ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    
    var allKeys: [String] {
        Self._allKeys
    }
    
    // MARK: - Initialization
    
    init(mode: SetupMode, presetStore: CustomPresetStore = .shared) {
        self.mode = mode
        self.presetStore = presetStore
        
        // Initialize based on mode
        switch mode {
        case .adHoc:
            self.currentConfig = ChordDrillConfig.default
            
        case .createPreset:
            self.currentConfig = ChordDrillConfig.default
            
        case .editPreset(let preset):
            self.currentConfig = preset.config
            self.presetName = preset.name
            self.editingPresetId = preset.id
        }
    }
    
    // MARK: - Actions
    
    /// Validate the current configuration and set validation error if needed
    private func validate() -> Bool {
        // Clear previous error
        validationError = nil
        
        // Validate preset name for create/edit modes
        if case .createPreset = mode {
            let trimmedName = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedName.isEmpty {
                validationError = "Preset name is required"
                return false
            }
            // Check for duplicate name
            if presetStore.allPresets.contains(where: { $0.name == trimmedName }) {
                validationError = "A preset with this name already exists"
                return false
            }
        }
        
        if case .editPreset = mode {
            let trimmedName = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedName.isEmpty {
                validationError = "Preset name is required"
                return false
            }
        }
        
        return true
    }
    
    /// Perform the primary action based on mode
    func performPrimaryAction() -> SetupActionResult {
        guard validate(), canPerformPrimaryAction else {
            return .validationFailed(validationError ?? "Invalid configuration")
        }
        
        switch mode {
        case .adHoc:
            return .startDrill(currentConfig)
            
        case .createPreset:
            let preset = CustomChordDrillPreset(
                name: presetName.trimmingCharacters(in: .whitespacesAndNewlines),
                config: currentConfig
            )
            presetStore.savePreset(preset)
            return .presetSaved
            
        case .editPreset(let originalPreset):
            var updatedPreset = originalPreset
            updatedPreset.name = presetName.trimmingCharacters(in: .whitespacesAndNewlines)
            updatedPreset.config = currentConfig
            presetStore.updatePreset(updatedPreset)
            return .presetSaved
        }
    }
    
    // MARK: - Configuration Methods
    
    /// Toggle a question type on/off
    func toggleQuestionType(_ type: QuestionType) {
        if currentConfig.questionTypes.contains(type) {
            // Don't allow removing the last type
            if currentConfig.questionTypes.count > 1 {
                currentConfig.questionTypes.remove(type)
            }
        } else {
            currentConfig.questionTypes.insert(type)
        }
    }
    
    /// Toggle a chord type on/off (for custom difficulty)
    func toggleChordType(_ symbol: String) {
        if currentConfig.chordTypes.contains(symbol) {
            currentConfig.chordTypes.remove(symbol)
        } else {
            currentConfig.chordTypes.insert(symbol)
        }
    }
    
    /// Toggle a key on/off (for custom key difficulty)
    func toggleKey(_ keyName: String) {
        var keys = currentConfig.customKeys ?? []
        if keys.contains(keyName) {
            keys.remove(keyName)
        } else {
            keys.insert(keyName)
        }
        currentConfig.customKeys = keys
    }
    
    /// Check if a chord type is selected
    func isChordTypeSelected(_ symbol: String) -> Bool {
        currentConfig.chordTypes.contains(symbol)
    }
    
    /// Check if a key is selected
    func isKeySelected(_ keyName: String) -> Bool {
        currentConfig.customKeys?.contains(keyName) ?? false
    }
}
