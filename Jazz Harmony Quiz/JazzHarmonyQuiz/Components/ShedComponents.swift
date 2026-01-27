import SwiftUI

// MARK: - ShedButton

/// Primary button style using ShedTheme tokens
/// Distinctive brass-accented buttons with subtle depth
struct ShedButton: View {
    let title: String
    let action: () -> Void
    var style: ButtonVariant = .primary
    var isEnabled: Bool = true
    var fullWidth: Bool = false
    var size: ButtonSize = .medium
    
    enum ButtonVariant {
        case primary    // Brass accent, filled with glow
        case secondary  // Outlined with brass
        case ghost      // Text only
    }
    
    enum ButtonSize {
        case small, medium, large
        
        var verticalPadding: CGFloat {
            switch self {
            case .small: return ShedTheme.Space.xs
            case .medium: return ShedTheme.Space.s + 2
            case .large: return ShedTheme.Space.m
            }
        }
        
        var horizontalPadding: CGFloat {
            switch self {
            case .small: return ShedTheme.Space.m
            case .medium: return ShedTheme.Space.l
            case .large: return ShedTheme.Space.xl
            }
        }
        
        var font: Font {
            switch self {
            case .small: return ShedTheme.Typography.caption
            case .medium: return ShedTheme.Typography.bodyEmphasis
            case .large: return ShedTheme.Typography.heading
            }
        }
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: ShedTheme.Space.xs) {
                Text(title)
                    .font(size.font)
                    .fontWeight(.semibold)
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: fullWidth ? .infinity : nil)
            .padding(.horizontal, size.horizontalPadding)
            .padding(.vertical, size.verticalPadding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: ShedTheme.Radius.s))
            .overlay(overlay)
        }
        .buttonStyle(ShedButtonPressStyle())
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.4)
    }
    
    private var foregroundColor: Color {
        switch style {
        case .primary:
            return ShedTheme.Colors.bg
        case .secondary, .ghost:
            return isEnabled ? ShedTheme.Colors.brass : ShedTheme.Colors.textTertiary
        }
    }
    
    @ViewBuilder
    private var background: some View {
        switch style {
        case .primary:
            ZStack {
                // Base brass fill
                RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                    .fill(isEnabled ? ShedTheme.Colors.brass : ShedTheme.Colors.textTertiary)
                // Subtle top highlight
                RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.15), Color.clear],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
            }
        case .secondary:
            RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                .fill(ShedTheme.Colors.brassGlow)
        case .ghost:
            Color.clear
        }
    }
    
    @ViewBuilder
    private var overlay: some View {
        switch style {
        case .secondary:
            RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                .stroke(isEnabled ? ShedTheme.Colors.brass : ShedTheme.Colors.textTertiary, lineWidth: ShedTheme.Stroke.thin)
        case .primary, .ghost:
            EmptyView()
        }
    }
}

// Custom press style for tactile feedback
struct ShedButtonPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(ShedTheme.Motion.fast, value: configuration.isPressed)
    }
}

// MARK: - ShedCard

/// Card component with distinctive styling
/// Features subtle brass accent line on highlighted cards
struct ShedCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = ShedTheme.Space.m
    var highlighted: Bool = false
    
    init(padding: CGFloat = ShedTheme.Space.m, highlighted: Bool = false, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.highlighted = highlighted
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: ShedTheme.Radius.m))
            .overlay(cardOverlay)
    }
    
    @ViewBuilder
    private var cardBackground: some View {
        ZStack {
            // Base surface
            RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                .fill(ShedTheme.Colors.surface)
            
            // Subtle top gradient for depth
            RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                .fill(ShedTheme.Effects.subtleDepth)
            
            // Brass glow for highlighted cards
            if highlighted {
                RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                    .fill(ShedTheme.Colors.brassGlow)
            }
        }
    }
    
    @ViewBuilder
    private var cardOverlay: some View {
        if highlighted {
            // Highlighted: brass accent border with glow effect
            ZStack {
                RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                    .stroke(ShedTheme.Colors.brass.opacity(0.5), lineWidth: ShedTheme.Stroke.thin)
                
                // Top accent line
                VStack {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(ShedTheme.Colors.brass)
                        .frame(width: 60, height: 3)
                        .padding(.top, 0)
                    Spacer()
                }
                .clipShape(RoundedRectangle(cornerRadius: ShedTheme.Radius.m))
            }
        } else {
            RoundedRectangle(cornerRadius: ShedTheme.Radius.m)
                .stroke(ShedTheme.Colors.stroke.opacity(0.5), lineWidth: ShedTheme.Stroke.hairline)
        }
    }
}

// MARK: - ShedRow

/// Row component for list-style layouts
struct ShedRow<Leading: View, Trailing: View>: View {
    let title: String
    var subtitle: String? = nil
    let leading: Leading
    let trailing: Trailing
    var action: (() -> Void)? = nil
    
    init(
        title: String,
        subtitle: String? = nil,
        @ViewBuilder leading: () -> Leading,
        @ViewBuilder trailing: () -> Trailing,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.leading = leading()
        self.trailing = trailing()
        self.action = action
    }
    
    var body: some View {
        let content = HStack(spacing: ShedTheme.Space.m) {
            leading
            
            VStack(alignment: .leading, spacing: ShedTheme.Space.xxs) {
                Text(title)
                    .font(ShedTheme.Typography.bodyEmphasis)
                    .foregroundColor(ShedTheme.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(ShedTheme.Typography.caption)
                        .foregroundColor(ShedTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            trailing
        }
        .padding(.vertical, ShedTheme.Space.s)
        .padding(.horizontal, ShedTheme.Space.m)
        .background(ShedTheme.Colors.surface)
        
        if let action = action {
            Button(action: action) {
                content
            }
        } else {
            content
        }
    }
}

// Convenience initializer when no leading/trailing needed
extension ShedRow where Leading == EmptyView, Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, action: (() -> Void)? = nil) {
        self.init(title: title, subtitle: subtitle, leading: { EmptyView() }, trailing: { EmptyView() }, action: action)
    }
}

extension ShedRow where Trailing == EmptyView {
    init(title: String, subtitle: String? = nil, @ViewBuilder leading: () -> Leading, action: (() -> Void)? = nil) {
        self.init(title: title, subtitle: subtitle, leading: leading, trailing: { EmptyView() }, action: action)
    }
}

extension ShedRow where Leading == EmptyView {
    init(title: String, subtitle: String? = nil, @ViewBuilder trailing: () -> Trailing, action: (() -> Void)? = nil) {
        self.init(title: title, subtitle: subtitle, leading: { EmptyView() }, trailing: trailing, action: action)
    }
}

// Simple label/value convenience for stats
extension ShedRow where Leading == EmptyView, Trailing == Text {
    init(label: String, value: String) {
        self.init(title: label, subtitle: nil, leading: { EmptyView() }, trailing: {
            Text(value)
                .font(ShedTheme.Typography.body)
                .foregroundColor(ShedTheme.Colors.textSecondary)
        }, action: nil)
    }
}

// MARK: - ShedHeader

/// Section header with subtle brass accent
struct ShedHeader: View {
    let title: String
    var subtitle: String? = nil
    var showAccent: Bool = true
    
    var body: some View {
        HStack(spacing: ShedTheme.Space.s) {
            if showAccent {
                // Brass accent bar
                RoundedRectangle(cornerRadius: 1)
                    .fill(ShedTheme.Colors.brass)
                    .frame(width: 3, height: 14)
            }
            
            VStack(alignment: .leading, spacing: ShedTheme.Space.xxs) {
                Text(title.uppercased())
                    .font(ShedTheme.Typography.captionSmall)
                    .fontWeight(.bold)
                    .foregroundColor(ShedTheme.Colors.textTertiary)
                    .tracking(1.5)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(ShedTheme.Typography.body)
                        .foregroundColor(ShedTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - ShedDivider

/// Divider with optional brass accent
struct ShedDivider: View {
    var accent: Bool = false
    
    var body: some View {
        Rectangle()
            .fill(accent ? ShedTheme.Colors.brassMuted.opacity(0.3) : ShedTheme.Colors.divider)
            .frame(height: ShedTheme.Stroke.hairline)
    }
}

// MARK: - ShedProgressBar

/// Progress bar with polished brass fill
struct ShedProgressBar: View {
    let progress: Double // 0.0 to 1.0
    var height: CGFloat = 6
    var showLabel: Bool = false
    
    var body: some View {
        VStack(alignment: .trailing, spacing: ShedTheme.Space.xxs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(ShedTheme.Colors.surfaceElevated)
                    
                    // Progress fill with subtle gradient
                    RoundedRectangle(cornerRadius: height / 2)
                        .fill(
                            LinearGradient(
                                colors: [ShedTheme.Colors.brass, ShedTheme.Colors.brassMuted],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * max(0, min(1, progress)))
                        .animation(ShedTheme.Motion.standard, value: progress)
                }
            }
            .frame(height: height)
            
            if showLabel {
                Text("\(Int(progress * 100))%")
                    .font(ShedTheme.Typography.captionSmall)
                    .fontWeight(.medium)
                    .foregroundColor(ShedTheme.Colors.brass)
            }
        }
    }
}

// MARK: - ShedIcon

/// Icon wrapper with brass-tinted container
struct ShedIcon: View {
    let systemName: String
    var size: IconSize = .medium
    var color: Color = ShedTheme.Colors.brass
    var filled: Bool = false
    
    enum IconSize {
        case small, medium, large
        
        var fontSize: CGFloat {
            switch self {
            case .small: return 14
            case .medium: return 18
            case .large: return 24
            }
        }
        
        var containerSize: CGFloat {
            switch self {
            case .small: return 28
            case .medium: return 40
            case .large: return 52
            }
        }
    }
    
    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: size.fontSize, weight: .semibold))
            .foregroundColor(filled ? ShedTheme.Colors.bg : color)
            .frame(width: size.containerSize, height: size.containerSize)
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                        .fill(filled ? color : color.opacity(0.12))
                    if !filled {
                        RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                            .stroke(color.opacity(0.2), lineWidth: ShedTheme.Stroke.hairline)
                    }
                }
            )
    }
}

// MARK: - ShedStatDisplay

/// Large stat display for key metrics (streak, XP, accuracy)
struct ShedStatDisplay: View {
    let value: String
    let label: String
    var icon: String? = nil
    var highlighted: Bool = false
    var accentColor: Color = ShedTheme.Colors.brass
    
    var body: some View {
        VStack(spacing: ShedTheme.Space.xs) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(highlighted ? accentColor : ShedTheme.Colors.textTertiary)
            }
            
            Text(value)
                .font(ShedTheme.Typography.title)
                .fontWeight(.bold)
                .foregroundColor(highlighted ? accentColor : ShedTheme.Colors.textPrimary)
            
            Text(label.uppercased())
                .font(ShedTheme.Typography.captionSmall)
                .fontWeight(.medium)
                .foregroundColor(ShedTheme.Colors.textTertiary)
                .tracking(1)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - ShedBadge

/// Small badge for streaks, ranks, achievements
struct ShedBadge: View {
    let text: String
    var icon: String? = nil
    var style: BadgeStyle = .default
    
    enum BadgeStyle {
        case `default`
        case brass
        case success
    }
    
    private var backgroundColor: Color {
        switch style {
        case .default: return ShedTheme.Colors.surface
        case .brass: return ShedTheme.Colors.brassGlow
        case .success: return ShedTheme.Colors.success.opacity(0.15)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case .default: return ShedTheme.Colors.textSecondary
        case .brass: return ShedTheme.Colors.brass
        case .success: return ShedTheme.Colors.success
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .default: return ShedTheme.Colors.stroke
        case .brass: return ShedTheme.Colors.brass.opacity(0.3)
        case .success: return ShedTheme.Colors.success.opacity(0.3)
        }
    }
    
    var body: some View {
        HStack(spacing: ShedTheme.Space.xxs) {
            if let icon = icon {
                Text(icon)
                    .font(.system(size: 12))
            }
            Text(text)
                .font(ShedTheme.Typography.captionSmall)
                .fontWeight(.semibold)
        }
        .foregroundColor(foregroundColor)
        .padding(.horizontal, ShedTheme.Space.s)
        .padding(.vertical, ShedTheme.Space.xxs + 2)
        .background(
            Capsule()
                .fill(backgroundColor)
                .overlay(
                    Capsule()
                        .stroke(borderColor, lineWidth: ShedTheme.Stroke.hairline)
                )
        )
    }
}

// MARK: - ShedFeedback

/// Feedback components for correct/incorrect states
struct ShedFeedback: View {
    let isCorrect: Bool
    var message: String? = nil
    var detail: String? = nil
    
    var body: some View {
        HStack(spacing: ShedTheme.Space.s) {
            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 24))
                .foregroundColor(isCorrect ? ShedTheme.Colors.success : ShedTheme.Colors.danger)
            
            VStack(alignment: .leading, spacing: ShedTheme.Space.xxs) {
                Text(message ?? (isCorrect ? "Correct" : "Incorrect"))
                    .font(ShedTheme.Typography.bodyEmphasis)
                    .foregroundColor(isCorrect ? ShedTheme.Colors.success : ShedTheme.Colors.danger)
                
                if let detail = detail {
                    Text(detail)
                        .font(ShedTheme.Typography.caption)
                        .foregroundColor(ShedTheme.Colors.textSecondary)
                }
            }
            
            Spacer()
        }
        .padding(ShedTheme.Space.m)
        .background(
            RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                .fill((isCorrect ? ShedTheme.Colors.success : ShedTheme.Colors.danger).opacity(0.1))
        )
    }
}

// MARK: - ShedChip

/// Tag/chip component for note displays, etc.
struct ShedChip: View {
    let text: String
    var variant: ChipVariant = .default
    
    enum ChipVariant {
        case `default`
        case success
        case danger
        case accent
    }
    
    var body: some View {
        Text(text)
            .font(ShedTheme.Typography.bodyEmphasis)
            .foregroundColor(foregroundColor)
            .padding(.horizontal, ShedTheme.Space.s)
            .padding(.vertical, ShedTheme.Space.xs)
            .background(
                RoundedRectangle(cornerRadius: ShedTheme.Radius.s)
                    .fill(backgroundColor)
            )
    }
    
    private var foregroundColor: Color {
        switch variant {
        case .default: return ShedTheme.Colors.textPrimary
        case .success: return ShedTheme.Colors.success
        case .danger: return ShedTheme.Colors.danger
        case .accent: return ShedTheme.Colors.bg
        }
    }
    
    private var backgroundColor: Color {
        switch variant {
        case .default: return ShedTheme.Colors.surface
        case .success: return ShedTheme.Colors.success.opacity(0.15)
        case .danger: return ShedTheme.Colors.danger.opacity(0.15)
        case .accent: return ShedTheme.Colors.brass
        }
    }
}

// MARK: - View Modifiers

/// Apply Shed background to any view
struct ShedBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(ShedTheme.Colors.bg)
    }
}

extension View {
    func shedBackground() -> some View {
        modifier(ShedBackgroundModifier())
    }
}

// MARK: - Previews

#Preview("ShedButton Variants") {
    VStack(spacing: ShedTheme.Space.m) {
        ShedButton(title: "Primary", action: {})
        ShedButton(title: "Secondary", action: {}, style: .secondary)
        ShedButton(title: "Ghost", action: {}, style: .ghost)
        ShedButton(title: "Disabled", action: {}, isEnabled: false)
        ShedButton(title: "Full Width", action: {}, fullWidth: true)
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("ShedCard") {
    VStack(spacing: ShedTheme.Space.m) {
        ShedCard {
            Text("Standard Card")
                .foregroundColor(ShedTheme.Colors.textPrimary)
        }
        
        ShedCard(highlighted: true) {
            Text("Highlighted Card")
                .foregroundColor(ShedTheme.Colors.textPrimary)
        }
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("ShedComponents") {
    ScrollView {
        VStack(alignment: .leading, spacing: ShedTheme.Space.l) {
            ShedHeader(title: "Section Header", subtitle: "With optional subtitle")
            
            ShedProgressBar(progress: 0.65, showLabel: true)
            
            ShedFeedback(isCorrect: true, detail: "Great job!")
            ShedFeedback(isCorrect: false, detail: "Try again")
            
            HStack {
                ShedChip(text: "C")
                ShedChip(text: "E", variant: .success)
                ShedChip(text: "G#", variant: .danger)
                ShedChip(text: "Bb", variant: .accent)
            }
            
            ShedIcon(systemName: "music.note", size: .large)
        }
        .padding(ShedTheme.Space.l)
    }
    .background(ShedTheme.Colors.bg)
}
