# Next Feature: Interval Ear Training

**Current Status:** Phase 1 (Spaced Repetition) ✅ Complete  
**Next Up:** Phase 1 Final Component - Interval Ear Training  
**Priority:** High (completes Phase 1)  
**Estimated Time:** 4-6 hours

---

## Why This Feature Next?

### Pedagogical Reasoning

1. **Completes Phase 1:** This was planned as part of the initial SR implementation phase
2. **Foundation for all ear training:** Intervals are the building blocks of chords and progressions
3. **Already 80% built:** You have `IntervalModel.swift`, `IntervalGame.swift`, and `AudioManager.swift`
4. **High impact:** Ear training is the #1 missing skill in jazz students
5. **Natural progression:** Students can already spell intervals visually; now they learn to hear them

### What Students Gain

- **Hear intervals before seeing them** → critical for real-world playing
- **Recognize chord extensions by ear** → hear a maj9 and know it's a maj9
- **Better melodic dictation** → transcribe solos faster
- **Improved intonation** → singing intervals develops internal pitch
- **Transfer to all music** → intervals are universal across styles

---

## What Already Exists

✅ **IntervalModel.swift** - Complete data model:
- `IntervalType` with semitones, quality, difficulty
- `IntervalQuestionType` enum (includes `.auralIdentify`)
- `IntervalQuestion` struct
- `IntervalDatabase` with all common intervals

✅ **IntervalGame.swift** - Game logic:
- Quiz state management
- Question generation
- Answer checking
- Results tracking
- SR integration (already added!)

✅ **IntervalDrillView.swift** - UI for visual interval practice

✅ **AudioManager.swift** - Audio playback infrastructure:
- MIDI-based sound synthesis
- Single note playback
- Volume control
- Settings integration

---

## What Needs to Be Built

### 1. Audio Playback for Intervals (Primary Task)

**Add to AudioManager.swift:**

```swift
// Play two notes as an interval
func playInterval(
    _ interval: Interval,
    style: IntervalPlaybackStyle,
    completion: (() -> Void)? = nil
)

enum IntervalPlaybackStyle {
    case harmonic          // Both notes at once
    case melodicAscending  // First note, then second note (up)
    case melodicDescending // First note, then second note (down)
}
```

**Implementation:**
- Harmonic: Play both MIDI notes simultaneously
- Melodic: Play first note, wait 0.5s, play second note
- Use existing AVAudioEngine infrastructure
- Add tempo control (for melodic intervals)

### 2. Aural Question Flow in IntervalDrillView

**Current flow (visual):**
1. Show two notes on keyboard
2. User identifies the interval
3. Check answer

**New flow (aural):**
1. Play interval audio (harmonic or melodic)
2. Show "Play Again" button
3. User identifies the interval (multiple choice or keyboard selection)
4. Check answer
5. Show visual confirmation (highlight the interval on keyboard)

**UI Changes:**
```swift
if question.questionType == .auralIdentify {
    VStack {
        // Play button
        Button("🔊 Play Interval") {
            playCurrentInterval()
        }
        
        // Multiple choice answers
        ForEach(answerChoices) { choice in
            Button(choice.name) {
                submitAnswer(choice)
            }
        }
        
        // OR: Keyboard selection mode
        PianoKeyboard(
            selectedNotes: $selectedNotes,
            onNoteTapped: { note in
                // Select two notes to form interval
            }
        )
    }
}
```

### 3. Answer Generation for Aural Questions

**Multiple Choice Mode:**
- Generate 4 answer choices
- Include correct interval
- Add 3 plausible distractors (nearby intervals)
- Example: If answer is "Major 3rd", distractors could be "Minor 3rd", "Perfect 4th", "Major 2nd"

**Keyboard Selection Mode:**
- User selects two notes on keyboard
- App calculates interval between them
- Compare to correct answer

### 4. Settings Integration

**Add to SettingsView.swift:**

```swift
Section("Interval Ear Training") {
    Toggle("Play Intervals Automatically", isOn: $settings.autoPlayIntervals)
    
    Picker("Playback Style", selection: $settings.defaultIntervalStyle) {
        Text("Harmonic").tag(IntervalPlaybackStyle.harmonic)
        Text("Melodic Ascending").tag(.melodicAscending)
        Text("Melodic Descending").tag(.melodicDescending)
    }
    
    Slider(value: $settings.intervalTempo, in: 60...180) {
        Text("Tempo: \(Int(settings.intervalTempo)) BPM")
    }
}
```

### 5. Progressive Difficulty

**Beginner (start here):**
- Perfect 5th, Perfect 4th, Octave
- Major/Minor 3rds, Major/Minor 2nds
- Harmonic playback only (easier)

**Intermediate:**
- Major/Minor 6ths, Major/Minor 7ths
- Tritone
- Melodic playback

**Advanced:**
- Compound intervals (9th, 10th, etc.)
- Augmented/Diminished intervals
- Faster tempo, single playthrough

---

## Implementation Steps (Recommended Order)

### Step 1: Audio Playback (2 hours)

1. Add `playInterval()` method to `AudioManager.swift`
2. Implement harmonic playback first (simplest)
3. Add melodic ascending/descending
4. Test with various intervals (M3, P5, m7, etc.)

### Step 2: UI for Aural Mode (1.5 hours)

1. Detect `.auralIdentify` question type in `IntervalDrillView`
2. Add "Play Interval" button
3. Implement "Play Again" functionality
4. Show answer choices (multiple choice first)

### Step 3: Answer Generation (1 hour)

1. Create distractor generation logic
2. Ensure correct answer is randomly positioned
3. Test with various intervals

### Step 4: Settings & Preferences (0.5 hours)

1. Add interval ear training settings
2. Hook up to IntervalGame
3. Persist to UserDefaults

### Step 5: Polish & Testing (1 hour)

1. Add visual feedback after answer (show interval on keyboard)
2. Test across all difficulty levels
3. Verify SR integration works
4. Add encouragement messages

---

## Technical Details

### Audio Playback Strategy

**Option 1: AVAudioEngine + Sampler (Current approach)**
- Use existing AudioManager setup
- Play MIDI notes with slight delay for melodic
- Pros: Already implemented for single notes
- Cons: Synthesized sound quality varies

**Option 2: Pre-recorded Audio Files**
- Record real piano intervals
- Bundle as .wav/.m4a files
- Pros: Professional sound quality
- Cons: Large file size, harder to transpose

**Recommendation:** Start with Option 1 (MIDI/Sampler), can upgrade to Option 2 later.

### Playback Timing

**Harmonic:**
```swift
func playHarmonic(note1: Int, note2: Int) {
    audioEngine.play(midiNote: note1)
    audioEngine.play(midiNote: note2)
    // Both play simultaneously
}
```

**Melodic:**
```swift
func playMelodic(note1: Int, note2: Int, ascending: Bool) {
    let (first, second) = ascending ? (note1, note2) : (note2, note1)
    
    audioEngine.play(midiNote: first, duration: 1.0)
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        audioEngine.play(midiNote: second, duration: 1.0)
    }
}
```

### Answer Choice Generation

```swift
func generateDistractors(for correctInterval: IntervalType) -> [IntervalType] {
    let allIntervals = IntervalDatabase.shared.allIntervals
    let semitonesRange = (correctInterval.semitones - 2)...(correctInterval.semitones + 2)
    
    let distractors = allIntervals
        .filter { $0.semitones != correctInterval.semitones }
        .filter { semitonesRange.contains($0.semitones) }
        .shuffled()
        .prefix(3)
    
    return Array(distractors)
}
```

---

## Files to Create/Modify

### New Files
None! (All infrastructure exists)

### Files to Modify

1. **AudioManager.swift**
   - Add `playInterval()` method
   - Add `IntervalPlaybackStyle` enum
   - Handle tempo control

2. **IntervalDrillView.swift**
   - Add aural question UI
   - Add "Play Interval" button
   - Add multiple choice layout
   - Handle answer submission

3. **IntervalGame.swift**
   - Add distractor generation
   - Hook up audio playback
   - Handle aural question flow

4. **SettingsManager.swift**
   - Add ear training preferences
   - Default playback style
   - Auto-play toggle
   - Tempo setting

5. **IntervalModel.swift**
   - Possibly add `generateDistractors()` method (optional)

---

## Testing Plan

### Manual Testing

1. **Audio Playback:**
   - Play each interval type (P5, M3, m7, etc.)
   - Verify harmonic sounds correct
   - Verify melodic ascending/descending works
   - Test at different tempos

2. **Answer Choices:**
   - Verify correct answer is included
   - Verify distractors are plausible
   - Verify choices are randomized

3. **User Flow:**
   - Start aural interval drill
   - Play interval multiple times
   - Select answer
   - Verify feedback is clear
   - Complete full quiz

4. **SR Integration:**
   - Complete aural interval quiz
   - Check console for SR recording
   - Verify items scheduled correctly

### Edge Cases

- What happens if user changes playback style mid-quiz?
- Can user replay interval unlimited times?
- What if user submits before playing interval?
- Audio interruption (phone call, etc.)

---

## Success Criteria

✅ **Functional:**
- Students can hear intervals and identify them
- Multiple choice answers work correctly
- Audio playback is clear and reliable
- SR integration records aural practice

✅ **Pedagogical:**
- Students can distinguish M3 from m3 by ear
- Students improve accuracy over time
- Students report "hearing intervals in songs"

✅ **UX:**
- Audio plays quickly (<500ms delay)
- "Play Again" button is obvious
- Visual feedback confirms answer
- Settings are intuitive

---

## After This Feature

Once Interval Ear Training is complete, Phase 1 will be 100% done. The next phases are:

**Phase 2 Options:**
1. **Chord Ear Training** (hear chord → identify quality)
2. **Cadence Ear Training** (hear progression → identify type)

**Phase 3 Option:**
3. **Progression Drills** (turnarounds, rhythm changes)

**Recommendation:** Complete Chord Ear Training next to build on the interval ear foundation.

---

## Quick Start Command

When you're ready to start, I can:

1. Add `playInterval()` method to AudioManager
2. Implement aural question UI in IntervalDrillView
3. Add distractor generation logic
4. Wire up all the connections
5. Test and debug

**Estimated time:** 4-6 hours total (can be done in 2-3 sessions)

---

## Questions to Consider

1. **Multiple choice vs keyboard selection?**
   - Multiple choice is faster/easier
   - Keyboard selection is more challenging but builds stronger ear
   - **Recommendation:** Start with multiple choice, add keyboard mode later

2. **How many playbacks allowed?**
   - Unlimited? (easier, less pressure)
   - Limited (2-3 plays)? (more realistic, builds first-listen skills)
   - **Recommendation:** Start unlimited, add timed/limited mode later

3. **Scoring for aural vs visual?**
   - Same XP? Different XP?
   - **Recommendation:** 1.5x XP for aural (it's harder and more valuable)

---

**Ready to implement?** Let me know and I'll start building! 🎵

---

**Last Updated:** January 23, 2026  
**Status:** 🔶 Next Feature - Ready to Build
