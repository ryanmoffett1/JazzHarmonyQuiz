import Foundation
import SwiftUI

// MARK: - Preset Selection View Model

/// ViewModel for the main Chord Drill preset selection screen
@MainActor
class ChordDrillPresetSelectionViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published private(set) var savedPresets: [CustomChordDrillPreset] = []
    
    // MARK: - Computed Properties
    
    /// The four built-in presets in display order
    var builtInPresets: [BuiltInChordDrillPreset] {
        [.basicTriads, .seventhAndSixthChords, .fullWorkout, .customAdHoc]
    }
    
    // MARK: - Dependencies
    
    private let presetStore: CustomPresetStore
    
    // MARK: - Initialization
    
    init(presetStore: CustomPresetStore = .shared) {
        self.presetStore = presetStore
        // Don't call refreshSavedPresets() here - it publishes changes during init
        // View will call it in onAppear instead
    }
    
    // MARK: - Actions
    
    /// Called when user taps a built-in preset
    func selectBuiltInPreset(_ preset: BuiltInChordDrillPreset) -> PresetSelectionAction {
        if preset.opensSetup {
            return .openSetup(.adHoc)
        } else if let config = preset.config {
            return .startDrill(config)
        } else {
            // Fallback - shouldn't happen
            return .openSetup(.adHoc)
        }
    }
    
    /// Called when user taps a saved preset
    func selectSavedPreset(_ preset: CustomChordDrillPreset) -> PresetSelectionAction {
        return .startDrill(preset.config)
    }
    
    /// Called when user taps "+ Create Preset"
    func createNewPreset() -> PresetSelectionAction {
        return .openSetup(.createPreset)
    }
    
    /// Called when user deletes a saved preset
    func deleteSavedPreset(_ preset: CustomChordDrillPreset) {
        presetStore.deletePreset(preset)
        refreshSavedPresets()
    }
    
    /// Refresh the list of saved presets from storage
    func refreshSavedPresets() {
        savedPresets = presetStore.allPresets
    }
}
