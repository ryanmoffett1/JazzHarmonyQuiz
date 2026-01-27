import SwiftUI

/// Modal sheet showing module details and completion requirements
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
                    headerSection
                    
                    Divider()
                    
                    aboutSection
                    
                    requirementsSection
                    
                    startButton
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
    
    // MARK: - Sections
    
    private var headerSection: some View {
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
    }
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("About This Module", systemImage: "info.circle")
                .font(.headline)
            
            Text(module.description)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal)
    }
    
    private var requirementsSection: some View {
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
    }
    
    private var startButton: some View {
        Button(action: { onStartModule(module) }) {
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
    
    private var pathwayColor: Color {
        return ShedTheme.Colors.brass
    }
}

// MARK: - Criteria Row

/// Single row showing a completion criterion with current status
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
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(current)
                .fontWeight(.semibold)
                .foregroundColor(isMet ? .green : .orange)
            
            if isMet {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(ShedTheme.Colors.success)
            }
        }
        .padding(12)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#Preview {
    ModuleDetailView(
        module: CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads
    ) { module in
        print("Starting module: \(module.title)")
    }
    .environmentObject(SettingsManager.shared)
}
