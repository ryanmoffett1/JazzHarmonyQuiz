import SwiftUI

/// Progress tab view showing statistics, key breakdown, and achievements
/// Per DESIGN.md Section 9
struct ProgressTabView: View {
    @ObservedObject var playerProfile = PlayerProfile.shared
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Level & XP Overview
                    LevelOverview(playerProfile: playerProfile)
                        .padding(.horizontal)
                    
                    // Stats Overview
                    StatsOverview(playerProfile: playerProfile)
                        .padding(.horizontal)
                    
                    // Category Breakdown
                    CategoryBreakdown(playerProfile: playerProfile)
                        .padding(.horizontal)
                    
                    // Achievements List
                    AchievementsList(playerProfile: playerProfile)
                        .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Progress")
            .background(settings.backgroundColor(for: colorScheme))
        }
    }
}

// MARK: - Level Overview

/// Shows current level based on XP (replaces old Rank display)
struct LevelOverview: View {
    @ObservedObject var playerProfile: PlayerProfile
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    private var level: PlayerLevel {
        PlayerLevel(xp: playerProfile.currentRating)
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Level badge
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Level \(level.level)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(settings.primaryText(for: colorScheme))
                    
                    Text("\(playerProfile.currentRating) XP")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Streak info
                VStack(alignment: .trailing, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "flame.fill")
                            .foregroundColor(.orange)
                        Text("\(playerProfile.currentStreak) day streak")
                            .fontWeight(.medium)
                    }
                    .font(.subheadline)
                    
                    if playerProfile.longestStreak > playerProfile.currentStreak {
                        Text("Best: \(playerProfile.longestStreak) days")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Progress to next level
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Progress to Level \(level.level + 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(level.xpUntilNextLevel) XP needed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                ProgressView(value: level.progressToNextLevel)
                    .tint(Color("BrassAccent"))
                    .frame(height: 8)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settings.cardBackground(for: colorScheme))
        )
    }
}

// MARK: - Preview

#Preview {
    ProgressTabView()
        .environmentObject(SettingsManager.shared)
}
