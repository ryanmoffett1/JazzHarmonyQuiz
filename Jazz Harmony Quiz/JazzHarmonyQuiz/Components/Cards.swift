import SwiftUI

/// Standard card component for general content
struct StandardCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(uiColor: .systemBackground))
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            )
    }
}

/// Highlighted card for Quick Practice and important actions (brass accent)
struct HighlightedCard<Content: View>: View {
    let content: Content
    var padding: CGFloat = 16
    
    init(padding: CGFloat = 16, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color("BrassAccent").opacity(0.15),
                                Color("BrassAccent").opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color("BrassAccent"), lineWidth: 1.5)
                    )
            )
    }
}

// MARK: - Previews

#Preview("Standard Card") {
    StandardCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Standard Card")
                .font(.headline)
            Text("This is a standard card with some content inside.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    .padding()
}

#Preview("Highlighted Card") {
    HighlightedCard {
        VStack(alignment: .leading, spacing: 8) {
            Text("Quick Practice")
                .font(.headline)
            Text("Start practicing right away with a smart mix of topics.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    .padding()
}

#Preview("Card Comparison") {
    VStack(spacing: 16) {
        StandardCard {
            VStack(alignment: .leading) {
                Text("Continue Learning")
                    .font(.headline)
                Text("Module 5: ii-V-I Progressions")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        
        HighlightedCard {
            VStack(alignment: .leading) {
                Text("Quick Practice")
                    .font(.headline)
                Text("15 min • Mixed Topics")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
    .padding()
}

#Preview("Dark Mode") {
    VStack(spacing: 16) {
        StandardCard {
            Text("Standard Card in Dark Mode")
                .font(.headline)
        }
        
        HighlightedCard {
            Text("Highlighted Card in Dark Mode")
                .font(.headline)
        }
    }
    .padding()
    .preferredColorScheme(.dark)
}
