import SwiftUI

/// Quick Stats View - summary of practice statistics
/// Per DESIGN.md Section 5.2 (Home Screen layout)
struct QuickStatsView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            StatRow(label: "Total Sessions", value: "\(totalSessions)")
            StatRow(label: "This Week", value: "\(sessionsThisWeek)")
            StatRow(label: "Avg Accuracy", value: "\(averageAccuracy)%")
        }
    }
    
    // MARK: - Data
    
    private var totalSessions: Int {
        // TODO: Connect to actual PlayerProfile
        // playerProfile.totalSessions
        0
    }
    
    private var sessionsThisWeek: Int {
        // TODO: Connect to actual practice history
        // playerProfile.getSessionsThisWeek()
        0
    }
    
    private var averageAccuracy: Int {
        // TODO: Connect to actual statistics
        // Int(statisticsManager.overallAccuracy * 100)
        0
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
