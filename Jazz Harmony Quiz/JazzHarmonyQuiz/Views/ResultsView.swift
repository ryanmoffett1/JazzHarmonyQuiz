import SwiftUI

struct ResultsView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showingReview = false
    @State private var selectedQuestionIndex = 0
    var onNewQuiz: (() -> Void)? = nil // Add callback for new quiz

    var body: some View {
        ScrollView {
            VStack(spacing: 20) { // Reduced from 30 to 20
                if let result = quizGame.currentResult {
                        // Header - Made more compact
                        VStack(spacing: 8) { // Reduced from 10 to 8
                            Text("Quiz Complete!")
                                .font(.title) // Reduced from largeTitle
                                .fontWeight(.bold)
                            
                            Text("Great job on completing the chord drill")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        // Score Card - Made more compact
                        VStack(spacing: 15) { // Reduced from 20 to 15
                            Text("\(result.score)%")
                                .font(.system(size: 50, weight: .bold, design: .rounded)) // Reduced from 60 to 50
                                .foregroundColor(scoreColor(result.score))
                            
                            Text("\(result.correctAnswers) out of \(result.totalQuestions) correct")
                                .font(.headline) // Reduced from title2
                                .fontWeight(.medium)
                            
                            HStack(spacing: 30) {
                                VStack {
                                    Text("\(formatTime(result.totalTime))")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text("Total Time")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                VStack {
                                    Text("\(formatTime(result.averageTimePerQuestion))")
                                        .font(.title3)
                                        .fontWeight(.bold)
                                    Text("Avg per Question")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                        .padding(.vertical, 15) // Reduced vertical padding
                        .padding(.horizontal)
                        .background(settings.cardBackground(for: colorScheme))
                        .cornerRadius(16)

                        // Performance Indicators - Made more compact
                        VStack(alignment: .leading, spacing: 10) { // Reduced from 15 to 10
                            Text("Performance")
                                .font(.headline)
                                .foregroundColor(settings.primaryText(for: colorScheme))

                            PerformanceBar(
                                label: "Accuracy",
                                value: result.accuracy,
                                color: settings.primaryAccent(for: colorScheme)
                            )

                            PerformanceBar(
                                label: "Speed",
                                value: speedScore(result.averageTimePerQuestion),
                                color: settings.successColor(for: colorScheme)
                            )

                            PerformanceBar(
                                label: "Overall",
                                value: overallScore(result),
                                color: settings.infoColor(for: colorScheme)
                            )
                        }
                        .padding()
                        .background(settings.cardBackground(for: colorScheme))
                        .cornerRadius(12)
                        
                        // Action Buttons - Reduced spacing and padding
                        VStack(spacing: 10) { // Reduced from 15 to 10
                            Button(action: {
                                print("Review button tapped")
                                showingReview = true
                            }) {
                                HStack {
                                    Image(systemName: "list.bullet")
                                    Text("Review Wrong Answers")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12) // Reduced from default padding
                                .background(settings.warningColor(for: colorScheme))
                                .cornerRadius(12)
                            }

                            Button(action: {
                                // Debug: Check if button is being tapped
                                print("New Quiz button tapped")
                                // Call the callback instead of directly resetting
                                onNewQuiz?()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.clockwise")
                                    Text("New Quiz")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12) // Reduced from default padding
                                .background(settings.primaryAccent(for: colorScheme))
                                .cornerRadius(12)
                            }

                            NavigationLink(destination: ScoreboardView().environmentObject(quizGame).environmentObject(settings)) {
                                HStack {
                                    Image(systemName: "trophy")
                                    Text("View Scoreboard")
                                }
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12) // Reduced from default padding
                                .background(settings.infoColor(for: colorScheme))
                                .cornerRadius(12)
                            }
                        }
                        
                        // Encouragement Message
                        Text(encouragementMessage(result.score))
                            .font(.caption) // Reduced from subheadline
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .padding(.top, 8) // Reduced padding
                    } else {
                        // No result available - redirect to main view
                        VStack(spacing: 30) {
                            Text("No Quiz Results - Results View")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Complete a quiz to see your results here.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                            
                            Button(action: {
                                // Call the callback instead of directly resetting
                                onNewQuiz?()
                            }) {
                                Text("Start New Quiz")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(12)
                            }
                        }
                        .padding()
                    }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .padding(.bottom, 60) // Ensure buttons are visible above safe area
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // Call the callback instead of directly resetting
                    onNewQuiz?()
                }) {
                    Text("New Quiz")
                }
            }
        }
        .fullScreenCover(isPresented: $showingReview) {
            NavigationView {
                ReviewView(selectedQuestionIndex: $selectedQuestionIndex)
                    .environmentObject(quizGame)
                    .environmentObject(settings)
            }
        }
        .onAppear {
            // Debug: Check if the view is properly appearing
            print("ResultsView appeared")
        }
        .onDisappear {
            // Debug: Check if the view is disappearing
            print("ResultsView disappeared")
        }
    }
    
    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 90...100:
            return .green
        case 70..<90:
            return .orange
        default:
            return .red
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    private func speedScore(_ averageTime: TimeInterval) -> Double {
        // Score based on speed (faster = higher score)
        let maxTime: TimeInterval = 30.0 // 30 seconds per question
        return max(0, min(1, (maxTime - averageTime) / maxTime))
    }
    
    private func overallScore(_ result: QuizResult) -> Double {
        let accuracyWeight = 0.7
        let speedWeight = 0.3
        return result.accuracy * accuracyWeight + speedScore(result.averageTimePerQuestion) * speedWeight
    }
    
    private func encouragementMessage(_ score: Int) -> String {
        switch score {
        case 90...100:
            return "Outstanding! You're a jazz harmony master! 🎵"
        case 80..<90:
            return "Excellent work! You're really getting the hang of this! 🎶"
        case 70..<80:
            return "Good job! Keep practicing to improve even more! 🎹"
        case 60..<70:
            return "Not bad! A bit more practice and you'll be great! 🎼"
        default:
            return "Keep practicing! Every jazz musician started somewhere! 🎺"
        }
    }
}

struct PerformanceBar: View {
    let label: String
    let value: Double
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(Int(value * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 8)
                        .cornerRadius(4)
                    
                    Rectangle()
                        .fill(color)
                        .frame(width: geometry.size.width * value, height: 8)
                        .cornerRadius(4)
                }
            }
            .frame(height: 8)
        }
    }
}

struct ReviewView: View {
    @EnvironmentObject var quizGame: QuizGame
    @Binding var selectedQuestionIndex: Int
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack {
                if let result = quizGame.currentResult {
                    let wrongQuestions = result.questions.enumerated().compactMap { index, question in
                        result.isCorrect[question.id.uuidString] == false ? (index, question) : nil
                    }
                    
                    if wrongQuestions.isEmpty {
                        VStack(spacing: 20) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.green)
                            
                            Text("Perfect Score!")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("You got all questions correct! No review needed.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    } else {
                        TabView(selection: $selectedQuestionIndex) {
                            ForEach(0..<wrongQuestions.count, id: \.self) { index in
                                let (originalIndex, question) = wrongQuestions[index]
                                QuestionReviewCard(
                                    question: question,
                                    originalIndex: originalIndex,
                                    userAnswer: result.userAnswers[question.id.uuidString] ?? [],
                                    correctAnswer: question.correctAnswer,
                                    isCorrect: result.isCorrect[question.id.uuidString] ?? false
                                )
                                .tag(index)
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                if let result = quizGame.currentResult,
                   !result.questions.enumerated().compactMap({ index, question in
                       result.isCorrect[question.id.uuidString] == false ? (index, question) : nil
                   }).isEmpty {
                    ToolbarItem(placement: .principal) {
                        Text("Review: \(selectedQuestionIndex + 1) of \(wrongQuestionsCount)")
                            .font(.headline)
                    }
                }
            })
    }
    
    private var wrongQuestionsCount: Int {
        guard let result = quizGame.currentResult else { return 0 }
        return result.questions.enumerated().compactMap { index, question in
            result.isCorrect[question.id.uuidString] == false ? (index, question) : nil
        }.count
    }
}

struct QuestionReviewCard: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    let question: QuizQuestion
    let originalIndex: Int
    let userAnswer: [Note]
    let correctAnswer: [Note]
    let isCorrect: Bool

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Question Header
                VStack(spacing: 10) {
                    Text("Question \(originalIndex + 1)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(settings.primaryText(for: colorScheme))

                    Text("Chord: \(question.chord.displayName)")
                        .font(settings.chordDisplayFont(size: 28, weight: .bold))
                        .foregroundColor(settings.primaryText(for: colorScheme))
                        .padding()
                        .background(settings.chordDisplayBackground(for: colorScheme))
                        .cornerRadius(8)
                    
                    Text(questionPrompt)
                        .font(.headline)
                        .multilineTextAlignment(.center)
                }
                
                // Answer Comparison
                VStack(spacing: 15) {
                    // User's Answer
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Your Answer:")
                                .font(.headline)
                            Spacer()
                            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundColor(isCorrect ? .green : .red)
                        }
                        
                        if userAnswer.isEmpty {
                            Text("No answer provided")
                                .foregroundColor(.secondary)
                                .italic()
                        } else {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                                ForEach(userAnswer.sorted(by: { $0.midiNumber < $1.midiNumber }), id: \.midiNumber) { note in
                                    let displayNote = convertToChordTonality(note)
                                    VStack(spacing: 4) {
                                        Text(displayNote.name)
                                            .font(settings.chordDisplayFont(size: 18, weight: .semibold))
                                            .foregroundColor(.white)
                                            .frame(height: 40)
                                        Text(getChordToneLabel(for: note))
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .background(isUserNoteCorrect(note) ? settings.successColor(for: colorScheme) : settings.errorColor(for: colorScheme))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(settings.cardBackground(for: colorScheme))
                    .cornerRadius(12)

                    // Correct Answer
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Correct Answer:")
                            .font(.headline)
                            .foregroundColor(settings.primaryText(for: colorScheme))
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 10) {
                            ForEach(Array(correctAnswer.sorted(by: { $0.midiNumber < $1.midiNumber }).enumerated()), id: \.element.midiNumber) { index, note in
                                VStack(spacing: 4) {
                                    Text(note.name)
                                        .font(settings.chordDisplayFont(size: 18, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(height: 40)
                                    Text(getChordToneLabel(for: note, isCorrectAnswer: true, index: index))
                                        .font(.caption2)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 8)
                                .background(settings.successColor(for: colorScheme))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(settings.cardBackground(for: colorScheme))
                    .cornerRadius(12)
                }

                // Chord Information
                VStack(alignment: .leading, spacing: 10) {
                    Text("Chord Information:")
                        .font(.headline)
                        .foregroundColor(settings.primaryText(for: colorScheme))
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Full Name: \(question.chord.fullName)")
                        Text("Difficulty: \(question.chord.chordType.difficulty.rawValue)")
                        Text("Chord Tones: \(formatChordTonesWithLabels())")
                    }
                    .font(.subheadline)
                    .foregroundColor(settings.secondaryText(for: colorScheme))
                }
                .padding()
                .background(settings.cardBackground(for: colorScheme))
                .cornerRadius(12)
                
                // Conceptual Explanation (only show if answer was wrong)
                if !isCorrect {
                    ConceptualExplanationView(chord: question.chord)
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private var questionPrompt: String {
        switch question.questionType {
        case .singleTone:
            if let targetTone = question.targetTone {
                return "Find the \(targetTone.name) of the chord"
            }
            return "Select the chord tone"
        case .allTones:
            return "Select all chord tones"
        case .earTraining, .auralQuality:
            return "Identify the chord by ear"
        case .auralSpelling:
            return "Spell the chord you heard"
        }
    }
    
    // Convert note to match the chord's tonality
    private func convertToChordTonality(_ note: Note) -> Note {
        let preferSharps = question.chord.root.isSharp || ["B", "E", "A", "D", "G"].contains(question.chord.root.name)
        return Note.noteFromMidi(note.midiNumber, preferSharps: preferSharps) ?? note
    }
    
    // Helper to determine if a user's note is correct
    private func isUserNoteCorrect(_ note: Note) -> Bool {
        let userPitchClass = ((note.midiNumber - 60) % 12 + 12) % 12
        return correctAnswer.contains { correctNote in
            let correctPitchClass = ((correctNote.midiNumber - 60) % 12 + 12) % 12
            return userPitchClass == correctPitchClass
        }
    }
    
    // Helper to get the chord tone label for a note
    private func getChordToneLabel(for note: Note, isCorrectAnswer: Bool = false, index: Int = 0) -> String {
        // Calculate pitch class relative to root
        let rootPitchClass = ((question.chord.root.midiNumber - 60) % 12 + 12) % 12
        let notePitchClass = ((note.midiNumber - 60) % 12 + 12) % 12
        let interval = (notePitchClass - rootPitchClass + 12) % 12
        
        // Try to match the interval to a chord tone from the chord type
        for chordTone in question.chord.chordType.chordTones {
            if chordTone.semitonesFromRoot == interval {
                return chordTone.name
            }
        }
        
        // Fallback: generic interval labels
        switch interval {
        case 0: return "Root"
        case 1: return "b9"
        case 2: return "9"
        case 3: return "b3/#9"
        case 4: return "3"
        case 5: return "4"
        case 6: return "b5"
        case 7: return "5"
        case 8: return "#5/b13"
        case 9: return "6/13"
        case 10: return "b7"
        case 11: return "7"
        default: return "?"
        }
    }
    
    private func formatChordTonesWithLabels() -> String {
        return question.chord.chordType.chordTones.enumerated().map { index, chordTone in
            if index < question.chord.chordTones.count {
                let note = question.chord.chordTones[index]
                return "\(note.name) (\(chordTone.name))"
            }
            return ""
        }.joined(separator: ", ")
    }
}

// MARK: - Conceptual Explanation View

struct ConceptualExplanationView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    let chord: Chord
    
    var body: some View {
        let concept = ConceptualExplanations.shared.chordExplanation(for: chord.chordType)
        
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
                Text("Understanding \(concept.name)")
                    .font(.headline)
                    .foregroundColor(settings.primaryText(for: colorScheme))
            }
            
            VStack(alignment: .leading, spacing: 12) {
                ExplanationSection(title: "Theory", icon: "book.fill", text: concept.theory, colorScheme: colorScheme)
                ExplanationSection(title: "Sound", icon: "waveform", text: concept.sound, colorScheme: colorScheme)
                ExplanationSection(title: "Usage", icon: "music.note", text: concept.usage, colorScheme: colorScheme)
                ExplanationSection(title: "Voicing Tip", icon: "hand.raised.fill", text: concept.voicingTip, colorScheme: colorScheme)
            }
        }
        .padding()
        .background(
            LinearGradient(
                colors: [
                    Color.blue.opacity(colorScheme == .dark ? 0.2 : 0.1),
                    Color.purple.opacity(colorScheme == .dark ? 0.2 : 0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue.opacity(0.3), lineWidth: 1)
        )
    }
}

struct ExplanationSection: View {
    let title: String
    let icon: String
    let text: String
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(colorScheme == .dark ? .white : .primary)
            }
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .white.opacity(0.9) : .secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Preview
#Preview {
    ResultsView()
        .environmentObject(QuizGame())
}
