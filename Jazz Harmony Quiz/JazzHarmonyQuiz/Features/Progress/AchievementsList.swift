import SwiftUI

/// Simplified achievements list per DESIGN.md Section 9.3.2
/// Professional presentation without excessive emoji
struct AchievementsList: View {
    @ObservedObject var playerProfile: PlayerProfile
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingAllAchievements = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                    .foregroundColor(settings.primaryText(for: colorScheme))
                
                Spacer()
                
                Text("\(playerProfile.unlockedAchievements.count)/\(AchievementType.allCases.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Show unlocked achievements
            if playerProfile.unlockedAchievements.isEmpty {
                emptyState
            } else {
                VStack(spacing: 8) {
                    let displayedAchievements = showingAllAchievements
                        ? playerProfile.unlockedAchievements
                        : Array(playerProfile.unlockedAchievements.suffix(5))
                    
                    ForEach(displayedAchievements.reversed()) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                    
                    if playerProfile.unlockedAchievements.count > 5 {
                        Button(action: { showingAllAchievements.toggle() }) {
                            Text(showingAllAchievements ? "Show Less" : "Show All (\(playerProfile.unlockedAchievements.count))")
                                .font(.subheadline)
                                .foregroundColor(Color("BrassAccent"))
                        }
                        .padding(.top, 4)
                    }
                }
            }
            
            // Next achievement hint
            if let nextAchievement = suggestedNextAchievement {
                Divider()
                    .padding(.vertical, 4)
                
                nextAchievementHint(nextAchievement)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settings.cardBackground(for: colorScheme))
        )
    }
    
    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            
            Text("Start practicing to earn achievements")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
    }
    
    private func nextAchievementHint(_ type: AchievementType) -> some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.right.circle")
                .foregroundColor(Color("BrassAccent"))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Next: \(type.title)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(settings.primaryText(for: colorScheme))
                
                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
    }
    
    private var suggestedNextAchievement: AchievementType? {
        // Find the next logical achievement based on progress
        let unlocked = Set(playerProfile.unlockedAchievements.map { $0.type })
        
        // Priority order for suggestions
        let priorityOrder: [AchievementType] = [
            .firstQuiz,
            .streak3,
            .hundredChords,
            .firstPerfect,
            .streak7,
            .accuracy90,
            .fiveHundredChords,
            .streak14,
            .thousandChords,
            .streak30
        ]
        
        return priorityOrder.first { !unlocked.contains($0) }
    }
}

/// Single achievement row
struct AchievementRow: View {
    let achievement: Achievement
    
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon (simplified - using system icons based on category)
            Image(systemName: iconForAchievement)
                .font(.title3)
                .foregroundColor(colorForAchievement)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(settings.primaryText(for: colorScheme))
                
                Text(achievement.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Date unlocked
            Text(formattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: achievement.unlockedDate)
    }
    
    private var iconForAchievement: String {
        switch achievement.type {
        case .firstQuiz, .hundredChords, .fiveHundredChords, .thousandChords:
            return "music.note"
        case .firstPerfect, .perfectStreak3, .perfectStreak5:
            return "star.fill"
        case .accuracy90:
            return "target"
        case .streak3, .streak7, .streak14, .streak30:
            return "flame.fill"
        case .rankGigging, .rankBebop, .rankWizard, .rankMaster:
            return "chart.line.uptrend.xyaxis"
        case .masterTriads, .masterSevenths:
            return "checkmark.seal.fill"
        case .allKeysPlayed:
            return "music.quarternote.3"
        }
    }
    
    private var colorForAchievement: Color {
        switch achievement.type {
        case .firstQuiz, .hundredChords, .fiveHundredChords, .thousandChords:
            return ShedTheme.Colors.brass
        case .firstPerfect, .perfectStreak3, .perfectStreak5:
            return ShedTheme.Colors.warning
        case .accuracy90:
            return ShedTheme.Colors.success
        case .streak3, .streak7, .streak14, .streak30:
            return ShedTheme.Colors.warning
        case .rankGigging, .rankBebop, .rankWizard, .rankMaster:
            return ShedTheme.Colors.brass
        case .masterTriads, .masterSevenths:
            return ShedTheme.Colors.brass
        case .allKeysPlayed:
            return ShedTheme.Colors.brass
        }
    }
}

// MARK: - Preview

#Preview {
    AchievementsList(playerProfile: PlayerProfile.shared)
        .environmentObject(SettingsManager.shared)
        .padding()
}
