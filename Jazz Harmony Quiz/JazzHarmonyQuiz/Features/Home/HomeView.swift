import SwiftUI

/// Home screen - daily dashboard with Quick Practice and progress overview
/// Per DESIGN.md Section 5, using ShedTheme for flat modern UI
struct HomeView: View {
    @EnvironmentObject var settings: SettingsManager
    @State private var showQuickPractice = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ShedTheme.Space.l) {
                    // Header with streak and XP
                    headerSection
                    
                    // Quick Practice Card (always first, always visible)
                    QuickPracticeCard(showQuickPractice: $showQuickPractice)
                    
                    // Continue Learning Card (if active curriculum module)
                    ContinueLearningCard()
                    
                    // Daily Focus Card (if weak area identified)
                    DailyFocusCard()
                    
                    // Weekly Streak
                    VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                        ShedHeader(title: "This Week")
                        WeeklyStreakView()
                    }
                    
                    // Quick Stats
                    VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                        ShedHeader(title: "Quick Stats")
                        QuickStatsView()
                    }
                    
                    Spacer(minLength: ShedTheme.Space.xxl)
                }
                .padding(.horizontal, ShedTheme.Space.m)
                .padding(.top, ShedTheme.Space.s)
            }
            .background(ShedTheme.Colors.bg.ignoresSafeArea())
            .navigationTitle("ShedPro")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(ShedTheme.Colors.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .sheet(isPresented: $showQuickPractice) {
                QuickPracticeView()
                    .environmentObject(settings)
            }
        }
    }
    
    private var headerSection: some View {
        HStack(spacing: ShedTheme.Space.s) {
            Spacer()
            
            // XP Badge
            let xp = PlayerProfile.shared.totalXP
            if xp > 0 {
                ShedBadge(text: "\(xp) XP", icon: "✦", style: .default)
            }
            
            // Streak Badge
            streakBadge
        }
        .padding(.top, ShedTheme.Space.xs)
    }
    
    @ViewBuilder
    private var streakBadge: some View {
        let streakDays = PlayerProfile.shared.currentStreak
        
        if streakDays > 0 {
            ShedBadge(
                text: "\(streakDays) day\(streakDays == 1 ? "" : "s")",
                icon: "🔥",
                style: streakDays >= 7 ? .brass : .default
            )
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SettingsManager.shared)
        .preferredColorScheme(.dark)
}
