import SwiftUI

// MARK: - Interval Drill View State

enum IntervalDrillViewState {
    case setup
    case active
    case results
}

// MARK: - Interval Drill View

struct IntervalDrillView: View {
    @EnvironmentObject var intervalGame: IntervalGame
    @EnvironmentObject var settings: SettingsManager
    @State private var viewState: IntervalDrillViewState = .setup
    
    // Setup configuration
    @State private var numberOfQuestions: Int = 10
    @State private var selectedDifficulty: IntervalDifficulty = .beginner
    @State private var selectedQuestionTypes: Set<IntervalQuestionType> = [.buildInterval]
    @State private var selectedDirection: IntervalDirection = .ascending
    @State private var selectedKeyDifficulty: KeyDifficulty = .easy
    
    // Session state
    @State private var selectedNote: Note?
    @State private var selectedInterval: IntervalType?
    @State private var showingFeedback = false
    @State private var hasSubmitted = false
    
    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                IntervalDrillSetup(
                    numberOfQuestions: $numberOfQuestions,
                    selectedDifficulty: $selectedDifficulty,
                    selectedQuestionTypes: $selectedQuestionTypes,
                    selectedDirection: $selectedDirection,
                    selectedKeyDifficulty: $selectedKeyDifficulty,
                    onStart: startQuiz
                )
            case .active:
                IntervalDrillSession(
                    selectedNote: $selectedNote,
                    selectedInterval: $selectedInterval,
                    showingFeedback: $showingFeedback,
                    hasSubmitted: $hasSubmitted,
                    onSubmit: submitAnswer,
                    onNext: nextQuestion
                )
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
                    .foregroundColor(.red)
                }
            }
        }
        .onChange(of: intervalGame.showingResults) { _, showingResults in
            if showingResults {
                viewState = .results
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
        selectedNote = nil
        selectedInterval = nil
        hasSubmitted = false
        viewState = .active
    }
    
    private func submitAnswer() {
        guard let question = intervalGame.currentQuestion else { return }
        hasSubmitted = true
        
        var isCorrect = false
        
        switch question.questionType {
        case .buildInterval:
            if let note = selectedNote {
                isCorrect = intervalGame.checkAnswer(selectedNote: note)
            }
        case .identifyInterval, .auralIdentify:
            if let interval = selectedInterval {
                isCorrect = intervalGame.checkAnswer(selectedInterval: interval)
            }
        }
        
        // Haptic feedback and audio
        if isCorrect {
            IntervalDrillHaptics.success()
            if settings.playChordOnCorrect {
                AudioManager.shared.playInterval(
                    rootNote: question.interval.rootNote,
                    targetNote: question.interval.targetNote,
                    style: settings.defaultIntervalStyle,
                    tempo: settings.intervalTempo
                )
            }
        } else {
            IntervalDrillHaptics.error()
            if settings.playChordOnCorrect {
                playIncorrectFeedback(question: question)
            }
        }
        
        showingFeedback = true
    }
    
    private func playIncorrectFeedback(question: IntervalQuestion) {
        switch question.questionType {
        case .buildInterval:
            if let userNote = selectedNote {
                let userInterval = Interval(
                    rootNote: question.interval.rootNote,
                    intervalType: IntervalDatabase.shared.interval(forSemitones: abs(userNote.midiNumber - question.interval.rootNote.midiNumber)) ?? question.interval.intervalType,
                    direction: question.interval.direction
                )
                AudioManager.shared.playInterval(
                    rootNote: userInterval.rootNote,
                    targetNote: userInterval.targetNote,
                    style: settings.defaultIntervalStyle,
                    tempo: settings.intervalTempo
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    AudioManager.shared.playInterval(
                        rootNote: question.interval.rootNote,
                        targetNote: question.interval.targetNote,
                        style: settings.defaultIntervalStyle,
                        tempo: settings.intervalTempo
                    )
                }
            }
            
        case .identifyInterval, .auralIdentify:
            if let userIntervalType = selectedInterval {
                let userInterval = Interval(
                    rootNote: question.interval.rootNote,
                    intervalType: userIntervalType,
                    direction: question.interval.direction
                )
                AudioManager.shared.playInterval(
                    rootNote: userInterval.rootNote,
                    targetNote: userInterval.targetNote,
                    style: settings.defaultIntervalStyle,
                    tempo: settings.intervalTempo
                )
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    AudioManager.shared.playInterval(
                        rootNote: question.interval.rootNote,
                        targetNote: question.interval.targetNote,
                        style: settings.defaultIntervalStyle,
                        tempo: settings.intervalTempo
                    )
                }
            }
        }
    }
    
    private func nextQuestion() {
        selectedNote = nil
        selectedInterval = nil
        hasSubmitted = false
        showingFeedback = false
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

// MARK: - Haptic Feedback Helper

enum IntervalDrillHaptics {
    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    static func error() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    static func light() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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
