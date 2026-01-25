import XCTest
@testable import JazzHarmonyQuiz

final class SettingsManagerTests: XCTestCase {
    
    var settingsManager: SettingsManager!
    
    override func setUp() {
        super.setUp()
        settingsManager = SettingsManager.shared
        // Reset to defaults before each test
        settingsManager.resetToDefaults()
    }
    
    override func tearDown() {
        settingsManager.resetToDefaults()
        super.tearDown()
    }
    
    // MARK: - Audio Settings Tests
    
    func testDefaultAudioEnabled() {
        XCTAssertTrue(settingsManager.audioEnabled, "Audio should be enabled by default")
    }
    
    func testToggleAudio() {
        settingsManager.audioEnabled = false
        XCTAssertFalse(settingsManager.audioEnabled)
        
        settingsManager.audioEnabled = true
        XCTAssertTrue(settingsManager.audioEnabled)
    }
    
    func testDefaultVolume() {
        XCTAssertEqual(settingsManager.volume, 0.7, accuracy: 0.01, "Default volume should be 70%")
    }
    
    func testVolumeRange() {
        settingsManager.volume = 0.0
        XCTAssertEqual(settingsManager.volume, 0.0, accuracy: 0.01)
        
        settingsManager.volume = 1.0
        XCTAssertEqual(settingsManager.volume, 1.0, accuracy: 0.01)
        
        settingsManager.volume = 0.5
        XCTAssertEqual(settingsManager.volume, 0.5, accuracy: 0.01)
    }
    
    // MARK: - Difficulty Settings Tests
    
    func testDefaultChordDifficulty() {
        XCTAssertEqual(settingsManager.chordDifficulty, .beginner)
    }
    
    func testChordDifficultyLevels() {
        settingsManager.chordDifficulty = .intermediate
        XCTAssertEqual(settingsManager.chordDifficulty, .intermediate)
        
        settingsManager.chordDifficulty = .advanced
        XCTAssertEqual(settingsManager.chordDifficulty, .advanced)
        
        settingsManager.chordDifficulty = .beginner
        XCTAssertEqual(settingsManager.chordDifficulty, .beginner)
    }
    
    func testDefaultScaleDifficulty() {
        XCTAssertEqual(settingsManager.scaleDifficulty, .beginner)
    }
    
    func testScaleDifficultyLevels() {
        settingsManager.scaleDifficulty = .intermediate
        XCTAssertEqual(settingsManager.scaleDifficulty, .intermediate)
        
        settingsManager.scaleDifficulty = .advanced
        XCTAssertEqual(settingsManager.scaleDifficulty, .advanced)
    }
    
    func testDefaultIntervalDifficulty() {
        XCTAssertEqual(settingsManager.intervalDifficulty, .beginner)
    }
    
    func testIntervalDifficultyLevels() {
        settingsManager.intervalDifficulty = .intermediate
        XCTAssertEqual(settingsManager.intervalDifficulty, .intermediate)
        
        settingsManager.intervalDifficulty = .advanced
        XCTAssertEqual(settingsManager.intervalDifficulty, .advanced)
    }
    
    // MARK: - Display Settings Tests
    
    func testDefaultShowNoteNames() {
        XCTAssertTrue(settingsManager.showNoteNames, "Note names should be shown by default")
    }
    
    func testToggleShowNoteNames() {
        settingsManager.showNoteNames = false
        XCTAssertFalse(settingsManager.showNoteNames)
        
        settingsManager.showNoteNames = true
        XCTAssertTrue(settingsManager.showNoteNames)
    }
    
    func testDefaultAutoPlay() {
        XCTAssertTrue(settingsManager.autoPlay, "Auto-play should be enabled by default")
    }
    
    func testToggleAutoPlay() {
        settingsManager.autoPlay = false
        XCTAssertFalse(settingsManager.autoPlay)
        
        settingsManager.autoPlay = true
        XCTAssertTrue(settingsManager.autoPlay)
    }
    
    // MARK: - Practice Settings Tests
    
    func testDefaultQuestionsPerSession() {
        XCTAssertEqual(settingsManager.questionsPerSession, 10)
    }
    
    func testQuestionsPerSessionRange() {
        settingsManager.questionsPerSession = 5
        XCTAssertEqual(settingsManager.questionsPerSession, 5)
        
        settingsManager.questionsPerSession = 20
        XCTAssertEqual(settingsManager.questionsPerSession, 20)
        
        settingsManager.questionsPerSession = 50
        XCTAssertEqual(settingsManager.questionsPerSession, 50)
    }
    
    func testDefaultShowTimer() {
        XCTAssertFalse(settingsManager.showTimer, "Timer should be hidden by default")
    }
    
    func testToggleShowTimer() {
        settingsManager.showTimer = true
        XCTAssertTrue(settingsManager.showTimer)
        
        settingsManager.showTimer = false
        XCTAssertFalse(settingsManager.showTimer)
    }
    
    // MARK: - Persistence Tests
    
    func testSettingsPersistence() {
        // Change multiple settings
        settingsManager.audioEnabled = false
        settingsManager.volume = 0.5
        settingsManager.chordDifficulty = .advanced
        settingsManager.questionsPerSession = 25
        
        // Create new instance (simulating app restart)
        let newManager = SettingsManager.shared
        
        // Verify settings persisted
        XCTAssertFalse(newManager.audioEnabled)
        XCTAssertEqual(newManager.volume, 0.5, accuracy: 0.01)
        XCTAssertEqual(newManager.chordDifficulty, .advanced)
        XCTAssertEqual(newManager.questionsPerSession, 25)
    }
    
    func testResetToDefaults() {
        // Change all settings
        settingsManager.audioEnabled = false
        settingsManager.volume = 0.3
        settingsManager.chordDifficulty = .advanced
        settingsManager.scaleDifficulty = .advanced
        settingsManager.intervalDifficulty = .advanced
        settingsManager.showNoteNames = false
        settingsManager.autoPlay = false
        settingsManager.questionsPerSession = 50
        settingsManager.showTimer = true
        
        // Reset
        settingsManager.resetToDefaults()
        
        // Verify all back to defaults
        XCTAssertTrue(settingsManager.audioEnabled)
        XCTAssertEqual(settingsManager.volume, 0.7, accuracy: 0.01)
        XCTAssertEqual(settingsManager.chordDifficulty, .beginner)
        XCTAssertEqual(settingsManager.scaleDifficulty, .beginner)
        XCTAssertEqual(settingsManager.intervalDifficulty, .beginner)
        XCTAssertTrue(settingsManager.showNoteNames)
        XCTAssertTrue(settingsManager.autoPlay)
        XCTAssertEqual(settingsManager.questionsPerSession, 10)
        XCTAssertFalse(settingsManager.showTimer)
    }
    
    // MARK: - Singleton Tests
    
    func testSingletonInstance() {
        let instance1 = SettingsManager.shared
        let instance2 = SettingsManager.shared
        
        XCTAssertTrue(instance1 === instance2, "SettingsManager should be a singleton")
    }
    
    func testSingletonStateSharing() {
        let instance1 = SettingsManager.shared
        instance1.audioEnabled = false
        
        let instance2 = SettingsManager.shared
        XCTAssertFalse(instance2.audioEnabled, "Changes should be shared across singleton instances")
    }
}
