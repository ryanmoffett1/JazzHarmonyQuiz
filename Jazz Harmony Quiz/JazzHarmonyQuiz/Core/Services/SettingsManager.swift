import Foundation
import SwiftUI

// MARK: - Enums for Settings

enum AppTheme: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var id: String { rawValue }
}

// MARK: - Settings Manager

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        }
    }
    
    // Audio settings
    @Published var audioEnabled: Bool {
        didSet {
            UserDefaults.standard.set(audioEnabled, forKey: "audioEnabled")
            updateAudioManagerEnabled()
        }
    }
    
    @Published var playChordOnCorrect: Bool {
        didSet {
            UserDefaults.standard.set(playChordOnCorrect, forKey: "playChordOnCorrect")
        }
    }
    
    @Published var audioVolume: Float {
        didSet {
            UserDefaults.standard.set(audioVolume, forKey: "audioVolume")
            updateAudioManagerVolume()
        }
    }
    
    // Computed property for test compatibility (volume as Double)
    var volume: Double {
        get { Double(audioVolume) }
        set { audioVolume = Float(newValue) }
    }
    
    // Practice difficulty settings
    @Published var chordDifficulty: ChordType.ChordDifficulty {
        didSet {
            UserDefaults.standard.set(chordDifficulty.rawValue, forKey: "chordDifficulty")
        }
    }
    
    @Published var scaleDifficulty: ChordType.ChordDifficulty {
        didSet {
            UserDefaults.standard.set(scaleDifficulty.rawValue, forKey: "scaleDifficulty")
        }
    }
    
    @Published var intervalDifficulty: ChordType.ChordDifficulty {
        didSet {
            UserDefaults.standard.set(intervalDifficulty.rawValue, forKey: "intervalDifficulty")
        }
    }
    
    @Published var questionsPerSession: Int {
        didSet {
            UserDefaults.standard.set(questionsPerSession, forKey: "questionsPerSession")
        }
    }
    
    // Display settings
    @Published var showNoteNames: Bool {
        didSet {
            UserDefaults.standard.set(showNoteNames, forKey: "showNoteNames")
        }
    }
    
    @Published var autoPlay: Bool {
        didSet {
            UserDefaults.standard.set(autoPlay, forKey: "autoPlay")
        }
    }
    
    @Published var showTimer: Bool {
        didSet {
            UserDefaults.standard.set(showTimer, forKey: "showTimer")
        }
    }
    
    // Interval Ear Training settings
    @Published var autoPlayIntervals: Bool {
        didSet {
            UserDefaults.standard.set(autoPlayIntervals, forKey: "autoPlayIntervals")
        }
    }
    
    @Published var defaultIntervalStyle: AudioManager.IntervalPlaybackStyle {
        didSet {
            UserDefaults.standard.set(defaultIntervalStyle.rawValue, forKey: "defaultIntervalStyle")
        }
    }
    
    @Published var intervalTempo: Double {
        didSet {
            UserDefaults.standard.set(intervalTempo, forKey: "intervalTempo")
        }
    }

    // Chord Ear Training Settings
    @Published var autoPlayChords: Bool {
        didSet {
            UserDefaults.standard.set(autoPlayChords, forKey: "autoPlayChords")
        }
    }

    @Published var defaultChordStyle: AudioManager.ChordPlaybackStyle {
        didSet {
            UserDefaults.standard.set(defaultChordStyle.rawValue, forKey: "defaultChordStyle")
        }
    }

    @Published var chordTempo: Double {
        didSet {
            UserDefaults.standard.set(chordTempo, forKey: "chordTempo")
        }
    }

    // Cadence Ear Training Settings
    @Published var autoPlayCadences: Bool {
        didSet {
            UserDefaults.standard.set(autoPlayCadences, forKey: "autoPlayCadences")
        }
    }

    @Published var cadenceBPM: Double {
        didSet {
            UserDefaults.standard.set(cadenceBPM, forKey: "cadenceBPM")
        }
    }

    @Published var cadenceBeatsPerChord: Double {
        didSet {
            UserDefaults.standard.set(cadenceBeatsPerChord, forKey: "cadenceBeatsPerChord")
        }
    }

    // MARK: - Audio Manager Helpers
    
    private func updateAudioManagerEnabled() {
        AudioManager.shared.isEnabled = audioEnabled
    }
    
    private func updateAudioManagerVolume() {
        AudioManager.shared.setVolume(audioVolume)
    }
    
    func applyAudioSettings() {
        AudioManager.shared.isEnabled = audioEnabled
        AudioManager.shared.setVolume(audioVolume)
    }

    private init() {
        // Load saved preferences or use defaults
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.selectedTheme = theme
        } else {
            self.selectedTheme = .system
        }
        
        // Audio settings - load from UserDefaults
        self.audioEnabled = UserDefaults.standard.object(forKey: "audioEnabled") as? Bool ?? true
        self.playChordOnCorrect = UserDefaults.standard.object(forKey: "playChordOnCorrect") as? Bool ?? true
        self.audioVolume = UserDefaults.standard.object(forKey: "audioVolume") as? Float ?? 0.7
        
        // Practice difficulty settings
        if let savedDifficulty = UserDefaults.standard.string(forKey: "chordDifficulty"),
           let difficulty = ChordType.ChordDifficulty(rawValue: savedDifficulty) {
            self.chordDifficulty = difficulty
        } else {
            self.chordDifficulty = .beginner
        }
        
        if let savedDifficulty = UserDefaults.standard.string(forKey: "scaleDifficulty"),
           let difficulty = ChordType.ChordDifficulty(rawValue: savedDifficulty) {
            self.scaleDifficulty = difficulty
        } else {
            self.scaleDifficulty = .beginner
        }
        
        if let savedDifficulty = UserDefaults.standard.string(forKey: "intervalDifficulty"),
           let difficulty = ChordType.ChordDifficulty(rawValue: savedDifficulty) {
            self.intervalDifficulty = difficulty
        } else {
            self.intervalDifficulty = .beginner
        }
        
        self.questionsPerSession = UserDefaults.standard.object(forKey: "questionsPerSession") as? Int ?? 10
        self.showNoteNames = UserDefaults.standard.object(forKey: "showNoteNames") as? Bool ?? true
        self.autoPlay = UserDefaults.standard.object(forKey: "autoPlay") as? Bool ?? true
        self.showTimer = UserDefaults.standard.object(forKey: "showTimer") as? Bool ?? false
        
        // Interval ear training settings
        self.autoPlayIntervals = UserDefaults.standard.object(forKey: "autoPlayIntervals") as? Bool ?? true
        if let savedStyle = UserDefaults.standard.string(forKey: "defaultIntervalStyle"),
           let style = AudioManager.IntervalPlaybackStyle(rawValue: savedStyle) {
            self.defaultIntervalStyle = style
        } else {
            self.defaultIntervalStyle = .harmonic
        }
        self.intervalTempo = UserDefaults.standard.object(forKey: "intervalTempo") as? Double ?? 120

        // Chord ear training settings
        self.autoPlayChords = UserDefaults.standard.object(forKey: "autoPlayChords") as? Bool ?? true
        if let savedChordStyle = UserDefaults.standard.string(forKey: "defaultChordStyle"),
           let chordStyle = AudioManager.ChordPlaybackStyle(rawValue: savedChordStyle) {
            self.defaultChordStyle = chordStyle
        } else {
            self.defaultChordStyle = .block
        }
        self.chordTempo = UserDefaults.standard.object(forKey: "chordTempo") as? Double ?? 120

        // Cadence ear training settings
        self.autoPlayCadences = UserDefaults.standard.object(forKey: "autoPlayCadences") as? Bool ?? true
        self.cadenceBPM = UserDefaults.standard.object(forKey: "cadenceBPM") as? Double ?? 90
        self.cadenceBeatsPerChord = UserDefaults.standard.object(forKey: "cadenceBeatsPerChord") as? Double ?? 2.0

        // Apply audio settings after a brief delay to ensure AudioManager is initialized
        DispatchQueue.main.async { [weak self] in
            self?.applyAudioSettings()
        }
    }

    // MARK: - Theme Helpers

    var colorScheme: ColorScheme? {
        switch selectedTheme {
        case .light:
            return .light
        case .dark:
            return .dark
        case .system:
            return nil
        }
    }

    // MARK: - Font Helpers

    func chordDisplayFont(size: CGFloat = 28, weight: Font.Weight = .bold) -> Font {
        return .system(size: size, weight: weight, design: .rounded)
    }

    // MARK: - Dark Mode Colors

    // Background colors optimized for dark mode
    func backgroundColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(white: 0.11) : Color(.systemGray6)
    }

    func cardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(white: 0.18) : .white
    }

    func primaryAccent(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.blue.opacity(0.8) : .blue
    }

    func successColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.green.opacity(0.8) : .green
    }

    func errorColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.red.opacity(0.8) : .red
    }

    func warningColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.orange.opacity(0.8) : .orange
    }

    func infoColor(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.purple.opacity(0.8) : .purple
    }

    // Chord display background
    func chordDisplayBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.blue.opacity(0.2) : Color.blue.opacity(0.1)
    }

    // Selected note background
    func selectedNoteBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.blue.opacity(0.7) : .blue
    }

    // Text colors with proper contrast
    func primaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? .white : .primary
    }

    func secondaryText(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.white.opacity(0.7) : .secondary
    }
    
    // MARK: - Reset
    
    func resetToDefaults() {
        audioEnabled = true
        playChordOnCorrect = true
        audioVolume = 0.7
        chordDifficulty = .beginner
        scaleDifficulty = .beginner
        intervalDifficulty = .beginner
        questionsPerSession = 10
        showNoteNames = true
        autoPlay = true
        showTimer = false
        autoPlayIntervals = true
        defaultIntervalStyle = .harmonic
        intervalTempo = 120
        autoPlayChords = true
        defaultChordStyle = .block
        chordTempo = 120
        autoPlayCadences = true
        cadenceBPM = 90
        cadenceBeatsPerChord = 2.0
        selectedTheme = .system
    }
}
