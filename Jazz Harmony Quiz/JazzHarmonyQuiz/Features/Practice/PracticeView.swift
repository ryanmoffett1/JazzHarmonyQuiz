import SwiftUI

/// Practice view - drill selection screen per DESIGN.md
struct PracticeView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
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
                            accentColor: Color("BrassAccent")
                        )
                    }
                    
                    // Cadence Drill
                    NavigationLink {
                        CadenceDrillView()
                            .environmentObject(CadenceGame())
                            .environmentObject(settings)
                    } label: {
                        DrillSelectionCard(
                            title: "Cadence Training",
                            subtitle: "Identify chord progressions by ear",
                            icon: "arrow.triangle.2.circlepath",
                            accentColor: Color("BrassAccent")
                        )
                    }
                    
                    // Scale Drill
                    NavigationLink {
                        ScaleDrillView()
                            .environmentObject(ScaleGame())
                            .environmentObject(settings)
                    } label: {
                        DrillSelectionCard(
                            title: "Scale Spelling",
                            subtitle: "Build scales from any root",
                            icon: "waveform.path.ecg",
                            accentColor: Color("BrassAccent")
                        )
                    }
                    
                    // Interval Drill
                    NavigationLink {
                        IntervalDrillView()
                            .environmentObject(IntervalGame())
                            .environmentObject(settings)
                    } label: {
                        DrillSelectionCard(
                            title: "Interval Training",
                            subtitle: "Recognize intervals by ear",
                            icon: "tuningfork",
                            accentColor: Color("BrassAccent")
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
    let accentColor: Color
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon with brass accent background
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(accentColor)
                .frame(width: 50, height: 50)
                .background(accentColor.opacity(colorScheme == .dark ? 0.2 : 0.15))
                .cornerRadius(10)
            
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
                .font(.subheadline)
        }
        .padding()
        .background(Color(uiColor: colorScheme == .dark ? .secondarySystemBackground : .systemBackground))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    PracticeView()
        .environmentObject(QuizGame())
        .environmentObject(SettingsManager.shared)
}
