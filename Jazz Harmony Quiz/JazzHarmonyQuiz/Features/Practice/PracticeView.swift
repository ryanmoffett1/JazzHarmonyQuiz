import SwiftUI

/// Practice view - drill selection screen per DESIGN.md
struct PracticeView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Chord Drill
                    NavigationLink {
                        ChordDrillView()
                            .environmentObject(quizGame)
                            .environmentObject(settings)
                    } label: {
                        DrillSelectionCard(
                            title: "Chord Spelling",
                            subtitle: "Spell chord tones on the keyboard",
                            icon: "music.note.list",
                            color: .blue
                        )
                    }
                    
                    // Cadence Drill
                    NavigationLink {
                        CadenceDrillView()
                            .environmentObject(settings)
                    } label: {
                        DrillSelectionCard(
                            title: "Cadence Training",
                            subtitle: "Identify chord progressions by ear",
                            icon: "arrow.triangle.2.circlepath",
                            color: .green
                        )
                    }
                    
                    // Scale Drill
                    NavigationLink {
                        ScaleDrillView()
                            .environmentObject(settings)
                    } label: {
                        DrillSelectionCard(
                            title: "Scale Spelling",
                            subtitle: "Build scales from any root",
                            icon: "waveform.path.ecg",
                            color: .purple
                        )
                    }
                    
                    // Interval Drill
                    NavigationLink {
                        IntervalDrillView()
                            .environmentObject(settings)
                    } label: {
                        DrillSelectionCard(
                            title: "Interval Training",
                            subtitle: "Recognize intervals by ear",
                            icon: "tuningfork",
                            color: .orange
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Practice")
        }
    }
}

// MARK: - Drill Selection Card

struct DrillSelectionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    PracticeView()
        .environmentObject(QuizGame())
        .environmentObject(SettingsManager.shared)
}
