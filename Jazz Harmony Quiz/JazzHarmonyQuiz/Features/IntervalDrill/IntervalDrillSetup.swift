import SwiftUI

// MARK: - Interval Drill Setup View

struct IntervalDrillSetup: View {
    @EnvironmentObject var intervalGame: IntervalGame
    
    @Binding var numberOfQuestions: Int
    @Binding var selectedDifficulty: IntervalDifficulty
    @Binding var selectedQuestionTypes: Set<IntervalQuestionType>
    @Binding var selectedDirection: IntervalDirection
    @Binding var selectedKeyDifficulty: KeyDifficulty
    let onStart: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerView
                
                // Settings Cards
                VStack(spacing: 16) {
                    difficultyCard
                    questionsCard
                    questionTypesCard
                    directionCard
                    keyDifficultyCard
                }
                .padding(.horizontal)
                
                // Start Button
                startButton
                
                // Scoreboard Preview
                if !intervalGame.scoreboard.isEmpty {
                    IntervalScoreboardPreview()
                        .padding(.horizontal)
                }
                
                Spacer(minLength: 20)
            }
        }
    }
    
    // MARK: - Header
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.system(size: 50))
                .foregroundColor(ShedTheme.Colors.success)
            Text("Interval Drill")
                .font(.title)
                .fontWeight(.bold)
            Text("Master musical intervals")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.top)
    }
    
    // MARK: - Settings Cards
    
    private var difficultyCard: some View {
        IntervalSettingsCard(title: "Difficulty", icon: "speedometer") {
            Picker("Difficulty", selection: $selectedDifficulty) {
                ForEach(IntervalDifficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var questionsCard: some View {
        IntervalSettingsCard(title: "Questions", icon: "number") {
            VStack {
                Slider(value: Binding(
                    get: { Double(numberOfQuestions) },
                    set: { numberOfQuestions = Int($0) }
                ), in: 5...20, step: 1)
                Text("\(numberOfQuestions) questions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private var questionTypesCard: some View {
        IntervalSettingsCard(title: "Question Types", icon: "questionmark.circle") {
            VStack(spacing: 8) {
                ForEach(IntervalQuestionType.allCases, id: \.self) { type in
                    Button(action: {
                        toggleQuestionType(type)
                    }) {
                        HStack {
                            Image(systemName: type.icon)
                                .frame(width: 24)
                            Text(type.rawValue)
                            Spacer()
                            if selectedQuestionTypes.contains(type) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(ShedTheme.Colors.success)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    private var directionCard: some View {
        IntervalSettingsCard(title: "Direction", icon: "arrow.up.arrow.down") {
            Picker("Direction", selection: $selectedDirection) {
                Text("↑").tag(IntervalDirection.ascending)
                Text("↓").tag(IntervalDirection.descending)
                Text("↑↓").tag(IntervalDirection.both)
            }
            .pickerStyle(.segmented)
        }
    }
    
    private var keyDifficultyCard: some View {
        IntervalSettingsCard(title: "Keys", icon: "key") {
            Picker("Key Difficulty", selection: $selectedKeyDifficulty) {
                ForEach(KeyDifficulty.allCases, id: \.self) { keyDiff in
                    Text(keyDiff.rawValue).tag(keyDiff)
                }
            }
            .pickerStyle(.segmented)
        }
    }
    
    // MARK: - Start Button
    
    private var startButton: some View {
        Button(action: onStart) {
            HStack {
                Image(systemName: "play.fill")
                Text("Start Quiz")
            }
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(selectedQuestionTypes.isEmpty ? Color.gray : Color("BrassAccent"))
            .cornerRadius(12)
        }
        .disabled(selectedQuestionTypes.isEmpty)
        .padding(.horizontal)
    }
    
    // MARK: - Helper Methods
    
    private func toggleQuestionType(_ type: IntervalQuestionType) {
        if selectedQuestionTypes.contains(type) {
            if selectedQuestionTypes.count > 1 {
                selectedQuestionTypes.remove(type)
            }
        } else {
            selectedQuestionTypes.insert(type)
        }
    }
}

// MARK: - Settings Card

struct IntervalSettingsCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(ShedTheme.Colors.success)
                Text(title)
                    .font(.headline)
            }
            content
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Scoreboard Preview

struct IntervalScoreboardPreview: View {
    @EnvironmentObject var intervalGame: IntervalGame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy")
                    .foregroundColor(ShedTheme.Colors.warning)
                Text("Recent Scores")
                    .font(.headline)
            }
            
            ForEach(intervalGame.scoreboard.prefix(3)) { score in
                HStack {
                    Text("\(score.difficulty.rawValue)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(score.correctAnswers)/\(score.totalQuestions)")
                        .font(.caption.monospacedDigit())
                    Text("(\(Int(score.accuracy))%)")
                        .font(.caption)
                        .foregroundColor(score.accuracy >= 80 ? .green : .orange)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    IntervalDrillSetup(
        numberOfQuestions: .constant(10),
        selectedDifficulty: .constant(.beginner),
        selectedQuestionTypes: .constant([.buildInterval]),
        selectedDirection: .constant(.ascending),
        selectedKeyDifficulty: .constant(.easy),
        onStart: {}
    )
    .environmentObject(IntervalGame())
}
