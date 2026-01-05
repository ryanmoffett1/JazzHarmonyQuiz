import SwiftUI

struct ChordDrillView: View {
    @EnvironmentObject var quizGame: QuizGame
    @State private var selectedNotes: Set<Note> = []
    @State private var viewState: ViewState = .setup
    @State private var numberOfQuestions: Int
    @State private var selectedDifficulty: ChordType.ChordDifficulty
    @State private var selectedQuestionTypes: Set<QuestionType>
    @State private var showingResults = false
    @State private var showingFeedback = false
    
    enum ViewState {
        case setup
        case active
        case results
    }
    
    init(numberOfQuestions: Int = 10, 
         selectedDifficulty: ChordType.ChordDifficulty = .beginner, 
         selectedQuestionTypes: Set<QuestionType> = [.singleTone, .allTones]) {
        self._numberOfQuestions = State(initialValue: numberOfQuestions)
        self._selectedDifficulty = State(initialValue: selectedDifficulty)
        self._selectedQuestionTypes = State(initialValue: selectedQuestionTypes)
    }
    
    var body: some View {
        let _ = print("🔍 ChordDrillView body evaluating: viewState=\(viewState), isQuizActive=\(quizGame.isQuizActive), isQuizCompleted=\(quizGame.isQuizCompleted)")
        
        return ZStack {
            switch viewState {
            case .setup:
                QuizSetupView(
                    numberOfQuestions: $numberOfQuestions,
                    selectedDifficulty: $selectedDifficulty,
                    selectedQuestionTypes: $selectedQuestionTypes,
                    onStartQuiz: startQuiz
                )
            case .active:
                ActiveQuizView(selectedNotes: $selectedNotes, showingFeedback: $showingFeedback, viewState: $viewState)
            case .results:
                ResultsView(onNewQuiz: {
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
        // Removed .onChange handlers that were causing state confusion
        .onChange(of: quizGame.isQuizCompleted) { isCompleted in
            // When quiz completes, switch to results view
            if isCompleted {
                viewState = .results
            }
        }
    }
    
    private func startQuiz() {
        // Clear all previous state
        selectedNotes = []
        showingFeedback = false
        viewState = .active
        
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

struct QuizSetupView: View {
    @EnvironmentObject var quizGame: QuizGame
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
                
                // Leaderboard Button
                NavigationLink(destination: LeaderboardView().environmentObject(quizGame)) {
                    HStack {
                        Image(systemName: "trophy.fill")
                        Text("View Leaderboard")
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
    @Binding var viewState: ChordDrillView.ViewState
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
                    showNoteNames: false,
                    allowMultipleSelection: question.questionType != .singleTone
                )
                .padding(.horizontal)
                .frame(height: 140)
                
                // Selected Notes Display
                if !selectedNotes.isEmpty {
                    VStack(spacing: 8) {
                        Text("Selected Notes:")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // Use FlowLayout for wrapping with dynamic sizing
                        FlowLayout(spacing: 8) {
                            ForEach(Array(selectedNotes.sorted(by: { $0.midiNumber < $1.midiNumber })), id: \.midiNumber) { note in
                                Text(note.name)
                                    .font(selectedNotes.count > 5 ? .body : .title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, selectedNotes.count > 5 ? 12 : 16)
                                    .padding(.vertical, selectedNotes.count > 5 ? 8 : 10)
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
        
        // Check if this is the last question BEFORE submitting
        isLastQuestion = quizGame.currentQuestionIndex == quizGame.totalQuestions - 1
        
        // Check if answer is correct
        isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
        
        // Show feedback FIRST (especially important for last question)
        showingFeedback = true
        
        // Submit the answer (this will advance to next question or finish quiz)
        // But we'll handle the actual submission in continueToNextQuestion()
    }
    
    private func isAnswerCorrect(userAnswer: [Note], question: QuizQuestion) -> Bool {
        let correctAnswer = question.correctAnswer
        
        // Helper function to normalize MIDI number to pitch class (0-11)
        func pitchClass(_ midiNumber: Int) -> Int {
            return ((midiNumber - 60) % 12 + 12) % 12
        }
        
        // For single tone questions, check if the user selected the correct note
        if question.questionType == .singleTone {
            guard userAnswer.count == 1, correctAnswer.count == 1 else { return false }
            // Compare pitch classes to handle different octaves
            return pitchClass(userAnswer[0].midiNumber) == pitchClass(correctAnswer[0].midiNumber)
        }
        
        // For all tones and chord spelling, check if all correct notes are selected
        // and no incorrect notes are selected (comparing pitch classes)
        let userPitchClasses = Set(userAnswer.map { pitchClass($0.midiNumber) })
        let correctPitchClasses = Set(correctAnswer.map { pitchClass($0.midiNumber) })
        
        return userPitchClasses == correctPitchClasses
    }
    
    private func clearSelection() {
        selectedNotes.removeAll()
    }
    
    private func continueToNextQuestion() {
        // Submit the answer to QuizGame now (after showing feedback)
        if let question = currentQuestionForFeedback {
            let userAnswer = Array(selectedNotes)
            quizGame.submitAnswer(userAnswer)
        }
        
        selectedNotes.removeAll()
        
        // The viewState will automatically update to .results when isQuizCompleted changes
        // via the onChange handler in ChordDrillView
    }
}

// MARK: - FlowLayout Helper
// A custom layout that wraps content to the next line when it doesn't fit
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowLayoutResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowLayoutResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x, y: bounds.minY + result.positions[index].y), proposal: .unspecified)
        }
    }
    
    struct FlowLayoutResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if currentX + size.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }
            
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

// MARK: - Preview
#Preview {
    ChordDrillView()
        .environmentObject(QuizGame())
}
