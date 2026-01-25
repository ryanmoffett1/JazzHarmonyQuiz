import SwiftUI

/// Progress tab view - statistics and achievements
/// Placeholder for Phase 6 implementation
struct ProgressTabView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Progress tracking will be implemented in Phase 6")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding()
                    
                    // TODO: Phase 6 - Progress screens
                    // - Stats Overview
                    // - By Category (chords, scales, etc.)
                    // - By Key (12 keys breakdown)
                    // - History (calendar view)
                    // - Achievements
                }
                .padding()
            }
            .navigationTitle("Progress")
        }
    }
}

#Preview {
    ProgressTabView()
}
