import SwiftUI

struct CurriculumView: View {
    @StateObject private var curriculumManager = CurriculumManager.shared
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPathway: CurriculumPathway = .harmonyFoundations
    @State private var showingModuleDetail: CurriculumModule?
    @State private var moduleToStart: CurriculumModule? // Module to start after sheet dismisses
    
    var body: some View {
        NavigationView {
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
        }
    }
    
    private func startModule(_ module: CurriculumModule) {
        // Set active module
        curriculumManager.setActiveModule(module.id)
        
        // Apply module configuration
        applyModuleConfiguration(module)
        
        // Dismiss curriculum view - parent ContentView will handle navigation
        dismiss()
    }
    
    private func applyModuleConfiguration(_ module: CurriculumModule) {
        let config = module.recommendedConfig
        
        switch module.mode {
        case .chords:
            if let chordTypes = config.chordTypes {
                settings.selectedChordTypes = chordTypes
            }
            if let difficulty = config.keyDifficulty {
                settings.keyDifficulty = difficulty
            }
            settings.showNoteNames = config.showNoteNames ?? settings.showNoteNames
            settings.showKeyboard = config.showKeyboard ?? settings.showKeyboard
            
        case .scales:
            if let scaleTypes = config.scaleTypes {
                settings.selectedScaleTypes = scaleTypes
            }
            if let difficulty = config.keyDifficulty {
                settings.keyDifficulty = difficulty
            }
            
        case .cadences:
            if let cadenceTypes = config.cadenceTypes {
                settings.selectedCadenceTypes = cadenceTypes
            }
            if let difficulty = config.keyDifficulty {
                settings.keyDifficulty = difficulty
            }
            
        case .intervals:
            if let intervalTypes = config.intervalTypes {
                settings.selectedIntervalTypes = intervalTypes
            }
            settings.playMelodically = config.playMelodically ?? settings.playMelodically
            
        case .progressions:
            if let progressionTypes = config.progressionTypes {
                settings.selectedProgressionTypes = progressionTypes
            }
            if let difficulty = config.keyDifficulty {
                settings.keyDifficulty = difficulty
            }
        }
    }
}

// MARK: - Pathway Selector

struct PathwaySelector: View {
    @Binding var selectedPathway: CurriculumPathway
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CurriculumPathway.allCases, id: \.self) { pathway in
                    PathwayButton(
                        pathway: pathway,
                        isSelected: selectedPathway == pathway
                    ) {
                        withAnimation {
                            selectedPathway = pathway
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

struct PathwayButton: View {
    let pathway: CurriculumPathway
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: pathway.icon)
                    .font(.title2)
                
                Text(pathway.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .frame(width: 100, height: 80)
            .foregroundColor(isSelected ? .white : settings.primaryText(for: colorScheme))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? pathwayColor : Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? pathwayColor : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private var pathwayColor: Color {
        switch pathway {
        case .harmonyFoundations: return .blue
        case .functionalHarmony: return .green
        case .earTraining: return .orange
        case .advancedTopics: return .purple
        }
    }
}

// MARK: - Module Card

struct ModuleCard: View {
    let module: CurriculumModule
    let isUnlocked: Bool
    let isCompleted: Bool
    let progressPercentage: Double
    
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji & Status
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(.green)
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(.gray)
                } else {
                    Text(module.emoji)
                        .font(.largeTitle)
                }
            }
            
            // Module Info
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(module.title)
                        .font(.headline)
                        .foregroundColor(settings.primaryText(for: colorScheme))
                    
                    Spacer()
                    
                    // Mode badge
                    HStack(spacing: 4) {
                        Image(systemName: module.mode.icon)
                        Text(module.mode.rawValue)
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
                }
                
                Text(module.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                if isUnlocked && !isCompleted {
                    // Progress bar
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Progress:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Spacer()
                            
                            Text("\(Int(progressPercentage))%")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(statusColor)
                        }
                        
                        ProgressView(value: progressPercentage, total: 100)
                            .tint(statusColor)
                            .frame(height: 6)
                    }
                } else if isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text("Completed")
                    }
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isUnlocked ? settings.backgroundColor(for: colorScheme) : Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isCompleted ? Color.green : (isUnlocked ? statusColor : Color.gray), lineWidth: isCompleted ? 2 : 1)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
    
    private var statusColor: Color {
        switch module.pathway {
        case .harmonyFoundations: return .blue
        case .functionalHarmony: return .green
        case .earTraining: return .orange
        case .advancedTopics: return .purple
        }
    }
}

// MARK: - Module Detail View

struct ModuleDetailView: View {
    let module: CurriculumModule
    let onStartModule: (CurriculumModule) -> Void
    
    @StateObject private var curriculumManager = CurriculumManager.shared
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    var progress: ModuleProgress {
        curriculumManager.getProgress(for: module.id)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text(module.emoji)
                            .font(.system(size: 80))
                        
                        Text(module.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        Text(module.pathway.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    
                    Divider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Label("About This Module", systemImage: "info.circle")
                            .font(.headline)
                        
                        Text(module.description)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)
                    
                    // Completion Criteria
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Completion Requirements", systemImage: "checkmark.circle")
                            .font(.headline)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            CriteriaRow(
                                icon: "target",
                                text: "Accuracy: \(Int(module.completionCriteria.accuracyThreshold * 100))%+",
                                current: "\(Int(progress.accuracy * 100))%",
                                isMet: progress.accuracy >= module.completionCriteria.accuracyThreshold
                            )
                            
                            CriteriaRow(
                                icon: "number",
                                text: "Questions: \(module.completionCriteria.minimumAttempts)+",
                                current: "\(progress.attempts)",
                                isMet: progress.attempts >= module.completionCriteria.minimumAttempts
                            )
                            
                            if let perfectRequired = module.completionCriteria.perfectSessionsRequired {
                                CriteriaRow(
                                    icon: "star.fill",
                                    text: "Perfect Sessions: \(perfectRequired)",
                                    current: "\(progress.perfectSessions)",
                                    isMet: progress.perfectSessions >= perfectRequired
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Start Button
                    Button(action: startModule) {
                        HStack {
                            Image(systemName: progress.attempts > 0 ? "arrow.clockwise" : "play.fill")
                            Text(progress.attempts > 0 ? "Continue Practice" : "Start Module")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(pathwayColor)
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
                .padding(.vertical)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var pathwayColor: Color {
        switch module.pathway {
        case .harmonyFoundations: return .blue
        case .functionalHarmony: return .green
        case .earTraining: return .orange
        case .advancedTopics: return .purple
        }
    }
    
    private func startModule() {
        onStartModule(module)
    }
}

struct CriteriaRow: View {
    let icon: String
    let text: String
    let current: String
    let isMet: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isMet ? .green : .orange)
                .frame(width: 24)
            
            Text(text)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(current)
                .fontWeight(.semibold)
                .foregroundColor(isMet ? .green : .orange)
            
            if isMet {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview

struct CurriculumView_Previews: PreviewProvider {
    static var previews: some View {
        CurriculumView()
            .environmentObject(SettingsManager())
    }
}
