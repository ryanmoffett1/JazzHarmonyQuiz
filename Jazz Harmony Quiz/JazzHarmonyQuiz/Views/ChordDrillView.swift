import SwiftUI

struct ChordDrillView: View {
    @EnvironmentObject var quizGame: QuizGame
    @State private var selectedNotes: Set<Note> = []
    @State private var showingQuizSetup = true
    @State private var numberOfQuestions: Int
    @State private var selectedDifficulty: ChordType.ChordDifficulty
    @State private var selectedQuestionTypes: Set<QuestionType>
    @State private var showingResults = false
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
            if showingQuizSetup {
                QuizSetupView(
                    numberOfQuestions: $numberOfQuestions,
                    selectedDifficulty: $selectedDifficulty,
                    selectedQuestionTypes: $selectedQuestionTypes,
                    onStartQuiz: startQuiz
                )
            } else if quizGame.isQuizActive {
                ActiveQuizView(selectedNotes: $selectedNotes, showingFeedback: $showingFeedback, showingQuizSetup: $showingQuizSetup)
            } else if quizGame.isQuizCompleted {
                ResultsView()
            } else {
                // Show loading or start quiz immediately
                VStack {
                    Text("Starting Quiz...")
                        .font(.title)
                    ProgressView()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if quizGame.isQuizActive {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Quit") {
                        quitQuiz()
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text("Question \(quizGame.currentQuestionNumber) of \(quizGame.totalQuestions)")
                            .font(.headline)
                        ProgressView(value: quizGame.progress)
                            .frame(width: 200)
                    }
                }
            }
        }
        .onAppear {
            // Reset quiz state when view appears
            quizGame.resetQuizState()
        }
        .onChange(of: quizGame.isQuizCompleted) { isCompleted in
            // When quiz is completed, show results (but only if not showing feedback)
            if isCompleted && !showingFeedback {
                showingQuizSetup = false
            }
        }
        .onChange(of: quizGame.isQuizActive) { isActive in
            // When quiz becomes inactive and not completed, go back to setup
            if !isActive && !quizGame.isQuizCompleted {
                showingQuizSetup = true
            }
        }
        .onChange(of: quizGame.isQuizCompleted) { isCompleted in
            // When quiz is no longer completed, go back to setup
            if !isCompleted {
                showingQuizSetup = true
            }
        }
    }
    
    private func startQuiz() {
        showingQuizSetup = false
        showingFeedback = false  // Reset feedback state
        quizGame.startNewQuiz(
            numberOfQuestions: numberOfQuestions,
            difficulty: selectedDifficulty,
            questionTypes: selectedQuestionTypes
        )
    }
    
    private func quitQuiz() {
        showingQuizSetup = true
        quizGame.isQuizActive = false
        selectedNotes = []
    }
}

struct QuizSetupView: View {
    @Binding var numberOfQuestions: Int
    @Binding var selectedDifficulty: ChordType.ChordDifficulty
    @Binding var selectedQuestionTypes: Set<QuestionType>
    let onStartQuiz: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Chord Drill Setup")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 20) {
                    // Number of Questions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Number of Questions")
                            .font(.headline)
                        
                        Picker("Questions", selection: $numberOfQuestions) {
                            ForEach([1, 5, 10, 15, 20, 25, 30], id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Difficulty Level
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Difficulty Level")
                            .font(.headline)
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(ChordType.ChordDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue).tag(difficulty)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Question Types
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Question Types")
                            .font(.headline)
                        
                        ForEach(QuestionType.allCases, id: \.self) { questionType in
                            HStack {
                                Button(action: {
                                    if selectedQuestionTypes.contains(questionType) {
                                        selectedQuestionTypes.remove(questionType)
                                    } else {
                                        selectedQuestionTypes.insert(questionType)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: selectedQuestionTypes.contains(questionType) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedQuestionTypes.contains(questionType) ? .blue : .gray)
                                        
                                        VStack(alignment: .leading) {
                                            Text(questionType.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(questionType.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Start Button
                Button(action: onStartQuiz) {
                    Text("Start Quiz")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .disabled(selectedQuestionTypes.isEmpty)
                
                Spacer()
            }
            .padding()
        }
    }
}

struct ActiveQuizView: View {
    @EnvironmentObject var quizGame: QuizGame
    @Binding var selectedNotes: Set<Note>
    @Binding var showingFeedback: Bool
    @Binding var showingQuizSetup: Bool
    @State private var isCorrect = false
    @State private var currentQuestionForFeedback: QuizQuestion?
    @State private var correctAnswerForFeedback: [Note] = []
    @State private var isLastQuestion = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let question = quizGame.currentQuestion {
                // Question Display
                VStack(spacing: 15) {
                    Text("Chord: \(question.chord.displayName)")
                        .font(.title)
                        .fontWeight(.bold)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    Text(questionPrompt(for: question))
                        .font(.headline)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    if let targetTone = question.targetTone {
                        Text("Find the: \(targetTone.name)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                // Piano Keyboard
                PianoKeyboard(
                    selectedNotes: $selectedNotes,
                    octaveRange: 4...4,
                    showNoteNames: true,
                    allowMultipleSelection: question.questionType != .singleTone
                )
                .padding()
                
                // Selected Notes Display
                if !selectedNotes.isEmpty {
                    VStack(spacing: 8) {
                        Text("Selected Notes:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 8) {
                            ForEach(Array(selectedNotes), id: \.midiNumber) { note in
                                Text(note.name)
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .frame(width: 40, height: 40)
                                    .background(Color.blue)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Submit Button
                Button(action: submitAnswer) {
                    Text("Submit Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedNotes.isEmpty ? Color.gray : Color.green)
                        .cornerRadius(12)
                }
                .disabled(selectedNotes.isEmpty)
                .padding(.horizontal)
                
                // Clear Button
                Button(action: clearSelection) {
                    Text("Clear Selection")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                
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
                Text("Correct! 🎉")
            } else {
                let correctNoteNames = correctAnswerForFeedback.map { $0.name }.joined(separator: ", ")
                Text("Incorrect. The correct answer was: \(correctNoteNames)")
            }
        }
    }
    
    private func questionPrompt(for question: QuizQuestion) -> String {
        switch question.questionType {
        case .singleTone:
            return "Select the chord tone shown above"
        case .allTones:
            return "Select all the chord tones for this chord"
        case .chordSpelling:
            return "Spell the entire chord by selecting all chord tones"
        }
    }
    
    private func submitAnswer() {
        guard let question = quizGame.currentQuestion else { return }
        
        let userAnswer = Array(selectedNotes)
        let correctAnswer = question.correctAnswer
        
        // Store current question and correct answer for feedback
        currentQuestionForFeedback = question
        correctAnswerForFeedback = correctAnswer
        
        // Check if this is the last question
        isLastQuestion = quizGame.currentQuestionIndex == quizGame.totalQuestions - 1
        
        // Check if answer is correct
        isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
        
        // Submit the answer
        quizGame.submitAnswer(userAnswer)
        
        // Show feedback
        showingFeedback = true
    }
    
    private func isAnswerCorrect(userAnswer: [Note], question: QuizQuestion) -> Bool {
        let correctAnswer = question.correctAnswer
        
        // For single tone questions, check if the user selected the correct note
        if question.questionType == .singleTone {
            guard userAnswer.count == 1, correctAnswer.count == 1 else { return false }
            // Compare MIDI numbers to handle enharmonic equivalents
            return userAnswer[0].midiNumber == correctAnswer[0].midiNumber
        }
        
        // For all tones and chord spelling, check if all correct notes are selected
        // and no incorrect notes are selected
        let userNotes = Set(userAnswer.map { $0.midiNumber })
        let correctNotes = Set(correctAnswer.map { $0.midiNumber })
        
        return userNotes == correctNotes
    }
    
    private func clearSelection() {
        selectedNotes.removeAll()
    }
    
    private func continueToNextQuestion() {
        selectedNotes.removeAll()
        
        if isLastQuestion {
            // This was the last question, show results
            showingQuizSetup = false
        } else if quizGame.isQuizActive {
            // Quiz continues
        } else {
            // Quiz completed, results will be shown
            showingQuizSetup = false
        }
    }
}

// MARK: - Preview
#Preview {
    ChordDrillView()
        .environmentObject(QuizGame())
}
