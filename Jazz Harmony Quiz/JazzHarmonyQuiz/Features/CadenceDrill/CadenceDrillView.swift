import SwiftUI

// MARK: - Cadence Drill View

/// Main container view for the Cadence Drill feature
/// Manages navigation between Setup, Session, and Results states
///
/// Per DESIGN.md Appendix C: Supports three launch modes:
/// - freePractice: Shows full setup (Practice tab)
/// - curriculum: Locks config to module's recommendedConfig
/// - quickPractice: Uses QuickPracticeSession instead
struct CadenceDrillView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @State private var viewState: DrillState = .setup
    @State private var numberOfQuestions: Int = 10
    @State private var selectedCadenceType: CadenceType = .major
    @State private var selectedDrillMode: CadenceDrillMode = .fullProgression
    @State private var selectedKeyDifficulty: KeyDifficulty = .all
    
    // Phase 2 state
    @State private var useMixedCadences: Bool = false
    @State private var selectedCadenceTypes: Set<CadenceType> = [.major, .minor]
    
    // Phase 3 state
    @State private var useExtendedVChords: Bool = false
    @State private var selectedExtendedVChord: ExtendedVChordOption = .ninth
    @State private var selectedCommonTonePair: CommonTonePair = .iiToV

    // Ear training state
    @State private var userSelectedCadenceType: CadenceType? = nil
    
    /// The launch mode determines UI behavior and config locking
    let launchMode: DrillLaunchMode
    
    /// Module info for curriculum mode header
    private var activeModule: CurriculumModule? {
        if case .curriculum(let moduleId) = launchMode {
            return CurriculumManager.shared.allModules.first { $0.id == moduleId }
        }
        return nil
    }
    
    init(launchMode: DrillLaunchMode = .freePractice) {
        self.launchMode = launchMode
    }

    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                if launchMode.showsSetupScreen {
                    CadenceDrillSetup(
                        numberOfQuestions: $numberOfQuestions,
                        selectedCadenceType: $selectedCadenceType,
                        selectedDrillMode: $selectedDrillMode,
                        selectedKeyDifficulty: $selectedKeyDifficulty,
                        useMixedCadences: $useMixedCadences,
                        selectedCadenceTypes: $selectedCadenceTypes,
                        useExtendedVChords: $useExtendedVChords,
                        selectedExtendedVChord: $selectedExtendedVChord,
                        selectedCommonTonePair: $selectedCommonTonePair,
                        onStartQuiz: startQuiz,
                        onPracticeWeakKeys: startWeakKeyPractice
                    )
                } else {
                    // Curriculum mode: show config summary then auto-start
                    curriculumStartView
                }
            case .active:
                VStack(spacing: 0) {
                    // Curriculum mode header
                    if let module = activeModule {
                        curriculumHeader(for: module)
                    }
                    
                    if cadenceGame.selectedDrillMode == .chordIdentification {
                        CadenceChordIdentificationSession(viewState: $viewState)
                    } else {
                        CadenceDrillSession(
                            viewState: $viewState,
                            userSelectedCadenceType: $userSelectedCadenceType
                        )
                    }
                }
            case .results:
                CadenceDrillResults(onNewQuiz: {
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
        .onAppear {
            // Auto-apply config for curriculum mode
            if case .curriculum = launchMode {
                applyModuleConfig()
            }
        }
    }
    
    // MARK: - Curriculum Mode Views
    
    private var curriculumStartView: some View {
        VStack(spacing: 24) {
            if let module = activeModule {
                // Module header
                VStack(spacing: 8) {
                    Text(module.emoji)
                        .font(.system(size: 60))
                    Text(module.title)
                        .font(.title)
                        .fontWeight(.bold)
                    Text(module.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 40)
                
                Divider()
                    .padding(.horizontal, 40)
                
                // Config summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("SESSION CONFIG")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    configRow(label: "Questions", value: "\(module.recommendedConfig.totalQuestions)")
                    
                    if let drillMode = module.recommendedConfig.drillMode {
                        configRow(label: "Mode", value: drillMode.capitalized)
                    }
                    
                    if let cadenceTypes = module.recommendedConfig.cadenceTypes {
                        configRow(label: "Cadence Types", value: cadenceTypes.joined(separator: ", ").capitalized)
                    }
                    
                    configRow(label: "Audio", value: module.recommendedConfig.useAudio ? "Enabled" : "Disabled")
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
                .padding(.horizontal)
                
                Spacer()
                
                // Start button
                Button {
                    startQuiz()
                } label: {
                    Text("Start Practice")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color("BrassAccent"))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            } else {
                Text("Module not found")
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func configRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
    
    private func curriculumHeader(for module: CurriculumModule) -> some View {
        HStack {
            Text(module.emoji)
            Text(module.title)
                .font(.subheadline)
                .fontWeight(.medium)
            Spacer()
            Image(systemName: "lock.fill")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(Color("BrassAccent").opacity(0.1))
    }
    
    // MARK: - Config Application
    
    private func applyModuleConfig() {
        guard let module = activeModule else { return }
        let config = module.recommendedConfig
        
        // Apply locked config from module
        numberOfQuestions = config.totalQuestions
        
        // Map cadence types
        if let cadenceTypes = config.cadenceTypes, !cadenceTypes.isEmpty {
            // Map string names to CadenceType enum
            let mapped = cadenceTypes.compactMap { name -> CadenceType? in
                switch name.lowercased() {
                case "major": return .major
                case "minor": return .minor
                case "tritonesub", "tritone", "tritonesubstitution": return .tritoneSubstitution
                case "backdoor": return .backdoor
                case "birdchanges", "bird": return .birdChanges
                default: return nil
                }
            }
            if !mapped.isEmpty {
                selectedCadenceTypes = Set(mapped)
                useMixedCadences = mapped.count > 1
                selectedCadenceType = mapped.first ?? .major
            }
        }
        
        // Map drill mode
        if let drillMode = config.drillMode {
            switch drillMode.lowercased() {
            case "fullprogression", "full": selectedDrillMode = .fullProgression
            case "chordidentification", "identify": selectedDrillMode = .chordIdentification
            case "auralidentify", "aural": selectedDrillMode = .auralIdentify
            case "guidetones", "guide": selectedDrillMode = .guideTones
            case "commontones", "common": selectedDrillMode = .commonTones
            case "resolutiontargets", "resolution": selectedDrillMode = .resolutionTargets
            default: selectedDrillMode = .fullProgression
            }
        }
        
        // Map key difficulty
        if let keyDiff = config.keyDifficulty {
            switch keyDiff.lowercased() {
            case "easy": selectedKeyDifficulty = .easy
            case "medium": selectedKeyDifficulty = .medium
            case "hard": selectedKeyDifficulty = .hard
            default: selectedKeyDifficulty = .all
            }
        }
    }

    // MARK: - Actions
    
    private func startQuiz() {
        // Set Phase 2 parameters
        cadenceGame.useMixedCadences = useMixedCadences
        cadenceGame.selectedCadenceTypes = selectedCadenceTypes
        
        // Set Phase 3 parameters
        cadenceGame.useExtendedVChords = useExtendedVChords
        cadenceGame.selectedExtendedVChord = selectedExtendedVChord
        cadenceGame.selectedCommonTonePair = selectedCommonTonePair
        
        // Generate questions FIRST, before changing view state
        cadenceGame.startNewQuiz(
            numberOfQuestions: numberOfQuestions,
            cadenceType: selectedCadenceType,
            drillMode: selectedDrillMode,
            keyDifficulty: selectedKeyDifficulty
        )
        
        // Only switch to active view AFTER questions are ready
        viewState = .active
    }
    
    private func startWeakKeyPractice() {
        cadenceGame.startWeakKeyPractice()
        viewState = .active
    }

    private func quitQuiz() {
        viewState = .setup
        cadenceGame.resetQuizState()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CadenceDrillView()
            .environmentObject(CadenceGame())
            .environmentObject(SettingsManager.shared)
    }
}
