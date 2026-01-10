import Foundation
import SwiftUI

// MARK: - Enums for Settings

enum AppTheme: String, CaseIterable, Identifiable {
    case light = "Light"
    case dark = "Dark"
    case system = "System"

    var id: String { rawValue }
}

enum ChordFont: String, CaseIterable, Identifiable {
    case system = "System"
    case caveat = "Caveat"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system:
            return "Default"
        case .caveat:
            return "Jazz (Handwritten)"
        }
    }
}

// MARK: - Settings Manager

class SettingsManager: ObservableObject {
    static let shared = SettingsManager()

    @Published var selectedTheme: AppTheme {
        didSet {
            UserDefaults.standard.set(selectedTheme.rawValue, forKey: "selectedTheme")
        }
    }

    @Published var selectedChordFont: ChordFont {
        didSet {
            UserDefaults.standard.set(selectedChordFont.rawValue, forKey: "selectedChordFont")
        }
    }

    private init() {
        // Load saved preferences or use defaults
        if let savedTheme = UserDefaults.standard.string(forKey: "selectedTheme"),
           let theme = AppTheme(rawValue: savedTheme) {
            self.selectedTheme = theme
        } else {
            self.selectedTheme = .system
        }

        if let savedFont = UserDefaults.standard.string(forKey: "selectedChordFont"),
           let font = ChordFont(rawValue: savedFont) {
            self.selectedChordFont = font
        } else {
            self.selectedChordFont = .system
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
        switch selectedChordFont {
        case .system:
            return .system(size: size, weight: weight)
        case .caveat:
            return .custom("Caveat", size: size + 4) // Slightly larger for handwritten feel
        }
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
}
