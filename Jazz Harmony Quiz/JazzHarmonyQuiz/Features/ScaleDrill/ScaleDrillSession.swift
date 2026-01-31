import SwiftUI
import UIKit

// MARK: - Haptic Feedback Helper

fileprivate enum ScaleDrillHaptics {
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

// MARK: - Scale Drill Session View

/// Active quiz session view for scale drills
/// Handles visual scale questions and ear training questions
struct ScaleDrillSession: View {
    @EnvironmentObject var scaleGame: ScaleGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var viewState: DrillState
    @StateObject private var viewModel = ScaleDrillViewModel()
    
    var body: some View {
        VStack(spacing: 16) {
            if let question = scaleGame.currentQuestion {
                // Different display for ear training vs visual
                if question.questionType == .earTraining {
                    earTrainingDisplay(question: question)
                } else {
                    visualScaleDisplay(question: question)
                }
                
                // Selected Notes Display or Feedback (for visual questions)
                if question.questionType != .earTraining {
                    if viewModel.showingFeedback {
                        feedbackNotesView(question: question)
                    } else if !viewModel.selectedNotes.isEmpty {
                        selectedNotesDisplay(question: question)
                    } else {
                        Text("Tap keys to select notes")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(height: 44)
                    }
                }
                
                Spacer()
                
                // Max notes warning (visual questions only)
                if question.questionType != .earTraining && viewModel.showMaxNotesWarning {
                    maxNotesWarningView(question: question)
                }
                
                // Piano Keyboard (visual questions only)
                if question.questionType != .earTraining {
                    PianoKeyboard(selectedNotes: limitedSelectedNotes(maxNotes: question.correctNotes.count))
                        .frame(height: 180)
                        .padding(.horizontal, 8)
                        .disabled(viewModel.hasSubmitted)
                }
                
                // Action Buttons
                actionButtonsView(question: question)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.showingFeedback)
        .onChange(of: scaleGame.currentQuestionIndex) { _, _ in
            // Auto-play scale for ear training questions (only if quiz is still active)
            if scaleGame.isQuizActive,
               let question = scaleGame.currentQuestion,
               question.questionType == .earTraining {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    viewModel.playCurrentScale(question: question)
                }
            }
        }
        .onAppear {
            // Play on initial appear if ear training question
            if let question = scaleGame.currentQuestion,
               question.questionType == .earTraining {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    viewModel.playCurrentScale(question: question)
                }
            }
        }
    }
    
    // MARK: - Ear Training Display
    
    @ViewBuilder
    private func earTrainingDisplay(question: ScaleQuestion) -> some View {
        VStack(spacing: 16) {
            // Ear icon and instruction
            VStack(spacing: 12) {
                Image(systemName: "ear.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ShedTheme.Colors.brass)
                
                Text("Listen to the scale")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text("Root: \(question.scale.root.name)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
            
            // Play Scale Button
            Button(action: {
                viewModel.playCurrentScale(question: question)
            }) {
                HStack {
                    Image(systemName: "speaker.wave.2.fill")
                    Text("Play Scale")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.purple, .blue],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Text("Select the scale type you hear")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Answer Choices
            if !scaleGame.currentAnswerChoices.isEmpty {
                VStack(spacing: 8) {
                    ForEach(scaleGame.currentAnswerChoices, id: \.id) { scaleType in
                        earTrainingChoiceButton(scaleType: scaleType, question: question)
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    @ViewBuilder
    private func earTrainingChoiceButton(scaleType: ScaleType, question: ScaleQuestion) -> some View {
        let isSelected = viewModel.selectedScaleType?.id == scaleType.id
        let isCorrectChoice = viewModel.showingFeedback && scaleType.id == question.scale.scaleType.id
        let isWrongChoice = viewModel.showingFeedback && isSelected && scaleType.id != question.scale.scaleType.id
        
        Button(action: {
            if !viewModel.showingFeedback {
                viewModel.selectedScaleType = scaleType
                ScaleDrillHaptics.light()
            }
        }) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(scaleType.name)
                        .font(.headline)
                    if !scaleType.description.isEmpty {
                        Text(scaleType.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                Spacer()
                
                if viewModel.showingFeedback {
                    if isCorrectChoice {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(ShedTheme.Colors.success)
                    } else if isWrongChoice {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(ShedTheme.Colors.danger)
                    }
                } else if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(ShedTheme.Colors.brass)
                }
            }
            .padding()
            .background(
                viewModel.showingFeedback ?
                    (isCorrectChoice ? ShedTheme.Colors.success.opacity(0.2) :
                     isWrongChoice ? ShedTheme.Colors.danger.opacity(0.2) :
                     Color(.systemGray6)) :
                    (isSelected ? ShedTheme.Colors.brass.opacity(0.2) : Color(.systemGray6))
            )
            .cornerRadius(10)
        }
        .disabled(viewModel.showingFeedback)
    }
    
    // MARK: - Visual Scale Display
    
    @ViewBuilder
    private func visualScaleDisplay(question: ScaleQuestion) -> some View {
        // Scale Display
        VStack(spacing: 8) {
            Text(question.scale.displayName)
                .font(settings.chordDisplayFont(size: 48, weight: .bold))
                .foregroundColor(settings.primaryText(for: colorScheme))
            
            if !question.scale.scaleType.description.isEmpty {
                Text(question.scale.scaleType.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(settings.chordDisplayBackground(for: colorScheme))
        .cornerRadius(16)
        .padding(.horizontal)
        
        // Question Text with tone count hint
        VStack(spacing: 4) {
            Text(question.questionText)
                .font(.title3)
                .fontWeight(.medium)
                .multilineTextAlignment(.center)
            
            Text("\(question.correctNotes.count) tones")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    // MARK: - Selected Notes Display
    
    @ViewBuilder
    private func selectedNotesDisplay(question: ScaleQuestion) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(viewModel.selectedNotes).sorted { $0.midiNumber < $1.midiNumber }, id: \.midiNumber) { note in
                    Text(viewModel.displayNoteName(note, for: question.scale))
                        .font(.headline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(ShedTheme.Colors.brass)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
        .frame(height: 44)
    }
    
    // MARK: - Max Notes Warning
    
    @ViewBuilder
    private func maxNotesWarningView(question: ScaleQuestion) -> some View {
        Text("Maximum \(question.correctNotes.count) notes allowed!")
            .font(.caption)
            .foregroundColor(ShedTheme.Colors.warning)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(ShedTheme.Colors.warning.opacity(0.15))
            .cornerRadius(8)
            .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Play Scale
    
    // MARK: - Feedback View
    
    @ViewBuilder
    private func feedbackNotesView(question: ScaleQuestion) -> some View {
        VStack(spacing: 16) {
            // For single degree questions, use simpler display
            if question.questionType == .singleDegree {
                if viewModel.isCorrect {
                    // Simple confirmation for correct answer
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.largeTitle)
                            Text("Correct!")
                                .font(.title2)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(.green)
                        
                        if let userNote = viewModel.userAnswerNotes.first {
                            Text(viewModel.displayNoteName(userNote, for: question.scale))
                                .font(.title)
                                .fontWeight(.bold)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(ShedTheme.Colors.success.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                } else {
                    // User's answer
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title3)
                            Text("Your answer:")
                                .font(.headline)
                        }
                        .foregroundColor(.red)
                        
                        if let userNote = viewModel.userAnswerNotes.first {
                            Text(viewModel.displayNoteName(userNote, for: question.scale))
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(ShedTheme.Colors.danger.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                    
                    Divider()
                    
                    // Correct answer
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                            Text("Correct answer:")
                                .font(.headline)
                        }
                        .foregroundColor(.green)
                        
                        if let correctNote = question.correctNotes.first {
                            Text(viewModel.displayNoteName(correctNote, for: question.scale))
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(ShedTheme.Colors.success.opacity(0.2))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                    }
                }
            } else {
                // Original display for other question types
                HStack {
                    Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title)
                    Text(viewModel.isCorrect ? "Correct!" : (viewModel.feedbackPhase == .showingUserAnswer ? "Your answer:" : "Correct answer:"))
                        .font(.headline)
                }
                .foregroundColor(viewModel.isCorrect ? .green : (viewModel.feedbackPhase == .showingCorrectAnswer ? .green : .red))
                
                // Notes display
                if viewModel.isCorrect || viewModel.feedbackPhase == .showingCorrectAnswer {
                    correctNotesDisplay(question: question)
                } else {
                    userNotesDisplay(question: question)
                }
                
                // Continue button for wrong answers in phase 1 (not for single degree)
                if !viewModel.isCorrect && viewModel.feedbackPhase == .showingUserAnswer && viewModel.showContinueButton && question.questionType != .singleDegree {
                    Button(action: {
                        viewModel.showCorrectAnswer(question: question)
                    }) {
                        Text("See Correct Answer")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(ShedTheme.Colors.brass)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(viewModel.isCorrect ? ShedTheme.Colors.success.opacity(0.1) : ShedTheme.Colors.danger.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func userNotesDisplay(question: ScaleQuestion) -> some View {
        let rootPitchClass = question.scale.root.pitchClass
        let sortedNotes = viewModel.sortNotesForScale(viewModel.userAnswerNotes, rootPitchClass: rootPitchClass)
        let correctPitchClasses = Set(question.correctNotes.map { $0.pitchClass })
        
        // Use FlowLayout for wrapping on smaller screens
        FlowLayout(spacing: 6) {
            ForEach(Array(sortedNotes.enumerated()), id: \.offset) { index, note in
                let isNoteCorrect = correctPitchClasses.contains(note.pitchClass)
                let isHighlighted = viewModel.highlightedNoteIndex == index
                
                // Check if this is an octave duplicate
                let isOctaveNote = note.midiNumber >= 72 && sortedNotes.contains(where: { 
                    $0.pitchClass == note.pitchClass && $0.midiNumber < note.midiNumber 
                })
                
                VStack(spacing: 1) {
                    Text(viewModel.displayNoteName(note, for: question.scale))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if isOctaveNote {
                        Text("8va")
                            .font(.caption2)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, isOctaveNote ? 4 : 6)
                .background(viewModel.noteBackgroundColor(isCorrect: isNoteCorrect, isHighlighted: isHighlighted, isAllCorrect: viewModel.isCorrect))
                .foregroundColor(.white)
                .cornerRadius(6)
                .scaleEffect(isHighlighted ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: viewModel.highlightedNoteIndex)
            }
            
            // Ghosted 8va note at the end
            if sortedNotes.count == question.correctNotes.count {
                let isOctaveHighlighted = viewModel.highlightedNoteIndex == sortedNotes.count
                let rootNote = sortedNotes.first ?? question.scale.root
                
                VStack(spacing: 1) {
                    Text(viewModel.displayNoteName(rootNote, for: question.scale))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("8va")
                        .font(.caption2)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isOctaveHighlighted ? ShedTheme.Colors.brass : Color.gray.opacity(0.3))
                .foregroundColor(isOctaveHighlighted ? .white : .white.opacity(0.5))
                .cornerRadius(6)
                .scaleEffect(isOctaveHighlighted ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: viewModel.highlightedNoteIndex)
            }
        }
        .padding(.horizontal)
        
        // Show missing notes
        if !viewModel.isCorrect && viewModel.feedbackPhase == .showingUserAnswer {
            let userPitchClasses = Set(viewModel.userAnswerNotes.map { $0.pitchClass })
            let missingNotes = question.correctNotes.filter { !userPitchClasses.contains($0.pitchClass) }
            
            if !missingNotes.isEmpty {
                VStack(spacing: 4) {
                    Text("Missing:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(missingNotes.sorted { $0.midiNumber < $1.midiNumber }, id: \.midiNumber) { note in
                                Text(viewModel.displayNoteName(note, for: question.scale))
                                    .font(.subheadline)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(ShedTheme.Colors.warning)
                                    .foregroundColor(.white)
                                    .cornerRadius(6)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func correctNotesDisplay(question: ScaleQuestion) -> some View {
        let rootPitchClass = question.scale.root.pitchClass
        let sortedNotes = viewModel.sortNotesForScale(question.correctNotes, rootPitchClass: rootPitchClass)
        
        // Use FlowLayout for wrapping on smaller screens
        FlowLayout(spacing: 6) {
            // Display the scale notes
            ForEach(Array(sortedNotes.enumerated()), id: \.offset) { index, note in
                let isHighlighted = viewModel.highlightedNoteIndex == index
                
                Text(viewModel.displayNoteName(note, for: question.scale))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isHighlighted ? ShedTheme.Colors.success : ShedTheme.Colors.success.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .scaleEffect(isHighlighted ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: viewModel.highlightedNoteIndex)
            }
            
            // Ghosted 8va note at the end
            let isOctaveHighlighted = viewModel.highlightedNoteIndex == sortedNotes.count
            
            VStack(spacing: 1) {
                Text(viewModel.displayNoteName(sortedNotes.first ?? question.scale.root, for: question.scale))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text("8va")
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(isOctaveHighlighted ? ShedTheme.Colors.success : Color.gray.opacity(0.3))
            .foregroundColor(isOctaveHighlighted ? .white : .white.opacity(0.5))
            .cornerRadius(6)
            .scaleEffect(isOctaveHighlighted ? 1.1 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: viewModel.highlightedNoteIndex)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func actionButtonsView(question: ScaleQuestion) -> some View {
        HStack(spacing: 16) {
            if !viewModel.hasSubmitted {
                // For ear training
                if question.questionType == .earTraining {
                    Button(action: {
                        viewModel.submitAnswer(question: question, gameSubmit: scaleGame.submitAnswer)
                    }) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedScaleType != nil ? ShedTheme.Colors.brass : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedScaleType == nil)
                } else {
                    // Visual questions - Clear and Submit
                    Button(action: {
                        viewModel.selectedNotes.removeAll()
                        ScaleDrillHaptics.light()
                    }) {
                        Text("Clear")
                            .font(.headline)
                            .foregroundColor(ShedTheme.Colors.danger)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ShedTheme.Colors.danger.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    let requiredCount = question.correctNotes.count
                    let hasCorrectCount = viewModel.selectedNotes.count == requiredCount
                    
                    Button(action: {
                        viewModel.submitAnswer(question: question, gameSubmit: scaleGame.submitAnswer)
                        if viewModel.isCorrect {
                            ScaleDrillHaptics.success()
                        } else {
                            ScaleDrillHaptics.error()
                        }
                    }) {
                        VStack(spacing: 2) {
                            Text("Submit")
                                .font(.headline)
                            if !hasCorrectCount && !viewModel.selectedNotes.isEmpty {
                                Text("\(viewModel.selectedNotes.count)/\(requiredCount) notes")
                                    .font(.caption)
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(hasCorrectCount ? ShedTheme.Colors.brass : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!hasCorrectCount)
                }
                
            } else if viewModel.isCorrect || viewModel.feedbackPhase == .showingCorrectAnswer || (question.questionType == .earTraining && viewModel.hasSubmitted) {
                // Play Scale Button
                Button(action: {
                    viewModel.playScaleWithHighlight(notes: question.correctNotes, question: question)
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Play Scale")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(ShedTheme.Colors.brass)
                    .cornerRadius(12)
                }
                
                // Next Button
                Button(action: {
                    viewModel.resetForNextQuestion()
                    scaleGame.moveToNextQuestion()
                }) {
                    Text(scaleGame.currentQuestionIndex < scaleGame.totalQuestions - 1 ? "Next" : "Finish")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(ShedTheme.Colors.brass)
                        .cornerRadius(12)
                }
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
    
    // MARK: - Helper Functions
    
    /// Creates a binding that limits the number of selected notes
    private func limitedSelectedNotes(maxNotes: Int) -> Binding<Set<Note>> {
        Binding(
            get: { viewModel.selectedNotes },
            set: { newValue in
                if newValue.count > maxNotes {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.showMaxNotesWarning = true
                    }
                    ScaleDrillHaptics.error()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            viewModel.showMaxNotesWarning = false
                        }
                    }
                } else {
                    viewModel.showMaxNotesWarning = false
                    viewModel.selectedNotes = newValue
                }
            }
        )
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScaleDrillSession(
            viewState: .constant(.active)
        )
        .environmentObject(ScaleGame())
        .environmentObject(SettingsManager.shared)
    }
}
