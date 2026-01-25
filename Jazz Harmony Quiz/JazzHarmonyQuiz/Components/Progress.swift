import SwiftUI

/// Progress bar component showing completion percentage
struct ProgressBar: View {
    let progress: Double // 0.0 to 1.0
    var height: CGFloat = 8
    var showPercentage: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color.gray.opacity(0.2))
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(Color("BrassAccent"))
                        .frame(width: geometry.size.width * max(0, min(1, progress)))
                }
            }
            .frame(height: height)
            
            if showPercentage {
                Text("\(Int(progress * 100))%")
                    .font(.system(.caption, design: .rounded, weight: .medium))
                    .foregroundColor(.secondary)
            }
        }
    }
}

/// Session progress indicator (Question X of Y)
struct SessionProgress: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 8) {
            Text("Question \(current) of \(total)")
                .font(.system(.subheadline, design: .rounded, weight: .medium))
                .foregroundColor(.secondary)
            
            ProgressBar(progress: Double(current) / Double(total), height: 6)
                .frame(maxWidth: 120)
        }
    }
}

// MARK: - Previews

#Preview("Progress Bar - Empty") {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.0)
        ProgressBar(progress: 0.0, showPercentage: true)
    }
    .padding()
}

#Preview("Progress Bar - Partial") {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.25)
        ProgressBar(progress: 0.5)
        ProgressBar(progress: 0.75)
        ProgressBar(progress: 0.75, showPercentage: true)
    }
    .padding()
}

#Preview("Progress Bar - Full") {
    VStack(spacing: 20) {
        ProgressBar(progress: 1.0)
        ProgressBar(progress: 1.0, showPercentage: true)
    }
    .padding()
}

#Preview("Session Progress") {
    VStack(spacing: 20) {
        SessionProgress(current: 1, total: 10)
        SessionProgress(current: 5, total: 10)
        SessionProgress(current: 10, total: 10)
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: 20) {
        ProgressBar(progress: 0.65, showPercentage: true)
        SessionProgress(current: 7, total: 10)
    }
    .padding()
    .preferredColorScheme(.dark)
}
