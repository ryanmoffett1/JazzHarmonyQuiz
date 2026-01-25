import Foundation

/// Represents a complete chord with root note and chord type
struct Chord: Identifiable, Hashable, Codable {
    let id = UUID()
    let root: Note
    let chordType: ChordType
    let chordTones: [Note]
    
    var displayName: String {
        return "\(root.name)\(chordType.symbol)"
    }
    
    var fullName: String {
        return "\(root.name) \(chordType.name)"
    }
    
    init(root: Note, chordType: ChordType) {
        self.root = root
        self.chordType = chordType
        
        // Determine tonality preference based on root note
        // Sharp roots (C#, D#, F#, G#, A#) and sharp-friendly keys (B, E, A, D, G) prefer sharps
        // Flat roots (Db, Eb, Gb, Ab, Bb) and flat-friendly keys (F, C) prefer flats
        let preferSharps = root.isSharp || ["B", "E", "A", "D", "G"].contains(root.name)
        
        // Calculate chord tones based on root and chord type
        var tones: [Note] = []
        for chordTone in chordType.chordTones {
            let midiNumber = root.midiNumber + chordTone.semitonesFromRoot
            if let note = Note.noteFromMidi(midiNumber, preferSharps: preferSharps) {
                tones.append(note)
            }
        }
        self.chordTones = tones
    }
    
    func getChordTone(by degree: Int, isAltered: Bool = false) -> Note? {
        let targetTone = ChordTone.allTones.first {
            $0.degree == degree && $0.isAltered == isAltered
        }
        
        guard let tone = targetTone else { return nil }
        
        let preferSharps = root.isSharp || ["B", "E", "A", "D", "G"].contains(root.name)
        let midiNumber = root.midiNumber + tone.semitonesFromRoot
        return Note.noteFromMidi(midiNumber, preferSharps: preferSharps)
    }
    
    func getChordTone(by name: String) -> Note? {
        let targetTone = ChordTone.allTones.first { $0.name == name }
        
        guard let tone = targetTone else { return nil }
        
        let preferSharps = root.isSharp || ["B", "E", "A", "D", "G"].contains(root.name)
        let midiNumber = root.midiNumber + tone.semitonesFromRoot
        return Note.noteFromMidi(midiNumber, preferSharps: preferSharps)
    }
    
    /// Find notes that are common between this chord and another chord (using pitch class comparison)
    func commonTones(with other: Chord) -> [Note] {
        let myNotes = self.chordTones
        let otherNotes = other.chordTones
        
        // Convert to pitch classes for comparison (0-11)
        let myPitchClasses = Set(myNotes.map { $0.pitchClass })
        let otherPitchClasses = Set(otherNotes.map { $0.pitchClass })
        
        // Find intersection
        let commonPitchClasses = myPitchClasses.intersection(otherPitchClasses)
        
        // Return the notes from this chord that have common pitch classes
        return myNotes.filter { commonPitchClasses.contains($0.pitchClass) }
    }
    
    /// Get the guide tones (3rd and 7th) of the chord
    var guideTones: [Note] {
        var tones: [Note] = []
        if let third = third {
            tones.append(third)
        }
        if let seventh = seventh {
            tones.append(seventh)
        }
        return tones
    }
    
    /// Get the third of the chord
    var third: Note? {
        return getChordTone(by: 3, isAltered: false)
    }
    
    /// Get the seventh of the chord
    var seventh: Note? {
        return getChordTone(by: 7, isAltered: false)
    }
    
    /// Find the role of a note in this chord
    func roleOfNote(_ note: Note) -> ChordToneRole? {
        // Compare by pitch class to handle enharmonic equivalents
        let pitchClass = note.pitchClass
        
        // Check if it's the root
        if root.pitchClass == pitchClass {
            return .root
        }
        
        // Check if it's the third
        if let third = third, third.pitchClass == pitchClass {
            return .third
        }
        
        // Check if it's the fifth
        if let fifth = getChordTone(by: 5, isAltered: false), fifth.pitchClass == pitchClass {
            return .fifth
        }
        
        // Check if it's the seventh
        if let seventh = seventh, seventh.pitchClass == pitchClass {
            return .seventh
        }
        
        // Check extensions (9th, 11th, 13th)
        if let ninth = getChordTone(by: 9, isAltered: false), ninth.pitchClass == pitchClass {
            return .ninth
        }
        
        if let eleventh = getChordTone(by: 11, isAltered: false), eleventh.pitchClass == pitchClass {
            return .eleventh
        }
        
        if let thirteenth = getChordTone(by: 13, isAltered: false), thirteenth.pitchClass == pitchClass {
            return .thirteenth
        }
        
        return nil
    }
}

/// Role of a note within a chord
enum ChordToneRole: String, Codable, Equatable {
    case root = "Root"
    case third = "3rd"
    case fifth = "5th"
    case seventh = "7th"
    case ninth = "9th"
    case eleventh = "11th"
    case thirteenth = "13th"
    
    var displayName: String {
        return rawValue
    }
    
    var isGuideTone: Bool {
        return self == .third || self == .seventh
    }
}
