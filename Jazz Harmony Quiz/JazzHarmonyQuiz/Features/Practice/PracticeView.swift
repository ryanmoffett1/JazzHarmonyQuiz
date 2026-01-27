import SwiftUI

/// Practice view - drill selection screen per DESIGN.md
/// Using ShedTheme for flat modern UI
struct PracticeView: View {
    @EnvironmentObject var quizGame: QuizGame
    @EnvironmentObject var settings: SettingsManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: ShedTheme.Space.m) {
                    // Chord Drill
                    NavigationLink {
                        ChordDrillView()
                            .environmentObject(quizGame)
                            .environmentObject(settings)
                    } label: {
                        DrillSelectionCard(
                            title: "Chord Spelling",
                            subtitle: "Spell chord tones on the keyboard",
                            icon: "music.note.list"
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
                            icon: "arrow.triangle.2.circlepath"
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
                            icon: "waveform.path.ecg"
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
                            icon: "tuningfork"
                        )
                    }
                }
                .padding(.horizontal, ShedTheme.Space.m)
            }
            .background(ShedTheme.Colors.bg)
            .navigationTitle("Practice")
            .toolbarBackground(ShedTheme.Colors.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

// MARK: - Drill Selection Card

struct DrillSelectionCard: View {
    let title: String
    let subtitle: String
    let icon: String
    
    var body: some View {
        HStack(spacing: ShedTheme.Space.m) {
            // Icon with brass accent background
            ShedIcon(systemName: icon, size: .large, color: ShedTheme.Colors.brass)
            
            VStack(alignment: .leading, spacing: ShedTheme.Space.xxs) {
                Text(title)
                    .font(ShedTheme.Type.bodyBold)
                    .foregroundColor(ShedTheme.Colors.textPrimary)
                
                Text(subtitle)
                    .font(ShedTheme.Type.body)
                    .foregroundColor(ShedTheme.Colors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(ShedTheme.Colors.textTertiary)
                .font(.subheadline)
        }
        .padding(ShedTheme.Space.m)
        .background(ShedTheme.Colors.surface)
        .cornerRadius(ShedTheme.Radius.m)
        .overlay(
            RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                .stroke(ShedTheme.Colors.stroke, lineWidth: ShedTheme.Stroke.thin)
        )
    }
}

#Preview {
    PracticeView()
        .environmentObject(QuizGame())
        .environmentObject(SettingsManager.shared)
        .preferredColorScheme(.dark)
}
