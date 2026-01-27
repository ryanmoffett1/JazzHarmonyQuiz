import SwiftUI

/// Key statistics summary card
/// Per DESIGN.md Section 9.2.2
struct StatsOverview: View {
    @ObservedObject var playerProfile: PlayerProfile
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .foregroundColor(settings.primaryText(for: colorScheme))
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ProgressStatCard(
                    title: "Total Questions",
                    value: "\(playerProfile.totalQuestionsAnswered)",
                    icon: "questionmark.circle",
                    color: ShedTheme.Colors.brass
                )
                
                ProgressStatCard(
                    title: "Accuracy",
                    value: String(format: "%.1f%%", playerProfile.overallAccuracy * 100),
                    icon: "target",
                    color: accuracyColor
                )
                
                ProgressStatCard(
                    title: "Practice Time",
                    value: formatTime(playerProfile.totalPracticeTime),
                    icon: "clock",
                    color: ShedTheme.Colors.brass
                )
                
                ProgressStatCard(
                    title: "Sessions",
                    value: "\(totalSessions)",
                    icon: "music.note.list",
                    color: ShedTheme.Colors.success
                )
                
                ProgressStatCard(
                    title: "Peak XP",
                    value: "\(playerProfile.peakRating)",
                    icon: "star",
                    color: ShedTheme.Colors.warning
                )
                
                ProgressStatCard(
                    title: "Achievements",
                    value: "\(playerProfile.unlockedAchievements.count)",
                    icon: "trophy",
                    color: ShedTheme.Colors.brass
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settings.cardBackground(for: colorScheme))
        )
    }
    
    private var accuracyColor: Color {
        if playerProfile.overallAccuracy >= 0.9 { return ShedTheme.Colors.success }
        if playerProfile.overallAccuracy >= 0.7 { return ShedTheme.Colors.warning }
        return ShedTheme.Colors.danger
    }
    
    private var totalSessions: Int {
        playerProfile.modeStats.values.reduce(0) { $0 + $1.sessionsCompleted }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let hours = Int(time) / 3600
        let minutes = (Int(time) % 3600) / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

/// Single stat card in the grid
struct ProgressStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title3)
                
                Spacer()
            }
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(settings.primaryText(for: colorScheme))
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// MARK: - Preview

#Preview {
    StatsOverview(playerProfile: PlayerProfile.shared)
        .environmentObject(SettingsManager.shared)
        .padding()
}
