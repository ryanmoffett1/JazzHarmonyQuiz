//
//  PlayerProfileTests.swift
//  JazzHarmonyQuizTests
//
//  Created on 2026-01-30.
//

import XCTest
@testable import JazzHarmonyQuiz

final class PlayerProfileTests: XCTestCase {
    
    var sut: PlayerProfile!
    
    override func setUp() {
        sut = PlayerProfile()
    }
    
    override func tearDown() {
        sut = nil
    }
    
    // MARK: - Initialization Tests
    
    func test_initialization_defaultValues() {
        XCTAssertEqual(sut.playerName, "Jazz Cat")
        XCTAssertEqual(sut.level, 1)
        XCTAssertEqual(sut.totalXP, 0)
        XCTAssertEqual(sut.selectedAvatar, .saxophone)
    }
    
    func test_initialization_defaultStats() {
        XCTAssertEqual(sut.stats[.harmony], 1)
        XCTAssertEqual(sut.stats[.ear], 1)
        XCTAssertEqual(sut.stats[.theory], 1)
        XCTAssertEqual(sut.stats[.flow], 1)
        XCTAssertEqual(sut.stats[.speed], 1)
        XCTAssertEqual(sut.stats[.precision], 1)
    }
    
    // MARK: - XP and Level Tests
    
    func test_addXP_incrementsTotalXP() {
        sut.addXP(100)
        
        XCTAssertEqual(sut.totalXP, 100)
    }
    
    func test_addXP_multipleAdds_accumulates() {
        sut.addXP(50)
        sut.addXP(75)
        sut.addXP(25)
        
        XCTAssertEqual(sut.totalXP, 150)
    }
    
    func test_xpToNextLevel_level1_requiresCorrectXP() {
        XCTAssertEqual(sut.xpToNextLevel, 100) // Level 1→2 requires 100 XP
    }
    
    func test_levelUp_whenEnoughXP_increasesLevel() {
        sut.addXP(100) // Enough for level 2
        
        XCTAssertGreaterThanOrEqual(sut.level, 2)
    }
    
    func test_levelProgress_startsAtZero() {
        XCTAssertEqual(sut.levelProgress, 0.0, accuracy: 0.01)
    }
    
    func test_levelProgress_incrementsWithXP() {
        sut.addXP(50) // 50/100 = 0.5
        
        XCTAssertEqual(sut.levelProgress, 0.5, accuracy: 0.01)
    }
    
    // MARK: - Stat Tests
    
    func test_increaseStat_incrementsStatValue() {
        let initialHarmony = sut.stats[.harmony] ?? 1
        
        sut.increaseStat(.harmony)
        
        XCTAssertEqual(sut.stats[.harmony], initialHarmony + 1)
    }
    
    func test_increaseStat_multipleStats() {
        sut.increaseStat(.harmony)
        sut.increaseStat(.ear)
        sut.increaseStat(.theory)
        
        XCTAssertGreaterThan(sut.stats[.harmony] ?? 0, 1)
        XCTAssertGreaterThan(sut.stats[.ear] ?? 0, 1)
        XCTAssertGreaterThan(sut.stats[.theory] ?? 0, 1)
    }
    
    func test_totalStatPoints_sumsAllStats() {
        sut.increaseStat(.harmony) // 2
        sut.increaseStat(.ear)     // 2
        // Others remain 1
        
        // Total: 2+2+1+1+1+1 = 8
        XCTAssertEqual(sut.totalStatPoints, 8)
    }
    
    func test_allStats_haveValues() {
        for stat in JazzStat.allCases {
            XCTAssertNotNil(sut.stats[stat], "Stat \(stat) should have a value")
            XCTAssertGreaterThan(sut.stats[stat] ?? 0, 0, "Stat \(stat) should be > 0")
        }
    }
    
    // MARK: - Practice Mode Stats Tests
    
    func test_updateModeStats_chordDrill_updatesCorrectStats() {
        let initialHarmony = sut.stats[.harmony] ?? 1
        
        sut.updateModeStats(.chordDrill, accuracy: 0.9, speedBonus: false)
        
        XCTAssertGreaterThan(sut.stats[.harmony] ?? 0, initialHarmony)
    }
    
    func test_updateModeStats_highAccuracy_increasesStats() {
        sut.updateModeStats(.chordDrill, accuracy: 0.95, speedBonus: false)
        
        // High accuracy should increase stats
        XCTAssertGreaterThan(sut.totalStatPoints, 6) // Started with 6 (all 1s)
    }
    
    func test_updateModeStats_lowAccuracy_mayNotIncreaseStats() {
        let initialTotal = sut.totalStatPoints
        
        sut.updateModeStats(.chordDrill, accuracy: 0.3, speedBonus: false)
        
        // Low accuracy might not increase stats much
        XCTAssertLessThanOrEqual(sut.totalStatPoints, initialTotal + 1)
    }
    
    // MARK: - Practice History Tests
    
    func test_recordPracticeSession_addsToPracticeLog() {
        let initialCount = sut.practiceLog.count
        
        sut.recordPracticeSession(
            mode: .chordDrill,
            duration: 300,
            accuracy: 0.85,
            questionsAnswered: 10
        )
        
        XCTAssertEqual(sut.practiceLog.count, initialCount + 1)
    }
    
    func test_practiceLog_containsSessionData() {
        sut.recordPracticeSession(
            mode: .scaleDrill,
            duration: 600,
            accuracy: 0.92,
            questionsAnswered: 15
        )
        
        guard let lastSession = sut.practiceLog.last else {
            XCTFail("Should have recorded session")
            return
        }
        
        XCTAssertEqual(lastSession.mode, .scaleDrill)
        XCTAssertEqual(lastSession.duration, 600)
        XCTAssertEqual(lastSession.accuracy, 0.92, accuracy: 0.01)
        XCTAssertEqual(lastSession.questionsAnswered, 15)
    }
    
    func test_totalPracticeTime_sumsAllSessions() {
        sut.recordPracticeSession(mode: .chordDrill, duration: 300, accuracy: 0.8, questionsAnswered: 10)
        sut.recordPracticeSession(mode: .scaleDrill, duration: 200, accuracy: 0.9, questionsAnswered: 8)
        
        XCTAssertEqual(sut.totalPracticeTime, 500)
    }
    
    // MARK: - Avatar Tests
    
    func test_setAvatar_updatesSelectedAvatar() {
        sut.selectedAvatar = .piano
        XCTAssertEqual(sut.selectedAvatar, .piano)
        
        sut.selectedAvatar = .guitar
        XCTAssertEqual(sut.selectedAvatar, .guitar)
    }
    
    func test_allAvatars_haveNames() {
        for avatar in PlayerAvatar.allCases {
            XCTAssertFalse(avatar.name.isEmpty)
        }
    }
    
    // MARK: - Player Name Tests
    
    func test_setPlayerName_updatesName() {
        sut.playerName = "Charlie Parker"
        XCTAssertEqual(sut.playerName, "Charlie Parker")
    }
    
    func test_playerName_canBeEmpty() {
        sut.playerName = ""
        XCTAssertEqual(sut.playerName, "")
    }
    
    // MARK: - Stat Enum Tests
    
    func test_allStats_haveEmojis() {
        for stat in JazzStat.allCases {
            XCTAssertFalse(stat.emoji.isEmpty)
        }
    }
    
    func test_allStats_haveDescriptions() {
        for stat in JazzStat.allCases {
            XCTAssertFalse(stat.description.isEmpty)
        }
    }
    
    func test_allStats_haveColors() {
        for stat in JazzStat.allCases {
            // Just ensure color property exists (SwiftUI Color)
            _ = stat.color
        }
    }
    
    // MARK: - Practice Mode Enum Tests
    
    func test_allModes_haveEmojis() {
        for mode in PracticeMode.allCases {
            XCTAssertFalse(mode.emoji.isEmpty)
        }
    }
    
    func test_allModes_havePrimaryStats() {
        for mode in PracticeMode.allCases {
            XCTAssertFalse(mode.primaryStats.isEmpty, "\(mode.rawValue) should have primary stats")
        }
    }
    
    func test_chordDrill_primaryStats_includeHarmony() {
        XCTAssertTrue(PracticeMode.chordDrill.primaryStats.contains(.harmony))
    }
    
    func test_intervalDrill_primaryStats_includeEar() {
        XCTAssertTrue(PracticeMode.intervalDrill.primaryStats.contains(.ear))
    }
    
    func test_scaleDrill_primaryStats_includeTheory() {
        XCTAssertTrue(PracticeMode.scaleDrill.primaryStats.contains(.theory))
    }
    
    // MARK: - Edge Cases
    
    func test_addXP_negativeAmount_doesNotDecrease() {
        sut.addXP(100)
        sut.addXP(-50)
        
        // Should not go below 100
        XCTAssertGreaterThanOrEqual(sut.totalXP, 100)
    }
    
    func test_stats_cannotGoNegative() {
        // Stats should always be positive
        for stat in JazzStat.allCases {
            XCTAssertGreaterThan(sut.stats[stat] ?? 0, 0)
        }
    }
    
    func test_level_startsAtOne() {
        XCTAssertEqual(sut.level, 1)
    }
}
