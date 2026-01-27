import SwiftUI

/// Progress tab view showing statistics, key breakdown, and achievements
/// Per DESIGN.md Section 9, using ShedTheme for flat modern UI
struct ProgressTabView: View {
    @ObservedObject var playerProfile = PlayerProfile.shared
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ShedTheme.Space.l) {
                    // Level & XP Overview
                    LevelOverview(playerProfile: playerProfile)
                    
                    // Stats Overview
                    StatsOverview(playerProfile: playerProfile)
                    
                    // Category Breakdown
                    CategoryBreakdown(playerProfile: playerProfile)
                    
                    // Achievements List
                    AchievementsList(playerProfile: playerProfile)
                }
                .padding(.horizontal, ShedTheme.Space.m)
                .padding(.vertical, ShedTheme.Space.m)
            }
            .background(ShedTheme.Colors.bg)
            .navigationTitle("Progress")
            .toolbarBackground(ShedTheme.Colors.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Level Overview

/// Shows current level based on XP (replaces old Rank display)
struct LevelOverview: View {
    @ObservedObject var playerProfile: PlayerProfile
    
    private var level: PlayerLevel {
        PlayerLevel(xp: playerProfile.currentRating)
    }
    
    var body: some View {
        ShedCard {
            VStack(spacing: ShedTheme.Space.m) {
                // Level badge
                HStack {
                    VStack(alignment: .leading, spacing: ShedTheme.Space.xxs) {
                        Text("Level \(level.level)")
                            .font(ShedTheme.Typography.title)
                            .foregroundColor(ShedTheme.Colors.textPrimary)
                        
                        Text("\(playerProfile.currentRating) XP")
                            .font(ShedTheme.Typography.body)
                            .foregroundColor(ShedTheme.Colors.textSecondary)
                    }
                    
                    Spacer()
                    
                    // Streak info
                    VStack(alignment: .trailing, spacing: ShedTheme.Space.xxs) {
                        HStack(spacing: ShedTheme.Space.xxs) {
                            Image(systemName: "flame.fill")
                                .foregroundColor(ShedTheme.Colors.warning)
                            Text("\(playerProfile.currentStreak) day streak")
                                .font(ShedTheme.Typography.bodyBold)
                        }
                        .font(ShedTheme.Typography.body)
                        .foregroundColor(ShedTheme.Colors.textPrimary)
                        
                        if playerProfile.longestStreak > playerProfile.currentStreak {
                            Text("Best: \(playerProfile.longestStreak) days")
                                .font(ShedTheme.Typography.caption)
                                .foregroundColor(ShedTheme.Colors.textTertiary)
                        }
                    }
                }
                
                // Progress to next level
                VStack(alignment: .leading, spacing: ShedTheme.Space.xxs) {
                    HStack {
                        Text("Progress to Level \(level.level + 1)")
                            .font(ShedTheme.Typography.caption)
                            .foregroundColor(ShedTheme.Colors.textSecondary)
                        
                        Spacer()
                        
                        Text("\(level.xpUntilNextLevel) XP needed")
                            .font(ShedTheme.Typography.caption)
                            .foregroundColor(ShedTheme.Colors.textTertiary)
                    }
                    
                    ShedProgressBar(progress: level.progressToNextLevel, showLabel: false)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ProgressTabView()
        .environmentObject(SettingsManager.shared)
        .preferredColorScheme(.dark)
}
