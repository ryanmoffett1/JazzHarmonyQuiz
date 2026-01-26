import SwiftUI

/// Quick Practice View - presents mixed practice from spaced repetition and weak areas
/// Per DESIGN.md Section 6.2
struct QuickPracticeView: View {
    @EnvironmentObject var settings: SettingsManager
    @EnvironmentObject var quizGame: QuizGame
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedDrill: DrillType?
    
    enum DrillType: Identifiable {
        case chord, cadence, scale, interval
        
        var id: Self { self }
    }
    
    private var dueItemsCount: Int {
        SpacedRepetitionStore.shared.totalDueCount()
    }
    
    private var dueByMode: [(mode: PracticeMode, count: Int)] {
        PracticeMode.allCases.compactMap { mode in
            let count = SpacedRepetitionStore.shared.dueCount(for: mode)
            return count > 0 ? (mode, count) : nil
        }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Header
                    headerSection
                    
                    Divider()
                    
                    // Due Items (if any)
                    if dueItemsCount > 0 {
                        dueItemsSection
                    }
                    
                    // Quick Drill Buttons
                    quickDrillsSection
                    
                    Spacer(minLength: 40)
                }
                .padding()
            }
            .navigationTitle("Quick Practice")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .navigationDestination(item: $selectedDrill) { drill in
                switch drill {
                case .chord:
                    ChordDrillView()
                        .environmentObject(quizGame)
                        .environmentObject(settings)
                case .cadence:
                    CadenceDrillView()
                        .environmentObject(settings)
                case .scale:
                    ScaleDrillView()
                        .environmentObject(settings)
                case .interval:
                    IntervalDrillView()
                        .environmentObject(settings)
                }
            }
        }
    }
    
    // MARK: - Sections
    
    private var headerSection: some View {
        VStack(spacing: 8) {
            if dueItemsCount > 0 {
                Text("📚")
                    .font(.system(size: 50))
                Text("\(dueItemsCount) Items Due")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("Items scheduled for review today")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else {
                Text("✨")
                    .font(.system(size: 50))
                Text("All Caught Up!")
                    .font(.title2)
                    .fontWeight(.bold)
                Text("No items due. Keep building fluency!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical)
    }
    
    private var dueItemsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("DUE FOR REVIEW")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundColor(.secondary)
            
            ForEach(dueByMode, id: \.mode) { item in
                Button {
                    navigateToDrill(for: item.mode)
                } label: {
                    HStack {
                        Text(item.mode.emoji)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.mode.rawValue)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text("\(item.count) item\(item.count == 1 ? "" : "s") due")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    private var quickDrillsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("QUICK DRILLS")
                .font(.system(.caption, design: .rounded, weight: .semibold))
                .foregroundColor(.secondary)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                quickDrillButton(
                    title: "Chords",
                    icon: "music.note.list",
                    color: .blue,
                    drill: .chord
                )
                
                quickDrillButton(
                    title: "Cadences",
                    icon: "arrow.triangle.2.circlepath",
                    color: .green,
                    drill: .cadence
                )
                
                quickDrillButton(
                    title: "Scales",
                    icon: "waveform.path.ecg",
                    color: .purple,
                    drill: .scale
                )
                
                quickDrillButton(
                    title: "Intervals",
                    icon: "tuningfork",
                    color: .orange,
                    drill: .interval
                )
            }
        }
    }
    
    private func quickDrillButton(title: String, icon: String, color: Color, drill: DrillType) -> some View {
        Button {
            selectedDrill = drill
        } label: {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 50, height: 50)
                    .background(color)
                    .cornerRadius(12)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - Navigation Helpers
    
    private func navigateToDrill(for mode: PracticeMode) {
        switch mode {
        case .chordDrill:
            selectedDrill = .chord
        case .cadenceDrill:
            selectedDrill = .cadence
        case .scaleDrill:
            selectedDrill = .scale
        case .intervalDrill:
            selectedDrill = .interval
        case .progressionDrill:
            selectedDrill = .cadence  // Progressions use cadence drill
        }
    }
}

#Preview("With Due Items") {
    QuickPracticeView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(QuizGame())
}

#Preview("All Caught Up") {
    QuickPracticeView()
        .environmentObject(SettingsManager.shared)
        .environmentObject(QuizGame())
}
