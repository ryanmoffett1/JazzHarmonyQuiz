import Foundation

/// Represents a chord quality/type (e.g., maj7, m7, 7, dim7, etc.)
struct ChordType: Identifiable, Hashable, Codable {
    let id: UUID
    let name: String
    let symbol: String
    let chordTones: [ChordTone]
    let difficulty: ChordDifficulty
    
    init(name: String, symbol: String, chordTones: [ChordTone], difficulty: ChordDifficulty) {
        self.id = UUID()
        self.name = name
        self.symbol = symbol
        self.chordTones = chordTones
        self.difficulty = difficulty
    }
    
    enum ChordDifficulty: String, CaseIterable, Codable {
        case beginner = "Beginner"
        case intermediate = "Intermediate"
        case advanced = "Advanced"
        case expert = "Expert"
        case custom = "Custom"
        
        var displayName: String {
            rawValue
        }
    }
}
