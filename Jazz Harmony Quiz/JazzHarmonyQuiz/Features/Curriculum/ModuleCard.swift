import SwiftUI

/// Card displaying a curriculum module with status and progress
/// States: Locked, Available, In-Progress, Completed
struct ModuleCard: View {
    let module: CurriculumModule
    let isUnlocked: Bool
    let isCompleted: Bool
    let progressPercentage: Double
    
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    /// Get the current progress data for this module
    private var progress: ModuleProgress {
        CurriculumManager.shared.getProgress(for: module.id)
    }
    
    /// Get a human-readable progress summary
    private var progressSummary: String {
        let criteria = module.completionCriteria
        let attemptsFraction = "\(progress.attempts)/\(criteria.minimumAttempts) questions"
        let accuracyPct = Int(progress.accuracy * 100)
        let accuracyNeeded = Int(criteria.accuracyThreshold * 100)
        return "\(attemptsFraction) • \(accuracyPct)% accuracy (need \(accuracyNeeded)%)"
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji & Status Icon
            statusIcon
            
            // Module Info
            VStack(alignment: .leading, spacing: 6) {
                headerRow
                
                Text(module.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                progressSection
            }
        }
        .padding()
        .background(cardBackground)
        .overlay(cardBorder)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
    
    // MARK: - Components
    
    private var statusIcon: some View {
        ZStack {
            Circle()
                .fill(statusColor.opacity(0.2))
                .frame(width: 60, height: 60)
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .font(.title)
                    .foregroundColor(ShedTheme.Colors.success)
            } else if !isUnlocked {
                Image(systemName: "lock.fill")
                    .font(.title2)
                    .foregroundColor(.gray)
            } else {
                Text(module.emoji)
                    .font(.largeTitle)
            }
        }
    }
    
    private var headerRow: some View {
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
    }
    
    @ViewBuilder
    private var progressSection: some View {
        if isUnlocked && !isCompleted {
            // Progress bar for in-progress modules
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
                
                // Show progress details
                if progress.attempts > 0 {
                    Text(progressSummary)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        } else if isCompleted {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                Text("Completed")
            }
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(ShedTheme.Colors.success)
        }
    }
    
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(isUnlocked ? settings.backgroundColor(for: colorScheme) : Color.gray.opacity(0.1))
    }
    
    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16)
            .stroke(
                isCompleted ? ShedTheme.Colors.success : (isUnlocked ? statusColor : Color.gray),
                lineWidth: isCompleted ? 2 : 1
            )
    }
    
    private var statusColor: Color {
        return ShedTheme.Colors.brass
    }
}

// MARK: - Preview

#Preview("Unlocked") {
    ModuleCard(
        module: CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads,
        isUnlocked: true,
        isCompleted: false,
        progressPercentage: 45
    )
    .environmentObject(SettingsManager.shared)
    .padding()
}

#Preview("Completed") {
    ModuleCard(
        module: CurriculumDatabase.harmonyFoundations_1_1_majorMinorTriads,
        isUnlocked: true,
        isCompleted: true,
        progressPercentage: 100
    )
    .environmentObject(SettingsManager.shared)
    .padding()
}

#Preview("Locked") {
    ModuleCard(
        module: CurriculumDatabase.harmonyFoundations_1_2_dimAugTriads,
        isUnlocked: false,
        isCompleted: false,
        progressPercentage: 0
    )
    .environmentObject(SettingsManager.shared)
    .padding()
}
