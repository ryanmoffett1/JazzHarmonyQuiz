import SwiftUI

// MARK: - Legacy Progress Wrappers (Using ShedTheme)

/// Progress bar component showing completion percentage
struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    var height: CGFloat = 6
    var showPercentage: Bool = false
    
    var body: some View {
        ShedProgressBar(progress: progress, height: height, showLabel: showPercentage)
    }
}

/// Session progress indicator (Question X of Y)
struct SessionProgress: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: ShedTheme.Space.xs) {
            Text("Question \(current) of \(total)")
                .font(ShedTheme.Typography.caption)
                .foregroundColor(ShedTheme.Colors.textSecondary)
            
            ShedProgressBar(progress: Double(current) / Double(total), height: 4)
                .frame(maxWidth: 100)
        }
    }
}

// MARK: - Previews

#Preview("Progress Bar - Empty") {
    VStack(spacing: ShedTheme.Space.m) {
        ProgressBar(progress: 0.0)
        ProgressBar(progress: 0.0, showPercentage: true)
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("Progress Bar - Partial") {
    VStack(spacing: ShedTheme.Space.m) {
        ProgressBar(progress: 0.25)
        ProgressBar(progress: 0.5)
        ProgressBar(progress: 0.75)
        ProgressBar(progress: 0.75, showPercentage: true)
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("Progress Bar - Full") {
    VStack(spacing: ShedTheme.Space.m) {
        ProgressBar(progress: 1.0)
        ProgressBar(progress: 1.0, showPercentage: true)
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("Session Progress") {
    VStack(spacing: ShedTheme.Space.m) {
        SessionProgress(current: 1, total: 10)
        SessionProgress(current: 5, total: 10)
        SessionProgress(current: 10, total: 10)
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}
