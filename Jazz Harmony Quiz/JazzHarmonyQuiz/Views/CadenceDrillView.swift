import SwiftUI

struct CadenceDrillView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @State private var viewState: ViewState = .setup
    @State private var numberOfQuestions: Int = 10
    @State private var selectedCadenceType: CadenceType = .major

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
                    onStartQuiz: startQuiz
                )
            case .active:
                ActiveCadenceQuizView(viewState: $viewState)
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
                        Text("Question \(cadenceGame.currentQuestionNumber) of \(cadenceGame.totalQuestions)")
                            .font(.headline)
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
        // Generate questions FIRST, before changing view state
        cadenceGame.startNewQuiz(
            numberOfQuestions: numberOfQuestions,
            cadenceType: selectedCadenceType
        )
        // Only switch to active view AFTER questions are ready
        viewState = .active
    }

    private func quitQuiz() {
        viewState = .setup
        cadenceGame.resetQuizState()
    }
}

// MARK: - Cadence Setup View
struct CadenceSetupView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSettings = false
    @Binding var numberOfQuestions: Int
    @Binding var selectedCadenceType: CadenceType
    let onStartQuiz: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Cadence Mode Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                VStack(alignment: .leading, spacing: 20) {
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

                    // Cadence Type
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Cadence Type")
                            .font(.headline)

                        Picker("Cadence Type", selection: $selectedCadenceType) {
                            ForEach(CadenceType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())

                        Text(selectedCadenceType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 5)
                    }

                    // Instructions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Instructions")
                            .font(.headline)

                        Text("You will be shown a ii-V-I cadence with all three chords displayed. Spell each chord by selecting the correct notes on the keyboard, then move to the next chord. When all three chords are spelled, submit your answer.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

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
    }
}

// MARK: - Active Cadence Quiz View
struct ActiveCadenceQuizView: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var viewState: CadenceDrillView.ViewState
    @State private var currentChordIndex = 0 // Which chord we're currently spelling (0, 1, or 2)
    @State private var chordSpellings: [[Note]] = [[], [], []] // Spellings for all 3 chords
    @State private var selectedNotes: Set<Note> = []
    @State private var showingFeedback = false
    @State private var isCorrect = false
    @State private var correctAnswerForFeedback: [[Note]] = []

    var body: some View {
        VStack(spacing: 20) {
            if let question = cadenceGame.currentQuestion {
                // Safety check - ensure we have all 3 chords
                if question.cadence.chords.count >= 3 && question.correctAnswers.count >= 3 {
                    // Cadence Display
                    VStack(spacing: 15) {
                        Text("Key: \(question.cadence.key.name) \(question.cadence.cadenceType.rawValue)")
                            .font(settings.chordDisplayFont(size: 24, weight: .bold))
                            .foregroundColor(settings.primaryText(for: colorScheme))
                            .padding()
                            .background(settings.chordDisplayBackground(for: colorScheme))
                            .cornerRadius(8)

                        // Display all 3 chords
                        HStack(spacing: 20) {
                            ForEach(0..<3, id: \.self) { index in
                                chordDisplayCard(
                                    chord: question.cadence.chords[index],
                                    index: index,
                                    isActive: index == currentChordIndex,
                                    isCompleted: !chordSpellings[index].isEmpty && index < currentChordIndex
                                )
                            }
                        }
                        .padding(.horizontal)

                        Text("Spell Chord \(currentChordIndex + 1): \(question.cadence.chords[currentChordIndex].displayName)")
                            .font(.headline)
                            .foregroundColor(settings.primaryAccent(for: colorScheme))
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

                    // Next Chord / Submit Button
                    if currentChordIndex < 2 {
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
                        .disabled(selectedNotes.isEmpty)
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
    }

    private func moveToNextChord() {
        // Save current chord spelling
        chordSpellings[currentChordIndex] = Array(selectedNotes)

        // Move to next chord
        currentChordIndex += 1
        selectedNotes.removeAll()
    }

    private func submitAnswer() {
        guard let question = cadenceGame.currentQuestion else { return }

        // Save the last chord spelling
        chordSpellings[currentChordIndex] = Array(selectedNotes)

        // Store correct answer for feedback
        correctAnswerForFeedback = question.correctAnswers

        // Check if answer is correct
        isCorrect = cadenceGame.isAnswerCorrect(userAnswer: chordSpellings, question: question)

        // Show feedback
        showingFeedback = true
    }

    private func continueToNextQuestion() {
        guard let question = cadenceGame.currentQuestion else { return }

        // Submit the answer
        cadenceGame.submitAnswer(chordSpellings)

        // Reset state for next question
        currentChordIndex = 0
        chordSpellings = [[], [], []]
        selectedNotes.removeAll()
    }

    private func formatFeedback() -> String {
        guard let question = cadenceGame.currentQuestion else { return "" }
        
        // Safety check - ensure correctAnswerForFeedback has been populated
        guard correctAnswerForFeedback.count >= 3 else { return "" }

        var feedback = ""

        for i in 0..<3 {
            // Safety check for chord access
            guard i < question.cadence.chords.count,
                  i < chordSpellings.count,
                  i < correctAnswerForFeedback.count else { continue }
            
            let chordName = question.cadence.chords[i].displayName
            let userNotes = chordSpellings[i].map { $0.name }.joined(separator: ", ")
            let correctNotes = correctAnswerForFeedback[i].map { $0.name }.joined(separator: ", ")

            feedback += "Chord \(i + 1) (\(chordName)):\n"
            feedback += "Your answer: \(userNotes)\n"

            if !isCorrect {
                feedback += "Correct: \(correctNotes)\n"
            }

            if i < 2 {
                feedback += "\n"
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

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                if let result = cadenceGame.currentResult {
                    // Header
                    Text("Quiz Complete!")
                        .font(.largeTitle)
                        .fontWeight(.bold)

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

                        // Cadence Type
                        Text("Cadence Type: \(result.cadenceType.rawValue)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                    // Action Buttons
                    VStack(spacing: 15) {
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
