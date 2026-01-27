import SwiftUI

// MARK: - View Extensions

extension View {
    /// Apply themed segmented picker style
    func shedSegmentedPicker() -> some View {
        self.pickerStyle(.segmented)
            .tint(ShedTheme.Colors.brass)
    }
}

// MARK: - Status Colors

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
