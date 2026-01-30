import Foundation
import AVFoundation
import AudioToolbox

/// Manages audio playback using AUGraph and MusicSequence for professional MIDI timing
class AudioManager: ObservableObject {
    static let shared = AudioManager()
    
    private var auGraph: AUGraph?
    private var samplerNode: AUNode = 0
    private var outputNode: AUNode = 0
    private var samplerUnit: AudioUnit?
    private var musicPlayer: MusicPlayer?
    private var musicSequence: MusicSequence?
    @Published var isEnabled: Bool = true
    @Published var volume: Float = 0.7
    
    /// Track currently playing MIDI notes so we can stop them before new playback
    private var activeNotes: Set<UInt8> = []
    private let notesLock = NSLock()
    
    /// Generation counter for canceling scheduled progression playback
    /// When a new playback starts, we increment this; scheduled plays check it before playing
    private var playbackGeneration: Int = 0
    private let generationLock = NSLock()
    
    // MARK: - Playback State Tracking (for UI highlighting)
    
    /// Which source is currently playing ("correct", "user", or nil if none)
    @Published var playingSource: String? = nil
    
    /// Which chord index is currently playing (-1 if none)
    @Published var playingChordIndex: Int = -1
    
    private init() {
        setupAudioSession()
        loadSoundFont()
    }
    
    private func setupAudioSession() {
        // Configure audio session for playback
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
    }
    
    private func loadSoundFont() {
        // Create AUGraph for professional MIDI sequencing
        var status = NewAUGraph(&auGraph)
        guard status == noErr, let graph = auGraph else {
            print("Failed to create AUGraph")
            return
        }
        
        // Add sampler node
        var samplerDescription = AudioComponentDescription(
            componentType: kAudioUnitType_MusicDevice,
            componentSubType: kAudioUnitSubType_Sampler,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0
        )
        status = AUGraphAddNode(graph, &samplerDescription, &samplerNode)
        guard status == noErr else {
            print("Failed to add sampler node")
            return
        }
        
        // Add output node
        var outputDescription = AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: kAudioUnitSubType_RemoteIO,
            componentManufacturer: kAudioUnitManufacturer_Apple,
            componentFlags: 0,
            componentFlagsMask: 0
        )
        status = AUGraphAddNode(graph, &outputDescription, &outputNode)
        guard status == noErr else {
            print("Failed to add output node")
            return
        }
        
        // Connect sampler to output
        status = AUGraphConnectNodeInput(graph, samplerNode, 0, outputNode, 0)
        guard status == noErr else {
            print("Failed to connect nodes")
            return
        }
        
        // Open and initialize the graph
        status = AUGraphOpen(graph)
        guard status == noErr else {
            print("Failed to open AUGraph")
            return
        }
        
        // Get the sampler unit
        status = AUGraphNodeInfo(graph, samplerNode, nil, &samplerUnit)
        guard status == noErr, let unit = samplerUnit else {
            print("Failed to get sampler unit")
            return
        }
        
        // Load soundfont
        do {
            // Try bundled soundfont first
            if let soundFontURL = Bundle.main.url(forResource: "Piano", withExtension: "sf2") {
                var bankURL = soundFontURL as CFURL
                var presetNumber: UInt8 = 0
                status = AudioUnitSetProperty(
                    unit,
                    AudioUnitPropertyID(kMusicDeviceProperty_SoundBankURL),
                    AudioUnitScope(kAudioUnitScope_Global),
                    0,
                    &bankURL,
                    UInt32(MemoryLayout<CFURL>.size)
                )
                if status == noErr {
                    print("Loaded bundled Piano.sf2")
                } else {
                    print("Failed to load soundfont: \(status)")
                }
            }
            
            // Initialize and start the graph
            status = AUGraphInitialize(graph)
            guard status == noErr else {
                print("Failed to initialize AUGraph")
                return
            }
            
            status = AUGraphStart(graph)
            guard status == noErr else {
                print("Failed to start AUGraph")
                return
            }
            
            // Create MusicSequence and MusicPlayer
            NewMusicSequence(&musicSequence)
            NewMusicPlayer(&musicPlayer)
            
            print("✅ AUGraph and MusicSequence initialized successfully")
            
        }
    }
    
    /// Stop all currently playing notes immediately and cancel scheduled playback
    /// Call this before starting any new sound to prevent overlapping
    func stopAllNotes() {
        guard let unit = samplerUnit else { return }
        
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
            sendMIDINoteOff(unit: unit, note: midiNote)
        }
        
        // Also send note-off for all possible notes in case any were missed
        for midiNote: UInt8 in 0...127 {
            sendMIDINoteOff(unit: unit, note: midiNote)
        }
    }
    
    /// Send MIDI Note On to AudioUnit
    private func sendMIDINoteOn(unit: AudioUnit, note: UInt8, velocity: UInt8, channel: UInt8 = 0) {
        let noteCommand: UInt8 = 0x90 | channel
        var status = MusicDeviceMIDIEvent(unit, UInt32(noteCommand), UInt32(note), UInt32(velocity), 0)
    }
    
    /// Send MIDI Note Off to AudioUnit
    private func sendMIDINoteOff(unit: AudioUnit, note: UInt8, channel: UInt8 = 0) {
        let noteCommand: UInt8 = 0x80 | channel
        var status = MusicDeviceMIDIEvent(unit, UInt32(noteCommand), UInt32(note), 0, 0)
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
        guard isEnabled, let unit = samplerUnit else { return }
        
        stopAllNotes()  // Stop any previous sounds
        
        trackNoteOn(midiNote)
        sendMIDINoteOn(unit: unit, note: midiNote, velocity: velocity)
        
        // Stop note after a short duration
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.trackNoteOff(midiNote)
            self.sendMIDINoteOff(unit: unit, note: midiNote)
        }
    }
    
    /// Stop a note
    func stopNote(_ midiNote: UInt8) {
        guard let unit = samplerUnit else { return }
        trackNoteOff(midiNote)
        sendMIDINoteOff(unit: unit, note: midiNote)
    }
    
    /// Play a chord (multiple notes together)
    func playChord(_ notes: [Note], velocity: UInt8 = 80, duration: TimeInterval = 1.5) {
        guard isEnabled, let unit = samplerUnit, !notes.isEmpty else { return }

        // Stop any currently playing sounds first
        stopAllNotes()

        // Normalize notes to middle C octave (MIDI 60-71)
        let normalizedMidiNotes = notes.map { note -> UInt8 in
            let pitchClass = note.midiNumber % 12
            return UInt8(60 + pitchClass)  // Octave 4 (middle C)
        }

        // Start all notes
        for midiNote in normalizedMidiNotes {
            trackNoteOn(midiNote)
            sendMIDINoteOn(unit: unit, note: midiNote, velocity: velocity)
        }

        // Stop all notes after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self, let unit = self.samplerUnit else { return }
            for midiNote in normalizedMidiNotes {
                self.trackNoteOff(midiNote)
                self.sendMIDINoteOff(unit: unit, note: midiNote)
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
        guard isEnabled, let unit = samplerUnit else {
            completion?()
            return
        }

        // Stop any currently playing sounds first
        stopAllNotes()

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
                    guard let self = self, let unit = self.samplerUnit else { return }
                    let pitchClass = note.midiNumber % 12
                    let normalizedMidi = UInt8(60 + pitchClass)
                    self.trackNoteOn(normalizedMidi)
                    self.sendMIDINoteOn(unit: unit, note: normalizedMidi, velocity: 80)

                    DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenNotes * 0.8) {
                        self.trackNoteOff(normalizedMidi)
                        self.sendMIDINoteOff(unit: unit, note: normalizedMidi)
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
                    guard let self = self, let unit = self.samplerUnit else { return }
                    let pitchClass = note.midiNumber % 12
                    let normalizedMidi = UInt8(60 + pitchClass)
                    self.trackNoteOn(normalizedMidi)
                    self.sendMIDINoteOn(unit: unit, note: normalizedMidi, velocity: 80)

                    DispatchQueue.main.asyncAfter(deadline: .now() + delayBetweenNotes * 0.8) {
                        self.trackNoteOff(normalizedMidi)
                        self.sendMIDINoteOff(unit: unit, note: normalizedMidi)
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
    
    /// Play a cadence progression with simple timing
    /// - Parameters:
    ///   - chords: Array of chord note arrays (e.g., [[ii chord notes], [V chord notes], [I chord notes]])
    ///   - bpm: Tempo in beats per minute (default 90 BPM for a relaxed jazz feel)
    ///   - beatsPerChord: How many beats each chord rings (default 2 beats)
    ///   - source: Identifier for UI highlighting ("correct", "user", or nil)
    func playCadenceProgression(_ chords: [[Note]], bpm: Double = 90, beatsPerChord: Double = 2, source: String? = nil) {
        guard isEnabled, let unit = samplerUnit, !chords.isEmpty else { return }
        
        stopAllNotes()
        
        // Set the playback source for UI highlighting
        DispatchQueue.main.async {
            self.playingSource = source
        }
        
        // Capture the current generation - if it changes, we abort
        let startGeneration = currentGeneration()
        
        let secondsPerBeat = 60.0 / bpm
        let chordDuration = secondsPerBeat * beatsPerChord
        
        // Schedule all chords
        for (chordIndex, chord) in chords.enumerated() {
            let delay = Double(chordIndex) * chordDuration
            
            // Schedule chord start
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self,
                      let unit = self.samplerUnit,
                      self.currentGeneration() == startGeneration else { return }
                
                // Update UI
                self.playingChordIndex = chordIndex
                
                // Normalize notes to middle C octave
                let normalizedMidiNotes = chord.map { note -> UInt8 in
                    let pitchClass = note.midiNumber % 12
                    return UInt8(60 + pitchClass)
                }
                
                // Play all notes
                for midiNote in normalizedMidiNotes {
                    self.trackNoteOn(midiNote)
                    self.sendMIDINoteOn(unit: unit, note: midiNote, velocity: 75)
                }
                
                // Stop notes after duration (90% articulation)
                let stopDelay = chordDuration * 0.9
                DispatchQueue.main.asyncAfter(deadline: .now() + stopDelay) { [weak self] in
                    guard let self = self,
                          let unit = self.samplerUnit,
                          self.currentGeneration() == startGeneration else { return }
                    for midiNote in normalizedMidiNotes {
                        self.trackNoteOff(midiNote)
                        self.sendMIDINoteOff(unit: unit, note: midiNote)
                    }
                }
            }
        }
        
        // Clear playback state after completion
        let totalDuration = Double(chords.count) * chordDuration + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) { [weak self] in
            guard let self = self,
                  self.currentGeneration() == startGeneration else { return }
            self.playingSource = nil
            self.playingChordIndex = -1
        }
    }
    
    /// Fallback to sampler-based cadence playback
    
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
        // Volume control can be implemented later via AudioUnit properties if needed
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
    
    /// Play a scale with professional MIDI sequencer timing
    /// - Parameters:
    ///   - notes: The scale notes (should include root through octave)
    ///   - bpm: Tempo in beats per minute (default 160 BPM for lively playback)
    ///   - direction: Whether to play ascending, descending, or both
    func playScale(_ notes: [Note], bpm: Double = 160, direction: ScaleDirection = .ascendingDescending) {
        guard isEnabled,
              let player = musicPlayer,
              let sequence = musicSequence,
              !notes.isEmpty else {
            return
        }
        
        // Stop current playback
        MusicPlayerStop(player)
        
        // Prepare note sequence
        var noteSequence: [Note] = []
        switch direction {
        case .ascending:
            noteSequence = notes
        case .descending:
            noteSequence = notes.reversed()
        case .ascendingDescending:
            noteSequence = notes + Array(notes.dropLast().reversed())
        }
        
        // Clear existing tracks
        var trackCount: UInt32 = 0
        MusicSequenceGetTrackCount(sequence, &trackCount)
        for i in (0..<trackCount).reversed() {
            var track: MusicTrack?
            MusicSequenceGetIndTrack(sequence, UInt32(i), &track)
            if let track = track {
                MusicSequenceDisposeTrack(sequence, track)
            }
        }
        
        // Create new track
        var track: MusicTrack?
        MusicSequenceNewTrack(sequence, &track)
        guard let musicTrack = track else { return }
        
        // Route track to our sampler node in the AUGraph
        MusicTrackSetDestNode(musicTrack, samplerNode)
        
        // Set tempo
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        if let tempoTrack = tempoTrack {
            MusicTrackClear(tempoTrack, 0, 1000)
            MusicTrackNewExtendedTempoEvent(tempoTrack, 0, bpm)
        }
        
        // Add MIDI note events
        for (index, note) in noteSequence.enumerated() {
            let startTime = MusicTimeStamp(index)
            var message = MIDINoteMessage(
                channel: 0,
                note: UInt8(note.midiNumber),
                velocity: 75,
                releaseVelocity: 0,
                duration: 0.85
            )
            MusicTrackNewMIDINoteEvent(musicTrack, startTime, &message)
        }
        
        // Set sequence length
        var length = MusicTimeStamp(noteSequence.count + 1)
        MusicTrackSetProperty(musicTrack, kSequenceTrackProperty_TrackLength, &length, UInt32(MemoryLayout<MusicTimeStamp>.size))
        
        // Connect sequence to player
        MusicPlayerSetSequence(player, sequence)
        
        // Preroll and start
        MusicPlayerSetTime(player, 0)
        MusicPlayerPreroll(player)
        MusicPlayerStart(player)
        
        print("🎵 MIDI Sequencer: \(noteSequence.count) notes at \(bpm) BPM")
    }
    
    /// Play a scale from a Scale object (ascending then descending)
    /// Uses the actual scale's root note to ensure audio matches the displayed root
    func playScaleObject(_ scale: Scale, bpm: Double = 160) {
        print("🔍 playScaleObject called")
        guard isEnabled else {
            print("❌ playScaleObject: audio disabled")
            return
        }
        
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
        
        print("🔍 playScaleObject calling playScale with \(adjustedNotes.count) notes")
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
        guard isEnabled, let unit = samplerUnit else {
            completion?()
            return
        }
        
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
        guard let unit = samplerUnit else { return }
        
        // Start both notes
        sendMIDINoteOn(unit: unit, note: rootMidi, velocity: velocity)
        sendMIDINoteOn(unit: unit, note: targetMidi, velocity: velocity)
        
        // Hold for 1.5 seconds
        let duration: TimeInterval = 1.5
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
            guard let self = self, let unit = self.samplerUnit else { return }
            self.sendMIDINoteOff(unit: unit, note: rootMidi)
            self.sendMIDINoteOff(unit: unit, note: targetMidi)
            completion?()
        }
    }
    
    /// Play two notes sequentially
    private func playMelodicInterval(firstMidi: UInt8, secondMidi: UInt8, tempo: Double, velocity: UInt8, completion: (() -> Void)?) {
        guard let unit = samplerUnit else { return }
        
        let secondsPerBeat = 60.0 / tempo
        let noteDuration = secondsPerBeat * 2.0  // Each note lasts 2 beats
        
        // Play first note
        sendMIDINoteOn(unit: unit, note: firstMidi, velocity: velocity)
        
        // Stop first note after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + noteDuration) { [weak self] in
            guard let self = self, let unit = self.samplerUnit else { return }
            self.sendMIDINoteOff(unit: unit, note: firstMidi)
            
            // Play second note
            self.sendMIDINoteOn(unit: unit, note: secondMidi, velocity: velocity)
            
            // Stop second note after duration
            DispatchQueue.main.asyncAfter(deadline: .now() + noteDuration) { [weak self] in
                guard let self = self, let unit = self.samplerUnit else { return }
                self.sendMIDINoteOff(unit: unit, note: secondMidi)
                completion?()
            }
        }
    }
    
    deinit {
        if let graph = auGraph {
            AUGraphStop(graph)
            DisposeAUGraph(graph)
        }
        if let player = musicPlayer {
            DisposeMusicPlayer(player)
        }
        if let sequence = musicSequence {
            DisposeMusicSequence(sequence)
        }
    }
}
