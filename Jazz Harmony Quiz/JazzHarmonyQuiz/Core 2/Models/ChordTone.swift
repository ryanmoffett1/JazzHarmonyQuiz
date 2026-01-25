import Foundation

/// Represents a chord tone (e.g., Root, 3rd, 7th, 9th, etc.)
struct ChordTone: Identifiable, Hashable, Codable {
    let id = UUID()
    let degree: Int
    let name: String
    let semitonesFromRoot: Int
    let isAltered: Bool
    
    static let allTones: [ChordTone] = [
        ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),
        ChordTone(degree: 2, name: "2nd", semitonesFromRoot: 2, isAltered: false),
        ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),
        ChordTone(degree: 4, name: "4th", semitonesFromRoot: 5, isAltered: false),
        ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),
        ChordTone(degree: 6, name: "6th", semitonesFromRoot: 9, isAltered: false),
        ChordTone(degree: 7, name: "7th", semitonesFromRoot: 11, isAltered: false),
        ChordTone(degree: 9, name: "9th", semitonesFromRoot: 2, isAltered: false),
        ChordTone(degree: 11, name: "11th", semitonesFromRoot: 5, isAltered: false),
        ChordTone(degree: 13, name: "13th", semitonesFromRoot: 9, isAltered: false),
        
        // Altered tones
        ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true),
        ChordTone(degree: 2, name: "#9", semitonesFromRoot: 3, isAltered: true),
        ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true),
        ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true),
        ChordTone(degree: 5, name: "#5", semitonesFromRoot: 8, isAltered: true),
        ChordTone(degree: 6, name: "b13", semitonesFromRoot: 8, isAltered: true),
        ChordTone(degree: 6, name: "#13", semitonesFromRoot: 10, isAltered: true),
        ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true)
    ]
}
