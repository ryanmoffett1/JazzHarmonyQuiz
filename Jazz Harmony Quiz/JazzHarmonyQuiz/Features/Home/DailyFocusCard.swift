import SwiftUI

/// Daily Focus Card - shows weak area to practice
/// Per DESIGN.md Section 5.3.3
struct DailyFocusCard: View {
    var body: some View {
        if let weakArea = identifiedWeakArea {
            StandardCard {
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text("DAILY FOCUS")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    // Weak area info
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Weak area: \(weakArea.name)")
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                        
                        Text("Last accuracy: \(Int(weakArea.accuracy * 100))%")
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundColor(.secondary)
                    }
                    
                    // Practice button
                    SecondaryButton(
                        title: "Practice \(weakArea.shortName)",
                        action: {
                            // TODO: Navigate to focused drill for this weak area
                        }
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

#Preview("With Weak Area") {
    // For preview, temporarily show the card
    DailyFocusCard()
        .padding()
}

#Preview("Dark Mode") {
    DailyFocusCard()
        .padding()
        .preferredColorScheme(.dark)
}
