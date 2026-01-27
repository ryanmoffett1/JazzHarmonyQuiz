import SwiftUI

// MARK: - Interval Drill Session View

struct IntervalDrillSession: View {
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
                
                // Replay button for ear training
                if question.questionType == .auralIdentify {
                    Button(action: { playInterval(question.interval) }) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Replay Interval")
                        }
                        .font(.subheadline)
                        .foregroundColor(ShedTheme.Colors.brass)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(ShedTheme.Colors.brass.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Answer Input
                if question.questionType == .buildInterval {
                    buildIntervalInput(question: question)
                } else {
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
            if let question = intervalGame.currentQuestion,
               question.questionType == .auralIdentify {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    playInterval(question.interval)
                }
            }
        }
        .onAppear {
            if let question = intervalGame.currentQuestion,
               question.questionType == .auralIdentify {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playInterval(question.interval)
                }
            }
        }
    }
    
    // MARK: - Build Interval Input
    
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
                            .foregroundColor(ShedTheme.Colors.success)
                        Text("Correct! The note is \(question.correctNote.name)")
                            .foregroundColor(ShedTheme.Colors.success)
                    } else {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ShedTheme.Colors.danger)
                        Text("The correct note is \(question.correctNote.name)")
                            .foregroundColor(ShedTheme.Colors.danger)
                    }
                }
                .font(.subheadline)
            }
        }
    }
    
    // MARK: - Identify Interval Input
    
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
    
    // MARK: - Feedback View
    
    @ViewBuilder
    private func feedbackView(question: IntervalQuestion) -> some View {
        HStack {
            Image(systemName: intervalGame.lastAnswerCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(intervalGame.lastAnswerCorrect ? .green : .red)
            
            if intervalGame.lastAnswerCorrect {
                Text("Correct!")
                    .fontWeight(.semibold)
                    .foregroundColor(ShedTheme.Colors.success)
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Incorrect")
                        .fontWeight(.semibold)
                        .foregroundColor(ShedTheme.Colors.danger)
                    Text("The answer is \(question.interval.intervalType.name) (\(question.correctNote.name))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Add conceptual explanation for wrong answers
                    let concept = ConceptualExplanations.shared.intervalExplanation(for: question.interval.intervalType)
                    Text(concept.sound)
                        .font(.caption)
                        .foregroundColor(ShedTheme.Colors.brass)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // Play interval button
            Button(action: { playInterval(question.interval) }) {
                Image(systemName: "speaker.wave.2.fill")
                    .foregroundColor(ShedTheme.Colors.brass)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Action Buttons
    
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
                        .foregroundColor(ShedTheme.Colors.danger)
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
                        .background(canSubmit(question) ? ShedTheme.Colors.success : Color.gray)
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
                    .background(ShedTheme.Colors.success)
                    .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    // MARK: - Helper Methods
    
    private func canSubmit(_ question: IntervalQuestion) -> Bool {
        switch question.questionType {
        case .buildInterval:
            return selectedNote != nil
        case .identifyInterval, .auralIdentify:
            return selectedInterval != nil
        }
    }
    
    private func playInterval(_ interval: Interval) {
        AudioManager.shared.playInterval(
            rootNote: interval.rootNote,
            targetNote: interval.targetNote,
            style: settings.defaultIntervalStyle,
            tempo: settings.intervalTempo
        )
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
    let showAnswer: Bool
    
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
            if isEarTraining && !showAnswer {
                VStack(spacing: 16) {
                    Image(systemName: "ear.fill")
                        .font(.system(size: 50))
                        .foregroundColor(ShedTheme.Colors.brass)
                    
                    Text("Listen to the interval")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("Use the replay button below if needed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 20)
            } else {
                HStack(spacing: 24) {
                    // Root note
                    IntervalNoteDisplay(
                        note: question.interval.rootNote,
                        label: "Root",
                        color: .blue
                    )
                    
                    // Arrow showing musical direction
                    Image(systemName: question.interval.direction == .descending ? "arrow.down" : "arrow.up")
                        .font(.title)
                        .foregroundColor(.secondary)
                    
                    // Target note
                    if showTarget || isIdentifyQuestion {
                        IntervalNoteDisplay(
                            note: question.interval.targetNote,
                            label: showAnswer ? question.interval.intervalType.shortName : "?",
                            color: .green
                        )
                    } else {
                        IntervalNoteDisplay(
                            note: nil,
                            label: "?",
                            color: .gray
                        )
                    }
                }
                
                // Semitones hint
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

// MARK: - Note Display

struct IntervalNoteDisplay: View {
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

// MARK: - Preview

#Preview {
    IntervalDrillSession(
        selectedNote: .constant(nil),
        selectedInterval: .constant(nil),
        showingFeedback: .constant(false),
        hasSubmitted: .constant(false),
        onSubmit: {},
        onNext: {}
    )
    .environmentObject(IntervalGame())
    .environmentObject(SettingsManager.shared)
}
