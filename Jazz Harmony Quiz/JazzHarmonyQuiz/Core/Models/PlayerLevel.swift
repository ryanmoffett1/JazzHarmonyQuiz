import Foundation

/// Simple level-based progression system (replaces Rank system)
struct PlayerLevel: Codable, Equatable {
    let level: Int
    let xp: Int
    let xpForNextLevel: Int
    
    /// Create a PlayerLevel from current XP
    init(xp: Int) {
        self.xp = xp
        self.level = PlayerLevel.levelFromXP(xp)
        self.xpForNextLevel = PlayerLevel.xpRequiredForLevel(self.level + 1)
    }
    
    /// Calculate level from XP using sqrt scaling
    /// Level 1: 0-99 XP
    /// Level 2: 100-399 XP  
    /// Level 3: 400-899 XP
    /// Level 4: 900-1599 XP
    /// etc.
    static func levelFromXP(_ xp: Int) -> Int {
        guard xp >= 0 else { return 1 }
        return max(1, Int(sqrt(Double(xp) / 100.0)) + 1)
    }
    
    /// Calculate XP required to reach a specific level
    static func xpRequiredForLevel(_ level: Int) -> Int {
        guard level > 1 else { return 0 }
        return (level - 1) * (level - 1) * 100
    }
    
    /// Progress toward next level (0.0 to 1.0)
    var progressToNextLevel: Double {
        let xpForCurrentLevel = PlayerLevel.xpRequiredForLevel(level)
        let xpForNext = xpForNextLevel
        let xpInCurrentLevel = xp - xpForCurrentLevel
        let xpNeededForLevel = xpForNext - xpForCurrentLevel
        
        guard xpNeededForLevel > 0 else { return 1.0 }
        return Double(xpInCurrentLevel) / Double(xpNeededForLevel)
    }
    
    /// XP remaining until next level
    var xpUntilNextLevel: Int {
        return max(0, xpForNextLevel - xp)
    }
}

/// XP awards for different actions
enum XPAward: Int {
    case correctBasic = 10
    case correctIntermediate = 15
    case correctAdvanced = 20
    case perfectSession = 50        // Bonus for 10+ questions all correct
    case curriculumModule = 100     // Bonus for completing a module
    case dailyStreak = 5            // Per day of streak maintained
    
    var amount: Int {
        return self.rawValue
    }
}
