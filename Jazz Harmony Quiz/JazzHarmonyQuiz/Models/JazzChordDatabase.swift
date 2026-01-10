import Foundation

class JazzChordDatabase {
    static let shared = JazzChordDatabase()
    
    var chordTypes: [ChordType] = []
    
    private init() {
        setupChordTypes()
    }
    
    private func setupChordTypes() {
        chordTypes = [
            // BEGINNER CHORDS
            ChordType(
                name: "Major Triad",
                symbol: "",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4]  // 5th
                ],
                difficulty: .beginner
            ),
            
            ChordType(
                name: "Minor Triad",
                symbol: "m",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true), // b3
                    ChordTone.allTones[4]  // 5th
                ],
                difficulty: .beginner
            ),
            
            ChordType(
                name: "Dominant 7th",
                symbol: "7",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)  // b7
                ],
                difficulty: .beginner
            ),
            
            ChordType(
                name: "Major 7th",
                symbol: "maj7",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone.allTones[6]  // 7th
                ],
                difficulty: .beginner
            ),
            
            ChordType(
                name: "Minor 7th",
                symbol: "m7",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true), // b3
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)  // b7
                ],
                difficulty: .beginner
            ),
            
            // INTERMEDIATE CHORDS
            ChordType(
                name: "Minor Major 7th",
                symbol: "m(maj7)",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true), // b3
                    ChordTone.allTones[4], // 5th
                    ChordTone.allTones[6]  // 7th
                ],
                difficulty: .intermediate
            ),
            
            ChordType(
                name: "Half Diminished 7th",
                symbol: "m7b5",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true), // b3
                    ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true), // b5
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)  // b7
                ],
                difficulty: .intermediate
            ),
            
            ChordType(
                name: "Diminished 7th",
                symbol: "dim7",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true), // b3
                    ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true), // b5
                    ChordTone(degree: 7, name: "bb7", semitonesFromRoot: 9, isAltered: true) // bb7
                ],
                difficulty: .intermediate
            ),
            
            ChordType(
                name: "Augmented 7th",
                symbol: "7#5",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone(degree: 5, name: "#5", semitonesFromRoot: 8, isAltered: true), // #5
                    ChordTone.allTones[6]  // b7
                ],
                difficulty: .intermediate
            ),
            
            ChordType(
                name: "Major 9th",
                symbol: "maj9",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone.allTones[6], // 7th
                    ChordTone.allTones[7]  // 9th
                ],
                difficulty: .intermediate
            ),
            
            ChordType(
                name: "Dominant 9th",
                symbol: "9",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone.allTones[7]  // 9th
                ],
                difficulty: .intermediate
            ),
            
            ChordType(
                name: "Minor 9th",
                symbol: "m9",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true), // b3
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone.allTones[7]  // 9th
                ],
                difficulty: .intermediate
            ),
            
            // ADVANCED CHORDS
            ChordType(
                name: "Dominant 7th b9",
                symbol: "7b9",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true) // b9
                ],
                difficulty: .advanced
            ),
            
            ChordType(
                name: "Dominant 7th #9",
                symbol: "7#9",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone(degree: 2, name: "#9", semitonesFromRoot: 3, isAltered: true) // #9
                ],
                difficulty: .advanced
            ),
            
            ChordType(
                name: "Dominant 7th b5",
                symbol: "7b5",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true), // b5
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)  // b7
                ],
                difficulty: .advanced
            ),
            
            ChordType(
                name: "Dominant 7th #5",
                symbol: "7#5",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone(degree: 5, name: "#5", semitonesFromRoot: 8, isAltered: true), // #5
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)  // b7
                ],
                difficulty: .advanced
            ),
            
            ChordType(
                name: "Dominant 7th b9 #9",
                symbol: "7b9#9",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true), // b9
                    ChordTone(degree: 2, name: "#9", semitonesFromRoot: 3, isAltered: true)  // #9
                ],
                difficulty: .advanced
            ),
            
            ChordType(
                name: "Dominant 7th b9 b5",
                symbol: "7b9b5",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true), // b5
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true)  // b9
                ],
                difficulty: .advanced
            ),
            
            ChordType(
                name: "Dominant 7th #9 #5",
                symbol: "7#9#5",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone(degree: 5, name: "#5", semitonesFromRoot: 8, isAltered: true), // #5
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone(degree: 2, name: "#9", semitonesFromRoot: 3, isAltered: true)  // #9
                ],
                difficulty: .advanced
            ),
            
            // EXPERT CHORDS
            ChordType(
                name: "Dominant 7th b9 #9 b5",
                symbol: "7b9#9b5",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true), // b5
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true), // b9
                    ChordTone(degree: 2, name: "#9", semitonesFromRoot: 3, isAltered: true)  // #9
                ],
                difficulty: .expert
            ),
            
            ChordType(
                name: "Dominant 7th b9 #9 #5",
                symbol: "7b9#9#5",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone(degree: 5, name: "#5", semitonesFromRoot: 8, isAltered: true), // #5
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true), // b9
                    ChordTone(degree: 2, name: "#9", semitonesFromRoot: 3, isAltered: true)  // #9
                ],
                difficulty: .expert
            ),
            
            ChordType(
                name: "Major 11th",
                symbol: "maj11",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone.allTones[6], // 7th
                    ChordTone.allTones[7], // 9th
                    ChordTone.allTones[8]  // 11th
                ],
                difficulty: .expert
            ),
            
            ChordType(
                name: "Dominant 11th",
                symbol: "11",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone.allTones[7], // 9th
                    ChordTone.allTones[8]  // 11th
                ],
                difficulty: .expert
            ),
            
            ChordType(
                name: "Minor 11th",
                symbol: "m11",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true), // b3
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone.allTones[7], // 9th
                    ChordTone.allTones[8]  // 11th
                ],
                difficulty: .expert
            ),
            
            ChordType(
                name: "Major 13th",
                symbol: "maj13",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone.allTones[6], // 7th
                    ChordTone.allTones[7], // 9th
                    ChordTone.allTones[9]  // 13th
                ],
                difficulty: .expert
            ),
            
            ChordType(
                name: "Dominant 13th",
                symbol: "13",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone.allTones[7], // 9th
                    ChordTone.allTones[9]  // 13th
                ],
                difficulty: .expert
            ),
            
            ChordType(
                name: "Minor 13th",
                symbol: "m13",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true), // b3
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone.allTones[7], // 9th
                    ChordTone.allTones[9]  // 13th
                ],
                difficulty: .expert
            ),
            
            ChordType(
                name: "Dominant 7th b13",
                symbol: "7b13",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone(degree: 6, name: "b13", semitonesFromRoot: 8, isAltered: true) // b13
                ],
                difficulty: .expert
            ),
            
            ChordType(
                name: "Dominant 7th #13",
                symbol: "7#13",
                chordTones: [
                    ChordTone.allTones[0], // Root
                    ChordTone.allTones[2], // 3rd
                    ChordTone.allTones[4], // 5th
                    ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true), // b7
                    ChordTone(degree: 6, name: "#13", semitonesFromRoot: 10, isAltered: true) // #13
                ],
                difficulty: .expert
            )
        ]
    }
    
    func getChordTypes(by difficulty: ChordType.ChordDifficulty) -> [ChordType] {
        return chordTypes.filter { $0.difficulty == difficulty }
    }
    
    func getAllChords() -> [Chord] {
        var chords: [Chord] = []
        
        // Use common chord roots that include both sharps and flats
        let commonChordRoots = [
            "C", "C#", "Db", "D", "D#", "Eb", "E", "F",
            "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B"
        ]
        
        for rootName in commonChordRoots {
            if let rootNote = Note.allNotes.first(where: { $0.name == rootName }) {
                for chordType in chordTypes {
                    chords.append(Chord(root: rootNote, chordType: chordType))
                }
            }
        }
        
        return chords
    }
    
    func getChords(by difficulty: ChordType.ChordDifficulty) -> [Chord] {
        var chords: [Chord] = []
        let filteredTypes = getChordTypes(by: difficulty)
        
        // Use common chord roots that include both sharps and flats
        let commonChordRoots = [
            "C", "C#", "Db", "D", "D#", "Eb", "E", "F",
            "F#", "Gb", "G", "G#", "Ab", "A", "A#", "Bb", "B"
        ]
        
        for rootName in commonChordRoots {
            if let rootNote = Note.allNotes.first(where: { $0.name == rootName }) {
                for chordType in filteredTypes {
                    chords.append(Chord(root: rootNote, chordType: chordType))
                }
            }
        }
        
        return chords
    }
    
    func getRandomChord(difficulty: ChordType.ChordDifficulty? = nil) -> Chord {
        let availableChords: [Chord]
        
        if let difficulty = difficulty {
            availableChords = getChords(by: difficulty)
        } else {
            availableChords = getAllChords()
        }
        
        return availableChords.randomElement() ?? Chord(root: Note.allNotes[0], chordType: chordTypes[0])
    }
    
    func getRandomChordTypes(count: Int, difficulty: ChordType.ChordDifficulty? = nil) -> [ChordType] {
        let availableTypes: [ChordType]

        if let difficulty = difficulty {
            availableTypes = getChordTypes(by: difficulty)
        } else {
            availableTypes = chordTypes
        }

        return Array(availableTypes.shuffled().prefix(count))
    }

    func getChordType(symbol: String) -> ChordType? {
        // Handle special case: ø7 is the same as m7b5 (half-diminished)
        let normalizedSymbol = symbol == "ø7" ? "m7b5" : symbol
        return chordTypes.first { $0.symbol == normalizedSymbol }
    }
}
