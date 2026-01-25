import SwiftUI
import SwiftUI
import Foundation

struct PianoKeyboard: View {
    @Binding var selectedNotes: Set<Note>
    @State private var pressedKeys: Set<Note> = []
    let octaveRange: ClosedRange<Int>
    let showNoteNames: Bool
    let allowMultipleSelection: Bool
    
    // Constants for key dimensions
    private let whiteKeyWidth: CGFloat = 30
    private let whiteKeyHeight: CGFloat = 120
    private let blackKeyWidth: CGFloat = 20
    private let blackKeyHeight: CGFloat = 75
    
    init(selectedNotes: Binding<Set<Note>>, 
         octaveRange: ClosedRange<Int> = 4...4, 
         showNoteNames: Bool = false,
         allowMultipleSelection: Bool = true) {
        self._selectedNotes = selectedNotes
        self.octaveRange = octaveRange
        self.showNoteNames = showNoteNames
        self.allowMultipleSelection = allowMultipleSelection
    }
    
    var body: some View {
        GeometryReader { geometry in
            let availableWidth = geometry.size.width
            let calculatedWhiteKeyWidth = availableWidth / CGFloat(whiteKeys.count)
            let calculatedBlackKeyWidth = calculatedWhiteKeyWidth * 0.65
            
            ZStack(alignment: .topLeading) {
                // White keys background
                HStack(spacing: 0) {
                    ForEach(Array(whiteKeys.enumerated()), id: \.element.midiNumber) { index, note in
                        WhiteKeyView(
                            note: note,
                            isPressed: pressedKeys.contains(note),
                            isSelected: selectedNotes.contains(note),
                            width: calculatedWhiteKeyWidth,
                            height: whiteKeyHeight,
                            showNoteName: showNoteNames
                        ) {
                            handleKeyPress(note)
                        }
                    }
                }
                
                // Black keys overlay - positioned absolutely based on white key positions
                ForEach(Array(whiteKeys.enumerated()), id: \.element.midiNumber) { index, whiteKey in
                    if let blackKey = blackKeyAfter(whiteKey: whiteKey) {
                        BlackKeyView(
                            note: blackKey,
                            isPressed: pressedKeys.contains(blackKey),
                            isSelected: selectedNotes.contains(blackKey),
                            width: calculatedBlackKeyWidth,
                            height: blackKeyHeight,
                            showNoteName: showNoteNames
                        ) {
                            handleKeyPress(blackKey)
                        }
                        .offset(x: CGFloat(index + 1) * calculatedWhiteKeyWidth - (calculatedBlackKeyWidth / 2), y: 0)
                    }
                }
            }
            .frame(width: availableWidth, height: whiteKeyHeight)
        }
        .frame(height: whiteKeyHeight)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    // Generate white keys for A to E (1.5 octaves)
    private var whiteKeys: [Note] {
        var keys: [Note] = []
        
        // Starting MIDI numbers: A4=69, B4=71, C5=72, D5=74, E5=76
        // We want: A, B, C, D, E, F, G, A, B, C, D, E
        // That's: A4, B4, C5, D5, E5, F5, G5, A5, B5, C6, D6, E6
        
        let whiteKeyMidiNumbers = [
            69, // A4
            71, // B4
            72, // C5
            74, // D5
            76, // E5
            77, // F5
            79, // G5
            81, // A5
            83, // B5
            84, // C6
            86, // D6
            88  // E6
        ]
        
        for midiNumber in whiteKeyMidiNumbers {
            // Find the note name from the base MIDI number
            let baseMidiNumber = ((midiNumber - 60) % 12) + 60
            if let baseNote = Note.allNotes.first(where: { $0.midiNumber == baseMidiNumber && !$0.isSharp }) {
                let note = Note(name: baseNote.name, midiNumber: midiNumber, isSharp: false)
                keys.append(note)
            }
        }
        
        return keys
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
    
    private func handleKeyPress(_ note: Note) {
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
                    Spacer()
                    
                    // Selection indicator at bottom
                    if isSelected {
                        Circle()
                            .fill(Color.blue)
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
            return .blue.opacity(0.2)
        } else if isPressed {
            return .gray.opacity(0.3)
        } else {
            return .white
        }
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
                            .fill(Color.blue)
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
            return .blue.opacity(0.8)
        } else if isPressed {
            return .gray.opacity(0.7)
        } else {
            return .black
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        Text("Piano Keyboard")
            .font(.headline)
            .padding()
        
        Text("1.5 Octaves: A to E")
            .font(.subheadline)
            .foregroundColor(.secondary)
        
        PianoKeyboard(
            selectedNotes: .constant(Set<Note>()),
            showNoteNames: true
        )
        .padding()
        
        Spacer()
    }
}
