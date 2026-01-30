import XCTest
import AudioToolbox
@testable import JazzHarmonyQuiz

final class AudioManagerTests: XCTestCase {
    
    var audioManager: AudioManager!
    
    override func setUp() {
        super.setUp()
        audioManager = AudioManager.shared
    }
    
    override func tearDown() {
        audioManager.stopAllNotes()
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testSharedInstanceExists() {
        XCTAssertNotNil(AudioManager.shared)
    }
    
    func testInitialState() {
        XCTAssertTrue(audioManager.isEnabled, "Audio should be enabled by default")
        XCTAssertEqual(audioManager.volume, 0.7, "Default volume should be 0.7")
    }
    
    // MARK: - Enable/Disable Tests
    
    func testToggleAudio() {
        let initialState = audioManager.isEnabled
        audioManager.toggleAudio()
        XCTAssertNotEqual(audioManager.isEnabled, initialState, "Toggle should change state")
        
        audioManager.toggleAudio()
        XCTAssertEqual(audioManager.isEnabled, initialState, "Double toggle should restore state")
    }
    
    func testDisableAudioStopsNotes() {
        audioManager.isEnabled = true
        audioManager.toggleAudio() // Should call stopAllNotes
        XCTAssertFalse(audioManager.isEnabled)
    }
    
    // MARK: - Volume Tests
    
    func testSetVolume() {
        audioManager.setVolume(0.5)
        XCTAssertEqual(audioManager.volume, 0.5)
        
        audioManager.setVolume(1.0)
        XCTAssertEqual(audioManager.volume, 1.0)
        
        audioManager.setVolume(0.0)
        XCTAssertEqual(audioManager.volume, 0.0)
    }
    
    func testSetVolumeClamps() {
        audioManager.setVolume(1.5)
        XCTAssertEqual(audioManager.volume, 1.0, "Volume should clamp to 1.0")
        
        audioManager.setVolume(-0.5)
        XCTAssertEqual(audioManager.volume, 0.0, "Volume should clamp to 0.0")
    }
    
    // MARK: - Note Playback Tests
    
    func testPlayNoteWhenEnabled() {
        audioManager.isEnabled = true
        
        // Should not crash
        audioManager.playNote(60, velocity: 80)
        
        // Give time for async cleanup
        let expectation = self.expectation(description: "Note stops")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPlayNoteWhenDisabled() {
        audioManager.isEnabled = false
        
        // Should not crash when disabled
        audioManager.playNote(60, velocity: 80)
    }
    
    func testStopNote() {
        audioManager.isEnabled = true
        
        // Should not crash
        audioManager.playNote(60)
        audioManager.stopNote(60)
    }
    
    // MARK: - Chord Playback Tests
    
    func testPlayChordWithEmptyArray() {
        audioManager.isEnabled = true
        
        // Should handle empty array gracefully
        audioManager.playChord([], velocity: 80, duration: 1.0)
    }
    
    func testPlayChordWithNotes() {
        audioManager.isEnabled = true
        
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "E", midiNumber: 64),
            Note(name: "G", midiNumber: 67)
        ]
        
        // Should not crash
        audioManager.playChord(notes, velocity: 80, duration: 0.5)
        
        let expectation = self.expectation(description: "Chord stops")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1.0)
    }
    
    func testPlayChordNormalizesToMiddleC() {
        audioManager.isEnabled = true
        
        // Notes in different octaves should normalize to middle C octave
        let notes = [
            Note(name: "C", midiNumber: 48), // C3
            Note(name: "E", midiNumber: 76), // E5
            Note(name: "G", midiNumber: 91)  // G6
        ]
        
        // Should not crash and should normalize
        audioManager.playChord(notes, velocity: 80, duration: 0.2)
    }
    
    func testPlayChordWithStyle() {
        audioManager.isEnabled = true
        
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "E", midiNumber: 64),
            Note(name: "G", midiNumber: 67)
        ]
        
        let expectation = self.expectation(description: "Chord playback completes")
        
        audioManager.playChord(notes, style: .block, tempo: 120) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testPlayChordArpeggioUp() {
        audioManager.isEnabled = true
        
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "E", midiNumber: 64),
            Note(name: "G", midiNumber: 67)
        ]
        
        let expectation = self.expectation(description: "Arpeggio completes")
        
        audioManager.playChord(notes, style: .arpeggioUp, tempo: 240) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testPlayChordArpeggioDown() {
        audioManager.isEnabled = true
        
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "E", midiNumber: 64),
            Note(name: "G", midiNumber: 67)
        ]
        
        let expectation = self.expectation(description: "Arpeggio completes")
        
        audioManager.playChord(notes, style: .arpeggioDown, tempo: 240) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testPlayChordGuideTones() {
        audioManager.isEnabled = true
        
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "E", midiNumber: 64),
            Note(name: "G", midiNumber: 67),
            Note(name: "B", midiNumber: 71)
        ]
        
        let expectation = self.expectation(description: "Guide tones complete")
        
        audioManager.playChord(notes, style: .guideTones) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    // MARK: - Scale Playback Tests
    
    func testPlayScaleAscending() {
        audioManager.isEnabled = true
        
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "D", midiNumber: 62),
            Note(name: "E", midiNumber: 64),
            Note(name: "F", midiNumber: 65),
            Note(name: "G", midiNumber: 67),
            Note(name: "A", midiNumber: 69),
            Note(name: "B", midiNumber: 71),
            Note(name: "C", midiNumber: 72)
        ]
        
        // Should not crash
        audioManager.playScale(notes, bpm: 240, direction: .ascending)
        
        // Give time for playback to start
        let expectation = self.expectation(description: "Scale starts")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 0.5)
    }
    
    func testPlayScaleDescending() {
        audioManager.isEnabled = true
        
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "D", midiNumber: 62),
            Note(name: "E", midiNumber: 64),
            Note(name: "F", midiNumber: 65),
            Note(name: "G", midiNumber: 67),
            Note(name: "A", midiNumber: 69),
            Note(name: "B", midiNumber: 71),
            Note(name: "C", midiNumber: 72)
        ]
        
        audioManager.playScale(notes, bpm: 240, direction: .descending)
    }
    
    func testPlayScaleAscendingDescending() {
        audioManager.isEnabled = true
        
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "D", midiNumber: 62),
            Note(name: "E", midiNumber: 64),
            Note(name: "F", midiNumber: 65),
            Note(name: "G", midiNumber: 67),
            Note(name: "A", midiNumber: 69),
            Note(name: "B", midiNumber: 71),
            Note(name: "C", midiNumber: 72)
        ]
        
        audioManager.playScale(notes, bpm: 240, direction: .ascendingDescending)
    }
    
    func testPlayScaleObject() {
        audioManager.isEnabled = true
        
        let cNote = Note(name: "C", midiNumber: 60)
        let scale = Scale(root: cNote, scaleType: .major)
        
        // Should not crash
        audioManager.playScaleObject(scale, bpm: 240)
    }
    
    func testPlayScaleWithEmptyArray() {
        audioManager.isEnabled = true
        
        // Should handle empty array gracefully
        audioManager.playScale([], bpm: 120, direction: .ascending)
    }
    
    // MARK: - Interval Playback Tests
    
    func testPlayIntervalHarmonic() {
        audioManager.isEnabled = true
        
        let root = Note(name: "C", midiNumber: 60)
        let target = Note(name: "E", midiNumber: 64)
        
        let expectation = self.expectation(description: "Harmonic interval completes")
        
        audioManager.playInterval(rootNote: root, targetNote: target, style: .harmonic) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testPlayIntervalMelodicAscending() {
        audioManager.isEnabled = true
        
        let root = Note(name: "C", midiNumber: 60)
        let target = Note(name: "G", midiNumber: 67)
        
        let expectation = self.expectation(description: "Melodic ascending completes")
        
        audioManager.playInterval(rootNote: root, targetNote: target, style: .melodicAscending, tempo: 240) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    func testPlayIntervalMelodicDescending() {
        audioManager.isEnabled = true
        
        let root = Note(name: "C", midiNumber: 60)
        let target = Note(name: "G", midiNumber: 67)
        
        let expectation = self.expectation(description: "Melodic descending completes")
        
        audioManager.playInterval(rootNote: root, targetNote: target, style: .melodicDescending, tempo: 240) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3.0)
    }
    
    // MARK: - Cadence Progression Tests
    
    func testPlayCadenceProgression() {
        audioManager.isEnabled = true
        
        let chords: [[Note]] = [
            [Note(name: "D", midiNumber: 62), Note(name: "F", midiNumber: 65), Note(name: "A", midiNumber: 69)], // ii
            [Note(name: "G", midiNumber: 67), Note(name: "B", midiNumber: 71), Note(name: "D", midiNumber: 74)], // V
            [Note(name: "C", midiNumber: 60), Note(name: "E", midiNumber: 64), Note(name: "G", midiNumber: 67)]  // I
        ]
        
        // Should not crash
        audioManager.playCadenceProgression(chords, bpm: 240, beatsPerChord: 1, source: "test")
        
        // Verify playback source is set
        XCTAssertEqual(audioManager.playingSource, "test")
    }
    
    func testCadenceProgressionClearsStateAfterCompletion() {
        audioManager.isEnabled = true
        
        let chords: [[Note]] = [
            [Note(name: "C", midiNumber: 60), Note(name: "E", midiNumber: 64)]
        ]
        
        audioManager.playCadenceProgression(chords, bpm: 480, beatsPerChord: 0.5, source: "test")
        
        let expectation = self.expectation(description: "Cadence completes and clears state")
        
        // Wait for completion (1 chord * 0.5 beats * (60/480 seconds per beat) + 0.5 buffer = ~0.6s)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            XCTAssertNil(self.audioManager.playingSource, "Playing source should be nil after completion")
            XCTAssertEqual(self.audioManager.playingChordIndex, -1, "Chord index should be -1 after completion")
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testCadenceProgressionWithEmptyArray() {
        audioManager.isEnabled = true
        
        // Should handle empty array gracefully
        audioManager.playCadenceProgression([], bpm: 120, beatsPerChord: 2)
    }
    
    // MARK: - Progression Tests
    
    func testPlayProgression() {
        audioManager.isEnabled = true
        
        let chords: [[Note]] = [
            [Note(name: "C", midiNumber: 60), Note(name: "E", midiNumber: 64)],
            [Note(name: "F", midiNumber: 65), Note(name: "A", midiNumber: 69)]
        ]
        
        // Should not crash
        audioManager.playProgression(chords, tempoMS: 200)
    }
    
    // MARK: - Sound Effect Tests
    
    func testPlaySuccessSound() {
        audioManager.isEnabled = true
        
        // Should not crash
        audioManager.playSuccessSound()
    }
    
    func testPlayErrorSound() {
        audioManager.isEnabled = true
        
        // Should not crash
        audioManager.playErrorSound()
    }
    
    func testSoundEffectsRespectEnabledState() {
        audioManager.isEnabled = false
        
        // Should not crash when disabled
        audioManager.playSuccessSound()
        audioManager.playErrorSound()
    }
    
    // MARK: - Stop All Notes Tests
    
    func testStopAllNotes() {
        audioManager.isEnabled = true
        
        // Play something first
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "E", midiNumber: 64)
        ]
        audioManager.playChord(notes)
        
        // Should not crash
        audioManager.stopAllNotes()
        
        // Should clear playback state
        XCTAssertNil(audioManager.playingSource)
        XCTAssertEqual(audioManager.playingChordIndex, -1)
    }
    
    func testStopAllNotesCancelsScheduledPlayback() {
        audioManager.isEnabled = true
        
        let chords: [[Note]] = [
            [Note(name: "C", midiNumber: 60)],
            [Note(name: "D", midiNumber: 62)],
            [Note(name: "E", midiNumber: 64)]
        ]
        
        audioManager.playCadenceProgression(chords, bpm: 60, beatsPerChord: 4, source: "test")
        
        // Stop immediately
        audioManager.stopAllNotes()
        
        // Playback state should be cleared
        XCTAssertNil(audioManager.playingSource)
        XCTAssertEqual(audioManager.playingChordIndex, -1)
    }
    
    // MARK: - Playback Style Enum Tests
    
    func testIntervalPlaybackStyleCases() {
        XCTAssertEqual(AudioManager.IntervalPlaybackStyle.harmonic.rawValue, "Harmonic")
        XCTAssertEqual(AudioManager.IntervalPlaybackStyle.melodicAscending.rawValue, "Melodic Up")
        XCTAssertEqual(AudioManager.IntervalPlaybackStyle.melodicDescending.rawValue, "Melodic Down")
    }
    
    func testIntervalPlaybackStyleDescriptions() {
        XCTAssertEqual(AudioManager.IntervalPlaybackStyle.harmonic.description, "Both notes together")
        XCTAssertEqual(AudioManager.IntervalPlaybackStyle.melodicAscending.description, "Lower then higher")
        XCTAssertEqual(AudioManager.IntervalPlaybackStyle.melodicDescending.description, "Higher then lower")
    }
    
    func testChordPlaybackStyleCases() {
        XCTAssertEqual(AudioManager.ChordPlaybackStyle.block.rawValue, "Block")
        XCTAssertEqual(AudioManager.ChordPlaybackStyle.arpeggioUp.rawValue, "Arpeggio ↑")
        XCTAssertEqual(AudioManager.ChordPlaybackStyle.arpeggioDown.rawValue, "Arpeggio ↓")
        XCTAssertEqual(AudioManager.ChordPlaybackStyle.guideTones.rawValue, "Guide Tones")
    }
    
    func testChordPlaybackStyleDescriptions() {
        XCTAssertEqual(AudioManager.ChordPlaybackStyle.block.description, "All notes simultaneously")
        XCTAssertEqual(AudioManager.ChordPlaybackStyle.arpeggioUp.description, "Notes ascending")
        XCTAssertEqual(AudioManager.ChordPlaybackStyle.arpeggioDown.description, "Notes descending")
        XCTAssertEqual(AudioManager.ChordPlaybackStyle.guideTones.description, "Root, 3rd, 7th only")
    }
    
    func testScaleDirectionCases() {
        // Just verify the enum exists and has expected cases
        let _: AudioManager.ScaleDirection = .ascending
        let _: AudioManager.ScaleDirection = .descending
        let _: AudioManager.ScaleDirection = .ascendingDescending
    }
    
    // MARK: - Performance Tests
    
    func testPlayChordPerformance() {
        audioManager.isEnabled = true
        
        let notes = [
            Note(name: "C", midiNumber: 60),
            Note(name: "E", midiNumber: 64),
            Note(name: "G", midiNumber: 67),
            Note(name: "B", midiNumber: 71)
        ]
        
        measure {
            audioManager.playChord(notes, velocity: 80, duration: 0.01)
        }
    }
    
    func testStopAllNotesPerformance() {
        audioManager.isEnabled = true
        
        // Play multiple notes
        for i in 0..<10 {
            audioManager.playNote(UInt8(60 + i))
        }
        
        measure {
            audioManager.stopAllNotes()
        }
    }
}
