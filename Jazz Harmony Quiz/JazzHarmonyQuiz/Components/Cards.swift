import SwiftUI

// MARK: - Legacy Card Wrappers (Using ShedTheme)
// These maintain API compatibility while using the new flat theme

/// Standard card component for general content
struct StandardCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = ShedTheme.Space.m
    
    init(padding: CGFloat = ShedTheme.Space.m, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        ShedCard(padding: padding, highlighted: false) {
            content
        }
    }
}

/// Highlighted card for Quick Practice and important actions (brass accent)
struct HighlightedCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = ShedTheme.Space.m
    
    init(padding: CGFloat = ShedTheme.Space.m, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        ShedCard(padding: padding, highlighted: true) {
            content
        }
    }
}

// MARK: - Previews

#Preview("Standard Card") {
    StandardCard {
        VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
            Text("Standard Card")
                .font(ShedTheme.Type.heading)
                .foregroundColor(ShedTheme.Colors.textPrimary)
            Text("This is a standard card with some content inside.")
                .font(ShedTheme.Type.body)
                .foregroundColor(ShedTheme.Colors.textSecondary)
        }
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("Highlighted Card") {
    HighlightedCard {
        VStack(alignment: .leading, spacing: ShedTheme.Space.xs) {
            Text("Quick Practice")
                .font(ShedTheme.Type.heading)
                .foregroundColor(ShedTheme.Colors.textPrimary)
            Text("Start practicing right away with a smart mix of topics.")
                .font(ShedTheme.Type.body)
                .foregroundColor(ShedTheme.Colors.textSecondary)
        }
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}

#Preview("Card Comparison") {
    VStack(spacing: ShedTheme.Space.m) {
        StandardCard {
            VStack(alignment: .leading) {
                Text("Continue Learning")
                    .font(ShedTheme.Type.heading)
                    .foregroundColor(ShedTheme.Colors.textPrimary)
                Text("Module 5: ii-V-I Progressions")
                    .font(ShedTheme.Type.body)
                    .foregroundColor(ShedTheme.Colors.textSecondary)
            }
        }
        
        HighlightedCard {
            VStack(alignment: .leading) {
                Text("Quick Practice")
                    .font(ShedTheme.Type.heading)
                    .foregroundColor(ShedTheme.Colors.textPrimary)
                Text("15 min • Mixed Topics")
                    .font(ShedTheme.Type.body)
                    .foregroundColor(ShedTheme.Colors.textSecondary)
            }
        }
    }
    .padding(ShedTheme.Space.l)
    .background(ShedTheme.Colors.bg)
}
