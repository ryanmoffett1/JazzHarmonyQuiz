import SwiftUI

// MARK: - Preset Selection View

/// The main entry point for Chord Drill - shows built-in presets and saved custom presets
struct ChordDrillPresetSelectionView: View {
    @StateObject private var viewModel = ChordDrillPresetSelectionViewModel()
    @State private var setupMode: SetupMode?
    @State private var activeConfig: ChordDrillConfig?
    @State private var showingDeleteConfirmation = false
    @State private var presetToDelete: CustomChordDrillPreset?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Built-in Presets Section
                    builtInPresetsSection
                    
                    // Saved Presets Section (if any)
                    if !viewModel.savedPresets.isEmpty {
                        savedPresetsSection
                    }
                    
                    // Create Preset Button
                    createPresetButton
                }
                .padding()
            }
            .navigationTitle("Chord Drill")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Back") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(item: $activeConfig) { config in
                ChordDrillView(config: config)
            }
            .sheet(item: $setupMode) { mode in
                ChordDrillSetupView(mode: mode) { result in
                    handleSetupResult(result)
                }
            }
            .alert("Delete Preset", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    if let preset = presetToDelete {
                        viewModel.deleteSavedPreset(preset)
                    }
                }
            } message: {
                Text("Are you sure you want to delete this preset? This action cannot be undone.")
            }
        }
        .onAppear {
            viewModel.refreshSavedPresets()
        }
    }
    
    // MARK: - Built-in Presets
    
    private var builtInPresetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Start")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                ForEach(BuiltInChordDrillPreset.allCases, id: \.self) { preset in
                    BuiltInPresetCard(preset: preset) {
                        handleBuiltInPresetTap(preset)
                    }
                }
            }
        }
    }
    
    // MARK: - Saved Presets
    
    private var savedPresetsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("My Presets")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                ForEach(viewModel.savedPresets) { preset in
                    SavedPresetCard(
                        preset: preset,
                        onTap: {
                            handleSavedPresetTap(preset)
                        },
                        onEdit: {
                            setupMode = .editPreset(preset)
                        },
                        onDelete: {
                            presetToDelete = preset
                            showingDeleteConfirmation = true
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Create Preset Button
    
    private var createPresetButton: some View {
        Button {
            setupMode = .createPreset
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                Text("Create Custom Preset")
            }
            .font(.headline)
            .foregroundColor(ShedTheme.Colors.brass)
            .frame(maxWidth: .infinity)
            .padding()
            .background(ShedTheme.Colors.brass.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ShedTheme.Colors.brass.opacity(0.3), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Handlers
    
    private func handleBuiltInPresetTap(_ preset: BuiltInChordDrillPreset) {
        let action = viewModel.selectBuiltInPreset(preset)
        handleAction(action)
    }
    
    private func handleSavedPresetTap(_ preset: CustomChordDrillPreset) {
        let action = viewModel.selectSavedPreset(preset)
        handleAction(action)
    }
    
    private func handleAction(_ action: PresetSelectionAction) {
        switch action {
        case .startDrill(let config):
            activeConfig = config
        case .openSetup(let mode):
            setupMode = mode
        }
    }
    
    private func handleSetupResult(_ result: SetupActionResult) {
        setupMode = nil
        
        switch result {
        case .startDrill(let config):
            activeConfig = config
        case .presetSaved:
            viewModel.refreshSavedPresets()
        case .validationFailed:
            break
        }
    }
}

// MARK: - Built-in Preset Card

struct BuiltInPresetCard: View {
    let preset: BuiltInChordDrillPreset
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Icon with brass accent
                Image(systemName: preset.iconName)
                    .font(.title2)
                    .foregroundColor(ShedTheme.Colors.brass)
                    .frame(width: 50, height: 50)
                    .background(ShedTheme.Colors.brass.opacity(0.1))
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(ShedTheme.Colors.brass.opacity(0.3), lineWidth: 1)
                    )
                
                // Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(preset.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(preset.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Play/Configure indicator
                Image(systemName: preset.opensSetup ? "slider.horizontal.3" : "play.circle.fill")
                    .font(.title2)
                    .foregroundColor(ShedTheme.Colors.brass)
            }
            .padding()
            .background(ShedTheme.Colors.brass.opacity(0.05))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ShedTheme.Colors.brass.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Saved Preset Card

struct SavedPresetCard: View {
    let preset: CustomChordDrillPreset
    let onTap: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 16) {
            // Main tap area
            Button(action: onTap) {
                HStack(spacing: 16) {
                    // Icon with brass accent
                    Image(systemName: "music.note.list")
                        .font(.title2)
                        .foregroundColor(ShedTheme.Colors.brass)
                        .frame(width: 50, height: 50)
                        .background(ShedTheme.Colors.brass.opacity(0.1))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(ShedTheme.Colors.brass.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Info
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preset.name)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text(preset.configSummary)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    // Play indicator
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(ShedTheme.Colors.brass)
                }
            }
            .buttonStyle(.plain)
            
            // Context menu for edit/delete
            Menu {
                Button {
                    onEdit()
                } label: {
                    Label("Edit", systemImage: "pencil")
                }
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(ShedTheme.Colors.brass.opacity(0.05))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(ShedTheme.Colors.brass.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Custom Preset Extensions

extension CustomChordDrillPreset {
    /// A brief summary of the preset's configuration
    var configSummary: String {
        let chordDesc: String
        switch config.difficulty {
        case .beginner:
            chordDesc = "Beginner chords"
        case .intermediate:
            chordDesc = "Intermediate chords"
        case .advanced:
            chordDesc = "Advanced chords"
        case .expert:
            chordDesc = "Expert chords"
        case .custom:
            chordDesc = "\(config.chordTypes.count) chord types"
        }
        
        let keyDesc: String
        switch config.keyDifficulty {
        case .easy:
            keyDesc = "Easy keys"
        case .medium:
            keyDesc = "Medium keys"
        case .hard, .all:
            keyDesc = "All keys"
        case .expert:
            keyDesc = "Expert keys"
        case .custom:
            keyDesc = "\(config.customKeys?.count ?? 0) keys"
        }
        
        return "\(chordDesc) • \(keyDesc) • \(config.questionCount)Q"
    }
}

// MARK: - Built-in Preset Extensions

extension BuiltInChordDrillPreset {
    var color: Color {
        // Use brass theme for all presets to match app design
        ShedTheme.Colors.brass
    }
}

// MARK: - Preview

#Preview {
    ChordDrillPresetSelectionView()
}
