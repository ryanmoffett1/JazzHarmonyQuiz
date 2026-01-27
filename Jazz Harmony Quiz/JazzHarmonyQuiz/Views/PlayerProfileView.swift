import SwiftUI

// MARK: - Player Profile View

struct PlayerProfileView: View {
    @ObservedObject var profile = PlayerProfile.shared
    @ObservedObject var playerStats = PlayerStats.shared
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    @State private var showingAvatarPicker = false
    @State private var showingNameEditor = false
    @State private var editedName = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Profile Header
                profileHeader
                
                // Level Progress
                levelProgress
                
                // Stats Hexagon
                statsSection
                
                // Mode Statistics
                modeStatsSection
                
                // Achievements Preview
                achievementsPreview
            }
            .padding()
        }
        .navigationTitle("Profile")
        .sheet(isPresented: $showingAvatarPicker) {
            AvatarPickerView(selectedAvatar: $profile.avatar)
        }
        .alert("Edit Name", isPresented: $showingNameEditor) {
            TextField("Name", text: $editedName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                profile.playerName = editedName
                profile.saveToUserDefaults()
            }
        } message: {
            Text("Enter your musician name")
        }
    }
    
    // MARK: - Profile Header
    
    private var profileHeader: some View {
        VStack(spacing: 16) {
            // Avatar
            Button(action: { showingAvatarPicker = true }) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            colors: [.blue, .purple],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                    
                    Text(profile.avatar.rawValue)
                        .font(.system(size: 50))
                }
            }
            
            // Name
            Button(action: {
                editedName = profile.playerName
                showingNameEditor = true
            }) {
                HStack {
                    Text(profile.playerName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Image(systemName: "pencil")
                        .font(.caption)
                }
            }
            .foregroundColor(.primary)
            
            // Level Badge (Updated per DESIGN.md Section 9.3.1 - no emoji)
            Text("Level \(playerLevel.level)")
                .font(.headline)
                .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    private var playerLevel: PlayerLevel {
        PlayerLevel(xp: profile.currentRating)
    }
    
    // MARK: - Level Progress
    
    private var levelProgress: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Level Progress")
                    .font(.headline)
                Spacer()
                Text("\(profile.totalXP) XP")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Progress bar to next level
            VStack(spacing: 4) {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.systemGray4))
                        
                        RoundedRectangle(cornerRadius: 8)
                            .fill(LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                            .frame(width: geometry.size.width * min(1, max(0, playerLevel.progressToNextLevel)))
                    }
                }
                .frame(height: 12)
                
                HStack {
                    Text("Level \(playerLevel.level)")
                        .font(.caption)
                    Spacer()
                    Text("\(playerLevel.xpUntilNextLevel) XP to Level \(playerLevel.level + 1)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Jazz Stats")
                    .font(.headline)
                Spacer()
                Text("Power: \(profile.overallPower)")
                    .font(.subheadline)
                    .foregroundColor(.purple)
                    .fontWeight(.semibold)
            }
            
            // Stats Grid
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                ForEach(JazzStat.allCases, id: \.self) { stat in
                    StatCard(stat: stat, value: profile.statValue(for: stat))
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Mode Stats Section
    
    private var modeStatsSection: some View {
        VStack(spacing: 16) {
            Text("Practice Modes")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(PracticeMode.allCases, id: \.self) { mode in
                ModeStatRow(mode: mode, stats: profile.modeStats[mode])
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    // MARK: - Achievements Preview
    
    private var achievementsPreview: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Achievements")
                    .font(.headline)
                Spacer()
                Text("\(playerStats.unlockedAchievements.count) unlocked")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if playerStats.unlockedAchievements.isEmpty {
                Text("Complete quizzes to earn achievements!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(playerStats.unlockedAchievements.prefix(5), id: \.type) { achievement in
                            VStack {
                                Text(achievement.type.emoji)
                                    .font(.title)
                                Text(achievement.type.title)
                                    .font(.caption2)
                                    .lineLimit(1)
                            }
                            .frame(width: 70)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
}

// MARK: - Stat Card

struct StatCard: View {
    let stat: JazzStat
    let value: Int
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text(stat.emoji)
                    .font(.title3)
                Text(stat.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemGray4))
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(stat.color)
                        .frame(width: geometry.size.width * Double(value) / 100.0)
                }
            }
            .frame(height: 8)
            
            HStack {
                Text("\(value)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(stat.color)
                Spacer()
                Text(stat.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Mode Stat Row

struct ModeStatRow: View {
    let mode: PracticeMode
    let stats: ModeStatistics?
    
    var body: some View {
        HStack(spacing: 12) {
            Text(mode.emoji)
                .font(.title2)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(mode.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let stats = stats, stats.totalQuestions > 0 {
                    HStack(spacing: 16) {
                        Label("\(stats.sessionsCompleted)", systemImage: "number")
                        Label("\(Int(stats.accuracy * 100))%", systemImage: "target")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                } else {
                    Text("No practice yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            if let stats = stats, !stats.highScores.isEmpty {
                VStack(alignment: .trailing) {
                    Text("Best")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    Text("\(stats.highScores.first?.score ?? 0)")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                }
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }
}

// MARK: - Avatar Picker

struct AvatarPickerView: View {
    @Binding var selectedAvatar: PlayerAvatar
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 16) {
                    ForEach(PlayerAvatar.allCases, id: \.self) { avatar in
                        Button(action: {
                            selectedAvatar = avatar
                            PlayerProfile.shared.saveToUserDefaults()
                            dismiss()
                        }) {
                            VStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(selectedAvatar == avatar ? 
                                              Color.blue.opacity(0.2) : Color(.systemGray5))
                                        .frame(width: 80, height: 80)
                                    
                                    Text(avatar.rawValue)
                                        .font(.system(size: 40))
                                }
                                .overlay(
                                    Circle()
                                        .stroke(selectedAvatar == avatar ? Color.blue : Color.clear, lineWidth: 3)
                                )
                                
                                Text(avatar.name)
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Choose Avatar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        PlayerProfileView()
            .environmentObject(SettingsManager.shared)
    }
}
