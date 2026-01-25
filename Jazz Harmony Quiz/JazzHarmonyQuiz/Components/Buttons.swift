import SwiftUI

/// Primary button style for main actions (brass accent color)
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var fullWidth: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isEnabled ? Color("BrassAccent") : Color.gray.opacity(0.3))
                )
        }
        .disabled(!isEnabled)
    }
}

/// Secondary button style for supporting actions
struct SecondaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    var fullWidth: Bool = false
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(.body, design: .rounded, weight: .medium))
                .foregroundColor(Color("BrassAccent"))
                .frame(maxWidth: fullWidth ? .infinity : nil)
                .padding(.horizontal, 24)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .strokeBorder(Color("BrassAccent"), lineWidth: 2)
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
    }
}

// MARK: - Previews

#Preview("Primary Button") {
    VStack(spacing: 20) {
        PrimaryButton(title: "Start Practice", action: {})
        PrimaryButton(title: "Full Width", action: {}, fullWidth: true)
        PrimaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding()
}

#Preview("Secondary Button") {
    VStack(spacing: 20) {
        SecondaryButton(title: "Skip", action: {})
        SecondaryButton(title: "Full Width", action: {}, fullWidth: true)
        SecondaryButton(title: "Disabled", action: {}, isEnabled: false)
    }
    .padding()
}

#Preview("Button Comparison") {
    VStack(spacing: 20) {
        PrimaryButton(title: "Primary Action", action: {}, fullWidth: true)
        SecondaryButton(title: "Secondary Action", action: {}, fullWidth: true)
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: 20) {
        PrimaryButton(title: "Primary", action: {}, fullWidth: true)
        SecondaryButton(title: "Secondary", action: {}, fullWidth: true)
    }
    .padding()
    .preferredColorScheme(.dark)
}
