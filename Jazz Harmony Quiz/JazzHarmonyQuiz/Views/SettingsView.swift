import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var settings: SettingsManager
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                // Theme Section
                Section {
                    Picker("Appearance", selection: $settings.selectedTheme) {
                        ForEach(AppTheme.allCases) { theme in
                            Text(theme.rawValue).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Theme")
                } footer: {
                    Text("Choose how the app appears. System will follow your device settings.")
                        .foregroundColor(settings.secondaryText(for: colorScheme))
                }

                // Font Section
                Section {
                    Picker("Chord Font", selection: $settings.selectedChordFont) {
                        ForEach(ChordFont.allCases) { font in
                            Text(font.displayName).tag(font)
                        }
                    }
                    .pickerStyle(.segmented)

                    // Font Preview
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Preview")
                            .font(.caption)
                            .foregroundColor(settings.secondaryText(for: colorScheme))

                        Text("Cmaj7")
                            .font(settings.chordDisplayFont(size: 32, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(settings.chordDisplayBackground(for: colorScheme))
                            .cornerRadius(8)

                        HStack(spacing: 8) {
                            Text("Dm7")
                                .font(settings.chordDisplayFont(size: 24, weight: .semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(settings.selectedNoteBackground(for: colorScheme))
                                .foregroundColor(.white)
                                .cornerRadius(8)

                            Text("G7")
                                .font(settings.chordDisplayFont(size: 24, weight: .semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(settings.selectedNoteBackground(for: colorScheme))
                                .foregroundColor(.white)
                                .cornerRadius(8)

                            Text("C")
                                .font(settings.chordDisplayFont(size: 24, weight: .semibold))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(settings.selectedNoteBackground(for: colorScheme))
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .padding(.vertical, 8)
                } header: {
                    Text("Chord Display Font")
                } footer: {
                    Text("The Jazz font gives chord names a handwritten, Real Book-style appearance.")
                        .foregroundColor(settings.secondaryText(for: colorScheme))
                }

                // About Section
                Section {
                    HStack {
                        Text("Version")
                            .foregroundColor(settings.primaryText(for: colorScheme))
                        Spacer()
                        Text("1.0")
                            .foregroundColor(settings.secondaryText(for: colorScheme))
                    }
                } header: {
                    Text("About")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .background(settings.backgroundColor(for: colorScheme).ignoresSafeArea())
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(SettingsManager.shared)
    }
}
