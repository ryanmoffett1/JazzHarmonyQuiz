import SwiftUI
import UIKit

// MARK: - Haptic Feedback Helper (shared with CadenceDrillView)
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

struct ChordDrillView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @State private var selectedNotes: Set<Note> = []
    @State private var selectedChordType: ChordType? = nil  // For ear training answers
    @State private var viewState: ViewState = .setup
    @State private var numberOfQuestions: Int
    @State private var selectedDifficulty: ChordType.ChordDifficulty
    @State private var selectedQuestionTypes: Set<QuestionType>
    @State private var selectedKeyDifficulty: KeyDifficulty = .all
    @State private var selectedChordSymbols: Set<String> = []  // Empty = all chord types
    @State private var showingResults = false
    @State private var showingFeedback = false
    
    // For direct launch modes
    private var startDailyChallenge: Bool = false
    private var startQuickPractice: Bool = false
    
    enum ViewState {
        case setup
        case active
        case results
    }
    
    init(numberOfQuestions: Int = 10,
         selectedDifficulty: ChordType.ChordDifficulty = .beginner,
         selectedQuestionTypes: Set<QuestionType> = [.singleTone, .allTones],
         startDailyChallenge: Bool = false,
         startQuickPractice: Bool = false) {
        self._numberOfQuestions = State(initialValue: numberOfQuestions)
        self._selectedDifficulty = State(initialValue: selectedDifficulty)
        self._selectedQuestionTypes = State(initialValue: selectedQuestionTypes)
        self.startDailyChallenge = startDailyChallenge
        self.startQuickPractice = startQuickPractice
    }
    
    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                QuizSetupView(
                    numberOfQuestions: $numberOfQuestions,
                    selectedDifficulty: $selectedDifficulty,
                    selectedQuestionTypes: $selectedQuestionTypes,
                    selectedKeyDifficulty: $selectedKeyDifficulty,
                    selectedChordSymbols: $selectedChordSymbols,
                    onStartQuiz: startQuiz,
                    onStartDailyChallenge: startDailyChallengeQuiz
                )
            case .active:
                ActiveQuizView(selectedNotes: $selectedNotes, selectedChordType: $selectedChordType, showingFeedback: $showingFeedback, viewState: $viewState)
            case .results:
                ChordDrillResultsView(onNewQuiz: {
                    // Reset quiz and show setup
                    quizGame.resetQuizState()
                    viewState = .setup
                    selectedNotes = []
                    showingFeedback = false
                })
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if quizGame.isQuizActive {
                    Button("Quit") {
                        quitQuiz()
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                if quizGame.isQuizActive {
                    VStack {
                        HStack(spacing: 4) {
                            Text("Question \(quizGame.currentQuestionNumber) of \(quizGame.totalQuestions)")
                                .font(.headline)
                            if quizGame.isDailyChallenge {
                                Text("📅")
                            }
                        }
                        ProgressView(value: quizGame.progress)
                            .frame(width: 200)
                    }
                }
            }
        }
        .onChange(of: quizGame.isQuizCompleted) { oldValue, newValue in
            if newValue && !oldValue {
                viewState = .results
            }
        }
        .onAppear {
            // Handle direct launch modes
            if startDailyChallenge {
                startDailyChallengeQuiz()
            } else if startQuickPractice {
                startQuickPracticeQuiz()
            }
        }
    }
    
    private func startQuiz() {
        // Clear all previous state
        selectedNotes = []
        showingFeedback = false
        viewState = .active
        
        // Set filtering options before starting
        quizGame.selectedKeyDifficulty = selectedKeyDifficulty
        quizGame.selectedChordSymbols = selectedChordSymbols
        
        // Start the new quiz
        quizGame.startNewQuiz(
            numberOfQuestions: numberOfQuestions,
            difficulty: selectedDifficulty,
            questionTypes: selectedQuestionTypes
        )
    }
    
    private func startDailyChallengeQuiz() {
        selectedNotes = []
        showingFeedback = false
        viewState = .active
        quizGame.startDailyChallenge()
    }
    
    private func startQuickPracticeQuiz() {
        selectedNotes = []
        showingFeedback = false
        viewState = .active
        quizGame.startQuickPractice()
    }
    
    private func quitQuiz() {
        viewState = .setup
        quizGame.resetQuizState()
        selectedNotes = []
        showingFeedback = false
    }
}

struct QuizSetupView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @State private var showingSettings = false
    @State private var showChordTypeFilter = false
    @Binding var numberOfQuestions: Int
    @Binding var selectedDifficulty: ChordType.ChordDifficulty
    @Binding var selectedQuestionTypes: Set<QuestionType>
    @Binding var selectedKeyDifficulty: KeyDifficulty
    @Binding var selectedChordSymbols: Set<String>
    let onStartQuiz: () -> Void
    let onStartDailyChallenge: () -> Void
    
    private var playerStats: PlayerStats { PlayerStats.shared }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with rank and streak
                VStack(spacing: 8) {
                    Text("Chord Drill Setup")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    // Stats row
                    HStack(spacing: 20) {
                        // Rank
                        HStack(spacing: 4) {
                            Text(playerStats.currentRank.emoji)
                            Text("\(playerStats.currentRating)")
                                .fontWeight(.semibold)
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        
                        // Streak
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
                
                // Daily Challenge Button
                Button(action: onStartDailyChallenge) {
                    HStack {
                        Image(systemName: "calendar.badge.clock")
                        VStack(alignment: .leading) {
                            Text("Daily Challenge")
                                .font(.headline)
                            Text(playerStats.isDailyChallengeCompletedToday ? "Completed! ✓" : "Same challenge for everyone!")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: playerStats.isDailyChallengeCompletedToday ? [.green, .mint] : [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(12)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Number of Questions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Number of Questions")
                            .font(.headline)
                        
                        Picker("Questions", selection: $numberOfQuestions) {
                            ForEach([1, 5, 10, 15, 20, 25, 30], id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Difficulty Level
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Chord Difficulty")
                            .font(.headline)
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(ChordType.ChordDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue).tag(difficulty)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
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
                        
                        ForEach(QuestionType.allCases, id: \.self) { questionType in
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
                                            .foregroundColor(selectedQuestionTypes.contains(questionType) ? .blue : .gray)

                                        Image(systemName: questionType.icon)
                                            .foregroundColor(.green)
                                            .frame(width: 24)

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
                    
                    // Chord Type Filter
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Chord Types")
                                .font(.headline)
                            Spacer()
                            Text(selectedChordSymbols.isEmpty ? "All" : "\(selectedChordSymbols.count) selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Button(action: { showChordTypeFilter.toggle() }) {
                            HStack {
                                Image(systemName: "slider.horizontal.3")
                                Text(selectedChordSymbols.isEmpty ? "Filter by chord type..." : chordFilterSummary)
                                    .lineLimit(1)
                                Spacer()
                                Image(systemName: showChordTypeFilter ? "chevron.up" : "chevron.down")
                            }
                            .font(.subheadline)
                            .foregroundColor(.primary)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(8)
                        }
                        
                        if showChordTypeFilter {
                            ChordTypeFilterView(selectedSymbols: $selectedChordSymbols)
                                .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                    }
                    .animation(.easeInOut(duration: 0.2), value: showChordTypeFilter)
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
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .disabled(selectedQuestionTypes.isEmpty)
                
                // Leaderboard Button
                NavigationLink(destination: ScoreboardView().environmentObject(quizGame)) {
                    HStack {
                        Image(systemName: "trophy.fill")
                        Text("View Scoreboard")
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

                // Settings Button
                Button(action: {
                    showingSettings = true
                }) {
                    HStack {
                        Image(systemName: "gear")
                        Text("Settings")
                    }
                    .font(.subheadline)
                    .foregroundColor(.purple)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.purple.opacity(0.1))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.purple, lineWidth: 1.5)
                    )
                }
                .sheet(isPresented: $showingSettings) {
                    SettingsView()
                        .environmentObject(settings)
                }

                Spacer()
            }
            .padding()
        }
    }
    
    private var chordFilterSummary: String {
        if selectedChordSymbols.isEmpty {
            return "All chord types"
        } else if selectedChordSymbols.count <= 3 {
            return selectedChordSymbols.sorted().map { $0.isEmpty ? "Major" : $0 }.joined(separator: ", ")
        } else {
            return "\(selectedChordSymbols.count) types selected"
        }
    }
}

// MARK: - Chord Type Filter View

struct ChordTypeFilterView: View {
    @Binding var selectedSymbols: Set<String>
    let database = JazzChordDatabase.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Quick actions
            HStack {
                Button("Select All") {
                    selectedSymbols = Set(database.getAllChordSymbols())
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
            
            // Categories
            ForEach(JazzChordDatabase.ChordCategory.allCases, id: \.self) { category in
                VStack(alignment: .leading, spacing: 8) {
                    Text(category.rawValue)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(getSymbolsForCategory(category), id: \.self) { symbol in
                            ChordTypeChip(
                                symbol: symbol,
                                isSelected: selectedSymbols.contains(symbol),
                                onTap: {
                                    if selectedSymbols.contains(symbol) {
                                        selectedSymbols.remove(symbol)
                                    } else {
                                        selectedSymbols.insert(symbol)
                                    }
                                }
                            )
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private func getSymbolsForCategory(_ category: JazzChordDatabase.ChordCategory) -> [String] {
        // Get symbols that exist in the database for this category
        return database.chordTypes
            .filter { category.chordSymbols.contains($0.symbol) }
            .map { $0.symbol }
    }
}

struct ChordTypeChip: View {
    let symbol: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var displayName: String {
        symbol.isEmpty ? "Maj" : symbol
    }
    
    var body: some View {
        Button(action: onTap) {
            Text(displayName)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color(.systemGray5))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

struct ActiveQuizView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Binding var selectedNotes: Set<Note>
    @Binding var selectedChordType: ChordType?
    @Binding var showingFeedback: Bool
    @Binding var viewState: ChordDrillView.ViewState
    @State private var isCorrect = false
    @State private var currentQuestionForFeedback: QuizQuestion?
    @State private var correctAnswerForFeedback: [Note] = []
    @State private var isLastQuestion = false
    @State private var feedbackPhase: FeedbackPhase = .showingUserAnswer
    @State private var userAnswerForFeedback: [Note] = []
    
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
                if question.questionType == .earTraining {
                    // Ear Training Display
                    VStack(spacing: 16) {
                        Image(systemName: "ear.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.blue)

                        Text("Listen to the chord")
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
                    Button(action: { playCurrentChord() }) {
                        HStack {
                            Image(systemName: "speaker.wave.2.fill")
                            Text("Replay Chord")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
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

                // Answer Input Area
                if question.questionType == .earTraining {
                    // Chord Type Picker for ear training
                    VStack(spacing: 8) {
                        Text("Select the chord quality")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        ChordTypePicker(
                            difficulty: quizGame.selectedDifficulty,
                            selectedChordType: $selectedChordType,
                            correctChord: showingFeedback ? question.chord.type : nil,
                            disabled: showingFeedback
                        )
                        .padding(.horizontal)
                    }
                } else {
                    // Piano Keyboard
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

                        // Use FlowLayout for wrapping with dynamic sizing
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
                }  // End of piano keyboard else block

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
            // Auto-play chord for ear training questions
            if let question = quizGame.currentQuestion,
               question.questionType == .earTraining {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    playCurrentChord()
                }
            }
        }
        .onAppear {
            // Play on initial appear if ear training question
            if let question = quizGame.currentQuestion,
               question.questionType == .earTraining {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    playCurrentChord()
                }
            }
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
            
            Spacer()
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
                    
                    VStack(spacing: 2) {
                        Text(note.name)
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
        case .earTraining:
            return "Identify the chord quality by ear"
        }
    }

    private var canSubmit: Bool {
        guard let question = quizGame.currentQuestion else { return false }

        switch question.questionType {
        case .earTraining:
            return selectedChordType != nil
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

    private func submitAnswer() {
        guard let question = quizGame.currentQuestion else { return }

        let userAnswer: [Note]
        let correctAnswer = question.correctAnswer

        // Handle answer based on question type
        if question.questionType == .earTraining {
            // For ear training, check chord type selection
            isCorrect = selectedChordType?.symbol == question.chord.type.symbol
            userAnswer = question.chord.chordTones  // Use chord tones for quiz game
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

            // For ear training, play correct answer; for visual, play user's answer
            if settings.audioEnabled {
                if question.questionType == .earTraining {
                    AudioManager.shared.playChord(correctAnswer, duration: 1.0)
                } else if !userAnswer.isEmpty {
                    AudioManager.shared.playChord(userAnswer, duration: 1.0)
                }
            }
        }

        // Show feedback
        showingFeedback = true
    }
    
    private func isAnswerCorrect(userAnswer: [Note], question: QuizQuestion) -> Bool {
        let correctAnswer = question.correctAnswer
        
        // Helper function to normalize MIDI number to pitch class (0-11)
        func pitchClass(_ midiNumber: Int) -> Int {
            return ((midiNumber - 60) % 12 + 12) % 12
        }
        
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
            quizGame.submitAnswer(userAnswerForFeedback)
        }
        
        // Reset state for next question
        selectedNotes.removeAll()
        userAnswerForFeedback = []
        feedbackPhase = .showingUserAnswer
        showingFeedback = false
        
        // The viewState will automatically update to .results when isQuizCompleted changes
        // via the onChange handler in ChordDrillView
    }
    
    private func formatAnswerWithLabels(_ notes: [Note]) -> String {
        guard let question = currentQuestionForFeedback else {
            return notes.map { $0.name }.joined(separator: ", ")
        }
        
        // Determine tonality preference based on the chord root
        let preferSharps = question.chord.root.isSharp || ["B", "E", "A", "D", "G"].contains(question.chord.root.name)
        
        // Keep notes in chord tone order (Root, 3rd, 5th, 7th, etc.) - don't sort by pitch
        let sortedNotes = notes
        return sortedNotes.map { note in
            // Convert note to match the chord's tonality
            let displayNote = Note.noteFromMidi(note.midiNumber, preferSharps: preferSharps) ?? note
            let label = getChordToneLabel(for: note, in: question)
            return "\(displayNote.name) (\(label))"
        }.joined(separator: ", ")
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

// MARK: - Chord Drill Results View

struct ChordDrillResultsView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    let onNewQuiz: () -> Void
    
    private var playerStats: PlayerStats { PlayerStats.shared }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let result = quizGame.currentResult {
                    // Rank Up Celebration (if applicable)
                    if quizGame.didRankUp {
                        VStack(spacing: 12) {
                            Text("🎉 Rank Up! 🎉")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            HStack(spacing: 20) {
                                if let prev = quizGame.previousRank {
                                    VStack {
                                        Text(prev.emoji)
                                            .font(.system(size: 40))
                                        Text(prev.title)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                                
                                Image(systemName: "arrow.right")
                                    .font(.title2)
                                    .foregroundColor(.green)
                                
                                VStack {
                                    Text(playerStats.currentRank.emoji)
                                        .font(.system(size: 50))
                                    Text(playerStats.currentRank.title)
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.yellow.opacity(0.3), .orange.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .cornerRadius(16)
                    }
                    
                    // Header
                    VStack(spacing: 8) {
                        Text("Quiz Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        if quizGame.isDailyChallenge {
                            HStack {
                                Image(systemName: "calendar.badge.clock")
                                Text("Daily Challenge")
                            }
                            .font(.subheadline)
                            .foregroundColor(.orange)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.orange.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // Score Display
                    VStack(spacing: 16) {
                        // Accuracy
                        Text("\(Int(result.accuracy * 100))%")
                            .font(.system(size: 72, weight: .bold))
                            .foregroundColor(accuracyColor(result.accuracy))
                        
                        Text("\(result.correctAnswers) of \(result.totalQuestions) correct")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        // XP Change
                        HStack(spacing: 16) {
                            VStack {
                                HStack(spacing: 4) {
                                    Text(quizGame.lastRatingChange >= 0 ? "+" : "")
                                    Text("\(quizGame.lastRatingChange)")
                                }
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(quizGame.lastRatingChange >= 0 ? .green : .red)
                                
                                Text("XP")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack {
                                Text("\(playerStats.currentRating)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                
                                Text("Total")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack {
                                Text(playerStats.currentRank.emoji)
                                    .font(.title)
                                Text(playerStats.currentRank.title)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        
                        // Time
                        HStack {
                            Image(systemName: "clock")
                            Text(formatTime(result.totalTime))
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    
                    // Streak info
                    if playerStats.currentStreak > 1 {
                        HStack {
                            Text("🔥")
                            Text("\(playerStats.currentStreak) day streak!")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
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
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: ScoreboardView()) {
                            HStack {
                                Image(systemName: "trophy")
                                Text("View Scoreboard")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func accuracyColor(_ accuracy: Double) -> Color {
        if accuracy >= 0.9 { return .green }
        if accuracy >= 0.7 { return .orange }
        return .red
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Chord Type Picker

struct ChordTypePicker: View {
    let difficulty: ChordType.ChordDifficulty
    @Binding var selectedChordType: ChordType?
    let correctChord: ChordType?
    let disabled: Bool

    private var chordTypes: [ChordType] {
        JazzChordDatabase.shared.chordTypes.filter { $0.difficulty == difficulty }
    }

    var body: some View {
        LazyVGrid(columns: [
            GridItem(.adaptive(minimum: 80), spacing: 8)
        ], spacing: 8) {
            ForEach(chordTypes) { chordType in
                Button(action: {
                    if !disabled {
                        selectedChordType = chordType
                        ChordDrillHaptics.light()
                    }
                }) {
                    VStack(spacing: 2) {
                        Text(chordType.symbol)
                            .font(.headline)
                        Text(chordType.name)
                            .font(.system(size: 9))
                            .lineLimit(1)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 4)
                    .frame(maxWidth: .infinity)
                    .background(backgroundColor(for: chordType))
                    .foregroundColor(foregroundColor(for: chordType))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(borderColor(for: chordType), lineWidth: 2)
                    )
                }
                .disabled(disabled)
            }
        }
    }

    private func backgroundColor(for chordType: ChordType) -> Color {
        if let correct = correctChord {
            if chordType.symbol == correct.symbol {
                return .green.opacity(0.3)
            } else if chordType == selectedChordType {
                return .red.opacity(0.3)
            }
        }

        if chordType == selectedChordType {
            return .green.opacity(0.2)
        }
        return Color(.systemGray6)
    }

    private func foregroundColor(for chordType: ChordType) -> Color {
        if let correct = correctChord {
            if chordType.symbol == correct.symbol {
                return .green
            } else if chordType == selectedChordType {
                return .red
            }
        }

        if chordType == selectedChordType {
            return .green
        }
        return .primary
    }

    private func borderColor(for chordType: ChordType) -> Color {
        if let correct = correctChord {
            if chordType.symbol == correct.symbol {
                return .green
            } else if chordType == selectedChordType {
                return .red
            }
        }

        if chordType == selectedChordType {
            return .green
        }
        return .clear
    }
}

// MARK: - Preview
#Preview {
    ChordDrillView()
        .environmentObject(QuizGame())
        .environmentObject(SettingsManager.shared)
}
