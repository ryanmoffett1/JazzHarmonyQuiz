import SwiftUI

/// Continue Learning Card - shows active or recommended curriculum module
/// Per DESIGN.md Section 5.3.2
struct ContinueLearningCard: View {
    var body: some View {
        if shouldShowCard {
            StandardCard {
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text("CONTINUE LEARNING")
                        .font(.system(.caption, design: .rounded, weight: .semibold))
                        .foregroundColor(.secondary)
                    
                    // Module info
                    VStack(alignment: .leading, spacing: 8) {
                        Text(moduleTitle)
                            .font(.system(.headline, design: .rounded, weight: .semibold))
                        
                        // Progress bar
                        ProgressBar(progress: moduleProgress, showPercentage: true)
                    }
                    
                    // Continue button
                    SecondaryButton(
                        title: isStarting ? "Start" : "Continue",
                        action: {
                            // TODO: Navigate to module drill
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Logic
    
    private var activeModule: CurriculumModule? {
        // TODO: Connect to actual CurriculumManager
        CurriculumManager.shared.activeModule
    }
    
    private var recommendedModule: CurriculumModule? {
        // TODO: Connect to actual CurriculumManager
        CurriculumManager.shared.recommendedNextModule
    }
    
    private var shouldShowCard: Bool {
        activeModule != nil || recommendedModule != nil
    }
    
    private var moduleTitle: String {
        if let active = activeModule {
            return active.title
        } else if let recommended = recommendedModule {
            return "Start: \(recommended.title)"
        }
        return ""
    }
    
    private var moduleProgress: Double {
        if let active = activeModule {
            return CurriculumManager.shared.getModuleProgressPercentage(active) / 100.0
        }
        return 0.0
    }
    
    private var isStarting: Bool {
        activeModule == nil && recommendedModule != nil
    }
}

#Preview("Active Module") {
    ContinueLearningCard()
        .padding()
}

#Preview("Dark Mode") {
    ContinueLearningCard()
        .padding()
        .preferredColorScheme(.dark)
}
