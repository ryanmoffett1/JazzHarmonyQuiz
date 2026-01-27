import SwiftUI

struct CurriculumView: View {
    @StateObject private var curriculumManager = CurriculumManager.shared
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedPathway: CurriculumPathway = .harmonyFoundations
    @State private var showingModuleDetail: CurriculumModule?
    @State private var moduleToStart: CurriculumModule?
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                ShedTheme.Colors.bg.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom header with decorative element
                    curriculumHeader
                    
                    // Pathway Selector
                    PathwaySelector(selectedPathway: $selectedPathway)
                        .padding(.top, ShedTheme.Space.m)
                        .padding(.bottom, ShedTheme.Space.s)
                    
                    // Module List
                    ScrollView {
                        LazyVStack(spacing: ShedTheme.Space.m) {
                            let modules = curriculumManager.getModules(for: selectedPathway)
                            
                            ForEach(Array(modules.enumerated()), id: \.element.id) { index, module in
                                ModuleCard(
                                    module: module,
                                    index: index + 1,
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
                            
                            // Bottom spacing
                            Spacer(minLength: ShedTheme.Space.xxl)
                        }
                        .padding(.horizontal, ShedTheme.Space.m)
                        .padding(.top, ShedTheme.Space.s)
                    }
                }
            }
            .navigationBarHidden(true)
            .sheet(item: $showingModuleDetail) { module in
                ModuleDetailView(module: module) { moduleToStart in
                    self.moduleToStart = moduleToStart
                    showingModuleDetail = nil
                }
            }
            .onChange(of: showingModuleDetail) { oldValue, newValue in
                if newValue == nil, let module = moduleToStart {
                    startModule(module)
                    moduleToStart = nil
                }
            }
        }
    }
    
    // MARK: - Custom Header
    
    private var curriculumHeader: some View {
        VStack(spacing: ShedTheme.Space.xs) {
            HStack {
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(ShedTheme.Colors.textSecondary)
                        .frame(width: 32, height: 32)
                        .background(ShedTheme.Colors.surface)
                        .clipShape(Circle())
                }
                
                Spacer()
                
                // Progress indicator
                let totalModules = CurriculumDatabase.allModules.count
                let completedModules = CurriculumDatabase.allModules.filter { curriculumManager.isModuleCompleted($0) }.count
                
                HStack(spacing: ShedTheme.Space.xs) {
                    Text("\(completedModules)/\(totalModules)")
                        .font(ShedTheme.Typography.caption)
                        .foregroundColor(ShedTheme.Colors.brass)
                    Text("complete")
                        .font(ShedTheme.Typography.captionSmall)
                        .foregroundColor(ShedTheme.Colors.textTertiary)
                }
            }
            .padding(.horizontal, ShedTheme.Space.m)
            .padding(.top, ShedTheme.Space.m)
            
            // Title with decorative lines
            HStack(spacing: ShedTheme.Space.m) {
                decorativeLine
                
                VStack(spacing: ShedTheme.Space.xxs) {
                    Text("CURRICULUM")
                        .font(ShedTheme.Typography.captionSmall)
                        .tracking(3)
                        .foregroundColor(ShedTheme.Colors.brass)
                    
                    Text("Guided Learning")
                        .font(ShedTheme.Typography.title)
                        .foregroundColor(ShedTheme.Colors.textPrimary)
                }
                
                decorativeLine
            }
            .padding(.vertical, ShedTheme.Space.s)
        }
        .background(
            // Subtle gradient at top
            LinearGradient(
                colors: [ShedTheme.Colors.surface.opacity(0.5), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 150)
            .ignoresSafeArea()
        , alignment: .top)
    }
    
    private var decorativeLine: some View {
        HStack(spacing: 4) {
            Rectangle()
                .fill(ShedTheme.Colors.stroke)
                .frame(height: 1)
            
            Circle()
                .fill(ShedTheme.Colors.brass)
                .frame(width: 4, height: 4)
        }
        .frame(maxWidth: 60)
    }
    
    private func startModule(_ module: CurriculumModule) {
        curriculumManager.setActiveModule(module.id)
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
                        withAnimation(ShedTheme.Motion.spring) {
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
                // Icon in a rounded square
                ZStack {
                    RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                        .fill(isSelected ? ShedTheme.Colors.brass : ShedTheme.Colors.surface)
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: pathway.icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(isSelected ? ShedTheme.Colors.bg : ShedTheme.Colors.textSecondary)
                }
                
                Text(pathway.rawValue)
                    .font(ShedTheme.Typography.captionSmall)
                    .foregroundColor(isSelected ? ShedTheme.Colors.brass : ShedTheme.Colors.textTertiary)
                    .lineLimit(1)
            }
            .frame(width: 80)
            .padding(.vertical, ShedTheme.Space.s)
            .background(
                RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                    .fill(isSelected ? ShedTheme.Colors.brassGlow : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Module Card

struct ModuleCard: View {
    let module: CurriculumModule
    let index: Int
    let isUnlocked: Bool
    let isCompleted: Bool
    let progressPercentage: Double
    
    var body: some View {
        HStack(spacing: ShedTheme.Space.m) {
            // Left: Module number with progress ring
            moduleIndicator
            
            // Center: Module Info
            VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                // Title row
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(module.title)
                            .font(ShedTheme.Typography.bodyEmphasis)
                            .foregroundColor(isUnlocked ? ShedTheme.Colors.textPrimary : ShedTheme.Colors.textTertiary)
                        
                        Text(module.mode.rawValue.uppercased())
                            .font(ShedTheme.Typography.captionSmall)
                            .tracking(1)
                            .foregroundColor(ShedTheme.Colors.textTertiary)
                    }
                    
                    Spacer()
                    
                    // Status indicator
                    statusBadge
                }
                
                Text(module.description)
                    .font(ShedTheme.Typography.caption)
                    .foregroundColor(ShedTheme.Colors.textSecondary)
                    .lineLimit(2)
                
                // Progress indicator for in-progress modules
                if isUnlocked && !isCompleted && progressPercentage > 0 {
                    HStack(spacing: ShedTheme.Space.xs) {
                        // Mini progress bar
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(ShedTheme.Colors.stroke)
                                    .frame(height: 3)
                                
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(ShedTheme.Colors.brass)
                                    .frame(width: geo.size.width * (progressPercentage / 100), height: 3)
                            }
                        }
                        .frame(height: 3)
                        
                        Text("\(Int(progressPercentage))%")
                            .font(ShedTheme.Typography.captionSmall)
                            .foregroundColor(ShedTheme.Colors.brass)
                            .frame(width: 32, alignment: .trailing)
                    }
                    .padding(.top, ShedTheme.Space.xxs)
                }
            }
            
            // Right: Chevron
            if isUnlocked {
                Image(systemName: "chevron.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(ShedTheme.Colors.textTertiary)
            }
        }
        .padding(ShedTheme.Space.m)
        .background(cardBackground)
        .overlay(cardOverlay)
        .opacity(isUnlocked ? 1.0 : 0.7)
    }
    
    // MARK: - Module Indicator (number + ring)
    
    @ViewBuilder
    private var moduleIndicator: some View {
        ZStack {
            // Progress ring background
            Circle()
                .stroke(ShedTheme.Colors.stroke, lineWidth: 2)
                .frame(width: 52, height: 52)
            
            // Progress ring (if in progress)
            if isUnlocked && !isCompleted && progressPercentage > 0 {
                Circle()
                    .trim(from: 0, to: progressPercentage / 100)
                    .stroke(ShedTheme.Colors.brass, style: StrokeStyle(lineWidth: 2, lineCap: .round))
                    .frame(width: 52, height: 52)
                    .rotationEffect(.degrees(-90))
            }
            
            // Completed ring
            if isCompleted {
                Circle()
                    .stroke(ShedTheme.Colors.success, lineWidth: 2)
                    .frame(width: 52, height: 52)
            }
            
            // Inner content
            ZStack {
                Circle()
                    .fill(innerCircleColor)
                    .frame(width: 44, height: 44)
                
                if isCompleted {
                    Image(systemName: "checkmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(ShedTheme.Colors.success)
                } else if !isUnlocked {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(ShedTheme.Colors.textTertiary)
                } else {
                    Text("\(index)")
                        .font(ShedTheme.Typography.heading)
                        .foregroundColor(ShedTheme.Colors.textPrimary)
                }
            }
        }
    }
    
    private var innerCircleColor: Color {
        if isCompleted {
            return ShedTheme.Colors.success.opacity(0.15)
        } else if isUnlocked {
            return ShedTheme.Colors.surface
        } else {
            return ShedTheme.Colors.surface.opacity(0.5)
        }
    }
    
    // MARK: - Status Badge
    
    @ViewBuilder
    private var statusBadge: some View {
        if isCompleted {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.system(size: 10))
                Text("Done")
                    .font(ShedTheme.Typography.captionSmall)
            }
            .foregroundColor(ShedTheme.Colors.success)
            .padding(.horizontal, ShedTheme.Space.xs)
            .padding(.vertical, 4)
            .background(ShedTheme.Colors.success.opacity(0.15))
            .clipShape(Capsule())
        } else if !isUnlocked {
            HStack(spacing: 4) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 9))
                Text("Locked")
                    .font(ShedTheme.Typography.captionSmall)
            }
            .foregroundColor(ShedTheme.Colors.textTertiary)
            .padding(.horizontal, ShedTheme.Space.xs)
            .padding(.vertical, 4)
            .background(ShedTheme.Colors.surface)
            .clipShape(Capsule())
        }
    }
    
    // MARK: - Card Styling
    
    @ViewBuilder
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
            .fill(ShedTheme.Colors.surface)
    }
    
    @ViewBuilder
    private var cardOverlay: some View {
        RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
            .stroke(
                isCompleted ? ShedTheme.Colors.success.opacity(0.3) :
                    (isUnlocked ? ShedTheme.Colors.stroke : ShedTheme.Colors.stroke.opacity(0.5)),
                lineWidth: ShedTheme.Stroke.thin
            )
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
            ZStack {
                ShedTheme.Colors.bg.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: ShedTheme.Space.l) {
                        // Header with emoji and decorative elements
                        moduleHeader
                        
                        // Stats row
                        if progress.attempts > 0 {
                            statsRow
                        }
                        
                        // Description section
                        descriptionSection
                        
                        // Requirements section
                        requirementsSection
                        
                        // Start Button
                        ShedButton(
                            title: progress.attempts > 0 ? "Continue Practice" : "Begin Module",
                            action: startModule,
                            style: .primary,
                            fullWidth: true,
                            size: .large
                        )
                        .padding(.horizontal, ShedTheme.Space.m)
                        .padding(.top, ShedTheme.Space.s)
                        
                        Spacer(minLength: ShedTheme.Space.xxl)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ShedTheme.Colors.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .foregroundColor(ShedTheme.Colors.brass)
                }
            }
        }
    }
    
    // MARK: - Module Header
    
    private var moduleHeader: some View {
        VStack(spacing: ShedTheme.Space.m) {
            // Large emoji with decorative ring
            ZStack {
                // Outer decorative ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [ShedTheme.Colors.brass.opacity(0.3), ShedTheme.Colors.brass.opacity(0.1)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 120, height: 120)
                
                // Inner circle
                Circle()
                    .fill(ShedTheme.Colors.surface)
                    .frame(width: 100, height: 100)
                
                Text(module.emoji)
                    .font(.system(size: 50))
            }
            
            // Title and pathway
            VStack(spacing: ShedTheme.Space.xs) {
                Text(module.title)
                    .font(ShedTheme.Typography.title)
                    .foregroundColor(ShedTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
                
                HStack(spacing: ShedTheme.Space.xs) {
                    Image(systemName: module.pathway.icon)
                        .font(.system(size: 12))
                    Text(module.pathway.rawValue)
                        .font(ShedTheme.Typography.caption)
                }
                .foregroundColor(ShedTheme.Colors.textTertiary)
            }
        }
        .padding(.top, ShedTheme.Space.l)
        .padding(.bottom, ShedTheme.Space.m)
    }
    
    // MARK: - Stats Row
    
    private var statsRow: some View {
        HStack(spacing: ShedTheme.Space.m) {
            statItem(value: "\(progress.attempts)", label: "Attempts", icon: "number")
            
            Rectangle()
                .fill(ShedTheme.Colors.stroke)
                .frame(width: 1, height: 40)
            
            statItem(value: "\(Int(progress.accuracy * 100))%", label: "Accuracy", icon: "target")
            
            Rectangle()
                .fill(ShedTheme.Colors.stroke)
                .frame(width: 1, height: 40)
            
            statItem(value: "\(progress.perfectSessions)", label: "Perfect", icon: "star.fill")
        }
        .padding(ShedTheme.Space.m)
        .background(ShedTheme.Colors.surface)
        .cornerRadius(ShedTheme.Radius.m)
        .padding(.horizontal, ShedTheme.Space.m)
    }
    
    private func statItem(value: String, label: String, icon: String) -> some View {
        VStack(spacing: ShedTheme.Space.xs) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(ShedTheme.Colors.brass)
            
            Text(value)
                .font(ShedTheme.Typography.heading)
                .foregroundColor(ShedTheme.Colors.textPrimary)
            
            Text(label)
                .font(ShedTheme.Typography.captionSmall)
                .foregroundColor(ShedTheme.Colors.textTertiary)
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Description Section
    
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
            sectionHeader(title: "About", icon: "info.circle")
            
            Text(module.description)
                .font(ShedTheme.Typography.body)
                .foregroundColor(ShedTheme.Colors.textSecondary)
                .lineSpacing(4)
        }
        .padding(.horizontal, ShedTheme.Space.m)
    }
    
    // MARK: - Requirements Section
    
    private var requirementsSection: some View {
        VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
            sectionHeader(title: "Requirements", icon: "checklist")
            
            VStack(spacing: ShedTheme.Space.xs) {
                CriteriaRow(
                    icon: "target",
                    text: "Accuracy",
                    requirement: "\(Int(module.completionCriteria.accuracyThreshold * 100))%+",
                    current: "\(Int(progress.accuracy * 100))%",
                    isMet: progress.accuracy >= module.completionCriteria.accuracyThreshold
                )
                
                CriteriaRow(
                    icon: "number",
                    text: "Questions",
                    requirement: "\(module.completionCriteria.minimumAttempts)+",
                    current: "\(progress.attempts)",
                    isMet: progress.attempts >= module.completionCriteria.minimumAttempts
                )
                
                if let perfectRequired = module.completionCriteria.perfectSessionsRequired {
                    CriteriaRow(
                        icon: "star.fill",
                        text: "Perfect Sessions",
                        requirement: "\(perfectRequired)",
                        current: "\(progress.perfectSessions)",
                        isMet: progress.perfectSessions >= perfectRequired
                    )
                }
            }
        }
        .padding(.horizontal, ShedTheme.Space.m)
    }
    
    private func sectionHeader(title: String, icon: String) -> some View {
        HStack(spacing: ShedTheme.Space.xs) {
            Image(systemName: icon)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(ShedTheme.Colors.brass)
            
            Text(title.uppercased())
                .font(ShedTheme.Typography.caption)
                .tracking(1)
                .foregroundColor(ShedTheme.Colors.textSecondary)
            
            Rectangle()
                .fill(ShedTheme.Colors.stroke)
                .frame(height: 1)
        }
    }
    
    private func startModule() {
        onStartModule(module)
    }
}

struct CriteriaRow: View {
    let icon: String
    let text: String
    let requirement: String
    let current: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: ShedTheme.Space.m) {
            // Icon
            ZStack {
                Circle()
                    .fill(isMet ? ShedTheme.Colors.success.opacity(0.15) : ShedTheme.Colors.surface)
                    .frame(width: 36, height: 36)
                
                Image(systemName: isMet ? "checkmark" : icon)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isMet ? ShedTheme.Colors.success : ShedTheme.Colors.textTertiary)
            }
            
            // Label and requirement
            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(ShedTheme.Typography.bodyEmphasis)
                    .foregroundColor(ShedTheme.Colors.textPrimary)
                
                Text("Need \(requirement)")
                    .font(ShedTheme.Typography.captionSmall)
                    .foregroundColor(ShedTheme.Colors.textTertiary)
            }
            
            Spacer()
            
            // Current value
            Text(current)
                .font(ShedTheme.Typography.heading)
                .foregroundColor(isMet ? ShedTheme.Colors.success : ShedTheme.Colors.textSecondary)
        }
        .padding(ShedTheme.Space.s)
        .background(ShedTheme.Colors.surface)
        .cornerRadius(ShedTheme.Radius.s)
        .overlay(
            RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                .stroke(isMet ? ShedTheme.Colors.success.opacity(0.3) : ShedTheme.Colors.stroke, lineWidth: ShedTheme.Stroke.hairline)
        )
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
