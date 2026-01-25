import SwiftUI

// MARK: - Cadence Drill Session View

/// Active session view for the standard cadence drill modes
/// Handles spelling chords, ear training, guide tones, etc.
struct CadenceDrillSession: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var viewState: CadenceDrillViewState
    @Binding var userSelectedCadenceType: CadenceType?  // For ear training answers
    @State private var currentChordIndex = 0 // Which chord we're currently spelling
    @State private var chordSpellings: [[Note]] = [[], [], [], [], []] // Spellings for up to 5 chords (Bird Changes)
    @State private var selectedNotes: Set<Note> = []
    @State private var showingFeedback = false
    @State private var isCorrect = false
    @State private var correctAnswerForFeedback: [[Note]] = []
    @State private var currentHintText: String? = nil
    
    // Ear training feedback state - capture before question advances
    @State private var feedbackCorrectCadenceType: CadenceType? = nil
    @State private var feedbackUserSelectedType: CadenceType? = nil
    @State private var currentQuestionCadenceChords: [[Note]] = []  // For audio playback

    /// Number of chords to spell based on drill mode
    private var chordsToSpellCount: Int {
        guard let question = cadenceGame.currentQuestion else { return 3 }
        return question.chordsToSpell.count
    }
    
    /// Whether we're in isolated chord mode
    private var isIsolatedMode: Bool {
        cadenceGame.selectedDrillMode == .isolatedChord
    }
    
    /// Whether we're in speed round mode
    private var isSpeedRoundMode: Bool {
        cadenceGame.selectedDrillMode == .speedRound
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
    
    /// Whether we're in smooth voicing mode
    private var isSmoothVoicingMode: Bool {
        cadenceGame.selectedDrillMode == .smoothVoicing
    }

    /// Whether we can submit ear training answer
    private var canSubmitEarTraining: Bool {
        if showingFeedback {
            return true
        }
        return userSelectedCadenceType != nil
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 20) {
            // Speed Round Timer (if in speed round mode)
            speedRoundTimerView
            
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
                        selectedNotes: $selectedNotes,
                        octaveRange: 4...4,
                        showNoteNames: false,
                        allowMultipleSelection: true
                    )
                    .padding(.horizontal)
                    .frame(height: 140)
                }

                // Selected Notes Display (only for non-ear training modes)
                if !isEarTrainingMode && !selectedNotes.isEmpty {
                    selectedNotesDisplay
                }

                // Action Buttons
                actionButtons(chordsToSpell: question.chordsToSpell)

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
        .onChange(of: cadenceGame.speedRoundTimeRemaining) { oldValue, newValue in
            // Handle speed round timeout
            if isSpeedRoundMode && newValue <= 0 && oldValue > 0 {
                handleSpeedRoundTimeout()
            }
        }
        .onChange(of: cadenceGame.currentQuestionIndex) { _, _ in
            // Store current question's cadence for playback (only if not showing feedback)
            // If showing feedback, we want to keep the previous question's chords
            if !showingFeedback, let question = cadenceGame.currentQuestion {
                currentQuestionCadenceChords = question.cadence.chords.map { $0.chordTones }
            }
            
            // Auto-play for ear training questions
            if isEarTrainingMode && settings.autoPlayCadences && !showingFeedback {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    playCurrentCadence()
                }
            }
        }
        .onAppear {
            // Store current question's cadence for playback
            if let question = cadenceGame.currentQuestion {
                currentQuestionCadenceChords = question.cadence.chords.map { $0.chordTones }
            }
            
            // Play on initial appear if ear training question
            if isEarTrainingMode && settings.autoPlayCadences {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playCurrentCadence()
                }
            }
        }
        .onDisappear {
            // Clean up timer when view disappears
            cadenceGame.stopSpeedRoundTimer()
        }
    }
    
    // MARK: - Speed Round Timer View
    
    @ViewBuilder
    private var speedRoundTimerView: some View {
        if isSpeedRoundMode && cadenceGame.speedRoundTimerActive {
            let timeText = String(format: "%.1f", cadenceGame.speedRoundTimeRemaining)
            let timerColor: Color = cadenceGame.speedRoundIsWarning ? .red : .orange
            let progressTint: Color = cadenceGame.speedRoundIsWarning ? .red : .orange
            
            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "timer")
                    Text(timeText)
                        .font(.title2)
                        .fontWeight(.bold)
                        .monospacedDigit()
                }
                .foregroundColor(timerColor)
                
                ProgressView(value: cadenceGame.speedRoundProgress)
                    .progressViewStyle(LinearProgressViewStyle(tint: progressTint))
                    .frame(height: 8)
                    .animation(.linear(duration: 0.1), value: cadenceGame.speedRoundProgress)
            }
            .padding(.horizontal)
        }
    }
    
    // MARK: - Ear Training Content View
    
    @ViewBuilder
    private var earTrainingContentView: some View {
        // Ear Training Display
        VStack(spacing: 16) {
            Image(systemName: "ear.fill")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
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
            .foregroundColor(.blue)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1))
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
                correctCadenceType: showingFeedback ? feedbackCorrectCadenceType : nil,
                disabled: showingFeedback,
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

                if isIsolatedMode {
                    Text("(\(cadenceGame.selectedIsolatedPosition.rawValue) only)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(settings.chordDisplayBackground(for: colorScheme))
            .cornerRadius(8)

            // Display chords based on mode
            chordDisplaySection(chordsToSpell: chordsToSpell)
            
            // Question text
            questionTextView(chordsToSpell: chordsToSpell)
            
            // Hint display
            if let hint = currentHintText {
                Text(hint)
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(8)
                    .background(Color.orange.opacity(0.1))
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
                    .foregroundColor(.orange)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.orange.opacity(0.1))
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
            Text("Spell: \(chordsToSpell[min(currentChordIndex, chordsToSpell.count - 1)].displayName) (3rd & 7th only)")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))
        } else if isResolutionTargetsMode {
            Text("Select the resolution target")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))
        } else if isSmoothVoicingMode {
            Text("Voice: \(chordsToSpell[min(currentChordIndex, chordsToSpell.count - 1)].displayName)")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))
        } else {
            Text("Spell: \(chordsToSpell[min(currentChordIndex, chordsToSpell.count - 1)].displayName)")
                .font(.headline)
                .foregroundColor(settings.primaryAccent(for: colorScheme))
        }
    }
    
    // MARK: - Chord Display Section
    
    @ViewBuilder
    private func chordDisplaySection(chordsToSpell: [Chord]) -> some View {
        if isIsolatedMode {
            // Single chord display for isolated mode
            chordDisplayCard(
                chord: chordsToSpell[0],
                index: 0,
                isActive: true,
                isCompleted: false
            )
            .frame(maxWidth: 200)
        } else if isCommonTonesMode {
            commonTonesModeDisplay(chordsToSpell: chordsToSpell)
        } else if isGuideTonesMode {
            guideTonesModeDisplay(chordsToSpell: chordsToSpell)
        } else if isResolutionTargetsMode {
            resolutionTargetsModeDisplay(chordsToSpell: chordsToSpell)
        } else if isSmoothVoicingMode {
            smoothVoicingModeDisplay(chordsToSpell: chordsToSpell)
        } else {
            // Display all chords for full progression or speed round
            HStack(spacing: 20) {
                ForEach(0..<chordsToSpell.count, id: \.self) { index in
                    chordDisplayCard(
                        chord: chordsToSpell[index],
                        index: index,
                        isActive: index == currentChordIndex,
                        isCompleted: !chordSpellings[index].isEmpty && index < currentChordIndex
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
                    .background(Color.blue.opacity(0.1))
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
                .foregroundColor(.orange)
                .padding(8)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            
            HStack(spacing: 20) {
                ForEach(0..<chordsToSpell.count, id: \.self) { index in
                    VStack(spacing: 6) {
                        Text(chordsToSpell[index].displayName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(index == currentChordIndex ? .blue : .secondary)
                        
                        Text("3rd & 7th")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(index == currentChordIndex ? Color.blue.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(index == currentChordIndex ? Color.blue : Color.clear, lineWidth: 2)
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
                        .foregroundColor(.blue)
                        .padding(12)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text(sourceChord.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text(pair.sourceNote.name)
                                .font(.title)
                                .foregroundColor(.blue)
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                        
                        Image(systemName: "arrow.right")
                            .font(.title)
                            .foregroundColor(.orange)
                        
                        VStack {
                            Text(targetChord.displayName)
                                .font(.title2)
                                .fontWeight(.bold)
                            Text("?")
                                .font(.title)
                                .foregroundColor(.orange)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    if showingFeedback, let targetNote = pair.targetNote {
                        Text("Answer: \(targetNote.name)")
                            .font(.headline)
                            .foregroundColor(.green)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func smoothVoicingModeDisplay(chordsToSpell: [Chord]) -> some View {
        VStack(spacing: 15) {
            Text("Move minimal semitones between chords")
                .font(.subheadline)
                .foregroundColor(.purple)
                .padding(8)
                .background(Color.purple.opacity(0.1))
                .cornerRadius(8)
            
            HStack(spacing: 15) {
                ForEach(0..<chordsToSpell.count, id: \.self) { index in
                    VStack(spacing: 6) {
                        Text(chordsToSpell[index].displayName)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(index == currentChordIndex ? .purple : .secondary)
                        
                        if index < currentChordIndex {
                            // Show completed voicing
                            Text(chordSpellings[index].map { $0.name }.joined(separator: " "))
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(index == currentChordIndex ? Color.purple.opacity(0.1) : Color.gray.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(index == currentChordIndex ? Color.purple : Color.clear, lineWidth: 2)
                    )
                    
                    if index < chordsToSpell.count - 1 {
                        Image(systemName: "arrow.right")
                            .foregroundColor(.gray)
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
                    Text(showingFeedback ? "Next Question →" : "Submit Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(canSubmitEarTraining ? settings.successColor(for: colorScheme) : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!canSubmitEarTraining && !showingFeedback)
            } else if isIsolatedMode {
                // In isolated mode, always show submit
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
            } else if isCommonTonesMode {
                // Common tones mode - single submit
                Button(action: submitAnswer) {
                    Text("Submit Common Tones")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedNotes.isEmpty ? Color.gray : settings.successColor(for: colorScheme))
                        .cornerRadius(12)
                }
                .disabled(selectedNotes.isEmpty)
            } else if isResolutionTargetsMode {
                // Resolution targets mode - single note submit
                Button(action: submitAnswer) {
                    Text("Submit Resolution Target")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(selectedNotes.isEmpty ? Color.gray : settings.successColor(for: colorScheme))
                        .cornerRadius(12)
                }
                .disabled(selectedNotes.isEmpty)
            } else if isGuideTonesMode || isSmoothVoicingMode {
                // Guide tones and smooth voicing modes - multi-chord submit
                if currentChordIndex < chordsToSpellCount - 1 {
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
            } else if currentChordIndex < chordsToSpellCount - 1 {
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
                .disabled(selectedNotes.isEmpty && !isSpeedRoundMode)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func handleSpeedRoundTimeout() {
        // Save whatever notes were selected (may be empty)
        chordSpellings[currentChordIndex] = Array(selectedNotes)
        
        if isIsolatedMode || currentChordIndex >= chordsToSpellCount - 1 {
            // Last chord or isolated mode - auto-submit
            submitAnswer()
        } else {
            // Move to next chord
            currentChordIndex += 1
            selectedNotes.removeAll()
            currentHintText = nil
            cadenceGame.resetSpeedRoundTimer()
        }
    }

    private func clearSelection() {
        selectedNotes.removeAll()
        HapticFeedback.light()
    }

    private func moveToNextChord() {
        // Save current chord spelling
        chordSpellings[currentChordIndex] = Array(selectedNotes)

        // Move to next chord
        currentChordIndex += 1
        selectedNotes.removeAll()
        currentHintText = nil  // Clear hint for new chord
        
        // Haptic feedback
        HapticFeedback.medium()
        
        // Reset speed round timer for next chord
        if isSpeedRoundMode {
            cadenceGame.resetSpeedRoundTimer()
        }
    }
    
    private func requestHint() {
        if let hint = cadenceGame.requestHint(for: currentChordIndex) {
            currentHintText = hint
        }
    }

    private func submitAnswer() {
        guard let question = cadenceGame.currentQuestion else { return }

        // Handle ear training mode
        if isEarTrainingMode {
            // If already showing feedback, move to next question
            if showingFeedback {
                continueToNextQuestion()
                return
            }

            // Capture feedback data BEFORE submitting (which advances the question)
            feedbackCorrectCadenceType = question.cadence.cadenceType
            feedbackUserSelectedType = userSelectedCadenceType
            currentQuestionCadenceChords = question.cadence.chords.map { $0.chordTones }
            
            // Check if selected cadence type matches
            isCorrect = userSelectedCadenceType == question.cadence.cadenceType

            // Haptic feedback
            if isCorrect {
                HapticFeedback.success()
            } else {
                HapticFeedback.error()
            }

            // Play the correct progression for feedback (using stored chords - same key)
            if settings.audioEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.playCurrentCadence()
                }
            }

            // Submit dummy answer (game expects chord spellings)
            cadenceGame.submitAnswer(question.expectedAnswers)
            showingFeedback = true
            return
        }

        // Stop speed round timer
        if isSpeedRoundMode {
            cadenceGame.stopSpeedRoundTimer()
        }

        // Save the last chord spelling
        chordSpellings[currentChordIndex] = Array(selectedNotes)

        // Prepare the answer based on mode
        let answerToSubmit: [[Note]]
        if isIsolatedMode || isCommonTonesMode || isResolutionTargetsMode {
            // Isolated, common tones, and resolution targets all submit just one set of notes
            answerToSubmit = [Array(selectedNotes)]
        } else if isGuideTonesMode || isSmoothVoicingMode {
            // Guide tones and smooth voicing submit all chords
            let numChords = chordsToSpellCount
            answerToSubmit = Array(chordSpellings.prefix(numChords))
        } else {
            // Only submit the number of chords we actually need to spell
            // (not the full 5-element array which may have empty trailing arrays)
            let numChords = chordsToSpellCount
            answerToSubmit = Array(chordSpellings.prefix(numChords))
        }

        // Store correct answer for feedback
        correctAnswerForFeedback = question.expectedAnswers

        // Check if answer is correct
        isCorrect = cadenceGame.isAnswerCorrect(userAnswer: answerToSubmit, question: question)

        // Haptic feedback based on result
        if isCorrect {
            HapticFeedback.success()

            // Play the user's entered chords as a cadence progression if enabled
            // This lets them hear their specific voicing/inversion
            if settings.playChordOnCorrect && settings.audioEnabled {
                // Use the user's entered notes (their inversions) for playback
                AudioManager.shared.playCadenceProgression(answerToSubmit, bpm: 90, beatsPerChord: 2)
            }
        } else {
            HapticFeedback.error()
            
            // Play the CORRECT answer so the user can hear what they should have spelled
            if settings.audioEnabled {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    AudioManager.shared.playCadenceProgression(
                        question.expectedAnswers,
                        bpm: 90,
                        beatsPerChord: 2
                    )
                }
            }
        }

        // Show feedback
        showingFeedback = true
    }

    private func continueToNextQuestion() {
        // For ear training mode, we already submitted in submitAnswer()
        // Just reset state and let the game continue
        if isEarTrainingMode {
            // Reset state for next question
            currentChordIndex = 0
            chordSpellings = [[], [], [], [], []]
            selectedNotes.removeAll()
            currentHintText = nil
            userSelectedCadenceType = nil
            feedbackCorrectCadenceType = nil
            feedbackUserSelectedType = nil
            showingFeedback = false
            
            // Store the new question's cadence chords and auto-play
            if let question = cadenceGame.currentQuestion {
                currentQuestionCadenceChords = question.cadence.chords.map { $0.chordTones }
                
                // Auto-play the new question
                if settings.autoPlayCadences {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        self.playCurrentCadence()
                    }
                }
            }
            return
        }
        
        guard let question = cadenceGame.currentQuestion else { return }

        // Prepare the answer based on mode
        let answerToSubmit: [[Note]]
        if isIsolatedMode || isCommonTonesMode {
            answerToSubmit = [Array(selectedNotes)]
        } else {
            // Only submit the number of chords we actually need to spell
            let numChords = chordsToSpellCount
            answerToSubmit = Array(chordSpellings.prefix(numChords))
        }
        
        // Submit the answer
        cadenceGame.submitAnswer(answerToSubmit)

        // Reset state for next question
        currentChordIndex = 0
        chordSpellings = [[], [], [], [], []]  // Reset for up to 5 chords
        selectedNotes.removeAll()
        currentHintText = nil
        userSelectedCadenceType = nil  // Clear ear training selection
        feedbackCorrectCadenceType = nil  // Clear ear training feedback
        feedbackUserSelectedType = nil
        currentQuestionCadenceChords = []  // Clear stored cadence
        showingFeedback = false

        // Start speed round timer for next question if still in quiz
        if isSpeedRoundMode && cadenceGame.isQuizActive {
            cadenceGame.startSpeedRoundTimer()
        }
    }

    private func playCurrentCadence() {
        // For ear training mode, ALWAYS use stored cadence chords to ensure same voicing/key
        // This is critical - never fall back to currentQuestion in ear training mode
        if isEarTrainingMode {
            guard !currentQuestionCadenceChords.isEmpty else {
                print("Warning: No stored cadence chords for ear training playback")
                return
            }
            let bpm = settings.cadenceBPM
            let beatsPerChord = settings.cadenceBeatsPerChord
            AudioManager.shared.playCadenceProgression(
                currentQuestionCadenceChords,
                bpm: bpm,
                beatsPerChord: beatsPerChord
            )
            return
        }
        
        // For other modes, use current question
        guard let question = cadenceGame.currentQuestion else { return }
        let chords = question.cadence.chords.map { $0.chordTones }
        
        let bpm = settings.cadenceBPM
        let beatsPerChord = settings.cadenceBeatsPerChord

        AudioManager.shared.playCadenceProgression(
            chords,
            bpm: bpm,
            beatsPerChord: beatsPerChord
        )
    }

    private func formatFeedback() -> String {
        guard let question = cadenceGame.currentQuestion else { return "" }
        
        // Handle ear training mode differently
        if isEarTrainingMode {
            // Use captured feedback data (not current question which has advanced)
            guard let correctType = feedbackCorrectCadenceType else { return "" }
            let userType = feedbackUserSelectedType
            
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
            guard i < chordSpellings.count, i < expectedAnswers.count else { continue }
            
            let chordName = chordsToSpell[i].displayName
            let userNotes = chordSpellings[i].map { $0.name }.joined(separator: ", ")
            let correctNotes = expectedAnswers[i].map { $0.name }.joined(separator: ", ")

            if isIsolatedMode {
                feedback += "Your answer: \(userNotes.isEmpty ? "None" : userNotes)\n"
                feedback += "Correct: \(correctNotes)\n"
            } else {
                feedback += "Chord \(i + 1) (\(chordName)):\n"
                feedback += "Your answer: \(userNotes.isEmpty ? "None" : userNotes)\n"

                if !isCorrect {
                    feedback += "Correct: \(correctNotes)\n"
                }

                if i < chordsToSpell.count - 1 {
                    feedback += "\n"
                }
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
