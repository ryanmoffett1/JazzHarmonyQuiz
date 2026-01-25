import SwiftUI

// MARK: - Cadence Drill Setup View

/// Setup screen for configuring cadence drill parameters
/// Allows selection of drill mode, key difficulty, number of questions, etc.
struct CadenceDrillSetup: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSettings = false
    @Binding var numberOfQuestions: Int
    @Binding var selectedCadenceType: CadenceType
    @Binding var selectedDrillMode: CadenceDrillMode
    @Binding var selectedKeyDifficulty: KeyDifficulty
    @Binding var selectedIsolatedPosition: IsolatedChordPosition
    
    // Phase 2 bindings
    @Binding var useMixedCadences: Bool
    @Binding var selectedCadenceTypes: Set<CadenceType>
    @Binding var speedRoundTime: Double
    
    // Phase 3 bindings
    @Binding var useExtendedVChords: Bool
    @Binding var selectedExtendedVChord: ExtendedVChordOption
    @Binding var selectedCommonTonePair: CommonTonePair
    
    let onStartQuiz: () -> Void
    let onPracticeWeakKeys: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with streak and stats
                headerSection
                
                // Practice Weak Keys Button (if enough data)
                practiceWeakKeysButton

                // Configuration options
                VStack(alignment: .leading, spacing: 20) {
                    drillModeSection
                    isolatedChordPositionSection
                    commonTonePairSection
                    speedRoundTimerSection
                    keyDifficultySection
                    numberOfQuestionsSection
                    mixedCadencesSection
                    cadenceTypeSelectionSection
                    extendedVChordsSection
                    instructionsSection
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .animation(.easeInOut(duration: 0.2), value: selectedDrillMode)
                .animation(.easeInOut(duration: 0.2), value: useExtendedVChords)

                // Start Button
                startButton

                // Leaderboard Button
                leaderboardButton

                // Settings Button
                settingsButton

                Spacer()
            }
            .padding()
        }
        .animation(.easeInOut(duration: 0.2), value: selectedDrillMode)
        .animation(.easeInOut(duration: 0.2), value: useMixedCadences)
    }
    
    // MARK: - Header Section
    
    @ViewBuilder
    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("Cadence Mode Setup")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Stats row - Rank and Rating (from shared PlayerStats)
            HStack(spacing: 20) {
                // Rank
                HStack(spacing: 4) {
                    Text(cadenceGame.playerStats.currentRank.emoji)
                    Text("\(cadenceGame.playerStats.currentRating)")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                
                // Streak
                if cadenceGame.playerStats.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Text("🔥")
                        Text("\(cadenceGame.playerStats.currentStreak)")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }
                
                // Accuracy (mode-specific)
                if cadenceGame.lifetimeStats.totalQuestionsAnswered > 0 {
                    HStack(spacing: 4) {
                        Text("📊")
                        Text("\(Int(cadenceGame.lifetimeStats.overallAccuracy * 100))%")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.green)
                    
                    HStack(spacing: 4) {
                        Text("✅")
                        Text("\(cadenceGame.lifetimeStats.totalQuestionsAnswered)")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.green)
                }
            }
        }
    }
    
    // MARK: - Practice Weak Keys
    
    @ViewBuilder
    private var practiceWeakKeysButton: some View {
        if cadenceGame.canPracticeWeakKeys {
            let weakKeys = cadenceGame.lifetimeStats.getWeakestKeys(limit: 3)
            Button(action: onPracticeWeakKeys) {
                HStack {
                    Image(systemName: "target")
                    VStack(alignment: .leading) {
                        Text("Practice Weak Keys")
                            .font(.headline)
                        Text("Focus on: \(weakKeys.map { $0.key }.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: [.red, .pink],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Drill Mode Section
    
    @ViewBuilder
    private var drillModeSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Drill Mode")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                ForEach(CadenceDrillMode.allCases, id: \.self) { mode in
                    Button(action: {
                        if mode == .auralIdentify {
                            // Auto-enable mixed cadences and set sensible defaults if empty
                            useMixedCadences = true
                            if selectedCadenceTypes.isEmpty {
                                selectedCadenceTypes = [.major, .minor, .tritoneSubstitution]
                            }
                        }
                        selectedDrillMode = mode
                    }) {
                        VStack(spacing: 4) {
                            Image(systemName: mode.iconName)
                                .font(.title2)
                            Text(mode.shortName)
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(selectedDrillMode == mode ? Color.blue : Color.gray.opacity(0.2))
                        .foregroundColor(selectedDrillMode == mode ? .white : .primary)
                        .cornerRadius(10)
                    }
                }
            }

            Text(selectedDrillMode.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Isolated Chord Position Section
    
    @ViewBuilder
    private var isolatedChordPositionSection: some View {
        if selectedDrillMode == .isolatedChord {
            VStack(alignment: .leading, spacing: 10) {
                Text("Chord to Practice")
                    .font(.headline)

                Picker("Chord Position", selection: $selectedIsolatedPosition) {
                    ForEach(IsolatedChordPosition.allCases, id: \.self) { position in
                        Text(position.rawValue).tag(position)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Text(selectedIsolatedPosition.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    // MARK: - Common Tone Pair Section
    
    @ViewBuilder
    private var commonTonePairSection: some View {
        if selectedDrillMode == .commonTones {
            VStack(alignment: .leading, spacing: 10) {
                Text("Chord Pair")
                    .font(.headline)

                Picker("Common Tone Pair", selection: $selectedCommonTonePair) {
                    ForEach(CommonTonePair.allCases, id: \.self) { pair in
                        Text(pair.rawValue).tag(pair)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                Text(selectedCommonTonePair.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    // MARK: - Speed Round Timer Section
    
    @ViewBuilder
    private var speedRoundTimerSection: some View {
        if selectedDrillMode == .speedRound {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Time Per Chord")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(speedRoundTime))s")
                        .font(.headline)
                        .foregroundColor(.orange)
                }

                Slider(value: $speedRoundTime, in: 3...15, step: 1)
                    .tint(.orange)

                Text("How long you have to spell each chord before auto-advancing")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        }
    }
    
    // MARK: - Key Difficulty Section
    
    @ViewBuilder
    private var keyDifficultySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Key Difficulty")
                .font(.headline)

            Picker("Key Difficulty", selection: $selectedKeyDifficulty) {
                ForEach(KeyDifficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            Text(selectedKeyDifficulty.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Number of Questions Section
    
    @ViewBuilder
    private var numberOfQuestionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Number of Questions")
                .font(.headline)

            Picker("Questions", selection: $numberOfQuestions) {
                ForEach([5, 10, 15, 20], id: \.self) { count in
                    Text("\(count)").tag(count)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    // MARK: - Mixed Cadences Section
    
    @ViewBuilder
    private var mixedCadencesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $useMixedCadences) {
                VStack(alignment: .leading) {
                    Text("Mixed Cadences")
                        .font(.headline)
                    Text("Randomly mix different cadence types")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .tint(.purple)
            .onChange(of: useMixedCadences) { _, newValue in
                // If disabling mixed cadences while in ear training mode, switch to full progression
                if !newValue && selectedDrillMode == .auralIdentify {
                    selectedDrillMode = .fullProgression
                }
            }
        }
    }
    
    // MARK: - Cadence Type Selection Section
    
    @ViewBuilder
    private var cadenceTypeSelectionSection: some View {
        if useMixedCadences {
            // Multi-select for mixed mode
            VStack(alignment: .leading, spacing: 10) {
                Text("Cadence Types to Include")
                    .font(.headline)
                
                ForEach(CadenceType.allCases, id: \.self) { type in
                    Button(action: {
                        if selectedCadenceTypes.contains(type) {
                            // Don't allow deselecting if it's the last one
                            if selectedCadenceTypes.count > 1 {
                                selectedCadenceTypes.remove(type)
                            }
                        } else {
                            selectedCadenceTypes.insert(type)
                        }
                    }) {
                        HStack {
                            Image(systemName: selectedCadenceTypes.contains(type) ? "checkmark.circle.fill" : "circle")
                                .foregroundColor(selectedCadenceTypes.contains(type) ? .purple : .gray)
                            VStack(alignment: .leading) {
                                Text(type.rawValue)
                                    .foregroundColor(.primary)
                                Text(type.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .transition(.opacity.combined(with: .move(edge: .top)))
        } else {
            // Single cadence type picker
            VStack(alignment: .leading, spacing: 10) {
                Text("Cadence Type")
                    .font(.headline)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(CadenceType.allCases, id: \.self) { type in
                        Button(action: {
                            selectedCadenceType = type
                        }) {
                            VStack(spacing: 4) {
                                Image(systemName: type.iconName)
                                    .font(.title3)
                                Text(type.shortName)
                                    .font(.caption)
                                    .fontWeight(.medium)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(selectedCadenceType == type ? Color.purple : Color.gray.opacity(0.2))
                            .foregroundColor(selectedCadenceType == type ? .white : .primary)
                            .cornerRadius(10)
                        }
                    }
                }

                Text(selectedCadenceType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK: - Extended V Chords Section
    
    @ViewBuilder
    private var extendedVChordsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Toggle(isOn: $useExtendedVChords) {
                VStack(alignment: .leading) {
                    Text("Extended V Chords")
                        .font(.headline)
                    Text("Use V9, V13, or altered dominants")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .tint(.blue)
            
            if useExtendedVChords {
                Picker("V Chord Type", selection: $selectedExtendedVChord) {
                    ForEach(ExtendedVChordOption.allCases, id: \.self) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text(selectedExtendedVChord.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: useExtendedVChords)
    }
    
    // MARK: - Instructions Section
    
    @ViewBuilder
    private var instructionsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Instructions")
                .font(.headline)

            Text(instructionText)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var instructionText: String {
        switch selectedDrillMode {
        case .fullProgression:
            let baseText = "You will be shown a ii-V-I cadence with all three chords displayed. Spell each chord by selecting the correct notes on the keyboard, then move to the next chord. When all three chords are spelled, submit your answer."
            if useMixedCadences {
                return baseText + " Cadence types will be randomly mixed."
            }
            return baseText
        case .isolatedChord:
            return "Focus on spelling just the \(selectedIsolatedPosition.rawValue) across different keys. This helps build deep familiarity with one chord type before combining them in full progressions."
        case .speedRound:
            return "Race against the clock! You have \(Int(speedRoundTime)) seconds to spell each chord. The quiz auto-advances when time runs out. Build speed while maintaining accuracy!"
        case .commonTones:
            return "Identify notes that are shared between two adjacent chords. This develops voice leading awareness - a key skill for smooth jazz improvisation and comping."
        case .chordIdentification:
            return "Identify each chord in the progression by selecting its root and quality. This tests your knowledge of chord symbols and their relationships in common jazz cadences."
        case .auralIdentify:
            return "Listen to the cadence and identify which type it is. This develops your ear for recognizing common chord progressions."
        case .guideTones:
            return "Identify the guide tones (3rd and 7th) and their resolutions through the progression. This develops awareness of how chord tones move in voice leading."
        case .resolutionTargets:
            return "Find where guide tones resolve in the next chord. This builds understanding of voice leading and tension resolution."
        case .smoothVoicing:
            return "Voice the progression with smooth voice leading, keeping common tones and moving other voices by small intervals."
        }
    }
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private var startButton: some View {
        Button(action: onStartQuiz) {
            Text("Start Cadence Drill")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.purple)
                .cornerRadius(12)
        }
    }
    
    @ViewBuilder
    private var leaderboardButton: some View {
        NavigationLink(destination: CadenceScoreboardView()) {
            HStack {
                Image(systemName: "trophy.fill")
                Text("View Cadence Leaderboard")
            }
            .font(.subheadline)
            .foregroundColor(.orange)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.orange, lineWidth: 1.5)
            )
        }
    }
    
    @ViewBuilder
    private var settingsButton: some View {
        Button(action: {
            showingSettings = true
        }) {
            HStack {
                Image(systemName: "gear")
                Text("Settings")
            }
            .font(.subheadline)
            .foregroundColor(.purple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple, lineWidth: 1.5)
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(settings)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CadenceDrillSetup(
            numberOfQuestions: .constant(10),
            selectedCadenceType: .constant(.major),
            selectedDrillMode: .constant(.fullProgression),
            selectedKeyDifficulty: .constant(.all),
            selectedIsolatedPosition: .constant(.ii),
            useMixedCadences: .constant(false),
            selectedCadenceTypes: .constant([.major, .minor]),
            speedRoundTime: .constant(5.0),
            useExtendedVChords: .constant(false),
            selectedExtendedVChord: .constant(.ninth),
            selectedCommonTonePair: .constant(.iiToV),
            onStartQuiz: {},
            onPracticeWeakKeys: {}
        )
        .environmentObject(CadenceGame())
        .environmentObject(SettingsManager.shared)
    }
}
