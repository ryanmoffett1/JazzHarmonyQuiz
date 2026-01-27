import SwiftUI

// MARK: - Practice Due Card

/// Card showing spaced repetition items due for practice
struct PracticeDueCard: View {
    @ObservedObject var srStore: SpacedRepetitionStore
    
    var totalDue: Int {
        srStore.totalDueCount()
    }
    
    var dueByMode: [(mode: PracticeMode, count: Int)] {
        PracticeMode.allCases.compactMap { mode in
            let count = srStore.dueCount(for: mode)
            return count > 0 ? (mode, count) : nil
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .font(.title2)
                    .foregroundColor(ShedTheme.Colors.warning)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Practice Due")
                        .font(.headline)
                    
                    if totalDue > 0 {
                        Text("\(totalDue) item\(totalDue == 1 ? "" : "s") ready to review")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("All caught up!")
                            .font(.caption)
                            .foregroundColor(ShedTheme.Colors.success)
                    }
                }
                
                Spacer()
                
                if totalDue > 0 {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.secondary)
                }
            }
            
            if totalDue > 0 {
                // Breakdown by mode
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(dueByMode, id: \.mode) { item in
                        HStack {
                            Text(item.mode.emoji)
                            Text(item.mode.rawValue)
                                .font(.subheadline)
                            Spacer()
                            Text("\(item.count)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding(.top, 4)
            } else {
                // Empty state with stats
                srStatisticsView
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(
                    totalDue > 0 ? ShedTheme.Colors.warning.opacity(0.3) : ShedTheme.Colors.success.opacity(0.3),
                    lineWidth: 2
                )
        )
    }
    
    private var srStatisticsView: some View {
        let stats = srStore.statistics()
        
        return VStack(alignment: .leading, spacing: 6) {
            if stats.totalItems > 0 {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Total Items")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(stats.totalItems)")
                            .font(.headline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Avg Accuracy")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(Int(stats.averageAccuracy * 100))%")
                            .font(.headline)
                            .foregroundColor(stats.averageAccuracy >= 0.8 ? .green : .orange)
                    }
                }
                
                // Maturity breakdown
                HStack(spacing: 12) {
                    maturityPill("New", count: stats.newItems, color: .blue)
                    maturityPill("Learning", count: stats.learningItems, color: .orange)
                    maturityPill("Young", count: stats.youngItems, color: .yellow)
                    maturityPill("Mature", count: stats.matureItems, color: .green)
                }
                .padding(.top, 4)
            } else {
                Text("Start practicing to build your review queue!")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func maturityPill(_ label: String, count: Int, color: Color) -> some View {
        VStack(spacing: 2) {
            Text("\(count)")
                .font(.caption.bold())
                .foregroundColor(color)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 4)
        .background(
            RoundedRectangle(cornerRadius: 6)
                .fill(color.opacity(0.1))
        )
    }
}

// MARK: - Preview

struct PracticeDueCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            // With due items
            PracticeDueCard(srStore: {
                let store = SpacedRepetitionStore.shared
                // Add some test data
                store.recordResult(
                    itemID: SRItemID(mode: .cadenceDrill, topic: "major", key: "C"),
                    wasCorrect: false
                )
                store.recordResult(
                    itemID: SRItemID(mode: .chordDrill, topic: "m7b5", key: "D"),
                    wasCorrect: false
                )
                return store
            }())
            
            // Empty state
            PracticeDueCard(srStore: SpacedRepetitionStore.shared)
        }
        .padding()
        .background(Color(uiColor: .systemGroupedBackground))
    }
}
