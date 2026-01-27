import SwiftUI

/// Quick Stats View - summary of practice statistics
/// Per DESIGN.md Section 5.2, using ShedTheme for flat modern UI
struct QuickStatsView: View {
    @ObservedObject private var playerProfile = PlayerProfile.shared
    
    var body: some View {
        ShedCard {
            VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                ShedRow(label: "Total Sessions", value: "\(totalSessions)")
                ShedDivider()
                ShedRow(label: "This Week", value: "\(sessionsThisWeek)")
                ShedDivider()
                ShedRow(label: "Avg Accuracy", value: "\(averageAccuracy)%")
            }
        }
    }
    
    // MARK: - Data
    
    private var totalSessions: Int {
        // Count total sessions across all modes
        playerProfile.modeStats.values.reduce(0) { $0 + $1.sessionsCompleted }
    }
    
    private var sessionsThisWeek: Int {
        // Count sessions from the last 7 days
        let calendar = Calendar.current
        let oneWeekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        
        var count = 0
        for (_, stats) in playerProfile.modeStats {
            if let lastDate = stats.lastPracticeDate, lastDate >= oneWeekAgo {
                // If they practiced this week, count at least 1
                // This is an approximation since we don't store per-session dates
                count += 1
            }
        }
        return count
    }
    
    private var averageAccuracy: Int {
        guard playerProfile.totalQuestionsAnswered > 0 else { return 0 }
        return Int(playerProfile.overallAccuracy * 100)
    }
}

#Preview {
    QuickStatsView()
        .padding()
        .background(ShedTheme.Colors.bg)
        .preferredColorScheme(.dark)
}
