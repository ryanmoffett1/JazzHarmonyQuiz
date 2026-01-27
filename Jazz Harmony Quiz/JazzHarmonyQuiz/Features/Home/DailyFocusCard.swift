import SwiftUI

/// Daily Focus Card - shows weak area to practice
/// Per DESIGN.md Section 5.3.3, using ShedTheme for flat modern UI
struct DailyFocusCard: View {
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
                            // TODO: Navigate to focused drill for this weak area
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
    }
    
    private var identifiedWeakArea: WeakArea? {
        // TODO: Connect to actual Statistics
        // Per DESIGN.md: Show if accuracy < 75%
        
        // Placeholder - will be replaced with real data
        // let stats = StatisticsManager.shared.getWeakestArea()
        // if stats.accuracy < 0.75 {
        //     return WeakArea(name: stats.name, shortName: stats.shortName, accuracy: stats.accuracy)
        // }
        
        return nil
    }
}

#Preview {
    DailyFocusCard()
        .padding()
        .background(ShedTheme.Colors.bg)
        .preferredColorScheme(.dark)
}
