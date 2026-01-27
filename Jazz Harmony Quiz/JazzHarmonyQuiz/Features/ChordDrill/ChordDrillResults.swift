import SwiftUI

// MARK: - Chord Drill Results View

/// Results screen displayed after completing a chord drill session
/// Shows score, XP gained, accuracy breakdown, and navigation options
/// Updated per DESIGN.md Section 9.3.1 to use PlayerLevel instead of Rank
struct ChordDrillResults: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    let onNewQuiz: () -> Void
    
    private var playerStats: PlayerStats { PlayerStats.shared }
    
    private var playerLevel: PlayerLevel {
        PlayerLevel(xp: playerStats.currentRating)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if let result = quizGame.currentResult {
                    // Level Up Celebration (if applicable)
                    if quizGame.didRankUp {
                        levelUpCelebration
                    }
                    
                    // Header
                    VStack(spacing: 8) {
                        Text("Quiz Complete!")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                    }
                    
                    // Score Display
                    scoreDisplay(result: result)
                    
                    // Streak info
                    if playerStats.currentStreak > 1 {
                        HStack {
                            Image(systemName: "flame.fill")
                            Text("\(playerStats.currentStreak) day streak!")
                        }
                        .font(.headline)
                        .foregroundColor(.orange)
                    }
                    
                    // Action Buttons
                    actionButtons
                }
            }
            .padding()
        }
    }
    
    // MARK: - Level Up Celebration
    
    private var levelUpCelebration: some View {
        VStack(spacing: 12) {
            Text("Level Up!")
                .font(.title)
                .fontWeight(.bold)
            
            HStack(spacing: 20) {
                if let prevLevel = quizGame.previousLevel {
                    VStack {
                        Text("\(prevLevel)")
                            .font(.system(size: 40, weight: .bold))
                            .foregroundColor(.secondary)
                        Text("Previous")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Image(systemName: "arrow.right")
                    .font(.title2)
                    .foregroundColor(.green)
                
                VStack {
                    Text("\(playerLevel.level)")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Level")
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            LinearGradient(
                colors: [.blue.opacity(0.2), .purple.opacity(0.2)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
    
    // MARK: - Score Display
    
    private func scoreDisplay(result: QuizResult) -> some View {
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
                    Text("Level \(playerLevel.level)")
                        .font(.title3)
                        .fontWeight(.bold)
                    Text("\(playerLevel.xpUntilNextLevel) to next")
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
                .background(Color.blue)
                .cornerRadius(12)
            }
        }
    }
    
    // MARK: - Helper Functions
    
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

// MARK: - Preview

#Preview {
    NavigationStack {
        ChordDrillResults(onNewQuiz: {})
            .environmentObject(QuizGame())
            .environmentObject(SettingsManager.shared)
    }
}
