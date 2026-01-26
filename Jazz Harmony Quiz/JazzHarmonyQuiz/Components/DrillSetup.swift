import SwiftUI

// MARK: - Drill Setup Components

/// Shared components for drill setup screens across all drill modules
/// Per DESIGN.md Section 7.3 Setup Screen Pattern

// MARK: - Quick Start Preset Card

/// A card for quick start presets in drill setup screens
struct QuickStartPresetCard<Preset: DrillPreset>: View {
    let preset: Preset
    let isSelected: Bool
    let action: () -> Void
    var accentColor: Color = .blue
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: preset.icon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : accentColor)
                
                Text(preset.name)
                    .font(.headline)
                    .foregroundColor(isSelected ? .white : .primary)
                
                Text(preset.description)
                    .font(.caption)
                    .foregroundColor(isSelected ? .white.opacity(0.8) : .secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? accentColor : Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Quick Start Section Header

/// Section header for quick start presets area
struct QuickStartSectionHeader: View {
    var title: String = "Quick Start"
    var subtitle: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Collapsible Custom Options Section

/// A collapsible section for custom drill configuration
struct CollapsibleCustomOptions<Content: View>: View {
    @Binding var isExpanded: Bool
    var title: String = "Custom Options"
    let content: () -> Content
    
    var body: some View {
        VStack(spacing: 0) {
            // Header button
            Button(action: { withAnimation { isExpanded.toggle() } }) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Collapsible content
            if isExpanded {
                VStack(spacing: 16) {
                    content()
                }
                .padding()
                .background(Color(.systemGray6).opacity(0.5))
                .cornerRadius(12)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
}

// MARK: - Setup Option Row

/// A row for displaying a setup option with label and picker
struct SetupOptionRow<Content: View>: View {
    let icon: String
    let label: String
    let content: () -> Content
    
    var body: some View {
        HStack {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
                    .frame(width: 24)
                Text(label)
                    .font(.subheadline)
            }
            
            Spacer()
            
            content()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Question Count Slider

/// Standard slider for selecting number of questions
struct QuestionCountSlider: View {
    @Binding var count: Int
    var range: ClosedRange<Int> = 5...30
    var step: Int = 5
    var accentColor: Color = .blue
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Questions")
                    .font(.subheadline)
                Spacer()
                Text("\(count)")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(accentColor)
            }
            
            Slider(
                value: Binding(
                    get: { Double(count) },
                    set: { count = Int($0) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: Double(step)
            )
            .tint(accentColor)
            
            HStack {
                Text("\(range.lowerBound)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(range.upperBound)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Setup Difficulty Picker

/// Standard picker for selecting drill difficulty
struct SetupDifficultyPicker<Difficulty: Hashable & CaseIterable & RawRepresentable>: View where Difficulty.RawValue == String, Difficulty.AllCases: RandomAccessCollection {
    @Binding var selection: Difficulty
    var accentColor: Color = .blue
    
    var body: some View {
        Picker("Difficulty", selection: $selection) {
            ForEach(Array(Difficulty.allCases), id: \.self) { difficulty in
                Text(difficulty.rawValue).tag(difficulty)
            }
        }
        .pickerStyle(.segmented)
    }
}

// MARK: - Setup Header View

/// Standard header for drill setup screens with stats
/// Updated per DESIGN.md Section 9.3.1 to use simple level instead of ranks
struct SetupHeaderView: View {
    let title: String
    let subtitle: String?
    let currentRating: Int
    let currentStreak: Int
    
    // Computed level from XP
    private var level: PlayerLevel {
        PlayerLevel(xp: currentRating)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Title
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            // Stats row
            HStack(spacing: 20) {
                // Level (simplified from rank)
                VStack(spacing: 2) {
                    Text("Lv.\(level.level)")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color("BrassAccent"))
                    Text("Level")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Divider()
                    .frame(height: 40)
                
                // Rating
                VStack(spacing: 2) {
                    Text("\(currentRating)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Streak (if active)
                if currentStreak > 1 {
                    Divider()
                        .frame(height: 40)
                    
                    VStack(spacing: 2) {
                        Text("🔥 \(currentStreak)")
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                        Text("Day Streak")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Setup Start Button

/// Standard start button for drill setup screens
struct SetupStartButton: View {
    let title: String
    let isEnabled: Bool
    let color: Color
    let action: () -> Void
    
    init(
        title: String = "Start Quiz",
        isEnabled: Bool = true,
        color: Color = .blue,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.isEnabled = isEnabled
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isEnabled ? color : Color.gray)
                .cornerRadius(12)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Setup Section Divider

/// A styled divider for separating setup sections
struct SetupSectionDivider: View {
    var text: String? = nil
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.gray.opacity(0.3))
                .frame(height: 1)
            
            if let text = text {
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
            }
        }
    }
}

// MARK: - Question Type Toggle Button

/// A toggle button for selecting question types in setup
struct QuestionTypeToggleButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    var accentColor: Color = .blue
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(isSelected ? accentColor : Color(.systemGray5))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(10)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Previews

#Preview("Quick Start Presets") {
    VStack(spacing: 12) {
        QuickStartSectionHeader(title: "Quick Start", subtitle: "Choose a preset to begin")
        
        HStack(spacing: 12) {
            QuickStartPresetCard(
                preset: ChordDrillPreset.basicTriads,
                isSelected: true,
                action: {}
            )
            QuickStartPresetCard(
                preset: ChordDrillPreset.seventhChords,
                isSelected: false,
                action: {}
            )
        }
    }
    .padding()
}

#Preview("Question Count Slider") {
    @Previewable @State var count = 10
    QuestionCountSlider(count: $count)
        .padding()
}

#Preview("Setup Header") {
    SetupHeaderView(
        title: "Chord Drill",
        subtitle: "Spell chord tones from symbols",
        currentRating: 1250,
        currentStreak: 5
    )
    .padding()
}

#Preview("Question Type Toggles") {
    HStack(spacing: 8) {
        QuestionTypeToggleButton(
            icon: "music.note.list",
            title: "All Tones",
            isSelected: true,
            action: {}
        )
        QuestionTypeToggleButton(
            icon: "music.note",
            title: "Single",
            isSelected: false,
            action: {}
        )
        QuestionTypeToggleButton(
            icon: "ear",
            title: "Ear Training",
            isSelected: false,
            action: {}
        )
    }
    .padding()
}
