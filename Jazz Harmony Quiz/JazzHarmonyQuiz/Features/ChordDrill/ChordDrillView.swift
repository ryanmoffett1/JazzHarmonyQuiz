import SwiftUI
import UIKit

// MARK: - Chord Drill View

/// Main container view for the Chord Drill feature
/// Manages navigation between Setup, Session, and Results states
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
    
    init(numberOfQuestions: Int = 10,
         selectedDifficulty: ChordType.ChordDifficulty = .beginner,
         selectedQuestionTypes: Set<QuestionType> = [.singleTone, .allTones]) {
        self._numberOfQuestions = State(initialValue: numberOfQuestions)
        self._selectedDifficulty = State(initialValue: selectedDifficulty)
        self._selectedQuestionTypes = State(initialValue: selectedQuestionTypes)
    }
    
    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                ChordDrillSetup(
                    numberOfQuestions: $numberOfQuestions,
                    selectedDifficulty: $selectedDifficulty,
                    selectedQuestionTypes: $selectedQuestionTypes,
                    selectedKeyDifficulty: $selectedKeyDifficulty,
                    selectedChordSymbols: $selectedChordSymbols,
                    onStartQuiz: startQuiz
                )
            case .active:
                ChordDrillSessionView(
                    selectedNotes: $selectedNotes,
                    selectedChordType: $selectedChordType,
                    showingFeedback: $showingFeedback,
                    viewState: $viewState
                )
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
    }
    
    // MARK: - Actions
    
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
