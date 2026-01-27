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
                    // Header with streak badge
                    headerSection
                    
                    // Quick Practice Card (always first, always visible)
                    QuickPracticeCard(showQuickPractice: $showQuickPractice)
                    
                    // Continue Learning Card (if active curriculum module)
                    ContinueLearningCard()
                    
                    // Daily Focus Card (if weak area identified)
                    DailyFocusCard()
                    
                    // Weekly Streak
                    VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                        ShedHeader(title: "This Week")
                        WeeklyStreakView()
                    }
                    
                    // Quick Stats
                    VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                        ShedHeader(title: "Quick Stats")
                        QuickStatsView()
                    }
                    
                    Spacer(minLength: ShedTheme.Space.l)
                }
                .padding(.horizontal, ShedTheme.Space.m)
            }
            .background(ShedTheme.Colors.bg)
            .navigationTitle("Shed Pro")
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
        HStack {
            Spacer()
            streakBadge
        }
        .padding(.top, ShedTheme.Space.xs)
    }
    
    @ViewBuilder
    private var streakBadge: some View {
        let streakDays = PlayerProfile.shared.currentStreak
        
        if streakDays > 0 {
            HStack(spacing: ShedTheme.Space.xxs) {
                Text("🔥")
                Text("\(streakDays) days")
                    .font(ShedTheme.Type.caption)
            }
            .foregroundColor(streakDays >= 7 ? ShedTheme.Colors.brass : ShedTheme.Colors.textSecondary)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SettingsManager.shared)
        .preferredColorScheme(.dark)
}
