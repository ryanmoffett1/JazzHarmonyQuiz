import SwiftUI

// MARK: - Main Content View

struct ContentView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var cadenceGame: CadenceGame
    @EnvironmentObject var settings: SettingsManager
    @State private var navigationPath = NavigationPath([String]())
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 20) {
                    // Compact Header
                    Text("Jazz Harmony Quiz")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                    
                    // Stats Dashboard Card (tap to view profile)
                    StatsDashboardCard(navigationPath: $navigationPath)
                    
                    // Spaced Repetition - Practice Due Card
                    practiceDueSection
                    
                    // Recommended Next Module
                    recommendedNextSection
                    
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
                case "harmonyDrill":
                    ProgressionDrillView()
                case "scaleDrill":
                    ScaleDrillView()
                case "intervalDrill":
                    IntervalDrillView()
                case "scoreboard":
                    ScoreboardView()
                case "profile":
                    PlayerProfileView()
                case "achievements":
                    EmptyView() // Placeholder for future achievements view
                case "curriculum":
                    CurriculumView()
                default:
                    EmptyView()
                }
            }
        }
    }
    
    // MARK: - Recommended Next Section
    
    @ViewBuilder
    private var recommendedNextSection: some View {
        let curriculumManager = CurriculumManager.shared
        
        if let nextModule = curriculumManager.recommendedNextModule {
            RecommendedNextCard(module: nextModule, navigationPath: $navigationPath)
        }
    }
    
    // MARK: - Practice Due Section
    
    @ViewBuilder
    private var practiceDueSection: some View {
        let srStore = SpacedRepetitionStore.shared
        let totalDue = srStore.totalDueCount()
        
        if totalDue > 0 {
            Button(action: {
                // Navigate to chord drill for practice
                navigationPath.append("chordDrill")
            }) {
                PracticeDueCard(srStore: srStore)
            }
            .buttonStyle(PlainButtonStyle())
        } else if srStore.statistics().totalItems > 0 {
            // Show stats even when nothing is due
            PracticeDueCard(srStore: srStore)
        }
    }
}

// MARK: - Stats Dashboard Card

struct StatsDashboardCard: View {
    @EnvironmentObject var quizGame: QuizGame
    @Binding var navigationPath: NavigationPath
    
    private var playerProfile: PlayerProfile { PlayerProfile.shared }
    
    var body: some View {
        Button(action: {
            navigationPath.append("profile")
        }) {
            VStack(spacing: 12) {
                // Main stats row - more compact
                HStack(spacing: 0) {
                    // Avatar + Name
                    VStack(spacing: 2) {
                        Text(playerProfile.avatar.rawValue)
                            .font(.system(size: 32))
                        Text(playerProfile.playerName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 50)
                    
                    // Rank
                    VStack(spacing: 2) {
                        Text(playerProfile.currentRank.emoji)
                            .font(.system(size: 28))
                        Text(playerProfile.currentRank.title)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                        Text("Rank")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 50)
                    
                    // XP - smaller
                    VStack(spacing: 2) {
                        Text("\(playerProfile.currentRating)")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.blue)
                        Text("XP")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    
                    // Divider
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 1, height: 50)
                    
                    // Streak - smaller
                    VStack(spacing: 2) {
                        HStack(spacing: 1) {
                            Text("🔥")
                                .font(.system(size: 18))
                            Text("\(playerProfile.currentStreak)")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.orange)
                        }
                        Text("Streak")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Progress to next rank - compact
                if let pointsNeeded = playerProfile.pointsToNextRank {
                    HStack(spacing: 4) {
                        ProgressView(value: progressToNextRank)
                            .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                            .frame(height: 4)
                        Text("\(pointsNeeded) to rank up")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .fixedSize()
                    }
                }
                
                Divider()
                
                // Today's Stats - compact
                let today = quizGame.stats.todaysPractice()
                HStack {
                    TodayStatItem(
                        icon: "checkmark.circle",
                        value: "\(today.chords)",
                        label: "Today"
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
                    
                    Spacer()
                    
                    // Chevron to indicate tappable
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var progressToNextRank: Double {
        guard let pointsNeeded = playerProfile.pointsToNextRank else { return 1.0 }
        let currentRankMin = playerProfile.currentRank.minRating
        let totalRange = Double(pointsNeeded) + Double(playerProfile.currentRating - currentRankMin)
        let progress = Double(playerProfile.currentRating - currentRankMin)
        return progress / totalRange
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
        VStack(spacing: 2) {
            HStack(spacing: 2) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(.blue)
                Text(value)
                    .font(.caption)
                    .fontWeight(.semibold)
            }
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Drill Options Section

struct DrillOptionsSection: View {
    @EnvironmentObject var quizGame: QuizGame
    @Binding var navigationPath: NavigationPath
    
    private var playerProfile: PlayerProfile { PlayerProfile.shared }
    
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
            
            // Harmony Practice
            Button(action: {
                navigationPath.append("harmonyDrill")
            }) {
                DrillOptionCard(
                    icon: "music.note.list",
                    title: "Harmony Practice",
                    subtitle: "Master progressions, cadences, and jazz harmony",
                    color: .purple
                )
            }
            
            // Scale Drill
            Button(action: {
                navigationPath.append("scaleDrill")
            }) {
                DrillOptionCard(
                    icon: "waveform.path",
                    title: "Scale Drill",
                    subtitle: "Learn jazz scales and modes",
                    color: .teal
                )
            }
            
            // Interval Drill
            Button(action: {
                navigationPath.append("intervalDrill")
            }) {
                DrillOptionCard(
                    icon: "arrow.up.arrow.down",
                    title: "Interval Drill",
                    subtitle: "Master musical intervals",
                    color: .green
                )
            }
            
            // Achievements
            Button(action: {
                navigationPath.append("achievements")
            }) {
                DrillOptionCard(
                    icon: "star.fill",
                    title: "Achievements",
                    subtitle: "\(playerProfile.unlockedAchievements.count)/\(AchievementType.allCases.count) unlocked",
                    color: .yellow
                )
            }
            
            // Settings
            Button(action: {
                navigationPath.append("settings")
            }) {
                DrillOptionCard(
                    icon: "gear",
                    title: "Settings",
                    subtitle: "Customize your experience",
                    color: .gray
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
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("Practice Suggestion")
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                    Text("Based on your recent scores, try focusing on \(weakChords.map { $0.symbol }.joined(separator: " and ")) chords to improve your accuracy.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity, alignment: .leading)
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

// MARK: - Achievements View

struct AchievementsView: View {
    @EnvironmentObject var quizGame: QuizGame
    @Environment(\.colorScheme) var colorScheme
    
    private var playerProfile: PlayerProfile { PlayerProfile.shared }
    
    var unlockedAchievements: [Achievement] {
        playerProfile.unlockedAchievements.sorted { $0.unlockedDate > $1.unlockedDate }
    }
    
    var lockedAchievements: [AchievementType] {
        AchievementType.allCases.filter { type in
            !playerProfile.hasAchievement(type)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Text("🏆 Achievements")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(unlockedAchievements.count) of \(AchievementType.allCases.count) unlocked")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Progress bar
                    ProgressView(value: Double(unlockedAchievements.count), total: Double(AchievementType.allCases.count))
                        .progressViewStyle(LinearProgressViewStyle(tint: .yellow))
                        .frame(width: 200)
                }
                .padding(.top)
                
                // Unlocked Achievements
                if !unlockedAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Unlocked")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ForEach(unlockedAchievements) { achievement in
                            AchievementCard(achievement: achievement, isUnlocked: true)
                        }
                    }
                }
                
                // Locked Achievements
                if !lockedAchievements.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Locked")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ForEach(lockedAchievements, id: \.self) { type in
                            LockedAchievementCard(type: type)
                        }
                    }
                }
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .navigationTitle("Achievements")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(achievement.emoji)
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(achievement.title)
                    .font(.headline)
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("Unlocked \(achievement.unlockedDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct LockedAchievementCard: View {
    let type: AchievementType
    
    var body: some View {
        HStack(spacing: 16) {
            Text("🔒")
                .font(.system(size: 40))
                .frame(width: 60, height: 60)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(type.title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(0.6)
    }
}

// MARK: - Recommended Next Card

struct RecommendedNextCard: View {
    let module: CurriculumModule
    @Binding var navigationPath: NavigationPath
    @StateObject private var curriculumManager = CurriculumManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("🎯 Recommended Next")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: {
                    navigationPath.append("curriculum")
                }) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.blue)
                }
            }
            
            HStack(spacing: 12) {
                // Module emoji
                Text(module.emoji)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(module.title)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    Text(module.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    HStack(spacing: 8) {
                        Label(module.pathway.rawValue, systemImage: "map")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Label("Level \(module.level)", systemImage: "chart.bar")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Button(action: startModule) {
                    VStack(spacing: 4) {
                        Image(systemName: "play.circle.fill")
                            .font(.title2)
                        Text("Start")
                            .font(.caption2)
                    }
                    .foregroundColor(.blue)
                }
            }
            
            // Progress bar if module is in progress
            if let progress = curriculumManager.moduleProgress[module.id] {
                let percentage = curriculumManager.getModuleProgressPercentage(module)
                ProgressView(value: percentage / 100.0)
                    .progressViewStyle(LinearProgressViewStyle(tint: pathwayColor))
                
                HStack {
                    Text("\(Int(percentage))% Complete")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(progress.attempts) attempts")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: pathwayColor.opacity(0.2), radius: 8, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(pathwayColor, lineWidth: 2)
        )
        .padding(.horizontal)
    }
    
    private var pathwayColor: Color {
        switch module.pathway {
        case .harmonyFoundations: return .blue
        case .functionalHarmony: return .green
        case .earTraining: return .orange
        case .advancedTopics: return .purple
        }
    }
    
    private func startModule() {
        // Set this module as active in the curriculum manager
        curriculumManager.setActiveModule(module.id)
        
        // Navigate to the appropriate drill mode based on module.mode
        let destination: String
        switch module.mode {
        case .chords:
            destination = "chordDrill"
        case .scales:
            destination = "scaleDrill"
        case .cadences:
            destination = "harmonyDrill"
        case .intervals:
            destination = "intervalDrill"
        case .progressions:
            destination = "progressionDrill"
        }
        
        // Apply module configuration to SettingsManager
        applyModuleConfiguration()
        
        // Navigate to the drill
        navigationPath.append(destination)
    }
    
    private func applyModuleConfiguration() {
        // Configuration will be applied by the drill views when they start
        // For now, just store the active module - the drill views will read
        // the configuration from CurriculumManager.shared.activeModule
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
