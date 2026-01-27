import SwiftUI

// MARK: - Scale Drill Setup View

/// Setup view for configuring scale drill parameters
/// Includes question count, difficulty, question types, and scale type filters
struct ScaleDrillSetup: View {
    @EnvironmentObject var scaleGame: ScaleGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
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
                headerView
                
                // Options Card
                optionsCard
                
                // Start Button
                startButton
                
                // Scoreboard Link
                scoreboardLink
                
                Spacer()
            }
            .padding()
        }
    }
    
    private var playerLevel: PlayerLevel {
        PlayerLevel(xp: playerStats.currentRating)
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text("Scale Drill Setup")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                HStack(spacing: 4) {
                    Text("Level \(playerLevel.level)")
                        .fontWeight(.semibold)
                    Text("•")
                    Text("\(playerStats.currentRating) XP")
                }
                .font(.subheadline)
                .foregroundColor(ShedTheme.Colors.brass)
                
                if playerStats.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                        Text("\(playerStats.currentStreak)")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(ShedTheme.Colors.brass)
                }
            }
        }
    }
    
    // MARK: - Options Card
    
    private var optionsCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Number of Questions
            questionCountPicker
            
            // Difficulty Level
            difficultyPicker
            
            // Key Difficulty
            keyDifficultyPicker
            
            // Question Types
            questionTypesPicker
            
            // Scale Type Filter (only for Custom difficulty)
            if selectedDifficulty == .custom {
                scaleTypeFilter
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Question Count Picker
    
    private var questionCountPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Number of Questions")
                .font(.headline)
            
            Picker("Questions", selection: $numberOfQuestions) {
                ForEach([5, 10, 15, 20, 25], id: \.self) { count in
                    Text("\(count)").tag(count)
                }
            }
            .shedSegmentedPicker()
        }
    }
    
    // MARK: - Difficulty Picker
    
    private var difficultyPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Scale Difficulty")
                .font(.headline)
            
            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(ScaleType.ScaleDifficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .shedSegmentedPicker()
            
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
    }
    
    // MARK: - Key Difficulty Picker
    
    private var keyDifficultyPicker: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Key Difficulty")
                .font(.headline)
            
            Picker("Keys", selection: $selectedKeyDifficulty) {
                ForEach(KeyDifficulty.allCases, id: \.self) { keyDiff in
                    Text(keyDiff.rawValue).tag(keyDiff)
                }
            }
            .shedSegmentedPicker()
            
            Text(selectedKeyDifficulty.description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Question Types Picker
    
    private var questionTypesPicker: some View {
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
                                .foregroundColor(selectedQuestionTypes.contains(questionType) ? ShedTheme.Colors.brass : .gray)
                            
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
    }
    
    // MARK: - Scale Type Filter
    
    private var scaleTypeFilter: some View {
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
                .background(ShedTheme.Colors.surface)
                .cornerRadius(8)
            }
            
            if showScaleTypeFilter {
                ScaleTypeFilterView(selectedSymbols: $selectedScaleSymbols)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: showScaleTypeFilter)
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
    
    // MARK: - Start Button
    
    private var startButton: some View {
        Button(action: onStartQuiz) {
            Text("Start Quiz")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BrassAccent"))
                .cornerRadius(12)
        }
        .disabled(selectedQuestionTypes.isEmpty)
    }
    
    // MARK: - Scoreboard Link
    
    private var scoreboardLink: some View {
        NavigationLink(destination: ScaleScoreboardView().environmentObject(scaleGame)) {
            HStack {
                Image(systemName: "trophy.fill")
                Text("View Scale Scoreboard")
            }
            .font(.subheadline)
            .foregroundColor(ShedTheme.Colors.warning)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(ShedTheme.Colors.warning.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(ShedTheme.Colors.warning, lineWidth: 1.5)
            )
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
                .foregroundColor(ShedTheme.Colors.brass)
                
                Spacer()
                
                Button("Clear All") {
                    selectedSymbols.removeAll()
                }
                .font(.caption)
                .foregroundColor(ShedTheme.Colors.danger)
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
        .background(ShedTheme.Colors.surface)
        .cornerRadius(8)
    }
}

// MARK: - Scale Type Chip

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
                .background(isSelected ? ShedTheme.Colors.brass : Color(.systemGray4))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(16)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ScaleDrillSetup(
            numberOfQuestions: .constant(10),
            selectedDifficulty: .constant(.beginner),
            selectedQuestionTypes: .constant([.allDegrees]),
            selectedKeyDifficulty: .constant(.all),
            selectedScaleSymbols: .constant([]),
            onStartQuiz: {}
        )
        .environmentObject(ScaleGame())
        .environmentObject(SettingsManager.shared)
    }
}
