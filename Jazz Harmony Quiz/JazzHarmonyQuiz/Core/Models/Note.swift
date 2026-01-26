import Foundation

/// Represents a musical note with MIDI number and enharmonic handling
struct Note: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String
    let midiNumber: Int
    let isSharp: Bool
    
    /// Returns the pitch class (0-11) for octave-agnostic comparison
    var pitchClass: Int {
        return midiNumber % 12
    }
    
    /// Returns the enharmonic equivalent of this note (e.g., C# <-> Db)
    var enharmonicEquivalent: Note? {
        // Find notes with the same MIDI number but different names
        let candidates = Note.allNotes.filter { $0.midiNumber == self.midiNumber && $0.name != self.name }
        return candidates.first
    }
    
    /// Checks if this note is enharmonically equivalent to another note
    func isEnharmonicWith(_ other: Note) -> Bool {
        return self.pitchClass == other.pitchClass
    }
    
    // Custom hash implementation based on MIDI number only
    func hash(into hasher: inout Hasher) {
        hasher.combine(midiNumber)
    }
    
    // Custom equality based on MIDI number only
    static func == (lhs: Note, rhs: Note) -> Bool {
        return lhs.midiNumber == rhs.midiNumber
    }
    
    static let allNotes: [Note] = [
        Note(name: "C", midiNumber: 60, isSharp: false),
        Note(name: "C#", midiNumber: 61, isSharp: true),
        Note(name: "Db", midiNumber: 61, isSharp: false),
        Note(name: "D", midiNumber: 62, isSharp: false),
        Note(name: "D#", midiNumber: 63, isSharp: true),
        Note(name: "Eb", midiNumber: 63, isSharp: false),
        Note(name: "E", midiNumber: 64, isSharp: false),
        Note(name: "F", midiNumber: 65, isSharp: false),
        Note(name: "F#", midiNumber: 66, isSharp: true),
        Note(name: "Gb", midiNumber: 66, isSharp: false),
        Note(name: "G", midiNumber: 67, isSharp: false),
        Note(name: "G#", midiNumber: 68, isSharp: true),
        Note(name: "Ab", midiNumber: 68, isSharp: false),
        Note(name: "A", midiNumber: 69, isSharp: false),
        Note(name: "A#", midiNumber: 70, isSharp: true),
        Note(name: "Bb", midiNumber: 70, isSharp: false),
        Note(name: "B", midiNumber: 71, isSharp: false)
    ]
    
    static func noteFromMidi(_ midiNumber: Int, preferSharps: Bool = true) -> Note? {
        // Handle octave wrapping - map to the base octave (60-71)
        // Use proper modulo that handles negative numbers correctly
        var pitchClass = (midiNumber - 60) % 12
        if pitchClass < 0 { pitchClass += 12 }
        let baseMidiNumber = pitchClass + 60
        
        // For black keys (enharmonic notes), choose based on tonality preference
        let candidates = allNotes.filter { $0.midiNumber == baseMidiNumber }
        
        if candidates.count == 1 {
            return candidates.first
        } else if candidates.count > 1 {
            // Multiple enharmonic options - choose based on preference
            if preferSharps {
                return candidates.first { $0.isSharp } ?? candidates.first
            } else {
                return candidates.first { !$0.isSharp } ?? candidates.first
            }
        }
        
        return nil
    }
    
    /// Create a Note from a note name string (e.g., "C", "C#", "Db")
    static func noteFromName(_ name: String) -> Note? {
        return allNotes.first { $0.name == name }
    }
}

// MARK: - Convenience Accessors
extension Note {
    static let C = allNotes.first { $0.name == "C" }!
    static let Db = allNotes.first { $0.name == "Db" }!
    static let D = allNotes.first { $0.name == "D" }!
    static let Eb = allNotes.first { $0.name == "Eb" }!
    static let E = allNotes.first { $0.name == "E" }!
    static let F = allNotes.first { $0.name == "F" }!
    static let Gb = allNotes.first { $0.name == "Gb" }!
    static let G = allNotes.first { $0.name == "G" }!
    static let Ab = allNotes.first { $0.name == "Ab" }!
    static let A = allNotes.first { $0.name == "A" }!
    static let Bb = allNotes.first { $0.name == "Bb" }!
    static let B = allNotes.first { $0.name == "B" }!
}
