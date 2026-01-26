import SwiftUI
import UIKit

// MARK: - Scale Drill View

/// Main container view for the Scale Drill feature
/// Manages navigation between Setup, Session, and Results states
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
    
    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                ScaleDrillSetup(
                    numberOfQuestions: $numberOfQuestions,
                    selectedDifficulty: $selectedDifficulty,
                    selectedQuestionTypes: $selectedQuestionTypes,
                    selectedKeyDifficulty: $selectedKeyDifficulty,
                    selectedScaleSymbols: $selectedScaleSymbols,
                    onStartQuiz: startQuiz
                )
            case .active:
                ScaleDrillSession(
                    selectedNotes: $selectedNotes,
                    showingFeedback: $showingFeedback,
                    viewState: $viewState
                )
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
