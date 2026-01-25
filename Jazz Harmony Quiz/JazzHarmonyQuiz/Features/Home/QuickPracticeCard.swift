import SwiftUI

/// Quick Practice Card - always first, always visible
/// Per DESIGN.md Section 5.3.1 and 6.2
struct QuickPracticeCard: View {
    @Binding var showQuickPractice: Bool
    
    var body: some View {
        HighlightedCard {
            VStack(alignment: .leading, spacing: 12) {
                // Title
                Text("QUICK PRACTICE")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundColor(Color("BrassAccent"))
                
                Divider()
                    .background(Color("BrassAccent").opacity(0.3))
                
                // Content based on what's available
                VStack(alignment: .leading, spacing: 8) {
                    Text(contentTitle)
                        .font(.system(.headline, design: .rounded, weight: .semibold))
                    
                    Text(contentSubtitle)
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.secondary)
                    
                    if let estimate = estimatedTime {
                        Text("Estimated: \(estimate)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                }
                
                // Start Button
                PrimaryButton(
                    title: "Start Session",
                    action: {
                        showQuickPractice = true
                    }
                )
            }
        }
    }
    
    // MARK: - Content Logic
    
    private var dueItemsCount: Int {
        // TODO: Connect to actual SpacedRepetitionStore
        SpacedRepetitionStore.shared.totalDueCount()
    }
    
    private var hasWeakAreas: Bool {
        // TODO: Connect to actual Statistics
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

#Preview("With Due Items") {
    QuickPracticeCard(showQuickPractice: .constant(false))
        .padding()
}

#Preview("Dark Mode") {
    QuickPracticeCard(showQuickPractice: .constant(false))
        .padding()
        .preferredColorScheme(.dark)
}
