import SwiftUI

/// Continue Learning Card - shows active or recommended curriculum module
/// Per DESIGN.md Section 5.3.2 and Appendix C.3
/// Using ShedTheme for flat modern UI
/// 
/// DESIGN CONTRACT: This card launches drills in CURRICULUM mode with locked config.
struct ContinueLearningCard: View {
    @State private var selectedModule: CurriculumModule?
    
    var body: some View {
        if shouldShowCard {
            ShedCard {
                VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                    // Title
                    Text("CONTINUE LEARNING")
                        .font(ShedTheme.Typography.caption)
                        .foregroundColor(ShedTheme.Colors.textSecondary)
                    
                    // Module info
                    VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                        Text(moduleTitle)
                            .font(ShedTheme.Typography.bodyBold)
                            .foregroundColor(ShedTheme.Colors.textPrimary)
                        
                        // Progress bar
                        ShedProgressBar(progress: moduleProgress, showLabel: true)
                    }
                    
                    // Continue button
                    ShedButton(
                        title: isStarting ? "Start" : "Continue",
                        action: {
                            startModulePractice()
                        },
                        style: .secondary
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

#Preview {
    NavigationStack {
        ContinueLearningCard()
            .padding()
            .background(ShedTheme.Colors.bg)
            .preferredColorScheme(.dark)
    }
}
