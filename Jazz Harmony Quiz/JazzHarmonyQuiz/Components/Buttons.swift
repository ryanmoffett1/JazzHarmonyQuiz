import SwiftUI

// MARK: - Legacy Button Wrappers (Using ShedTheme)
// These maintain API compatibility while using the new theme

/// Primary button style for main actions (brass accent color)
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var fullWidth: Bool = false
    
    var body: some View {
        ShedButton(
            title: title,
            action: action,
            style: .primary,
            isEnabled: isEnabled,
            fullWidth: fullWidth
        )
    }
}

/// Secondary button style for supporting actions
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var fullWidth: Bool = false
    
    var body: some View {
        ShedButton(
            title: title,
            action: action,
            style: .secondary,
            isEnabled: isEnabled,
            fullWidth: fullWidth
        )
    }
}

// MARK: - Previews

#Preview("Primary Button") {
    VStack(spacing: ShedTheme.Space.m) {
        PrimaryButton(title: "Start Practice", action: {})
        PrimaryButton(title: "Full Width", action: {}, fullWidth: true)
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("Secondary Button") {
    VStack(spacing: ShedTheme.Space.m) {
        SecondaryButton(title: "Skip", action: {})
        SecondaryButton(title: "Full Width", action: {}, fullWidth: true)
        SecondaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("Button Comparison") {
    VStack(spacing: ShedTheme.Space.m) {
        PrimaryButton(title: "Primary Action", action: {}, fullWidth: true)
        SecondaryButton(title: "Secondary Action", action: {}, fullWidth: true)
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}
