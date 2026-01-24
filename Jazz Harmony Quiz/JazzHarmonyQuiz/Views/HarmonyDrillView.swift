import SwiftUI

struct HarmonyDrillView: View {
    @StateObject private var game = ProgressionGame()
    @EnvironmentObject var settings: SettingsManager
    @State private var viewState: ViewState = .setup
    
    enum ViewState {
        case setup
        case active
        case results
    }
    
    var body: some View {
        ZStack {
            switch viewState {
            case .setup:
                HarmonySetupView(onStartQuiz: { config in
                    startQuiz(config)
                })
                .environmentObject(game)
                
            case .active:
                HarmonyActiveView(viewState: $viewState)
                    .environmentObject(game)
                    .environmentObject(settings)
                
            case .results:
                HarmonyResultsView(onNewQuiz: {
                    game.resetQuizState()
                    viewState = .setup
                })
                .environmentObject(game)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if game.isQuizActive {
                    Button("Quit") {
                        game.resetQuizState()
                        viewState = .setup
                    }
                }
            }
            
            ToolbarItem(placement: .principal) {
                if game.isQuizActive {
                    VStack {
                        HStack(spacing: 4) {
                            Text("Question \(game.currentQuestionIndex + 1) of \(game.totalQuestions)")
                                .font(.headline)
                        }
                        ProgressView(value: Double(game.currentQuestionIndex) / Double(game.totalQuestions))
                            .frame(width: 200)
                    }
                }
            }
        }
        .onChange(of: game.isQuizCompleted) { _, newValue in
            if newValue {
                viewState = .results
            }
        }
    }
    
    private func startQuiz(_ config: QuizConfig) {
        game.startNewQuiz(
            numberOfQuestions: config.numberOfQuestions,
            category: config.category,
            difficulty: config.difficulty,
            keyDifficulty: config.keyDifficulty,
            useMixedCategories: config.useMixedCategories,
            selectedCategories: config.selectedCategories
        )
        viewState = .active
    }
    
    struct QuizConfig {
        let numberOfQuestions: Int
        let category: ProgressionCategory
        let difficulty: ProgressionDifficulty
        let keyDifficulty: KeyDifficulty
        let useMixedCategories: Bool
        let selectedCategories: Set<ProgressionCategory>
    }
}

// MARK: - Setup View

struct HarmonySetupView: View {
    @EnvironmentObject var game: ProgressionGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @State private var numberOfQuestions: Int = 5
    @State private var selectedDifficulty: ProgressionDifficulty = .beginner
    @State private var selectedCategory: ProgressionCategory = .cadences
    @State private var selectedKeyDifficulty: KeyDifficulty = .easy
    @State private var useMixedCategories: Bool = false
    @State private var selectedCategories: Set<ProgressionCategory> = [.cadences]
    
    let onStartQuiz: (HarmonyDrillView.QuizConfig) -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("Harmony Practice")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Master cadences, progressions, and jazz harmony")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Number of Questions
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Number of Questions")
                            .font(.headline)
                        
                        Picker("Questions", selection: $numberOfQuestions) {
                            ForEach([1, 3, 5, 10], id: \.self) { count in
                                Text("\(count)").tag(count)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Difficulty Level
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Difficulty")
                            .font(.headline)
                        
                        Picker("Difficulty", selection: $selectedDifficulty) {
                            ForEach(ProgressionDifficulty.allCases, id: \.self) { difficulty in
                                Text(difficulty.rawValue).tag(difficulty)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                    
                    // Category Selection
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Progression Type")
                            .font(.headline)
                        
                        if !useMixedCategories {
                            Picker("Category", selection: $selectedCategory) {
                                ForEach(ProgressionCategory.allCases, id: \.self) { category in
                                    Label(category.rawValue, systemImage: category.icon).tag(category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        } else {
                            ForEach(ProgressionCategory.allCases, id: \.self) { category in
                                Button(action: {
                                    if selectedCategories.contains(category) {
                                        selectedCategories.remove(category)
                                    } else {
                                        selectedCategories.insert(category)
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: selectedCategories.contains(category) ? "checkmark.square.fill" : "square")
                                            .foregroundColor(selectedCategories.contains(category) ? .blue : .gray)
                                        Label(category.rawValue, systemImage: category.icon)
                                        Spacer()
                                    }
                                }
                                .foregroundColor(.primary)
                            }
                        }
                        
                        Toggle("Mix Multiple Types", isOn: $useMixedCategories)
                            .onChange(of: useMixedCategories) { _, newValue in
                                if newValue {
                                    selectedCategories.insert(selectedCategory)
                                }
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
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Start Button
                Button(action: {
                    let config = HarmonyDrillView.QuizConfig(
                        numberOfQuestions: numberOfQuestions,
                        category: selectedCategory,
                        difficulty: selectedDifficulty,
                        keyDifficulty: selectedKeyDifficulty,
                        useMixedCategories: useMixedCategories,
                        selectedCategories: selectedCategories
                    )
                    onStartQuiz(config)
                }) {
                    Text("Start Practice")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .disabled(useMixedCategories && selectedCategories.isEmpty)
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Active View

struct HarmonyActiveView: View {
    @EnvironmentObject var game: ProgressionGame
    @EnvironmentObject var settings: SettingsManager
    @Binding var viewState: HarmonyDrillView.ViewState
    @State private var userChords: [Chord?] = []
    @State private var selectedSlotIndex = 0
    @State private var showingAnswer = false
    
    var body: some View {
        VStack(spacing: 20) {
            if let question = game.currentQuestion {
                // Header
                VStack(spacing: 8) {
                    Text("\(question.progression.template.name)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Question \(game.currentQuestionIndex + 1) of \(game.questions.count)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Key: \(question.progression.key.name)")
                        .font(.headline)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.2))
                        .cornerRadius(8)
                }
                .padding(.top)
                
                Spacer()
                
                // Chord slots
                VStack(spacing: 16) {
                    Text("Spell the progression:")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Array(question.progression.chords.enumerated()), id: \.offset) { index, chord in
                                ChordSlotView(
                                    index: index,
                                    symbol: question.progression.template.chords[safe: index]?.romanNumeral ?? "?",
                                    userChord: userChords[safe: index] ?? nil,
                                    isSelected: selectedSlotIndex == index,
                                    showingAnswer: showingAnswer,
                                    correctChord: chord
                                ) {
                                    selectedSlotIndex = index
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
                
                // Chord builder
                if !showingAnswer {
                    ChordBuilderView(
                        selectedChord: Binding(
                            get: { userChords[safe: selectedSlotIndex] ?? nil },
                            set: { newChord in
                                if userChords.count <= selectedSlotIndex {
                                    userChords.append(contentsOf: Array(repeating: nil, count: selectedSlotIndex - userChords.count + 1))
                                }
                                userChords[selectedSlotIndex] = newChord
                            }
                        ),
                        key: question.progression.key
                    )
                }
                
                Spacer()
                
                // Action buttons
                HStack(spacing: 16) {
                    if !showingAnswer {
                        Button(action: clearCurrentSlot) {
                            Label("Clear", systemImage: "trash")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .disabled(userChords[safe: selectedSlotIndex] == nil)
                        
                        Button(action: submitAnswer) {
                            Text("Submit")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(!allSlotsFilled())
                    } else {
                        Button(action: nextQuestion) {
                            Text("Continue")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            initializeSlots()
        }
        .onChange(of: game.currentQuestionIndex) { _ in
            initializeSlots()
        }
    }
    
    private func initializeSlots() {
        guard let question = game.currentQuestion else { return }
        userChords = Array(repeating: nil, count: question.progression.chords.count)
        selectedSlotIndex = 0
        showingAnswer = false
    }
    
    private func clearCurrentSlot() {
        if userChords.indices.contains(selectedSlotIndex) {
            userChords[selectedSlotIndex] = nil
        }
    }
    
    private func allSlotsFilled() -> Bool {
        guard let question = game.currentQuestion else { return false }
        return userChords.count == question.progression.chords.count &&
               userChords.allSatisfy { $0 != nil }
    }
    
    private func submitAnswer() {
        showingAnswer = true
    }
    
    private func nextQuestion() {
        guard let question = game.currentQuestion else { return }
        
        let userAnswer = userChords.compactMap { $0 }
        let isCorrect = zip(userAnswer, question.progression.chords).allSatisfy { userChord, correctChord in
            Set(userChord.chordTones.map { $0.pitchClass }) == Set(correctChord.chordTones.map { $0.pitchClass })
        }
        
        game.submitAnswer(userChords.map { chord in chord?.chordTones ?? [] })
        showingAnswer = false
    }
}

// Helper view for chord slots
struct ChordSlotView: View {
    let index: Int
    let symbol: String
    let userChord: Chord?
    let isSelected: Bool
    let showingAnswer: Bool
    let correctChord: Chord
    let onTap: () -> Void
    
    var isCorrect: Bool? {
        guard showingAnswer, let userChord = userChord else {
            return nil
        }
        return Set(userChord.chordTones.map { $0.pitchClass }) == Set(correctChord.chordTones.map { $0.pitchClass })
    }
    
    var body: some View {
        VStack(spacing: 4) {
            Text(symbol)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(userChord?.displayName ?? "?")
                .font(.title3)
                .fontWeight(isSelected ? .bold : .regular)
                .frame(width: 80, height: 60)
                .background(backgroundColor)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: isSelected ? 3 : 1)
                )
        }
        .onTapGesture(perform: onTap)
    }
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? Color.green.opacity(0.2) : Color.red.opacity(0.2)
        }
        return userChord != nil ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05)
    }
    
    private var borderColor: Color {
        if let isCorrect = isCorrect {
            return isCorrect ? .green : .red
        }
        return isSelected ? .blue : .gray.opacity(0.3)
    }
}

// Simple chord builder
struct ChordBuilderView: View {
    @Binding var selectedChord: Chord?
    let key: Note
    @State private var selectedRoot: Note = Note.allNotes.first { $0.name == "C" }!
    @State private var selectedQuality: String = "maj7"
    
    // Get notes appropriate for the current key (no enharmonic duplicates)
    private var availableNotes: [Note] {
        let preferSharps = key.isSharp || ["B", "E", "A", "D", "G"].contains(key.name)
        var seen: Set<Int> = []
        var notes: [Note] = []
        
        for note in Note.allNotes where note.midiNumber >= 60 && note.midiNumber < 72 {
            let pitchClass = note.pitchClass
            if !seen.contains(pitchClass) {
                seen.insert(pitchClass)
                notes.append(note)
            } else if seen.contains(pitchClass) {
                // For enharmonic notes, replace if this one matches our preference
                if let index = notes.firstIndex(where: { $0.pitchClass == pitchClass }) {
                    let existing = notes[index]
                    // Replace with preferred spelling
                    if preferSharps && note.isSharp && !existing.isSharp {
                        notes[index] = note
                    } else if !preferSharps && !note.isSharp && existing.isSharp {
                        notes[index] = note
                    }
                }
            }
        }
        
        return notes.sorted { $0.midiNumber < $1.midiNumber }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Build Chord")
                .font(.headline)
            
            HStack(spacing: 20) {
                // Root picker
                VStack {
                    Text("Root")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Root", selection: $selectedRoot) {
                        ForEach(availableNotes, id: \.self) { note in
                            Text(note.name).tag(note)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 100, height: 120)
                }
                
                // Quality picker
                VStack {
                    Text("Quality")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Quality", selection: $selectedQuality) {
                        ForEach([
                            "maj7", "m7", "7", "m7b5", "dim7", "maj6", "m6",
                            "7b9", "7#9", "7b5", "7#5", "maj7#5"
                        ], id: \.self) { quality in
                            Text(quality).tag(quality)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(width: 120, height: 120)
                }
            }
            
            Button(action: setChord) {
                Text("Set Chord: \(selectedRoot.name)\(selectedQuality)")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .padding(.horizontal)
        }
        .padding()
        .background(Color(uiColor: .systemBackground))
        .cornerRadius(12)
        .shadow(radius: 4)
        .padding()
    }
    
    private func setChord() {
        let database = JazzChordDatabase.shared
        if let chordType = database.chordTypes.first(where: { $0.symbol == selectedQuality }) {
            selectedChord = Chord(root: selectedRoot, chordType: chordType)
        }
    }
}

// MARK: - Results View

struct HarmonyResultsView: View {
    @EnvironmentObject var game: ProgressionGame
    let onNewQuiz: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let result = game.currentResult {
                    // Header
                    VStack(spacing: 8) {
                        Text("Quiz Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Great work!")
                            .font(.headline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Score card
                    VStack(spacing: 16) {
                        HStack(spacing: 40) {
                            StatBox(
                                label: "Accuracy",
                                value: "\(Int(result.accuracy * 100))%",
                                color: result.accuracy >= 0.8 ? .green : result.accuracy >= 0.6 ? .orange : .red
                            )
                            
                            StatBox(
                                label: "Correct",
                                value: "\(result.correctAnswers)/\(result.totalQuestions)",
                                color: .blue
                            )
                        }
                    }
                    .padding()
                    
                    // Per-question breakdown
                    if !result.questions.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Question Breakdown")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            ForEach(Array(result.questions.enumerated()), id: \.offset) { index, question in
                                HStack {
                                    Text("Q\(index + 1): \(question.progression.template.name)")
                                        .font(.subheadline)
                                    
                                    Spacer()
                                    
                                    let isCorrect = result.isCorrect[question.id] ?? false
                                    Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                        .foregroundColor(isCorrect ? .green : .red)
                                }
                                .padding()
                                .background(Color(uiColor: .secondarySystemBackground))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                    
                    Spacer()
                    
                    // Action button
                    Button(action: onNewQuiz) {
                        Text("New Quiz")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding()
                }
            }
        }
    }
}

// Stat box helper view
struct StatBox: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(color)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(minWidth: 120)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        HarmonyDrillView()
            .environmentObject(SettingsManager.shared)
    }
}
