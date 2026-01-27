import SwiftUI

// MARK: - ShedTheme (Design Tokens)
// Single source of truth for colors, typography, spacing, radii, and strokes.
// Intentionally flat: no shadows, no textures, no gradients by default.

enum ShedTheme {

    // MARK: Colors
    enum Colors {
        // Backgrounds / surfaces
        static let bg = Color(hex: "#0F1115")         // app background (near-black, slightly cool)
        static let surface = Color(hex: "#161A22")    // cards / panels
        static let surfaceAlt = Color(hex: "#121620") // optional alternate surface

        // Text
        static let textPrimary = Color(hex: "#E7EAF0")
        static let textSecondary = Color(hex: "#A8B0C0")
        static let textTertiary = Color(hex: "#7C859A")

        // Accent (your "Brass Accent" family)
        static let brass = Color(hex: "#C8A46A")      // primary accent
        static let brassMuted = Color(hex: "#A88755") // secondary accent
        static let brassOnDark = Color(hex: "#E3D0A8")// highlight on very dark

        // Status (keep restrained)
        static let success = Color(hex: "#3CCB7F")
        static let danger  = Color(hex: "#FF5A6A")
        static let warning = Color(hex: "#F5B84B")

        // Lines
        static let divider = Color(hex: "#2A3140")
        static let stroke  = Color(hex: "#2F3748")
    }

    // MARK: Typography
    enum Type {
        // Use system fonts for maximum iOS-native polish and performance.
        // You can later swap in a custom font by changing only these definitions.
        static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
        static let heading = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .rounded)
        static let bodyEmphasis = Font.system(size: 16, weight: .semibold, design: .rounded)
        static let caption = Font.system(size: 13, weight: .regular, design: .rounded)
        static let mono = Font.system(size: 13, weight: .medium, design: .monospaced)
    }

    // MARK: Spacing
    enum Space {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 40
    }

    // MARK: Radius
    enum Radius {
        static let s: CGFloat = 10
        static let m: CGFloat = 16
        static let l: CGFloat = 22
    }

    // MARK: Stroke widths
    enum Stroke {
        static let hairline: CGFloat = 1
        static let strong: CGFloat = 2
    }

    // MARK: Animations (subtle)
    enum Motion {
        static let fast = Animation.easeOut(duration: 0.12)
        static let normal = Animation.easeOut(duration: 0.18)
    }
}

// MARK: - Helpers

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 255, 255, 255)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}