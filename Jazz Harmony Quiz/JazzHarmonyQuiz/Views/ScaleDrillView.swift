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
                    
                    // Scale Type Filter
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("Scale Types")
                                .font(.headline)
                            Spacer()
                            Text(selectedScaleSymbols.isEmpty ? "All" : "\(selectedScaleSymbols.count) selected")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
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
                
                // Scale Leaderboard Button
                NavigationLink(destination: ScaleLeaderboardView().environmentObject(scaleGame)) {
                    HStack {
                        Image(systemName: "trophy.fill")
                        Text("View Scale Leaderboard")
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
    
    private let audioManager = AudioManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            if let question = scaleGame.currentQuestion {
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
                
                // Question Text
                Text(question.questionText)
                    .font(.title3)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                // Selected Notes Display
                if !selectedNotes.isEmpty {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(selectedNotes).sorted { $0.midiNumber < $1.midiNumber }, id: \.midiNumber) { note in
                                Text(note.name)
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
                
                // Feedback Message
                if showingFeedback {
                    HStack {
                        Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                        Text(feedbackMessage)
                    }
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .red)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(isCorrect ? Color.green.opacity(0.1) : Color.red.opacity(0.1))
                    )
                    .transition(.scale.combined(with: .opacity))
                }
                
                Spacer()
                
                // Piano Keyboard
                PianoKeyboard(selectedNotes: $selectedNotes, isInteractive: !hasSubmitted)
                    .frame(height: 180)
                    .padding(.horizontal, 8)
                
                // Action Buttons
                HStack(spacing: 16) {
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
                    .disabled(hasSubmitted)
                    
                    if hasSubmitted {
                        // Play Scale Button (after correct answer)
                        if isCorrect {
                            Button(action: {
                                audioManager.playScaleObject(question.scale, bpm: 160)
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
                        }
                        
                        // Next Button
                        Button(action: {
                            moveToNext()
                        }) {
                            Text(scaleGame.currentQuestionIndex < scaleGame.totalQuestions - 1 ? "Next" : "Finish")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.teal)
                                .cornerRadius(12)
                        }
                    } else {
                        // Submit Button
                        Button(action: {
                            submitAnswer()
                        }) {
                            Text("Submit")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(selectedNotes.isEmpty ? Color.gray : Color.teal)
                                .cornerRadius(12)
                        }
                        .disabled(selectedNotes.isEmpty)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showingFeedback)
    }
    
    private func submitAnswer() {
        guard let question = scaleGame.currentQuestion else { return }
        
        isCorrect = scaleGame.submitAnswer(selectedNotes)
        hasSubmitted = true
        showingFeedback = true
        
        if isCorrect {
            feedbackMessage = "Correct! 🎉"
            ScaleDrillHaptics.success()
            if settings.playChordOnCorrect {
                audioManager.playScaleObject(question.scale, bpm: 160)
            }
        } else {
            let correctNoteNames = question.correctNotes.map { $0.name }.joined(separator: ", ")
            feedbackMessage = "Incorrect. The answer is: \(correctNoteNames)"
            ScaleDrillHaptics.error()
            if settings.audioEnabled {
                audioManager.playErrorSound()
            }
        }
    }
    
    private func moveToNext() {
        selectedNotes.removeAll()
        showingFeedback = false
        hasSubmitted = false
        feedbackMessage = ""
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
                        
                        // Rating Change
                        if scaleGame.lastRatingChange != 0 {
                            Divider()
                            
                            HStack {
                                Text("Rating")
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
                    
                    NavigationLink(destination: ScaleLeaderboardView().environmentObject(scaleGame)) {
                        HStack {
                            Image(systemName: "trophy.fill")
                            Text("View Leaderboard")
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

// MARK: - Scale Leaderboard View

struct ScaleLeaderboardView: View {
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
            return scaleGame.leaderboard.sorted { $0.accuracy > $1.accuracy }
        case .time:
            return scaleGame.leaderboard.sorted { $0.totalTime < $1.totalTime }
        case .date:
            return scaleGame.leaderboard.sorted { $0.date > $1.date }
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
            
            if scaleGame.leaderboard.isEmpty {
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
                        ScaleLeaderboardRow(result: result, rank: index + 1)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Scale Leaderboard")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ScaleLeaderboardRow: View {
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
        case .expert: return .red
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
