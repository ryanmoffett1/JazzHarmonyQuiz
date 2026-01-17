import SwiftUI
import UIKit

// MARK: - Haptic Feedback Helper
enum HapticFeedback {
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    static func medium() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
    }
    
    static func heavy() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func warning() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
    }
    
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }
}

struct CadenceDrillView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @State private var viewState: ViewState = .setup
    @State private var numberOfQuestions: Int = 10
    @State private var selectedCadenceType: CadenceType = .major
    @State private var selectedDrillMode: CadenceDrillMode = .fullProgression
    @State private var selectedKeyDifficulty: KeyDifficulty = .all
    @State private var selectedIsolatedPosition: IsolatedChordPosition = .ii
    
    // Phase 2 state
    @State private var useMixedCadences: Bool = false
    @State private var selectedCadenceTypes: Set<CadenceType> = [.major, .minor]
    @State private var speedRoundTime: Double = 5.0
    
    // Phase 3 state
    @State private var useExtendedVChords: Bool = false
    @State private var selectedExtendedVChord: ExtendedVChordOption = .ninth
    @State private var selectedCommonTonePair: CommonTonePair = .iiToV

    enum ViewState {
        case setup
        case active
        case results
    }

    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                CadenceSetupView(
                    numberOfQuestions: $numberOfQuestions,
                    selectedCadenceType: $selectedCadenceType,
                    selectedDrillMode: $selectedDrillMode,
                    selectedKeyDifficulty: $selectedKeyDifficulty,
                    selectedIsolatedPosition: $selectedIsolatedPosition,
                    useMixedCadences: $useMixedCadences,
                    selectedCadenceTypes: $selectedCadenceTypes,
                    speedRoundTime: $speedRoundTime,
                    useExtendedVChords: $useExtendedVChords,
                    selectedExtendedVChord: $selectedExtendedVChord,
                    selectedCommonTonePair: $selectedCommonTonePair,
                    onStartQuiz: startQuiz,
                    onStartDailyChallenge: startDailyChallenge,
                    onQuickPractice: startQuickPractice,
                    onPracticeWeakKeys: startWeakKeyPractice
                )
            case .active:
                if cadenceGame.selectedDrillMode == .chordIdentification {
                    ActiveChordIdentificationView(viewState: $viewState)
                } else {
                    ActiveCadenceQuizView(viewState: $viewState)
                }
            case .results:
                CadenceResultsView(onNewQuiz: {
                    cadenceGame.resetQuizState()
                    viewState = .setup
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if cadenceGame.isQuizActive {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Quit") {
                        quitQuiz()
                    }
                }

                ToolbarItem(placement: .principal) {
                    VStack {
                        HStack(spacing: 4) {
                            Text("Question \(cadenceGame.currentQuestionNumber) of \(cadenceGame.totalQuestions)")
                                .font(.headline)
                            if cadenceGame.isDailyChallenge {
                                Text("📅")
                            }
                            if cadenceGame.currentStreak > 0 {
                                Text("🔥\(cadenceGame.currentStreak)")
                                    .font(.caption)
                            }
                        }
                        ProgressView(value: cadenceGame.progress)
                            .frame(width: 200)
                    }
                }
            }
        }
        .onChange(of: cadenceGame.isQuizCompleted) { oldValue, newValue in
            if newValue && !oldValue {
                viewState = .results
            }
        }
    }

    private func startQuiz() {
        // Set Phase 2 parameters
        cadenceGame.useMixedCadences = useMixedCadences
        cadenceGame.selectedCadenceTypes = selectedCadenceTypes
        cadenceGame.speedRoundTimePerChord = speedRoundTime
        
        // Set Phase 3 parameters
        cadenceGame.useExtendedVChords = useExtendedVChords
        cadenceGame.selectedExtendedVChord = selectedExtendedVChord
        cadenceGame.selectedCommonTonePair = selectedCommonTonePair
        
        // Generate questions FIRST, before changing view state
        cadenceGame.startNewQuiz(
            numberOfQuestions: numberOfQuestions,
            cadenceType: selectedCadenceType,
            drillMode: selectedDrillMode,
            keyDifficulty: selectedKeyDifficulty,
            isolatedPosition: selectedIsolatedPosition,
            isDailyChallenge: false
        )
        
        // Start speed round timer if in speed round mode
        if selectedDrillMode == .speedRound {
            cadenceGame.startSpeedRoundTimer()
        }
        
        // Only switch to active view AFTER questions are ready
        viewState = .active
    }
    
    private func startDailyChallenge() {
        cadenceGame.startDailyChallenge()
        viewState = .active
    }
    
    private func startQuickPractice() {
        cadenceGame.startQuickPractice()
        viewState = .active
    }
    
    private func startWeakKeyPractice() {
        cadenceGame.startWeakKeyPractice()
        viewState = .active
    }
    
    private func startMistakeReview() {
        cadenceGame.startMistakeReviewDrill()
        viewState = .active
    }

    private func quitQuiz() {
        viewState = .setup
        cadenceGame.resetQuizState()
    }
}

// MARK: - Cadence Setup View
struct CadenceSetupView: View {
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
    let onStartDailyChallenge: () -> Void
    let onQuickPractice: () -> Void
    let onPracticeWeakKeys: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with streak and stats
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
                
                // Quick Practice Button (if has previous settings)
                if cadenceGame.canQuickPractice {
                    Button(action: onQuickPractice) {
                        HStack {
                            Image(systemName: "bolt.fill")
                            VStack(alignment: .leading) {
                                Text("Quick Practice")
                                    .font(.headline)
                                Text("5 questions with your last settings")
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
                                colors: [.green, .mint],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                }
                
                // Practice Weak Keys Button (if enough data)
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

                // Daily Challenge Button
                Button(action: onStartDailyChallenge) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        VStack(alignment: .leading) {
                            Text("Daily Challenge")
                                .font(.headline)
                            Text("Same challenge for everyone today!")
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
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }

                VStack(alignment: .leading, spacing: 20) {
                    // Drill Mode
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Drill Mode")
                            .font(.headline)

                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                            ForEach(CadenceDrillMode.allCases, id: \.self) { mode in
                                Button(action: {
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
                    // Isolated Chord Position (only shown in isolated mode)
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
                    
                    // Common Tone Pair (only shown in common tones mode)
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
                    
                    // Speed Round Timer (only shown in speed round mode)
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
                    
                    // Key Difficulty
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

                    // Number of Questions
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

                    // Mixed Cadences Toggle
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
                    }
                    
                    // Cadence Type Selection
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
                    
                    // Extended V Chord Options (Phase 3)
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

                    // Instructions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)

                        Text(instructionText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .animation(.easeInOut(duration: 0.2), value: selectedDrillMode)
                .animation(.easeInOut(duration: 0.2), value: useExtendedVChords)

                // Start Button
                Button(action: onStartQuiz) {
                    Text("Start Cadence Drill")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.purple)
                        .cornerRadius(12)
                }

                // Leaderboard Button
                NavigationLink(destination: CadenceLeaderboardView()) {
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

                // Settings Button
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

                Spacer()
            }
            .padding()
        }
        .animation(.easeInOut(duration: 0.2), value: selectedDrillMode)
        .animation(.easeInOut(duration: 0.2), value: useMixedCadences)
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
        }
    }
}

// MARK: - Active Cadence Quiz View
struct ActiveCadenceQuizView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var viewState: CadenceDrillView.ViewState
    @State private var currentChordIndex = 0 // Which chord we're currently spelling
    @State private var chordSpellings: [[Note]] = [[], [], [], [], []] // Spellings for up to 5 chords (Bird Changes)
    @State private var selectedNotes: Set<Note> = []
    @State private var showingFeedback = false
    @State private var isCorrect = false
    @State private var correctAnswerForFeedback: [[Note]] = []
    @State private var currentHintText: String? = nil

    /// Number of chords to spell based on drill mode
    private var chordsToSpellCount: Int {
        guard let question = cadenceGame.currentQuestion else { return 3 }
        return question.chordsToSpell.count
    }
    
    /// Whether we're in isolated chord mode
    private var isIsolatedMode: Bool {
        cadenceGame.selectedDrillMode == .isolatedChord
    }
    
    /// Whether we're in speed round mode
    private var isSpeedRoundMode: Bool {
        cadenceGame.selectedDrillMode == .speedRound
    }
    
    /// Whether we're in common tones mode
    private var isCommonTonesMode: Bool {
        cadenceGame.selectedDrillMode == .commonTones
    }

    var body: some View {
        VStack(spacing: 20) {
            // Speed Round Timer (if in speed round mode)
            if isSpeedRoundMode && cadenceGame.speedRoundTimerActive {
                VStack(spacing: 8) {
                    HStack {
                        Image(systemName: "timer")
                        Text(String(format: "%.1f", cadenceGame.speedRoundTimeRemaining))
                            .font(.title2)
                            .fontWeight(.bold)
                            .monospacedDigit()
                    }
                    .foregroundColor(cadenceGame.speedRoundIsWarning ? .red : .orange)
                    
                    ProgressView(value: cadenceGame.speedRoundProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: cadenceGame.speedRoundIsWarning ? .red : .orange))
                        .frame(height: 8)
                        .animation(.linear(duration: 0.1), value: cadenceGame.speedRoundProgress)
                }
                .padding(.horizontal)
            }
            
            if let question = cadenceGame.currentQuestion {
                // Safety check - ensure we have the expected chords
                let chordsToSpell = question.chordsToSpell
                if !chordsToSpell.isEmpty {
                    // Cadence Display
                    VStack(spacing: 15) {
                        HStack {
                            Text("Key: \(question.cadence.key.name) \(question.cadence.cadenceType.rawValue)")
                                .font(settings.chordDisplayFont(size: 24, weight: .bold))
                                .foregroundColor(settings.primaryText(for: colorScheme))
                            
                            if isIsolatedMode {
                                Text("(\(cadenceGame.selectedIsolatedPosition.rawValue) only)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(settings.chordDisplayBackground(for: colorScheme))
                        .cornerRadius(8)

                        // Display chords based on mode
                        if isIsolatedMode {
                            // Single chord display for isolated mode
                            chordDisplayCard(
                                chord: chordsToSpell[0],
                                index: 0,
                                isActive: true,
                                isCompleted: false
                            )
                            .frame(maxWidth: 200)
                        } else if isCommonTonesMode {
                            // Two chord display for common tones mode
                            VStack(spacing: 10) {
                                Text("Find Common Tones Between:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                HStack(spacing: 30) {
                                    ForEach(0..<min(2, chordsToSpell.count), id: \.self) { index in
                                        VStack {
                                            Text(chordsToSpell[index].displayName)
                                                .font(.title2)
                                                .fontWeight(.bold)
                                            Text(chordsToSpell[index].chordTones.map { $0.name }.joined(separator: " "))
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding()
                                        .background(Color.blue.opacity(0.1))
                                        .cornerRadius(12)
                                    }
                                }
                                
                                Text("→")
                                    .font(.title)
                                    .foregroundColor(.gray)
                            }
                        } else {
                            // Display all chords for full progression or speed round
                            HStack(spacing: 20) {
                                ForEach(0..<chordsToSpell.count, id: \.self) { index in
                                    chordDisplayCard(
                                        chord: chordsToSpell[index],
                                        index: index,
                                        isActive: index == currentChordIndex,
                                        isCompleted: !chordSpellings[index].isEmpty && index < currentChordIndex
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }

                        // Question text
                        if isCommonTonesMode {
                            Text("Select the note(s) that appear in both chords")
                                .font(.headline)
                                .foregroundColor(settings.primaryAccent(for: colorScheme))
                        } else {
                            Text("Spell: \(chordsToSpell[min(currentChordIndex, chordsToSpell.count - 1)].displayName)")
                                .font(.headline)
                                .foregroundColor(settings.primaryAccent(for: colorScheme))
                        }
                        
                        // Hint display
                        if let hint = currentHintText {
                            Text(hint)
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .padding(8)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                        
                        // Hint button (not for common tones - it would give away the answer)
                        if cadenceGame.canRequestHint && !isCommonTonesMode {
                            Button(action: requestHint) {
                                HStack {
                                    Image(systemName: "lightbulb")
                                    Text("Hint (\(3 - cadenceGame.currentHintLevel) left)")
                                }
                                .font(.caption)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    }
                }

                // Piano Keyboard
                PianoKeyboard(
                    selectedNotes: $selectedNotes,
                    octaveRange: 4...4,
                    showNoteNames: false,
                    allowMultipleSelection: true
                )
                .padding(.horizontal)
                .frame(height: 140)

                // Selected Notes Display
                if !selectedNotes.isEmpty {
                    VStack(spacing: 8) {
                        Text("Selected Notes:")
                            .font(.headline)
                            .foregroundColor(settings.secondaryText(for: colorScheme))

                        FlowLayout(spacing: 8) {
                            ForEach(Array(selectedNotes.sorted(by: { $0.midiNumber < $1.midiNumber })), id: \.midiNumber) { note in
                                Text(note.name)
                                    .font(settings.chordDisplayFont(size: selectedNotes.count > 5 ? 18 : 22, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, selectedNotes.count > 5 ? 12 : 16)
                                    .padding(.vertical, selectedNotes.count > 5 ? 8 : 10)
                                    .background(settings.selectedNoteBackground(for: colorScheme))
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(settings.backgroundColor(for: colorScheme))
                    .cornerRadius(12)
                }

                // Action Buttons
                HStack(spacing: 15) {
                    // Clear Button
                    Button(action: clearSelection) {
                        Text("Clear")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(12)
                    }

                    // Next Chord / Submit Button (logic depends on mode)
                    if isIsolatedMode {
                        // In isolated mode, always show submit
                        Button(action: submitAnswer) {
                            Text("Submit Answer")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedNotes.isEmpty ? Color.gray : settings.successColor(for: colorScheme))
                                .cornerRadius(12)
                        }
                        .disabled(selectedNotes.isEmpty)
                    } else if isCommonTonesMode {
                        // Common tones mode - single submit
                        Button(action: submitAnswer) {
                            Text("Submit Common Tones")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedNotes.isEmpty ? Color.gray : settings.successColor(for: colorScheme))
                                .cornerRadius(12)
                        }
                        .disabled(selectedNotes.isEmpty)
                    } else if currentChordIndex < chordsToSpellCount - 1 {
                        Button(action: moveToNextChord) {
                            Text("Next Chord →")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedNotes.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(12)
                        }
                        .disabled(selectedNotes.isEmpty)
                    } else {
                        Button(action: submitAnswer) {
                            Text("Submit Answer")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedNotes.isEmpty ? Color.gray : settings.successColor(for: colorScheme))
                                .cornerRadius(12)
                        }
                        .disabled(selectedNotes.isEmpty && !isSpeedRoundMode)
                    }
                }
                .padding(.horizontal)

                Spacer()
            }
        }
        .padding()
        .alert("Answer Feedback", isPresented: $showingFeedback) {
            Button("Continue") {
                continueToNextQuestion()
            }
        } message: {
            if isCorrect {
                Text("Correct! 🎉\n\n\(formatFeedback())")
            } else {
                Text("Incorrect.\n\n\(formatFeedback())")
            }
        }
        .onChange(of: cadenceGame.speedRoundTimeRemaining) { oldValue, newValue in
            // Handle speed round timeout
            if isSpeedRoundMode && newValue <= 0 && oldValue > 0 {
                handleSpeedRoundTimeout()
            }
        }
        .onDisappear {
            // Clean up timer when view disappears
            cadenceGame.stopSpeedRoundTimer()
        }
    }
    
    private func handleSpeedRoundTimeout() {
        // Save whatever notes were selected (may be empty)
        chordSpellings[currentChordIndex] = Array(selectedNotes)
        
        if isIsolatedMode || currentChordIndex >= chordsToSpellCount - 1 {
            // Last chord or isolated mode - auto-submit
            submitAnswer()
        } else {
            // Move to next chord
            currentChordIndex += 1
            selectedNotes.removeAll()
            currentHintText = nil
            cadenceGame.resetSpeedRoundTimer()
        }
    }

    private func chordDisplayCard(chord: Chord, index: Int, isActive: Bool, isCompleted: Bool) -> some View {
        VStack(spacing: 8) {
            Text(chord.displayName)
                .font(.headline)
                .foregroundColor(isActive ? .white : settings.primaryText(for: colorScheme))

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            } else if isActive {
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
                    .font(.caption)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isActive ? Color.blue : Color(.systemGray6))
        .cornerRadius(8)
    }

    private func clearSelection() {
        selectedNotes.removeAll()
        HapticFeedback.light()
    }

    private func moveToNextChord() {
        // Save current chord spelling
        chordSpellings[currentChordIndex] = Array(selectedNotes)

        // Move to next chord
        currentChordIndex += 1
        selectedNotes.removeAll()
        currentHintText = nil  // Clear hint for new chord
        
        // Haptic feedback
        HapticFeedback.medium()
        
        // Reset speed round timer for next chord
        if isSpeedRoundMode {
            cadenceGame.resetSpeedRoundTimer()
        }
    }
    
    private func requestHint() {
        if let hint = cadenceGame.requestHint(for: currentChordIndex) {
            currentHintText = hint
        }
    }

    private func submitAnswer() {
        guard let question = cadenceGame.currentQuestion else { return }
        
        // Stop speed round timer
        if isSpeedRoundMode {
            cadenceGame.stopSpeedRoundTimer()
        }

        // Save the last chord spelling
        chordSpellings[currentChordIndex] = Array(selectedNotes)
        
        // Prepare the answer based on mode
        let answerToSubmit: [[Note]]
        if isIsolatedMode || isCommonTonesMode {
            // Both isolated and common tones submit just one set of notes
            answerToSubmit = [Array(selectedNotes)]
        } else {
            // Only submit the number of chords we actually need to spell
            // (not the full 5-element array which may have empty trailing arrays)
            let numChords = chordsToSpellCount
            answerToSubmit = Array(chordSpellings.prefix(numChords))
        }

        // Store correct answer for feedback
        correctAnswerForFeedback = question.expectedAnswers

        // Check if answer is correct
        isCorrect = cadenceGame.isAnswerCorrect(userAnswer: answerToSubmit, question: question)
        
        // Haptic feedback based on result
        if isCorrect {
            HapticFeedback.success()
            
            // Play the user's entered chords as a cadence progression if enabled
            // This lets them hear their specific voicing/inversion
            if settings.playChordOnCorrect && settings.audioEnabled {
                // Use the user's entered notes (their inversions) for playback
                AudioManager.shared.playCadenceProgression(answerToSubmit, bpm: 90, beatsPerChord: 2)
            }
        } else {
            HapticFeedback.error()
        }

        // Show feedback
        showingFeedback = true
    }

    private func continueToNextQuestion() {
        guard let question = cadenceGame.currentQuestion else { return }

        // Prepare the answer based on mode
        let answerToSubmit: [[Note]]
        if isIsolatedMode || isCommonTonesMode {
            answerToSubmit = [Array(selectedNotes)]
        } else {
            // Only submit the number of chords we actually need to spell
            let numChords = chordsToSpellCount
            answerToSubmit = Array(chordSpellings.prefix(numChords))
        }
        
        // Submit the answer
        cadenceGame.submitAnswer(answerToSubmit)

        // Reset state for next question
        currentChordIndex = 0
        chordSpellings = [[], [], [], [], []]  // Reset for up to 5 chords
        selectedNotes.removeAll()
        currentHintText = nil
        
        // Start speed round timer for next question if still in quiz
        if isSpeedRoundMode && cadenceGame.isQuizActive {
            cadenceGame.startSpeedRoundTimer()
        }
    }

    private func formatFeedback() -> String {
        guard let question = cadenceGame.currentQuestion else { return "" }
        
        let chordsToSpell = question.chordsToSpell
        let expectedAnswers = question.expectedAnswers
        
        // Safety check
        guard !expectedAnswers.isEmpty else { return "" }

        var feedback = ""
        
        // Show hint penalty if hints were used
        if cadenceGame.hintsUsedThisQuestion > 0 {
            let creditPercent = Int(cadenceGame.hintPenalty * 100)
            feedback += "Hints used: \(cadenceGame.hintsUsedThisQuestion) (\(creditPercent)% credit)\n\n"
        }

        for i in 0..<chordsToSpell.count {
            guard i < chordSpellings.count, i < expectedAnswers.count else { continue }
            
            let chordName = chordsToSpell[i].displayName
            let userNotes = chordSpellings[i].map { $0.name }.joined(separator: ", ")
            let correctNotes = expectedAnswers[i].map { $0.name }.joined(separator: ", ")

            if isIsolatedMode {
                feedback += "Your answer: \(userNotes.isEmpty ? "None" : userNotes)\n"
                feedback += "Correct: \(correctNotes)\n"
            } else {
                feedback += "Chord \(i + 1) (\(chordName)):\n"
                feedback += "Your answer: \(userNotes.isEmpty ? "None" : userNotes)\n"

                if !isCorrect {
                    feedback += "Correct: \(correctNotes)\n"
                }

                if i < chordsToSpell.count - 1 {
                    feedback += "\n"
                }
            }
        }

        return feedback
    }
}

// MARK: - Cadence Results View
struct CadenceResultsView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    let onNewQuiz: () -> Void
    
    private var encouragement: EncouragementMessage? {
        cadenceGame.getEncouragementMessage()
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                if let result = cadenceGame.currentResult {
                    // Encouragement Message (Phase 5)
                    if let message = encouragement {
                        VStack(spacing: 8) {
                            Text(message.emoji)
                                .font(.system(size: 50))
                            Text(message.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(encouragementColor(for: message.type))
                            Text(message.message)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(encouragementColor(for: message.type).opacity(0.1))
                        .cornerRadius(16)
                    }
                    
                    // Header
                    VStack(spacing: 8) {
                        if encouragement == nil {
                            Text("Quiz Complete!")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                        }
                        
                        if cadenceGame.isDailyChallenge {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                Text("Daily Challenge")
                            }
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Streak encouragement
                        if let streakMessage = cadenceGame.getStreakEncouragement() {
                            Text(streakMessage)
                                .font(.subheadline)
                                .foregroundColor(.orange)
                                .multilineTextAlignment(.center)
                        } else if cadenceGame.currentStreak > 1 {
                            HStack {
                                Text("🔥")
                                Text("\(cadenceGame.currentStreak) day streak!")
                            }
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        }
                    }

                    // Score Display
                    VStack(spacing: 20) {
                        // Accuracy
                        VStack(spacing: 10) {
                            Text("\(Int(result.accuracy * 100))%")
                                .font(.system(size: 72, weight: .bold))
                                .foregroundColor(accuracyColor(result.accuracy))

                            Text("Accuracy")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }

                        // Stats
                        HStack(spacing: 40) {
                            VStack {
                                Text("\(result.correctAnswers)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Correct")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack {
                                Text("\(result.totalQuestions - result.correctAnswers)")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Incorrect")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }

                            VStack {
                                Text("\(Int(result.totalTime))s")
                                    .font(.title)
                                    .fontWeight(.bold)
                                Text("Total Time")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        // Cadence Type and Mode
                        VStack(spacing: 4) {
                            Text("Cadence Type: \(result.cadenceType.rawValue)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            if cadenceGame.selectedDrillMode == .isolatedChord {
                                Text("Mode: \(cadenceGame.selectedIsolatedPosition.rawValue) only")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            } else if cadenceGame.selectedDrillMode == .speedRound {
                                Text("Mode: Speed Round (\(Int(cadenceGame.speedRoundTimePerChord))s per chord)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                if cadenceGame.missedChordsDueToTimeout > 0 {
                                    Text("⏱ \(cadenceGame.missedChordsDueToTimeout) chord(s) timed out")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                }
                            }
                            
                            if cadenceGame.useMixedCadences {
                                Text("Mixed Cadences Mode")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Key Difficulty: \(cadenceGame.selectedKeyDifficulty.rawValue)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Divider()
                        
                        // Rating Change Display
                        HStack(spacing: 16) {
                            VStack {
                                HStack(spacing: 4) {
                                    Text(cadenceGame.lastRatingChange >= 0 ? "+" : "")
                                    Text("\(cadenceGame.lastRatingChange)")
                                }
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(cadenceGame.lastRatingChange >= 0 ? .green : .red)
                                
                                Text("Rating")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack {
                                Text("\(cadenceGame.playerStats.currentRating)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack {
                                Text(cadenceGame.playerStats.currentRank.emoji)
                                    .font(.title)
                                Text(cadenceGame.playerStats.currentRank.title)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                            }
                        }
                        
                        // Rank Up Celebration
                        if cadenceGame.didRankUp {
                            HStack(spacing: 8) {
                                if let prev = cadenceGame.previousRank {
                                    Text(prev.emoji)
                                }
                                Image(systemName: "arrow.right")
                                    .foregroundColor(.green)
                                Text(cadenceGame.playerStats.currentRank.emoji)
                                Text("Rank Up!")
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                            }
                            .font(.headline)
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(8)
                        }
                        
                        // Points to next rank
                        if let pointsNeeded = cadenceGame.playerStats.pointsToNextRank {
                            Text("\(pointsNeeded) points to next rank")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Action Buttons
                    VStack(spacing: 15) {
                        // Mistake Review Drill (only if there are missed questions)
                        if cadenceGame.hasMissedQuestions {
                            Button(action: {
                                cadenceGame.startMistakeReviewDrill()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.triangle.2.circlepath")
                                    Text("Drill Missed Chords (\(cadenceGame.getMissedQuestions().count))")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple)
                                .cornerRadius(12)
                            }
                        }
                        
                        if result.correctAnswers < result.totalQuestions {
                            NavigationLink(destination: CadenceReviewView()) {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle")
                                    Text("Review Wrong Answers")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(12)
                            }
                        }

                        Button(action: onNewQuiz) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                Text("New Quiz")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }

                        NavigationLink(destination: CadenceLeaderboardView()) {
                            HStack {
                                Image(systemName: "trophy")
                                Text("View Leaderboard")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
    }

    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.9 {
            return .green
        } else if accuracy >= 0.7 {
            return .orange
        } else {
            return .red
        }
    }
    
    private func encouragementColor(for type: EncouragementMessage.MessageType) -> Color {
        switch type {
        case .celebration:
            return .yellow
        case .positive:
            return .green
        case .encouraging:
            return .blue
        case .milestone:
            return .purple
        }
    }
}

// MARK: - Cadence Review View
struct CadenceReviewView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme

    var incorrectQuestions: [(question: CadenceQuestion, userAnswer: [[Note]])] {
        guard let result = cadenceGame.currentResult else { return [] }

        return result.questions.compactMap { question in
            let isCorrect = result.isCorrect[question.id.uuidString] ?? false
            if !isCorrect {
                let userAnswer = result.userAnswers[question.id.uuidString] ?? [[], [], []]
                return (question, userAnswer)
            }
            return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Wrong Answers Review")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding()

                if incorrectQuestions.isEmpty {
                    Text("No incorrect answers to review!")
                        .font(.headline)
                        .foregroundColor(.secondary)
                } else {
                    ForEach(Array(incorrectQuestions.enumerated()), id: \.offset) { index, item in
                        cadenceQuestionCard(question: item.question, userAnswer: item.userAnswer, index: index + 1)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Review")
    }

    private func cadenceQuestionCard(question: CadenceQuestion, userAnswer: [[Note]], index: Int) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Question \(index)")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))

            Text("Cadence: \(question.cadence.key.name) \(question.cadence.cadenceType.rawValue)")
                .font(.subheadline)
                .fontWeight(.semibold)

            ForEach(0..<3, id: \.self) { i in
                VStack(alignment: .leading, spacing: 5) {
                    Text("Chord \(i + 1): \(question.cadence.chords[i].displayName)")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    HStack {
                        Text("Your answer:")
                            .font(.caption)
                        Text(userAnswer[i].map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.red)
                    }

                    HStack {
                        Text("Correct answer:")
                            .font(.caption)
                        Text(question.correctAnswers[i].map { $0.name }.joined(separator: ", "))
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                }
                .padding(.leading)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Chord Voicing View
/// Shows a mini keyboard with the correct chord voicing highlighted
struct ChordVoicingView: View {
    let notes: [Note]
    let chordName: String
    
    // Piano key layout for one octave
    private let whiteKeyNames = ["C", "D", "E", "F", "G", "A", "B"]
    private let blackKeyNames = ["C#", "D#", "", "F#", "G#", "A#", ""]
    
    var body: some View {
        VStack(spacing: 8) {
            Text(chordName)
                .font(.headline)
                .fontWeight(.bold)
            
            // Mini piano
            GeometryReader { geometry in
                let whiteKeyWidth = geometry.size.width / 7
                let whiteKeyHeight: CGFloat = 80
                let blackKeyWidth = whiteKeyWidth * 0.6
                let blackKeyHeight = whiteKeyHeight * 0.6
                
                ZStack(alignment: .topLeading) {
                    // White keys
                    HStack(spacing: 1) {
                        ForEach(0..<7, id: \.self) { index in
                            let noteName = whiteKeyNames[index]
                            let isHighlighted = notes.contains { $0.name == noteName || $0.name == noteName }
                            
                            Rectangle()
                                .fill(isHighlighted ? Color.blue : Color.white)
                                .frame(width: whiteKeyWidth - 1, height: whiteKeyHeight)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        if isHighlighted {
                                            Text(noteName)
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .padding(.bottom, 4)
                                )
                                .border(Color.gray, width: 0.5)
                        }
                    }
                    
                    // Black keys
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { index in
                            if index < 6 && (index != 2 && index != 6) {
                                let noteName = index == 0 ? "C#" : index == 1 ? "D#" : index == 3 ? "F#" : index == 4 ? "G#" : "A#"
                                let isHighlighted = notes.contains { $0.name == noteName || $0.name == enharmonic(noteName) }
                                
                                Rectangle()
                                    .fill(isHighlighted ? Color.blue : Color.black)
                                    .frame(width: blackKeyWidth, height: blackKeyHeight)
                                    .offset(x: whiteKeyWidth * CGFloat(index) + whiteKeyWidth - blackKeyWidth / 2)
                                    .overlay(
                                        VStack {
                                            Spacer()
                                            if isHighlighted {
                                                Text(noteName)
                                                    .font(.system(size: 8))
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                        .padding(.bottom, 2)
                                        .offset(x: whiteKeyWidth * CGFloat(index) + whiteKeyWidth - blackKeyWidth / 2)
                                    )
                            }
                        }
                    }
                }
            }
            .frame(height: 90)
            
            // Note names
            Text(notes.map { $0.name }.joined(separator: " - "))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func enharmonic(_ note: String) -> String {
        switch note {
        case "C#": return "Db"
        case "D#": return "Eb"
        case "F#": return "Gb"
        case "G#": return "Ab"
        case "A#": return "Bb"
        case "Db": return "C#"
        case "Eb": return "D#"
        case "Gb": return "F#"
        case "Ab": return "G#"
        case "Bb": return "A#"
        default: return note
        }
    }
}

// MARK: - Active Chord Identification View

/// View for chord identification mode - user selects chords by root + quality
struct ActiveChordIdentificationView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var viewState: CadenceDrillView.ViewState
    
    @State private var currentChordIndex = 0
    @State private var chordSelections: [ChordSelection] = [ChordSelection(), ChordSelection(), ChordSelection(), ChordSelection(), ChordSelection()]
    @State private var showingFeedback = false
    @State private var feedbackResults: [Bool] = []
    
    private var question: CadenceQuestion? {
        cadenceGame.currentQuestion
    }
    
    private var expectedChords: [Chord] {
        question?.cadence.chords ?? []
    }
    
    private var availableQualities: [CadenceChordQuality] {
        guard let q = question else { return CadenceChordQuality.allCadenceQualities }
        switch q.cadence.cadenceType {
        case .major, .tritoneSubstitution, .backdoor, .birdChanges:
            return CadenceChordQuality.majorCadenceQualities
        case .minor:
            return CadenceChordQuality.minorCadenceQualities
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if let question = question {
                // Header: Key and Cadence Type
                VStack(spacing: 8) {
                    Text("Key of \(question.cadence.key.name)")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text(question.cadence.cadenceType.rawValue)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Roman numeral indicators
                HStack(spacing: 20) {
                    ForEach(0..<expectedChords.count, id: \.self) { index in
                        chordPositionIndicator(index: index)
                    }
                }
                .padding(.horizontal)
                
                // Current selection display
                if !showingFeedback {
                    VStack(spacing: 8) {
                        Text("Enter chord \(currentChordIndex + 1) of \(expectedChords.count)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(romanNumeral(for: currentChordIndex, cadenceType: question.cadence.cadenceType))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.blue)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Chord Selector or Feedback
                if showingFeedback {
                    feedbackView()
                } else {
                    ChordSelectorView(
                        selection: $chordSelections[currentChordIndex],
                        availableQualities: availableQualities,
                        disabled: false,
                        onComplete: nil
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Action Buttons
                actionButtons()
            }
        }
        .padding(.vertical)
        .onAppear {
            resetForNewQuestion()
        }
        .onChange(of: cadenceGame.currentQuestion?.id) { _, _ in
            resetForNewQuestion()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func chordPositionIndicator(index: Int) -> some View {
        let isActive = index == currentChordIndex && !showingFeedback
        let isCompleted = index < currentChordIndex || showingFeedback
        let selection = chordSelections[safe: index]
        
        VStack(spacing: 4) {
            // Roman numeral
            if let q = question {
                Text(romanNumeral(for: index, cadenceType: q.cadence.cadenceType))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Chord display
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor(isActive: isActive, isCompleted: isCompleted, index: index))
                    .frame(width: 80, height: 50)
                
                if isCompleted && showingFeedback {
                    // Show the selected chord with correctness indicator
                    VStack(spacing: 2) {
                        Text(selection?.displayName ?? "—")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(feedbackResults[safe: index] == true ? .green : .red)
                        
                        Image(systemName: feedbackResults[safe: index] == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(feedbackResults[safe: index] == true ? .green : .red)
                    }
                } else if isCompleted || selection?.isComplete == true {
                    Text(selection?.displayName ?? "—")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                } else if isActive {
                    Text("?")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("—")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func backgroundColor(isActive: Bool, isCompleted: Bool, index: Int) -> Color {
        if showingFeedback {
            return feedbackResults[safe: index] == true ? Color.green.opacity(0.8) : Color.red.opacity(0.8)
        } else if isCompleted {
            return Color.blue
        } else if isActive {
            return Color.blue.opacity(0.7)
        } else {
            return Color(.systemGray4)
        }
    }
    
    @ViewBuilder
    private func feedbackView() -> some View {
        VStack(spacing: 16) {
            let allCorrect = feedbackResults.allSatisfy { $0 }
            
            Image(systemName: allCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(allCorrect ? .green : .red)
            
            Text(allCorrect ? "Correct!" : "Not quite right")
                .font(.title2)
                .fontWeight(.bold)
            
            // Show correct answers if wrong
            if !allCorrect {
                VStack(spacing: 8) {
                    Text("Correct progression:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 16) {
                        ForEach(expectedChords.indices, id: \.self) { index in
                            Text(expectedChords[index].displayName)
                                .font(.headline)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.2))
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func actionButtons() -> some View {
        HStack(spacing: 16) {
            if showingFeedback {
                Button(action: nextQuestion) {
                    Text(cadenceGame.isLastQuestion ? "Finish" : "Next")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            } else {
                // Clear button
                Button(action: clearCurrentChord) {
                    Text("Clear")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Next Chord / Submit button
                Button(action: advanceOrSubmit) {
                    Text(currentChordIndex < expectedChords.count - 1 ? "Next Chord" : "Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(chordSelections[currentChordIndex].isComplete ? Color.blue : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!chordSelections[currentChordIndex].isComplete)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func resetForNewQuestion() {
        currentChordIndex = 0
        chordSelections = [ChordSelection(), ChordSelection(), ChordSelection(), ChordSelection(), ChordSelection()]
        showingFeedback = false
        feedbackResults = []
    }
    
    private func clearCurrentChord() {
        chordSelections[currentChordIndex].reset()
        HapticFeedback.light()
    }
    
    private func advanceOrSubmit() {
        if currentChordIndex < expectedChords.count - 1 {
            // Move to next chord
            currentChordIndex += 1
            HapticFeedback.light()
        } else {
            // Submit all answers
            submitAnswer()
        }
    }
    
    private func submitAnswer() {
        // Check each chord
        feedbackResults = expectedChords.indices.map { index in
            chordSelections[index].matches(expectedChords[index])
        }
        
        let allCorrect = feedbackResults.allSatisfy { $0 }
        
        // Record answer in game
        cadenceGame.recordChordIdentificationAnswer(
            selections: Array(chordSelections.prefix(expectedChords.count)),
            isCorrect: allCorrect
        )
        
        // Haptic feedback
        if allCorrect {
            HapticFeedback.success()
            if settings.playChordOnCorrect {
                AudioManager.shared.playSuccessSound()
            }
        } else {
            HapticFeedback.error()
        }
        
        showingFeedback = true
    }
    
    private func nextQuestion() {
        if cadenceGame.isLastQuestion {
            cadenceGame.endQuiz()
            viewState = .results
        } else {
            cadenceGame.advanceToNextQuestion()
            resetForNewQuestion()
        }
    }
    
    // MARK: - Helpers
    
    private func romanNumeral(for index: Int, cadenceType: CadenceType) -> String {
        switch cadenceType {
        case .major, .tritoneSubstitution, .backdoor, .birdChanges:
            switch index {
            case 0: return "ii"
            case 1: return cadenceType == .tritoneSubstitution ? "SubV" : "V"
            case 2: return "I"
            default: return ""
            }
        case .minor:
            switch index {
            case 0: return "ii°"
            case 1: return "V"
            case 2: return "i"
            default: return ""
            }
        case .birdChanges:
            switch index {
            case 0: return "iii"
            case 1: return "VI"
            case 2: return "ii"
            case 3: return "V"
            case 4: return "I"
            default: return ""
            }
        }
    }
}

// MARK: - Array Safe Subscript Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
