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
        
        XCTAssertEqual(player.xp, 500)
        XCTAssertEqual(player.level, 3) // sqrt(500/100) + 1 ≈ 3.23 → 3
    }
    
    func testPlayerLevelXPInCurrentLevel() {
        let player = PlayerLevel(xp: 500)
        
        let xpForCurrentLevel = PlayerLevel.xpRequiredForLevel(player.level)
        let xpInCurrentLevel = player.xp - xpForCurrentLevel
        
        XCTAssertEqual(xpInCurrentLevel, 100) // 500 - 400 = 100
    }
    
    func testPlayerLevelXPForNextLevel() {
        let player = PlayerLevel(xp: 500)
        
        XCTAssertEqual(player.xpForNextLevel, 900) // Level 4 needs 900 total
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
    
    func testPlayerLevelXPUntilNextLevel() {
        let player = PlayerLevel(xp: 500)
        XCTAssertEqual(player.xpUntilNextLevel, 400) // 900 - 500 = 400
    }
    
    // MARK: - Adding XP (Immutable - creates new instance)
    
    func testCreatePlayerLevelWithMoreXP() {
        let player = PlayerLevel(xp: 100)
        XCTAssertEqual(player.level, 2)
        
        let newPlayer = PlayerLevel(xp: player.xp + 300)
        XCTAssertEqual(newPlayer.xp, 400)
        XCTAssertEqual(newPlayer.level, 3)
    }
    
    func testCreatePlayerLevelMultipleLevels() {
        let player = PlayerLevel(xp: 100)
        XCTAssertEqual(player.level, 2)
        
        let newPlayer = PlayerLevel(xp: player.xp + 1500) // Jump to 1600 total
        XCTAssertEqual(newPlayer.xp, 1600)
        XCTAssertEqual(newPlayer.level, 5)
    }
    
    func testCreatePlayerLevelWithSameXP() {
        let player = PlayerLevel(xp: 500)
        let originalLevel = player.level
        
        let newPlayer = PlayerLevel(xp: player.xp + 0)
        XCTAssertEqual(newPlayer.xp, 500)
        XCTAssertEqual(newPlayer.level, originalLevel)
    }
    
    func testCreatePlayerLevelSmallIncrement() {
        let player = PlayerLevel(xp: 500)
        
        let newPlayer = PlayerLevel(xp: player.xp + 10)
        XCTAssertEqual(newPlayer.xp, 510)
        XCTAssertEqual(newPlayer.level, player.level) // Still level 3
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
        let initialPlayer = PlayerLevel(xp: 0)
        var currentXP = initialPlayer.xp
        
        // Answer 10 basic questions correctly
        for _ in 1...10 {
            currentXP += XPAward.correctBasic.rawValue
        }
        
        let player = PlayerLevel(xp: currentXP)
        XCTAssertEqual(player.xp, 100)
        XCTAssertEqual(player.level, 2)
    }
    
    func testXPAwardPerfectSession() {
        let player = PlayerLevel(xp: 50 + XPAward.perfectSession.rawValue)
        XCTAssertEqual(player.xp, 100)
        XCTAssertEqual(player.level, 2)
    }
    
    func testXPAwardCurriculumModule() {
        // Complete a curriculum module
        let player = PlayerLevel(xp: XPAward.curriculumModule.rawValue)
        XCTAssertEqual(player.xp, 100)
        XCTAssertEqual(player.level, 2)
    }
    
    func testXPAwardDailyStreak() {
        // Daily streak bonus pushes to level 2
        let player = PlayerLevel(xp: 95 + XPAward.dailyStreak.rawValue)
        XCTAssertEqual(player.xp, 100)
        XCTAssertEqual(player.level, 2)
    }
    
    // MARK: - Codable Tests
    
    func testPlayerLevelCodable() throws {
        let original = PlayerLevel(xp: 1234)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(PlayerLevel.self, from: data)
        
        XCTAssertEqual(decoded.xp, original.xp)
        XCTAssertEqual(decoded.level, original.level)
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
