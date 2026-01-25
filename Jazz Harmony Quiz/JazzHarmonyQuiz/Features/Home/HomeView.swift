import SwiftUI

/// Home screen - daily dashboard with Quick Practice and progress overview
/// Per DESIGN.md Section 5
struct HomeView: View {
    @EnvironmentObject var settings: SettingsManager
    @State private var showQuickPractice = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with streak badge
                    headerSection
                    
                    // Quick Practice Card (always first, always visible)
                    QuickPracticeCard(showQuickPractice: $showQuickPractice)
                    
                    // Continue Learning Card (if active curriculum module)
                    ContinueLearningCard()
                    
                    // Daily Focus Card (if weak area identified)
                    DailyFocusCard()
                    
                    // Weekly Streak
                    VStack(alignment: .leading, spacing: 8) {
                        Text("THIS WEEK")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        WeeklyStreakView()
                    }
                    
                    // Quick Stats
                    VStack(alignment: .leading, spacing: 8) {
                        Text("QUICK STATS")
                            .font(.system(.caption, design: .rounded, weight: .semibold))
                            .foregroundColor(.secondary)
                        
                        QuickStatsView()
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Shed Pro")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var headerSection: some View {
        HStack {
            Spacer()
            streakBadge
        }
        .padding(.top, 8)
    }
    
    @ViewBuilder
    private var streakBadge: some View {
        // TODO: Implement actual streak logic from PlayerProfile
        // For now, showing a placeholder
        let streakDays = 0 // Replace with actual streak
        
        if streakDays > 0 {
            HStack(spacing: 4) {
                Text("🔥")
                Text("\(streakDays) days")
                    .font(.system(.caption, design: .rounded, weight: .medium))
            }
            .foregroundColor(streakDays >= 7 ? Color("BrassAccent") : .secondary)
        }
    }
}

#Preview("Light Mode") {
    HomeView()
        .environmentObject(SettingsManager.shared)
}

#Preview("Dark Mode") {
    HomeView()
        .environmentObject(SettingsManager.shared)
        .preferredColorScheme(.dark)
}
