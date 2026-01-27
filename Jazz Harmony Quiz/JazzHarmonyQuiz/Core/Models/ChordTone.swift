import Foundation

/// Represents a chord tone (e.g., Root, 3rd, 7th, 9th, etc.)
struct ChordTone: Identifiable, Hashable, Codable {
    let id = UUID()
    let degree: Int
    let name: String
    let semitonesFromRoot: Int
    let isAltered: Bool
    
    static let allTones: [ChordTone] = [
        ChordTone(degree: 1, name: "Root", semitonesFromRoot: 0, isAltered: false),      // [0]
        ChordTone(degree: 2, name: "2nd", semitonesFromRoot: 2, isAltered: false),       // [1]
        ChordTone(degree: 3, name: "3rd", semitonesFromRoot: 4, isAltered: false),       // [2]
        ChordTone(degree: 4, name: "4th", semitonesFromRoot: 5, isAltered: false),       // [3]
        ChordTone(degree: 5, name: "5th", semitonesFromRoot: 7, isAltered: false),       // [4]
        ChordTone(degree: 6, name: "6th", semitonesFromRoot: 9, isAltered: false),       // [5]
        ChordTone(degree: 7, name: "7th", semitonesFromRoot: 11, isAltered: false),      // [6]
        ChordTone(degree: 9, name: "9th", semitonesFromRoot: 2, isAltered: false),       // [7]
        ChordTone(degree: 11, name: "11th", semitonesFromRoot: 5, isAltered: false),     // [8]
        ChordTone(degree: 13, name: "13th", semitonesFromRoot: 9, isAltered: false),     // [9]
        
        // Altered tones
        ChordTone(degree: 2, name: "b9", semitonesFromRoot: 1, isAltered: true),         // [10]
        ChordTone(degree: 2, name: "#9", semitonesFromRoot: 3, isAltered: true),         // [11]
        ChordTone(degree: 3, name: "b3", semitonesFromRoot: 3, isAltered: true),         // [12]
        ChordTone(degree: 5, name: "b5", semitonesFromRoot: 6, isAltered: true),         // [13]
        ChordTone(degree: 5, name: "#5", semitonesFromRoot: 8, isAltered: true),         // [14]
        ChordTone(degree: 6, name: "b13", semitonesFromRoot: 8, isAltered: true),        // [15]
        ChordTone(degree: 6, name: "#13", semitonesFromRoot: 10, isAltered: true),       // [16]
        ChordTone(degree: 7, name: "b7", semitonesFromRoot: 10, isAltered: true),        // [17]
        ChordTone(degree: 11, name: "#11", semitonesFromRoot: 6, isAltered: true)        // [18] - Lydian #11
    ]
}
