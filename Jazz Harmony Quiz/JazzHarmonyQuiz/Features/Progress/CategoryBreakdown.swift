import SwiftUI

/// Breakdown of progress by drill category
struct CategoryBreakdown: View {
    @ObservedObject var playerProfile: PlayerProfile
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)
                .foregroundColor(settings.primaryText(for: colorScheme))
            
            VStack(spacing: 8) {
                ForEach(PracticeMode.allCases, id: \.self) { mode in
                    CategoryRow(
                        mode: mode,
                        stats: playerProfile.modeStats[mode]
                    )
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(settings.cardBackground(for: colorScheme))
        )
    }
}

/// Single category row
struct CategoryRow: View {
    let mode: PracticeMode
    let stats: ModeStatistics?
    
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    private var accuracy: Double {
        stats?.accuracy ?? 0
    }
    
    private var questionsAnswered: Int {
        stats?.totalQuestions ?? 0
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Icon
            Image(systemName: iconForMode)
                .font(.title3)
                .foregroundColor(colorForMode)
                .frame(width: 36)
            
            // Title
            Text(mode.rawValue)
                .font(.subheadline)
                .foregroundColor(settings.primaryText(for: colorScheme))
            
            Spacer()
            
            // Stats
            if questionsAnswered > 0 {
                Text(String(format: "%.0f%%", accuracy * 100))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(accuracyColor)
                
                Text("(\(questionsAnswered))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("No data")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray.opacity(0.05))
        )
    }
    
    private var iconForMode: String {
        switch mode {
        case .chordDrill: return "music.note"
        case .scaleDrill: return "music.note.list"
        case .intervalDrill: return "arrow.up.and.down"
        case .cadenceDrill: return "arrow.triangle.branch"
        case .progressionDrill: return "arrow.triangle.swap"
        }
    }
    
    private var colorForMode: Color {
        switch mode {
        case .chordDrill: return .blue
        case .scaleDrill: return .green
        case .intervalDrill: return .purple
        case .cadenceDrill: return .orange
        case .progressionDrill: return .pink
        }
    }
    
    private var accuracyColor: Color {
        if accuracy >= 0.9 { return .green }
        if accuracy >= 0.7 { return .orange }
        return .red
    }
}

// MARK: - Preview

#Preview {
    CategoryBreakdown(playerProfile: PlayerProfile.shared)
        .environmentObject(SettingsManager.shared)
        .padding()
}
