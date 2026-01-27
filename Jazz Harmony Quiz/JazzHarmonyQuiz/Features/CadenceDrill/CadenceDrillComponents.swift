import SwiftUI

// MARK: - Cadence Chord Identification Session View

/// View for chord identification mode - user selects chords by root + quality
struct CadenceChordIdentificationSession: View {
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var viewState: DrillState
    
    @State private var currentChordIndex = 0
    @State private var chordSelections: [ChordSelection] = [ChordSelection(), ChordSelection(), ChordSelection(), ChordSelection(), ChordSelection()]
    @State private var showingFeedback = false
    @State private var feedbackResults: [Bool] = []
    @State private var feedbackPhase: FeedbackPhase = .showingUserAnswer
    @State private var highlightedChordIndex: Int? = nil
    @State private var showContinueButton = false
    
    enum FeedbackPhase {
        case showingUserAnswer
        case showingCorrectAnswer
    }
    
    private var question: CadenceQuestion? {
        cadenceGame.currentQuestion
    }
    
    private var expectedChords: [Chord] {
        question?.cadence.chords ?? []
    }
    
    private var availableQualities: [CadenceChordQuality] {
        guard let q = question else { return CadenceChordQuality.allCadenceQualities }
        switch q.cadence.cadenceType {
        case .major, .tritoneSubstitution, .backdoor, .birdChanges:
            return CadenceChordQuality.majorCadenceQualities
        case .minor:
            return CadenceChordQuality.minorCadenceQualities
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            if let question = question {
                // Header: Key and Cadence Type
                VStack(spacing: 8) {
                    Text("Key of \(question.cadence.key.name)")
                        .font(.system(size: 32, weight: .bold))
                    
                    Text(question.cadence.cadenceType.rawValue)
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                .padding()
                
                // Roman numeral indicators
                HStack(spacing: 20) {
                    ForEach(0..<expectedChords.count, id: \.self) { index in
                        chordPositionIndicator(index: index)
                    }
                }
                .padding(.horizontal)
                
                // Current selection display
                if !showingFeedback {
                    VStack(spacing: 8) {
                        Text("Enter chord \(currentChordIndex + 1) of \(expectedChords.count)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(romanNumeral(for: currentChordIndex, cadenceType: question.cadence.cadenceType))
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(ShedTheme.Colors.brass)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Chord Selector or Feedback
                if showingFeedback {
                    feedbackView()
                } else {
                    ChordSelectorView(
                        selection: $chordSelections[currentChordIndex],
                        availableQualities: availableQualities,
                        disabled: false,
                        onComplete: nil,
                        keyContext: question.cadence.key
                    )
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Action Buttons
                actionButtons()
            }
        }
        .padding(.vertical)
        .onAppear {
            resetForNewQuestion()
        }
        .onChange(of: cadenceGame.currentQuestion?.id) { _, _ in
            resetForNewQuestion()
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func chordPositionIndicator(index: Int) -> some View {
        let isActive = index == currentChordIndex && !showingFeedback
        let isCompleted = index < currentChordIndex || showingFeedback
        let selection = chordSelections[safe: index]
        
        VStack(spacing: 4) {
            // Roman numeral
            if let q = question {
                Text(romanNumeral(for: index, cadenceType: q.cadence.cadenceType))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Chord display
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor(isActive: isActive, isCompleted: isCompleted, index: index))
                    .frame(width: 80, height: 50)
                
                if isCompleted && showingFeedback {
                    // Show the selected chord with correctness indicator
                    VStack(spacing: 2) {
                        Text(selection?.displayName ?? "—")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(feedbackResults[safe: index] == true ? .green : .red)
                        
                        Image(systemName: feedbackResults[safe: index] == true ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(feedbackResults[safe: index] == true ? .green : .red)
                    }
                } else if isCompleted || selection?.isComplete == true {
                    Text(selection?.displayName ?? "—")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                } else if isActive {
                    Text("?")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.7))
                } else {
                    Text("—")
                        .foregroundColor(.secondary)
                }
            }
        }
    }
    
    private func backgroundColor(isActive: Bool, isCompleted: Bool, index: Int) -> Color {
        if showingFeedback {
            return feedbackResults[safe: index] == true ? ShedTheme.Colors.success.opacity(0.8) : ShedTheme.Colors.danger.opacity(0.8)
        } else if isCompleted {
            return ShedTheme.Colors.brass
        } else if isActive {
            return ShedTheme.Colors.brass.opacity(0.7)
        } else {
            return Color(.systemGray4)
        }
    }
    
    @ViewBuilder
    private func feedbackView() -> some View {
        let allCorrect = feedbackResults.allSatisfy { $0 }
        
        VStack(spacing: 20) {
            if allCorrect {
                // Correct answer - simple display
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ShedTheme.Colors.success)
                
                Text("Correct!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                // Show the progression with highlighting
                userAnswerDisplay(allCorrect: true)
                
            } else {
                // Wrong answer - two phase display
                if feedbackPhase == .showingUserAnswer {
                    // Phase 1: Show user's answer
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(ShedTheme.Colors.danger)
                    
                    Text("Your answer:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    userAnswerDisplay(allCorrect: false)
                    
                    if showContinueButton {
                        Button(action: showCorrectAnswer) {
                            Text("See Correct Answer")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 24)
                                .padding(.vertical, 12)
                                .background(ShedTheme.Colors.brass)
                                .cornerRadius(10)
                        }
                        .padding(.top, 8)
                    }
                    
                } else {
                    // Phase 2: Show correct answer
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(ShedTheme.Colors.success)
                    
                    Text("Correct answer:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    correctAnswerDisplay()
                }
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func userAnswerDisplay(allCorrect: Bool) -> some View {
        HStack(spacing: 12) {
            ForEach(expectedChords.indices, id: \.self) { index in
                let isHighlighted = highlightedChordIndex == index
                let isCorrect = feedbackResults[safe: index] ?? false
                let selection = chordSelections[safe: index]
                
                VStack(spacing: 4) {
                    if let q = question {
                        Text(romanNumeral(for: index, cadenceType: q.cadence.cadenceType))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(selection?.displayName ?? "—")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(chordBackgroundColor(isHighlighted: isHighlighted, isCorrect: isCorrect, showResult: highlightedChordIndex == nil || highlightedChordIndex! >= index))
                        .foregroundColor(chordForegroundColor(isHighlighted: isHighlighted, isCorrect: isCorrect, showResult: highlightedChordIndex == nil || highlightedChordIndex! >= index))
                        .cornerRadius(8)
                        .scaleEffect(isHighlighted ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
                }
            }
        }
    }
    
    @ViewBuilder
    private func correctAnswerDisplay() -> some View {
        HStack(spacing: 12) {
            ForEach(expectedChords.indices, id: \.self) { index in
                let isHighlighted = highlightedChordIndex == index
                
                VStack(spacing: 4) {
                    if let q = question {
                        Text(romanNumeral(for: index, cadenceType: q.cadence.cadenceType))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(expectedChords[index].displayName)
                        .font(.system(size: 16, weight: .semibold))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(isHighlighted ? ShedTheme.Colors.success : ShedTheme.Colors.success.opacity(0.2))
                        .foregroundColor(isHighlighted ? .white : .primary)
                        .cornerRadius(8)
                        .scaleEffect(isHighlighted ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
                }
            }
        }
    }
    
    private func chordBackgroundColor(isHighlighted: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        if isHighlighted {
            return isCorrect ? ShedTheme.Colors.success : ShedTheme.Colors.danger
        }
        if showResult {
            return isCorrect ? ShedTheme.Colors.success.opacity(0.2) : ShedTheme.Colors.danger.opacity(0.2)
        }
        return ShedTheme.Colors.surface
    }
    
    private func chordForegroundColor(isHighlighted: Bool, isCorrect: Bool, showResult: Bool) -> Color {
        if isHighlighted {
            return .white
        }
        if showResult {
            return isCorrect ? .green : .red
        }
        return .primary
    }
    
    private func showCorrectAnswer() {
        feedbackPhase = .showingCorrectAnswer
        highlightedChordIndex = nil
        
        // Play correct progression with highlighting
        playCorrectProgressionWithHighlight()
    }
    
    @ViewBuilder
    private func actionButtons() -> some View {
        let allCorrect = feedbackResults.allSatisfy { $0 }
        
        HStack(spacing: 16) {
            if showingFeedback {
                // Only show Next button when:
                // - Answer was correct, OR
                // - We're in phase 2 (showing correct answer)
                if allCorrect || feedbackPhase == .showingCorrectAnswer {
                    Button(action: nextQuestion) {
                        Text(cadenceGame.isLastQuestion ? "Finish" : "Next")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ShedTheme.Colors.brass)
                            .cornerRadius(12)
                    }
                } else {
                    // Phase 1 with wrong answer - show empty space (continue button is in feedbackView)
                    Spacer()
                }
            } else {
                // Clear button
                Button(action: clearCurrentChord) {
                    Text("Clear")
                        .font(.headline)
                        .foregroundColor(ShedTheme.Colors.danger)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                
                // Next Chord / Submit button
                Button(action: advanceOrSubmit) {
                    Text(currentChordIndex < expectedChords.count - 1 ? "Next Chord" : "Submit")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(chordSelections[currentChordIndex].isComplete ? ShedTheme.Colors.brass : Color.gray)
                        .cornerRadius(12)
                }
                .disabled(!chordSelections[currentChordIndex].isComplete)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Actions
    
    private func resetForNewQuestion() {
        currentChordIndex = 0
        chordSelections = [ChordSelection(), ChordSelection(), ChordSelection(), ChordSelection(), ChordSelection()]
        showingFeedback = false
        feedbackResults = []
        feedbackPhase = .showingUserAnswer
        highlightedChordIndex = nil
        showContinueButton = false
    }
    
    private func clearCurrentChord() {
        chordSelections[currentChordIndex].reset()
        HapticFeedback.light()
    }
    
    private func advanceOrSubmit() {
        if currentChordIndex < expectedChords.count - 1 {
            // Move to next chord
            currentChordIndex += 1
            HapticFeedback.light()
        } else {
            // Submit all answers
            submitAnswer()
        }
    }
    
    private func submitAnswer() {
        // Check each chord
        feedbackResults = expectedChords.indices.map { index in
            chordSelections[index].matches(expectedChords[index])
        }
        
        let allCorrect = feedbackResults.allSatisfy { $0 }
        
        // Record answer in game
        cadenceGame.recordChordIdentificationAnswer(
            selections: Array(chordSelections.prefix(expectedChords.count)),
            isCorrect: allCorrect
        )
        
        // Reset feedback state
        feedbackPhase = .showingUserAnswer
        highlightedChordIndex = nil
        showContinueButton = false
        showingFeedback = true
        
        // Haptic feedback
        if allCorrect {
            HapticFeedback.success()
        } else {
            HapticFeedback.error()
        }
        
        // Play user's progression with highlighting
        playUserProgressionWithHighlight(allCorrect: allCorrect)
    }
    
    private func playUserProgressionWithHighlight(allCorrect: Bool) {
        let chordCount = expectedChords.count
        let tempoMS = 800
        
        // Convert user's chord selections to notes
        let userChords: [[Note]] = chordSelections.prefix(chordCount).compactMap { selection in
            selection.toNotes()
        }
        
        // Play and highlight each chord
        for index in 0..<chordCount {
            let delay = Double(index) * Double(tempoMS) / 1000.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    self.highlightedChordIndex = index
                }
                
                // Play the chord
                if index < userChords.count {
                    AudioManager.shared.playChord(userChords[index], duration: Double(tempoMS) / 1000.0 * 0.9)
                }
            }
        }
        
        // After all chords played, clear highlight and show continue button (if wrong)
        let totalDuration = Double(chordCount) * Double(tempoMS) / 1000.0 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            withAnimation {
                self.highlightedChordIndex = nil
                if !allCorrect {
                    self.showContinueButton = true
                }
            }
        }
    }
    
    private func playCorrectProgressionWithHighlight() {
        let chordCount = expectedChords.count
        let tempoMS = 800
        
        // Get correct chord notes
        let correctChords: [[Note]] = expectedChords.map { chord in
            chord.chordTones
        }
        
        // Play and highlight each chord
        for index in 0..<chordCount {
            let delay = Double(index) * Double(tempoMS) / 1000.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.15)) {
                    self.highlightedChordIndex = index
                }
                
                // Play the chord
                AudioManager.shared.playChord(correctChords[index], duration: Double(tempoMS) / 1000.0 * 0.9)
            }
        }
        
        // After all chords played, clear highlight
        let totalDuration = Double(chordCount) * Double(tempoMS) / 1000.0 + 0.3
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            withAnimation {
                self.highlightedChordIndex = nil
            }
        }
    }
    
    private func nextQuestion() {
        if cadenceGame.isLastQuestion {
            cadenceGame.endQuiz()
            viewState = .results
        } else {
            cadenceGame.advanceToNextQuestion()
            resetForNewQuestion()
        }
    }
    
    // MARK: - Helpers
    
    private func romanNumeral(for index: Int, cadenceType: CadenceType) -> String {
        switch cadenceType {
        case .major, .tritoneSubstitution, .backdoor:
            switch index {
            case 0: return "ii"
            case 1: return cadenceType == .tritoneSubstitution ? "SubV" : "V"
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
}

// MARK: - Cadence Type Picker for Ear Training

struct CadenceTypePicker: View {
    @Binding var selectedCadenceType: CadenceType?
    let correctCadenceType: CadenceType?
    let disabled: Bool
    let availableTypes: [CadenceType]  // Filter to only show these types

    var body: some View {
        VStack(spacing: 8) {
            ForEach(availableTypes, id: \.self) { cadenceType in
                Button(action: {
                    if !disabled {
                        selectedCadenceType = cadenceType
                        HapticFeedback.light()
                    }
                }) {
                    HStack {
                        Text(cadenceType.rawValue)
                            .font(.headline)

                        Spacer()

                        // Show icon based on state
                        if let correct = correctCadenceType {
                            if cadenceType == correct {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ShedTheme.Colors.success)
                            } else if cadenceType == selectedCadenceType {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(ShedTheme.Colors.danger)
                            }
                        } else if cadenceType == selectedCadenceType {
                            Image(systemName: "checkmark.circle")
                                .foregroundColor(ShedTheme.Colors.success)
                        } else {
                            Image(systemName: "circle")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(backgroundColor(for: cadenceType))
                    .cornerRadius(8)
                }
                .disabled(disabled)
            }
        }
    }

    private func backgroundColor(for cadenceType: CadenceType) -> Color {
        if let correct = correctCadenceType {
            if cadenceType == correct {
                return .green.opacity(0.2)
            } else if cadenceType == selectedCadenceType {
                return .red.opacity(0.2)
            }
        }

        if cadenceType == selectedCadenceType {
            return .green.opacity(0.1)
        }
        return Color(.systemGray6)
    }
}

// MARK: - Chord Voicing View

/// Shows a mini keyboard with the correct chord voicing highlighted
struct ChordVoicingView: View {
    let notes: [Note]
    let chordName: String
    
    // Piano key layout for one octave
    private let whiteKeyNames = ["C", "D", "E", "F", "G", "A", "B"]
    private let blackKeyNames = ["C#", "D#", "", "F#", "G#", "A#", ""]
    
    var body: some View {
        VStack(spacing: 8) {
            Text(chordName)
                .font(.headline)
                .fontWeight(.bold)
            
            // Mini piano
            GeometryReader { geometry in
                let whiteKeyWidth = geometry.size.width / 7
                let whiteKeyHeight: CGFloat = 80
                let blackKeyWidth = whiteKeyWidth * 0.6
                let blackKeyHeight = whiteKeyHeight * 0.6
                
                ZStack(alignment: .topLeading) {
                    // White keys
                    HStack(spacing: 1) {
                        ForEach(0..<7, id: \.self) { index in
                            let noteName = whiteKeyNames[index]
                            let isHighlighted = notes.contains { $0.name == noteName || $0.name == noteName }
                            
                            Rectangle()
                                .fill(isHighlighted ? ShedTheme.Colors.brass : Color.white)
                                .frame(width: whiteKeyWidth - 1, height: whiteKeyHeight)
                                .overlay(
                                    VStack {
                                        Spacer()
                                        if isHighlighted {
                                            Text(noteName)
                                                .font(.caption2)
                                                .foregroundColor(.white)
                                                .fontWeight(.bold)
                                        }
                                    }
                                    .padding(.bottom, 4)
                                )
                                .border(Color.gray, width: 0.5)
                        }
                    }
                    
                    // Black keys
                    HStack(spacing: 0) {
                        ForEach(0..<7, id: \.self) { index in
                            if index < 6 && (index != 2 && index != 6) {
                                let noteName = index == 0 ? "C#" : index == 1 ? "D#" : index == 3 ? "F#" : index == 4 ? "G#" : "A#"
                                let isHighlighted = notes.contains { $0.name == noteName || $0.name == enharmonic(noteName) }
                                
                                Rectangle()
                                    .fill(isHighlighted ? ShedTheme.Colors.brass : Color.black)
                                    .frame(width: blackKeyWidth, height: blackKeyHeight)
                                    .offset(x: whiteKeyWidth * CGFloat(index) + whiteKeyWidth - blackKeyWidth / 2)
                                    .overlay(
                                        VStack {
                                            Spacer()
                                            if isHighlighted {
                                                Text(noteName)
                                                    .font(.system(size: 8))
                                                    .foregroundColor(.white)
                                                    .fontWeight(.bold)
                                            }
                                        }
                                        .padding(.bottom, 2)
                                        .offset(x: whiteKeyWidth * CGFloat(index) + whiteKeyWidth - blackKeyWidth / 2)
                                    )
                            }
                        }
                    }
                }
            }
            .frame(height: 90)
            
            // Note names
            Text(notes.map { $0.name }.joined(separator: " - "))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func enharmonic(_ note: String) -> String {
        switch note {
        case "C#": return "Db"
        case "D#": return "Eb"
        case "F#": return "Gb"
        case "G#": return "Ab"
        case "A#": return "Bb"
        case "Db": return "C#"
        case "Eb": return "D#"
        case "Gb": return "F#"
        case "Ab": return "G#"
        case "Bb": return "A#"
        default: return note
        }
    }
}

// MARK: - Array Safe Subscript Extension

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}

// MARK: - Previews

#Preview("Chord Identification Session") {
    NavigationStack {
        CadenceChordIdentificationSession(viewState: .constant(.active))
            .environmentObject(CadenceGame())
            .environmentObject(SettingsManager.shared)
    }
}

#Preview("Cadence Type Picker") {
    CadenceTypePicker(
        selectedCadenceType: .constant(.major),
        correctCadenceType: nil,
        disabled: false,
        availableTypes: CadenceType.allCases
    )
    .padding()
}
