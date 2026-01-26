import SwiftUI

/// Main curriculum tab view showing learning pathways and modules
/// Per DESIGN.md Section 8
struct CurriculumView: View {
    @StateObject private var curriculumManager = CurriculumManager.shared
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPathway: CurriculumPathway = .harmonyFoundations
    @State private var showingModuleDetail: CurriculumModule?
    @State private var moduleToStart: CurriculumModule?
    @State private var navigateToDrill: CurriculumPracticeMode?
    
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
            .navigationDestination(item: $navigateToDrill) { mode in
                drillView(for: mode)
            }
        }
    }
    
    @ViewBuilder
    private func drillView(for mode: CurriculumPracticeMode) -> some View {
        switch mode {
        case .chords:
            ChordDrillView()
        case .cadences:
            CadenceDrillView()
        case .scales:
            ScaleDrillView()
        case .intervals:
            IntervalDrillView()
        case .progressions:
            ProgressionDrillView()
        }
    }
    
    private func startModule(_ module: CurriculumModule) {
        // Set active module - drill views will read configuration from this
        curriculumManager.setActiveModule(module.id)
        
        // Navigate to the appropriate drill view
        navigateToDrill = module.mode
    }
}

// MARK: - Preview

#Preview {
    CurriculumView()
        .environmentObject(SettingsManager.shared)
}
