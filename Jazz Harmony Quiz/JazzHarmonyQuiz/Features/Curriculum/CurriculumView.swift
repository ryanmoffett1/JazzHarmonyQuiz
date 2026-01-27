import SwiftUI

/// Main curriculum tab view showing learning pathways and modules
/// Per DESIGN.md Section 8 and Appendix C
struct CurriculumView: View {
    @StateObject private var curriculumManager = CurriculumManager.shared
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPathway: CurriculumPathway = .harmonyFoundations
    @State private var showingModuleDetail: CurriculumModule?
    @State private var moduleToStart: CurriculumModule?
    @State private var navigateToModule: CurriculumModule?
    
    // Stable game instances that persist during navigation
    // These are recreated only when a new module is started
    @StateObject private var quizGame = QuizGame()
    @StateObject private var cadenceGame = CadenceGame()
    @StateObject private var scaleGame = ScaleGame()
    @StateObject private var intervalGame = IntervalGame()
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Pathway Selector
                PathwaySelector(selectedPathway: $selectedPathway)
                    .padding(.vertical, 12)
                
                // Module List
                ScrollView {
                    LazyVStack(spacing: 16) {
                        let modules = curriculumManager.getModules(for: selectedPathway)
                        
                        ForEach(modules) { module in
                            ModuleCard(
                                module: module,
                                isUnlocked: curriculumManager.isModuleUnlocked(module),
                                isCompleted: curriculumManager.isModuleCompleted(module),
                                progressPercentage: curriculumManager.getModuleProgressPercentage(module)
                            )
                            .onTapGesture {
                                if curriculumManager.isModuleUnlocked(module) {
                                    showingModuleDetail = module
                                }
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Guided Curriculum")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $showingModuleDetail) { module in
                ModuleDetailView(module: module) { moduleToStart in
                    self.moduleToStart = moduleToStart
                    showingModuleDetail = nil
                }
            }
            .onChange(of: showingModuleDetail) { oldValue, newValue in
                // When sheet dismisses and we have a module to start
                if newValue == nil, let module = moduleToStart {
                    startModule(module)
                    moduleToStart = nil
                }
            }
            .navigationDestination(item: $navigateToModule) { module in
                drillView(for: module)
            }
        }
    }
    
    /// Creates the appropriate drill view with curriculum mode locked config
    /// Per DESIGN.md Appendix C.2: Curriculum mode locks drill configuration
    /// Uses stable @StateObject game instances to preserve state during navigation
    @ViewBuilder
    private func drillView(for module: CurriculumModule) -> some View {
        let launchMode = DrillLaunchMode.curriculum(moduleId: module.id)
        
        switch module.mode {
        case .chords:
            ChordDrillView(launchMode: launchMode)
                .environmentObject(quizGame)
        case .cadences:
            CadenceDrillView(launchMode: launchMode)
                .environmentObject(cadenceGame)
        case .scales:
            ScaleDrillView(launchMode: launchMode)
                .environmentObject(scaleGame)
        case .intervals:
            IntervalDrillView(launchMode: launchMode)
                .environmentObject(intervalGame)
        case .progressions:
            ProgressionDrillView()
        }
    }
    
    private func startModule(_ module: CurriculumModule) {
        // Set active module - drill views will read configuration from this
        curriculumManager.setActiveModule(module.id)
        
        // Reset the appropriate game state before starting
        // This ensures clean state for each module without recreating the object
        switch module.mode {
        case .chords:
            quizGame.resetQuizState()
        case .cadences:
            cadenceGame.resetQuizState()
        case .scales:
            scaleGame.resetQuizState()
        case .intervals:
            intervalGame.resetQuiz()
        case .progressions:
            break
        }
        
        // Navigate to the appropriate drill view with curriculum mode
        navigateToModule = module
    }
}

// MARK: - Preview

#Preview {
    CurriculumView()
        .environmentObject(SettingsManager.shared)
}
