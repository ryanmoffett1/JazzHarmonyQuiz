import SwiftUI

// MARK: - Cadence Drill View State

/// Shared state enum for cadence drill view navigation
enum CadenceDrillViewState {
    case setup
    case active
    case results
}

// MARK: - Cadence Drill View

/// Main container view for the Cadence Drill feature
/// Manages navigation between Setup, Session, and Results states
struct CadenceDrillView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @State private var viewState: CadenceDrillViewState = .setup
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

    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
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
            case .active:
                if cadenceGame.selectedDrillMode == .chordIdentification {
                    CadenceChordIdentificationSession(viewState: $viewState)
                } else {
                    CadenceDrillSession(
                        viewState: $viewState,
                        userSelectedCadenceType: $userSelectedCadenceType
                    )
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
