import Foundation
import AVFoundation

/// Manages audio playback for chord sounds using AVFoundation
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var audioEngine: AVAudioEngine?
    private var sampler: AVAudioUnitSampler?
    @Published var isEnabled: Bool = true
    @Published var volume: Float = 0.7
    
    private init() {
        setupAudioEngine()
        loadSoundFont()
    }
    
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        
        guard let engine = audioEngine, let sampler = sampler else { return }
        
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
        } catch {
            print("Failed to start audio engine: \(error)")
        }
    }
    
    private func loadSoundFont() {
        guard let sampler = sampler else { return }
        
        // Try to load sounds in order of preference
        do {
            // 1. Try bundled soundfont first (best quality, consistent across devices)
            if let soundFontURL = Bundle.main.url(forResource: "Piano", withExtension: "sf2") {
                try sampler.loadSoundBankInstrument(
                    at: soundFontURL,
                    program: 0,
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: UInt8(kAUSampler_DefaultBankLSB)
                )
                print("Loaded bundled Piano.sf2")
                return
            }
            
            // 2. Try macOS simulator DLS file (nice piano, but simulator only)
            #if targetEnvironment(simulator)
            let dlsURL = URL(fileURLWithPath: "/System/Library/Components/CoreAudio.component/Contents/Resources/gs_instruments.dls")
            if FileManager.default.fileExists(atPath: dlsURL.path) {
                try sampler.loadSoundBankInstrument(
                    at: dlsURL,
                    program: 0,  // Acoustic Grand Piano
                    bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                    bankLSB: UInt8(kAUSampler_DefaultBankLSB)
                )
                print("Loaded system DLS piano (simulator)")
                return
            }
            #endif
            
            // 3. On device without bundled soundfont, configure the sampler with default sounds
            // The default AVAudioUnitSampler produces a basic sine-wave tone
            // For better sound, add a Piano.sf2 file to the bundle
            print("Using default sampler (consider adding Piano.sf2 for better sound)")
            
        } catch {
            print("Sound loading note: \(error.localizedDescription)")
            // Sampler will still work with default synthesis
        }
    }
    
    /// Play a single note
    func playNote(_ midiNote: UInt8, velocity: UInt8 = 80) {
        guard isEnabled, let sampler = sampler else { return }
        sampler.startNote(midiNote, withVelocity: velocity, onChannel: 0)
        
        // Stop note after a short duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            sampler.stopNote(midiNote, onChannel: 0)
        }
    }
    
    /// Stop a note
    func stopNote(_ midiNote: UInt8) {
        guard let sampler = sampler else { return }
        sampler.stopNote(midiNote, onChannel: 0)
    }
    
    /// Play a chord (multiple notes simultaneously)
    func playChord(_ notes: [Note], velocity: UInt8 = 80, duration: TimeInterval = 1.0) {
        guard isEnabled, let sampler = sampler else { return }
        
        // Normalize notes to middle C octave (MIDI 60-71)
        let normalizedMidiNotes = notes.map { note -> UInt8 in
            let pitchClass = note.midiNumber % 12
            return UInt8(60 + pitchClass)  // Octave 4 (middle C)
        }
        
        // Start all notes
        for midiNote in normalizedMidiNotes {
            sampler.startNote(midiNote, withVelocity: velocity, onChannel: 0)
        }
        
        // Stop all notes after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            for midiNote in normalizedMidiNotes {
                sampler.stopNote(midiNote, onChannel: 0)
            }
        }
    }
    
    /// Play a cadence progression with proper rhythm
    /// - Parameters:
    ///   - chords: Array of chord note arrays (e.g., [[ii chord notes], [V chord notes], [I chord notes]])
    ///   - bpm: Tempo in beats per minute (default 90 BPM for a relaxed jazz feel)
    ///   - beatsPerChord: How many beats each chord rings (default 2 beats)
    func playCadenceProgression(_ chords: [[Note]], bpm: Double = 90, beatsPerChord: Double = 2) {
        guard isEnabled, let sampler = sampler else { return }
        
        let secondsPerBeat = 60.0 / bpm
        let chordDuration = secondsPerBeat * beatsPerChord
        
        for (index, chord) in chords.enumerated() {
            let delay = Double(index) * chordDuration
            
            // Normalize notes to middle C octave (MIDI 60-71)
            let normalizedMidiNotes = chord.map { note -> UInt8 in
                let pitchClass = note.midiNumber % 12
                return UInt8(60 + pitchClass)  // Octave 4 (middle C)
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                // Start chord
                for midiNote in normalizedMidiNotes {
                    sampler.startNote(midiNote, withVelocity: 75, onChannel: 0)
                }
            }
            
            // Stop chord slightly before next one (legato feel with small gap)
            let stopDelay = delay + (chordDuration * 0.9)
            DispatchQueue.main.asyncAfter(deadline: .now() + stopDelay) {
                for midiNote in normalizedMidiNotes {
                    sampler.stopNote(midiNote, onChannel: 0)
                }
            }
        }
    }
    
    /// Play a chord progression with timing between chords
    func playProgression(_ chords: [[Note]], tempoMS: Int = 800) {
        guard isEnabled else { return }
        
        for (index, chord) in chords.enumerated() {
            let delay = Double(index) * Double(tempoMS) / 1000.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.playChord(chord, duration: Double(tempoMS) / 1000.0 * 0.9)
            }
        }
    }
    
    /// Play a success sound (ascending arpeggio)
    func playSuccessSound() {
        guard isEnabled else { return }
        
        let notes: [UInt8] = [60, 64, 67, 72]  // C major arpeggio
        for (index, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.1) {
                self.playNote(note, velocity: 70)
            }
        }
    }
    
    /// Play an error sound (minor second)
    func playErrorSound() {
        guard isEnabled else { return }
        
        playNote(60, velocity: 60)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.playNote(61, velocity: 60)
        }
    }
    
    /// Stop all notes
    func stopAllNotes() {
        guard let sampler = sampler else { return }
        for midiNote: UInt8 in 0...127 {
            sampler.stopNote(midiNote, onChannel: 0)
        }
    }
    
    /// Set the volume (0.0 to 1.0)
    func setVolume(_ volume: Float) {
        self.volume = max(0, min(1, volume))
        audioEngine?.mainMixerNode.outputVolume = self.volume
    }
    
    /// Toggle audio on/off
    func toggleAudio() {
        isEnabled.toggle()
        if !isEnabled {
            stopAllNotes()
        }
    }
    
    // MARK: - Scale Playback
    
    /// Direction for scale playback
    enum ScaleDirection {
        case ascending
        case descending
        case ascendingDescending
    }
    
    /// Play a scale with proper timing
    /// - Parameters:
    ///   - notes: The scale notes (should include root through octave)
    ///   - bpm: Tempo in beats per minute (default 160 BPM for lively playback)
    ///   - direction: Whether to play ascending, descending, or both
    func playScale(_ notes: [Note], bpm: Double = 160, direction: ScaleDirection = .ascendingDescending) {
        guard isEnabled, let sampler = sampler, !notes.isEmpty else { return }
        
        let secondsPerBeat = 60.0 / bpm
        let noteDuration = secondsPerBeat  // Quarter notes
        
        // Prepare the sequence of notes based on direction
        var sequence: [Note] = []
        switch direction {
        case .ascending:
            sequence = notes
        case .descending:
            sequence = notes.reversed()
        case .ascendingDescending:
            // Go up, then back down (don't repeat the top note)
            sequence = notes + Array(notes.dropLast().reversed())
        }
        
        // Play each note in sequence
        for (index, note) in sequence.enumerated() {
            let delay = Double(index) * noteDuration
            let midiNote = UInt8(note.midiNumber)
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                sampler.startNote(midiNote, withVelocity: 75, onChannel: 0)
            }
            
            // Stop note slightly before next one for articulation
            let stopDelay = delay + (noteDuration * 0.85)
            DispatchQueue.main.asyncAfter(deadline: .now() + stopDelay) {
                sampler.stopNote(midiNote, onChannel: 0)
            }
        }
    }
    
    /// Play a scale from a Scale object (ascending then descending)
    /// Adjusts MIDI numbers so the scale plays in proper ascending order from middle C
    func playScaleObject(_ scale: Scale, bpm: Double = 160) {
        guard isEnabled, let sampler = sampler else { return }
        
        let ascendingNotes = scale.notesAscending()
        let rootMidi = 60  // Start from middle C
        
        // Build adjusted notes with correct MIDI numbers
        var adjustedNotes: [Note] = []
        for (index, note) in ascendingNotes.enumerated() {
            let interval = scale.scaleType.degrees[index].semitonesFromRoot
            let adjustedMidi = rootMidi + interval
            let adjustedNote = Note(
                name: note.name,
                midiNumber: adjustedMidi,
                isSharp: note.isSharp
            )
            adjustedNotes.append(adjustedNote)
        }
        
        playScale(adjustedNotes, bpm: bpm, direction: .ascendingDescending)
    }
    
    deinit {
        audioEngine?.stop()
    }
}
