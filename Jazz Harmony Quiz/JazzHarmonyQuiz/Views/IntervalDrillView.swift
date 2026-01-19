import SwiftUI
import UIKit

// MARK: - Haptic Feedback Helper
fileprivate enum IntervalDrillHaptics {
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

// MARK: - Interval Drill View

struct IntervalDrillView: View {
    @EnvironmentObject var intervalGame: IntervalGame
    @EnvironmentObject var settings: SettingsManager
    @State private var selectedNote: Note?
    @State private var selectedInterval: IntervalType?
    @State private var viewState: ViewState = .setup
    @State private var numberOfQuestions: Int = 10
    @State private var selectedDifficulty: IntervalDifficulty = .beginner
    @State private var selectedQuestionTypes: Set<IntervalQuestionType> = [.buildInterval]
    @State private var selectedDirection: IntervalDirection = .ascending
    @State private var selectedKeyDifficulty: KeyDifficulty = .easy
    @State private var showingFeedback = false
    @State private var hasSubmitted = false
    
    enum ViewState {
        case setup
        case active
        case results
    }
    
    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                IntervalSetupView(
                    numberOfQuestions: $numberOfQuestions,
                    selectedDifficulty: $selectedDifficulty,
                    selectedQuestionTypes: $selectedQuestionTypes,
                    selectedDirection: $selectedDirection,
                    selectedKeyDifficulty: $selectedKeyDifficulty,
                    onStart: startQuiz
                )
            case .active:
                IntervalActiveView(
                    selectedNote: $selectedNote,
                    selectedInterval: $selectedInterval,
                    showingFeedback: $showingFeedback,
                    hasSubmitted: $hasSubmitted,
                    onSubmit: submitAnswer,
                    onNext: nextQuestion
                )
            case .results:
                IntervalResultsView(
                    onPlayAgain: resetQuiz,
                    onBackToSetup: backToSetup
                )
            }
        }
        .navigationTitle("Interval Drill")
        .navigationBarTitleDisplayMode(.inline)
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
                // Play the correct interval to reinforce the sound
                AudioManager.shared.playInterval(question.interval)
            }
        } else {
            IntervalDrillHaptics.error()
            if settings.playChordOnCorrect {
                // Play what the user entered first, then the correct answer
                playIncorrectFeedback(question: question)
            }
        }
        
        showingFeedback = true
    }
    
    /// Play audio feedback for incorrect answers
    /// First plays what the user entered, then plays the correct interval
    private func playIncorrectFeedback(question: IntervalQuestion) {
        switch question.questionType {
        case .buildInterval:
            // User selected a wrong note - play that interval first
            if let userNote = selectedNote {
                let userInterval = Interval(
                    rootNote: question.interval.rootNote,
                    intervalType: IntervalDatabase.shared.interval(forSemitones: abs(userNote.midiNumber - question.interval.rootNote.midiNumber)) ?? question.interval.intervalType,
                    direction: question.interval.direction
                )
                AudioManager.shared.playInterval(userInterval)
                
                // Then play the correct interval after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    AudioManager.shared.playInterval(question.interval)
                }
            }
            
        case .identifyInterval, .auralIdentify:
            // User selected wrong interval type - play that interval from the same root
            if let userIntervalType = selectedInterval {
                let userInterval = Interval(
                    rootNote: question.interval.rootNote,
                    intervalType: userIntervalType,
                    direction: question.interval.direction
                )
                AudioManager.shared.playInterval(userInterval)
                
                // Then play the correct interval after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    AudioManager.shared.playInterval(question.interval)
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
    
    private func resetQuiz() {
        intervalGame.resetQuiz()
        viewState = .setup
    }
    
    private func backToSetup() {
        intervalGame.resetQuiz()
        viewState = .setup
    }
}

// MARK: - Setup View

struct IntervalSetupView: View {
    @EnvironmentObject var intervalGame: IntervalGame
    @Binding var numberOfQuestions: Int
    @Binding var selectedDifficulty: IntervalDifficulty
    @Binding var selectedQuestionTypes: Set<IntervalQuestionType>
    @Binding var selectedDirection: IntervalDirection
    @Binding var selectedKeyDifficulty: KeyDifficulty
    let onStart: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.system(size: 50))
                        .foregroundColor(.green)
                    Text("Interval Drill")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("Master musical intervals")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Settings Cards
                VStack(spacing: 16) {
                    // Difficulty
                    SettingsCard(title: "Difficulty", icon: "speedometer") {
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(IntervalDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue).tag(difficulty)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Number of Questions
                    SettingsCard(title: "Questions", icon: "number") {
                        VStack {
                            Slider(value: Binding(
                                get: { Double(numberOfQuestions) },
                                set: { numberOfQuestions = Int($0) }
                            ), in: 5...20, step: 1)
                            Text("\(numberOfQuestions) questions")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Question Types
                    SettingsCard(title: "Question Types", icon: "questionmark.circle") {
                        VStack(spacing: 8) {
                            ForEach(IntervalQuestionType.allCases, id: \.self) { type in
                                Button(action: {
                                    toggleQuestionType(type)
                                }) {
                                    HStack {
                                        Image(systemName: type.icon)
                                            .frame(width: 24)
                                        Text(type.rawValue)
                                        Spacer()
                                        if selectedQuestionTypes.contains(type) {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.green)
                                        } else {
                                            Image(systemName: "circle")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                    
                    // Direction
                    SettingsCard(title: "Direction", icon: "arrow.up.arrow.down") {
                        Picker("Direction", selection: $selectedDirection) {
                            Text("↑").tag(IntervalDirection.ascending)
                            Text("↓").tag(IntervalDirection.descending)
                            Text("↑↓").tag(IntervalDirection.both)
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    // Key Difficulty
                    SettingsCard(title: "Keys", icon: "key") {
                        Picker("Key Difficulty", selection: $selectedKeyDifficulty) {
                            ForEach(KeyDifficulty.allCases, id: \.self) { keyDiff in
                                Text(keyDiff.rawValue).tag(keyDiff)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }
                .padding(.horizontal)
                
                // Start Button
                Button(action: onStart) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Quiz")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedQuestionTypes.isEmpty ? Color.gray : Color.green)
                    .cornerRadius(12)
                }
                .disabled(selectedQuestionTypes.isEmpty)
                .padding(.horizontal)
                
                // Scoreboard Preview
                if !intervalGame.scoreboard.isEmpty {
                    IntervalScoreboardPreview()
                        .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
    }
    
    private func toggleQuestionType(_ type: IntervalQuestionType) {
        if selectedQuestionTypes.contains(type) {
            if selectedQuestionTypes.count > 1 {
                selectedQuestionTypes.remove(type)
            }
        } else {
            selectedQuestionTypes.insert(type)
        }
    }
}

// MARK: - Settings Card

fileprivate struct SettingsCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.green)
                Text(title)
                    .font(.headline)
            }
            content
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Active View

struct IntervalActiveView: View {
    @EnvironmentObject var intervalGame: IntervalGame
    @EnvironmentObject var settings: SettingsManager
    @Binding var selectedNote: Note?
    @Binding var selectedInterval: IntervalType?
    @Binding var showingFeedback: Bool
    @Binding var hasSubmitted: Bool
    let onSubmit: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // Progress Bar
            ProgressView(value: Double(intervalGame.questionNumber), total: Double(intervalGame.totalQuestions))
                .tint(.green)
                .padding(.horizontal)
            
            // Timer and Progress
            HStack {
                Text("Question \(intervalGame.questionNumber)/\(intervalGame.totalQuestions)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(formatTime(intervalGame.elapsedTime))
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            if let question = intervalGame.currentQuestion {
                // Question Text
                Text(question.questionText)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Visual Display
                IntervalDisplayView(
                    question: question,
                    showTarget: hasSubmitted,
                    showAnswer: hasSubmitted
                )
                .padding(.horizontal)
                
                Spacer()
                
                // Answer Input
                if question.questionType == .buildInterval {
                    // Piano Keyboard for build questions
                    buildIntervalInput(question: question)
                } else {
                    // Interval Picker for identify questions
                    identifyIntervalInput(question: question)
                }
                
                // Feedback
                if showingFeedback {
                    feedbackView(question: question)
                }
                
                // Action Buttons
                actionButtons(question: question)
            }
        }
        .padding(.vertical)
        .onChange(of: intervalGame.questionNumber) { _, _ in
            // Auto-play interval for ear training questions
            if let question = intervalGame.currentQuestion,
               question.questionType == .auralIdentify {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    playInterval(question.interval)
                }
            }
        }
        .onAppear {
            // Play on initial appear if ear training question
            if let question = intervalGame.currentQuestion,
               question.questionType == .auralIdentify {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playInterval(question.interval)
                }
            }
        }
    }
    
    @ViewBuilder
    private func buildIntervalInput(question: IntervalQuestion) -> some View {
        VStack(spacing: 8) {
            Text("Select the target note")
                .font(.caption)
                .foregroundColor(.secondary)
            
            PianoKeyboard(
                selectedNotes: Binding(
                    get: { selectedNote.map { Set([$0]) } ?? [] },
                    set: { notes in
                        selectedNote = notes.first
                        IntervalDrillHaptics.light()
                    }
                ),
                allowMultipleSelection: false
            )
            .frame(height: 160)
            .disabled(hasSubmitted)
            .padding(.horizontal)
            
            // Show feedback after submission
            if hasSubmitted {
                HStack {
                    if intervalGame.lastAnswerCorrect {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Correct! The note is \(question.correctNote.name)")
                            .foregroundColor(.green)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.red)
                        Text("The correct note is \(question.correctNote.name)")
                            .foregroundColor(.red)
                    }
                }
                .font(.subheadline)
            }
        }
    }
    
    @ViewBuilder
    private func identifyIntervalInput(question: IntervalQuestion) -> some View {
        VStack(spacing: 8) {
            Text("Select the interval")
                .font(.caption)
                .foregroundColor(.secondary)
            
            IntervalPicker(
                difficulty: intervalGame.selectedDifficulty,
                selectedInterval: $selectedInterval,
                correctInterval: hasSubmitted ? question.interval.intervalType : nil,
                disabled: hasSubmitted
            )
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func feedbackView(question: IntervalQuestion) -> some View {
        HStack {
            Image(systemName: intervalGame.lastAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(intervalGame.lastAnswerCorrect ? .green : .red)
            
            if intervalGame.lastAnswerCorrect {
                Text("Correct!")
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            } else {
                VStack(alignment: .leading) {
                    Text("Incorrect")
                        .fontWeight(.semibold)
                        .foregroundColor(.red)
                    Text("The answer is \(question.interval.intervalType.name) (\(question.correctNote.name))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Play interval button
            Button(action: { playInterval(question.interval) }) {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func actionButtons(question: IntervalQuestion) -> some View {
        HStack(spacing: 16) {
            if !hasSubmitted {
                // Clear button
                Button(action: {
                    selectedNote = nil
                    selectedInterval = nil
                }) {
                    Text("Clear")
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Submit button
                Button(action: onSubmit) {
                    Text("Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSubmit(question) ? Color.green : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSubmit(question))
            } else {
                // Next button
                Button(action: onNext) {
                    HStack {
                        Text(intervalGame.questionNumber >= intervalGame.totalQuestions ? "Finish" : "Next")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    private func canSubmit(_ question: IntervalQuestion) -> Bool {
        switch question.questionType {
        case .buildInterval:
            return selectedNote != nil
        case .identifyInterval, .auralIdentify:
            return selectedInterval != nil
        }
    }
    
    private func playInterval(_ interval: Interval) {
        AudioManager.shared.playInterval(interval)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Interval Display View

struct IntervalDisplayView: View {
    let question: IntervalQuestion
    let showTarget: Bool
    let showAnswer: Bool  // Whether to show the interval name (answer)
    
    init(question: IntervalQuestion, showTarget: Bool, showAnswer: Bool = true) {
        self.question = question
        self.showTarget = showTarget
        self.showAnswer = showAnswer
    }
    
    private var isEarTraining: Bool {
        question.questionType == .auralIdentify
    }
    
    private var isIdentifyQuestion: Bool {
        question.questionType == .identifyInterval
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // For ear training, show a speaker icon instead of notes
            if isEarTraining && !showAnswer {
                VStack(spacing: 16) {
                    Image(systemName: "ear.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Listen to the interval")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            } else {
                HStack(spacing: 24) {
                    // Root note
                    NoteDisplay(
                        note: question.interval.rootNote,
                        label: "Root",
                        color: .blue
                    )
                    
                    // Arrow showing musical direction (up = ascending, down = descending)
                    Image(systemName: question.interval.direction == .descending ? "arrow.down" : "arrow.up")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    // Target note - for identify questions, show the note but not the interval name
                    if showTarget || isIdentifyQuestion {
                        NoteDisplay(
                            note: question.interval.targetNote,
                            label: showAnswer ? question.interval.intervalType.shortName : "?",
                            color: .green
                        )
                    } else {
                        NoteDisplay(
                            note: nil,
                            label: "?",
                            color: .gray
                        )
                    }
                }
                
                // Semitones hint - only show after answer is revealed
                if showAnswer && showTarget {
                    Text("\(question.interval.intervalType.semitones) semitones")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

struct NoteDisplay: View {
    let note: Note?
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                Text(note?.name ?? "?")
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Interval Picker

struct IntervalPicker: View {
    let difficulty: IntervalDifficulty
    @Binding var selectedInterval: IntervalType?
    let correctInterval: IntervalType?
    let disabled: Bool
    
    private var intervals: [IntervalType] {
        IntervalDatabase.shared.intervals(for: difficulty)
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 70), spacing: 8)
        ], spacing: 8) {
            ForEach(intervals) { interval in
                Button(action: {
                    if !disabled {
                        selectedInterval = interval
                        IntervalDrillHaptics.light()
                    }
                }) {
                    VStack(spacing: 2) {
                        Text(interval.shortName)
                            .font(.headline)
                        Text(interval.name)
                            .font(.system(size: 9))
                            .lineLimit(1)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    .background(backgroundColor(for: interval))
                    .foregroundColor(foregroundColor(for: interval))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor(for: interval), lineWidth: 2)
                    )
                }
                .disabled(disabled)
            }
        }
    }
    
    private func backgroundColor(for interval: IntervalType) -> Color {
        if let correct = correctInterval {
            if interval == correct {
                return .green.opacity(0.3)
            } else if interval == selectedInterval && interval != correct {
                return .red.opacity(0.3)
            }
        }
        
        if interval == selectedInterval {
            return .green.opacity(0.2)
        }
        return Color(.systemGray6)
    }
    
    private func foregroundColor(for interval: IntervalType) -> Color {
        if let correct = correctInterval {
            if interval == correct {
                return .green
            } else if interval == selectedInterval && interval != correct {
                return .red
            }
        }
        
        if interval == selectedInterval {
            return .green
        }
        return .primary
    }
    
    private func borderColor(for interval: IntervalType) -> Color {
        if let correct = correctInterval {
            if interval == correct {
                return .green
            } else if interval == selectedInterval && interval != correct {
                return .red
            }
        }
        
        if interval == selectedInterval {
            return .green
        }
        return .clear
    }
}

// MARK: - Results View

struct IntervalResultsView: View {
    @EnvironmentObject var intervalGame: IntervalGame
    let onPlayAgain: () -> Void
    let onBackToSetup: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    private var accuracy: Double {
        guard intervalGame.totalQuestions > 0 else { return 0 }
        return Double(intervalGame.correctAnswers) / Double(intervalGame.totalQuestions) * 100
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Rank Up Celebration
                if let newRank = intervalGame.newRank {
                    RankUpView(newRank: newRank)
                }
                
                // Score Circle
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                        .frame(width: 150, height: 150)
                    
                    Circle()
                        .trim(from: 0, to: accuracy / 100)
                        .stroke(scoreColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                        .frame(width: 150, height: 150)
                        .rotationEffect(.degrees(-90))
                    
                    VStack {
                        Text("\(Int(accuracy))%")
                            .font(.system(size: 36, weight: .bold))
                        Text("\(intervalGame.correctAnswers)/\(intervalGame.totalQuestions)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.top)
                
                // XP Change
                HStack {
                    Text("XP:")
                        .foregroundColor(.secondary)
                    Text(intervalGame.lastRatingChange >= 0 ? "+\(intervalGame.lastRatingChange)" : "\(intervalGame.lastRatingChange)")
                        .font(.headline)
                        .foregroundColor(intervalGame.lastRatingChange >= 0 ? .green : .red)
                }
                
                // Stats Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    IntervalStatCard(title: "Time", value: formatTime(intervalGame.elapsedTime), icon: "clock")
                    IntervalStatCard(title: "Difficulty", value: intervalGame.selectedDifficulty.rawValue, icon: "speedometer")
                    IntervalStatCard(title: "Avg/Question", value: formatTime(intervalGame.elapsedTime / Double(intervalGame.totalQuestions)), icon: "timer")
                    IntervalStatCard(title: "Direction", value: intervalGame.selectedDirection.rawValue, icon: "arrow.up.arrow.down")
                }
                .padding(.horizontal)
                
                // Encouragement
                Text(encouragementText)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: onPlayAgain) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Play Again")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(12)
                    }
                    
                    Button(action: onBackToSetup) {
                        HStack {
                            Image(systemName: "slider.horizontal.3")
                            Text("Change Settings")
                        }
                        .font(.headline)
                        .foregroundColor(.green)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    NavigationLink(destination: IntervalScoreboardView().environmentObject(intervalGame)) {
                        HStack {
                            Image(systemName: "trophy")
                            Text("View Scoreboard")
                        }
                        .font(.headline)
                        .foregroundColor(.yellow)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    Button(action: { dismiss() }) {
                        HStack {
                            Image(systemName: "house")
                            Text("Back to Home")
                        }
                        .font(.headline)
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                    }
                }
                .padding(.horizontal)
                
                Spacer(minLength: 20)
            }
        }
    }
    
    private var scoreColor: Color {
        if accuracy >= 90 { return .green }
        if accuracy >= 70 { return .yellow }
        if accuracy >= 50 { return .orange }
        return .red
    }
    
    private var encouragementText: String {
        if accuracy >= 90 { return "🎉 Outstanding! You're an interval master!" }
        if accuracy >= 80 { return "🌟 Great job! Keep up the excellent work!" }
        if accuracy >= 70 { return "👍 Good effort! Practice makes perfect!" }
        if accuracy >= 50 { return "💪 Keep practicing! You're improving!" }
        return "📚 Don't give up! Try an easier difficulty."
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

fileprivate struct IntervalStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.green)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

fileprivate struct RankUpView: View {
    let newRank: Rank
    
    var body: some View {
        VStack(spacing: 12) {
            Text("🎊 Rank Up! 🎊")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(newRank.emoji)
                .font(.system(size: 60))
            
            Text(newRank.title)
                .font(.title3)
                .fontWeight(.semibold)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.yellow.opacity(0.3), .orange.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

// MARK: - Scoreboard Preview

struct IntervalScoreboardPreview: View {
    @EnvironmentObject var intervalGame: IntervalGame
    
    var body: some View {
        NavigationLink(destination: IntervalScoreboardView().environmentObject(intervalGame)) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: "trophy")
                        .foregroundColor(.yellow)
                    Text("Best Scores")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
                
                ForEach(intervalGame.scoreboard.prefix(3).indices, id: \.self) { index in
                    let result = intervalGame.scoreboard[index]
                    HStack {
                        Text(medalEmoji(for: index))
                        Text("\(Int(result.accuracy))%")
                            .fontWeight(.semibold)
                        Spacer()
                        Text(formatTime(result.totalTime))
                            .foregroundColor(.secondary)
                    }
                    .font(.subheadline)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    private func medalEmoji(for index: Int) -> String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "  "
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Audio Manager Extension

extension AudioManager {
    /// Play an interval (two notes in sequence)
    func playInterval(_ interval: Interval, style: IntervalPlayStyle = .melodic) {
        guard isEnabled else { return }
        
        let rootMidi = interval.rootNote.midiNumber
        // Calculate the actual target MIDI based on direction
        // Don't use targetNote.midiNumber as it may be normalized to base octave
        let semitoneOffset = interval.direction == .descending ? -interval.intervalType.semitones : interval.intervalType.semitones
        let targetMidi = rootMidi + semitoneOffset
        
        switch style {
        case .melodic:
            // Play notes sequentially
            playNote(UInt8(clamping: rootMidi), velocity: 80)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.playNote(UInt8(clamping: targetMidi), velocity: 80)
            }
        case .harmonic:
            // Play notes simultaneously - use calculated MIDI values
            playNote(UInt8(clamping: rootMidi), velocity: 80)
            playNote(UInt8(clamping: targetMidi), velocity: 80)
            // Stop after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.stopNote(UInt8(clamping: rootMidi))
                self.stopNote(UInt8(clamping: targetMidi))
            }
        }
    }
    
    enum IntervalPlayStyle {
        case melodic   // Notes played one after another
        case harmonic  // Notes played together
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

// MARK: - Interval Scoreboard View

struct IntervalScoreboardView: View {
    @EnvironmentObject var intervalGame: IntervalGame
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            if intervalGame.scoreboard.isEmpty {
                emptyState
            } else {
                scoreboardList
            }
        }
        .navigationTitle("Interval Scoreboard")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "trophy")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            Text("No scores yet")
                .font(.title2)
                .foregroundColor(.secondary)
            Text("Complete an interval quiz to see your scores here!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var scoreboardList: some View {
        List {
            ForEach(Array(intervalGame.scoreboard.enumerated()), id: \.element.id) { index, result in
                ScoreboardRow(index: index, result: result)
            }
        }
        .listStyle(.plain)
    }
}

fileprivate struct ScoreboardRow: View {
    let index: Int
    let result: IntervalQuizResult
    
    private var medalEmoji: String {
        switch index {
        case 0: return "🥇"
        case 1: return "🥈"
        case 2: return "🥉"
        default: return "\(index + 1)"
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: result.date)
    }
    
    private var formattedTime: String {
        let minutes = Int(result.totalTime) / 60
        let seconds = Int(result.totalTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Rank/Medal
            Text(medalEmoji)
                .font(index < 3 ? .title2 : .body)
                .frame(width: 36)
            
            // Score info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("\(Int(result.accuracy))%")
                        .font(.headline)
                        .foregroundColor(accuracyColor)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("\(result.correctAnswers)/\(result.totalQuestions)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Image(systemName: "clock")
                        .font(.caption)
                    Text(formattedTime)
                        .font(.caption)
                    
                    Text("•")
                        .font(.caption)
                    
                    Text(result.difficulty.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Date
            Text(formattedDate)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var accuracyColor: Color {
        if result.accuracy >= 90 { return .green }
        if result.accuracy >= 70 { return .yellow }
        if result.accuracy >= 50 { return .orange }
        return .red
    }
}
