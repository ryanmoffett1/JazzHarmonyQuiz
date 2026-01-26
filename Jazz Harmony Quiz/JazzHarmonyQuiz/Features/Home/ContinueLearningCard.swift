import SwiftUI

/// Continue Learning Card - shows active or recommended curriculum module
/// Per DESIGN.md Section 5.3.2
struct ContinueLearningCard: View {
    @State private var selectedDrill: DrillDestination?
    
    enum DrillDestination: Identifiable {
        case chord, cadence, scale, interval, progression
        
        var id: Self { self }
    }
    
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
            .navigationDestination(item: $selectedDrill) { drill in
                drillView(for: drill)
            }
        }
    }
    
    // MARK: - Navigation
    
    @ViewBuilder
    private func drillView(for drill: DrillDestination) -> some View {
        switch drill {
        case .chord:
            ChordDrillView()
        case .cadence:
            CadenceDrillView()
        case .scale:
            ScaleDrillView()
        case .interval:
            IntervalDrillView()
        case .progression:
            ProgressionDrillView()
        }
    }
    
    private func startModulePractice() {
        // Set the module as active
        if let module = targetModule {
            CurriculumManager.shared.setActiveModule(module.id)
            
            // Navigate to appropriate drill based on module mode
            switch module.mode {
            case .chords:
                selectedDrill = .chord
            case .cadences:
                selectedDrill = .cadence
            case .scales:
                selectedDrill = .scale
            case .intervals:
                selectedDrill = .interval
            case .progressions:
                selectedDrill = .progression
            }
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
