import SwiftUI

/// Practice view - drill selection screen
/// Placeholder for Phase 5 implementation
struct PracticeView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    Text("Practice drills will be implemented in Phase 5")
                        .font(.system(.body, design: .rounded))
                        .foregroundColor(.secondary)
                        .padding()
                    
                    // TODO: Phase 5 - Drill selection cards
                    // - Chord Spelling
                    // - Cadence Training
                    // - Scale Spelling
                    // - Interval Training
                }
                .padding()
            }
            .navigationTitle("Practice")
        }
    }
}

#Preview {
    PracticeView()
}
