import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss
    
    /// When true, show Done button (for sheet presentation)
    /// When false, hide Done button (for tab presentation)
    var showDoneButton: Bool = false
    
    @State private var showResetStatsAlert = false
    @State private var showResetAllAlert = false
    @State private var showExportSheet = false

    var body: some View {
        NavigationView {
            Form {
                audioSection
                intervalEarTrainingSection
                chordEarTrainingSection
                displaySection
                practiceDefaultsSection
                dataSection
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if showDoneButton {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            dismiss()
                        }
                    }
                }
            }
            .background(settings.backgroundColor(for: colorScheme).ignoresSafeArea())
            .alert("Reset Statistics", isPresented: $showResetStatsAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    resetStatistics()
                }
            } message: {
                Text("This will reset all your practice statistics and achievements. Your curriculum progress will be preserved.")
            }
            .alert("Reset All Data", isPresented: $showResetAllAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset Everything", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will permanently delete all your data including statistics, curriculum progress, and settings. This cannot be undone.")
            }
            .sheet(isPresented: $showExportSheet) {
                ExportProgressView()
            }
        }
    }
    
    // MARK: - Audio Section
    
    private var audioSection: some View {
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
                .foregroundColor(ShedTheme.Colors.brass)
            }
        } header: {
            Text("Audio")
        } footer: {
            Text("Hear the chord played back when you answer correctly. Great for ear training!")
                .foregroundColor(settings.secondaryText(for: colorScheme))
        }
    }
    
    // MARK: - Interval Ear Training Section
    
    private var intervalEarTrainingSection: some View {
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
            .foregroundColor(ShedTheme.Colors.brass)
        } header: {
            Text("Interval Ear Training")
        } footer: {
            Text("Configure how intervals are played during ear training exercises. Harmonic plays both notes together, melodic plays them in sequence.")
                .foregroundColor(settings.secondaryText(for: colorScheme))
        }
    }
    
    // MARK: - Chord Ear Training Section
    
    private var chordEarTrainingSection: some View {
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
            .foregroundColor(ShedTheme.Colors.brass)
        } header: {
            Text("Chord Ear Training")
        } footer: {
            Text("Configure how chords are played during ear training exercises. Choose from block chords, arpeggios, or guide tones only.")
                .foregroundColor(settings.secondaryText(for: colorScheme))
        }
    }
    
    // MARK: - Display Section
    
    private var displaySection: some View {
        Section {
            Picker("Appearance", selection: $settings.selectedTheme) {
                ForEach(AppTheme.allCases) { theme in
                    Text(theme.rawValue).tag(theme)
                }
            }
            .pickerStyle(.segmented)
        } header: {
            Text("Display")
        } footer: {
            Text("Choose how the app appears. System will follow your device settings.")
                .foregroundColor(settings.secondaryText(for: colorScheme))
        }
    }
    
    // MARK: - Practice Defaults Section
    
    private var practiceDefaultsSection: some View {
        Section {
            Stepper(value: $settings.questionsPerSession, in: 5...30, step: 5) {
                HStack {
                    Text("Default Questions")
                    Spacer()
                    Text("\(settings.questionsPerSession)")
                        .foregroundColor(settings.secondaryText(for: colorScheme))
                }
            }
            
            Toggle("Haptic Feedback", isOn: $settings.hapticFeedback)
        } header: {
            Text("Practice Defaults")
        } footer: {
            Text("These settings apply when starting new practice sessions.")
                .foregroundColor(settings.secondaryText(for: colorScheme))
        }
    }
    
    // MARK: - Data Section
    
    private var dataSection: some View {
        Section {
            Button {
                showExportSheet = true
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                    Text("Export Progress")
                }
            }
            
            Button(role: .destructive) {
                showResetStatsAlert = true
            } label: {
                HStack {
                    Image(systemName: "chart.bar.xaxis")
                    Text("Reset Statistics")
                }
            }
            
            Button(role: .destructive) {
                showResetAllAlert = true
            } label: {
                HStack {
                    Image(systemName: "trash")
                    Text("Reset All Data")
                }
            }
        } header: {
            Text("Data")
        } footer: {
            Text("Export your progress to share or backup. Reset options cannot be undone.")
                .foregroundColor(settings.secondaryText(for: colorScheme))
        }
    }
    
    // MARK: - About Section
    
    private var aboutSection: some View {
        Section {
            HStack {
                Text("Version")
                Spacer()
                Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0")
                    .foregroundColor(settings.secondaryText(for: colorScheme))
            }
            
            Link(destination: URL(string: "mailto:feedback@shedpro.app?subject=Shed%20Pro%20Feedback")!) {
                HStack {
                    Image(systemName: "envelope")
                    Text("Send Feedback")
                    Spacer()
                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(settings.secondaryText(for: colorScheme))
                }
            }
            
            // Note: Update with actual App Store ID after app submission
            if let url = URL(string: "https://apps.apple.com/app/shed-pro/id123456789?action=write-review") {
                Link(destination: url) {
                    HStack {
                        Image(systemName: "star")
                        Text("Rate Shed Pro")
                        Spacer()
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundColor(settings.secondaryText(for: colorScheme))
                    }
                }
            }
        } header: {
            Text("About")
        }
    }
    
    // MARK: - Actions
    
    private func resetStatistics() {
        // Reset spaced repetition data
        SpacedRepetitionStore.shared.resetAll()
        
        // Generate haptic feedback
        if settings.hapticFeedback {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    private func resetAllData() {
        // Reset statistics
        resetStatistics()
        
        // Reset curriculum progress
        CurriculumManager.shared.resetProgress()
        
        // Reset settings to defaults
        settings.resetToDefaults()
        
        // Generate haptic feedback
        if settings.hapticFeedback {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
        }
    }
}

// MARK: - Export Progress View

struct ExportProgressView: View {
    @Environment(\.dismiss) var dismiss
    @State private var exportData: String = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "square.and.arrow.up.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(ShedTheme.Colors.brass)
                
                Text("Export Your Progress")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your practice data can be exported as a JSON file for backup or sharing.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                if let data = generateExportData() {
                    ShareLink(item: data, preview: SharePreview("Shed Pro Progress", image: Image(systemName: "music.note"))) {
                        Label("Share Progress Data", systemImage: "square.and.arrow.up")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(ShedTheme.Colors.brass)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.top, 40)
            .navigationTitle("Export")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func generateExportData() -> String? {
        let completedModuleIds = CurriculumManager.shared.allModules
            .filter { CurriculumManager.shared.isModuleCompleted($0) }
            .map { $0.id.uuidString }
        
        let exportObject: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "appVersion": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            "totalModulesCompleted": CurriculumManager.shared.getTotalModulesCompleted(),
            "completedModuleIds": completedModuleIds,
            "totalItemsDue": SpacedRepetitionStore.shared.totalDueCount()
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: exportObject, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        
        return jsonString
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsManager.shared)
    }
}
