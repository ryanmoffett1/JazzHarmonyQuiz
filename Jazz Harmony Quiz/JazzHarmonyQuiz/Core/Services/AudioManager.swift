import Foundation
import AVFoundation

/// Manages audio playback for chord sounds using AVFoundation
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var audioEngine: AVAudioEngine?
    private var sampler: AVAudioUnitSampler?
    @Published var isEnabled: Bool = true
    @Published var volume: Float = 0.7
    
    /// Track currently playing MIDI notes so we can stop them before new playback
    private var activeNotes: Set<UInt8> = []
    private let notesLock = NSLock()
    
    /// Generation counter for canceling scheduled progression playback
    /// When a new playback starts, we increment this; scheduled plays check it before playing
    private var playbackGeneration: Int = 0
    private let generationLock = NSLock()
    
    /// Precise timer for audio playback scheduling
    private var playbackTimer: Timer?
    private var scheduledNotes: [(time: Double, note: UInt8, isStart: Bool)] = []
    private var playbackStartTime: Double = 0
    
    // MARK: - Playback State Tracking (for UI highlighting)
    
    /// Which source is currently playing ("correct", "user", or nil if none)
    @Published var playingSource: String? = nil
    
    /// Which chord index is currently playing (-1 if none)
    @Published var playingChordIndex: Int = -1
    
    private init() {
        setupAudioEngine()
        loadSoundFont()
    }
    
    private func setupAudioEngine() {
        // Configure audio session for playback
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        
        audioEngine = AVAudioEngine()
        sampler = AVAudioUnitSampler()
        
        guard let engine = audioEngine, let sampler = sampler else { return }
        
        engine.attach(sampler)
        engine.connect(sampler, to: engine.mainMixerNode, format: nil)
        
        do {
            try engine.start()
            print("Audio engine started successfully")
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
    

    /// Ensure the audio engine is running (restart if needed)
    private func ensureAudioEngineRunning() {
        guard let engine = audioEngine else { return }
        
        if !engine.isRunning {
            do {
                try engine.start()
                print("Audio engine restarted")
            } catch {
                print("Failed to restart audio engine: \(error)")
            }
        }
    }

    /// Stop all currently playing notes immediately and cancel scheduled playback
    /// Call this before starting any new sound to prevent overlapping
    func stopAllNotes() {
        guard let sampler = sampler else { return }
        
        // Increment generation to cancel any scheduled chord plays
        generationLock.lock()
        playbackGeneration += 1
        generationLock.unlock()
        
        // Clear playback state
        DispatchQueue.main.async {
            self.playingSource = nil
            self.playingChordIndex = -1
        }
        
        notesLock.lock()
        let notesToStop = activeNotes
        activeNotes.removeAll()
        notesLock.unlock()
        
        // Send note-off for all tracked notes
        for midiNote in notesToStop {
            sampler.stopNote(midiNote, onChannel: 0)
        }
        
        // Also send note-off for all possible notes in case any were missed
        // This ensures clean cutoff even if tracking got out of sync
        for midiNote: UInt8 in 0...127 {
            sampler.stopNote(midiNote, onChannel: 0)
        }
    }
    
    /// Get the current playback generation (for checking if playback was canceled)
    private func currentGeneration() -> Int {
        generationLock.lock()
        let gen = playbackGeneration
        generationLock.unlock()
        return gen
    }
    
    /// Track a note as actively playing
    private func trackNoteOn(_ midiNote: UInt8) {
        notesLock.lock()
        activeNotes.insert(midiNote)
        notesLock.unlock()
    }
    
    /// Track a note as stopped
    private func trackNoteOff(_ midiNote: UInt8) {
        notesLock.lock()
        activeNotes.remove(midiNote)
        notesLock.unlock()
    }

    /// Play a single note
    func playNote(_ midiNote: UInt8, velocity: UInt8 = 80) {
        guard isEnabled, let sampler = sampler else { return }
        
        stopAllNotes()  // Stop any previous sounds
        
        trackNoteOn(midiNote)
        sampler.startNote(midiNote, withVelocity: velocity, onChannel: 0)
        
        // Stop note after a short duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.trackNoteOff(midiNote)
            sampler.stopNote(midiNote, onChannel: 0)
        }
    }
    
    /// Stop a note
    func stopNote(_ midiNote: UInt8) {
        guard let sampler = sampler else { return }
        trackNoteOff(midiNote)
        sampler.stopNote(midiNote, onChannel: 0)
    }
    
    /// Play a chord (multiple notes simultaneously)
    func playChord(_ notes: [Note], velocity: UInt8 = 80, duration: TimeInterval = 1.0) {
        guard isEnabled, let sampler = sampler else {
            print("playChord: isEnabled=\(isEnabled), sampler=\(self.sampler != nil ? "exists" : "nil")")
            return
        }

        // Stop any currently playing sounds first
        stopAllNotes()
        
        // Ensure audio engine is running
        ensureAudioEngineRunning()

        // Normalize notes to middle C octave (MIDI 60-71)
        let normalizedMidiNotes = notes.map { note -> UInt8 in
            let pitchClass = note.midiNumber % 12
            return UInt8(60 + pitchClass)  // Octave 4 (middle C)
        }

        // Start all notes
        for midiNote in normalizedMidiNotes {
            trackNoteOn(midiNote)
            sampler.startNote(midiNote, withVelocity: velocity, onChannel: 0)
        }

        // Stop all notes after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            for midiNote in normalizedMidiNotes {
                self?.trackNoteOff(midiNote)
                sampler.stopNote(midiNote, onChannel: 0)
            }
        }
    }

    /// Play a chord with a specific playback style (block, arpeggio, guide tones)
    /// - Parameters:
    ///   - notes: Array of notes to play
    ///   - style: Playback style (block, arpeggio up/down, guide tones)
    ///   - tempo: Tempo in BPM for arpeggio styles (default 120)
    ///   - completion: Optional closure called when playback completes
    func playChord(
        _ notes: [Note],
        style: ChordPlaybackStyle = .block,
        tempo: Double = 120,
        completion: (() -> Void)? = nil
    ) {
        guard isEnabled, let sampler = sampler else {
            completion?()
            return
        }

        // Stop any currently playing sounds first
        stopAllNotes()
        
        ensureAudioEngineRunning()

        switch style {
        case .block:
            // Use existing playChord() method for block style (which also stops notes)
            playChord(notes, velocity: 80, duration: 1.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                completion?()
            }

        case .arpeggioUp:
            // Play notes ascending with tempo-based delay
            let delayBetweenNotes = 60.0 / tempo  // BPM to seconds
            let sortedNotes = notes.sorted { $0.midiNumber < $1.midiNumber }

            for (index, note) in sortedNotes.enumerated() {
                let playDelay = Double(index) * delayBetweenNotes
                DispatchQueue.main.asyncAfter(deadline: .now() + playDelay) { [weak self] in
                    let pitchClass = note.midiNumber % 12
                    let normalizedMidi = UInt8(60 + pitchClass)
                    self?.trackNoteOn(normalizedMidi)
                    sampler.startNote(normalizedMidi, withVelocity: 80, onChannel: 0)

                    DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenNotes * 0.8) {
                        self?.trackNoteOff(normalizedMidi)
                        sampler.stopNote(normalizedMidi, onChannel: 0)
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(sortedNotes.count) * delayBetweenNotes) {
                completion?()
            }

        case .arpeggioDown:
            // Play notes descending
            let delayBetweenNotes = 60.0 / tempo
            let sortedNotes = notes.sorted { $0.midiNumber > $1.midiNumber }

            for (index, note) in sortedNotes.enumerated() {
                let playDelay = Double(index) * delayBetweenNotes
                DispatchQueue.main.asyncAfter(deadline: .now() + playDelay) { [weak self] in
                    let pitchClass = note.midiNumber % 12
                    let normalizedMidi = UInt8(60 + pitchClass)
                    self?.trackNoteOn(normalizedMidi)
                    sampler.startNote(normalizedMidi, withVelocity: 80, onChannel: 0)

                    DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenNotes * 0.8) {
                        self?.trackNoteOff(normalizedMidi)
                        sampler.stopNote(normalizedMidi, onChannel: 0)
                    }
                }
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + Double(sortedNotes.count) * delayBetweenNotes) {
                completion?()
            }

        case .guideTones:
            // Extract and play root, 3rd, 7th only
            let guideTones = extractGuideTones(from: notes)
            playChord(guideTones, velocity: 80, duration: 1.5)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                completion?()
            }
        }
    }

    /// Extract guide tones (root, 3rd, 7th) from a chord
    private func extractGuideTones(from notes: [Note]) -> [Note] {
        guard notes.count >= 3 else { return notes }
        let sorted = notes.sorted { $0.midiNumber < $1.midiNumber }

        // Return root (first), third (2nd), and seventh (last or 2nd-to-last)
        return [
            sorted[0],                              // Root
            sorted[min(1, sorted.count - 1)],      // 3rd
            sorted[sorted.count - 1]                // 7th
        ]
    }
    
    /// Play a cadence progression with proper rhythm
    /// - Parameters:
    ///   - chords: Array of chord note arrays (e.g., [[ii chord notes], [V chord notes], [I chord notes]])
    ///   - bpm: Tempo in beats per minute (default 90 BPM for a relaxed jazz feel)
    ///   - beatsPerChord: How many beats each chord rings (default 2 beats)
    ///   - source: Identifier for UI highlighting ("correct", "user", or nil)
    func playCadenceProgression(_ chords: [[Note]], bpm: Double = 90, beatsPerChord: Double = 2, source: String? = nil) {
        guard isEnabled, let sampler = sampler, !chords.isEmpty else { return }
        
        // Stop any currently playing sounds and cancel existing timer
        stopAllNotes()
        playbackTimer?.invalidate()
        playbackTimer = nil
        scheduledNotes.removeAll()
        
        // Set the playback source for UI highlighting
        DispatchQueue.main.async {
            self.playingSource = source
        }
        
        // Capture the current generation - if it changes, we abort
        let startGeneration = currentGeneration()
        
        let secondsPerBeat = 60.0 / bpm
        let chordDuration = secondsPerBeat * beatsPerChord
        
        // Build schedule of chord events
        var events: [(time: Double, chordIndex: Int, notes: [UInt8], isStart: Bool)] = []
        
        for (index, chord) in chords.enumerated() {
            let chordStartTime = Double(index) * chordDuration
            let chordStopTime = chordStartTime + (chordDuration * 0.9) // 90% duration for slight gap
            
            // Normalize notes to middle C octave (MIDI 60-71)
            let normalizedMidiNotes = chord.map { note -> UInt8 in
                let pitchClass = note.midiNumber % 12
                return UInt8(60 + pitchClass)
            }
            
            events.append((time: chordStartTime, chordIndex: index, notes: normalizedMidiNotes, isStart: true))
            events.append((time: chordStopTime, chordIndex: index, notes: normalizedMidiNotes, isStart: false))
        }
        
        var sortedEvents = events.sorted { $0.time < $1.time }
        playbackStartTime = CACurrentMediaTime()
        let totalDuration = Double(chords.count) * chordDuration
        
        // Use a high-frequency timer for precise scheduling
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            // Check if playback was canceled
            guard self.currentGeneration() == startGeneration else {
                timer.invalidate()
                self.playbackTimer = nil
                return
            }
            
            let currentTime = CACurrentMediaTime() - self.playbackStartTime
            
            // Process all events that should have fired by now
            while !sortedEvents.isEmpty && sortedEvents[0].time <= currentTime {
                let event = sortedEvents.removeFirst()
                
                if event.isStart {
                    // Update which chord is playing for UI highlighting
                    self.playingChordIndex = event.chordIndex
                    
                    // Start chord
                    for midiNote in event.notes {
                        self.trackNoteOn(midiNote)
                        sampler.startNote(midiNote, withVelocity: 75, onChannel: 0)
                    }
                } else {
                    // Stop chord
                    for midiNote in event.notes {
                        self.trackNoteOff(midiNote)
                        sampler.stopNote(midiNote, onChannel: 0)
                    }
                }
            }
            
            // Stop timer when all events are processed
            if sortedEvents.isEmpty || currentTime >= totalDuration {
                timer.invalidate()
                self.playbackTimer = nil
                self.playingSource = nil
                self.playingChordIndex = -1
            }
        }
        
        // Ensure timer runs on common run loop mode for precision
        if let timer = playbackTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    /// Play a chord progression with timing between chords
    func playProgression(_ chords: [[Note]], tempoMS: Int = 800) {
        guard isEnabled else { return }
        
        // Stop any currently playing sounds first (this also increments generation)
        stopAllNotes()
        
        // Capture the current generation - if it changes, we abort
        let startGeneration = currentGeneration()
        
        for (index, chord) in chords.enumerated() {
            let delay = Double(index) * Double(tempoMS) / 1000.0
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self else { return }
                // Check if playback was canceled
                guard self.currentGeneration() == startGeneration else { return }
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
        
        // Cancel any existing playback
        playbackTimer?.invalidate()
        playbackTimer = nil
        scheduledNotes.removeAll()
        
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
        
        // Build schedule of note events
        var events: [(time: Double, note: UInt8, isStart: Bool)] = []
        for (index, note) in sequence.enumerated() {
            let noteStartTime = Double(index) * noteDuration
            let noteStopTime = noteStartTime + (noteDuration * 0.85)
            let midiNote = UInt8(note.midiNumber)
            
            events.append((time: noteStartTime, note: midiNote, isStart: true))
            events.append((time: noteStopTime, note: midiNote, isStart: false))
        }
        
        scheduledNotes = events.sorted { $0.time < $1.time }
        playbackStartTime = CACurrentMediaTime()
        
        // Use a high-frequency timer for precise scheduling
        playbackTimer = Timer.scheduledTimer(withTimeInterval: 0.001, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            
            let currentTime = CACurrentMediaTime() - self.playbackStartTime
            
            // Process all events that should have fired by now
            while !self.scheduledNotes.isEmpty && self.scheduledNotes[0].time <= currentTime {
                let event = self.scheduledNotes.removeFirst()
                
                if event.isStart {
                    sampler.startNote(event.note, withVelocity: 75, onChannel: 0)
                } else {
                    sampler.stopNote(event.note, onChannel: 0)
                }
            }
            
            // Stop timer when all events are processed
            if self.scheduledNotes.isEmpty {
                timer.invalidate()
                self.playbackTimer = nil
            }
        }
        
        // Ensure timer runs on common run loop mode for precision
        if let timer = playbackTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    /// Play a scale from a Scale object (ascending then descending)
    /// Uses the actual scale's root note to ensure audio matches the displayed root
    func playScaleObject(_ scale: Scale, bpm: Double = 160) {
        guard isEnabled, let sampler = sampler else { return }
        
        let ascendingNotes = scale.notesAscending()
        let rootMidi = scale.root.midiNumber  // Use the actual root from the scale
        
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
    
    // MARK: - Interval Playback
    
    /// Style for playing intervals
    enum IntervalPlaybackStyle: String, CaseIterable {
        case harmonic = "Harmonic"              // Both notes simultaneously
        case melodicAscending = "Melodic Up"    // Lower note, then higher note
        case melodicDescending = "Melodic Down" // Higher note, then lower note

        var description: String {
            switch self {
            case .harmonic:
                return "Both notes together"
            case .melodicAscending:
                return "Lower then higher"
            case .melodicDescending:
                return "Higher then lower"
            }
        }
    }

    enum ChordPlaybackStyle: String, CaseIterable, Codable {
        case block = "Block"
        case arpeggioUp = "Arpeggio ↑"
        case arpeggioDown = "Arpeggio ↓"
        case guideTones = "Guide Tones"

        var description: String {
            switch self {
            case .block: return "All notes simultaneously"
            case .arpeggioUp: return "Notes ascending"
            case .arpeggioDown: return "Notes descending"
            case .guideTones: return "Root, 3rd, 7th only"
            }
        }
    }
    
    /// Play an interval between two notes
    /// - Parameters:
    ///   - rootNote: The lower note of the interval
    ///   - targetNote: The higher note of the interval
    ///   - style: How to play the interval (harmonic, melodic ascending, or melodic descending)
    ///   - tempo: BPM for melodic playback (default 120 BPM = 0.5s per note)
    ///   - completion: Called when playback completes
    func playInterval(
        rootNote: Note,
        targetNote: Note,
        style: IntervalPlaybackStyle = .harmonic,
        tempo: Double = 120,
        completion: (() -> Void)? = nil
    ) {
        guard isEnabled, let sampler = sampler else {
            completion?()
            return
        }
        
        ensureAudioEngineRunning()
        
        let rootMidi = UInt8(rootNote.midiNumber)
        let targetMidi = UInt8(targetNote.midiNumber)
        let velocity: UInt8 = 80
        
        switch style {
        case .harmonic:
            playHarmonicInterval(rootMidi: rootMidi, targetMidi: targetMidi, velocity: velocity, completion: completion)
            
        case .melodicAscending:
            playMelodicInterval(firstMidi: rootMidi, secondMidi: targetMidi, tempo: tempo, velocity: velocity, completion: completion)
            
        case .melodicDescending:
            playMelodicInterval(firstMidi: targetMidi, secondMidi: rootMidi, tempo: tempo, velocity: velocity, completion: completion)
        }
    }
    
    /// Play both notes of an interval simultaneously
    private func playHarmonicInterval(rootMidi: UInt8, targetMidi: UInt8, velocity: UInt8, completion: (() -> Void)?) {
        guard let sampler = sampler else { return }
        
        // Start both notes
        sampler.startNote(rootMidi, withVelocity: velocity, onChannel: 0)
        sampler.startNote(targetMidi, withVelocity: velocity, onChannel: 0)
        
        // Hold for 1.5 seconds
        let duration: TimeInterval = 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            sampler.stopNote(rootMidi, onChannel: 0)
            sampler.stopNote(targetMidi, onChannel: 0)
            completion?()
        }
    }
    
    /// Play two notes sequentially
    private func playMelodicInterval(firstMidi: UInt8, secondMidi: UInt8, tempo: Double, velocity: UInt8, completion: (() -> Void)?) {
        guard let sampler = sampler else { return }
        
        let secondsPerBeat = 60.0 / tempo
        let noteDuration = secondsPerBeat * 2.0  // Each note lasts 2 beats
        
        // Play first note
        sampler.startNote(firstMidi, withVelocity: velocity, onChannel: 0)
        
        // Stop first note after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + noteDuration) {
            sampler.stopNote(firstMidi, onChannel: 0)
            
            // Play second note
            sampler.startNote(secondMidi, withVelocity: velocity, onChannel: 0)
            
            // Stop second note after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + noteDuration) {
                sampler.stopNote(secondMidi, onChannel: 0)
                completion?()
            }
        }
    }
    
    deinit {
        audioEngine?.stop()
    }
}
