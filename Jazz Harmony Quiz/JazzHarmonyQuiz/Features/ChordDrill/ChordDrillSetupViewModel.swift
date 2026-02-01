import Foundation
import SwiftUI

// MARK: - Setup Mode

/// Represents the current mode/view in the chord drill setup
enum ChordDrillSetupMode: String, CaseIterable, Equatable {
    case quickStart = "Quick Start"
    case custom = "Custom Drill"
    case savePreset = "Save Preset"
    
    var displayName: String {
        rawValue
    }
    
    var description: String {
        switch self {
        case .quickStart:
            return "Choose a preset to start quickly"
        case .custom:
            return "Configure your own drill settings"
        case .savePreset:
            return "Save your current configuration"
        }
    }
}

// MARK: - Chord Drill Setup View Model

/// ViewModel for the chord drill setup screen
/// Manages mode switching, preset selection, and configuration
@MainActor
class ChordDrillSetupViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var currentMode: ChordDrillSetupMode = .quickStart
    @Published var selectedBuiltInPreset: ChordDrillPreset? = .basicTriads
    @Published var selectedCustomPreset: CustomChordDrillPreset?
    
    // Current configuration - settable for direct manipulation
    @Published var currentConfig: ChordDrillConfig = ChordDrillConfig(
        chordTypes: ["", "m", "dim", "aug", "sus2", "sus4"],
        keyDifficulty: .easy,
        questionTypes: [.allTones],
        difficulty: .beginner,
        questionCount: 10,
        audioEnabled: true
    )
    
    // Preset saving
    @Published var presetName: String = ""
    
    // MARK: - Dependencies
    
    let presetStore: CustomPresetStore
    
    // MARK: - Computed Properties
    
    /// The available built-in presets
    var builtInPresets: [ChordDrillPreset] {
        ChordDrillPreset.allCases
    }
    
    /// Custom presets from the store
    var customPresets: [CustomChordDrillPreset] {
        presetStore.allPresets
    }
    
    /// Whether a new preset can be saved
    var canSavePreset: Bool {
        presetStore.canAddMore && !presetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Whether to show the chord type selection UI (when difficulty is .custom)
    var showChordTypeSelection: Bool {
        currentConfig.difficulty == .custom
    }
    
    /// Whether to show the key selection UI (when keyDifficulty is .custom)
    var showKeySelection: Bool {
        currentConfig.keyDifficulty == .custom
    }
    
    /// All available keys (12 chromatic notes)
    var availableKeys: [String] {
        ["C", "C#", "D", "Eb", "E", "F", "F#", "G", "Ab", "A", "Bb", "B"]
    }
    
    /// All available chord types from the database
    var availableChordTypes: [String] {
        JazzChordDatabase.shared.chordTypes.map { $0.symbol }
    }
    
    /// All available question types
    var availableQuestionTypes: [QuestionType] {
        [.singleTone, .allTones, .auralQuality, .auralSpelling]
    }
    
    /// Returns chord type symbols appropriate for a given difficulty
    /// Higher difficulties include all chords from lower difficulties
    func chordTypesForDifficulty(_ difficulty: ChordType.ChordDifficulty) -> [String] {
        switch difficulty {
        case .beginner:
            return JazzChordDatabase.shared.getChordTypes(by: .beginner).map { $0.symbol }
        case .intermediate:
            // Intermediate includes beginner + intermediate
            let beginner = JazzChordDatabase.shared.getChordTypes(by: .beginner)
            let intermediate = JazzChordDatabase.shared.getChordTypes(by: .intermediate)
            return (beginner + intermediate).map { $0.symbol }
        case .advanced, .expert:
            // Advanced and Expert include all chord types
            return JazzChordDatabase.shared.chordTypes.map { $0.symbol }
        case .custom:
            // Custom returns current config's chord types
            return Array(currentConfig.chordTypes)
        }
    }
    
    /// Whether the current configuration is valid and drill can start
    var canStartDrill: Bool {
        // Must have at least one question type
        guard !currentConfig.questionTypes.isEmpty else { return false }
        
        // Question count must be at least 1
        guard currentConfig.questionCount >= 1 else { return false }
        
        // If using custom keys, must have at least one selected
        if currentConfig.keyDifficulty == .custom {
            guard let customKeys = currentConfig.customKeys, !customKeys.isEmpty else { return false }
        }
        
        // If using custom chord difficulty, must have at least one chord type
        if currentConfig.difficulty == .custom {
            guard !currentConfig.chordTypes.isEmpty else { return false }
        }
        
        return true
    }
    
    /// Builds and returns the configuration for starting a drill
    func buildConfigForDrill() -> ChordDrillConfig {
        // Return the current config as-is
        return currentConfig
    }

    /// Validates the current configuration is ready to start
    var isValidConfiguration: Bool {
        // Must have at least one question type
        guard !currentConfig.questionTypes.isEmpty else { return false }
        
        // Question count must be reasonable
        guard currentConfig.questionCount >= 1 && currentConfig.questionCount <= 100 else { return false }
        
        // If using custom keys, must have at least one selected
        if currentConfig.keyDifficulty == .custom {
            guard let customKeys = currentConfig.customKeys, !customKeys.isEmpty else { return false }
        }
        
        return true
    }
    
    // MARK: - Initialization
    
    init(presetStore: CustomPresetStore) {
        self.presetStore = presetStore
    }
    
    // MARK: - Mode Switching
    
    func switchToQuickStart() {
        currentMode = .quickStart
    }
    
    func switchToCustomMode() {
        currentMode = .custom
    }
    
    func switchToSavePresetMode() {
        currentMode = .savePreset
    }
    
    // MARK: - Preset Selection
    
    func selectBuiltInPreset(_ preset: ChordDrillPreset) {
        selectedBuiltInPreset = preset
        selectedCustomPreset = nil
        
        // Preserve user's question count preference
        let preservedQuestionCount = currentConfig.questionCount
        
        // Update configuration from preset
        let presetConfig = ChordDrillConfig.fromPreset(preset)
        currentConfig = ChordDrillConfig(
            chordTypes: presetConfig.chordTypes,
            keyDifficulty: presetConfig.keyDifficulty,
            questionTypes: presetConfig.questionTypes,
            difficulty: presetConfig.difficulty,
            questionCount: preservedQuestionCount,
            audioEnabled: presetConfig.audioEnabled,
            customKeys: presetConfig.customKeys
        )
    }
    
    func selectCustomPreset(_ preset: CustomChordDrillPreset) {
        selectedCustomPreset = preset
        selectedBuiltInPreset = nil
        
        // Update configuration from preset
        currentConfig = preset.config
    }
    
    // MARK: - Configuration Updates
    
    func updateQuestionCount(_ count: Int) {
        currentConfig.questionCount = max(1, min(100, count))
    }
    
    func updateChordDifficulty(_ difficulty: ChordType.ChordDifficulty) {
        currentConfig.difficulty = difficulty
        
        // When switching to a non-custom difficulty, apply the chord types for that difficulty
        if difficulty != .custom {
            currentConfig.chordTypes = Set(chordTypesForDifficulty(difficulty))
        }
    }
    
    func updateKeyDifficulty(_ difficulty: KeyDifficulty) {
        currentConfig.keyDifficulty = difficulty
        
        // Initialize custom keys if switching to custom
        if difficulty == .custom && currentConfig.customKeys == nil {
            currentConfig.customKeys = []
        }
    }
    
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
    
    func setQuestionTypes(_ types: Set<QuestionType>) {
        guard !types.isEmpty else { return }
        currentConfig.questionTypes = types
    }
    
    func toggleChordType(_ symbol: String) {
        if currentConfig.chordTypes.contains(symbol) {
            currentConfig.chordTypes.remove(symbol)
        } else {
            currentConfig.chordTypes.insert(symbol)
        }
    }
    
    func toggleKey(_ keyName: String) {
        var keys = currentConfig.customKeys ?? []
        if keys.contains(keyName) {
            // Don't allow removing the last key
            if keys.count > 1 {
                keys.remove(keyName)
            }
        } else {
            keys.insert(keyName)
        }
        currentConfig.customKeys = keys
    }
    
    func setCustomKeys(_ keys: Set<String>) {
        currentConfig.customKeys = keys
    }
    
    // MARK: - Refresh
    
    func refreshCustomPresets() {
        // Trigger objectWillChange to refresh views showing customPresets
        objectWillChange.send()
    }
    
    // MARK: - Preset Management
    
    func saveCurrentAsPreset() -> SavePresetResult {
        guard !presetName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return .failed(.emptyName)
        }
        
        let preset = CustomChordDrillPreset(
            name: presetName.trimmingCharacters(in: .whitespacesAndNewlines),
            config: currentConfig
        )
        
        let result = presetStore.savePreset(preset)
        if result.success {
            presetName = ""
            currentMode = .quickStart  // Return to quick start after successful save
        }
        return result
    }
    
    func deleteCustomPreset(_ preset: CustomChordDrillPreset) {
        presetStore.deletePreset(preset)
        
        // Clear selection if we deleted the selected preset
        if selectedCustomPreset?.id == preset.id {
            selectedCustomPreset = nil
        }
    }
}
