import SwiftUI

/// Horizontal scroll selector for curriculum pathways
/// Per DESIGN.md Section 8.2
struct PathwaySelector: View {
    @Binding var selectedPathway: CurriculumPathway
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(CurriculumPathway.allCases, id: \.self) { pathway in
                    PathwayButton(
                        pathway: pathway,
                        isSelected: selectedPathway == pathway
                    ) {
                        withAnimation {
                            selectedPathway = pathway
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

/// Individual pathway selection button
struct PathwayButton: View {
    let pathway: CurriculumPathway
    let isSelected: Bool
    let action: () -> Void
    
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: pathway.icon)
                    .font(.title2)
                
                Text(pathway.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(width: 100, height: 80)
            .foregroundColor(isSelected ? .white : settings.primaryText(for: colorScheme))
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? pathwayColor : Color.gray.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? pathwayColor : Color.clear, lineWidth: 2)
            )
        }
    }
    
    private var pathwayColor: Color {
        return ShedTheme.Colors.brass
    }
}

// MARK: - Preview

#Preview {
    PathwaySelector(selectedPathway: .constant(.harmonyFoundations))
        .environmentObject(SettingsManager.shared)
        .padding()
}
