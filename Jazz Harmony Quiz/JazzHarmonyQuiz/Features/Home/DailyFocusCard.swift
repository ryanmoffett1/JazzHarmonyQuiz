import SwiftUI

/// Daily Focus Card - shows weak area to practice
/// Per DESIGN.md Section 5.3.3, using ShedTheme for flat modern UI
struct DailyFocusCard: View {
    @ObservedObject private var profile = PlayerProfile.shared
    
    var body: some View {
        if let weakArea = identifiedWeakArea {
            ShedCard {
                VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                    // Title
                    Text("DAILY FOCUS")
                        .font(ShedTheme.Typography.caption)
                        .foregroundColor(ShedTheme.Colors.textSecondary)
                    
                    // Weak area info
                    VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                        Text("Weak area: \(weakArea.name)")
                            .font(ShedTheme.Typography.bodyBold)
                            .foregroundColor(ShedTheme.Colors.textPrimary)
                        
                        Text("Last accuracy: \(Int(weakArea.accuracy * 100))%")
                            .font(ShedTheme.Typography.body)
                            .foregroundColor(ShedTheme.Colors.textSecondary)
                    }
                    
                    // Practice button
                    ShedButton(
                        title: "Practice \(weakArea.shortName)",
                        action: {
                            // Navigation handled by parent view
                            // User can tap to see more details and navigate
                        },
                        style: .secondary
                    )
                }
            }
        }
    }
    
    // MARK: - Logic
    
    private struct WeakArea {
        let name: String
        let shortName: String
        let accuracy: Double
        let mode: PracticeMode
    }
    
    private var identifiedWeakArea: WeakArea? {
        // Find the mode with lowest accuracy that has sufficient data
        let threshold = 0.75
        let minQuestions = 10 // Need at least 10 questions for meaningful data
        
        var weakestMode: (mode: PracticeMode, accuracy: Double)?
        
        for mode in PracticeMode.allCases {
            guard let stats = profile.modeStats[mode],
                  stats.totalQuestions >= minQuestions else { continue }
            
            let accuracy = stats.accuracy
            
            // Only show if below threshold
            if accuracy < threshold {
                if weakestMode == nil || accuracy < weakestMode!.accuracy {
                    weakestMode = (mode, accuracy)
                }
            }
        }
        
        guard let (mode, accuracy) = weakestMode else { return nil }
        
        return WeakArea(
            name: mode.rawValue,
            shortName: mode.emoji,
            accuracy: accuracy,
            mode: mode
        )
    }
}

#Preview {
    DailyFocusCard()
        .padding()
        .background(ShedTheme.Colors.bg)
        .preferredColorScheme(.dark)
}
