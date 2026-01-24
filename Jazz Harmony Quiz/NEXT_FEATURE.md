# Next Feature: Progression Drills

**Current Status:** Ear Training Suite ✅ Complete (Intervals, Chords, Cadences)  
**Next Up:** Progression Drills (Turnarounds, Rhythm Changes, Blues, Standards)  
**Priority:** High (apply ear training to real music)  
**Estimated Time:** 8-10 hours

---

## Why This Feature Next?

### Pedagogical Reasoning

1. **Natural progression:** Students can now identify intervals by ear; next step is full chord qualities
2. **Most impactful skill:** Recognizing chord types by ear is essential for comping, transcription, and improvisation
3. **Builds on existing infrastructure:** AudioManager can already play chords, just need ear-first UI
4. **High student demand:** "What chord is that?" is the #1 question on gigs
5. **Bridges theory → music:** Students can spell chords visually; now they learn to hear them

### What Students Gain

- **Recognize chord quality by ear** → hear maj7 vs dom7 vs m7
- **Identify extensions instantly** → hear a 9, 11, or 13 in context
- **Better transcription** → learn songs faster from recordings
- **Improved comping** → match the pianist's voicings
- **Transfer to all music** → chord recognition is universal

---

## What Already Exists

✅ **ChordModel.swift** - Complete data model:
- `ChordQuality` enum with all jazz chord types
- `Chord` struct with voicing logic
- `ChordDatabase` with beginner → expert progression
- Extensions support (9, 11, 13, alterations)

✅ **QuizGame.swift** - Game logic foundation:
- Quiz state management
- Question generation
- Answer checking
- Results tracking
- SR integration

✅ **ChordDrillView.swift** - UI for visual chord practice

✅ **AudioManager.swift** - Complete audio infrastructure:
- `playChord()` method with multiple notes
- Block chord playback
- Arpeggio support (already implemented)
- Guide tone playback
- Volume control
- Settings integration

---

## WhatChord Question Type Extension

**Add to ChordModel.swift:**

```swift
enum ChordQuestionType: String, Codable, CaseIterable {
    case singleTone = "Identify Single Tone"
    case allTones = "Spell All Tones"
    case spelling = "Written Spelling"
    case auralQuality = "Identify Quality by Ear"      // NEW
    case auralSpelling = "Spell Chord by Ear"          // NEW
    case auralExtension = "Identify Extension by Ear"  // NEW
}
```

### 2. Answer Generation for Ear Training

**Multiple Choice Quality Recognition:**
- Generate 4-6 answer choices based on difficulty
- Beginner: maj7, m7, 7, dim7
- Intermediate: Add m7♭5, maj6, sus4
- Advanced: Add alt, maj7#5, m(maj7), add9
- Distractors should be sonically similar (maj7 vs maj6, m7 vs m7♭5)

**Example:** If correct chord is Dm7:
- Choices: Dmaj7, Dm7 ✓, D7, Dm7♭5

### 3. Aural Question Flow in ChordDrillView

**Current flow (visual):**
1. Show chord symbol (e.g., "Cmaj7")
2. User selects notes on keyboard
3. Check answer

**New flow (aural quality):**
1. Play chord audio (block, arpeggio, or guide tones)
2. Show "Play Again" button
3. User selects chord quality from multiple choice
4. Check answer
5. Show visual confirmation (chord symbol + keyboard highlighting)

**New flow (aural spelling):**
1. Play chord audio
2. Show "Play Again" button  
3. User selects all notes on keyboard
4. Check answer (can be partial credit)
5. Show visual confirmation

**UI Changes:**
```swift
if question.questionType.isAural {
    VStack {
        // Play button with style options
        Menu {
            Button("Block Chord") { playChord(.block) }
            Button("Arpeggio Up") { playChord(.arpeggioUp) }
            Button("Guide Tones") { playChord(.guideTones) }
        } label: {
            Label("🔊 Play Chord", systemImage: "speaker.wave.2")
        }
        
        // For quality questions: multiple choice
        if question.questionType == .auralQuality {
            ForEach(qualityChoices) { choice in
                Button(choice.name) {
                    submitAnswer(choice)
                }
            }
        }
        
        // For spelling questions: keyboard
        if question.questionType == .auralSpelling {
            PianoKeyboard(selectedNotes: $selectedNotes)
        }
    }
}
```

### 4. Settings Integration

**Add to SettingsView.swift:**

```swift
Section("Chord Ear Training") {
    Toggle("Auto-Play Chords", isOn: $settings.autoPlayChords)
    
    Picker("Default Playback Style", selection: $settings.defaultChordStyle) {
        Text("Block").tag(ChordPlaybackStyle.block)
        Text("Arpeggio Up").tag(.arpeggioUp)
        Text("Arpeggio Down").tag(.arpeggioDown)
        Text("Guide Tones Only").tag(.guideTones)
    }
    
    Toggle("Allow Playback Style Choice", isOn: $settings.allowChordStyleChoice)
    
    Slider(value: $settings.arpeggioSpeed, in: 0.05...0.3) {
        Text("Arpeggio Speed: \(Int(settings.arpeggioSpeed * 1000))ms")
    }
}
```

### 5. Progressive Difficulty

**Beginner:**
- Major 7th, Minor 7th, Dominant 7th
- Block chord playback (easiest)
- Only quality recognition (not spelling)

**Intermediate:**
- Add: m7♭5, diminished 7th, sus4, major 6th
- Arpeggio playback
- Both quality + spelling questions

**Advanced:**
- All alterations: 7alt, maj7#5, m(maj7)
- Extensions: 9ths, 11ths, 13ths
- Guide tones only (hardest - just 3rd & 7th)
- "Identify the extension" questionstc.)
- Augmented/Diminished intervals
- Faster tempo, single playthrough
Extend Chord Model (1 hour)

1. Add `.auralQuality`, `.auralSpelling`, `.auralExtension` to `ChordQuestionType`
2. Add `isAural` computed property for convenience
3. Update `QuizGame` to handle new question types
4. Test compilation across all files

### Step 2: Answer Generation Logic (2 hours)

1. Create `generateQualityChoices()` in `QuizGame`
2. Implement difficulty-based distractor selection
3. Ensure sonic similarity (maj7 ≈ maj6, not maj7 ≈ dim7)
4. Test with all chord qualities

### Step 3: UI for Aural Mode (2 hours)

1. Detect aural question types in `ChordDrillView`
2. Add "Play Chord" menu button with style options
3. Implement auto-play on question load
4. Add multiple choice UI for quality questions
5. Add keyboard UI for spelling questions

### Step 4: Audio Playback Enhancement (1 hour)

1. Test existing `playChord()` method with various voicings
2. Add arpeggio timing control if needed
3. Ensure guide tones work correctly (3rd + 7th only)
4. Add completion callbacks for UI sync

### Step 5: Settings & Integration (1 hour)

1. Add chord ear training settings
2. Hook up auto-play toggle
3. Add playback style preferences
4. Persist to UserDefaults

### Step 6: Polish & Testing (1 hour)

1. Add visual feedback after submission
2. Test across all difficulty levels
3. Verify SR integration captures ear training attempts
4.Using existing AudioManager infrastructure:**
- `playChord()` already supports multiple notes
- Block chord: All notes simultaneously
- Arpeggio: Already implemented with timing control
- Guide tones: Filter to 3rd + 7th before playback

**Voicing choices:**
- Close voicing (within one octave): Easier to hear quality
- Drop 2: More realistic jazz sound
- Spread voicing: Harder challenge

**Recommendation:** Start with close voicing for beginner/intermediate, add spread for advanced.

### Playback Timing

**Block Chord:**
```swift
// Already implemented
audioManager.playChord(chord.notes, style: .block)
```

**Arpeggio:**
```swift
// Already implemented with customizable delay
audioManager.playChord(chord.notes, style: .arpeggioUp)
```

**Guide Tones Only:**
```swift
let guideTones = chord.notes.filter { note in
    // Keep only 3rd and 7th
    let chordTone = chord.chordTone(for: note)
    return chordTone == .third || chordTone == .seventh
}
audioManager.playChord(guideTones, style: .block)
```
```

### Answer Distractor Strategy

**Chord Quality Recognition:**
Sonically similar chords work best as distractors:
- For Cmaj7, use: Cmaj6 (similar brightness), C7 (same root + 3rd), Cm7 (same structure, different 3rd)
- For Cm7, use: Cm7♭5 (same root + m3), Cmaj7 (same structure, different 3rd), C7 (similar function)
- Avoid: Cmaj7 vs. Cdim7 (too obviously different)

**Algorithm:**
```swift
func generateQualityDistractors(correctQuality: ChordQuality, difficulty: Difficulty) -> [ChordQuality] {
    switch difficulty {
    case .beginner:
        return [.major7, .minor7, .dominant7, .diminished7]
            .filter { $0 != correctQuality }
            .shuffled()
            .prefix(3)
    case .intermediate:
        return similarQualities(to: correctQuality, pool: intermediateQualities)
    case .advanced:
        return similarQualities(to: correctQuality, pool: allQualities)
    }
}

func similarQualities(to target: ChordQuality, pool: [ChordQuality]) -> [ChordQuality] {
    return pool
        .filter { $0 != target }
        .sorted { similarity($0, to: target) > similarity($1, to: target) }
        .prefix(3)
}
```

---

## Example User Flows

### Beginner Chord Ear Training

**Setup:**
- Difficulty: Beginner
- Question Types: Aural Quality
- Chord Types: maj7, m7, 7, dim7 only
- Playback: Block chord

**Question 1:**
1. Screen shows: "What chord quality do you hear?"
2. Audio plays: C-E-G-B (Cmaj7, block voicing)
3. Replay button with menu: "🔊 Play Chord" (tap for Block, Arpeggio, Guide Tones)
4. Answer choices:
   - Major 7 (maj7) ✓
   - Minor 7 (m7)
   - Dominant 7 (7)
   - Diminished 7 (dim7)
5. Student selects "Major 7"
6. ✅ "Correct! That's a Major 7 chord"
7. Piano keyboard shows C-E-G-B highlighted
8. Chord symbol "Cmaj7" appears
9. Click Next

---

## Success Metrics & Validation

### Quantitative Metrics
- **70%+ accuracy** on beginner chord qualities (maj7, m7, 7) after 5 sessions
- **60%+ accuracy** on intermediate qualities (m7♭5, dim7, sus4) after 10 sessions
- **Average response time < 15 seconds** for common qualities
- **Spaced repetition works:** Chords practiced 3+ times show 20%+ accuracy improvement

### Qualitative Feedback
- Students report "I can hear the difference between maj7 and dom7 now"
- Improved transcription speed (self-reported)
- Better comping choices on gigs

---

## Future Enhancements (Post-MVP)

### Phase 3 Additions
- **Context mode:** Hear chord within a ii-V-I progression
- **Comparison mode:** Hear two chords, identify the difference
- **Real recordings:** Use actual jazz recordings instead of MIDI

---

## Implementation Checklist

### Core Features
- [ ] Add `.auralQuality`, `.auralSpelling`, `.auralExtension` to `ChordQuestionType`
- [ ] Implement quality distractor generation in `QuizGame`
- [ ] Update `ChordDrillView` for ear training UI
- [ ] Add "Play Chord" menu button (Block, Arpeggio, Guide Tones)
- [ ] Create multiple-choice quality selector
- [ ] Add auto-play on question load (with toggle)

### Settings Integration
- [ ] Add "Chord Ear Training" section to SettingsView
- [ ] Toggle: Auto-play chords
- [ ] Picker: Default playback style
- [ ] Persist settings to UserDefaults

### Testing
- [ ] Test all difficulty levels
- [ ] Verify SR integration
- [ ] Test on real device

---

## Next Phase Preview

After Chord Ear Training, continue with **Cadence Ear Training** (already partially implemented):

- Fully implement hear ii–V–I → Identify cadence type (major/minor/tritone sub/backdoor)
- Hear progression → Spell each chord
- Real-world application combining interval + chord recognition skills
   - Same XP? Different XP?
   - **Recommendation:** 1.5x XP for aural (it's harder and more valuable)

---

**Ready to implement?** Let me know and I'll start building! 🎵

---

**Last Updated:** January 23, 2026  
**Status:** 🔶 Next Feature - Ready to Build
