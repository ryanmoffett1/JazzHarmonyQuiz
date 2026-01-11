import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with Title
                    VStack(spacing: 8) {
                        Text("Jazz Harmony Quiz")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("Master jazz chord theory")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top)
                    
                    // Stats Dashboard Card
                    StatsDashboardCard()
                    
                    // Quick Actions
                    QuickActionsSection(navigationPath: $navigationPath)
                    
                    // Main Drill Options
                    DrillOptionsSection(navigationPath: $navigationPath)
                    
                    // Progress Cards
                    ProgressCardsSection()
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationBarHidden(true)
            .navigationDestination(for: String.self) { destination in
                switch destination {
                case "chordDrill":
                    ChordDrillView()
                case "cadenceDrill":
                    CadenceDrillView()
                case "leaderboard":
                    LeaderboardView()
                case "dailyChallenge":
                    ChordDrillView(startDailyChallenge: true)
                case "quickPractice":
                    ChordDrillView(startQuickPractice: true)
                default:
                    EmptyView()
                }
            }
        }
    }
}

// MARK: - Stats Dashboard Card

struct StatsDashboardCard: View {
    @EnvironmentObject var quizGame: QuizGame
    
    var body: some View {
        VStack(spacing: 16) {
            // Rank and Rating Row
            HStack(spacing: 20) {
                // Rank Badge
                VStack(spacing: 4) {
                    Text(quizGame.stats.currentRank.emoji)
                        .font(.system(size: 44))
                    Text(quizGame.stats.currentRank.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 60)
                
                // Rating
                VStack(spacing: 4) {
                    Text("\(quizGame.stats.currentRating)")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.blue)
                    Text("Rating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    // Progress to next rank
                    if let pointsNeeded = quizGame.stats.pointsToNextRank {
                        Text("\(pointsNeeded) to next rank")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(maxWidth: .infinity)
                
                // Divider
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 1, height: 60)
                
                // Streak
                VStack(spacing: 4) {
                    HStack(spacing: 2) {
                        Text("🔥")
                            .font(.title)
                        Text("\(quizGame.stats.currentStreak)")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    Text("Day Streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
            }
            
            Divider()
            
            // Today's Stats
            let today = quizGame.stats.todaysPractice()
            HStack {
                TodayStatItem(
                    icon: "checkmark.circle",
                    value: "\(today.chords)",
                    label: "Chords Today"
                )
                
                Spacer()
                
                TodayStatItem(
                    icon: "percent",
                    value: today.chords > 0 ? "\(Int(Double(today.correct) / Double(today.chords) * 100))%" : "-",
                    label: "Accuracy"
                )
                
                Spacer()
                
                TodayStatItem(
                    icon: "clock",
                    value: formatTime(today.time),
                    label: "Time"
                )
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        }
        return "\(seconds)s"
    }
}

struct TodayStatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.blue)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Quick Actions Section

struct QuickActionsSection: View {
    @EnvironmentObject var quizGame: QuizGame
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(spacing: 12) {
            // Daily Challenge Button
            Button(action: {
                navigationPath.append("dailyChallenge")
            }) {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Challenge")
                            .font(.headline)
                        Text(quizGame.stats.isDailyChallengeCompletedToday ? "Completed! ✓" : "Same challenge for everyone")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    Spacer()
                    if quizGame.stats.dailyChallengeStreak > 0 {
                        Text("🔥 \(quizGame.stats.dailyChallengeStreak)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.white)
                .padding()
                .background(
                    LinearGradient(
                        colors: quizGame.stats.isDailyChallengeCompletedToday ? [.green, .mint] : [.orange, .red],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
            
            // Quick Practice Button
            Button(action: {
                navigationPath.append("quickPractice")
            }) {
                HStack {
                    Image(systemName: "bolt.fill")
                        .font(.title2)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Quick Practice")
                            .font(.headline)
                        Text("5 quick questions")
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
                        colors: [.green, .mint],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
            }
        }
    }
}

// MARK: - Drill Options Section

struct DrillOptionsSection: View {
    @Binding var navigationPath: NavigationPath
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Practice Modes")
                .font(.headline)
                .foregroundColor(.secondary)
            
            // Chord Drill
            Button(action: {
                navigationPath.append("chordDrill")
            }) {
                DrillOptionCard(
                    icon: "music.note",
                    title: "Chord Drill",
                    subtitle: "Practice spelling individual chords",
                    color: .blue
                )
            }
            
            // Cadence Mode
            Button(action: {
                navigationPath.append("cadenceDrill")
            }) {
                DrillOptionCard(
                    icon: "music.note.list",
                    title: "Cadence Mode",
                    subtitle: "Master ii-V-I progressions",
                    color: .purple
                )
            }
            
            // Leaderboard
            Button(action: {
                navigationPath.append("leaderboard")
            }) {
                DrillOptionCard(
                    icon: "trophy",
                    title: "Leaderboard",
                    subtitle: "View your best scores",
                    color: .orange
                )
            }
        }
    }
}

struct DrillOptionCard: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(color)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Progress Cards Section

struct ProgressCardsSection: View {
    @EnvironmentObject var quizGame: QuizGame
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("This Week")
                .font(.headline)
                .foregroundColor(.secondary)
            
            let weekStats = quizGame.stats.thisWeeksPractice()
            
            HStack(spacing: 12) {
                // Chords practiced
                ProgressCard(
                    title: "Chords",
                    value: "\(weekStats.chords)",
                    icon: "music.note",
                    color: .blue
                )
                
                // Days practiced
                ProgressCard(
                    title: "Days",
                    value: "\(weekStats.days)/7",
                    icon: "calendar",
                    color: .green
                )
                
                // Accuracy
                ProgressCard(
                    title: "Accuracy",
                    value: weekStats.chords > 0 ? "\(Int(Double(weekStats.correct) / Double(weekStats.chords) * 100))%" : "-",
                    icon: "target",
                    color: .orange
                )
            }
            
            // Weak areas hint
            let weakChords = quizGame.getWeakChordTypes(limit: 2)
            if !weakChords.isEmpty {
                HStack {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                    Text("Focus on: \(weakChords.map { $0.symbol }.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.yellow.opacity(0.1))
                .cornerRadius(8)
            }
        }
    }
}

struct ProgressCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
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

// MARK: - Legacy MainMenuView (kept for compatibility)

struct MainMenuView: View {
    @EnvironmentObject var quizGame: QuizGame
    @State private var numberOfQuestions = 10
    @State private var selectedDifficulty: ChordType.ChordDifficulty = .beginner
    @State private var selectedQuestionTypes: Set<QuestionType> = [.singleTone, .allTones]
    
    var body: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
        .environmentObject(QuizGame())
        .environmentObject(CadenceGame())
        .environmentObject(SettingsManager.shared)
}