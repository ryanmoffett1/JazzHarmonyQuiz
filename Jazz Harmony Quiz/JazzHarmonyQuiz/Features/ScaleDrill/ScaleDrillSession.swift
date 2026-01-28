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
    
    @Binding var selectedNotes: Set<Note>
    @Binding var showingFeedback: Bool
    @Binding var viewState: DrillState
    
    @State private var feedbackMessage: String = ""
    @State private var isCorrect: Bool = false
    @State private var hasSubmitted: Bool = false
    @State private var feedbackPhase: FeedbackPhase = .showingUserAnswer
    @State private var userAnswerNotes: [Note] = []
    @State private var highlightedNoteIndex: Int? = nil
    @State private var showContinueButton: Bool = false
    @State private var showMaxNotesWarning: Bool = false
    @State private var selectedScaleType: ScaleType? = nil  // For ear training
    
    private let audioManager = AudioManager.shared
    
    enum FeedbackPhase {
        case showingUserAnswer
        case showingCorrectAnswer
    }
    
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
                    if showingFeedback {
                        feedbackNotesView(question: question)
                    } else if !selectedNotes.isEmpty {
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
                if question.questionType != .earTraining && showMaxNotesWarning {
                    maxNotesWarningView(question: question)
                }
                
                // Piano Keyboard (visual questions only)
                if question.questionType != .earTraining {
                    PianoKeyboard(selectedNotes: limitedSelectedNotes(maxNotes: question.correctNotes.count))
                        .frame(height: 180)
                        .padding(.horizontal, 8)
                        .disabled(hasSubmitted)
                }
                
                // Action Buttons
                actionButtonsView(question: question)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingFeedback)
        .onChange(of: scaleGame.currentQuestionIndex) { _, _ in
            // Auto-play scale for ear training questions (only if quiz is still active)
            if scaleGame.isQuizActive,
               let question = scaleGame.currentQuestion,
               question.questionType == .earTraining {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    playCurrentScale()
                }
            }
        }
        .onAppear {
            // Play on initial appear if ear training question
            if let question = scaleGame.currentQuestion,
               question.questionType == .earTraining {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playCurrentScale()
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
            Button(action: playCurrentScale) {
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
        let isSelected = selectedScaleType?.id == scaleType.id
        let isCorrectChoice = showingFeedback && scaleType.id == question.scale.scaleType.id
        let isWrongChoice = showingFeedback && isSelected && scaleType.id != question.scale.scaleType.id
        
        Button(action: {
            if !showingFeedback {
                selectedScaleType = scaleType
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
                
                if showingFeedback {
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
                showingFeedback ?
                    (isCorrectChoice ? ShedTheme.Colors.success.opacity(0.2) :
                     isWrongChoice ? ShedTheme.Colors.danger.opacity(0.2) :
                     Color(.systemGray6)) :
                    (isSelected ? ShedTheme.Colors.brass.opacity(0.2) : Color(.systemGray6))
            )
            .cornerRadius(10)
        }
        .disabled(showingFeedback)
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
                ForEach(Array(selectedNotes).sorted { $0.midiNumber < $1.midiNumber }, id: \.midiNumber) { note in
                    Text(displayNoteName(note, for: question.scale))
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
    
    private func playCurrentScale() {
        guard let question = scaleGame.currentQuestion else { return }
        audioManager.playScaleObject(question.scale, bpm: 140)
    }
    
    // MARK: - Feedback View
    
    @ViewBuilder
    private func feedbackNotesView(question: ScaleQuestion) -> some View {
        VStack(spacing: 16) {
            // For single degree questions, use simpler display
            if question.questionType == .singleDegree {
                if isCorrect {
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
                        
                        if let userNote = userAnswerNotes.first {
                            Text(displayNoteName(userNote, for: question.scale))
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
                        
                        if let userNote = userAnswerNotes.first {
                            Text(displayNoteName(userNote, for: question.scale))
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
                            Text(displayNoteName(correctNote, for: question.scale))
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
                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.title)
                    Text(isCorrect ? "Correct!" : (feedbackPhase == .showingUserAnswer ? "Your answer:" : "Correct answer:"))
                        .font(.headline)
                }
                .foregroundColor(isCorrect ? .green : (feedbackPhase == .showingCorrectAnswer ? .green : .red))
                
                // Notes display
                if isCorrect || feedbackPhase == .showingCorrectAnswer {
                    correctNotesDisplay(question: question)
                } else {
                    userNotesDisplay(question: question)
                }
                
                // Continue button for wrong answers in phase 1 (not for single degree)
                if !isCorrect && feedbackPhase == .showingUserAnswer && showContinueButton && question.questionType != .singleDegree {
                    Button(action: showCorrectAnswer) {
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
                .fill(isCorrect ? ShedTheme.Colors.success.opacity(0.1) : ShedTheme.Colors.danger.opacity(0.1))
        )
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func userNotesDisplay(question: ScaleQuestion) -> some View {
        let rootPitchClass = question.scale.root.pitchClass
        let sortedNotes = sortNotesForScale(userAnswerNotes, rootPitchClass: rootPitchClass)
        let correctPitchClasses = Set(question.correctNotes.map { $0.pitchClass })
        
        // Use FlowLayout for wrapping on smaller screens
        FlowLayout(spacing: 6) {
            ForEach(Array(sortedNotes.enumerated()), id: \.offset) { index, note in
                let isNoteCorrect = correctPitchClasses.contains(note.pitchClass)
                let isHighlighted = highlightedNoteIndex == index
                
                // Check if this is an octave duplicate
                let isOctaveNote = note.midiNumber >= 72 && sortedNotes.contains(where: { 
                    $0.pitchClass == note.pitchClass && $0.midiNumber < note.midiNumber 
                })
                
                VStack(spacing: 1) {
                    Text(displayNoteName(note, for: question.scale))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    if isOctaveNote {
                        Text("8va")
                            .font(.caption2)
                    }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, isOctaveNote ? 4 : 6)
                .background(noteBackgroundColor(isCorrect: isNoteCorrect, isHighlighted: isHighlighted, isAllCorrect: isCorrect))
                .foregroundColor(.white)
                .cornerRadius(6)
                .scaleEffect(isHighlighted ? 1.1 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: highlightedNoteIndex)
            }
            
            // Ghosted 8va note at the end
            if sortedNotes.count == question.correctNotes.count {
                let isOctaveHighlighted = highlightedNoteIndex == sortedNotes.count
                let rootNote = sortedNotes.first ?? question.scale.root
                
                VStack(spacing: 1) {
                    Text(displayNoteName(rootNote, for: question.scale))
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
                .animation(.easeInOut(duration: 0.1), value: highlightedNoteIndex)
            }
        }
        .padding(.horizontal)
        
        // Show missing notes
        if !isCorrect && feedbackPhase == .showingUserAnswer {
            let userPitchClasses = Set(userAnswerNotes.map { $0.pitchClass })
            let missingNotes = question.correctNotes.filter { !userPitchClasses.contains($0.pitchClass) }
            
            if !missingNotes.isEmpty {
                VStack(spacing: 4) {
                    Text("Missing:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 6) {
                            ForEach(missingNotes.sorted { $0.midiNumber < $1.midiNumber }, id: \.midiNumber) { note in
                                Text(displayNoteName(note, for: question.scale))
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
        let sortedNotes = sortNotesForScale(question.correctNotes, rootPitchClass: rootPitchClass)
        
        // Use FlowLayout for wrapping on smaller screens
        FlowLayout(spacing: 6) {
            // Display the scale notes
            ForEach(Array(sortedNotes.enumerated()), id: \.offset) { index, note in
                let isHighlighted = highlightedNoteIndex == index
                
                Text(displayNoteName(note, for: question.scale))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isHighlighted ? ShedTheme.Colors.success : ShedTheme.Colors.success.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .scaleEffect(isHighlighted ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: highlightedNoteIndex)
            }
            
            // Ghosted 8va note at the end
            let isOctaveHighlighted = highlightedNoteIndex == sortedNotes.count
            
            VStack(spacing: 1) {
                Text(displayNoteName(sortedNotes.first ?? question.scale.root, for: question.scale))
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
            .animation(.easeInOut(duration: 0.1), value: highlightedNoteIndex)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func actionButtonsView(question: ScaleQuestion) -> some View {
        HStack(spacing: 16) {
            if !hasSubmitted {
                // For ear training
                if question.questionType == .earTraining {
                    Button(action: submitAnswer) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedScaleType != nil ? ShedTheme.Colors.brass : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(selectedScaleType == nil)
                } else {
                    // Visual questions - Clear and Submit
                    Button(action: {
                        selectedNotes.removeAll()
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
                    let hasCorrectCount = selectedNotes.count == requiredCount
                    
                    Button(action: submitAnswer) {
                        VStack(spacing: 2) {
                            Text("Submit")
                                .font(.headline)
                            if !hasCorrectCount && !selectedNotes.isEmpty {
                                Text("\(selectedNotes.count)/\(requiredCount) notes")
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
                
            } else if isCorrect || feedbackPhase == .showingCorrectAnswer || (question.questionType == .earTraining && hasSubmitted) {
                // Play Scale Button
                Button(action: {
                    playScaleWithHighlight(notes: question.correctNotes)
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
                Button(action: moveToNext) {
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
            get: { selectedNotes },
            set: { newValue in
                if newValue.count > maxNotes {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMaxNotesWarning = true
                    }
                    ScaleDrillHaptics.error()
                    audioManager.playNote(50, velocity: 60)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        audioManager.stopNote(50)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showMaxNotesWarning = false
                        }
                    }
                } else {
                    showMaxNotesWarning = false
                    selectedNotes = newValue
                }
            }
        )
    }
    
    private func noteBackgroundColor(isCorrect: Bool, isHighlighted: Bool, isAllCorrect: Bool) -> Color {
        if isAllCorrect {
            return isHighlighted ? ShedTheme.Colors.success : ShedTheme.Colors.success.opacity(0.7)
        }
        if isHighlighted {
            return isCorrect ? ShedTheme.Colors.success : ShedTheme.Colors.danger
        }
        return isCorrect ? ShedTheme.Colors.success.opacity(0.7) : ShedTheme.Colors.danger.opacity(0.7)
    }
    
    private func displayNoteName(_ note: Note, for scale: Scale) -> String {
        if let scaleNote = scale.scaleNotes.first(where: { $0.pitchClass == note.pitchClass }) {
            return scaleNote.name
        }
        
        let preferSharps = scale.root.isSharp || ["B", "E", "A", "D", "G"].contains(scale.root.name)
        if let displayNote = Note.noteFromMidi(note.midiNumber, preferSharps: preferSharps) {
            return displayNote.name
        }
        return note.name
    }
    
    /// Sort notes in scale order starting from the root
    private func sortNotesForScale(_ notes: [Note], rootPitchClass: Int) -> [Note] {
        let rootNotes = notes.filter { $0.pitchClass == rootPitchClass }
        let baseRootMidi = rootNotes.map { $0.midiNumber }.min() ?? 60
        
        return notes.sorted { note1, note2 in
            let isNote1OctaveRoot = note1.pitchClass == rootPitchClass && note1.midiNumber > baseRootMidi
            let isNote2OctaveRoot = note2.pitchClass == rootPitchClass && note2.midiNumber > baseRootMidi
            
            if isNote1OctaveRoot && !isNote2OctaveRoot {
                return false
            }
            if isNote2OctaveRoot && !isNote1OctaveRoot {
                return true
            }
            
            if isNote1OctaveRoot && isNote2OctaveRoot {
                return note1.midiNumber < note2.midiNumber
            }
            
            let interval1 = (note1.pitchClass - rootPitchClass + 12) % 12
            let interval2 = (note2.pitchClass - rootPitchClass + 12) % 12
            
            if interval1 == interval2 {
                return note1.midiNumber < note2.midiNumber
            }
            return interval1 < interval2
        }
    }
    
    private func submitAnswer() {
        guard let question = scaleGame.currentQuestion else { return }
        
        if question.questionType == .earTraining {
            submitEarTrainingAnswer()
            return
        }
        
        userAnswerNotes = Array(selectedNotes)
        highlightedNoteIndex = nil
        showContinueButton = false
        
        isCorrect = scaleGame.submitAnswer(selectedNotes)
        hasSubmitted = true
        showingFeedback = true
        
        // For single degree, show both answers immediately without playback
        if question.questionType == .singleDegree {
            feedbackPhase = .showingCorrectAnswer
            if isCorrect {
                feedbackMessage = "Correct! 🎉"
                ScaleDrillHaptics.success()
            } else {
                feedbackMessage = "Incorrect"
                ScaleDrillHaptics.error()
            }
        } else {
            // For all degrees, use the original flow with playback
            feedbackPhase = .showingUserAnswer
            if isCorrect {
                feedbackMessage = "Correct! 🎉"
                ScaleDrillHaptics.success()
                playScaleWithHighlight(notes: question.correctNotes)
            } else {
                feedbackMessage = "Incorrect"
                ScaleDrillHaptics.error()
                playUserAnswerWithHighlight()
            }
        }
    }
    
    private func submitEarTrainingAnswer() {
        guard let question = scaleGame.currentQuestion,
              let selected = selectedScaleType else { return }
        
        let correctScaleType = question.scale.scaleType
        isCorrect = selected.id == correctScaleType.id
        hasSubmitted = true
        showingFeedback = true
        
        if isCorrect {
            feedbackMessage = "Correct! 🎉"
            ScaleDrillHaptics.success()
            scaleGame.recordEarTrainingAnswer(correct: true)
        } else {
            feedbackMessage = "Incorrect - \(correctScaleType.name)"
            ScaleDrillHaptics.error()
            scaleGame.recordEarTrainingAnswer(correct: false)
            
            let concept = ConceptualExplanations.shared.scaleExplanation(for: correctScaleType)
            feedbackMessage += "\n\n" + concept.sound
        }
    }
    
    private func playUserAnswerWithHighlight() {
        guard let question = scaleGame.currentQuestion else { return }
        
        let rootPitchClass = question.scale.root.pitchClass
        let rootMidi = question.scale.root.midiNumber
        let sortedNotes = sortNotesForScale(userAnswerNotes, rootPitchClass: rootPitchClass)
        let beatDuration: TimeInterval = 0.3
        
        var playbackSequence: [(midi: Int, displayIndex: Int)] = []
        
        for (index, note) in sortedNotes.enumerated() {
            let interval = (note.pitchClass - rootPitchClass + 12) % 12
            let midi = rootMidi + interval
            playbackSequence.append((midi: midi, displayIndex: index))
        }
        
        if sortedNotes.count == question.correctNotes.count {
            playbackSequence.append((midi: rootMidi + 12, displayIndex: sortedNotes.count))
            
            for i in stride(from: sortedNotes.count - 1, through: 0, by: -1) {
                let note = sortedNotes[i]
                let interval = (note.pitchClass - rootPitchClass + 12) % 12
                let midi = rootMidi + interval
                playbackSequence.append((midi: midi, displayIndex: i))
            }
        }
        
        let baseTime = DispatchTime.now()
        let totalNotes = playbackSequence.count
        
        for (index, item) in playbackSequence.enumerated() {
            let noteStartTime = baseTime + .milliseconds(Int(Double(index) * beatDuration * 1000))
            let noteStopTime = baseTime + .milliseconds(Int((Double(index) + 0.8) * beatDuration * 1000))
            
            DispatchQueue.main.asyncAfter(deadline: noteStartTime) { [self] in
                self.highlightedNoteIndex = item.displayIndex
            }
            
            if settings.audioEnabled {
                DispatchQueue.main.asyncAfter(deadline: noteStartTime) { [self] in
                    audioManager.playNote(UInt8(item.midi), velocity: 80)
                }
                
                DispatchQueue.main.asyncAfter(deadline: noteStopTime) { [self] in
                    audioManager.stopNote(UInt8(item.midi))
                }
            }
        }
        
        let endTime = baseTime + .milliseconds(Int(Double(totalNotes) * beatDuration * 1000 + 200))
        DispatchQueue.main.asyncAfter(deadline: endTime) { [self] in
            self.highlightedNoteIndex = nil
            self.showContinueButton = true
        }
    }
    
    private func showCorrectAnswer() {
        guard let question = scaleGame.currentQuestion else { return }
        
        feedbackPhase = .showingCorrectAnswer
        highlightedNoteIndex = nil
        
        playScaleWithHighlight(notes: question.correctNotes)
    }
    
    private func playScaleWithHighlight(notes: [Note]) {
        guard let question = scaleGame.currentQuestion else { return }
        
        let rootPitchClass = question.scale.root.pitchClass
        let rootMidi = question.scale.root.midiNumber
        let sortedNotes = sortNotesForScale(notes, rootPitchClass: rootPitchClass)
        let beatDuration: TimeInterval = 0.3
        
        var playbackSequence: [(midi: Int, displayIndex: Int)] = []
        
        for (index, note) in sortedNotes.enumerated() {
            let interval = (note.pitchClass - rootPitchClass + 12) % 12
            let midi = rootMidi + interval
            playbackSequence.append((midi: midi, displayIndex: index))
        }
        
        playbackSequence.append((midi: rootMidi + 12, displayIndex: sortedNotes.count))
        
        for i in stride(from: sortedNotes.count - 1, through: 0, by: -1) {
            let note = sortedNotes[i]
            let interval = (note.pitchClass - rootPitchClass + 12) % 12
            let midi = rootMidi + interval
            playbackSequence.append((midi: midi, displayIndex: i))
        }
        
        let baseTime = DispatchTime.now()
        let totalNotes = playbackSequence.count
        
        for (index, item) in playbackSequence.enumerated() {
            let noteStartTime = baseTime + .milliseconds(Int(Double(index) * beatDuration * 1000))
            let noteStopTime = baseTime + .milliseconds(Int((Double(index) + 0.8) * beatDuration * 1000))
            
            DispatchQueue.main.asyncAfter(deadline: noteStartTime) { [self] in
                self.highlightedNoteIndex = item.displayIndex
            }
            
            if settings.audioEnabled {
                DispatchQueue.main.asyncAfter(deadline: noteStartTime) { [self] in
                    audioManager.playNote(UInt8(item.midi), velocity: 80)
                }
                
                DispatchQueue.main.asyncAfter(deadline: noteStopTime) { [self] in
                    audioManager.stopNote(UInt8(item.midi))
                }
            }
        }
        
        let endTime = baseTime + .milliseconds(Int(Double(totalNotes) * beatDuration * 1000 + 200))
        DispatchQueue.main.asyncAfter(deadline: endTime) { [self] in
            self.highlightedNoteIndex = nil
        }
    }
    
    private func moveToNext() {
        selectedNotes.removeAll()
        selectedScaleType = nil
        userAnswerNotes = []
        showingFeedback = false
        hasSubmitted = false
        feedbackMessage = ""
        feedbackPhase = .showingUserAnswer
        highlightedNoteIndex = nil
        showContinueButton = false
        scaleGame.moveToNextQuestion()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScaleDrillSession(
            selectedNotes: .constant([]),
            showingFeedback: .constant(false),
            viewState: .constant(.active)
        )
        .environmentObject(ScaleGame())
        .environmentObject(SettingsManager.shared)
    }
}
