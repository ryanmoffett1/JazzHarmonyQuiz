import SwiftUI

// MARK: - Interval Drill Results View

struct IntervalDrillResults: View {
    @EnvironmentObject var intervalGame: IntervalGame
    @Environment(\.dismiss) private var dismiss
    
    let onPlayAgain: () -> Void
    let onBackToSetup: () -> Void
    
    private var playerLevel: PlayerLevel {
        PlayerLevel(xp: PlayerStats.shared.currentRating)
    }
    
    private var accuracy: Double {
        guard intervalGame.totalQuestions > 0 else { return 0 }
        return Double(intervalGame.correctAnswers) / Double(intervalGame.totalQuestions) * 100
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Level Up Celebration
                if intervalGame.didRankUp, let prevLevel = intervalGame.previousLevel {
                    IntervalLevelUpView(previousLevel: prevLevel, newLevel: playerLevel.level)
                }
                
                // Score Circle
                scoreCircle
                
                // Rating Change
                ratingChangeView
                
                // Stats Grid
                statsGrid
                
                // Encouragement
                Text(encouragementText)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                
                // Action Buttons
                actionButtons
                
                Spacer(minLength: 20)
            }
        }
    }
    
    // MARK: - Score Circle
    
    private var scoreCircle: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                .frame(width: 150, height: 150)
            
            Circle()
                .trim(from: 0, to: accuracy / 100)
                .stroke(scoreColor, style: StrokeStyle(lineWidth: 20, lineCap: .round))
                .frame(width: 150, height: 150)
                .rotationEffect(.degrees(-90))
            
            VStack {
                Text("\(Int(accuracy))%")
                    .font(.system(size: 36, weight: .bold))
                Text("\(intervalGame.correctAnswers)/\(intervalGame.totalQuestions)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.top)
    }
    
    // MARK: - Rating Change
    
    private var ratingChangeView: some View {
        HStack {
            Text("Rating:")
                .foregroundColor(.secondary)
            Text(intervalGame.lastRatingChange >= 0 ? "+\(intervalGame.lastRatingChange)" : "\(intervalGame.lastRatingChange)")
                .font(.headline)
                .foregroundColor(intervalGame.lastRatingChange >= 0 ? .green : .red)
        }
    }
    
    // MARK: - Stats Grid
    
    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            IntervalStatCard(title: "Time", value: formatTime(intervalGame.elapsedTime), icon: "clock")
            IntervalStatCard(title: "Difficulty", value: intervalGame.selectedDifficulty.rawValue, icon: "speedometer")
            IntervalStatCard(title: "Avg/Question", value: formatTime(intervalGame.elapsedTime / Double(max(1, intervalGame.totalQuestions))), icon: "timer")
            IntervalStatCard(title: "Direction", value: intervalGame.selectedDirection.rawValue, icon: "arrow.up.arrow.down")
        }
        .padding(.horizontal)
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button(action: onPlayAgain) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Play Again")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color("BrassAccent"))
                .cornerRadius(12)
            }
            
            Button(action: onBackToSetup) {
                HStack {
                    Image(systemName: "slider.horizontal.3")
                    Text("Change Settings")
                }
                .font(.headline)
                .foregroundColor(Color("BrassAccent"))
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            
            Button(action: { dismiss() }) {
                HStack {
                    Image(systemName: "house")
                    Text("Back to Home")
                }
                .font(.headline)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity)
                .padding()
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Helper Properties
    
    private var scoreColor: Color {
        if accuracy >= 90 { return .green }
        if accuracy >= 70 { return .yellow }
        if accuracy >= 50 { return .orange }
        return .red
    }
    
    private var encouragementText: String {
        if accuracy >= 90 { return "🎉 Outstanding! You're an interval master!" }
        if accuracy >= 80 { return "🌟 Great job! Keep up the excellent work!" }
        if accuracy >= 70 { return "👍 Good effort! Practice makes perfect!" }
        if accuracy >= 50 { return "💪 Keep practicing! You're improving!" }
        return "📚 Don't give up! Try an easier difficulty."
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Stat Card

struct IntervalStatCard: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(ShedTheme.Colors.success)
            Text(value)
                .font(.headline)
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Level Up View

struct IntervalLevelUpView: View {
    let previousLevel: Int
    let newLevel: Int
    
    var body: some View {
        VStack(spacing: 12) {
            Text("🎊 Level Up! 🎊")
                .font(.title2)
                .fontWeight(.bold)
            
            HStack(spacing: 16) {
                Text("Level \(previousLevel)")
                    .font(.title3)
                    .foregroundColor(.secondary)
                
                Image(systemName: "arrow.right")
                    .foregroundColor(ShedTheme.Colors.success)
                
                Text("Level \(newLevel)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(ShedTheme.Colors.success)
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
        .padding(.horizontal)
    }
}

// MARK: - Scoreboard View

struct IntervalScoreboardView: View {
    @EnvironmentObject var intervalGame: IntervalGame
    @State private var sortBy: ScoreboardSort = .accuracy
    
    enum ScoreboardSort: String, CaseIterable {
        case accuracy = "Accuracy"
        case time = "Time"
        case date = "Recent"
    }
    
    private var sortedScores: [IntervalQuizResult] {
        switch sortBy {
        case .accuracy:
            return intervalGame.scoreboard.sorted { $0.accuracy > $1.accuracy }
        case .time:
            return intervalGame.scoreboard.sorted { $0.totalTime < $1.totalTime }
        case .date:
            return intervalGame.scoreboard.sorted { $0.date > $1.date }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Sort Picker
            Picker("Sort", selection: $sortBy) {
                ForEach(ScoreboardSort.allCases, id: \.self) { sort in
                    Text(sort.rawValue).tag(sort)
                }
            }
            .pickerStyle(.segmented)
            
            // Scores List
            if sortedScores.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "trophy")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("No scores yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Complete a quiz to see your scores here")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 40)
            } else {
                ForEach(Array(sortedScores.enumerated()), id: \.element.id) { index, score in
                    HStack {
                        // Rank
                        Text("#\(index + 1)")
                            .font(.headline)
                            .foregroundColor(index < 3 ? .yellow : .secondary)
                            .frame(width: 40)
                        
                        // Score Details
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\(score.correctAnswers)/\(score.totalQuestions)")
                                .font(.headline)
                            Text(score.difficulty.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Accuracy
                        Text("\(Int(score.accuracy))%")
                            .font(.headline)
                            .foregroundColor(score.accuracy >= 80 ? .green : .orange)
                        
                        // Time
                        Text(formatTime(score.totalTime))
                            .font(.caption.monospacedDigit())
                            .foregroundColor(.secondary)
                            .frame(width: 50)
                    }
                    .padding(.vertical, 8)
                    
                    if index < sortedScores.count - 1 {
                        Divider()
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// MARK: - Preview

#Preview {
    IntervalDrillResults(
        onPlayAgain: {},
        onBackToSetup: {}
    )
    .environmentObject(IntervalGame())
}
