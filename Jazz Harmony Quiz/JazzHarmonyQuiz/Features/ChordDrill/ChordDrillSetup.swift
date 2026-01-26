import SwiftUI

// MARK: - Chord Drill Setup View

/// Setup screen for configuring a chord drill session
/// Contains quick start presets and custom configuration options
struct ChordDrillSetup: View {
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
    
    private var playerStats: PlayerStats { PlayerStats.shared }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with rank and streak
                headerView
                
                // Quick Start Presets
                quickStartSection
                
                // Custom Configuration
                customConfigSection
                
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
                    SettingsView(showDoneButton: true)
                        .environmentObject(settings)
                }

                Spacer()
            }
            .padding()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
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
    }
    
    // MARK: - Quick Start Section
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.headline)
            
            HStack(spacing: 12) {
                ChordQuickStartButton(
                    title: "Basic Triads",
                    subtitle: "Major, minor, dim, aug",
                    icon: "music.note",
                    color: .green
                ) {
                    applyPreset(.basicTriads)
                    onStartQuiz()
                }
                
                ChordQuickStartButton(
                    title: "7th Chords",
                    subtitle: "Dom7, maj7, min7",
                    icon: "music.note.list",
                    color: .blue
                ) {
                    applyPreset(.seventhChords)
                    onStartQuiz()
                }
                
                ChordQuickStartButton(
                    title: "Full Workout",
                    subtitle: "All chord types",
                    icon: "flame.fill",
                    color: .orange
                ) {
                    applyPreset(.fullWorkout)
                    onStartQuiz()
                }
            }
        }
    }
    
    private func applyPreset(_ preset: ChordDrillPreset) {
        let config = ChordDrillConfig.fromPreset(preset)
        // Note: We intentionally do NOT override numberOfQuestions
        // This allows users to customize the question count before using a preset
        selectedDifficulty = config.difficulty
        selectedQuestionTypes = config.questionTypes
        selectedKeyDifficulty = config.keyDifficulty
        selectedChordSymbols = config.chordTypes
    }
    
    // MARK: - Custom Configuration Section
    
    private var customConfigSection: some View {
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

// MARK: - Chord Quick Start Button (Compact vertical style for HStack layout)

fileprivate struct ChordQuickStartButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(color.opacity(0.3), lineWidth: 1)
            )
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

// MARK: - Chord Type Chip

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

// MARK: - Preview

#Preview {
    NavigationStack {
        ChordDrillSetup(
            numberOfQuestions: .constant(10),
            selectedDifficulty: .constant(.beginner),
            selectedQuestionTypes: .constant([.allTones]),
            selectedKeyDifficulty: .constant(.all),
            selectedChordSymbols: .constant([]),
            onStartQuiz: {}
        )
        .environmentObject(QuizGame())
        .environmentObject(SettingsManager.shared)
    }
}
