import SwiftUI

/// Quick Stats View - summary of practice statistics
/// Per DESIGN.md Section 5.2 (Home Screen layout)
struct QuickStatsView: View {
    @ObservedObject private var playerProfile = PlayerProfile.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            StatRow(label: "Total Sessions", value: "\(totalSessions)")
            StatRow(label: "This Week", value: "\(sessionsThisWeek)")
            StatRow(label: "Avg Accuracy", value: "\(averageAccuracy)%")
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

/// Single stat row
private struct StatRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(.subheadline, design: .rounded))
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.system(.subheadline, design: .rounded, weight: .semibold))
        }
    }
}

#Preview("Light Mode") {
    QuickStatsView()
        .padding()
}

#Preview("Dark Mode") {
    QuickStatsView()
        .padding()
        .preferredColorScheme(.dark)
}
