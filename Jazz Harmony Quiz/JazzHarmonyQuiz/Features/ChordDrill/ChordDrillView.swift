import SwiftUI
import UIKit

// MARK: - Chord Drill View

/// Main container view for the Chord Drill feature
/// Manages navigation between Setup, Session, and Results states
/// 
/// Per DESIGN.md Appendix C: Supports three launch modes:
/// - freePractice: Shows full setup (Practice tab)
/// - curriculum: Locks config to module's recommendedConfig
/// - quickPractice: Uses QuickPracticeSession instead
struct ChordDrillView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @State private var selectedNotes: Set<Note> = []
    @State private var selectedChordType: ChordType? = nil
    @State private var viewState: DrillState = .setup
    @State private var numberOfQuestions: Int
    @State private var selectedDifficulty: ChordType.ChordDifficulty
    @State private var selectedQuestionTypes: Set<QuestionType>
    @State private var selectedKeyDifficulty: KeyDifficulty = .all
    @State private var selectedChordSymbols: Set<String> = []
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
    
    init(
        launchMode: DrillLaunchMode = .freePractice,
        numberOfQuestions: Int = 10,
        selectedDifficulty: ChordType.ChordDifficulty = .beginner,
        selectedQuestionTypes: Set<QuestionType> = [.singleTone, .allTones]
    ) {
        self.launchMode = launchMode
        self._numberOfQuestions = State(initialValue: numberOfQuestions)
        self._selectedDifficulty = State(initialValue: selectedDifficulty)
        self._selectedQuestionTypes = State(initialValue: selectedQuestionTypes)
    }
    
    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                if launchMode.showsSetupScreen {
                    ChordDrillSetup(
                        numberOfQuestions: $numberOfQuestions,
                        selectedDifficulty: $selectedDifficulty,
                        selectedQuestionTypes: $selectedQuestionTypes,
                        selectedKeyDifficulty: $selectedKeyDifficulty,
                        selectedChordSymbols: $selectedChordSymbols,
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
                    
                    ChordDrillSessionView(
                        selectedNotes: $selectedNotes,
                        selectedChordType: $selectedChordType,
                        showingFeedback: $showingFeedback,
                        viewState: $viewState
                    )
                }
            case .results:
                ChordDrillResults(onNewQuiz: {
                    // Reset quiz and show setup
                    quizGame.resetQuizState()
                    viewState = .setup
                    selectedNotes = []
                    showingFeedback = false
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if quizGame.isQuizActive {
                    Button("Quit") {
                        quitQuiz()
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                if quizGame.isQuizActive {
                    VStack {
                        Text("Question \(quizGame.currentQuestionNumber) of \(quizGame.totalQuestions)")
                            .font(.headline)
                        ProgressView(value: quizGame.progress)
                            .frame(width: 200)
                    }
                }
            }
        }
        .onChange(of: quizGame.isQuizCompleted) { oldValue, newValue in
            if newValue && !oldValue {
                viewState = .results
            }
        }
        .onAppear {
            // Auto-start for curriculum mode
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
                    
                    if let chordTypes = module.recommendedConfig.chordTypes {
                        configRow(label: "Chord Types", value: chordTypes.joined(separator: ", "))
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
    
    // MARK: - Actions
    
    private func applyModuleConfig() {
        guard let module = activeModule else { return }
        let config = module.recommendedConfig
        
        // Apply locked config from module
        numberOfQuestions = config.totalQuestions
        
        // Map chord type strings to actual symbols using the resolver
        if let resolvedSymbols = config.resolvedChordSymbols {
            selectedChordSymbols = resolvedSymbols
            // Set difficulty based on chord types
            if resolvedSymbols.contains(where: { $0.contains("7") || $0.contains("9") }) {
                selectedDifficulty = .intermediate
            } else {
                selectedDifficulty = .beginner
            }
        }
        
        // Map question type
        if let questionType = config.questionType {
            switch questionType {
            case "allTones":
                selectedQuestionTypes = [.allTones]
            case "singleTone":
                selectedQuestionTypes = [.singleTone]
            case "auralQuality":
                selectedQuestionTypes = [.auralQuality]
            default:
                selectedQuestionTypes = [.allTones, .singleTone]
            }
        }
    }
    
    private func startQuiz() {
        // Clear all previous state
        selectedNotes = []
        showingFeedback = false
        viewState = .active
        
        // Set filtering options before starting
        quizGame.selectedKeyDifficulty = selectedKeyDifficulty
        quizGame.selectedChordSymbols = selectedChordSymbols
        
        // Start the new quiz
        quizGame.startNewQuiz(
            numberOfQuestions: numberOfQuestions,
            difficulty: selectedDifficulty,
            questionTypes: selectedQuestionTypes
        )
    }
    
    private func quitQuiz() {
        viewState = .setup
        quizGame.resetQuizState()
        selectedNotes = []
        showingFeedback = false
    }
}

// MARK: - Chord Type Picker

/// Picker component for selecting chord types (used in aural quality questions)
struct ChordTypePicker: View {
    let difficulty: ChordType.ChordDifficulty
    @Binding var selectedChordType: ChordType?
    let correctChord: ChordType?
    let disabled: Bool

    private var chordTypes: [ChordType] {
        JazzChordDatabase.shared.chordTypes.filter { $0.difficulty == difficulty }
    }

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 80), spacing: 8)
        ], spacing: 8) {
            ForEach(chordTypes) { chordType in
                Button(action: {
                    if !disabled {
                        selectedChordType = chordType
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                    }
                }) {
                    VStack(spacing: 2) {
                        Text(chordType.symbol)
                            .font(.headline)
                        Text(chordType.name)
                            .font(.system(size: 9))
                            .lineLimit(1)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    .background(backgroundColor(for: chordType))
                    .foregroundColor(foregroundColor(for: chordType))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor(for: chordType), lineWidth: 2)
                    )
                }
                .disabled(disabled)
            }
        }
    }

    private func backgroundColor(for chordType: ChordType) -> Color {
        if let correct = correctChord {
            if chordType.symbol == correct.symbol {
                return .green.opacity(0.3)
            } else if chordType == selectedChordType {
                return .red.opacity(0.3)
            }
        }

        if chordType == selectedChordType {
            return .green.opacity(0.2)
        }
        return Color(.systemGray6)
    }

    private func foregroundColor(for chordType: ChordType) -> Color {
        if let correct = correctChord {
            if chordType.symbol == correct.symbol {
                return .green
            } else if chordType == selectedChordType {
                return .red
            }
        }

        if chordType == selectedChordType {
            return .green
        }
        return .primary
    }

    private func borderColor(for chordType: ChordType) -> Color {
        if let correct = correctChord {
            if chordType.symbol == correct.symbol {
                return .green
            } else if chordType == selectedChordType {
                return .red
            }
        }

        if chordType == selectedChordType {
            return .green
        }
        return .clear
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ChordDrillView()
            .environmentObject(QuizGame())
            .environmentObject(SettingsManager.shared)
    }
}
