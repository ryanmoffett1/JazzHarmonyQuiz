import SwiftUI

// MARK: - Interval Drill View

/// Main container view for the Interval Drill feature
/// Per DESIGN.md Appendix C: Supports three launch modes:
/// - freePractice: Shows full setup (Practice tab)
/// - curriculum: Locks config to module's recommendedConfig
/// - quickPractice: Uses QuickPracticeSession instead
struct IntervalDrillView: View {
    @EnvironmentObject var intervalGame: IntervalGame
    @EnvironmentObject var settings: SettingsManager
    @StateObject private var viewModel = IntervalDrillViewModel()
    @State private var viewState: DrillState = .setup
    
    // Setup configuration
    @State private var numberOfQuestions: Int = 10
    @State private var selectedDifficulty: IntervalDifficulty = .beginner
    @State private var selectedQuestionTypes: Set<IntervalQuestionType> = [.buildInterval]
    @State private var selectedDirection: IntervalDirection = .ascending
    @State private var selectedKeyDifficulty: KeyDifficulty = .easy
    
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
                    IntervalDrillSetup(
                        numberOfQuestions: $numberOfQuestions,
                        selectedDifficulty: $selectedDifficulty,
                        selectedQuestionTypes: $selectedQuestionTypes,
                        selectedDirection: $selectedDirection,
                        selectedKeyDifficulty: $selectedKeyDifficulty,
                        onStart: startQuiz
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
                    
                    IntervalDrillSession(
                        selectedNote: $viewModel.selectedNote,
                        selectedInterval: $viewModel.selectedInterval,
                        showingFeedback: $viewModel.showingFeedback,
                        hasSubmitted: $viewModel.hasSubmitted,
                        onSubmit: submitAnswer,
                        onNext: nextQuestion
                    )
                }
            case .results:
                IntervalDrillResults(
                    onPlayAgain: playAgain,
                    onBackToSetup: backToSetup
                )
            }
        }
        .navigationTitle("Interval Drill")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if viewState == .active {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Quit") {
                        quitQuiz()
                    }
                    .foregroundColor(ShedTheme.Colors.danger)
                }
            }
        }
        .onChange(of: intervalGame.showingResults) { _, showingResults in
            if showingResults {
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
                    
                    if let intervalTypes = module.recommendedConfig.intervalTypes {
                        configRow(label: "Intervals", value: intervalTypes.prefix(3).joined(separator: ", ") + (intervalTypes.count > 3 ? "..." : ""))
                    }
                    
                    if let mode = module.recommendedConfig.intervalMode {
                        configRow(label: "Mode", value: mode.capitalized)
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
        
        // Map interval mode (visual vs aural)
        if let intervalMode = config.intervalMode {
            switch intervalMode.lowercased() {
            case "aural", "ear", "auralidentify":
                selectedQuestionTypes = [.auralIdentify]
            case "visual", "build", "buildinterval":
                selectedQuestionTypes = [.buildInterval]
            case "identify", "identifyinterval":
                selectedQuestionTypes = [.identifyInterval]
            default:
                selectedQuestionTypes = [.buildInterval]
            }
        }
        
        // Map interval types to set difficulty
        if let intervalTypes = config.intervalTypes, !intervalTypes.isEmpty {
            // Basic intervals are easier
            let basicIntervals = ["minor 2nd", "major 2nd", "minor 3rd", "major 3rd", "perfect 4th", "perfect 5th"]
            let advancedIntervals = ["minor 6th", "major 6th", "minor 7th", "major 7th", "tritone"]
            
            let hasAdvanced = intervalTypes.contains(where: { advancedIntervals.contains($0.lowercased()) })
            let hasBasic = intervalTypes.contains(where: { basicIntervals.contains($0.lowercased()) })
            
            if hasAdvanced && !hasBasic {
                selectedDifficulty = .advanced
            } else if hasAdvanced {
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
            default: selectedKeyDifficulty = .easy
            }
        }
    }
    
    // MARK: - Actions
    
    private func startQuiz() {
        intervalGame.startQuiz(
            numberOfQuestions: numberOfQuestions,
            difficulty: selectedDifficulty,
            questionTypes: selectedQuestionTypes,
            direction: selectedDirection,
            keyDifficulty: selectedKeyDifficulty
        )
        viewModel.clearSelection()
        viewModel.hasSubmitted = false
        viewState = .active
    }
    
    private func submitAnswer() {
        guard let question = intervalGame.currentQuestion else { return }
        
        viewModel.submitAnswer(
            question: question,
            checkBuildAnswer: { note in
                intervalGame.checkAnswer(selectedNote: note)
            },
            checkIdentifyAnswer: { interval in
                intervalGame.checkAnswer(selectedInterval: interval)
            }
        )
    }
    
    
    private func nextQuestion() {
        viewModel.resetForNextQuestion()
        intervalGame.nextQuestion()
    }
    
    private func playAgain() {
        intervalGame.resetQuiz()
        startQuiz()
    }
    
    private func backToSetup() {
        intervalGame.resetQuiz()
        viewState = .setup
    }
    
    private func quitQuiz() {
        intervalGame.resetQuiz()
        viewState = .setup
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        IntervalDrillView()
            .environmentObject(IntervalGame())
            .environmentObject(SettingsManager.shared)
    }
}
