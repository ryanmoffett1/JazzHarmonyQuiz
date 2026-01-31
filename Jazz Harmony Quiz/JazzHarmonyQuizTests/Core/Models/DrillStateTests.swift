import XCTest
@testable import JazzHarmonyQuiz

final class DrillStateTests: XCTestCase {
    
    // MARK: - DrillLaunchMode Tests
    
    func test_drillLaunchMode_curriculum_isConfigLocked() {
        let mode = DrillLaunchMode.curriculum(moduleId: UUID())
        XCTAssertTrue(mode.isConfigLocked)
    }
    
    func test_drillLaunchMode_curriculum_doesNotShowSetup() {
        let mode = DrillLaunchMode.curriculum(moduleId: UUID())
        XCTAssertFalse(mode.showsSetupScreen)
    }
    
    func test_drillLaunchMode_curriculum_hasModuleId() {
        let testId = UUID()
        let mode = DrillLaunchMode.curriculum(moduleId: testId)
        XCTAssertEqual(mode.moduleId, testId)
    }
    
    func test_drillLaunchMode_quickPractice_isConfigLocked() {
        let mode = DrillLaunchMode.quickPractice
        XCTAssertTrue(mode.isConfigLocked)
    }
    
    func test_drillLaunchMode_quickPractice_doesNotShowSetup() {
        let mode = DrillLaunchMode.quickPractice
        XCTAssertFalse(mode.showsSetupScreen)
    }
    
    func test_drillLaunchMode_quickPractice_hasNoModuleId() {
        let mode = DrillLaunchMode.quickPractice
        XCTAssertNil(mode.moduleId)
    }
    
    func test_drillLaunchMode_freePractice_isNotConfigLocked() {
        let mode = DrillLaunchMode.freePractice
        XCTAssertFalse(mode.isConfigLocked)
    }
    
    func test_drillLaunchMode_freePractice_showsSetup() {
        let mode = DrillLaunchMode.freePractice
        XCTAssertTrue(mode.showsSetupScreen)
    }
    
    func test_drillLaunchMode_freePractice_hasNoModuleId() {
        let mode = DrillLaunchMode.freePractice
        XCTAssertNil(mode.moduleId)
    }
    
    func test_drillLaunchMode_equatable() {
        let id1 = UUID()
        let id2 = UUID()
        
        XCTAssertEqual(DrillLaunchMode.curriculum(moduleId: id1), DrillLaunchMode.curriculum(moduleId: id1))
        XCTAssertNotEqual(DrillLaunchMode.curriculum(moduleId: id1), DrillLaunchMode.curriculum(moduleId: id2))
        XCTAssertEqual(DrillLaunchMode.quickPractice, DrillLaunchMode.quickPractice)
        XCTAssertEqual(DrillLaunchMode.freePractice, DrillLaunchMode.freePractice)
        XCTAssertNotEqual(DrillLaunchMode.quickPractice, DrillLaunchMode.freePractice)
    }
    
    // MARK: - DrillState Tests
    
    func test_drillState_allCases() {
        let allStates = DrillState.allCases
        XCTAssertEqual(allStates.count, 3)
        XCTAssertTrue(allStates.contains(.setup))
        XCTAssertTrue(allStates.contains(.active))
        XCTAssertTrue(allStates.contains(.results))
    }
    
    func test_drillState_equatable() {
        XCTAssertEqual(DrillState.setup, DrillState.setup)
        XCTAssertEqual(DrillState.active, DrillState.active)
        XCTAssertEqual(DrillState.results, DrillState.results)
        XCTAssertNotEqual(DrillState.setup, DrillState.active)
        XCTAssertNotEqual(DrillState.active, DrillState.results)
    }
    
    // MARK: - DrillSessionResult Tests
    
    func test_drillSessionResult_initialization() {
        let result = DrillSessionResult(
            drillType: .chordDrill,
            startTime: Date(),
            endTime: Date().addingTimeInterval(60),
            totalQuestions: 10,
            correctAnswers: 7,
            missedItems: []
        )
        
        XCTAssertEqual(result.drillType, .chordDrill)
        XCTAssertEqual(result.totalQuestions, 10)
        XCTAssertEqual(result.correctAnswers, 7)
        XCTAssertNotNil(result.id)
    }
    
    func test_drillSessionResult_accuracyCalculation() {
        let result = DrillSessionResult(
            drillType: .chordDrill,
            startTime: Date(),
            endTime: Date(),
            totalQuestions: 10,
            correctAnswers: 7,
            missedItems: []
        )
        
        XCTAssertEqual(result.accuracy, 0.7, accuracy: 0.001)
    }
    
    func test_drillSessionResult_perfectAccuracy() {
        let result = DrillSessionResult(
            drillType: .scaleDrill,
            startTime: Date(),
            endTime: Date(),
            totalQuestions: 10,
            correctAnswers: 10,
            missedItems: []
        )
        
        XCTAssertEqual(result.accuracy, 1.0)
        XCTAssertEqual(result.accuracyPercentage, 100)
    }
    
    func test_drillSessionResult_zeroAccuracy() {
        let result = DrillSessionResult(
            drillType: .intervalDrill,
            startTime: Date(),
            endTime: Date(),
            totalQuestions: 10,
            correctAnswers: 0,
            missedItems: []
        )
        
        XCTAssertEqual(result.accuracy, 0.0)
        XCTAssertEqual(result.accuracyPercentage, 0)
    }
    
    func test_drillSessionResult_zeroQuestionsHandling() {
        let result = DrillSessionResult(
            drillType: .chordDrill,
            startTime: Date(),
            endTime: Date(),
            totalQuestions: 0,
            correctAnswers: 0,
            missedItems: []
        )
        
        XCTAssertEqual(result.accuracy, 0.0)
    }
    
    func test_drillSessionResult_durationCalculation() {
        let start = Date()
        let end = start.addingTimeInterval(125) // 2 minutes 5 seconds
        
        let result = DrillSessionResult(
            drillType: .cadenceDrill,
            startTime: start,
            endTime: end,
            totalQuestions: 5,
            correctAnswers: 3,
            missedItems: []
        )
        
        XCTAssertEqual(result.duration, 125, accuracy: 0.1)
    }
    
    func test_drillSessionResult_formattedDuration() {
        let start = Date()
        let end = start.addingTimeInterval(125) // 2 minutes 5 seconds
        
        let result = DrillSessionResult(
            drillType: .chordDrill,
            startTime: start,
            endTime: end,
            totalQuestions: 10,
            correctAnswers: 7,
            missedItems: []
        )
        
        XCTAssertEqual(result.formattedDuration, "2:05")
    }
    
    func test_drillSessionResult_formattedDuration_underOneMinute() {
        let start = Date()
        let end = start.addingTimeInterval(45)
        
        let result = DrillSessionResult(
            drillType: .chordDrill,
            startTime: start,
            endTime: end,
            totalQuestions: 5,
            correctAnswers: 4,
            missedItems: []
        )
        
        XCTAssertEqual(result.formattedDuration, "0:45")
    }
    
    func test_drillSessionResult_formattedDuration_exactMinute() {
        let start = Date()
        let end = start.addingTimeInterval(120)
        
        let result = DrillSessionResult(
            drillType: .scaleDrill,
            startTime: start,
            endTime: end,
            totalQuestions: 8,
            correctAnswers: 6,
            missedItems: []
        )
        
        XCTAssertEqual(result.formattedDuration, "2:00")
    }
    
    func test_drillSessionResult_accuracyPercentage() {
        let result = DrillSessionResult(
            drillType: .intervalDrill,
            startTime: Date(),
            endTime: Date(),
            totalQuestions: 20,
            correctAnswers: 15,
            missedItems: []
        )
        
        XCTAssertEqual(result.accuracyPercentage, 75)
    }
    
    func test_drillSessionResult_withMissedItems() {
        let missedItems = [
            MissedItem(question: "What is C major 7?", userAnswer: "C E G Bb", correctAnswer: "C E G B", category: "Chord"),
            MissedItem(question: "What is F dorian?", userAnswer: "F G Ab Bb C D E F", correctAnswer: "F G Ab Bb C D Eb F", category: "Scale")
        ]
        
        let result = DrillSessionResult(
            drillType: .chordDrill,
            startTime: Date(),
            endTime: Date(),
            totalQuestions: 10,
            correctAnswers: 8,
            missedItems: missedItems
        )
        
        XCTAssertEqual(result.missedItems.count, 2)
        XCTAssertEqual(result.missedItems[0].question, "What is C major 7?")
        XCTAssertEqual(result.missedItems[1].category, "Scale")
    }
    
    // MARK: - MissedItem Tests
    
    func test_missedItem_initialization() {
        let item = MissedItem(
            question: "What chord is this?",
            userAnswer: "Cmaj7",
            correctAnswer: "C7",
            category: "Chord"
        )
        
        XCTAssertEqual(item.question, "What chord is this?")
        XCTAssertEqual(item.userAnswer, "Cmaj7")
        XCTAssertEqual(item.correctAnswer, "C7")
        XCTAssertEqual(item.category, "Chord")
        XCTAssertNotNil(item.id)
    }
    
    func test_missedItem_withNilCategory() {
        let item = MissedItem(
            question: "Test question",
            userAnswer: "User's answer",
            correctAnswer: "Correct answer",
            category: nil
        )
        
        XCTAssertNil(item.category)
    }
    
    func test_missedItem_uniqueIDs() {
        let item1 = MissedItem(question: "Q1", userAnswer: "A1", correctAnswer: "C1", category: nil)
        let item2 = MissedItem(question: "Q1", userAnswer: "A1", correctAnswer: "C1", category: nil)
        
        XCTAssertNotEqual(item1.id, item2.id)
    }
    
    // MARK: - ChordDrillPreset Tests
    
    func test_chordDrillPreset_allCases() {
        let presets = ChordDrillPreset.allCases
        XCTAssertEqual(presets.count, 3)
        XCTAssertTrue(presets.contains(.basicTriads))
        XCTAssertTrue(presets.contains(.seventhChords))
        XCTAssertTrue(presets.contains(.fullWorkout))
    }
    
    func test_chordDrillPreset_names() {
        XCTAssertEqual(ChordDrillPreset.basicTriads.name, "Basic Triads")
        XCTAssertEqual(ChordDrillPreset.seventhChords.name, "7th Chords")
        XCTAssertEqual(ChordDrillPreset.fullWorkout.name, "Full Workout")
    }
    
    func test_chordDrillPreset_descriptions() {
        XCTAssertEqual(ChordDrillPreset.basicTriads.description, "Major and minor triads")
        XCTAssertEqual(ChordDrillPreset.seventhChords.description, "7, maj7, m7, m7b5, dim7")
        XCTAssertEqual(ChordDrillPreset.fullWorkout.description, "All chord types, random keys")
    }
    
    func test_chordDrillPreset_icons() {
        XCTAssertEqual(ChordDrillPreset.basicTriads.icon, "1.circle")
        XCTAssertEqual(ChordDrillPreset.seventhChords.icon, "7.circle")
        XCTAssertEqual(ChordDrillPreset.fullWorkout.icon, "flame")
    }
    
    // MARK: - CadenceDrillPreset Tests
    
    func test_cadenceDrillPreset_allCases() {
        let presets = CadenceDrillPreset.allCases
        XCTAssertEqual(presets.count, 3)
        XCTAssertTrue(presets.contains(.majorIIVI))
        XCTAssertTrue(presets.contains(.minorIIVI))
        XCTAssertTrue(presets.contains(.mixedCadences))
    }
    
    func test_cadenceDrillPreset_names() {
        XCTAssertEqual(CadenceDrillPreset.majorIIVI.name, "Major ii-V-I")
        XCTAssertEqual(CadenceDrillPreset.minorIIVI.name, "Minor ii-V-i")
        XCTAssertEqual(CadenceDrillPreset.mixedCadences.name, "Mixed Cadences")
    }
    
    func test_cadenceDrillPreset_descriptions() {
        XCTAssertEqual(CadenceDrillPreset.majorIIVI.description, "Practice major key cadences")
        XCTAssertEqual(CadenceDrillPreset.minorIIVI.description, "Practice minor key cadences")
        XCTAssertEqual(CadenceDrillPreset.mixedCadences.description, "Both major and minor")
    }
    
    func test_cadenceDrillPreset_icons() {
        XCTAssertEqual(CadenceDrillPreset.majorIIVI.icon, "music.note")
        XCTAssertEqual(CadenceDrillPreset.minorIIVI.icon, "music.note.list")
        XCTAssertEqual(CadenceDrillPreset.mixedCadences.icon, "shuffle")
    }
    
    // MARK: - ScaleDrillPreset Tests
    
    func test_scaleDrillPreset_allCases() {
        let presets = ScaleDrillPreset.allCases
        XCTAssertEqual(presets.count, 3)
        XCTAssertTrue(presets.contains(.majorModes))
        XCTAssertTrue(presets.contains(.minorScales))
        XCTAssertTrue(presets.contains(.allScales))
    }
    
    func test_scaleDrillPreset_names() {
        XCTAssertEqual(ScaleDrillPreset.majorModes.name, "Major Modes")
        XCTAssertEqual(ScaleDrillPreset.minorScales.name, "Minor Scales")
        XCTAssertEqual(ScaleDrillPreset.allScales.name, "All Scales")
    }
    
    func test_scaleDrillPreset_descriptions() {
        XCTAssertEqual(ScaleDrillPreset.majorModes.description, "Ionian, Dorian, Mixolydian")
        XCTAssertEqual(ScaleDrillPreset.minorScales.description, "Natural, harmonic, melodic")
        XCTAssertEqual(ScaleDrillPreset.allScales.description, "Complete scale workout")
    }
    
    func test_scaleDrillPreset_icons() {
        XCTAssertEqual(ScaleDrillPreset.majorModes.icon, "music.quarternote.3")
        XCTAssertEqual(ScaleDrillPreset.minorScales.icon, "music.mic")
        XCTAssertEqual(ScaleDrillPreset.allScales.icon, "flame")
    }
    
    // MARK: - IntervalDrillPreset Tests
    
    func test_intervalDrillPreset_allCases() {
        let presets = IntervalDrillPreset.allCases
        XCTAssertEqual(presets.count, 3)
        XCTAssertTrue(presets.contains(.basicIntervals))
        XCTAssertTrue(presets.contains(.allIntervals))
        XCTAssertTrue(presets.contains(.earTraining))
    }
    
    func test_intervalDrillPreset_names() {
        XCTAssertEqual(IntervalDrillPreset.basicIntervals.name, "Basic Intervals")
        XCTAssertEqual(IntervalDrillPreset.allIntervals.name, "All Intervals")
        XCTAssertEqual(IntervalDrillPreset.earTraining.name, "Ear Training")
    }
    
    func test_intervalDrillPreset_descriptions() {
        XCTAssertEqual(IntervalDrillPreset.basicIntervals.description, "2nds, 3rds, 5ths, octaves")
        XCTAssertEqual(IntervalDrillPreset.allIntervals.description, "All intervals including tritones")
        XCTAssertEqual(IntervalDrillPreset.earTraining.description, "Identify intervals by ear")
    }
    
    func test_intervalDrillPreset_icons() {
        XCTAssertEqual(IntervalDrillPreset.basicIntervals.icon, "arrow.up.arrow.down")
        XCTAssertEqual(IntervalDrillPreset.allIntervals.icon, "arrow.up.and.down.and.arrow.left.and.right")
        XCTAssertEqual(IntervalDrillPreset.earTraining.icon, "ear")
    }
    
    // MARK: - DrillPreset Protocol Conformance Tests
    
    func test_drillPreset_protocolConformance() {
        let chordPreset: any DrillPreset = ChordDrillPreset.basicTriads
        XCTAssertEqual(chordPreset.name, "Basic Triads")
        XCTAssertFalse(chordPreset.description.isEmpty)
        XCTAssertFalse(chordPreset.icon.isEmpty)
        
        let cadencePreset: any DrillPreset = CadenceDrillPreset.majorIIVI
        XCTAssertEqual(cadencePreset.name, "Major ii-V-I")
        
        let scalePreset: any DrillPreset = ScaleDrillPreset.majorModes
        XCTAssertEqual(scalePreset.name, "Major Modes")
        
        let intervalPreset: any DrillPreset = IntervalDrillPreset.basicIntervals
        XCTAssertEqual(intervalPreset.name, "Basic Intervals")
    }
}
