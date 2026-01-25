import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // Theme Section
                Section {
                    Picker("Appearance", selection: $settings.selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Theme")
                } footer: {
                    Text("Choose how the app appears. System will follow your device settings.")
                        .foregroundColor(settings.secondaryText(for: colorScheme))
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(settings.primaryText(for: colorScheme))
                        Spacer()
                        Text("1.0")
                            .foregroundColor(settings.secondaryText(for: colorScheme))
                    }
                } header: {
                    Text("About")
                }
                
                // Audio Section
                Section {
                    Toggle("Audio Enabled", isOn: $settings.audioEnabled)
                    
                    if settings.audioEnabled {
                        Toggle("Play Chord on Correct Answer", isOn: $settings.playChordOnCorrect)
                        
                        VStack(alignment: .leading) {
                            HStack {
                                Text("Volume")
                                Spacer()
                                Text("\(Int(settings.audioVolume * 100))%")
                                    .foregroundColor(settings.secondaryText(for: colorScheme))
                            }
                            Slider(value: $settings.audioVolume, in: 0...1, step: 0.1)
                        }
                        
                        Button("Test Sound") {
                            AudioManager.shared.playChord([
                                Note(name: "C", midiNumber: 60, isSharp: false),
                                Note(name: "E", midiNumber: 64, isSharp: false),
                                Note(name: "G", midiNumber: 67, isSharp: false),
                                Note(name: "B", midiNumber: 71, isSharp: false)
                            ], duration: 1.5)
                        }
                        .foregroundColor(.blue)
                    }
                } header: {
                    Text("Audio")
                } footer: {
                    Text("Hear the chord played back when you answer correctly. Great for ear training!")
                        .foregroundColor(settings.secondaryText(for: colorScheme))
                }
                
                // Interval Ear Training Section
                Section {
                    Toggle("Auto-Play Intervals", isOn: $settings.autoPlayIntervals)
                    
                    Picker("Playback Style", selection: $settings.defaultIntervalStyle) {
                        ForEach(AudioManager.IntervalPlaybackStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Tempo")
                            Spacer()
                            Text("\(Int(settings.intervalTempo)) BPM")
                                .foregroundColor(settings.secondaryText(for: colorScheme))
                        }
                        Slider(value: $settings.intervalTempo, in: 60...180, step: 10)
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
                    .foregroundColor(.blue)
                } header: {
                    Text("Interval Ear Training")
                } footer: {
                    Text("Configure how intervals are played during ear training exercises. Harmonic plays both notes together, melodic plays them in sequence.")
                        .foregroundColor(settings.secondaryText(for: colorScheme))
                }
                
                // Chord Ear Training Section
                Section {
                    Toggle("Auto-Play Chords", isOn: $settings.autoPlayChords)
                    
                    Picker("Default Playback Style", selection: $settings.defaultChordStyle) {
                        ForEach(AudioManager.ChordPlaybackStyle.allCases, id: \.self) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Tempo")
                            Spacer()
                            Text("\(Int(settings.chordTempo)) BPM")
                                .foregroundColor(settings.secondaryText(for: colorScheme))
                        }
                        Slider(value: $settings.chordTempo, in: 60...180, step: 10)
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
                    .foregroundColor(.blue)
                } header: {
                    Text("Chord Ear Training")
                } footer: {
                    Text("Configure how chords are played during ear training exercises. Choose from block chords, arpeggios, or guide tones only.")
                        .foregroundColor(settings.secondaryText(for: colorScheme))
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(settings.backgroundColor(for: colorScheme).ignoresSafeArea())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsManager.shared)
    }
}
