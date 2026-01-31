import SwiftUI
import UIKit

// MARK: - Haptic Feedback Helper

fileprivate enum ChordDrillHaptics {
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

// MARK: - Chord Drill Session View

/// Active session view for chord drills
/// Displays questions, handles input, and shows feedback
struct ChordDrillSessionView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var viewState: DrillState
    @StateObject private var viewModel = ChordDrillViewModel()

    var body: some View {
        VStack(spacing: 20) {
            if viewModel.showingFeedback {
                // Feedback View
                feedbackView()
            } else if let question = quizGame.currentQuestion {
                // Question Display
                questionDisplay(for: question)

                // Answer Input Area
                answerInputArea(for: question)

                // Submit Button
                Button(action: submitAnswer) {
                    Text("Submit Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canSubmit(for: question) ? settings.successColor(for: colorScheme) : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!viewModel.canSubmit(for: question))
                .padding(.horizontal)

                // Clear Button
                Button(action: { viewModel.clearSelection() }) {
                    Text("Clear Selection")
                        .font(.subheadline)
                        .foregroundColor(settings.primaryAccent(for: colorScheme))
                }
                
                Spacer()
            }
        }
        .padding()
        .onChange(of: quizGame.currentQuestionIndex) { _, _ in
            // Auto-play chord for aural questions
            if let question = quizGame.currentQuestion,
               question.questionType.isAural {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    playCurrentChord()
                }
            }
        }
        .onAppear {
            // Play on initial appear if aural question
            if let question = quizGame.currentQuestion,
               question.questionType.isAural {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playCurrentChord()
                }
            }
        }
    }
    
    // MARK: - Question Display
    
    @ViewBuilder
    private func questionDisplay(for question: QuizQuestion) -> some View {
        if question.questionType == .auralQuality {
            // Aural Quality Display
            VStack(spacing: 16) {
                Image(systemName: "ear.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ShedTheme.Colors.brass)

                Text("Listen to the chord")
                    .font(.headline)
                    .foregroundColor(.secondary)

                Text("Identify the chord quality")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
        } else if question.questionType == .auralSpelling {
            // Aural Spelling Display - show root so user doesn't need perfect pitch
            VStack(spacing: 16) {
                Image(systemName: "ear.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ShedTheme.Colors.brass)

                Text("Listen and spell the chord")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Show the root note so user can identify quality and spell from there
                Text("Root: \(question.chord.root.name)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(ShedTheme.Colors.brass.opacity(0.2))
                    .cornerRadius(12)

                Text("Identify the quality and select all chord tones")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(16)
            .padding(.horizontal)
        } else {
            // Regular Question Display
            VStack(spacing: 15) {
                Text("Chord: \(question.chord.displayName)")
                    .font(settings.chordDisplayFont(size: 28, weight: .bold))
                    .foregroundColor(settings.primaryText(for: colorScheme))
                    .padding()
                    .background(settings.chordDisplayBackground(for: colorScheme))
                    .cornerRadius(8)

                Text(viewModel.questionPrompt(for: question))
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                if let targetTone = question.targetTone {
                    Text("Find the: \(targetTone.name)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    // MARK: - Answer Input Area
    
    @ViewBuilder
    private func answerInputArea(for question: QuizQuestion) -> some View {
        if question.questionType.isAural {
            // Play Chord Button with style menu
            VStack(spacing: 12) {
                Menu {
                    Button("Block Chord") {
                        playChordWithStyle(.block)
                    }
                    Button("Arpeggio Up") {
                        playChordWithStyle(.arpeggioUp)
                    }
                    Button("Arpeggio Down") {
                        playChordWithStyle(.arpeggioDown)
                    }
                    Button("Guide Tones Only") {
                        playChordWithStyle(.guideTones)
                    }
                } label: {
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                        Text("Play Chord")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                if question.questionType == .auralQuality {
                    Text("Select the chord quality")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    Text("Select the notes you hear")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Chord Type Picker for quality recognition
            if question.questionType == .auralQuality {
                chordTypeAnswerPicker(for: question)
            }
            
            // Piano Keyboard for aural spelling
            if question.questionType == .auralSpelling {
                pianoKeyboardInput(for: question)
            }
        } else {
            // Piano Keyboard for visual questions
            pianoKeyboardInput(for: question)
        }
    }
    
    @ViewBuilder
    private func chordTypeAnswerPicker(for question: QuizQuestion) -> some View {
        VStack(spacing: 8) {
            ForEach(quizGame.currentAnswerChoices, id: \.id) { chordType in
                let isSelected = viewModel.selectedChordType?.id == chordType.id
                let isCorrect = viewModel.showingFeedback && chordType.id == question.chord.chordType.id
                let isWrong = viewModel.showingFeedback && isSelected && chordType.id != question.chord.chordType.id
                
                Button(action: {
                    if !viewModel.showingFeedback {
                        viewModel.selectedChordType = chordType
                        ChordDrillHaptics.light()
                    }
                }) {
                    HStack {
                        Text(chordType.name)
                            .font(.headline)
                        Spacer()
                        Text(chordType.symbol.isEmpty ? "Major" : chordType.symbol)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if viewModel.showingFeedback {
                            if isCorrect {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ShedTheme.Colors.success)
                            } else if isWrong {
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
                            (isCorrect ? ShedTheme.Colors.success.opacity(0.2) :
                             isWrong ? ShedTheme.Colors.danger.opacity(0.2) :
                             Color(.systemGray6)) :
                            (isSelected ? ShedTheme.Colors.brass.opacity(0.2) : Color(.systemGray6))
                    )
                    .cornerRadius(10)
                }
                .disabled(viewModel.showingFeedback)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func pianoKeyboardInput(for question: QuizQuestion) -> some View {
        PianoKeyboard(
            selectedNotes: $viewModel.selectedNotes,
            octaveRange: 4...4,
            showNoteNames: false,
            allowMultipleSelection: question.questionType != .singleTone
        )
        .padding(.horizontal)
        .frame(height: 140)
        
        // Selected Notes Display
        if !viewModel.selectedNotes.isEmpty {
            VStack(spacing: 8) {
                Text("Selected Notes:")
                    .font(.headline)
                    .foregroundColor(settings.secondaryText(for: colorScheme))

                FlowLayout(spacing: 8) {
                    ForEach(Array(viewModel.selectedNotes.sorted(by: { $0.midiNumber < $1.midiNumber })), id: \.midiNumber) { note in
                        Text(note.name)
                            .font(settings.chordDisplayFont(size: viewModel.selectedNotes.count > 5 ? 18 : 22, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, viewModel.selectedNotes.count > 5 ? 12 : 16)
                            .padding(.vertical, viewModel.selectedNotes.count > 5 ? 8 : 10)
                            .background(settings.selectedNoteBackground(for: colorScheme))
                            .cornerRadius(8)
                    }
                }
            }
            .padding()
            .background(settings.backgroundColor(for: colorScheme))
            .cornerRadius(12)
        }
    }

    // MARK: - Feedback View
    
    @ViewBuilder
    private func feedbackView() -> some View {
        VStack(spacing: 24) {
            if let question = viewModel.currentQuestionForFeedback {
                // Chord name header
                Text("Chord: \(question.chord.displayName)")
                    .font(settings.chordDisplayFont(size: 24, weight: .bold))
                    .foregroundColor(settings.primaryText(for: colorScheme))
                    .padding()
                    .background(settings.chordDisplayBackground(for: colorScheme))
                    .cornerRadius(8)
                
                // Ear training feedback shows chord qualities, not individual notes
                if question.questionType == .auralQuality {
                    auralQualityFeedback(for: question)
                } else {
                    // Visual question feedback shows individual notes
                    visualQuestionFeedback(for: question)
                }
            }
            
            Spacer()
        }
    }
    
    @ViewBuilder
    private func auralQualityFeedback(for question: QuizQuestion) -> some View {
        if viewModel.isCorrect {
            // Correct answer
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(ShedTheme.Colors.success)
            
            Text("Correct!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ShedTheme.Colors.success)
            
            Text(question.chord.chordType.name)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .background(ShedTheme.Colors.success)
                .cornerRadius(12)
            
            continueButton()
            
        } else {
            // Incorrect answer
            if viewModel.feedbackPhase == .showingUserAnswer {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ShedTheme.Colors.danger)
                
                Text("Your answer:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let selected = viewModel.selectedChordType {
                    Text(selected.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(ShedTheme.Colors.danger)
                        .cornerRadius(12)
                }
                
                Button(action: { viewModel.showCorrectAnswer(audioEnabled: settings.audioEnabled) }) {
                    Text("See Correct Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(ShedTheme.Colors.brass)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
                
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ShedTheme.Colors.success)
                
                Text("Correct answer:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(question.chord.chordType.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(ShedTheme.Colors.success)
                    .cornerRadius(12)
                
                // Comparison buttons to toggle between chords
                compareChordButtons(for: question)
                
                continueButton()
            }
        }
    }
    
    @ViewBuilder
    private func compareChordButtons(for question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            Text("Compare:")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            HStack(alignment: .top, spacing: 16) {
                VStack(spacing: 4) {
                    Button(action: {
                        viewModel.playUserAnswer(question: question)
                    }) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Your Answer")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(ShedTheme.Colors.danger)
                        .cornerRadius(8)
                    }
                    
                    if let selected = viewModel.selectedChordType {
                        Text(selected.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(spacing: 4) {
                    Button(action: {
                        viewModel.playCorrectAnswerChord()
                    }) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Correct")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(ShedTheme.Colors.success)
                        .cornerRadius(8)
                    }
                    
                    Text(question.chord.chordType.name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    @ViewBuilder
    private func visualQuestionFeedback(for question: QuizQuestion) -> some View {
        if viewModel.isCorrect {
            // Correct answer display
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(ShedTheme.Colors.success)
            
            Text("Correct!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(ShedTheme.Colors.success)
            
            // Show correct notes (all green)
            notesDisplay(notes: viewModel.correctAnswerForFeedback, allCorrect: true)
            
            continueButton()
            
        } else {
            // Incorrect answer - two phases
            if viewModel.feedbackPhase == .showingUserAnswer {
                // Phase 1: Show user's answer
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ShedTheme.Colors.danger)
                
                Text("Your answer:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Show user's notes with correct/incorrect coloring
                userAnswerNotesDisplay()
                
                Button(action: { viewModel.showCorrectAnswer(audioEnabled: settings.audioEnabled) }) {
                    Text("See Correct Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(ShedTheme.Colors.brass)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
                
            } else {
                // Phase 2: Show correct answer
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(ShedTheme.Colors.success)
                
                Text("Correct answer:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Show correct notes (all green)
                notesDisplay(notes: viewModel.correctAnswerForFeedback, allCorrect: true)
                
                continueButton()
            }
        }
    }
    
    @ViewBuilder
    private func userAnswerNotesDisplay() -> some View {
        let sortedUserNotes = viewModel.userAnswerForFeedback.sorted { $0.midiNumber < $1.midiNumber }
        let correctPitchClasses = Set(viewModel.correctAnswerForFeedback.map { pitchClass($0.midiNumber) })
        
        VStack(spacing: 12) {
            FlowLayout(spacing: 8) {
                ForEach(sortedUserNotes, id: \.midiNumber) { note in
                    let isNoteCorrect = correctPitchClasses.contains(pitchClass(note.midiNumber))
                    let label = getChordToneLabelForFeedback(for: note)
                    
                    // Use correct enharmonic spelling for the chord context
                    let displayNote = viewModel.currentQuestionForFeedback?.chord.correctEnharmonic(for: note) ?? note
                    
                    VStack(spacing: 2) {
                        Text(displayNote.name)
                            .font(settings.chordDisplayFont(size: 20, weight: .semibold))
                        Text(label)
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isNoteCorrect ? ShedTheme.Colors.success : ShedTheme.Colors.danger)
                    .cornerRadius(8)
                }
            }
            
            // Show missing notes if any
            let userPitchClasses = Set(viewModel.userAnswerForFeedback.map { pitchClass($0.midiNumber) })
            let missingNotes = viewModel.correctAnswerForFeedback.filter { !userPitchClasses.contains(pitchClass($0.midiNumber)) }
            
            if !missingNotes.isEmpty {
                Text("Missing:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 8)
                
                FlowLayout(spacing: 8) {
                    ForEach(missingNotes.sorted { $0.midiNumber < $1.midiNumber }, id: \.midiNumber) { note in
                        let label = getChordToneLabelForFeedback(for: note)
                        
                        VStack(spacing: 2) {
                            Text(note.name)
                                .font(settings.chordDisplayFont(size: 18, weight: .semibold))
                            Text(label)
                                .font(.caption2)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(ShedTheme.Colors.warning)
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func notesDisplay(notes: [Note], allCorrect: Bool) -> some View {
        // Keep notes in chord tone order (Root, 3rd, 5th, 7th, etc.) - don't sort by pitch
        let sortedNotes = notes
        
        FlowLayout(spacing: 8) {
            ForEach(sortedNotes, id: \.midiNumber) { note in
                let label = getChordToneLabelForFeedback(for: note)
                
                VStack(spacing: 2) {
                    Text(note.name)
                        .font(settings.chordDisplayFont(size: 20, weight: .semibold))
                    Text(label)
                        .font(.caption)
                }
                .foregroundColor(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(ShedTheme.Colors.success)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    @ViewBuilder
    private func continueButton() -> some View {
        Button(action: continueToNextQuestion) {
            Text(viewModel.isLastQuestion ? "See Results" : "Continue")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(ShedTheme.Colors.brass)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Helper Functions
    
    private func pitchClass(_ midiNumber: Int) -> Int {
        return ((midiNumber - 60) % 12 + 12) % 12
    }
    
    private func getChordToneLabelForFeedback(for note: Note) -> String {
        guard let question = viewModel.currentQuestionForFeedback else { return "?" }
        return viewModel.getChordToneLabel(for: note, in: question)
    }

    private func playCurrentChord() {
        guard let question = quizGame.currentQuestion else { return }
        viewModel.playCurrentChord(question: question, style: settings.defaultChordStyle, tempo: settings.chordTempo)
    }
    
    private func playChordWithStyle(_ style: AudioManager.ChordPlaybackStyle) {
        guard let question = quizGame.currentQuestion else { return }
        viewModel.playChordWithStyle(style, question: question, tempo: settings.chordTempo)
    }

    private func submitAnswer() {
        guard let question = quizGame.currentQuestion else { return }

        // Check if this is the last question BEFORE submitting
        viewModel.checkIfLastQuestion(currentIndex: quizGame.currentQuestionIndex, totalQuestions: quizGame.totalQuestions)

        // Haptic feedback
        viewModel.submitAnswer(question: question, audioEnabled: settings.audioEnabled)
        
        if viewModel.isCorrect {
            ChordDrillHaptics.success()
        } else {
            ChordDrillHaptics.error()
        }
    }
    
    private func continueToNextQuestion() {
        // Submit the answer to QuizGame now (after showing feedback)
        if viewModel.currentQuestionForFeedback != nil {
            // Check if this was a chord type answer or a note answer
            if let chordType = viewModel.selectedChordTypeForFeedback {
                quizGame.submitChordTypeAnswer(chordType)
            } else {
                quizGame.submitAnswer(viewModel.userAnswerForFeedback)
            }
        }
        
        // Reset state for next question
        viewModel.resetForNextQuestion()
        
        // The viewState will automatically update to .results when isQuizCompleted changes
        // via the onChange handler in ChordDrillView
    }
}

// MARK: - Preview

#Preview {
    ChordDrillSessionView(
        viewState: .constant(.active)
    )
    .environmentObject(QuizGame())
    .environmentObject(SettingsManager.shared)
}
