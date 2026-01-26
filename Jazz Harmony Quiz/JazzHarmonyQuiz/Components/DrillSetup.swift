import SwiftUI

// MARK: - Drill Setup Protocol

/// Protocol for drill-specific configuration that can be used with DrillSetupContainer
protocol DrillSetupConfiguration {
    var numberOfQuestions: Int { get set }
    var isValid: Bool { get }
}

// MARK: - Quick Start Preset

/// Represents a quick start preset for drill configuration
struct QuickStartPreset: Identifiable {
    let id = UUID()
    let name: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
}

// MARK: - Drill Setup Container

/// Shared container view for drill setup screens
/// Per DESIGN.md Section 7.4.1 (Quick Start Presets + Custom Configuration)
struct DrillSetupContainer<CustomContent: View>: View {
    let title: String
    let presets: [QuickStartPreset]
    let onStartQuiz: () -> Void
    let isStartEnabled: Bool
    let customContent: () -> CustomContent
    
    @EnvironmentObject var settings: SettingsManager
    @State private var showingSettings = false
    
    private var playerStats: PlayerStats { PlayerStats.shared }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header with rank and streak
                headerView
                
                // Quick Start Presets
                quickStartSection
                
                // Custom Configuration
                customConfigSection
                
                // Start Button
                startButton
                
                // Settings Button
                settingsButton
                
                Spacer(minLength: 20)
            }
            .padding()
        }
    }
    
    // MARK: - Header View
    
    private var headerView: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            // Stats row
            HStack(spacing: 20) {
                // Rank
                HStack(spacing: 4) {
                    Text(playerStats.currentRank.emoji)
                    Text("\(playerStats.currentRating)")
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
                .foregroundColor(.blue)
                
                // Streak
                if playerStats.currentStreak > 0 {
                    HStack(spacing: 4) {
                        Text("🔥")
                        Text("\(playerStats.currentStreak)")
                            .fontWeight(.semibold)
                    }
                    .font(.subheadline)
                    .foregroundColor(.orange)
                }
            }
        }
    }
    
    // MARK: - Quick Start Section
    
    private var quickStartSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Start")
                .font(.headline)
                .foregroundColor(.secondary)
            
            ForEach(presets) { preset in
                QuickStartPresetButton(preset: preset)
            }
        }
    }
    
    // MARK: - Custom Config Section
    
    private var customConfigSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Custom Configuration")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 16) {
                customContent()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
    
    // MARK: - Start Button
    
    private var startButton: some View {
        Button(action: onStartQuiz) {
            Text("Start Quiz")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isStartEnabled ? Color.blue : Color.gray)
                .cornerRadius(12)
        }
        .disabled(!isStartEnabled)
    }
    
    // MARK: - Settings Button
    
    private var settingsButton: some View {
        Button(action: { showingSettings = true }) {
            HStack {
                Image(systemName: "gear")
                Text("Settings")
            }
            .font(.subheadline)
            .foregroundColor(.purple)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.purple.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.purple, lineWidth: 1.5)
            )
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(showDoneButton: true)
                .environmentObject(settings)
        }
    }
}

// MARK: - Quick Start Preset Button

/// Individual button for a quick start preset
/// Supports both preset-based and inline parameter initialization
struct QuickStartPresetButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    /// Initialize with a QuickStartPreset
    init(preset: QuickStartPreset) {
        self.title = preset.name
        self.subtitle = preset.description
        self.icon = preset.icon
        self.color = preset.color
        self.action = preset.action
    }
    
    /// Initialize with individual parameters
    init(title: String, subtitle: String, icon: String, color: Color, action: @escaping () -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.color = color
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 44, height: 44)
                    .background(color.opacity(0.15))
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Common Setup Components

/// Picker for number of questions
struct QuestionCountPicker: View {
    @Binding var numberOfQuestions: Int
    let range: ClosedRange<Int>
    
    init(numberOfQuestions: Binding<Int>, range: ClosedRange<Int> = 5...20) {
        self._numberOfQuestions = numberOfQuestions
        self.range = range
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Number of Questions: \(numberOfQuestions)")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Slider(
                value: Binding(
                    get: { Double(numberOfQuestions) },
                    set: { numberOfQuestions = Int($0) }
                ),
                in: Double(range.lowerBound)...Double(range.upperBound),
                step: 1
            )
            .tint(.blue)
        }
    }
}

/// Picker for difficulty level
struct DifficultyPicker<T: RawRepresentable & CaseIterable & Hashable>: View where T.RawValue == String {
    let title: String
    @Binding var selection: T
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker(title, selection: $selection) {
                ForEach(Array(T.allCases), id: \.self) { difficulty in
                    Text(difficulty.rawValue.capitalized).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

/// Standard Key Difficulty picker
struct KeyDifficultyPicker: View {
    @Binding var selection: KeyDifficulty
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Key Difficulty")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Picker("Key Difficulty", selection: $selection) {
                ForEach(KeyDifficulty.allCases, id: \.self) { difficulty in
                    Text(difficulty.rawValue.capitalized).tag(difficulty)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

// MARK: - Setup Section Header

/// Standard section header for setup views
struct SetupSectionHeader: View {
    let title: String
    let icon: String?
    
    init(_ title: String, icon: String? = nil) {
        self.title = title
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                Image(systemName: icon)
                    .foregroundColor(.secondary)
            }
            
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        DrillSetupContainer(
            title: "Chord Drill Setup",
            presets: [
                QuickStartPreset(
                    name: "Basic Triads",
                    description: "Major and minor triads in easy keys",
                    icon: "music.note",
                    color: .green,
                    action: {}
                ),
                QuickStartPreset(
                    name: "7th Chords",
                    description: "Maj7, min7, dom7 in all keys",
                    icon: "music.quarternote.3",
                    color: .blue,
                    action: {}
                ),
                QuickStartPreset(
                    name: "Full Workout",
                    description: "All chord types, 20 questions",
                    icon: "flame.fill",
                    color: .orange,
                    action: {}
                )
            ],
            onStartQuiz: {},
            isStartEnabled: true
        ) {
            VStack(spacing: 16) {
                QuestionCountPicker(numberOfQuestions: .constant(10))
                KeyDifficultyPicker(selection: .constant(.easy))
            }
        }
        .environmentObject(SettingsManager.shared)
    }
}
