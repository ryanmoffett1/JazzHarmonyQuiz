import SwiftUI

/// A compact chord selector for picking root + quality
/// Used in Cadence Identification mode
struct ChordSelectorView: View {
    @Binding var selection: ChordSelection
    let availableQualities: [CadenceChordQuality]
    let disabled: Bool
    let onComplete: (() -> Void)?
    let keyContext: Note?  // The key of the cadence, used to determine sharp/flat preference
    
    init(
        selection: Binding<ChordSelection>,
        availableQualities: [CadenceChordQuality] = CadenceChordQuality.allCadenceQualities,
        disabled: Bool = false,
        onComplete: (() -> Void)? = nil,
        keyContext: Note? = nil
    ) {
        self._selection = selection
        self.availableQualities = availableQualities
        self.disabled = disabled
        self.onComplete = onComplete
        self.keyContext = keyContext
    }
    
    /// Determine if we should prefer sharps based on the key context
    private var preferSharps: Bool {
        guard let key = keyContext else { return true }
        // Sharp keys: G, D, A, E, B, F#, C# (and their relative minors)
        // Flat keys: F, Bb, Eb, Ab, Db, Gb, Cb
        // If the key itself is a sharp, prefer sharps
        // If the key itself is a flat (name contains "b"), prefer flats
        if key.name.contains("b") {
            return false
        }
        if key.isSharp || key.name.contains("#") {
            return true
        }
        // Natural keys: C prefers sharps, F prefers flats
        // G, D, A, E, B prefer sharps
        return ["C", "G", "D", "A", "E", "B"].contains(key.name)
    }
    
    /// Generate roots with appropriate spelling based on key context
    private var roots: [Note] {
        if preferSharps {
            return [
                Note(name: "C", midiNumber: 60, isSharp: false),
                Note(name: "C#", midiNumber: 61, isSharp: true),
                Note(name: "D", midiNumber: 62, isSharp: false),
                Note(name: "D#", midiNumber: 63, isSharp: true),
                Note(name: "E", midiNumber: 64, isSharp: false),
                Note(name: "F", midiNumber: 65, isSharp: false),
                Note(name: "F#", midiNumber: 66, isSharp: true),
                Note(name: "G", midiNumber: 67, isSharp: false),
                Note(name: "G#", midiNumber: 68, isSharp: true),
                Note(name: "A", midiNumber: 69, isSharp: false),
                Note(name: "A#", midiNumber: 70, isSharp: true),
                Note(name: "B", midiNumber: 71, isSharp: false),
            ]
        } else {
            // Flat spellings - no double flats
            return [
                Note(name: "C", midiNumber: 60, isSharp: false),
                Note(name: "Db", midiNumber: 61, isSharp: false),
                Note(name: "D", midiNumber: 62, isSharp: false),
                Note(name: "Eb", midiNumber: 63, isSharp: false),
                Note(name: "E", midiNumber: 64, isSharp: false),
                Note(name: "F", midiNumber: 65, isSharp: false),
                Note(name: "Gb", midiNumber: 66, isSharp: false),
                Note(name: "G", midiNumber: 67, isSharp: false),
                Note(name: "Ab", midiNumber: 68, isSharp: false),
                Note(name: "A", midiNumber: 69, isSharp: false),
                Note(name: "Bb", midiNumber: 70, isSharp: false),
                Note(name: "B", midiNumber: 71, isSharp: false),
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Selection Preview
            HStack {
                Text("Selected:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text(selectionDisplayName)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(selection.isComplete ? .primary : .secondary)
                
                Spacer()
                
                if selection.selectedRoot != nil || selection.selectedQuality != nil {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selection.reset()
                        }
                        HapticFeedback.light()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .disabled(disabled)
                }
            }
            .padding(.horizontal)
            
            // Root Selection - Two rows of 6
            VStack(spacing: 8) {
                Text("Root")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                VStack(spacing: 6) {
                    // First row: C to F (or Gb in flat keys)
                    HStack(spacing: 6) {
                        ForEach(roots.prefix(6), id: \.midiNumber) { note in
                            rootButton(for: note)
                        }
                    }
                    // Second row: F#/Gb to B
                    HStack(spacing: 6) {
                        ForEach(roots.suffix(6), id: \.midiNumber) { note in
                            rootButton(for: note)
                        }
                    }
                }
            }
            
            // Quality Selection
            VStack(spacing: 8) {
                Text("Quality")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 6) {
                    ForEach(availableQualities, id: \.rawValue) { quality in
                        qualityButton(for: quality)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(16)
    }
    
    /// Display name respecting the key context's spelling preference
    private var selectionDisplayName: String {
        guard let root = selection.selectedRoot, let quality = selection.selectedQuality else {
            return "—"
        }
        // Find the matching root from our roots array to get the correct spelling
        if let matchingRoot = roots.first(where: { $0.pitchClass == root.pitchClass }) {
            return "\(matchingRoot.name)\(quality)"
        }
        return "\(root.name)\(quality)"
    }
    
    @ViewBuilder
    private func rootButton(for note: Note) -> some View {
        let isSelected = selection.selectedRoot?.pitchClass == note.pitchClass
        
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                selection.selectedRoot = note
            }
            HapticFeedback.light()
            checkCompletion()
        }) {
            Text(note.name)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 44, height: 44)
                .background(isSelected ? ShedTheme.Colors.brass : ShedTheme.Colors.surface)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .disabled(disabled)
    }
    
    @ViewBuilder
    private func qualityButton(for quality: CadenceChordQuality) -> some View {
        let isSelected = selection.selectedQuality == quality.rawValue
        
        Button(action: {
            withAnimation(.easeInOut(duration: 0.15)) {
                selection.selectedQuality = quality.rawValue
            }
            HapticFeedback.light()
            checkCompletion()
        }) {
            Text(quality.displayName)
                .font(.system(size: 13, weight: .semibold))
                .frame(minWidth: 44, idealWidth: 50)
                .padding(.vertical, 10)
                .padding(.horizontal, 8)
                .background(isSelected ? ShedTheme.Colors.brass : ShedTheme.Colors.surface)
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(8)
        }
        .disabled(disabled)
    }
    
    private func checkCompletion() {
        if selection.isComplete {
            onComplete?()
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var selection = ChordSelection()
        
        var body: some View {
            VStack(spacing: 20) {
                // Sharp key context (G major)
                Text("Key of G (sharps):")
                ChordSelectorView(
                    selection: $selection,
                    availableQualities: CadenceChordQuality.majorCadenceQualities,
                    keyContext: Note(name: "G", midiNumber: 67, isSharp: false)
                )
                .padding(.horizontal)
                
                // Flat key context (Ab major)
                Text("Key of Ab (flats):")
                ChordSelectorView(
                    selection: $selection,
                    availableQualities: CadenceChordQuality.majorCadenceQualities,
                    keyContext: Note(name: "Ab", midiNumber: 68, isSharp: false)
                )
                .padding(.horizontal)
            }
        }
    }
    
    return PreviewWrapper()
}
