import SwiftUI
import Foundation

struct PianoKeyboard: View {
    @Binding var selectedNotes: Set<Note>
    @State private var pressedKeys: Set<Note> = []
    let octaveRange: ClosedRange<Int>
    let showNoteNames: Bool
    let allowMultipleSelection: Bool
    
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
        ZStack {
            // Vector-based piano keyboard
            PianoKeyboardShape()
                .fill(Color.white)
                .overlay(
                    PianoKeyboardShape()
                        .stroke(Color.black, lineWidth: 1)
                )
            
            // Black keys overlay
            PianoBlackKeysShape()
                .fill(Color.black)
                .overlay(
                    PianoBlackKeysShape()
                        .stroke(Color.black, lineWidth: 1)
                )
            
            // Interactive key areas
            ForEach(allKeys, id: \.midiNumber) { note in
                KeyArea(note: note, 
                       isPressed: pressedKeys.contains(note),
                       isSelected: selectedNotes.contains(note),
                       showNoteName: showNoteNames) {
                    handleKeyPress(note)
                }
            }
        }
        .frame(width: 350, height: 120)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
    
    private var allKeys: [Note] {
        var keys: [Note] = []
        
        for octave in octaveRange {
            // White keys: C, D, E, F, G, A, B
            let whiteKeyNames = ["C", "D", "E", "F", "G", "A", "B"]
            for noteName in whiteKeyNames {
                if let baseNote = Note.allNotes.first(where: { $0.name == noteName }) {
                    let midiNumber = baseNote.midiNumber + (octave - 4) * 12
                    let octaveNote = Note(name: noteName, midiNumber: midiNumber, isSharp: baseNote.isSharp)
                    keys.append(octaveNote)
                }
            }
            
            // Black keys: C#, D#, F#, G#, A#
            let blackKeyEnharmonics = [
                ("C#", "Db"), ("D#", "Eb"), ("F#", "Gb"), ("G#", "Ab"), ("A#", "Bb")
            ]
            for (sharpName, flatName) in blackKeyEnharmonics {
                if let sharpNote = Note.allNotes.first(where: { $0.name == sharpName }) {
                    let midiNumber = sharpNote.midiNumber + (octave - 4) * 12
                    let displayName = "\(sharpName)/\(flatName)"
                    let octaveNote = Note(name: displayName, midiNumber: midiNumber, isSharp: true)
                    keys.append(octaveNote)
                }
            }
        }
        
        return keys.sorted { $0.midiNumber < $1.midiNumber }
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

// MARK: - Piano Keyboard Shape
struct PianoKeyboardShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let keyWidth = rect.width / 7 // 7 white keys
        let keyHeight = rect.height
        
        // Draw 7 white keys
        for i in 0..<7 {
            let x = CGFloat(i) * keyWidth
            let keyRect = CGRect(x: x, y: 0, width: keyWidth, height: keyHeight)
            path.addRect(keyRect)
        }
        
        return path
    }
}

// MARK: - Piano Black Keys Shape
struct PianoBlackKeysShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let whiteKeyWidth = rect.width / 7
        let blackKeyWidth = whiteKeyWidth * 0.6
        let blackKeyHeight = rect.height * 0.6
        
        // Black key positions relative to white keys
        let blackKeyPositions: [CGFloat] = [
            0.75,  // C# (between C and D)
            1.75,  // D# (between D and E)
            // Skip E-F gap
            3.75,  // F# (between F and G)
            4.75,  // G# (between G and A)
            5.75   // A# (between A and B)
        ]
        
        for position in blackKeyPositions {
            let x = position * whiteKeyWidth - blackKeyWidth / 2
            let y = 0
            let keyRect = CGRect(x: x, y: CGFloat(y), width: blackKeyWidth, height: blackKeyHeight)
            path.addRoundedRect(in: keyRect, cornerSize: CGSize(width: 4, height: 4))
        }
        
        return path
    }
}

// MARK: - Interactive Key Area
struct KeyArea: View {
    let note: Note
    let isPressed: Bool
    let isSelected: Bool
    let showNoteName: Bool
    let onPress: () -> Void
    
    var body: some View {
        Button(action: onPress) {
            ZStack {
                // Invisible hit area
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: keyWidth, height: keyHeight)
                    .position(keyPosition)
                
                // Note name overlay
                if showNoteName {
                    Text(note.name)
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(note.isSharp ? .white : .black)
                        .position(noteNamePosition)
                }
                
                // Selection indicator
                if isSelected {
                    Circle()
                        .fill(Color.blue.opacity(0.7))
                        .frame(width: 20, height: 20)
                        .position(selectionIndicatorPosition)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
    
    private var keyWidth: CGFloat {
        note.isSharp ? 30 : 50
    }
    
    private var keyHeight: CGFloat {
        note.isSharp ? 72 : 120
    }
    
    private var keyPosition: CGPoint {
        let whiteKeyWidth: CGFloat = 50
        let blackKeyWidth: CGFloat = 30
        
        if note.isSharp {
            // Black key positioning
            let blackKeyPositions: [String: CGFloat] = [
                "C#": 0.75,
                "D#": 1.75,
                "F#": 3.75,
                "G#": 4.75,
                "A#": 5.75
            ]
            
            let sharpName = note.name.components(separatedBy: "/").first ?? ""
            let position = blackKeyPositions[sharpName] ?? 0
            let x = position * whiteKeyWidth
            let y: CGFloat = 36 // Half of black key height
            
            return CGPoint(x: x, y: y)
        } else {
            // White key positioning
            let whiteKeyPositions: [String: Int] = [
                "C": 0, "D": 1, "E": 2, "F": 3, "G": 4, "A": 5, "B": 6
            ]
            
            let position = whiteKeyPositions[note.name] ?? 0
            let x = CGFloat(position) * whiteKeyWidth + whiteKeyWidth / 2
            let y: CGFloat = 60 // Half of white key height
            
            return CGPoint(x: x, y: y)
        }
    }
    
    private var noteNamePosition: CGPoint {
        let pos = keyPosition
        return CGPoint(x: pos.x, y: pos.y + 20)
    }
    
    private var selectionIndicatorPosition: CGPoint {
        let pos = keyPosition
        return CGPoint(x: pos.x, y: pos.y - 30)
    }
}

// MARK: - Preview
#Preview {
    VStack {
        Text("Piano Keyboard")
            .font(.headline)
            .padding()
        
        PianoKeyboard(
            selectedNotes: .constant(Set<Note>()),
            showNoteNames: true
        )
        .padding()
        
        Spacer()
    }
}