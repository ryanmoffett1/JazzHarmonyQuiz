import SwiftUI

// MARK: - Setup View

/// Setup screen for configuring chord drill settings
/// Supports ad-hoc mode, create preset mode, and edit preset mode
///
/// This uses a wrapper pattern to correctly initialize StateObject with parameters.
/// The outer view passes parameters, the inner view owns the StateObject.
struct ChordDrillSetupView: View {
    let mode: SetupMode
    let onComplete: (SetupActionResult) -> Void
    
    var body: some View {
        ChordDrillSetupViewContent(mode: mode, onComplete: onComplete)
    }
}

/// Inner view that owns the StateObject - this ensures proper lifecycle management
private struct ChordDrillSetupViewContent: View {
    @StateObject private var viewModel: ChordDrillSetupViewModelNew
    @Environment(\.dismiss) private var dismiss
    
    let onComplete: (SetupActionResult) -> Void
    
    init(mode: SetupMode, onComplete: @escaping (SetupActionResult) -> Void) {
        // This is safe because SwiftUI only calls init once for the inner view
        self._viewModel = StateObject(wrappedValue: ChordDrillSetupViewModelNew(mode: mode))
        self.onComplete = onComplete
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Preset Name Section (only for create/edit modes)
                if viewModel.showsPresetNameField {
                    presetNameSection
                }
                
                // Chord Difficulty Section
                chordDifficultySection
                
                // Custom Chord Types (when custom difficulty selected)
                if viewModel.showsChordTypePicker {
                    customChordTypesSection
                }
                
                // Key Difficulty Section
                keyDifficultySection
                
                // Custom Keys (when custom key difficulty selected)
                if viewModel.showsKeyPicker {
                    customKeysSection
                }
                
                // Question Types Section
                questionTypesSection
                
                // Question Count Section
                questionCountSection
                
                // Audio Section
                audioSection
            }
            .navigationTitle(staticNavigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.primaryButtonTitle) {
                        let result = viewModel.performPrimaryAction()
                        onComplete(result)
                    }
                    .disabled(!viewModel.canPerformPrimaryAction)
                }
            }
        }
    }
    
    private var staticNavigationTitle: String {
        if viewModel.showsPresetNameField {
            return "New Preset"
        }
        return "Custom Ad-Hoc Drill"
    }
    
    // MARK: - Preset Name Section
    
    private var presetNameSection: some View {
        Section {
            TextField("Preset Name", text: $viewModel.presetName)
                .textInputAutocapitalization(.words)
            
            if let error = viewModel.validationError {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
            }
        } header: {
            Text("Preset Name")
        }
    }
    
    // MARK: - Chord Difficulty Section
    
    private var chordDifficultySection: some View {
        Section {
            Picker("Chord Difficulty", selection: $viewModel.currentConfig.difficulty) {
                ForEach(viewModel.availableChordDifficulties, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(.menu)
            
            // Show hint about what chords are included
            if !viewModel.showsChordTypePicker {
                Text(chordDifficultyHint)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Chord Types")
        }
    }
    
    private var chordDifficultyHint: String {
        switch viewModel.currentConfig.difficulty {
        case .beginner:
            return "Major, minor, diminished, augmented, sus2, sus4"
        case .intermediate:
            return "Includes 7th chords, 6th chords"
        case .advanced:
            return "All chord types including altered chords"
        case .expert:
            return "All chord types"
        case .custom:
            return "Select specific chord types below"
        }
    }
    
    // MARK: - Custom Chord Types Section
    
    private var customChordTypesSection: some View {
        Section {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(viewModel.allChordTypes, id: \.self) { chordType in
                    ChordTypeToggle(
                        symbol: chordType,
                        isSelected: viewModel.isChordTypeSelected(chordType)
                    ) {
                        viewModel.toggleChordType(chordType)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Select Chord Types (\(viewModel.currentConfig.chordTypes.count) selected)")
        }
    }
    
    // MARK: - Key Difficulty Section
    
    private var keyDifficultySection: some View {
        Section {
            Picker("Key Difficulty", selection: $viewModel.currentConfig.keyDifficulty) {
                ForEach(viewModel.availableKeyDifficulties, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(.menu)
            
            // Show hint about what keys are included
            if !viewModel.showsKeyPicker {
                Text(keyDifficultyHint)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        } header: {
            Text("Keys")
        }
    }
    
    private var keyDifficultyHint: String {
        switch viewModel.currentConfig.keyDifficulty {
        case .easy:
            return "C, G, D, F, Bb (5 keys)"
        case .medium:
            return "Easy keys plus A, E, Eb, Ab (9 keys)"
        case .hard, .all:
            return "All 12 keys"
        case .expert:
            return "All keys with enharmonic variations"
        case .custom:
            return "Select specific keys below"
        }
    }
    
    // MARK: - Custom Keys Section
    
    private var customKeysSection: some View {
        Section {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 8) {
                ForEach(viewModel.allKeys, id: \.self) { key in
                    KeyToggle(
                        keyName: key,
                        isSelected: viewModel.isKeySelected(key)
                    ) {
                        viewModel.toggleKey(key)
                    }
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Select Keys (\(viewModel.currentConfig.customKeys?.count ?? 0) selected)")
        }
    }
    
    // MARK: - Question Types Section
    
    private var questionTypesSection: some View {
        Section {
            ForEach(QuestionType.allCases, id: \.self) { type in
                Toggle(isOn: Binding(
                    get: { viewModel.currentConfig.questionTypes.contains(type) },
                    set: { _ in viewModel.toggleQuestionType(type) }
                )) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(type.rawValue)
                        Text(type.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        } header: {
            Text("Question Types")
        } footer: {
            Text("At least one question type must be selected")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Question Count Section
    
    private var questionCountSection: some View {
        Section {
            Stepper(
                "Questions: \(viewModel.currentConfig.questionCount)",
                value: $viewModel.currentConfig.questionCount,
                in: 5...50,
                step: 5
            )
        } header: {
            Text("Session Length")
        }
    }
    
    // MARK: - Audio Section
    
    private var audioSection: some View {
        Section {
            Toggle("Play Audio", isOn: $viewModel.currentConfig.audioEnabled)
        } header: {
            Text("Audio")
        } footer: {
            Text("Play chord sounds when displaying questions")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Chord Type Toggle

struct ChordTypeToggle: View {
    let symbol: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(symbol.isEmpty ? "Maj" : symbol)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Key Toggle

struct KeyToggle: View {
    let keyName: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(keyName)
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.accentColor : Color(.tertiarySystemFill))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview("Ad-Hoc Mode") {
    ChordDrillSetupView(mode: .adHoc) { result in
        print("Result: \(result)")
    }
}

#Preview("Create Mode") {
    ChordDrillSetupView(mode: .createPreset) { result in
        print("Result: \(result)")
    }
}
