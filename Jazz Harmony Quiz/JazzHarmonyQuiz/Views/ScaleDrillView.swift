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

// MARK: - Scale Drill View

struct ScaleDrillView: View {
    @EnvironmentObject var scaleGame: ScaleGame
    @EnvironmentObject var settings: SettingsManager
    @State private var selectedNotes: Set<Note> = []
    @State private var viewState: ViewState = .setup
    @State private var numberOfQuestions: Int = 10
    @State private var selectedDifficulty: ScaleType.ScaleDifficulty = .beginner
    @State private var selectedQuestionTypes: Set<ScaleQuestionType> = [.allDegrees]
    @State private var selectedKeyDifficulty: KeyDifficulty = .all
    @State private var selectedScaleSymbols: Set<String> = []
    @State private var showingFeedback = false
    @State private var showScaleTypeFilter = false
    
    enum ViewState {
        case setup
        case active
        case results
    }
    
    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                ScaleSetupView(
                    numberOfQuestions: $numberOfQuestions,
                    selectedDifficulty: $selectedDifficulty,
                    selectedQuestionTypes: $selectedQuestionTypes,
                    selectedKeyDifficulty: $selectedKeyDifficulty,
                    selectedScaleSymbols: $selectedScaleSymbols,
                    onStartQuiz: startQuiz
                )
            case .active:
                ActiveScaleQuizView(
                    selectedNotes: $selectedNotes,
                    showingFeedback: $showingFeedback,
                    viewState: $viewState
                )
            case .results:
                ScaleDrillResultsView(onNewQuiz: {
                    scaleGame.resetQuizState()
                    viewState = .setup
                    selectedNotes = []
                    showingFeedback = false
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if scaleGame.isQuizActive {
                    Button("Quit") {
                        quitQuiz()
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                if scaleGame.isQuizActive {
                    VStack {
                        Text("Question \(scaleGame.currentQuestionNumber) of \(scaleGame.totalQuestions)")
                            .font(.headline)
                        ProgressView(value: scaleGame.progress)
                            .frame(width: 200)
                    }
                }
            }
        }
        .onChange(of: scaleGame.isQuizCompleted) { oldValue, newValue in
            if newValue && !oldValue {
                viewState = .results
            }
        }
    }
    
    private func startQuiz() {
        selectedNotes = []
        showingFeedback = false
        viewState = .active
        
        scaleGame.selectedKeyDifficulty = selectedKeyDifficulty
        scaleGame.selectedScaleSymbols = selectedScaleSymbols
        
        scaleGame.startNewQuiz(
            numberOfQuestions: numberOfQuestions,
            difficulty: selectedDifficulty,
            questionTypes: selectedQuestionTypes
        )
    }
    
    private func quitQuiz() {
        viewState = .setup
        scaleGame.resetQuizState()
        selectedNotes = []
        showingFeedback = false
    }
}

// MARK: - Scale Setup View

struct ScaleSetupView: View {
    @EnvironmentObject var scaleGame: ScaleGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSettings = false
    @Binding var numberOfQuestions: Int
    @Binding var selectedDifficulty: ScaleType.ScaleDifficulty
    @Binding var selectedQuestionTypes: Set<ScaleQuestionType>
    @Binding var selectedKeyDifficulty: KeyDifficulty
    @Binding var selectedScaleSymbols: Set<String>
    @State private var showScaleTypeFilter = false
    let onStartQuiz: () -> Void
    
    private var playerStats: PlayerStats { PlayerStats.shared }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Scale Drill Setup")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Text(playerStats.currentRank.emoji)
                            Text("\(playerStats.currentRating)")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        
                        if playerStats.currentStreak > 0 {
                            HStack(spacing: 4) {
                                Text("🔥")
                                Text("\(playerStats.currentStreak)")
                                    .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            .foregroundColor(.orange)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Number of Questions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Number of Questions")
                            .font(.headline)
                        
                        Picker("Questions", selection: $numberOfQuestions) {
                            ForEach([5, 10, 15, 20, 25], id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Difficulty Level
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Scale Difficulty")
                            .font(.headline)
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(ScaleType.ScaleDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue).tag(difficulty)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text(selectedDifficulty.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: selectedDifficulty) { _, newValue in
                        // Clear scale type filter when changing difficulty (unless Custom)
                        if newValue != .custom {
                            selectedScaleSymbols.removeAll()
                        }
                    }
                    
                    // Key Difficulty
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Key Difficulty")
                            .font(.headline)
                        
                        Picker("Keys", selection: $selectedKeyDifficulty) {
                            ForEach(KeyDifficulty.allCases, id: \.self) { keyDiff in
                                Text(keyDiff.rawValue).tag(keyDiff)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        
                        Text(selectedKeyDifficulty.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    // Question Types
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Question Types")
                            .font(.headline)
                        
                        ForEach(ScaleQuestionType.allCases, id: \.self) { questionType in
                            HStack {
                                Button(action: {
                                    if selectedQuestionTypes.contains(questionType) {
                                        selectedQuestionTypes.remove(questionType)
                                    } else {
                                        selectedQuestionTypes.insert(questionType)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: selectedQuestionTypes.contains(questionType) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedQuestionTypes.contains(questionType) ? .teal : .gray)
                                        
                                        VStack(alignment: .leading) {
                                            Text(questionType.rawValue)
                                                .font(.subheadline)
                                                .fontWeight(.medium)
                                            Text(questionType.description)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        
                                        Spacer()
                                    }
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    
                    // Scale Type Filter (only for Custom difficulty)
                    if selectedDifficulty == .custom {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Scale Types Filter")
                                    .font(.headline)
                                Spacer()
                                Text(selectedScaleSymbols.isEmpty ? "All" : "\(selectedScaleSymbols.count) selected")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text("Customize which scale types to include")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Button(action: { showScaleTypeFilter.toggle() }) {
                                HStack {
                                    Image(systemName: "slider.horizontal.3")
                                    Text(selectedScaleSymbols.isEmpty ? "Filter by scale type..." : scaleFilterSummary)
                                        .lineLimit(1)
                                    Spacer()
                                    Image(systemName: showScaleTypeFilter ? "chevron.up" : "chevron.down")
                                }
                                .font(.subheadline)
                                .foregroundColor(.primary)
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(8)
                            }
                            
                            if showScaleTypeFilter {
                                ScaleTypeFilterView(selectedSymbols: $selectedScaleSymbols)
                                    .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .animation(.easeInOut(duration: 0.2), value: showScaleTypeFilter)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Start Button
                Button(action: onStartQuiz) {
                    Text("Start Quiz")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .cornerRadius(12)
                }
                .disabled(selectedQuestionTypes.isEmpty)
                
                // Scale Scoreboard Button
                NavigationLink(destination: ScaleScoreboardView().environmentObject(scaleGame)) {
                    HStack {
                        Image(systemName: "trophy.fill")
                        Text("View Scale Scoreboard")
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.orange, lineWidth: 1.5)
                    )
                }
                
                Spacer()
            }
            .padding()
        }
    }
    
    private var scaleFilterSummary: String {
        if selectedScaleSymbols.isEmpty {
            return "All scale types"
        } else if selectedScaleSymbols.count <= 3 {
            return selectedScaleSymbols.sorted().joined(separator: ", ")
        } else {
            return "\(selectedScaleSymbols.count) types selected"
        }
    }
}

// MARK: - Scale Type Filter View

struct ScaleTypeFilterView: View {
    @Binding var selectedSymbols: Set<String>
    let database = JazzScaleDatabase.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button("Select All") {
                    selectedSymbols = Set(database.getAllScaleSymbols())
                }
                .font(.caption)
                .foregroundColor(.blue)
                
                Spacer()
                
                Button("Clear All") {
                    selectedSymbols.removeAll()
                }
                .font(.caption)
                .foregroundColor(.red)
            }
            
            ForEach(JazzScaleDatabase.ScaleCategory.allCases, id: \.self) { category in
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(database.getScalesInCategory(category), id: \.id) { scaleType in
                            ScaleTypeChip(
                                symbol: scaleType.symbol,
                                isSelected: selectedSymbols.contains(scaleType.symbol),
                                onTap: {
                                    if selectedSymbols.contains(scaleType.symbol) {
                                        selectedSymbols.remove(scaleType.symbol)
                                    } else {
                                        selectedSymbols.insert(scaleType.symbol)
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(8)
    }
}

struct ScaleTypeChip: View {
    let symbol: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            Text(symbol)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.teal : Color(.systemGray4))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Active Scale Quiz View

struct ActiveScaleQuizView: View {
    @EnvironmentObject var scaleGame: ScaleGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedNotes: Set<Note>
    @Binding var showingFeedback: Bool
    @Binding var viewState: ScaleDrillView.ViewState
    
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
                    // Ear Training Display
                    earTrainingDisplay(question: question)
                } else {
                    // Visual Scale Display
                    visualScaleDisplay(question: question)
                }
                
                // Selected Notes Display or Feedback (for visual questions)
                if question.questionType != .earTraining {
                    if showingFeedback {
                        feedbackNotesView(question: question)
                    } else if !selectedNotes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(Array(selectedNotes).sorted { $0.midiNumber < $1.midiNumber }, id: \.midiNumber) { note in
                                    Text(displayNoteName(note, for: question.scale))
                                        .font(.headline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(Color.teal)
                                        .foregroundColor(.white)
                                        .cornerRadius(8)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 44)
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
                    Text("Maximum \(question.correctNotes.count) notes allowed!")
                        .font(.caption)
                        .foregroundColor(.orange)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(8)
                        .transition(.scale.combined(with: .opacity))
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
                    .foregroundColor(.purple)
                
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
                                            .foregroundColor(.green)
                                    } else if isWrongChoice {
                                        Image(systemName: "xmark.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                } else if isSelected {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.purple)
                                }
                            }
                            .padding()
                            .background(
                                showingFeedback ?
                                    (isCorrectChoice ? Color.green.opacity(0.2) :
                                     isWrongChoice ? Color.red.opacity(0.2) :
                                     Color(.systemGray6)) :
                                    (isSelected ? Color.purple.opacity(0.2) : Color(.systemGray6))
                            )
                            .cornerRadius(10)
                        }
                        .disabled(showingFeedback)
                    }
                }
                .padding(.horizontal)
            }
        }
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
    
    // MARK: - Play Scale
    
    private func playCurrentScale() {
        guard let question = scaleGame.currentQuestion else { return }
        audioManager.playScaleObject(question.scale, bpm: 140)
    }
    
    // MARK: - Feedback View
    
    @ViewBuilder
    private func feedbackNotesView(question: ScaleQuestion) -> some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.title)
                Text(isCorrect ? "Correct!" : (feedbackPhase == .showingUserAnswer ? "Your answer:" : "Correct answer:"))
                    .font(.headline)
            }
            .foregroundColor(isCorrect ? .green : (feedbackPhase == .showingCorrectAnswer ? .green : .red))
            
            // Notes display
            // For correct answers or when showing correct answer, use correctNotesDisplay
            // which includes the 8va visualization for playback
            if isCorrect || feedbackPhase == .showingCorrectAnswer {
                correctNotesDisplay(question: question)
            } else {
                // Phase 1 for wrong answers: show user's notes with color coding
                userNotesDisplay(question: question)
            }
            
            // Continue button for wrong answers in phase 1
            if !isCorrect && feedbackPhase == .showingUserAnswer && showContinueButton {
                Button(action: showCorrectAnswer) {
                    Text("See Correct Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCorrect ? Color.green.opacity(0.1) : (feedbackPhase == .showingCorrectAnswer ? Color.green.opacity(0.1) : Color.red.opacity(0.1)))
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
                
                // Check if this is an octave duplicate (higher octave of same pitch class)
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
            
            // Ghosted 8va note at the end (for playback visualization)
            // Only show if user entered the correct number of notes (complete scale)
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
                .background(isOctaveHighlighted ? Color.blue : Color.gray.opacity(0.3))
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
                                    .background(Color.orange)
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
            // Display the scale notes (indices 0 to count-1)
            ForEach(Array(sortedNotes.enumerated()), id: \.offset) { index, note in
                let isHighlighted = highlightedNoteIndex == index
                
                Text(displayNoteName(note, for: question.scale))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isHighlighted ? Color.green : Color.green.opacity(0.7))
                    .foregroundColor(.white)
                    .cornerRadius(6)
                    .scaleEffect(isHighlighted ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.1), value: highlightedNoteIndex)
            }
            
            // Ghosted 8va note at the end (index = sortedNotes.count)
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
            .background(isOctaveHighlighted ? Color.green : Color.gray.opacity(0.3))
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
                    // Submit Button - requires scale type selection
                    Button(action: submitAnswer) {
                        Text("Submit")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(selectedScaleType != nil ? Color.purple : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(selectedScaleType == nil)
                } else {
                    // Visual questions - Clear and Submit
                    // Clear Button
                    Button(action: {
                        selectedNotes.removeAll()
                        ScaleDrillHaptics.light()
                    }) {
                        Text("Clear")
                            .font(.headline)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                    }
                    
                    // Submit Button - requires exact number of notes
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
                        .background(hasCorrectCount ? Color.teal : Color.gray)
                        .cornerRadius(12)
                    }
                    .disabled(!hasCorrectCount)
                }
                
            } else if isCorrect || feedbackPhase == .showingCorrectAnswer {
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
                    .background(Color.purple)
                    .cornerRadius(12)
                }
                
                // Next Button
                Button(action: moveToNext) {
                    Text(scaleGame.currentQuestionIndex < scaleGame.totalQuestions - 1 ? "Next" : "Finish")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
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
                    // User tried to add more notes than allowed
                    // Show warning and provide feedback
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showMaxNotesWarning = true
                    }
                    ScaleDrillHaptics.error()
                    audioManager.playNote(50, velocity: 60)  // Low thud sound
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        audioManager.stopNote(50)
                    }
                    
                    // Hide warning after a moment
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showMaxNotesWarning = false
                        }
                    }
                    // Don't update - keep the current selection
                } else {
                    showMaxNotesWarning = false
                    selectedNotes = newValue
                }
            }
        )
    }
    
    private func noteBackgroundColor(isCorrect: Bool, isHighlighted: Bool, isAllCorrect: Bool) -> Color {
        if isAllCorrect {
            return isHighlighted ? Color.green : Color.green.opacity(0.7)
        }
        if isHighlighted {
            return isCorrect ? Color.green : Color.red
        }
        return isCorrect ? Color.green.opacity(0.7) : Color.red.opacity(0.7)
    }
    
    private func displayNoteName(_ note: Note, for scale: Scale) -> String {
        // First, try to find this note's pitch class in the scale's own notes
        // This ensures we use the same enharmonic spelling the scale uses
        if let scaleNote = scale.scaleNotes.first(where: { $0.pitchClass == note.pitchClass }) {
            return scaleNote.name
        }
        
        // Fallback: use the scale's root to determine sharp/flat preference
        // This matches the logic in Scale.init
        let preferSharps = scale.root.isSharp || ["B", "E", "A", "D", "G"].contains(scale.root.name)
        if let displayNote = Note.noteFromMidi(note.midiNumber, preferSharps: preferSharps) {
            return displayNote.name
        }
        return note.name
    }
    
    /// Sort notes in scale order starting from the root
    /// This ensures D E F G A B C sorts correctly for a D scale (not C D E F G A B)
    /// Octave notes (same pitch class as root but higher octave) go at the END
    private func sortNotesForScale(_ notes: [Note], rootPitchClass: Int) -> [Note] {
        // Find the lowest MIDI number for the root pitch class (the "base" root)
        let rootNotes = notes.filter { $0.pitchClass == rootPitchClass }
        let baseRootMidi = rootNotes.map { $0.midiNumber }.min() ?? 60
        
        return notes.sorted { note1, note2 in
            // Check if either note is an octave of the root (same pitch class, higher MIDI)
            let isNote1OctaveRoot = note1.pitchClass == rootPitchClass && note1.midiNumber > baseRootMidi
            let isNote2OctaveRoot = note2.pitchClass == rootPitchClass && note2.midiNumber > baseRootMidi
            
            // Octave roots always go to the end
            if isNote1OctaveRoot && !isNote2OctaveRoot {
                return false  // note1 (octave) comes after note2
            }
            if isNote2OctaveRoot && !isNote1OctaveRoot {
                return true   // note1 comes before note2 (octave)
            }
            
            // If both are octave roots (multiple octaves), sort by MIDI
            if isNote1OctaveRoot && isNote2OctaveRoot {
                return note1.midiNumber < note2.midiNumber
            }
            
            // For non-octave notes, sort by interval from root
            let interval1 = (note1.pitchClass - rootPitchClass + 12) % 12
            let interval2 = (note2.pitchClass - rootPitchClass + 12) % 12
            
            // If same interval, sort by MIDI number
            if interval1 == interval2 {
                return note1.midiNumber < note2.midiNumber
            }
            return interval1 < interval2
        }
    }
    
    /// Get the MIDI number to play for a note in a scale context
    /// This handles octave wrapping so the scale plays ascending
    private func getMidiForScaleNote(_ note: Note, index: Int, rootMidi: Int, rootPitchClass: Int) -> UInt8 {
        // Calculate the interval from root (0-11)
        let interval = (note.pitchClass - rootPitchClass + 12) % 12
        // Add the interval to the root MIDI to get the actual pitch to play
        return UInt8(rootMidi + interval)
    }
    
    private func submitAnswer() {
        guard let question = scaleGame.currentQuestion else { return }
        
        // Handle ear training differently
        if question.questionType == .earTraining {
            submitEarTrainingAnswer()
            return
        }
        
        // Store user's answer for display
        userAnswerNotes = Array(selectedNotes)
        feedbackPhase = .showingUserAnswer
        highlightedNoteIndex = nil
        showContinueButton = false
        
        isCorrect = scaleGame.submitAnswer(selectedNotes)
        hasSubmitted = true
        showingFeedback = true
        
        if isCorrect {
            feedbackMessage = "Correct! 🎉"
            ScaleDrillHaptics.success()
            // Play with highlighting
            playScaleWithHighlight(notes: question.correctNotes)
        } else {
            feedbackMessage = "Incorrect"
            ScaleDrillHaptics.error()
            // Play user's answer with highlighting
            playUserAnswerWithHighlight()
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
            // Record correct answer
            scaleGame.recordEarTrainingAnswer(correct: true)
        } else {
            feedbackMessage = "Incorrect - \(correctScaleType.name)"
            ScaleDrillHaptics.error()
            // Record incorrect answer
            scaleGame.recordEarTrainingAnswer(correct: false)
            
            // Show conceptual explanation
            let concept = ConceptualExplanations.shared.scaleExplanation(for: correctScaleType)
            feedbackMessage += "\n\n" + concept.sound
        }
    }
    
    private func playUserAnswerWithHighlight() {
        guard let question = scaleGame.currentQuestion else { return }
        
        let rootPitchClass = question.scale.root.pitchClass
        let rootMidi = question.scale.root.midiNumber
        let sortedNotes = sortNotesForScale(userAnswerNotes, rootPitchClass: rootPitchClass)
        let beatDuration: TimeInterval = 0.3  // 300ms per note
        
        // Build the full sequence: ascending + octave + descending (like correct answer playback)
        var playbackSequence: [(midi: Int, displayIndex: Int)] = []
        
        // Ascending: play each note from root up (indices 0 to count-1)
        for (index, note) in sortedNotes.enumerated() {
            let interval = (note.pitchClass - rootPitchClass + 12) % 12
            let midi = rootMidi + interval
            playbackSequence.append((midi: midi, displayIndex: index))
        }
        
        // Only add octave and descending if user entered correct number of notes
        if sortedNotes.count == question.correctNotes.count {
            // Octave (8va) - display index is sortedNotes.count
            playbackSequence.append((midi: rootMidi + 12, displayIndex: sortedNotes.count))
            
            // Descending: go back down, highlighting the same display indices in reverse
            for i in stride(from: sortedNotes.count - 1, through: 0, by: -1) {
                let note = sortedNotes[i]
                let interval = (note.pitchClass - rootPitchClass + 12) % 12
                let midi = rootMidi + interval
                playbackSequence.append((midi: midi, displayIndex: i))
            }
        }
        
        // Use pre-calculated absolute times for precise scheduling
        let baseTime = DispatchTime.now()
        let totalNotes = playbackSequence.count
        
        for (index, item) in playbackSequence.enumerated() {
            let noteStartTime = baseTime + .milliseconds(Int(Double(index) * beatDuration * 1000))
            let noteStopTime = baseTime + .milliseconds(Int((Double(index) + 0.8) * beatDuration * 1000))
            
            // Schedule highlight update
            DispatchQueue.main.asyncAfter(deadline: noteStartTime) { [self] in
                self.highlightedNoteIndex = item.displayIndex
            }
            
            // Schedule note on
            if settings.audioEnabled {
                DispatchQueue.main.asyncAfter(deadline: noteStartTime) { [self] in
                    audioManager.playNote(UInt8(item.midi), velocity: 80)
                }
                
                // Schedule note off
                DispatchQueue.main.asyncAfter(deadline: noteStopTime) { [self] in
                    audioManager.stopNote(UInt8(item.midi))
                }
            }
        }
        
        // After all notes played, clear highlight and show continue button
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
        
        // Play correct scale with highlighting
        playScaleWithHighlight(notes: question.correctNotes)
    }
    
    private func playScaleWithHighlight(notes: [Note]) {
        guard let question = scaleGame.currentQuestion else { return }
        
        let rootPitchClass = question.scale.root.pitchClass
        let rootMidi = question.scale.root.midiNumber
        let sortedNotes = sortNotesForScale(notes, rootPitchClass: rootPitchClass)
        let beatDuration: TimeInterval = 0.3  // 300ms per note = 200 BPM eighth notes
        
        // Build the full sequence: ascending + octave + descending
        var playbackSequence: [(midi: Int, displayIndex: Int)] = []
        
        // Ascending: play each note from root up (indices 0 to count-1)
        for (index, note) in sortedNotes.enumerated() {
            let interval = (note.pitchClass - rootPitchClass + 12) % 12
            let midi = rootMidi + interval
            playbackSequence.append((midi: midi, displayIndex: index))
        }
        
        // Octave (8va) - display index is sortedNotes.count
        playbackSequence.append((midi: rootMidi + 12, displayIndex: sortedNotes.count))
        
        // Descending: go back down, highlighting the same display indices in reverse
        for i in stride(from: sortedNotes.count - 1, through: 0, by: -1) {
            let note = sortedNotes[i]
            let interval = (note.pitchClass - rootPitchClass + 12) % 12
            let midi = rootMidi + interval
            playbackSequence.append((midi: midi, displayIndex: i))
        }
        
        // Use pre-calculated absolute times for precise scheduling
        var currentNoteIndex = 0
        let totalNotes = playbackSequence.count
        
        // Schedule all notes at once using DispatchQueue with absolute deadline
        let baseTime = DispatchTime.now()
        
        for (index, item) in playbackSequence.enumerated() {
            let noteStartTime = baseTime + .milliseconds(Int(Double(index) * beatDuration * 1000))
            let noteStopTime = baseTime + .milliseconds(Int((Double(index) + 0.8) * beatDuration * 1000))
            
            // Schedule highlight update
            DispatchQueue.main.asyncAfter(deadline: noteStartTime) { [self] in
                self.highlightedNoteIndex = item.displayIndex
            }
            
            // Schedule note on
            if settings.audioEnabled {
                DispatchQueue.main.asyncAfter(deadline: noteStartTime) { [self] in
                    audioManager.playNote(UInt8(item.midi), velocity: 80)
                }
                
                // Schedule note off
                DispatchQueue.main.asyncAfter(deadline: noteStopTime) { [self] in
                    audioManager.stopNote(UInt8(item.midi))
                }
            }
        }
        
        // Clear highlight after all notes
        let endTime = baseTime + .milliseconds(Int(Double(totalNotes) * beatDuration * 1000 + 200))
        DispatchQueue.main.asyncAfter(deadline: endTime) { [self] in
            self.highlightedNoteIndex = nil
        }
    }
    
    private func moveToNext() {
        selectedNotes.removeAll()
        selectedScaleType = nil  // Reset ear training selection
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

// MARK: - Scale Drill Results View

struct ScaleDrillResultsView: View {
    @EnvironmentObject var scaleGame: ScaleGame
    @Environment(\.colorScheme) var colorScheme
    let onNewQuiz: () -> Void
    
    private var playerStats: PlayerStats { PlayerStats.shared }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Results Header
                VStack(spacing: 12) {
                    Text(resultEmoji)
                        .font(.system(size: 80))
                    
                    Text(resultTitle)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text(resultSubtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top)
                
                // Score Card
                if let result = scaleGame.currentResult {
                    VStack(spacing: 16) {
                        // Score
                        HStack {
                            VStack {
                                Text("\(result.correctAnswers)/\(result.totalQuestions)")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(.teal)
                                Text("Score")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 1, height: 60)
                            
                            VStack {
                                Text("\(Int(result.accuracy * 100))%")
                                    .font(.system(size: 48, weight: .bold))
                                    .foregroundColor(accuracyColor(result.accuracy))
                                Text("Accuracy")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                        
                        Divider()
                        
                        // Time
                        HStack {
                            Image(systemName: "clock")
                            Text(formatTime(result.totalTime))
                            Spacer()
                            Text("(\(String(format: "%.1f", result.averageTimePerQuestion))s avg)")
                                .foregroundColor(.secondary)
                        }
                        .font(.subheadline)
                        
                        // XP Change
                        if scaleGame.lastRatingChange != 0 {
                            Divider()
                            
                            HStack {
                                Text("XP")
                                Spacer()
                                HStack(spacing: 4) {
                                    Text(scaleGame.lastRatingChange > 0 ? "+" : "")
                                    Text("\(scaleGame.lastRatingChange)")
                                }
                                .foregroundColor(scaleGame.lastRatingChange > 0 ? .green : .red)
                                .fontWeight(.semibold)
                            }
                            .font(.subheadline)
                            
                            // New rating
                            HStack {
                                Text("New Rating")
                                Spacer()
                                Text("\(playerStats.currentRating)")
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                            }
                            .font(.subheadline)
                        }
                        
                        // Rank Up Celebration
                        if scaleGame.didRankUp {
                            Divider()
                            
                            VStack(spacing: 8) {
                                Text("🎉 Rank Up! 🎉")
                                    .font(.headline)
                                    .foregroundColor(.yellow)
                                
                                HStack {
                                    if let previous = scaleGame.previousRank {
                                        Text(previous.emoji)
                                        Text(previous.title)
                                    }
                                    
                                    Image(systemName: "arrow.right")
                                        .foregroundColor(.yellow)
                                    
                                    Text(playerStats.currentRank.emoji)
                                    Text(playerStats.currentRank.title)
                                        .fontWeight(.bold)
                                }
                                .font(.subheadline)
                            }
                            .padding()
                            .background(Color.yellow.opacity(0.1))
                            .cornerRadius(12)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                // Action Buttons
                VStack(spacing: 12) {
                    Button(action: onNewQuiz) {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("New Quiz")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.teal)
                        .cornerRadius(12)
                    }
                    
                    NavigationLink(destination: ScaleScoreboardView().environmentObject(scaleGame)) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("View Scoreboard")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.orange, lineWidth: 1.5)
                        )
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var resultEmoji: String {
        guard let result = scaleGame.currentResult else { return "🎵" }
        let accuracy = result.accuracy
        if accuracy >= 1.0 { return "🏆" }
        if accuracy >= 0.9 { return "🌟" }
        if accuracy >= 0.7 { return "👍" }
        if accuracy >= 0.5 { return "📚" }
        return "💪"
    }
    
    private var resultTitle: String {
        guard let result = scaleGame.currentResult else { return "Quiz Complete" }
        let accuracy = result.accuracy
        if accuracy >= 1.0 { return "Perfect!" }
        if accuracy >= 0.9 { return "Excellent!" }
        if accuracy >= 0.7 { return "Good Job!" }
        if accuracy >= 0.5 { return "Keep Practicing" }
        return "Room to Grow"
    }
    
    private var resultSubtitle: String {
        guard let result = scaleGame.currentResult else { return "" }
        let accuracy = result.accuracy
        if accuracy >= 1.0 { return "You nailed every scale!" }
        if accuracy >= 0.9 { return "Almost perfect! You really know your scales." }
        if accuracy >= 0.7 { return "Solid knowledge. Keep building those scale patterns." }
        if accuracy >= 0.5 { return "You're making progress. Focus on the tricky ones." }
        return "Every expert was once a beginner. Keep at it!"
    }
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.9 { return .green }
        if accuracy >= 0.7 { return .yellow }
        if accuracy >= 0.5 { return .orange }
        return .red
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Scale Scoreboard View

struct ScaleScoreboardView: View {
    @EnvironmentObject var scaleGame: ScaleGame
    @State private var sortOption: SortOption = .accuracy
    
    enum SortOption: String, CaseIterable {
        case accuracy = "Accuracy"
        case time = "Time"
        case date = "Recent"
    }
    
    var sortedResults: [ScaleQuizResult] {
        switch sortOption {
        case .accuracy:
            return scaleGame.scoreboard.sorted { $0.accuracy > $1.accuracy }
        case .time:
            return scaleGame.scoreboard.sorted { $0.totalTime < $1.totalTime }
        case .date:
            return scaleGame.scoreboard.sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        VStack {
            // Sort Picker
            Picker("Sort by", selection: $sortOption) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.rawValue).tag(option)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if scaleGame.scoreboard.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "waveform.path")
                        .font(.system(size: 60))
                        .foregroundColor(.gray)
                    Text("No Results Yet")
                        .font(.headline)
                        .foregroundColor(.gray)
                    Text("Complete a scale quiz to see your scores here!")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                List {
                    ForEach(Array(sortedResults.enumerated()), id: \.element.id) { index, result in
                        ScaleScoreboardRow(result: result, rank: index + 1)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Scale Scoreboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ScaleScoreboardRow: View {
    let result: ScaleQuizResult
    let rank: Int
    
    var body: some View {
        HStack(spacing: 16) {
            // Rank
            Text(rankEmoji)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                // Score
                HStack {
                    Text("\(result.correctAnswers)/\(result.totalQuestions)")
                        .font(.headline)
                    Text("(\(Int(result.accuracy * 100))%)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Details
                HStack {
                    Text(result.difficulty.rawValue)
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(difficultyColor.opacity(0.2))
                        .foregroundColor(difficultyColor)
                        .cornerRadius(4)
                    
                    Text(formatTime(result.totalTime))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Date
            Text(result.date.formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
    
    private var rankEmoji: String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }
    
    private var difficultyColor: Color {
        switch result.difficulty {
        case .beginner: return .green
        case .intermediate: return .blue
        case .advanced: return .orange
        case .custom: return .purple
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

#Preview {
    NavigationStack {
        ScaleDrillView()
            .environmentObject(ScaleGame())
            .environmentObject(SettingsManager.shared)
    }
}
