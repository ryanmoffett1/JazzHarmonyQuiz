# Next Feature: Progression Drills

**Current Status:** Chord Ear Training ✅ Complete (Quality Recognition + Spelling)  
**Next Up:** Progression Drills (Turnarounds, Rhythm Changes, Blues, Standards)  
**Priority:** High (apply ear training to real music)  
**Estimated Time:** 8-10 hours

---

## What We Just Completed

✅ **Chord Ear Training** (January 24, 2026)
- Aural quality recognition with smart multiple-choice distractors
- Aural spelling with piano keyboard input
- Playback controls (block/arpeggio/guide tones)
- Similarity-based answer generation
- Complete SR integration

---

## Why Progression Drills Next?

### Pedagogical Reasoning

1. **Apply isolated skills to music:** Students can identify intervals and chords; now apply them to real progressions
2. **Most practical skill:** Turnarounds, ii-V-Is, and blues are the foundation of jazz repertoire
3. **Context is everything:** Chords sound different in context (ii vs. IV, V vs. I)
4. **Builds muscle memory:** Recognizing common progressions speeds up learning tunes
5. **Bridges practice → performance:** These progressions appear in every jazz standard

### What Students Gain

- **Instant pattern recognition** → hear ii-V-I and know exactly what's happening
- **Faster tune learning** → recognize rhythm changes, blues, turnarounds instantly
- **Better improvisation** → know where you are in the form at all times
- **Real-world application** → practice what you'll actually play on gigs
- **Harmonic vocabulary** → internalize the building blocks of jazz

---

## What Already Exists

✅ **ProgressionDatabase.swift** - Progression data model:
- Common jazz progressions (turnarounds, ii-V-I, etc.)
- Progression categorization system
- Ready for quiz integration

✅ **ProgressionGame.swift** - Game logic foundation:
- Quiz state management (may need updates)
- Question generation structure
- SR integration hooks

✅ **QuizGame.swift** - Core game mechanics:
- Quiz flow and timing
- Answer validation
- Results tracking
- Spaced repetition integration

✅ **AudioManager.swift** - Complete audio infrastructure:
- `playChord()` with multiple playback styles
- Sequential chord playback capability
- Tempo/timing control
- Already tested with chord ear training

---

## What Needs to Be Built

### 1. Progression Question Types

**Add to ProgressionModel.swift (or create if needed):**

```swift
enum ProgressionQuestionType: String, Codable, CaseIterable {
    case identifyProgression = "Identify Progression Type"     // NEW: ii-V-I, turnaround, etc.
    case spellProgression = "Spell All Chords"                 // NEW: Write each chord symbol
    case identifyFunction = "Identify Chord Function"          // NEW: Is this chord ii, V, or I?
    case missingChord = "Fill in Missing Chord"                // NEW: Complete the progression
}
```

### 2. Progression Playback

**Sequential chord playback:**
```swift
func playProgression(_ progression: Progression, style: ChordPlaybackStyle, tempo: BPM) {
    // Play chords in sequence with rhythmic timing
    // Each chord plays for specified duration (whole note, half note, etc.)
    // Visual indicator shows current chord position
}
```

**Example:** ii-V-I in C
1. Play Dm7 (2 beats)
2. Play G7 (2 beats)
3. Play Cmaj7 (4 beats)

### 3. UI for Progression Drills

**New ProgressionDrillView.swift:**

**For "Identify Progression" questions:**
- Play button with tempo control
- Visual indicator showing current chord (bar 1, bar 2, etc.)
- Multiple choice: "ii-V-I", "I-vi-ii-V", "Rhythm Changes A", "Blues"
- Replay with highlighting (shows which chord is playing)

**For "Spell Progression" questions:**
- Play button with playback controls
- Input for each chord in sequence
- Can replay individual chords or full progression
- Piano keyboard for spelling each chord

**For "Identify Function" questions:**
- Hear full progression
- Highlight plays on target chord
- Multiple choice: "I", "ii", "V", "IV", "vi", etc.

### 4. Progression Categories

**Organize by familiarity:**

**Beginner:**
- Major ii-V-I
- Minor ii-V-i
- I-vi-ii-V turnaround
- 12-bar blues

**Intermediate:**
- Rhythm Changes A section (I-vi-ii-V in 4 keys)
- Tritone substitution
- Backdoor ii-V
- Coltrane changes (simple)

**Advanced:**
- Rhythm Changes full form (with bridge)
- Giant Steps
- Countdown changes
- Modal progressions

### 5. Answer Validation

**Challenges:**
- Chord spelling: Dm7 = D-F-A-C, but also Dm9 = D-F-A-C-E
- Enharmonic equivalents: G# = Ab
- Extensions: Is Dm9 acceptable for Dm7?

**Solution:**
```swift
func validateChordInProgression(_ userAnswer: Chord, _ correctAnswer: Chord) -> Bool {
    // 1. Check root (with enharmonic equivalence)
    guard userAnswer.root.isEnharmonicWith(correctAnswer.root) else { return false }
    
    // 2. Check quality (exactly)
    guard userAnswer.quality == correctAnswer.quality else { return false }
    
    // 3. Allow extensions if base chord matches
    // Dm9 should be accepted for Dm7, but not Dm7 for Dm9
    return true
}
```

---

## Implementation Plan

### Step 1: Review & Update ProgressionGame (2 hours)

1. Read `ProgressionDatabase.swift` to understand current data structure
2. Check if `ProgressionGame.swift` exists and what it contains
3. Add progression question types if needed
4. Update game logic for progression-specific questions

### Step 2: Sequential Chord Playback (2 hours)

1. Extend `AudioManager` with `playProgression()` method
2. Implement tempo-based timing between chords
3. Add visual indicator for current chord position
4. Test with various tempos and progression lengths

### Step 3: Create/Update ProgressionDrillView (3 hours)

1. Create new view or update existing one
2. Implement progression playback controls
3. Add question type UI:
   - Multiple choice for "Identify Progression"
   - Chord input sequence for "Spell Progression"
   - Function identification UI
4. Add visual feedback (highlight current chord)

### Step 4: Answer Validation Logic (1 hour)

1. Implement progression matching algorithm
2. Handle enharmonic equivalents
3. Decide on extension tolerance (Dm9 vs Dm7)
4. Add partial credit for spelling questions

### Step 5: Integration & Testing (2 hours)

1. Connect to main navigation
2. Verify SR integration
3. Test all question types
4. Test across difficulty levels
5. Polish UI and transitions

---

## Example User Flows

### Beginner: Identify ii-V-I Progression

**Setup:**
- Difficulty: Beginner
- Question Type: Identify Progression
- Tempo: Medium (120 BPM)

**Question Flow:**
1. Screen shows: "What progression do you hear?"
2. Audio plays: Dm7 → G7 → Cmaj7 (2-2-4 beats)
3. Visual indicator shows | ● | ○ | ○ | moving through chords
4. Replay button with "🔊 Play Again"
5. Answer choices:
   - ii-V-I ✓
   - I-vi-ii-V
   - I-IV-V
   - Blues Progression
6. Student selects "ii-V-I"
7. ✅ "Correct! That's a ii-V-I in C major"
8. Screen shows chord symbols: Dm7 - G7 - Cmaj7
9. Click Next

### Intermediate: Spell Turnaround

**Setup:**
- Difficulty: Intermediate
- Question Type: Spell Progression
- Progression: I-vi-ii-V turnaround

**Question Flow:**
1. Screen shows: "Spell each chord in this progression"
2. Audio plays: Cmaj7 → Am7 → Dm7 → G7
3. Input fields for 4 chords with play buttons for each
4. Student enters: Cmaj7, Am7, Dm7, G7
5. ✅ "Perfect! All chords correct"
6. Shows Roman numeral analysis: Imaj7 - vim7 - iim7 - V7

---

## Success Metrics & Validation

### Quantitative Metrics
- **80%+ accuracy** on basic progressions (ii-V-I, turnarounds) after 5 sessions
- **70%+ accuracy** on intermediate progressions (rhythm changes, blues) after 10 sessions
- **Average response time < 20 seconds** for common progressions
- **Spaced repetition works:** Progressions practiced 3+ times show 20%+ accuracy improvement

### Qualitative Feedback
- Students report "I instantly recognize turnarounds now"
- Faster tune learning (can hear the form)
- Better navigation during improvisation

---

## Future Enhancements (Post-MVP)

### Phase 2 Additions
- **Custom progressions:** Let students input their own progressions from tunes they're learning
- **Tune recognition:** Hear progression → identify the standard ("Autumn Leaves", "Giant Steps", etc.)
- **Voice leading:** Focus on bass movement and guide tone lines
- **Real recordings:** Use actual jazz recordings instead of MIDI

---

## Implementation Checklist

### Core Features
- [ ] Review ProgressionDatabase.swift and ProgressionGame.swift
- [ ] Add progression question types (identify, spell, function)
- [ ] Implement `playProgression()` in AudioManager
- [ ] Create/update ProgressionDrillView UI
- [ ] Add multiple choice for progression identification
- [ ] Add chord sequence input for spelling
- [ ] Implement visual playback indicator

### Audio & Timing
- [ ] Sequential chord playback with tempo control
- [ ] Visual indicator for current chord
- [ ] Replay controls (full progression or individual chords)
- [ ] Tempo settings integration

### Answer Validation
- [ ] Progression matching algorithm
- [ ] Enharmonic equivalence handling
- [ ] Extension tolerance policy
- [ ] Partial credit for spelling

### Testing
- [ ] Test all progression types (ii-V-I, turnarounds, blues, rhythm changes)
- [ ] Verify SR integration
- [ ] Test across all difficulty levels
- [ ] Test on real device

---

**Ready to implement?** This builds on all the ear training work we've done and applies it to real musical contexts! 🎵

---

**Last Updated:** January 24, 2026  
**Status:** 🔶 Next Feature - Ready to Build
**Previous Feature:** Chord Ear Training (✅ Complete)
