import SwiftUI

/// Continue Learning Card - shows active or recommended curriculum module
/// Per DESIGN.md Section 5.3.2 and Appendix C.3
/// 
/// DESIGN CONTRACT: This card launches drills in CURRICULUM mode with locked config.
struct ContinueLearningCard: View {
    @State private var selectedModule: CurriculumModule?
    
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
                            startModulePractice()
                        }
                    )
                }
            }
            .navigationDestination(item: $selectedModule) { module in
                drillView(for: module)
            }
        }
    }
    
    // MARK: - Navigation
    
    /// Creates drill view with curriculum mode - config is LOCKED to module
    @ViewBuilder
    private func drillView(for module: CurriculumModule) -> some View {
        let launchMode = DrillLaunchMode.curriculum(moduleId: module.id)
        
        switch module.mode {
        case .chords:
            ChordDrillView(launchMode: launchMode)
                .environmentObject(QuizGame())
        case .cadences:
            CadenceDrillView(launchMode: launchMode)
                .environmentObject(CadenceGame())
        case .scales:
            ScaleDrillView(launchMode: launchMode)
                .environmentObject(ScaleGame())
        case .intervals:
            IntervalDrillView(launchMode: launchMode)
                .environmentObject(IntervalGame())
        case .progressions:
            ProgressionDrillView()
        }
    }
    
    private func startModulePractice() {
        // Set the module as active and navigate
        if let module = targetModule {
            CurriculumManager.shared.setActiveModule(module.id)
            selectedModule = module
        }
    }
    
    // MARK: - Logic
    
    private var activeModule: CurriculumModule? {
        CurriculumManager.shared.activeModule
    }
    
    private var recommendedModule: CurriculumModule? {
        CurriculumManager.shared.recommendedNextModule
    }
    
    private var targetModule: CurriculumModule? {
        activeModule ?? recommendedModule
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
    NavigationStack {
        ContinueLearningCard()
            .padding()
    }
}

#Preview("Dark Mode") {
    NavigationStack {
        ContinueLearningCard()
            .padding()
            .preferredColorScheme(.dark)
    }
}
