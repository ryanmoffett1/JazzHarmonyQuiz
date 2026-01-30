import SwiftUI

/// Quick Practice Session - runs a mixed practice session without setup
/// Per DESIGN.md Section 6.3
struct QuickPracticeSession: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var items: [QuickPracticeItem] = []
    @State private var currentIndex = 0
    @State private var selectedNotes: Set<Note> = []
    @State private var showingFeedback = false
    @State private var isCorrect = false
    @State private var sessionStartTime = Date()
    @State private var correctCount = 0
    @State private var missedItems: [MissedItem] = []
    @State private var sessionComplete = false
    
    private let generator = QuickPracticeGenerator.shared
    
    // MARK: - Computed Properties
    
    private var currentItem: QuickPracticeItem? {
        guard currentIndex < items.count else { return nil }
        return items[currentIndex]
    }
    
    private var progress: Double {
        guard !items.isEmpty else { return 0 }
        return Double(currentIndex) / Double(items.count)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if sessionComplete {
                    resultsView
                } else if let item = currentItem {
                    questionView(for: item)
                } else {
                    loadingView
                }
            }
            .navigationTitle("Quick Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Exit") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            startSession()
        }
    }
    
    // MARK: - Loading View
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
                .scaleEffect(1.5)
            Text("Generating session...")
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Question View
    
    private func questionView(for item: QuickPracticeItem) -> some View {
        VStack(spacing: 0) {
            // Progress bar
            progressBar
            
            ScrollView {
                VStack(spacing: 24) {
                    // Question header
                    questionHeader(for: item)
                    
                    // Piano keyboard for chord/interval/scale spelling
                    if item.type == .chordSpelling || item.type == .intervalBuilding || item.type == .scaleSpelling {
                        pianoSection
                    }
                    
                    // Feedback overlay
                    if showingFeedback {
                        feedbackView(for: item)
                    }
                    
                    Spacer(minLength: 20)
                    
                    // Action button
                    actionButton
                }
                .padding()
            }
        }
    }
    
    private var progressBar: some View {
        VStack(spacing: 4) {
            HStack {
                Text("Question \(currentIndex + 1) of \(items.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(correctCount) correct")
                    .font(.caption)
                    .foregroundColor(ShedTheme.Colors.success)
            }
            .padding(.horizontal)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color("BrassAccent"))
                        .frame(width: geometry.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
        }
        .padding(.top, 8)
    }
    
    private func questionHeader(for item: QuickPracticeItem) -> some View {
        VStack(spacing: 12) {
            // Category badge
            Text(item.category.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color.secondary.opacity(0.1))
                .cornerRadius(8)
            
            // Question text
            Text(item.question)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    private var pianoSection: some View {
        VStack(spacing: 16) {
            // Selected notes display using styled chips (like ChordDrillSession)
            if !selectedNotes.isEmpty {
                VStack(spacing: 8) {
                    Text("Selected Notes:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(Array(selectedNotes.sorted(by: { $0.midiNumber < $1.midiNumber })), id: \.midiNumber) { note in
                            Text(note.name)
                                .font(.system(size: selectedNotes.count > 5 ? 18 : 22, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, selectedNotes.count > 5 ? 12 : 16)
                                .padding(.vertical, selectedNotes.count > 5 ? 8 : 10)
                                .background(Color("BrassAccent"))
                                .cornerRadius(8)
                        }
                    }
                }
                .padding()
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .cornerRadius(12)
            }
            
            // Piano keyboard - consistent with other drills (no note names by default)
            PianoKeyboard(
                selectedNotes: $selectedNotes,
                octaveRange: 4...4,
                showNoteNames: false,
                allowMultipleSelection: true
            )
            .frame(height: 180)
            .padding(.horizontal)
            .disabled(showingFeedback)
            .onChange(of: selectedNotes) { oldValue, newValue in
                // Play audio when notes are selected
                if let newNote = newValue.subtracting(oldValue).first {
                    AudioManager.shared.playNote(UInt8(newNote.midiNumber))
                }
            }
        }
    }
    
    private func feedbackView(for item: QuickPracticeItem) -> some View {
        VStack(spacing: 12) {
            // Result indicator
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title)
                Text(isCorrect ? "Correct!" : "Incorrect")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(isCorrect ? .green : .red)
            
            // Correct answer
            if !isCorrect {
                VStack(spacing: 4) {
                    Text("Correct answer:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(item.correctNotes.map { $0.name }.joined(separator: " - "))
                        .font(.headline)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill((isCorrect ? ShedTheme.Colors.success : ShedTheme.Colors.danger).opacity(0.1))
        )
    }
    
    private var actionButton: some View {
        Button {
            if showingFeedback {
                nextQuestion()
            } else {
                checkAnswer()
            }
        } label: {
            Text(showingFeedback ? "Next" : "Check Answer")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BrassAccent"))
                .cornerRadius(12)
        }
        .disabled(!showingFeedback && selectedNotes.isEmpty)
        .opacity(!showingFeedback && selectedNotes.isEmpty ? 0.5 : 1)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
    
    // MARK: - Results View
    
    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Session Complete")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    let accuracy = items.isEmpty ? 0 : Int((Double(correctCount) / Double(items.count)) * 100)
                    Text("\(accuracy)% Accuracy")
                        .font(.title2)
                        .foregroundColor(accuracy >= 80 ? .green : (accuracy >= 60 ? .orange : .red))
                }
                .padding(.top, 20)
                
                // Stats
                HStack(spacing: 40) {
                    statItem(value: "\(correctCount)", label: "Correct")
                    statItem(value: "\(items.count - correctCount)", label: "Missed")
                    statItem(value: formatDuration(), label: "Time")
                }
                
                Divider()
                
                // Missed items review
                if !missedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("REVIEW MISSED")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        ForEach(missedItems) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.question)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    Text("You said: \(item.userAnswer)")
                                        .font(.caption)
                                        .foregroundColor(ShedTheme.Colors.danger)
                                    Text("Correct: \(item.correctAnswer)")
                                        .font(.caption)
                                        .foregroundColor(ShedTheme.Colors.success)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(8)
                        }
                    }
                }
                
                Spacer(minLength: 40)
                
                // Action buttons
                VStack(spacing: 12) {
                    Button {
                        restartSession()
                    } label: {
                        Text("Practice Again")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color("BrassAccent"))
                            .cornerRadius(12)
                    }
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
    }
    
    private func statItem(value: String, label: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Actions
    
    private func startSession() {
        items = generator.generateSession()
        currentIndex = 0
        correctCount = 0
        missedItems = []
        selectedNotes = []
        showingFeedback = false
        sessionComplete = false
        sessionStartTime = Date()
    }
    
    private func checkAnswer() {
        guard let item = currentItem else { return }
        
        // Validate answer based on item type
        switch item.type {
        case .chordSpelling:
            isCorrect = validateChordAnswer(item: item)
        case .intervalBuilding:
            isCorrect = validateIntervalAnswer(item: item)
        case .scaleSpelling:
            isCorrect = validateScaleAnswer(item: item)
        case .cadenceProgression:
            isCorrect = false  // Not yet implemented
        }
        
        if isCorrect {
            correctCount += 1
            if settings.hapticFeedback {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
            }
            // Play correct chord/interval as audio feedback
            if !item.correctNotes.isEmpty {
                playCorrectAnswer(item.correctNotes)
            }
        } else {
            // Record missed item
            missedItems.append(MissedItem(
                question: item.question,
                userAnswer: selectedNotes.map { $0.name }.joined(separator: ", "),
                correctAnswer: item.correctNotes.map { $0.name }.joined(separator: ", "),
                category: item.category
            ))
            if settings.hapticFeedback {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.error)
            }
            // Play correct answer so user can hear it
            if !item.correctNotes.isEmpty {
                playCorrectAnswer(item.correctNotes)
            }
        }
        
        showingFeedback = true
    }
    
    private func validateChordAnswer(item: QuickPracticeItem) -> Bool {
        // Compare pitch classes (ignore octave)
        let selectedPitchClasses = Set(selectedNotes.map { $0.midiNumber % 12 })
        let correctPitchClasses = Set(item.correctNotes.map { $0.midiNumber % 12 })
        return selectedPitchClasses == correctPitchClasses
    }
    
    private func validateIntervalAnswer(item: QuickPracticeItem) -> Bool {
        // For intervals, we need the correct number of semitones
        let sortedSelected = selectedNotes.sorted { $0.midiNumber < $1.midiNumber }
        guard sortedSelected.count == 2, item.correctNotes.count == 2 else {
            return false
        }
        let selectedInterval = abs(sortedSelected[1].midiNumber - sortedSelected[0].midiNumber) % 12
        let correctInterval = abs(item.correctNotes[1].midiNumber - item.correctNotes[0].midiNumber) % 12
        return selectedInterval == correctInterval
    }
    
    private func validateScaleAnswer(item: QuickPracticeItem) -> Bool {
        // Scale validation - compare pitch classes
        guard selectedNotes.count == item.correctNotes.count else {
            return false
        }
        let selectedPitchClasses = Set(selectedNotes.map { $0.midiNumber % 12 })
        let correctPitchClasses = Set(item.correctNotes.map { $0.midiNumber % 12 })
        return selectedPitchClasses == correctPitchClasses
    }
    
    private func nextQuestion() {
        selectedNotes = []
        showingFeedback = false
        
        if currentIndex < items.count - 1 {
            currentIndex += 1
        } else {
            sessionComplete = true
            recordSessionResults()
        }
    }
    
    private func restartSession() {
        startSession()
    }
    
    private func recordSessionResults() {
        // Record to spaced repetition
        // Record to statistics
        // (Integration with existing systems)
    }
    
    private func formatDuration() -> String {
        let duration = Date().timeIntervalSince(sessionStartTime)
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// Plays the correct answer notes as audio feedback
    private func playCorrectAnswer(_ notes: [Note]) {
        // Play notes as a chord (simultaneously)
        AudioManager.shared.playChord(notes)
    }
}

#Preview {
    QuickPracticeSession()
        .environmentObject(SettingsManager.shared)
}
