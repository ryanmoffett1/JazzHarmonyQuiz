import SwiftUI
import UIKit

// MARK: - Scale Drill View

/// Main container view for the Scale Drill feature
/// Manages navigation between Setup, Session, and Results states
///
/// Per DESIGN.md Appendix C: Supports three launch modes:
/// - freePractice: Shows full setup (Practice tab)
/// - curriculum: Locks config to module's recommendedConfig
/// - quickPractice: Uses QuickPracticeSession instead
struct ScaleDrillView: View {
    @EnvironmentObject var scaleGame: ScaleGame
    @EnvironmentObject var settings: SettingsManager
    @State private var selectedNotes: Set<Note> = []
    @State private var viewState: DrillState = .setup
    @State private var numberOfQuestions: Int = 10
    @State private var selectedDifficulty: ScaleType.ScaleDifficulty = .beginner
    @State private var selectedQuestionTypes: Set<ScaleQuestionType> = [.allDegrees]
    @State private var selectedKeyDifficulty: KeyDifficulty = .all
    @State private var selectedScaleSymbols: Set<String> = []
    @State private var showingFeedback = false
    
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
                    ScaleDrillSetup(
                        numberOfQuestions: $numberOfQuestions,
                        selectedDifficulty: $selectedDifficulty,
                        selectedQuestionTypes: $selectedQuestionTypes,
                        selectedKeyDifficulty: $selectedKeyDifficulty,
                        selectedScaleSymbols: $selectedScaleSymbols,
                        onStartQuiz: startQuiz
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
                    
                    ScaleDrillSession(
                        selectedNotes: $selectedNotes,
                        showingFeedback: $showingFeedback,
                        viewState: $viewState
                    )
                }
            case .results:
                ScaleDrillResults(onNewQuiz: {
                    scaleGame.resetQuizState()
                    viewState = .setup
                    selectedNotes = []
                    showingFeedback = false
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if scaleGame.isQuizActive {
                    Button("Quit") {
                        quitQuiz()
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                if scaleGame.isQuizActive {
                    VStack {
                        Text("Question \(scaleGame.currentQuestionNumber) of \(scaleGame.totalQuestions)")
                            .font(.headline)
                        ProgressView(value: scaleGame.progress)
                            .frame(width: 200)
                    }
                }
            }
        }
        .onChange(of: scaleGame.isQuizCompleted) { oldValue, newValue in
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
                    
                    if let scaleTypes = module.recommendedConfig.scaleTypes {
                        configRow(label: "Scale Types", value: scaleTypes.joined(separator: ", "))
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
        
        // Map scale types
        if let scaleTypes = config.scaleTypes, !scaleTypes.isEmpty {
            selectedScaleSymbols = Set(scaleTypes)
            // Determine difficulty from scale types
            let modeScales = ["Dorian", "Phrygian", "Lydian", "Mixolydian", "Aeolian", "Locrian"]
            let advancedScales = ["Melodic Minor", "Harmonic Minor", "Whole Tone", "Diminished"]
            
            if scaleTypes.contains(where: { advancedScales.contains($0) }) {
                selectedDifficulty = .advanced
            } else if scaleTypes.contains(where: { modeScales.contains($0) }) {
                selectedDifficulty = .intermediate
            } else {
                selectedDifficulty = .beginner
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
        selectedNotes = []
        showingFeedback = false
        viewState = .active
        
        scaleGame.selectedKeyDifficulty = selectedKeyDifficulty
        scaleGame.selectedScaleSymbols = selectedScaleSymbols
        
        scaleGame.startNewQuiz(
            numberOfQuestions: numberOfQuestions,
            difficulty: selectedDifficulty,
            questionTypes: selectedQuestionTypes
        )
    }
    
    private func quitQuiz() {
        viewState = .setup
        scaleGame.resetQuizState()
        selectedNotes = []
        showingFeedback = false
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScaleDrillView()
            .environmentObject(ScaleGame())
            .environmentObject(SettingsManager.shared)
    }
}
