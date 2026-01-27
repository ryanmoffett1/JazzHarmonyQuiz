import SwiftUI

/// Quick Practice Card - always first, always visible
/// Per DESIGN.md Section 5.3.1 and 6.2, using ShedTheme for flat modern UI
struct QuickPracticeCard: View {
    @Binding var showQuickPractice: Bool
    
    var body: some View {
        ShedCard(highlighted: true) {
            VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                // Title
                Text("QUICK PRACTICE")
                    .font(ShedTheme.Type.caption)
                    .foregroundColor(ShedTheme.Colors.brass)
                
                ShedDivider()
                
                // Content based on what's available
                VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                    Text(contentTitle)
                        .font(ShedTheme.Type.bodyBold)
                        .foregroundColor(ShedTheme.Colors.textPrimary)
                    
                    Text(contentSubtitle)
                        .font(ShedTheme.Type.body)
                        .foregroundColor(ShedTheme.Colors.textSecondary)
                    
                    if let estimate = estimatedTime {
                        Text("Estimated: \(estimate)")
                            .font(ShedTheme.Type.caption)
                            .foregroundColor(ShedTheme.Colors.textTertiary)
                    }
                }
                
                // Start Button
                ShedButton(
                    title: "Start Session",
                    style: .primary,
                    action: {
                        showQuickPractice = true
                    }
                )
            }
        }
    }
    
    // MARK: - Content Logic
    
    private var dueItemsCount: Int {
        SpacedRepetitionStore.shared.totalDueCount()
    }
    
    private var hasWeakAreas: Bool {
        false
    }
    
    private var contentTitle: String {
        if dueItemsCount > 0 {
            return "\(dueItemsCount) items due for review"
        } else if hasWeakAreas {
            return "Strengthen Weak Areas"
        } else {
            return "Free Practice"
        }
    }
    
    private var contentSubtitle: String {
        if dueItemsCount > 0 {
            return "Spaced repetition review session"
        } else if hasWeakAreas {
            return "Focus on areas needing work"
        } else {
            return "All caught up! Keep building fluency."
        }
    }
    
    private var estimatedTime: String? {
        if dueItemsCount > 0 {
            let minutes = max(5, (dueItemsCount * 20) / 60)
            return "\(minutes) min"
        } else {
            return "5 min"
        }
    }
}

#Preview {
    QuickPracticeCard(showQuickPractice: .constant(false))
        .padding()
        .background(ShedTheme.Colors.bg)
        .preferredColorScheme(.dark)
}
