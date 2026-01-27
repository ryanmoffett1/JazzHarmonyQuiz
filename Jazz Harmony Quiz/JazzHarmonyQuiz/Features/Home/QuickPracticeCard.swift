import SwiftUI

/// Quick Practice Card - always first, always visible
/// Per DESIGN.md Section 5.3.1 and 6.2, using ShedTheme for flat modern UI
struct QuickPracticeCard: View {
    @Binding var showQuickPractice: Bool
    
    var body: some View {
        ShedCard(highlighted: true) {
            VStack(alignment: .leading, spacing: ShedTheme.Space.m) {
                // Title row with icon
                HStack(spacing: ShedTheme.Space.s) {
                    Text("✦")
                        .font(.system(size: 14))
                        .foregroundColor(ShedTheme.Colors.brass)
                    
                    Text("QUICK PRACTICE")
                        .font(ShedTheme.Typography.caption)
                        .tracking(1.5)
                        .foregroundColor(ShedTheme.Colors.brass)
                }
                
                // Content based on what's available
                VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                    Text(contentTitle)
                        .font(ShedTheme.Typography.title)
                        .foregroundColor(ShedTheme.Colors.textPrimary)
                    
                    Text(contentSubtitle)
                        .font(ShedTheme.Typography.body)
                        .foregroundColor(ShedTheme.Colors.textSecondary)
                    
                    if let estimate = estimatedTime {
                        HStack(spacing: ShedTheme.Space.xxs) {
                            Image(systemName: "clock")
                                .font(.system(size: 11))
                            Text(estimate)
                        }
                        .font(ShedTheme.Typography.captionSmall)
                        .foregroundColor(ShedTheme.Colors.textTertiary)
                        .padding(.top, ShedTheme.Space.xxs)
                    }
                }
                
                // Start Button
                ShedButton(
                    title: "Start Session",
                    action: {
                        showQuickPractice = true
                    },
                    style: .primary
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
