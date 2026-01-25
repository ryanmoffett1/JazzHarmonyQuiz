import SwiftUI

// MARK: - Scale Drill Results View

/// Results view shown after completing a scale drill session
/// Displays score, accuracy, time, XP changes, and scoreboard access
struct ScaleDrillResults: View {
    @EnvironmentObject var scaleGame: ScaleGame
    @Environment(\.colorScheme) var colorScheme
    let onNewQuiz: () -> Void
    
    private var playerStats: PlayerStats { PlayerStats.shared }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Results Header
                resultsHeader
                
                // Score Card
                if let result = scaleGame.currentResult {
                    scoreCard(result: result)
                }
                
                // Action Buttons
                actionButtons
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Results Header
    
    private var resultsHeader: some View {
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
    }
    
    // MARK: - Score Card
    
    @ViewBuilder
    private func scoreCard(result: ScaleQuizResult) -> some View {
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
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
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
    }
    
    // MARK: - Computed Properties
    
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
                emptyStateView
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
    
    private var emptyStateView: some View {
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
    }
}

// MARK: - Scale Scoreboard Row

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

// MARK: - Preview

#Preview {
    NavigationStack {
        ScaleDrillResults(onNewQuiz: {})
            .environmentObject(ScaleGame())
            .environmentObject(SettingsManager.shared)
    }
}
