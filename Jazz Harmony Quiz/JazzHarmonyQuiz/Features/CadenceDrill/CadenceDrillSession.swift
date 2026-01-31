import SwiftUI

// MARK: - Cadence Drill Session View

/// Active session view for the standard cadence drill modes
/// Handles spelling chords, ear training, guide tones, etc.
struct CadenceDrillSession: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var viewModel = CadenceDrillViewModel()
    @Binding var viewState: DrillState
    @Binding var userSelectedCadenceType: CadenceType?  // For ear training answers

    /// Number of chords to spell based on drill mode
    private var chordsToSpellCount: Int {
        guard let question = cadenceGame.currentQuestion else { return 3 }
        return question.chordsToSpell.count
    }
    
    /// Whether we're in common tones mode
    private var isCommonTonesMode: Bool {
        cadenceGame.selectedDrillMode == .commonTones
    }

    /// Whether we're in ear training mode
    private var isEarTrainingMode: Bool {
        cadenceGame.selectedDrillMode == .auralIdentify
    }
    
    /// Whether we're in guide tones mode
    private var isGuideTonesMode: Bool {
        cadenceGame.selectedDrillMode == .guideTones
    }
    
    /// Whether we're in resolution targets mode
    private var isResolutionTargetsMode: Bool {
        cadenceGame.selectedDrillMode == .resolutionTargets
    }

    /// Whether we can submit ear training answer
    private var canSubmitEarTraining: Bool {
        if viewModel.showingFeedback {
            return true
        }
        return userSelectedCadenceType != nil
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            if let question = cadenceGame.currentQuestion {
                // Safety check - ensure we have the expected chords
                let chordsToSpell = question.chordsToSpell
                if !chordsToSpell.isEmpty {
                    // Conditional UI based on mode
                    if isEarTrainingMode {
                        earTrainingContentView
                    } else {
                        visualDisplayContentView(question: question, chordsToSpell: chordsToSpell)
                    }
                }

                // Piano Keyboard (only for non-ear training modes)
                if !isEarTrainingMode {
                    PianoKeyboard(
                        selectedNotes: $viewModel.selectedNotes,
                        octaveRange: 4...4,
                        showNoteNames: false,
                        allowMultipleSelection: true
                    )
                    .padding(.horizontal)
                    .frame(height: 140)
                }

                // Selected Notes Display (only for non-ear training modes)
                if !isEarTrainingMode && !viewModel.selectedNotes.isEmpty {
                    selectedNotesDisplay
                }

                // Action Buttons
                actionButtons(chordsToSpell: question.chordsToSpell)

                Spacer()
            }
        }
        .padding()
        .alert("Answer Feedback", isPresented: $viewModel.showingFeedback) {
            Button("Continue") {
                continueToNextQuestion()
            }
        } message: {
            if viewModel.isCorrect {
                Text("Correct! 🎉\n\n\(formatFeedback())")
            } else {
                Text("Incorrect.\n\n\(formatFeedback())")
            }
        }
        .onChange(of: cadenceGame.currentQuestionIndex) { _, _ in
            // Auto-play handled by viewModel
            
            // Auto-play for ear training questions
            if isEarTrainingMode && settings.autoPlayCadences && !viewModel.showingFeedback {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    playCurrentCadence()
                }
            }
        }
        .onAppear {
            
            // Play on initial appear if ear training question
            if isEarTrainingMode && settings.autoPlayCadences {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playCurrentCadence()
                }
            }
        }
    }
    
    // MARK: - Ear Training Content View
    
    @ViewBuilder
    private var earTrainingContentView: some View {
        // Ear Training Display
        VStack(spacing: 16) {
            Image(systemName: "ear.fill")
                .font(.system(size: 50))
                .foregroundColor(ShedTheme.Colors.brass)
            
            Text("Listen to the progression")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Use the replay button below if needed")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
        .padding(.horizontal)
        
        // Replay button
        Button(action: { playCurrentCadence() }) {
            HStack {
                Image(systemName: "speaker.wave.2.fill")
                Text("Replay Progression")
            }
            .font(.subheadline)
            .foregroundColor(ShedTheme.Colors.brass)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(ShedTheme.Colors.brass.opacity(0.1))
            .cornerRadius(8)
        }
        .padding(.horizontal)
        
        Spacer()
        
        // Cadence Type Picker
        VStack(spacing: 8) {
            Text("Select the cadence type")
                .font(.caption)
                .foregroundColor(.secondary)
            
            let availableTypes: [CadenceType] = cadenceGame.useMixedCadences && !cadenceGame.selectedCadenceTypes.isEmpty
                ? Array(cadenceGame.selectedCadenceTypes).sorted(by: { $0.rawValue < $1.rawValue })
                : CadenceType.allCases
            
            CadenceTypePicker(
                selectedCadenceType: $userSelectedCadenceType,
                correctCadenceType: viewModel.showingFeedback ? viewModel.feedbackCorrectCadenceType : nil,
                disabled: viewModel.showingFeedback,
                availableTypes: availableTypes
            )
            .padding(.horizontal)
        }
    }
    
    // MARK: - Visual Display Content View

    @ViewBuilder
    private func visualDisplayContentView(question: CadenceQuestion, chordsToSpell: [Chord]) -> some View {
        // Visual Display for Other Modes
        VStack(spacing: 15) {
            HStack {
                Text("Key: \(question.cadence.key.name) \(question.cadence.cadenceType.rawValue)")
                    .font(settings.chordDisplayFont(size: 24, weight: .bold))
                    .foregroundColor(settings.primaryText(for: colorScheme))
            }
            .padding()
            .background(settings.chordDisplayBackground(for: colorScheme))
            .cornerRadius(8)

            // Display chords based on mode
            chordDisplaySection(chordsToSpell: chordsToSpell)
            
            // Question text
            questionTextView(chordsToSpell: chordsToSpell)
            
            // Hint display
            if let hint = viewModel.currentHintText {
                Text(hint)
                    .font(.subheadline)
                    .foregroundColor(ShedTheme.Colors.warning)
                    .padding(8)
                    .background(ShedTheme.Colors.warning.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Hint button (not for modes where it would give away the answer)
            if cadenceGame.canRequestHint && !isCommonTonesMode && !isResolutionTargetsMode {
                Button(action: requestHint) {
                    HStack {
                        Image(systemName: "lightbulb")
                        Text("Hint (\(3 - cadenceGame.currentHintLevel) left)")
                    }
                    .font(.caption)
                    .foregroundColor(ShedTheme.Colors.warning)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(ShedTheme.Colors.warning.opacity(0.1))
                    .cornerRadius(8)
                }
            }
        }
    }
    
    @ViewBuilder
    private func questionTextView(chordsToSpell: [Chord]) -> some View {
        if isCommonTonesMode {
            Text("Select the note(s) that appear in both chords")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))
        } else if isGuideTonesMode {
            Text("Spell: \(chordsToSpell[min(viewModel.currentChordIndex, chordsToSpell.count - 1)].displayName) (3rd & 7th only)")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))
        } else if isResolutionTargetsMode {
            Text("Select the resolution target")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))
        } else {
            Text("Spell: \(chordsToSpell[min(viewModel.currentChordIndex, chordsToSpell.count - 1)].displayName)")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))
        }
    }
    
    // MARK: - Chord Display Section
    
    @ViewBuilder
    private func chordDisplaySection(chordsToSpell: [Chord]) -> some View {
        if isCommonTonesMode {
            commonTonesModeDisplay(chordsToSpell: chordsToSpell)
        } else if isGuideTonesMode {
            guideTonesModeDisplay(chordsToSpell: chordsToSpell)
        } else if isResolutionTargetsMode {
            resolutionTargetsModeDisplay(chordsToSpell: chordsToSpell)
        } else {
            // Display all chords for full progression
            HStack(spacing: 20) {
                ForEach(0..<chordsToSpell.count, id: \.self) { index in
                    chordDisplayCard(
                        chord: chordsToSpell[index],
                        index: index,
                        isActive: index == viewModel.currentChordIndex,
                        isCompleted: !viewModel.chordSpellings[index].isEmpty && index < viewModel.currentChordIndex
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    @ViewBuilder
    private func commonTonesModeDisplay(chordsToSpell: [Chord]) -> some View {
        VStack(spacing: 10) {
            Text("Find Common Tones Between:")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 30) {
                ForEach(0..<min(2, chordsToSpell.count), id: \.self) { index in
                    VStack {
                        Text(chordsToSpell[index].displayName)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(chordsToSpell[index].chordTones.map { $0.name }.joined(separator: " "))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(ShedTheme.Colors.brass.opacity(0.1))
                    .cornerRadius(12)
                }
            }
            
            Text("→")
                .font(.title)
                .foregroundColor(.gray)
        }
    }
    
    @ViewBuilder
    private func guideTonesModeDisplay(chordsToSpell: [Chord]) -> some View {
        VStack(spacing: 10) {
            Text("Play ONLY the guide tones (3rd and 7th)")
                .font(.subheadline)
                .foregroundColor(ShedTheme.Colors.warning)
                .padding(8)
                .background(ShedTheme.Colors.warning.opacity(0.1))
                .cornerRadius(8)
            
            HStack(spacing: 20) {
                ForEach(0..<chordsToSpell.count, id: \.self) { index in
                    VStack(spacing: 6) {
                        Text(chordsToSpell[index].displayName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(index == viewModel.currentChordIndex ? .blue : .secondary)
                        
                        Text("3rd & 7th")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(index == viewModel.currentChordIndex ? ShedTheme.Colors.brass.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(index == viewModel.currentChordIndex ? ShedTheme.Colors.brass : Color.clear, lineWidth: 2)
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private func resolutionTargetsModeDisplay(chordsToSpell: [Chord]) -> some View {
        if let question = cadenceGame.currentQuestion,
           let pairs = question.resolutionPairs,
           let currentIndex = question.currentResolutionIndex,
           currentIndex < pairs.count {
            let pair = pairs[currentIndex]
            let sourceChord = question.cadence.chords[pair.sourceChordIndex]
            let targetChord = question.cadence.chords[pair.targetChordIndex]
            
            VStack(spacing: 15) {
                VStack(spacing: 10) {
                    Text("The \(pair.sourceRole.rawValue) of \(sourceChord.displayName) is \(pair.sourceNote.name)")
                        .font(.headline)
                        .foregroundColor(ShedTheme.Colors.brass)
                        .padding(12)
                        .background(ShedTheme.Colors.brass.opacity(0.1))
                        .cornerRadius(8)
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text(sourceChord.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(pair.sourceNote.name)
                                .font(.title)
                                .foregroundColor(ShedTheme.Colors.brass)
                        }
                        .padding()
                        .background(ShedTheme.Colors.brass.opacity(0.1))
                        .cornerRadius(12)
                        
                        Image(systemName: "arrow.right")
                            .font(.title)
                            .foregroundColor(ShedTheme.Colors.warning)
                        
                        VStack {
                            Text(targetChord.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("?")
                                .font(.title)
                                .foregroundColor(ShedTheme.Colors.warning)
                        }
                        .padding()
                        .background(ShedTheme.Colors.warning.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    if viewModel.showingFeedback, let targetNote = pair.targetNote {
                        Text("Answer: \(targetNote.name)")
                            .font(.headline)
                            .foregroundColor(ShedTheme.Colors.success)
                    }
                }
            }
        }
    }
    
    // MARK: - Chord Display Card
    
    private func chordDisplayCard(chord: Chord, index: Int, isActive: Bool, isCompleted: Bool) -> some View {
        let cadenceType = cadenceGame.currentQuestion?.cadence.cadenceType ?? .major
        return VStack(spacing: 4) {
            // Roman numeral
            Text(romanNumeralForBuildMode(for: index, cadenceType: cadenceType))
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Chord name
            Text(chord.displayName)
                .font(.headline)
                .foregroundColor(isActive ? .white : settings.primaryText(for: colorScheme))

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(ShedTheme.Colors.success)
            } else if isActive {
                Image(systemName: "circle.fill")
                    .foregroundColor(ShedTheme.Colors.brass)
                    .font(.caption)
            } else {
                Image(systemName: "circle")
                    .foregroundColor(.gray)
                    .font(.caption)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(isActive ? ShedTheme.Colors.brass : Color(.systemGray6))
        .cornerRadius(8)
    }

    private func romanNumeralForBuildMode(for index: Int, cadenceType: CadenceType) -> String {
        switch cadenceType {
        case .major:
            switch index {
            case 0: return "ii"
            case 1: return "V"
            case 2: return "I"
            default: return ""
            }
        case .minor:
            switch index {
            case 0: return "ii°"
            case 1: return "V"
            case 2: return "i"
            default: return ""
            }
        case .tritoneSubstitution:
            switch index {
            case 0: return "ii"
            case 1: return "SubV"
            case 2: return "I"
            default: return ""
            }
        case .backdoor:
            switch index {
            case 0: return "iv"
            case 1: return "bVII"
            case 2: return "I"
            default: return ""
            }
        case .birdChanges:
            switch index {
            case 0: return "iii"
            case 1: return "VI"
            case 2: return "ii"
            case 3: return "V"
            case 4: return "I"
            default: return ""
            }
        }
    }
    
    // MARK: - Selected Notes Display
    
    @ViewBuilder
    private var selectedNotesDisplay: some View {
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
    
    // MARK: - Action Buttons
    
    @ViewBuilder
    private func actionButtons(chordsToSpell: [Chord]) -> some View {
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

            // Next Chord / Submit Button (logic depends on mode)
            if isEarTrainingMode {
                // Ear training mode - submit cadence type selection
                Button(action: submitAnswer) {
                    Text(viewModel.showingFeedback ? "Next Question →" : "Submit Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSubmitEarTraining ? settings.successColor(for: colorScheme) : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSubmitEarTraining && !viewModel.showingFeedback)
            } else if isCommonTonesMode {
                // Common tones mode - single submit
                Button(action: submitAnswer) {
                    Text("Submit Common Tones")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedNotes.isEmpty ? Color.gray : settings.successColor(for: colorScheme))
                        .cornerRadius(12)
                }
                .disabled(viewModel.selectedNotes.isEmpty)
            } else if isResolutionTargetsMode {
                // Resolution targets mode - single note submit
                Button(action: submitAnswer) {
                    Text("Submit Resolution Target")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedNotes.isEmpty ? Color.gray : settings.successColor(for: colorScheme))
                        .cornerRadius(12)
                }
                .disabled(viewModel.selectedNotes.isEmpty)
            } else if isGuideTonesMode {
                // Guide tones mode - multi-chord submit
                if viewModel.currentChordIndex < chordsToSpellCount - 1 {
                    Button(action: moveToNextChord) {
                        Text("Next Chord →")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedNotes.isEmpty ? Color.gray : ShedTheme.Colors.brass)
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedNotes.isEmpty)
                } else {
                    Button(action: submitAnswer) {
                        Text("Submit Answer")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(viewModel.selectedNotes.isEmpty ? Color.gray : settings.successColor(for: colorScheme))
                            .cornerRadius(12)
                    }
                    .disabled(viewModel.selectedNotes.isEmpty)
                }
            } else if viewModel.currentChordIndex < chordsToSpellCount - 1 {
                Button(action: moveToNextChord) {
                    Text("Next Chord →")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedNotes.isEmpty ? Color.gray : ShedTheme.Colors.brass)
                        .cornerRadius(12)
                }
                .disabled(viewModel.selectedNotes.isEmpty)
            } else {
                Button(action: submitAnswer) {
                    Text("Submit Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.selectedNotes.isEmpty ? Color.gray : settings.successColor(for: colorScheme))
                        .cornerRadius(12)
                }
                .disabled(viewModel.selectedNotes.isEmpty)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Actions

    private func clearSelection() {
        viewModel.clearSelection()
    }

    private func moveToNextChord() {
        viewModel.moveToNextChord()
    }
    
    private func requestHint() {
        viewModel.requestHint { index in
            cadenceGame.requestHint(for: index)
        }
    }

    private func submitAnswer() {
        guard let question = cadenceGame.currentQuestion else { return }

        // Handle ear training mode
        if isEarTrainingMode && viewModel.showingFeedback {
            continueToNextQuestion()
            return
        }

        viewModel.submitAnswer(
            question: question,
            drillMode: cadenceGame.selectedDrillMode,
            chordsToSpellCount: chordsToSpellCount,
            userSelectedCadenceType: userSelectedCadenceType,
            checkAnswer: { answer, question in
                cadenceGame.isAnswerCorrect(userAnswer: answer, question: question)
            }
        )
        
        // For ear training, submit dummy answer
        if isEarTrainingMode {
            cadenceGame.submitAnswer(question.expectedAnswers)
        }
    }

    private func continueToNextQuestion() {
        // For non-ear-training modes, submit the pending answer
        if !isEarTrainingMode {
            guard !viewModel.pendingAnswerToSubmit.isEmpty else { return }
            cadenceGame.submitAnswer(viewModel.pendingAnswerToSubmit)
        }
        
        // Reset ViewModel state for next question
        viewModel.resetForNextQuestion(
            drillMode: cadenceGame.selectedDrillMode,
            currentQuestion: cadenceGame.currentQuestion
        )
        
        // Clear ear training selection
        userSelectedCadenceType = nil
    }

    private func playCurrentCadence() {
        viewModel.playCurrentCadence(
            drillMode: cadenceGame.selectedDrillMode,
            currentQuestion: cadenceGame.currentQuestion
        )
    }

    private func formatFeedback() -> String {
        guard let question = cadenceGame.currentQuestion else { return "" }
        
        // Handle ear training mode differently
        if isEarTrainingMode {
            // Use captured feedback data (not current question which has advanced)
            guard let correctType = viewModel.feedbackCorrectCadenceType else { return "" }
            let userType = viewModel.feedbackUserSelectedType
            
            var feedback = ""
            feedback += "Correct Cadence: \(correctType.rawValue)\n"
            if let selected = userType, selected != correctType {
                feedback += "You selected: \(selected.rawValue)\n"
            }
            return feedback
        }
        
        let chordsToSpell = question.chordsToSpell
        let expectedAnswers = question.expectedAnswers
        
        // Safety check
        guard !expectedAnswers.isEmpty else { return "" }

        var feedback = ""
        
        // Show hint penalty if hints were used
        if cadenceGame.hintsUsedThisQuestion > 0 {
            let creditPercent = Int(cadenceGame.hintPenalty * 100)
            feedback += "Hints used: \(cadenceGame.hintsUsedThisQuestion) (\(creditPercent)% credit)\n\n"
        }

        for i in 0..<chordsToSpell.count {
            guard i < viewModel.chordSpellings.count, i < expectedAnswers.count else { continue }
            
            let chordName = chordsToSpell[i].displayName
            let userNotes = viewModel.chordSpellings[i].map { $0.name }.joined(separator: ", ")
            let correctNotes = expectedAnswers[i].map { $0.name }.joined(separator: ", ")

            feedback += "Chord \(i + 1) (\(chordName)):\n"
            feedback += "Your answer: \(userNotes.isEmpty ? "None" : userNotes)\n"

            if !viewModel.isCorrect {
                feedback += "Correct: \(correctNotes)\n"
            }

            if i < chordsToSpell.count - 1 {
                feedback += "\n"
            }
        }

        return feedback
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        CadenceDrillSession(
            viewState: .constant(.active),
            userSelectedCadenceType: .constant(nil)
        )
        .environmentObject(CadenceGame())
        .environmentObject(SettingsManager.shared)
    }
}
