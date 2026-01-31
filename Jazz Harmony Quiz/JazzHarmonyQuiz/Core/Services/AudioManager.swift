import Foundation
import AVFoundation
import AudioToolbox
#if os(iOS)
import AVKit
#endif

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
        #if os(iOS)
        // Configure audio session for playback
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            print("Audio session configured successfully")
        } catch {
            print("Failed to configure audio session: \(error)")
        }
        #endif
    }
    
    private func loadSoundFont() {
        // Create AUGraph for professional MIDI sequencing
        var status = NewAUGraph(&auGraph)
        guard status == noErr, let graph = auGraph else {
            print("Failed to create AUGraph")
            return
        }
        
        // Add sampler node (use Sampler on iOS, supports SF2 via kMusicDeviceProperty_SoundBankURL)
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
        #if os(iOS)
        let outputSubType = kAudioUnitSubType_RemoteIO
        #else
        let outputSubType = kAudioUnitSubType_DefaultOutput
        #endif
        
        var outputDescription = AudioComponentDescription(
            componentType: kAudioUnitType_Output,
            componentSubType: outputSubType,
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
        
        // Initialize the graph FIRST (required before loading instruments)
        status = AUGraphInitialize(graph)
        guard status == noErr else {
            print("❌ Failed to initialize AUGraph: OSStatus \(status)")
            return
        }
        
        // Load preset into the sampler AFTER graph initialization
        if let soundFontURL = Bundle.main.url(forResource: "Piano", withExtension: "sf2") {
            print("📁 Found Piano.sf2 at: \(soundFontURL.path)")
            
            // Load the soundfont using AUPreset data
            var presetData = AUSamplerInstrumentData(
                fileURL: Unmanaged.passRetained(soundFontURL as CFURL),
                instrumentType: UInt8(kInstrumentType_SF2Preset),
                bankMSB: UInt8(kAUSampler_DefaultMelodicBankMSB),
                bankLSB: UInt8(kAUSampler_DefaultBankLSB),
                presetID: 0
            )
            
            status = AudioUnitSetProperty(
                unit,
                AudioUnitPropertyID(kAUSamplerProperty_LoadInstrument),
                AudioUnitScope(kAudioUnitScope_Global),
                0,
                &presetData,
                UInt32(MemoryLayout<AUSamplerInstrumentData>.size)
            )
            
            if status == noErr {
                print("✅ Loaded Piano.sf2 successfully")
            } else {
                print("⚠️ Failed to load Piano.sf2: OSStatus \(status)")
            }
        } else {
            print("⚠️ Piano.sf2 not found in bundle")
        }
        
        status = AUGraphStart(graph)
        guard status == noErr else {
            print("❌ Failed to start AUGraph: OSStatus \(status)")
            return
        }
        
        // Create MusicSequence and MusicPlayer
        NewMusicSequence(&musicSequence)
        NewMusicPlayer(&musicPlayer)
        
        // CRITICAL: Connect the sequence to our AUGraph (so it uses our loaded soundfont)
        if let sequence = musicSequence {
            status = MusicSequenceSetAUGraph(sequence, graph)
            if status == noErr {
                print("✅ MusicSequence connected to AUGraph")
            } else {
                print("⚠️ Failed to connect MusicSequence to AUGraph: OSStatus \(status)")
            }
        }
        
        print("✅ AUGraph and MusicSequence initialized successfully")
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
        _ = MusicDeviceMIDIEvent(unit, UInt32(noteCommand), UInt32(note), UInt32(velocity), 0)
    }
    
    /// Send MIDI Note Off to AudioUnit
    private func sendMIDINoteOff(unit: AudioUnit, note: UInt8, channel: UInt8 = 0) {
        let noteCommand: UInt8 = 0x80 | channel
        _ = MusicDeviceMIDIEvent(unit, UInt32(noteCommand), UInt32(note), 0, 0)
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
        guard isEnabled, !notes.isEmpty else { return }
        
        // Stop any currently playing sounds first
        stopAllNotes()
        
        // Normalize notes to middle C octave (MIDI 60-71)
        let normalizedMidiNotes = notes.map { note -> UInt8 in
            let pitchClass = note.midiNumber % 12
            return UInt8(60 + pitchClass)  // Octave 4 (middle C)
        }
        
        // Use MusicSequence for sample-accurate timing
        guard let sequence = musicSequence, let player = musicPlayer else { return }
        
        var status: OSStatus
        
        // Stop any currently playing sequence
        status = MusicPlayerStop(player)
        
        // Clear sequence
        var trackCount: UInt32 = 0
        status = MusicSequenceGetTrackCount(sequence, &trackCount)
        for i in (0..<trackCount).reversed() {
            var track: MusicTrack?
            status = MusicSequenceGetIndTrack(sequence, UInt32(i), &track)
            if let track = track {
                MusicSequenceDisposeTrack(sequence, track)
            }
        }
        
        // Create new track
        var track: MusicTrack?
        status = MusicSequenceNewTrack(sequence, &track)
        guard status == noErr, let track = track else { return }
        
        // Set track to use our sampler node
        if samplerNode != -1 {
            MusicTrackSetDestNode(track, samplerNode)
        }
        
        // Add note events - all start at beat 0 (simultaneous)
        for midiNote in normalizedMidiNotes {
            var message = MIDINoteMessage(
                channel: 0,
                note: midiNote,
                velocity: velocity,
                releaseVelocity: 0,
                duration: Float32(duration)
            )
            
            status = MusicTrackNewMIDINoteEvent(track, 0, &message)
            guard status == noErr else { continue }
        }
        
        // Set sequence length
        var length = MusicTimeStamp(duration)
        status = MusicTrackSetProperty(track, kSequenceTrackProperty_TrackLength, &length, UInt32(MemoryLayout<MusicTimeStamp>.size))
        
        // Configure and play
        status = MusicPlayerSetSequence(player, sequence)
        status = MusicPlayerPreroll(player)
        status = MusicPlayerSetTime(player, 0)
        status = MusicPlayerStart(player)
        
        // Stop player after duration
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) { [weak self] in
            guard let self = self, let player = self.musicPlayer else { return }
            MusicPlayerStop(player)
            self.stopAllNotes()
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
            playArpeggio(notes: notes.sorted { $0.midiNumber < $1.midiNumber }, tempo: tempo, completion: completion)

        case .arpeggioDown:
            playArpeggio(notes: notes.sorted { $0.midiNumber > $1.midiNumber }, tempo: tempo, completion: completion)

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
    
    /// Play arpeggio using MusicSequence for sample-accurate timing
    private func playArpeggio(notes: [Note], tempo: Double, completion: (() -> Void)?) {
        guard let sequence = musicSequence, let player = musicPlayer else {
            completion?()
            return
        }
        
        var status: OSStatus
        let beatsPerNote = 1.0
        let noteDuration = beatsPerNote * 0.8
        
        // Stop current playback
        MusicPlayerStop(player)
        
        // Clear sequence
        var trackCount: UInt32 = 0
        status = MusicSequenceGetTrackCount(sequence, &trackCount)
        for i in (0..<trackCount).reversed() {
            var track: MusicTrack?
            status = MusicSequenceGetIndTrack(sequence, UInt32(i), &track)
            if let track = track {
                MusicSequenceDisposeTrack(sequence, track)
            }
        }
        
        // Create track
        var track: MusicTrack?
        status = MusicSequenceNewTrack(sequence, &track)
        guard status == noErr, let track = track else {
            completion?()
            return
        }
        
        if samplerNode != -1 {
            MusicTrackSetDestNode(track, samplerNode)
        }
        
        // Add notes
        for (index, note) in notes.enumerated() {
            let pitchClass = note.midiNumber % 12
            let normalizedMidi = UInt8(60 + pitchClass)
            let startBeat = MusicTimeStamp(Double(index) * beatsPerNote)
            
            var message = MIDINoteMessage(
                channel: 0,
                note: normalizedMidi,
                velocity: 80,
                releaseVelocity: 0,
                duration: Float32(noteDuration)
            )
            
            MusicTrackNewMIDINoteEvent(track, startBeat, &message)
        }
        
        // Set tempo
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        if let tempoTrack = tempoTrack {
            MusicTrackClear(tempoTrack, 0, 1000)
            MusicTrackNewExtendedTempoEvent(tempoTrack, 0, tempo)
        }
        
        // Play
        MusicPlayerSetSequence(player, sequence)
        MusicPlayerPreroll(player)
        MusicPlayerSetTime(player, 0)
        MusicPlayerStart(player)
        
        // Call completion
        let totalDuration = (60.0 / tempo) * Double(notes.count) * beatsPerNote
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            completion?()
        }
    }
    
    /// Play a cadence progression with MusicSequence timing
    /// - Parameters:
    ///   - chords: Array of chord note arrays (e.g., [[ii chord notes], [V chord notes], [I chord notes]])
    ///   - bpm: Tempo in beats per minute (default 90 BPM for a relaxed jazz feel)
    ///   - beatsPerChord: How many beats each chord rings (default 2 beats)
    ///   - source: Identifier for UI highlighting ("correct", "user", or nil)
    func playCadenceProgression(_ chords: [[Note]], bpm: Double = 90, beatsPerChord: Double = 2, source: String? = nil) {
        guard isEnabled, !chords.isEmpty else { return }
        guard let sequence = musicSequence, let player = musicPlayer else { return }
        
        stopAllNotes()
        
        // Set playback source for UI
        DispatchQueue.main.async {
            self.playingSource = source
        }
        
        let startGeneration = currentGeneration()
        var status: OSStatus
        
        // Stop and clear
        MusicPlayerStop(player)
        var trackCount: UInt32 = 0
        status = MusicSequenceGetTrackCount(sequence, &trackCount)
        for i in (0..<trackCount).reversed() {
            var track: MusicTrack?
            status = MusicSequenceGetIndTrack(sequence, UInt32(i), &track)
            if let track = track {
                MusicSequenceDisposeTrack(sequence, track)
            }
        }
        
        // Create track
        var track: MusicTrack?
        status = MusicSequenceNewTrack(sequence, &track)
        guard status == noErr, let track = track else { return }
        
        if samplerNode != -1 {
            MusicTrackSetDestNode(track, samplerNode)
        }
        
        // Add chords
        let noteDuration = beatsPerChord * 0.9
        for (chordIndex, chord) in chords.enumerated() {
            let startBeat = MusicTimeStamp(Double(chordIndex) * beatsPerChord)
            
            let normalizedMidiNotes = chord.map { note -> UInt8 in
                let pitchClass = note.midiNumber % 12
                return UInt8(60 + pitchClass)
            }
            
            for midiNote in normalizedMidiNotes {
                var message = MIDINoteMessage(
                    channel: 0,
                    note: midiNote,
                    velocity: 75,
                    releaseVelocity: 0,
                    duration: Float32(noteDuration)
                )
                MusicTrackNewMIDINoteEvent(track, startBeat, &message)
            }
            
            // Schedule UI update
            let delay = (60.0 / bpm) * Double(chordIndex) * beatsPerChord
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) { [weak self] in
                guard let self = self, self.currentGeneration() == startGeneration else { return }
                self.playingChordIndex = chordIndex
            }
        }
        
        // Set tempo
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        if let tempoTrack = tempoTrack {
            MusicTrackClear(tempoTrack, 0, 1000)
            MusicTrackNewExtendedTempoEvent(tempoTrack, 0, bpm)
        }
        
        // Play
        MusicPlayerSetSequence(player, sequence)
        MusicPlayerPreroll(player)
        MusicPlayerSetTime(player, 0)
        MusicPlayerStart(player)
        
        // Clear state after completion
        let totalDuration = (60.0 / bpm) * Double(chords.count) * beatsPerChord + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) { [weak self] in
            guard let self = self, self.currentGeneration() == startGeneration else { return }
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
    
    /// Play both notes of an interval simultaneously using MusicSequence
    private func playHarmonicInterval(rootMidi: UInt8, targetMidi: UInt8, velocity: UInt8, completion: (() -> Void)?) {
        guard let sequence = musicSequence, let player = musicPlayer else {
            completion?()
            return
        }
        
        var status: OSStatus
        let duration = 1.5
        
        // Stop and clear
        MusicPlayerStop(player)
        var trackCount: UInt32 = 0
        status = MusicSequenceGetTrackCount(sequence, &trackCount)
        for i in (0..<trackCount).reversed() {
            var track: MusicTrack?
            status = MusicSequenceGetIndTrack(sequence, UInt32(i), &track)
            if let track = track {
                MusicSequenceDisposeTrack(sequence, track)
            }
        }
        
        // Create track
        var track: MusicTrack?
        status = MusicSequenceNewTrack(sequence, &track)
        guard status == noErr, let track = track else {
            completion?()
            return
        }
        
        if samplerNode != -1 {
            MusicTrackSetDestNode(track, samplerNode)
        }
        
        // Add both notes at beat 0
        var rootMessage = MIDINoteMessage(channel: 0, note: rootMidi, velocity: velocity, releaseVelocity: 0, duration: Float32(duration))
        var targetMessage = MIDINoteMessage(channel: 0, note: targetMidi, velocity: velocity, releaseVelocity: 0, duration: Float32(duration))
        MusicTrackNewMIDINoteEvent(track, 0, &rootMessage)
        MusicTrackNewMIDINoteEvent(track, 0, &targetMessage)
        
        // Play
        MusicPlayerSetSequence(player, sequence)
        MusicPlayerPreroll(player)
        MusicPlayerSetTime(player, 0)
        MusicPlayerStart(player)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + duration + 0.1) {
            completion?()
        }
    }
    
    /// Play two notes sequentially using MusicSequence
    private func playMelodicInterval(firstMidi: UInt8, secondMidi: UInt8, tempo: Double, velocity: UInt8, completion: (() -> Void)?) {
        guard let sequence = musicSequence, let player = musicPlayer else {
            completion?()
            return
        }
        
        var status: OSStatus
        let beatsPerNote = 2.0
        let noteDuration = beatsPerNote * 0.9
        
        // Stop and clear
        MusicPlayerStop(player)
        var trackCount: UInt32 = 0
        status = MusicSequenceGetTrackCount(sequence, &trackCount)
        for i in (0..<trackCount).reversed() {
            var track: MusicTrack?
            status = MusicSequenceGetIndTrack(sequence, UInt32(i), &track)
            if let track = track {
                MusicSequenceDisposeTrack(sequence, track)
            }
        }
        
        // Create track
        var track: MusicTrack?
        status = MusicSequenceNewTrack(sequence, &track)
        guard status == noErr, let track = track else {
            completion?()
            return
        }
        
        if samplerNode != -1 {
            MusicTrackSetDestNode(track, samplerNode)
        }
        
        // Add notes sequentially
        var firstMessage = MIDINoteMessage(channel: 0, note: firstMidi, velocity: velocity, releaseVelocity: 0, duration: Float32(noteDuration))
        var secondMessage = MIDINoteMessage(channel: 0, note: secondMidi, velocity: velocity, releaseVelocity: 0, duration: Float32(noteDuration))
        MusicTrackNewMIDINoteEvent(track, 0, &firstMessage)
        MusicTrackNewMIDINoteEvent(track, MusicTimeStamp(beatsPerNote), &secondMessage)
        
        // Set tempo
        var tempoTrack: MusicTrack?
        MusicSequenceGetTempoTrack(sequence, &tempoTrack)
        if let tempoTrack = tempoTrack {
            MusicTrackClear(tempoTrack, 0, 1000)
            MusicTrackNewExtendedTempoEvent(tempoTrack, 0, tempo)
        }
        
        // Play
        MusicPlayerSetSequence(player, sequence)
        MusicPlayerPreroll(player)
        MusicPlayerSetTime(player, 0)
        MusicPlayerStart(player)
        
        let totalDuration = (60.0 / tempo) * beatsPerNote * 2.0
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration + 0.1) {
            completion?()
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
