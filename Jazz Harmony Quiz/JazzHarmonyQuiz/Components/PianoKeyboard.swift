import SwiftUI
import Foundation

struct PianoKeyboard: View {
    @Binding var selectedNotes: Set<Note>
    @State private var pressedKeys: Set<Note> = []
    @State private var scrollOffset: CGFloat = 0
    @State private var currentOctave: Int = 4
    @State private var visibleRect: CGRect = .zero
    
    let octaveRange: ClosedRange<Int>
    let showNoteNames: Bool
    let allowMultipleSelection: Bool
    let playAudio: Bool
    
    // Constants for key dimensions
    private let whiteKeyWidth: CGFloat = 30
    private let whiteKeyHeight: CGFloat = 120
    private let blackKeyWidth: CGFloat = 20
    private let blackKeyHeight: CGFloat = 75
    
    init(selectedNotes: Binding<Set<Note>>, 
         octaveRange: ClosedRange<Int> = 4...4, 
         showNoteNames: Bool = false,
         allowMultipleSelection: Bool = true,
         playAudio: Bool = true) {
        self._selectedNotes = selectedNotes
        self.octaveRange = octaveRange
        self.showNoteNames = showNoteNames
        self.allowMultipleSelection = allowMultipleSelection
        self.playAudio = playAudio
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Scrollable keyboard
            ScrollViewReader { proxy in
                GeometryReader { outerGeometry in
                    ScrollView(.horizontal, showsIndicators: false) {
                        GeometryReader { geometry in
                            Color.clear.preference(
                                key: VisibleRectPreferenceKey.self,
                                value: geometry.frame(in: .named("scroll"))
                            )
                        }
                        .frame(height: 0)
                        
                        keyboardContent
                            .background(
                                GeometryReader { keyboardGeometry in
                                    Color.clear
                                }
                            )
                            .onAppear {
                                // Scroll to C4 on appear
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    scrollToNote(name: "C", octave: 4, proxy: proxy)
                                }
                            }
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(VisibleRectPreferenceKey.self) { rect in
                        visibleRect = rect
                        updateCurrentOctave(visibleRect: rect, containerWidth: outerGeometry.size.width)
                    }
                }
            }
        }
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    // MARK: - Keyboard Content
    
    private var keyboardContent: some View {
        let totalWidth = CGFloat(whiteKeys.count) * whiteKeyWidth
        
        return ZStack(alignment: .topLeading) {
            // White keys
            HStack(spacing: 0) {
                ForEach(Array(whiteKeys.enumerated()), id: \.element.midiNumber) { index, note in
                    WhiteKeyView(
                        note: note,
                        isPressed: pressedKeys.contains(note),
                        isSelected: selectedNotes.contains(note),
                        width: whiteKeyWidth,
                        height: whiteKeyHeight,
                        showNoteName: showNoteNames
                    ) {
                        handleKeyPress(note)
                    }
                    .id(note.midiNumber)
                }
            }
            
            // Black keys overlay - aligned to top
            ForEach(blackKeys, id: \.midiNumber) { blackKey in
                BlackKeyView(
                    note: blackKey,
                    isPressed: pressedKeys.contains(blackKey),
                    isSelected: selectedNotes.contains(blackKey),
                    width: blackKeyWidth,
                    height: blackKeyHeight,
                    showNoteName: showNoteNames
                ) {
                    handleKeyPress(blackKey)
                }
                .frame(width: blackKeyWidth, height: blackKeyHeight, alignment: .top)
                .offset(x: xPositionForBlackKey(blackKey), y: 0)
                .id(blackKey.midiNumber)
            }
        }
        .frame(width: totalWidth, height: whiteKeyHeight)
    }
    
    // MARK: - Key Generation
    
    // Generate white keys for all octaves (C2 to C6)
    private var whiteKeys: [Note] {
        var keys: [Note] = []
        
        // White key pattern: C D E F G A B (7 notes per octave)
        let whiteNoteOffsets = [0, 2, 4, 5, 7, 9, 11] // Semitones from C
        let whiteNoteNames = ["C", "D", "E", "F", "G", "A", "B"]
        
        // Generate from C2 (MIDI 36) to C6 (MIDI 84)
        for octave in 2...6 {
            let octaveBase = (octave + 1) * 12 // MIDI: C(-1)=0, C0=12, C1=24, C2=36
            for (index, offset) in whiteNoteOffsets.enumerated() {
                let midiNumber = octaveBase + offset
                if midiNumber <= 84 { // Stop at C6
                    let note = Note(
                        name: whiteNoteNames[index],
                        midiNumber: midiNumber,
                        isSharp: false
                    )
                    keys.append(note)
                }
            }
        }
        
        return keys
    }
    
    // Generate black keys for all octaves
    private var blackKeys: [Note] {
        var keys: [Note] = []
        
        // Black key pattern: C# D# F# G# A# (5 per octave)
        let blackKeyOffsets = [1, 3, 6, 8, 10] // Semitones from C
        let blackKeyNames = ["C#", "D#", "F#", "G#", "A#"]
        
        for octave in 2...6 {
            let octaveBase = (octave + 1) * 12
            for (index, offset) in blackKeyOffsets.enumerated() {
                let midiNumber = octaveBase + offset
                if midiNumber < 84 { // Don't go past C6
                    let note = Note(
                        name: blackKeyNames[index],
                        midiNumber: midiNumber,
                        isSharp: true
                    )
                    keys.append(note)
                }
            }
        }
        
        return keys
    }
    
    // Calculate X position for a black key based on its MIDI number
    private func xPositionForBlackKey(_ blackKey: Note) -> CGFloat {
        // Count how many white keys come before this black key
        let whiteKeysBefore = whiteKeys.filter { $0.midiNumber < blackKey.midiNumber }.count
        
        // Position black key at the right edge of the previous white key
        // For example: C# comes after C (1 white key before), so position at 1 * 30 - 10 = 20
        return CGFloat(whiteKeysBefore) * whiteKeyWidth - (blackKeyWidth / 2)
    }
    
    // Get the black key that appears after a given white key, if any
    private func blackKeyAfter(whiteKey: Note) -> Note? {
        let noteName = whiteKey.name
        
        // No black keys after E and B
        if noteName == "E" || noteName == "B" {
            return nil
        }
        
        // Calculate the black key MIDI number (one semitone above the white key)
        let blackKeyMidiNumber = whiteKey.midiNumber + 1
        
        // Create the black key note
        let baseMidiNumber = ((blackKeyMidiNumber - 60) % 12) + 60
        
        // Find the sharp version of the note
        if let baseNote = Note.allNotes.first(where: { $0.midiNumber == baseMidiNumber && $0.isSharp }) {
            // Also find the flat version for display
            if let flatNote = Note.allNotes.first(where: { $0.midiNumber == baseMidiNumber && !$0.isSharp && $0.name.contains("b") }) {
                let displayName = "\(baseNote.name)/\(flatNote.name)"
                return Note(name: displayName, midiNumber: blackKeyMidiNumber, isSharp: true)
            }
            return Note(name: baseNote.name, midiNumber: blackKeyMidiNumber, isSharp: true)
        }
        
        return nil
    }
    
    // MARK: - Interaction
    
    private func handleKeyPress(_ note: Note) {
        // Determine if we're selecting (not deselecting)
        let willSelect = !selectedNotes.contains(note) || !allowMultipleSelection
        
        // Play audio when selecting a note
        if playAudio && willSelect {
            AudioManager.shared.playNote(UInt8(note.midiNumber))
        }
        
        withAnimation(.easeInOut(duration: 0.1)) {
            if allowMultipleSelection {
                if selectedNotes.contains(note) {
                    selectedNotes.remove(note)
                } else {
                    selectedNotes.insert(note)
                }
            } else {
                selectedNotes = [note]
            }
        }
        
        // Visual feedback
        pressedKeys.insert(note)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            pressedKeys.remove(note)
        }
    }
    
    // MARK: - Scroll Helpers
    
    private func updateCurrentOctave(visibleRect: CGRect, containerWidth: CGFloat) {
        // Calculate the center of the visible area
        let centerX = abs(visibleRect.origin.x) + (containerWidth / 2)
        
        // Find which white key index is at the center
        let centerKeyIndex = Int(centerX / whiteKeyWidth)
        
        // Each octave has 7 white keys (C D E F G A B)
        // C2 starts at index 0, C3 at index 7, C4 at index 14, etc.
        let octaveFromIndex = min(max(2 + (centerKeyIndex / 7), 2), 6)
        
        if octaveFromIndex != currentOctave {
            withAnimation(.easeInOut(duration: 0.15)) {
                currentOctave = octaveFromIndex
            }
        }
    }
    
    private func scrollToNote(name: String, octave: Int, proxy: ScrollViewProxy) {
        // Find the C note of the specified octave
        // MIDI calculation: C2=36, C3=48, C4=60, C5=72, C6=84
        let targetMidi = (octave + 1) * 12
        
        if let targetNote = whiteKeys.first(where: { $0.midiNumber == targetMidi && $0.name == name }) {
            proxy.scrollTo(targetNote.midiNumber, anchor: .leading)
        }
    }
}

// MARK: - White Key View
struct WhiteKeyView: View {
    let note: Note
    let isPressed: Bool
    let isSelected: Bool
    let width: CGFloat
    let height: CGFloat
    let showNoteName: Bool
    let onPress: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            ZStack {
                Rectangle()
                    .fill(keyColor)
                    .frame(width: width, height: height)
                    .overlay(
                        Rectangle()
                            .stroke(Color.black, lineWidth: 1)
                    )
                
                VStack {
                    // Octave number above C keys
                    if note.name == "C" {
                        VStack(spacing: 2) {
                            Text("\(octaveNumber(from: note.midiNumber))")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(ShedTheme.Colors.brass)
                            Circle()
                                .fill(Color.black.opacity(0.4))
                                .frame(width: 6, height: 6)
                        }
                        .padding(.top, 6)
                    }
                    
                    Spacer()
                    
                    // Selection indicator at bottom
                    if isSelected {
                        Circle()
                            .fill(ShedTheme.Colors.brass)
                            .frame(width: min(width * 0.6, 16), height: min(width * 0.6, 16))
                            .padding(.bottom, 8)
                    }
                    
                    // Note name at bottom
                    if showNoteName {
                        Text(note.name)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black.opacity(0.6))
                            .padding(.bottom, 4)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private var keyColor: Color {
        if isSelected {
            return ShedTheme.Colors.brass.opacity(0.2)
        } else if isPressed {
            return Color.gray.opacity(0.3)
        } else {
            return .white
        }
    }
    
    // Calculate octave number from MIDI number
    // MIDI: C2=36, C3=48, C4=60, C5=72, C6=84
    private func octaveNumber(from midiNumber: Int) -> Int {
        return (midiNumber / 12) - 1
    }
}

// MARK: - Black Key View
struct BlackKeyView: View {
    let note: Note
    let isPressed: Bool
    let isSelected: Bool
    let width: CGFloat
    let height: CGFloat
    let showNoteName: Bool
    let onPress: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(keyColor)
                    .frame(width: width, height: height)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 2)
                
                VStack {
                    Spacer()
                    
                    // Selection indicator at bottom
                    if isSelected {
                        Circle()
                            .fill(ShedTheme.Colors.brass)
                            .frame(width: min(width * 0.6, 12), height: min(width * 0.6, 12))
                            .padding(.bottom, 6)
                    }
                    
                    // Note name at bottom
                    if showNoteName {
                        Text(note.name)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.bottom, 4)
                    }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private var keyColor: Color {
        if isSelected {
            return ShedTheme.Colors.brass.opacity(0.8)
        } else if isPressed {
            return .gray.opacity(0.7)
        } else {
            return .black
        }
    }
}

// MARK: - Visible Rect Preference Key

struct VisibleRectPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Piano Keyboard")
            .font(.headline)
            .padding()
        
        Text("Scrollable: C2 to C6")
            .font(.subheadline)
            .foregroundColor(.secondary)
        
        PianoKeyboard(
            selectedNotes: .constant(Set<Note>()),
            showNoteNames: true
        )
        .padding()
        .frame(height: 150)
        
        Spacer()
    }
}
