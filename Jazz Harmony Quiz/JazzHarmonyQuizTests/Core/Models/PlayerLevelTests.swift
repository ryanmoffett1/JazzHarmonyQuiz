import XCTest
@testable import JazzHarmonyQuiz

final class PlayerLevelTests: XCTestCase {
    
    // MARK: - Level Calculation from XP
    
    func testLevelFromXPZero() {
        let level = PlayerLevel.levelFromXP(0)
        XCTAssertEqual(level, 1, "Starting level should be 1 with 0 XP")
    }
    
    func testLevelFromXPBasic() {
        // Level formula: max(1, Int(sqrt(xp / 100)) + 1)
        XCTAssertEqual(PlayerLevel.levelFromXP(100), 2)   // sqrt(100/100) + 1 = 2
        XCTAssertEqual(PlayerLevel.levelFromXP(400), 3)   // sqrt(400/100) + 1 = 3
        XCTAssertEqual(PlayerLevel.levelFromXP(900), 4)   // sqrt(900/100) + 1 = 4
        XCTAssertEqual(PlayerLevel.levelFromXP(1600), 5)  // sqrt(1600/100) + 1 = 5
    }
    
    func testLevelFromXPProgression() {
        // Test that XP requirements increase progressively
        let level2XP = 100    // Level 2
        let level3XP = 400    // Level 3
        let level5XP = 1600   // Level 5
        let level10XP = 8100  // Level 10
        
        XCTAssertEqual(PlayerLevel.levelFromXP(level2XP), 2)
        XCTAssertEqual(PlayerLevel.levelFromXP(level3XP), 3)
        XCTAssertEqual(PlayerLevel.levelFromXP(level5XP), 5)
        XCTAssertEqual(PlayerLevel.levelFromXP(level10XP), 10)
    }
    
    func testLevelFromXPLargeValues() {
        XCTAssertEqual(PlayerLevel.levelFromXP(10000), 11)  // sqrt(10000/100) + 1 = 11
        XCTAssertEqual(PlayerLevel.levelFromXP(40000), 21)  // sqrt(40000/100) + 1 = 21
    }
    
    // MARK: - XP for Level Calculation
    
    func testXPForLevel() {
        // Reverse of level formula: xp = (level - 1)^2 * 100
        XCTAssertEqual(PlayerLevel.xpRequiredForLevel(1), 0)
        XCTAssertEqual(PlayerLevel.xpRequiredForLevel(2), 100)    // (2-1)^2 * 100 = 100
        XCTAssertEqual(PlayerLevel.xpRequiredForLevel(3), 400)    // (3-1)^2 * 100 = 400
        XCTAssertEqual(PlayerLevel.xpRequiredForLevel(5), 1600)   // (5-1)^2 * 100 = 1600
        XCTAssertEqual(PlayerLevel.xpRequiredForLevel(10), 8100)  // (10-1)^2 * 100 = 8100
    }
    
    func testXPForLevelProgression() {
        // Verify that XP required increases quadratically
        let xp5 = PlayerLevel.xpRequiredForLevel(5)
        let xp10 = PlayerLevel.xpRequiredForLevel(10)
        let xp20 = PlayerLevel.xpRequiredForLevel(20)
        
        XCTAssertEqual(xp5, 1600)
        XCTAssertEqual(xp10, 8100)
        XCTAssertEqual(xp20, 36100)
    }
    
    // MARK: - PlayerLevel Initialization and Properties
    
    func testPlayerLevelInit() {
        let player = PlayerLevel(xp: 500)
        
        XCTAssertEqual(player.totalXP, 500)
        XCTAssertEqual(player.level, 3) // sqrt(500/100) + 1 ≈ 3.23 → 3
    }
    
    func testPlayerLevelCurrentLevelXP() {
        let player = PlayerLevel(xp: 500)
        
        let currentLevelXP = player.currentLevelXP
        let xpForCurrentLevel = PlayerLevel.xpRequiredForLevel(player.level)
        
        XCTAssertEqual(currentLevelXP, 500 - xpForCurrentLevel)
        XCTAssertEqual(currentLevelXP, 100) // 500 - 400 = 100
    }
    
    func testPlayerLevelXPForNextLevel() {
        let player = PlayerLevel(xp: 500)
        
        let xpForNext = player.xpForNextLevel
        let xpForLevel4 = PlayerLevel.xpRequiredForLevel(4)
        let xpForLevel3 = PlayerLevel.xpRequiredForLevel(3)
        
        XCTAssertEqual(xpForNext, xpForLevel4 - xpForLevel3)
        XCTAssertEqual(xpForNext, 500) // Level 4 needs 900 - 400 = 500 XP
    }
    
    func testPlayerLevelProgressToNextLevel() {
        let player = PlayerLevel(xp: 500)
        
        // At 500 XP total, level 3 (needs 400), level 4 needs 900
        // Current level XP: 500 - 400 = 100
        // XP for next level: 900 - 400 = 500
        // Progress: 100 / 500 = 0.2
        
        XCTAssertEqual(player.progressToNextLevel, 0.2, accuracy: 0.001)
    }
    
    func testPlayerLevelProgressAtLevelStart() {
        let player = PlayerLevel(xp: 400) // Exactly at level 3 start
        XCTAssertEqual(player.progressToNextLevel, 0.0)
    }
    
    func testPlayerLevelProgressNearLevelEnd() {
        let player = PlayerLevel(xp: 890) // Almost at level 4 (needs 900)
        
        // Level 3 needs 400, level 4 needs 900
        // Current: 890 - 400 = 490
        // Needed: 900 - 400 = 500
        // Progress: 490 / 500 = 0.98
        
        XCTAssertEqual(player.progressToNextLevel, 0.98, accuracy: 0.001)
    }
    
    // MARK: - Adding XP
    
    func testAddXPBasic() {
        var player = PlayerLevel(xp: 100)
        XCTAssertEqual(player.level, 2)
        
        player.addXP(300)
        XCTAssertEqual(player.totalXP, 400)
        XCTAssertEqual(player.level, 3)
    }
    
    func testAddXPMultipleLevels() {
        var player = PlayerLevel(xp: 100)
        XCTAssertEqual(player.level, 2)
        
        player.addXP(1500) // Jump to 1600 total
        XCTAssertEqual(player.totalXP, 1600)
        XCTAssertEqual(player.level, 5)
    }
    
    func testAddXPZero() {
        var player = PlayerLevel(xp: 500)
        let originalLevel = player.level
        
        player.addXP(0)
        XCTAssertEqual(player.totalXP, 500)
        XCTAssertEqual(player.level, originalLevel)
    }
    
    func testAddXPSmallIncrement() {
        var player = PlayerLevel(xp: 500)
        
        player.addXP(10)
        XCTAssertEqual(player.totalXP, 510)
        XCTAssertEqual(player.level, 3) // Still level 3
    }
    
    // MARK: - XPAward Enum Tests
    
    func testXPAwardValues() {
        XCTAssertEqual(XPAward.correctBasic.rawValue, 10)
        XCTAssertEqual(XPAward.correctIntermediate.rawValue, 15)
        XCTAssertEqual(XPAward.correctAdvanced.rawValue, 20)
        XCTAssertEqual(XPAward.perfectSession.rawValue, 50)
        XCTAssertEqual(XPAward.curriculumModule.rawValue, 100)
        XCTAssertEqual(XPAward.dailyStreak.rawValue, 5)
    }
    
    func testXPAwardUsage() {
        var player = PlayerLevel(xp: 0)
        
        // Answer 10 basic questions correctly
        for _ in 1...10 {
            player.addXP(XPAward.correctBasic.rawValue)
        }
        
        XCTAssertEqual(player.totalXP, 100)
        XCTAssertEqual(player.level, 2)
    }
    
    func testXPAwardPerfectSession() {
        var player = PlayerLevel(xp: 50)
        
        player.addXP(XPAward.perfectSession.rawValue)
        XCTAssertEqual(player.totalXP, 100)
        XCTAssertEqual(player.level, 2)
    }
    
    func testXPAwardCurriculumModule() {
        var player = PlayerLevel(xp: 0)
        
        // Complete a curriculum module
        player.addXP(XPAward.curriculumModule.rawValue)
        XCTAssertEqual(player.totalXP, 100)
        XCTAssertEqual(player.level, 2)
    }
    
    func testXPAwardDailyStreak() {
        var player = PlayerLevel(xp: 95)
        
        // Daily streak bonus pushes to level 2
        player.addXP(XPAward.dailyStreak.rawValue)
        XCTAssertEqual(player.totalXP, 100)
        XCTAssertEqual(player.level, 2)
    }
    
    // MARK: - Codable Tests
    
    func testPlayerLevelCodable() throws {
        let original = PlayerLevel(xp: 1234)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PlayerLevel.self, from: data)
        
        XCTAssertEqual(decoded.totalXP, original.totalXP)
        XCTAssertEqual(decoded.level, original.level)
        XCTAssertEqual(decoded.currentLevelXP, original.currentLevelXP)
        XCTAssertEqual(decoded.xpForNextLevel, original.xpForNextLevel)
        XCTAssertEqual(decoded.progressToNextLevel, original.progressToNextLevel, accuracy: 0.001)
    }
    
    // MARK: - Equatable Tests
    
    func testPlayerLevelEquality() {
        let player1 = PlayerLevel(xp: 500)
        let player2 = PlayerLevel(xp: 500)
        
        XCTAssertEqual(player1, player2)
    }
    
    func testPlayerLevelInequality() {
        let player1 = PlayerLevel(xp: 500)
        let player2 = PlayerLevel(xp: 600)
        
        XCTAssertNotEqual(player1, player2)
    }
    
    // MARK: - Edge Cases
    
    func testPlayerLevelNegativeXP() {
        // Ensure level doesn't go below 1 even with negative values
        let player = PlayerLevel(xp: -100)
        XCTAssertEqual(player.level, 1)
    }
    
    func testPlayerLevelVeryHighXP() {
        let player = PlayerLevel(xp: 100000)
        let expectedLevel = PlayerLevel.levelFromXP(100000)
        
        XCTAssertEqual(player.level, expectedLevel)
        XCTAssertGreaterThan(player.level, 20)
    }
    
    func testProgressToNextLevelNeverExceedsOne() {
        // Test various XP values
        for xp in stride(from: 0, to: 10000, by: 50) {
            let player = PlayerLevel(xp: xp)
            XCTAssertLessThanOrEqual(player.progressToNextLevel, 1.0)
            XCTAssertGreaterThanOrEqual(player.progressToNextLevel, 0.0)
        }
    }
}
