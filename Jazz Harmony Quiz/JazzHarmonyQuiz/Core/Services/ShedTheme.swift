import SwiftUI

// MARK: - ShedTheme (Design Tokens)
// Visual identity: Professional musician's practice tool
// Aesthetic inspiration: Vintage jazz club meets high-end audio equipment
// Dark, confident, warm brass accents, subtle depth without shadows

enum ShedTheme {

    // MARK: Colors
    enum Colors {
        // Backgrounds - deep, rich blacks with subtle warmth
        static let bg = Color(hex: "#0A0B0F")              // deepest black, slightly warm
        static let surface = Color(hex: "#141519")          // cards - subtle lift
        static let surfaceElevated = Color(hex: "#1C1D24")  // modals, popovers
        static let surfacePressed = Color(hex: "#0E0F12")   // pressed states

        // Text hierarchy - warm whites
        static let textPrimary = Color(hex: "#F5F3EF")      // warm white
        static let textSecondary = Color(hex: "#9B978F")    // warm gray
        static let textTertiary = Color(hex: "#5C5A55")     // muted

        // Brass accent family - the signature color (Quick Practice, main app)
        static let brass = Color(hex: "#D4A857")            // rich gold brass
        static let brassLight = Color(hex: "#E8C878")       // highlights
        static let brassMuted = Color(hex: "#8B7355")       // subtle accents
        static let brassGlow = Color(hex: "#D4A857").opacity(0.12) // subtle glow effect

        // Status colors - muted, professional
        static let success = Color(hex: "#5BA37A")          // muted sage green
        static let danger = Color(hex: "#C75B5B")           // muted coral red
        static let warning = Color(hex: "#C9A555")          // warm amber

        // Lines & borders
        static let divider = Color(hex: "#252730")          // subtle separation
        static let stroke = Color(hex: "#2D2F38")           // card borders
        static let strokeAccent = Color(hex: "#3D3830")     // warm tinted stroke
    }

    // MARK: Typography
    enum Typography {
        // Display - for large chord symbols, key numbers
        static let display = Font.system(size: 48, weight: .bold, design: .rounded)
        static let displayMedium = Font.system(size: 36, weight: .semibold, design: .rounded)
        
        // Standard hierarchy
        static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
        static let title = Font.system(size: 28, weight: .bold, design: .rounded)
        static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
        static let heading = Font.system(size: 20, weight: .semibold, design: .rounded)
        static let body = Font.system(size: 16, weight: .regular, design: .default)
        static let bodyEmphasis = Font.system(size: 16, weight: .semibold, design: .default)
        static let bodyBold = Font.system(size: 16, weight: .semibold, design: .default)
        static let caption = Font.system(size: 13, weight: .medium, design: .default)
        static let captionSmall = Font.system(size: 11, weight: .medium, design: .default)
        
        // Monospace for chord symbols and musical notation
        static let mono = Font.system(size: 14, weight: .medium, design: .monospaced)
        static let monoLarge = Font.system(size: 24, weight: .semibold, design: .monospaced)
    }

    // MARK: Spacing - generous, breathable
    enum Space {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
        static let xxxl: CGFloat = 64
    }

    // MARK: Radius - softer, more refined
    enum Radius {
        static let xs: CGFloat = 6
        static let s: CGFloat = 10
        static let m: CGFloat = 14
        static let l: CGFloat = 20
        static let xl: CGFloat = 28
        static let full: CGFloat = 999 // pill shape
    }

    // MARK: Stroke widths
    enum Stroke {
        static let hairline: CGFloat = 0.5
        static let thin: CGFloat = 1
        static let medium: CGFloat = 1.5
        static let strong: CGFloat = 2
    }

    // MARK: Animations
    enum Motion {
        static let fast = Animation.easeOut(duration: 0.15)
        static let standard = Animation.easeOut(duration: 0.25)
        static let slow = Animation.easeInOut(duration: 0.4)
        static let spring = Animation.spring(response: 0.35, dampingFraction: 0.7)
        static let springBouncy = Animation.spring(response: 0.4, dampingFraction: 0.6)
    }
    
    // MARK: Effects
    enum Effects {
        // Subtle inner glow for highlighted cards
        static func innerGlow(color: Color = Colors.brass, radius: CGFloat = 20) -> some View {
            RoundedRectangle(cornerRadius: Radius.m)
                .stroke(color.opacity(0.3), lineWidth: 1)
                .blur(radius: 4)
        }
        
        // Subtle gradient for depth (use sparingly)
        static var subtleDepth: LinearGradient {
            LinearGradient(
                colors: [Color.white.opacity(0.03), Color.clear],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        
        // Decorative line for visual interest
        static func accentLine(color: Color = Colors.brass, width: CGFloat = 40) -> some View {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: width, height: 3)
        }
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

// MARK: - View Extensions

extension View {
    /// Apply themed segmented picker style
    func shedSegmentedPicker() -> some View {
        self.pickerStyle(.segmented)
            .tint(ShedTheme.Colors.brass)
    }
}

// MARK: - Theme Color Helpers

extension ShedTheme.Colors {
    /// Get appropriate color for a status/state
    static func statusColor(isCorrect: Bool) -> Color {
        isCorrect ? success : danger
    }
    
    /// Get background color for a status/state
    static func statusBackground(isCorrect: Bool) -> Color {
        isCorrect ? success.opacity(0.15) : danger.opacity(0.15)
    }
    
    /// Get highlight color (replaces generic Color.blue)
    static var highlight: Color { brass }
    
    /// Get selection background color
    static var selectionBackground: Color { brassGlow }
}