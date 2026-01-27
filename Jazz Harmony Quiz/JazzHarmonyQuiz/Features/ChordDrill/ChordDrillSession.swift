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
    @Binding var selectedNotes: Set<Note>
    @Binding var selectedChordType: ChordType?
    @Binding var showingFeedback: Bool
    @Binding var viewState: DrillState
    @State private var isCorrect = false
    @State private var currentQuestionForFeedback: QuizQuestion?
    @State private var correctAnswerForFeedback: [Note] = []
    @State private var isLastQuestion = false
    @State private var feedbackPhase: FeedbackPhase = .showingUserAnswer
    @State private var userAnswerForFeedback: [Note] = []
    @State private var selectedChordTypeForFeedback: ChordType? = nil
    
    enum FeedbackPhase {
        case showingUserAnswer
        case showingCorrectAnswer
    }

    var body: some View {
        VStack(spacing: 20) {
            if showingFeedback {
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
                        .background(canSubmit ? settings.successColor(for: colorScheme) : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSubmit)
                .padding(.horizontal)

                // Clear Button
                Button(action: clearSelection) {
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
                    .foregroundColor(.blue)

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
                    .foregroundColor(.purple)

                Text("Listen and spell the chord")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Show the root note so user can identify quality and spell from there
                Text("Root: \(question.chord.root.name)")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.purple.opacity(0.2))
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
                let isSelected = selectedChordType?.id == chordType.id
                let isCorrect = showingFeedback && chordType.id == question.chord.chordType.id
                let isWrong = showingFeedback && isSelected && chordType.id != question.chord.chordType.id
                
                Button(action: {
                    if !showingFeedback {
                        selectedChordType = chordType
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
                        
                        if showingFeedback {
                            if isCorrect {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                            } else if isWrong {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        } else if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(
                        showingFeedback ?
                            (isCorrect ? Color.green.opacity(0.2) :
                             isWrong ? Color.red.opacity(0.2) :
                             Color(.systemGray6)) :
                            (isSelected ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    )
                    .cornerRadius(10)
                }
                .disabled(showingFeedback)
            }
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func pianoKeyboardInput(for question: QuizQuestion) -> some View {
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
    }

    // MARK: - Feedback View
    
    @ViewBuilder
    private func feedbackView() -> some View {
        VStack(spacing: 24) {
            if let question = currentQuestionForFeedback {
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
        if isCorrect {
            // Correct answer
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Correct!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            Text(question.chord.chordType.name)
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            
            continueButton()
            
        } else {
            // Incorrect answer
            if feedbackPhase == .showingUserAnswer {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                Text("Your answer:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                if let selected = selectedChordType {
                    Text(selected.name)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.red)
                        .cornerRadius(12)
                }
                
                Button(action: showCorrectAnswer) {
                    Text("See Correct Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
                
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                Text("Correct answer:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(question.chord.chordType.name)
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.green)
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
                        if let selected = selectedChordType {
                            let userChord = Chord(root: question.chord.root, chordType: selected)
                            AudioManager.shared.playChord(userChord.chordTones, duration: 1.2)
                        }
                    }) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Your Answer")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.red)
                        .cornerRadius(8)
                    }
                    
                    if let selected = selectedChordType {
                        Text(selected.name)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                VStack(spacing: 4) {
                    Button(action: {
                        AudioManager.shared.playChord(correctAnswerForFeedback, duration: 1.2)
                    }) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Correct")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(Color.green)
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
        if isCorrect {
            // Correct answer display
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.green)
            
            Text("Correct!")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.green)
            
            // Show correct notes (all green)
            notesDisplay(notes: correctAnswerForFeedback, allCorrect: true)
            
            continueButton()
            
        } else {
            // Incorrect answer - two phases
            if feedbackPhase == .showingUserAnswer {
                // Phase 1: Show user's answer
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.red)
                
                Text("Your answer:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Show user's notes with correct/incorrect coloring
                userAnswerNotesDisplay()
                
                Button(action: showCorrectAnswer) {
                    Text("See Correct Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 8)
                
            } else {
                // Phase 2: Show correct answer
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                Text("Correct answer:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                // Show correct notes (all green)
                notesDisplay(notes: correctAnswerForFeedback, allCorrect: true)
                
                continueButton()
            }
        }
    }
    
    @ViewBuilder
    private func userAnswerNotesDisplay() -> some View {
        let sortedUserNotes = userAnswerForFeedback.sorted { $0.midiNumber < $1.midiNumber }
        let correctPitchClasses = Set(correctAnswerForFeedback.map { pitchClass($0.midiNumber) })
        
        VStack(spacing: 12) {
            FlowLayout(spacing: 8) {
                ForEach(sortedUserNotes, id: \.midiNumber) { note in
                    let isNoteCorrect = correctPitchClasses.contains(pitchClass(note.midiNumber))
                    let label = getChordToneLabelForFeedback(for: note)
                    
                    // Use correct enharmonic spelling for the chord context
                    let displayNote = currentQuestionForFeedback?.chord.correctEnharmonic(for: note) ?? note
                    
                    VStack(spacing: 2) {
                        Text(displayNote.name)
                            .font(settings.chordDisplayFont(size: 20, weight: .semibold))
                        Text(label)
                            .font(.caption)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(isNoteCorrect ? Color.green : Color.red)
                    .cornerRadius(8)
                }
            }
            
            // Show missing notes if any
            let userPitchClasses = Set(userAnswerForFeedback.map { pitchClass($0.midiNumber) })
            let missingNotes = correctAnswerForFeedback.filter { !userPitchClasses.contains(pitchClass($0.midiNumber)) }
            
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
                        .background(Color.orange)
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
                .background(Color.green)
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
            Text(isLastQuestion ? "See Results" : "Continue")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding(.horizontal)
        .padding(.top, 8)
    }
    
    // MARK: - Helper Functions
    
    private func showCorrectAnswer() {
        feedbackPhase = .showingCorrectAnswer
        
        // Play the correct chord
        if settings.audioEnabled {
            AudioManager.shared.playChord(correctAnswerForFeedback, duration: 1.0)
        }
    }
    
    private func pitchClass(_ midiNumber: Int) -> Int {
        return ((midiNumber - 60) % 12 + 12) % 12
    }
    
    private func getChordToneLabelForFeedback(for note: Note) -> String {
        guard let question = currentQuestionForFeedback else { return "?" }
        return getChordToneLabel(for: note, in: question)
    }
    
    private func questionPrompt(for question: QuizQuestion) -> String {
        switch question.questionType {
        case .singleTone:
            return "Select the chord tone shown above"
        case .allTones:
            return "Select all the chord tones for this chord"
        case .auralQuality:
            return "Identify the chord quality by ear"
        case .auralSpelling:
            return "Hear the quality, spell from the root"
        }
    }

    private var canSubmit: Bool {
        guard let question = quizGame.currentQuestion else { return false }

        switch question.questionType {
        case .auralQuality:
            return selectedChordType != nil
        case .auralSpelling:
            return !selectedNotes.isEmpty
        case .singleTone, .allTones:
            return !selectedNotes.isEmpty
        }
    }

    private func playCurrentChord() {
        guard let question = quizGame.currentQuestion else { return }
        let audioManager = AudioManager.shared
        let style = settings.defaultChordStyle
        let tempo = settings.chordTempo

        audioManager.playChord(
            question.chord.chordTones,
            style: style,
            tempo: tempo
        )
    }
    
    private func playChordWithStyle(_ style: AudioManager.ChordPlaybackStyle) {
        guard let question = quizGame.currentQuestion else { return }
        let audioManager = AudioManager.shared
        let tempo = settings.chordTempo

        audioManager.playChord(
            question.chord.chordTones,
            style: style,
            tempo: tempo
        )
    }

    private func submitAnswer() {
        guard let question = quizGame.currentQuestion else { return }

        let userAnswer: [Note]
        let correctAnswer = question.correctAnswer

        // Handle answer based on question type
        // NOTE: We do NOT call quizGame.submitAnswer() here - that happens in continueToNextQuestion()
        // after feedback is shown. Otherwise the question index advances twice.
        if question.questionType == .auralQuality {
            // For aural quality recognition, check chord type selection
            if let selectedType = selectedChordType {
                isCorrect = selectedType.id == question.chord.chordType.id
                // Store selected type for later submission
                selectedChordTypeForFeedback = selectedType
            } else {
                isCorrect = false
                selectedChordTypeForFeedback = nil
            }
            userAnswer = question.chord.chordTones  // Use chord tones for display
        } else if question.questionType == .auralSpelling {
            // For aural spelling, check selected notes
            userAnswer = Array(selectedNotes)
            isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
        } else {
            // For visual questions, use selected notes
            userAnswer = Array(selectedNotes)
            isCorrect = isAnswerCorrect(userAnswer: userAnswer, question: question)
        }

        // Store current question, user's answer, and correct answer for feedback
        currentQuestionForFeedback = question
        correctAnswerForFeedback = correctAnswer
        userAnswerForFeedback = userAnswer
        feedbackPhase = .showingUserAnswer

        // Check if this is the last question BEFORE submitting
        isLastQuestion = quizGame.currentQuestionIndex == quizGame.totalQuestions - 1

        // Haptic feedback and audio
        if isCorrect {
            ChordDrillHaptics.success()

            // Play correct chord audio if enabled
            if settings.audioEnabled {
                AudioManager.shared.playChord(correctAnswer, duration: 1.0)
            }
        } else {
            ChordDrillHaptics.error()

            // For aural questions, don't auto-play - let user control playback
            // For visual questions, play user's answer
            if settings.audioEnabled && !question.questionType.isAural {
                if !userAnswer.isEmpty {
                    AudioManager.shared.playChord(userAnswer, duration: 1.0)
                }
            }
        }

        // Show feedback
        showingFeedback = true
    }
    
    private func isAnswerCorrect(userAnswer: [Note], question: QuizQuestion) -> Bool {
        let correctAnswer = question.correctAnswer
        
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
        selectedChordType = nil
    }
    
    private func continueToNextQuestion() {
        // Submit the answer to QuizGame now (after showing feedback)
        if currentQuestionForFeedback != nil {
            // Check if this was a chord type answer or a note answer
            if let chordType = selectedChordTypeForFeedback {
                quizGame.submitChordTypeAnswer(chordType)
            } else {
                quizGame.submitAnswer(userAnswerForFeedback)
            }
        }
        
        // Reset state for next question
        selectedNotes.removeAll()
        selectedChordType = nil
        selectedChordTypeForFeedback = nil
        userAnswerForFeedback = []
        feedbackPhase = .showingUserAnswer
        showingFeedback = false
        
        // The viewState will automatically update to .results when isQuizCompleted changes
        // via the onChange handler in ChordDrillView
    }
    
    private func getChordToneLabel(for note: Note, in question: QuizQuestion) -> String {
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
}

// MARK: - Preview

#Preview {
    ChordDrillSessionView(
        selectedNotes: .constant([]),
        selectedChordType: .constant(nil),
        showingFeedback: .constant(false),
        viewState: .constant(.active)
    )
    .environmentObject(QuizGame())
    .environmentObject(SettingsManager.shared)
}
