import SwiftUI

struct CurriculumView: View {
    @StateObject private var curriculumManager = CurriculumManager.shared
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPathway: CurriculumPathway = .harmonyFoundations
    @State private var showingModuleDetail: CurriculumModule?
    @State private var moduleToStart: CurriculumModule? // Module to start after sheet dismisses
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Pathway Selector
                PathwaySelector(selectedPathway: $selectedPathway)
                    .padding(.vertical, ShedTheme.Space.s)
                
                // Module List
                ScrollView {
                    LazyVStack(spacing: ShedTheme.Space.m) {
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
                    .padding(.horizontal, ShedTheme.Space.m)
                }
            }
            .background(ShedTheme.Colors.bg)
            .navigationTitle("Guided Curriculum")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(ShedTheme.Colors.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
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
        // Set active module - drill views will read configuration from this
        curriculumManager.setActiveModule(module.id)
        
        // Dismiss curriculum view - parent ContentView will handle navigation
        dismiss()
    }
}

// MARK: - Pathway Selector

struct PathwaySelector: View {
    @Binding var selectedPathway: CurriculumPathway
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: ShedTheme.Space.s) {
                ForEach(CurriculumPathway.allCases, id: \.self) { pathway in
                    PathwayButton(
                        pathway: pathway,
                        isSelected: selectedPathway == pathway
                    ) {
                        withAnimation(ShedTheme.Motion.standard) {
                            selectedPathway = pathway
                        }
                    }
                }
            }
            .padding(.horizontal, ShedTheme.Space.m)
        }
    }
}

struct PathwayButton: View {
    let pathway: CurriculumPathway
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: ShedTheme.Space.xs) {
                Image(systemName: pathway.icon)
                    .font(.title2)
                
                Text(pathway.rawValue)
                    .font(ShedTheme.Type.caption)
            }
            .frame(width: 100, height: 80)
            .foregroundColor(isSelected ? ShedTheme.Colors.bg : ShedTheme.Colors.textPrimary)
            .background(
                RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                    .fill(isSelected ? ShedTheme.Colors.brass : ShedTheme.Colors.surface)
            )
            .overlay(
                RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                    .stroke(isSelected ? ShedTheme.Colors.brass : ShedTheme.Colors.stroke, lineWidth: ShedTheme.Stroke.thin)
            )
        }
    }
}

// MARK: - Module Card

struct ModuleCard: View {
    let module: CurriculumModule
    let isUnlocked: Bool
    let isCompleted: Bool
    let progressPercentage: Double
    
    var body: some View {
        HStack(spacing: ShedTheme.Space.m) {
            // Emoji & Status
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 60, height: 60)
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title)
                        .foregroundColor(ShedTheme.Colors.success)
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.title2)
                        .foregroundColor(ShedTheme.Colors.textTertiary)
                } else {
                    Text(module.emoji)
                        .font(.largeTitle)
                }
            }
            
            // Module Info
            VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                HStack {
                    Text(module.title)
                        .font(ShedTheme.Type.bodyBold)
                        .foregroundColor(ShedTheme.Colors.textPrimary)
                    
                    Spacer()
                    
                    // Mode badge
                    ShedChip(text: module.mode.rawValue, style: .neutral)
                }
                
                Text(module.description)
                    .font(ShedTheme.Type.body)
                    .foregroundColor(ShedTheme.Colors.textSecondary)
                    .lineLimit(2)
                
                if isUnlocked && !isCompleted {
                    // Progress bar
                    VStack(alignment: .leading, spacing: ShedTheme.Space.xxs) {
                        HStack {
                            Text("Progress:")
                                .font(ShedTheme.Type.caption)
                                .foregroundColor(ShedTheme.Colors.textTertiary)
                            
                            Spacer()
                            
                            Text("\(Int(progressPercentage))%")
                                .font(ShedTheme.Type.caption)
                                .foregroundColor(statusColor)
                        }
                        
                        ShedProgressBar(progress: progressPercentage / 100, showPercentage: false, fillColor: statusColor)
                    }
                } else if isCompleted {
                    HStack(spacing: ShedTheme.Space.xxs) {
                        Image(systemName: "star.fill")
                        Text("Completed")
                    }
                    .font(ShedTheme.Type.caption)
                    .foregroundColor(ShedTheme.Colors.success)
                }
            }
        }
        .padding(ShedTheme.Space.m)
        .background(
            RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                .fill(isUnlocked ? ShedTheme.Colors.surface : ShedTheme.Colors.surface.opacity(0.5))
        )
        .overlay(
            RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                .stroke(isCompleted ? ShedTheme.Colors.success : (isUnlocked ? ShedTheme.Colors.stroke : ShedTheme.Colors.stroke.opacity(0.5)), lineWidth: ShedTheme.Stroke.thin)
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
    
    private var statusColor: Color {
        ShedTheme.Colors.brass
    }
}

// MARK: - Module Detail View

struct ModuleDetailView: View {
    let module: CurriculumModule
    let onStartModule: (CurriculumModule) -> Void
    
    @StateObject private var curriculumManager = CurriculumManager.shared
    @Environment(\.dismiss) var dismiss
    
    var progress: ModuleProgress {
        curriculumManager.getProgress(for: module.id)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: ShedTheme.Space.l) {
                    // Header
                    VStack(spacing: ShedTheme.Space.s) {
                        Text(module.emoji)
                            .font(.system(size: 80))
                        
                        Text(module.title)
                            .font(ShedTheme.Type.title)
                            .multilineTextAlignment(.center)
                            .foregroundColor(ShedTheme.Colors.textPrimary)
                        
                        Text(module.pathway.rawValue)
                            .font(ShedTheme.Type.body)
                            .foregroundColor(ShedTheme.Colors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(ShedTheme.Space.m)
                    
                    ShedDivider()
                    
                    // Description
                    VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                        Label("About This Module", systemImage: "info.circle")
                            .font(ShedTheme.Type.bodyBold)
                            .foregroundColor(ShedTheme.Colors.textPrimary)
                        
                        Text(module.description)
                            .font(ShedTheme.Type.body)
                            .foregroundColor(ShedTheme.Colors.textSecondary)
                    }
                    .padding(.horizontal, ShedTheme.Space.m)
                    
                    // Completion Criteria
                    VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                        Label("Completion Requirements", systemImage: "checkmark.circle")
                            .font(ShedTheme.Type.bodyBold)
                            .foregroundColor(ShedTheme.Colors.textPrimary)
                        
                        VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
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
                    .padding(.horizontal, ShedTheme.Space.m)
                    
                    // Start Button
                    ShedButton(
                        title: progress.attempts > 0 ? "Continue Practice" : "Start Module",
                        icon: progress.attempts > 0 ? "arrow.clockwise" : "play.fill",
                        style: .primary,
                        action: startModule
                    )
                    .padding(.horizontal, ShedTheme.Space.m)
                    .padding(.top, ShedTheme.Space.xs)
                }
                .padding(.vertical, ShedTheme.Space.m)
            }
            .background(ShedTheme.Colors.bg)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ShedTheme.Colors.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ShedTheme.Colors.brass)
                }
            }
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
                .foregroundColor(isMet ? ShedTheme.Colors.success : ShedTheme.Colors.warning)
                .frame(width: 24)
            
            Text(text)
                .font(ShedTheme.Type.body)
                .foregroundColor(ShedTheme.Colors.textSecondary)
            
            Spacer()
            
            Text(current)
                .font(ShedTheme.Type.bodyBold)
                .foregroundColor(isMet ? ShedTheme.Colors.success : ShedTheme.Colors.warning)
            
            if isMet {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(ShedTheme.Colors.success)
            }
        }
        .padding(ShedTheme.Space.s)
        .background(ShedTheme.Colors.surface)
        .cornerRadius(ShedTheme.Radius.s)
    }
}

// MARK: - Preview

struct CurriculumView_Previews: PreviewProvider {
    static var previews: some View {
        CurriculumView()
            .environmentObject(SettingsManager.shared)
            .preferredColorScheme(.dark)
    }
}
