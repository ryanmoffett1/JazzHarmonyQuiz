import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: ShedTheme.Space.m) {
                    // Theme Section
                    ShedCard {
                        VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                            ShedHeader(title: "Appearance")
                            
                            Picker("Appearance", selection: $settings.selectedTheme) {
                                ForEach(AppTheme.allCases) { theme in
                                    Text(theme.rawValue).tag(theme)
                                }
                            }
                            .pickerStyle(.segmented)
                            
                            Text("Choose how the app appears. System will follow your device settings.")
                                .font(ShedTheme.Typography.caption)
                                .foregroundColor(ShedTheme.Colors.textTertiary)
                        }
                    }

                    // About Section
                    ShedCard {
                        VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                            ShedHeader(title: "About")
                            ShedRow(label: "Version", value: "1.0")
                        }
                    }
                    
                    // Audio Section
                    ShedCard {
                        VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                            ShedHeader(title: "Audio")
                            
                            Toggle("Audio Enabled", isOn: $settings.audioEnabled)
                                .tint(ShedTheme.Colors.brass)
                            
                            if settings.audioEnabled {
                                ShedDivider()
                                
                                Toggle("Play Chord on Correct Answer", isOn: $settings.playChordOnCorrect)
                                    .tint(ShedTheme.Colors.brass)
                                
                                VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                                    HStack {
                                        Text("Volume")
                                            .font(ShedTheme.Typography.body)
                                            .foregroundColor(ShedTheme.Colors.textPrimary)
                                        Spacer()
                                        Text("\(Int(settings.audioVolume * 100))%")
                                            .font(ShedTheme.Typography.body)
                                            .foregroundColor(ShedTheme.Colors.textSecondary)
                                    }
                                    Slider(value: $settings.audioVolume, in: 0...1, step: 0.1)
                                        .tint(ShedTheme.Colors.brass)
                                }
                                
                                Button("Test Sound") {
                                    AudioManager.shared.playChord([
                                        Note(name: "C", midiNumber: 60, isSharp: false),
                                        Note(name: "E", midiNumber: 64, isSharp: false),
                                        Note(name: "G", midiNumber: 67, isSharp: false),
                                        Note(name: "B", midiNumber: 71, isSharp: false)
                                    ], duration: 1.5)
                                }
                                .font(ShedTheme.Typography.body)
                                .foregroundColor(ShedTheme.Colors.brass)
                            }
                            
                            Text("Hear the chord played back when you answer correctly. Great for ear training!")
                                .font(ShedTheme.Typography.caption)
                                .foregroundColor(ShedTheme.Colors.textTertiary)
                        }
                    }
                    
                    // Interval Ear Training Section
                    ShedCard {
                        VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                            ShedHeader(title: "Interval Ear Training")
                            
                            Toggle("Auto-Play Intervals", isOn: $settings.autoPlayIntervals)
                                .tint(ShedTheme.Colors.brass)
                            
                            ShedDivider()
                            
                            Picker("Playback Style", selection: $settings.defaultIntervalStyle) {
                                ForEach(AudioManager.IntervalPlaybackStyle.allCases, id: \.self) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(ShedTheme.Colors.brass)
                            
                            VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                                HStack {
                                    Text("Tempo")
                                        .font(ShedTheme.Typography.body)
                                        .foregroundColor(ShedTheme.Colors.textPrimary)
                                    Spacer()
                                    Text("\(Int(settings.intervalTempo)) BPM")
                                        .font(ShedTheme.Typography.body)
                                        .foregroundColor(ShedTheme.Colors.textSecondary)
                                }
                                Slider(value: $settings.intervalTempo, in: 60...180, step: 10)
                                    .tint(ShedTheme.Colors.brass)
                            }
                            
                            Button("Test Interval") {
                                let audioManager = AudioManager.shared
                                let rootNote = Note(name: "C", midiNumber: 60, isSharp: false)
                                let targetNote = Note(name: "E", midiNumber: 64, isSharp: false)
                                audioManager.playInterval(
                                    rootNote: rootNote,
                                    targetNote: targetNote,
                                    style: settings.defaultIntervalStyle,
                                    tempo: settings.intervalTempo
                                )
                            }
                            .font(ShedTheme.Typography.body)
                            .foregroundColor(ShedTheme.Colors.brass)
                            
                            Text("Configure how intervals are played during ear training exercises. Harmonic plays both notes together, melodic plays them in sequence.")
                                .font(ShedTheme.Typography.caption)
                                .foregroundColor(ShedTheme.Colors.textTertiary)
                        }
                    }
                    
                    // Chord Ear Training Section
                    ShedCard {
                        VStack(alignment: .leading, spacing: ShedTheme.Space.s) {
                            ShedHeader(title: "Chord Ear Training")
                            
                            Toggle("Auto-Play Chords", isOn: $settings.autoPlayChords)
                                .tint(ShedTheme.Colors.brass)
                            
                            ShedDivider()
                            
                            Picker("Default Playback Style", selection: $settings.defaultChordStyle) {
                                ForEach(AudioManager.ChordPlaybackStyle.allCases, id: \.self) { style in
                                    Text(style.rawValue).tag(style)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(ShedTheme.Colors.brass)
                            
                            VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
                                HStack {
                                    Text("Tempo")
                                        .font(ShedTheme.Typography.body)
                                        .foregroundColor(ShedTheme.Colors.textPrimary)
                                    Spacer()
                                    Text("\(Int(settings.chordTempo)) BPM")
                                        .font(ShedTheme.Typography.body)
                                        .foregroundColor(ShedTheme.Colors.textSecondary)
                                }
                                Slider(value: $settings.chordTempo, in: 60...180, step: 10)
                                    .tint(ShedTheme.Colors.brass)
                            }
                            
                            Button("Test Chord") {
                                let audioManager = AudioManager.shared
                                let chordNotes = [
                                    Note(name: "C", midiNumber: 60, isSharp: false),
                                    Note(name: "E", midiNumber: 64, isSharp: false),
                                    Note(name: "G", midiNumber: 67, isSharp: false),
                                    Note(name: "B", midiNumber: 71, isSharp: false)
                                ]
                                audioManager.playChord(
                                    chordNotes,
                                    style: settings.defaultChordStyle,
                                    tempo: settings.chordTempo
                                )
                            }
                            .font(ShedTheme.Typography.body)
                            .foregroundColor(ShedTheme.Colors.brass)
                            
                            Text("Configure how chords are played during ear training exercises. Choose from block chords, arpeggios, or guide tones only.")
                                .font(ShedTheme.Typography.caption)
                                .foregroundColor(ShedTheme.Colors.textTertiary)
                        }
                    }
                }
                .padding(.horizontal, ShedTheme.Space.m)
            }
            .background(ShedTheme.Colors.bg)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(ShedTheme.Colors.bg, for: .navigationBar)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(ShedTheme.Colors.brass)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsManager.shared)
            .preferredColorScheme(.dark)
    }
}
