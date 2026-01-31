import SwiftUI

/// Quick Practice Session - runs a mixed practice session without setup
/// Per DESIGN.md Section 6.3
struct QuickPracticeSession: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - ViewModel
    
    @StateObject private var viewModel = QuickPracticeViewModel()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Group {
                if viewModel.sessionComplete {
                    resultsView
                } else if let item = viewModel.currentItem {
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
            viewModel.startSession()
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
                    if viewModel.showingFeedback {
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
                Text("Question \(viewModel.currentIndex + 1) of \(viewModel.items.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(viewModel.correctCount) correct")
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
                        .frame(width: geometry.size.width * viewModel.progress, height: 4)
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
            if !viewModel.selectedNotes.isEmpty {
                VStack(spacing: 8) {
                    Text("Selected Notes:")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(Array(viewModel.selectedNotes.sorted(by: { $0.midiNumber < $1.midiNumber })), id: \.midiNumber) { note in
                            Text(note.name)
                                .font(.system(size: viewModel.selectedNotes.count > 5 ? 18 : 22, weight: .semibold))
                                .foregroundColor(.white)
                                .padding(.horizontal, viewModel.selectedNotes.count > 5 ? 12 : 16)
                                .padding(.vertical, viewModel.selectedNotes.count > 5 ? 8 : 10)
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
                selectedNotes: $viewModel.selectedNotes,
                octaveRange: 4...4,
                showNoteNames: false,
                allowMultipleSelection: true
            )
            .frame(height: 180)
            .padding(.horizontal)
            .disabled(viewModel.showingFeedback)
            .onChange(of: viewModel.selectedNotes) { oldValue, newValue in
                // Play audio when notes are selected
                if let newNote = newValue.subtracting(oldValue).first {
                    viewModel.playNote(newNote)
                }
            }
        }
    }
    
    private func feedbackView(for item: QuickPracticeItem) -> some View {
        VStack(spacing: 12) {
            // Result indicator
            HStack {
                Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title)
                Text(viewModel.isCorrect ? "Correct!" : "Incorrect")
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .foregroundColor(viewModel.isCorrect ? .green : .red)
            
            // Correct answer
            if !viewModel.isCorrect {
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
                .fill((viewModel.isCorrect ? ShedTheme.Colors.success : ShedTheme.Colors.danger).opacity(0.1))
        )
    }
    
    private var actionButton: some View {
        Button {
            if viewModel.showingFeedback {
                viewModel.nextQuestion()
            } else {
                viewModel.checkAnswer()
                if settings.hapticFeedback {
                    let generator = UINotificationFeedbackGenerator()
                    generator.notificationOccurred(viewModel.isCorrect ? .success : .error)
                }
            }
        } label: {
            Text(viewModel.showingFeedback ? "Next" : "Check Answer")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BrassAccent"))
                .cornerRadius(12)
        }
        .disabled(!viewModel.canSubmitAnswer)
        .opacity(!viewModel.canSubmitAnswer ? 0.5 : 1)
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
                    
                    Text("\(viewModel.accuracy)% Accuracy")
                        .font(.title2)
                        .foregroundColor(viewModel.accuracy >= 80 ? .green : (viewModel.accuracy >= 60 ? .orange : .red))
                }
                .padding(.top, 20)
                
                // Stats
                HStack(spacing: 40) {
                    statItem(value: "\(viewModel.correctCount)", label: "Correct")
                    statItem(value: "\(viewModel.items.count - viewModel.correctCount)", label: "Missed")
                    statItem(value: viewModel.formatDuration(), label: "Time")
                }
                
                Divider()
                
                // Missed items review
                if !viewModel.missedItems.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("REVIEW MISSED")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.secondary)
                        
                        ForEach(viewModel.missedItems) { item in
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
                        viewModel.restartSession()
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
}

#Preview {
    QuickPracticeSession()
        .environmentObject(SettingsManager.shared)
}
