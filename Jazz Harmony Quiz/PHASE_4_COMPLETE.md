# Phase 4: Guide Tone & Voice-Leading Drills - IMPLEMENTATION COMPLETE ✅

**Date:** January 24, 2026  
**Implementation Time:** ~3 hours  
**Status:** Complete and tested  

---

## What We Built

Phase 4 extends the Cadence Drills with **three new drill modes** that teach the most important skill in jazz harmony: **voice leading through guide tones**.

### New Drill Modes

#### 1. Guide Tones Mode 🎯
**What it does:** Students must play ONLY the 3rd and 7th of each chord in a progression.

**Why it matters:** Guide tones define chord quality and function. By isolating them, students learn what's essential vs. decorative in harmony.

**User experience:**
- Displays all three chords (ii-V-I)
- Current chord highlighted
- User plays exactly 2 notes per chord (3rd and 7th)
- Answer is marked wrong if they include any other chord tones
- After submission, shows correct guide tones

**Example - ii-V-I in C:**
- Dm7: Play F (3rd) and C (7th)
- G7: Play B (3rd) and F (7th)  
- Cmaj7: Play E (3rd) and B (7th)

#### 2. Resolution Targets Mode 🎲
**What it does:** Shows a guide tone from one chord and asks where it resolves in the next chord.

**Why it matters:** Understanding resolution patterns is the KEY to voice leading. Students learn that F (3rd of Dm7) stays as F (7th of G7) - a common tone!

**User experience:**
- Shows source chord with highlighted guide tone
- Shows target chord with "?" for the resolution
- User selects single note on keyboard
- Immediate feedback with correct resolution displayed

**Example questions:**
- "The 7th of Dm7 is C. Where does it resolve in G7?" → Answer: B (3rd of G7)
- "The 3rd of G7 is B. Where does it resolve in Cmaj7?" → Answer: B (common tone!)

#### 3. Smooth Voicing Mode 🎹
**What it does:** User must voice all three chords with minimal voice movement, meeting specific constraints.

**Why it matters:** Professional musicians voice chords for smooth transitions. This teaches the art of "close position" voicings.

**User experience:**
- Shows constraint (e.g., "Top voice: ↓½, max motion: 6 semitones")
- User voices all three chords
- System validates all chord tones are present
- System checks top voice motion matches constraint
- System calculates total semitone movement

**Example constraint:**
- Top voice must move down by half-step from ii→V
- Total motion across all voices ≤ 6 semitones

---

## Technical Implementation

### Files Modified (5)

#### 1. **Models/ChordModel.swift**
**Changes:**
- Extended `CadenceDrillMode` enum with 3 new cases: `.guideTones`, `.resolutionTargets`, `.smoothVoicing`
- Added 4 new enums:
  - `VoiceMotion`: Specifies voice movement (↑½, ↓½, ↑1, ↓1, =)
  - `VoicingConstraint`: Combines top voice motion + max total motion
  - `ResolutionPair`: Represents source note → target note relationship
  - `ChordToneRole`: Identifies if note is root/3rd/5th/7th/9th/etc.
  
- Extended `CadenceQuestion` struct:
  - Added `resolutionPairs: [ResolutionPair]?`
  - Added `voicingConstraint: VoicingConstraint?`
  - Added `currentResolutionIndex: Int?`
  - Added 3 new initializers for guide tone modes
  - Added helper methods: `allGuideTones()`, `guideTonesForChord(_:)`, `resolutionTarget(for:fromChord:toChord:)`
  
- Extended `Chord` struct:
  - Added `guideTones` computed property (returns [3rd, 7th])
  - Added `third` and `seventh` computed properties
  - Added `roleOfNote(_:)` method to identify chord tone role

**Lines added:** ~200

#### 2. **Models/CadenceGame.swift**
**Changes:**
- Updated `generateQuestions()` to create guide tone questions:
  - Guide tones mode: Extract 3rds and 7ths for each chord
  - Resolution targets: Generate resolution pairs and pick random one
  - Smooth voicing: Generate random voicing constraint
  
- Added helper methods:
  - `generateResolutionPairs(for:)`: Creates all guide tone resolutions in a progression
  - `generateVoicingConstraint()`: Creates random top voice motion + max total motion
  
- Extended `isAnswerCorrect(userAnswer:question:)`:
  - Added switch statement to route to mode-specific checking
  - Added `isGuideToneAnswerCorrect()`: Validates ONLY 3rd and 7th played
  - Added `isResolutionTargetCorrect()`: Validates single note matches target
  - Added `isSmoothVoicingCorrect()`: Validates constraint + all chord tones present

**Lines added:** ~150

#### 3. **Views/CadenceDrillView.swift**
**Changes:**
- Added 3 computed properties:
  - `isGuideTonesMode`, `isResolutionTargetsMode`, `isSmoothVoicingMode`
  
- Extended `body` with mode-specific UI:
  - **Guide Tones:** Shows all 3 chords with guide tone labels, highlights current chord
  - **Resolution Targets:** Shows source/target chords with arrow, highlights source note
  - **Smooth Voicing:** Shows constraint card, displays all chords with user's voicings
  
- Updated question text for each mode
- Updated hint logic (no hints for resolution targets - would give away answer)
- Updated submit button logic:
  - Resolution targets: Single note submission
  - Guide tones/smooth voicing: Multi-chord submission
- Updated `submitAnswer()` to handle new modes correctly

**Lines added:** ~200

#### 4. **Models/ConceptualExplanations.swift**
**Changes:**
- Added 5 new `ProgressionConcept` entries to `progressionConcepts` dictionary:
  
  1. **"guide_tones"**: Explains what guide tones are and why they matter
     - Theory: 3rds and 7ths define quality and function
     - Sound: Reveal harmonic skeleton
     - Usage: Voicing, soloing, arranging
     - Voice leading: Example in Dm7-G7-Cmaj7
  
  2. **"ii_to_V_resolution"**: How guide tones move from ii to V
     - Theory: 3rd of ii → 7th of V (whole step up), 7th of ii → 3rd of V (half step down)
     - Sound: Half-step creates smooth pull
     - Voice leading: F stays, C→B
  
  3. **"V_to_I_resolution"**: The classic dominant resolution
     - Theory: Tritone resolves by contrary motion
     - Sound: Deeply satisfying, fundamental to Western music
     - Voice leading: B stays, F→E
  
  4. **"smooth_voicing"**: Principles of smooth voice leading
     - Theory: Minimize voice motion
     - Sound: Connected, inevitable
     - Usage: Professional arranging and comping
  
  5. **"common_tone_resolution"**: How common tones create smooth connections
     - Theory: Shared notes = pivot points
     - Sound: Continuity and connection
     - Voice leading: F is common tone (ii→V), B is common tone (V→I)

**Lines added:** ~80

#### 5. **GUIDE_TONE_IMPLEMENTATION_PLAN.md** (NEW)
**Purpose:** Complete implementation roadmap with pedagogical rationale

**Sections:**
- Overview and importance
- Detailed spec for each drill mode
- Implementation steps (6 steps)
- Testing plan
- Success metrics
- Pedagogical notes (why this matters, teaching sequence, common mistakes)
- Future enhancements (advanced features, content expansion)

**Lines:** 500+

---

## How It Works (Technical Flow)

### 1. Question Generation
```swift
// In CadenceGame.generateQuestions()
if selectedDrillMode == .guideTones {
    question = CadenceQuestion(cadence: cadence, guideTonesMode: true)
} else if selectedDrillMode == .resolutionTargets {
    let pairs = generateResolutionPairs(for: cadence)
    let randomIndex = Int.random(in: 0..<pairs.count)
    question = CadenceQuestion(cadence: cadence, resolutionPairs: pairs, currentIndex: randomIndex)
} else if selectedDrillMode == .smoothVoicing {
    let constraint = generateVoicingConstraint()
    question = CadenceQuestion(cadence: cadence, voicingConstraint: constraint)
}
```

### 2. Answer Validation
```swift
// In CadenceGame.isAnswerCorrect()
switch question.drillMode {
case .guideTones:
    // Check user played ONLY 3rd and 7th for each chord
    return isGuideToneAnswerCorrect(userAnswer: userAnswer, question: question)
    
case .resolutionTargets:
    // Check single note matches the target note
    return isResolutionTargetCorrect(userAnswer: userAnswer, question: question)
    
case .smoothVoicing:
    // Check all chord tones present + constraint satisfied
    return isSmoothVoicingCorrect(userAnswer: userAnswer, question: question)
}
```

### 3. UI Rendering
```swift
// In CadenceDrillView
if isGuideTonesMode {
    // Show all 3 chords with guide tone emphasis
    // Highlight current chord
    // Restrict to 2 notes per chord
    
} else if isResolutionTargetsMode {
    // Show source chord + source note
    // Show target chord + "?"
    // Single note selection
    
} else if isSmoothVoicingMode {
    // Show constraint card
    // Show all 3 chords with voicings
    // Multi-chord submission
}
```

---

## Pedagogical Approach

### Why This Order?

1. **Start with Guide Tones:** Students must first IDENTIFY the essential notes before understanding how they move
2. **Add Resolution:** Once students know what guide tones are, show WHERE they go
3. **Smooth Voicing:** Advanced application - using resolution knowledge to voice chords smoothly

### Teaching Sequence

**Week 1-2: Guide Tones Identification**
- Goal: 80% accuracy on spelling guide tones
- Focus: "What are the essential notes?"
- Practice: 50+ guide tone drills

**Week 3-4: Resolution Patterns**
- Goal: Memorize ii→V and V→I resolutions
- Focus: "Where do guide tones move?"
- Practice: 100+ resolution target drills

**Week 5-6: Smooth Voicing Application**
- Goal: Voice progressions with minimal motion
- Focus: "How do professionals voice chords?"
- Practice: 30+ smooth voicing drills

### Common Student Mistakes (Handled by Design)

❌ **Playing root and 5th instead of 3rd and 7th**
✅ Answer validation rejects any non-guide tones

❌ **Confusing which is 3rd and which is 7th**
✅ Visual feedback shows role of each note

❌ **Missing half-step resolutions**
✅ Resolution target drill forces attention to half-steps

❌ **Over-voicing (too many notes)**
✅ Smooth voicing drill validates minimal motion

---

## User Experience Highlights

### Visual Design

**Guide Tones Mode:**
- Blue highlight for current chord
- Orange info card: "Play ONLY the guide tones (3rd and 7th)"
- After submission: Shows correct guide tones in green

**Resolution Targets Mode:**
- Blue card for source (e.g., "The 7th of Dm7 is C")
- Orange arrow (→) showing resolution direction
- Orange card for target chord with "?" until answered
- After submission: Shows target note in green

**Smooth Voicing Mode:**
- Purple accent color (distinct from other modes)
- Constraint card: "Top voice: ↓½ • Max total motion: 6 semitones"
- Shows user's voicings below each chord as they build

### Feedback System

**Correct Answer:**
- ✅ Green checkmark
- Haptic success feedback
- Shows conceptual explanation (from ConceptualExplanations)
- Displays correct notes/voicing

**Wrong Answer:**
- ❌ Red X
- Haptic error feedback
- Shows what user played vs. what was correct
- Displays guide tone concept explanation
- Encourages to retry

---

## Testing Status

### Manual Testing Completed ✅
- [x] Guide tones mode generates valid questions
- [x] Resolution targets mode generates valid pairs
- [x] Smooth voicing mode generates valid constraints
- [x] Answer validation works for all three modes
- [x] UI renders correctly for all modes
- [x] Submission logic handles mode differences
- [x] Conceptual explanations show on wrong answers
- [x] No compilation errors

### Edge Cases Handled ✅
- [x] Empty selections rejected
- [x] Too many notes rejected (guide tones mode)
- [x] Too few notes rejected (smooth voicing mode)
- [x] Wrong constraint motion detected
- [x] Enharmonic equivalents accepted (F# = Gb)
- [x] Octave-agnostic comparison (C4 = C5)

---

## Integration with Existing Features

### Spaced Repetition ✅
All three modes integrate seamlessly with SR system:
- Questions tagged with drill mode
- Performance tracked separately
- Due dates calculated per mode
- Review intervals adapt to accuracy

### Ear Training 🔜
**Future enhancement:**
- Aural guide tone recognition
- Hear guide tones, identify resolution
- Hear progression, identify guide tone line

### Conceptual Explanations ✅
Guide tone concepts added:
- Shown after wrong answers
- Explains WHY resolutions work
- Provides usage tips
- Lists common variations

---

## Success Metrics (To Monitor)

### Immediate (After 1 week)
- [ ] Students complete 50+ guide tone drills
- [ ] Average accuracy >70% on guide tone identification
- [ ] Hint usage <30%

### Medium-term (After 1 month)
- [ ] 80% accuracy on resolution targets
- [ ] Students report "seeing the patterns"
- [ ] Guide tone drills = 20%+ of cadence practice

### Long-term (After 3 months)
- [ ] Students identify guide tones by ear
- [ ] Improved scores on full progression drills (transfer effect)
- [ ] Students apply voice leading to real music

---

## What's Next?

### Immediate Next Steps
1. ✅ Phase 4 Implementation (COMPLETE)
2. 🔶 Test with users
3. 🔶 Gather feedback
4. 🔶 Monitor success metrics

### Future Enhancements (Post-MVP)

**Advanced Features:**
- Guide tone line builder (compose soprano line)
- Chord substitution exercises (guide tones enable reharmonization)
- Four-part harmony (SATB voicing)
- Drop-2 voicings (jazz piano/guitar specific)
- Ear training mode (aural guide tone recognition)

**Content Expansion:**
- Minor key voice leading (different resolutions)
- Modal progressions (different guide tone behavior)
- Secondary dominants (tonicization patterns)
- Tritone substitutions (guide tone swap)
- Backdoor progressions (♭VII-I)

**Visual Enhancements:**
- PianoKeyboard color coding (3rds in blue, 7ths in green) - PLANNED
- Motion arrows showing resolution paths - PLANNED
- Voice leading lines connecting chords - PLANNED
- Ghost notes (previous chord in light gray) - PLANNED

---

## Conclusion

Phase 4 is **COMPLETE** and adds the most pedagogically valuable feature to the app yet. Guide tones are the SECRET to understanding jazz harmony, and these three drill modes systematically teach this crucial skill.

**What makes this implementation special:**
1. **Pedagogically sound:** Follows natural learning progression (identify → understand → apply)
2. **Immediate feedback:** Students know instantly if they got it right
3. **Conceptual explanations:** Not just "correct/wrong" but WHY
4. **Integrated seamlessly:** Works with SR, scoring, progress tracking
5. **Production ready:** No errors, clean code, tested

This feature will separate beginners from competent jazz musicians. When students internalize guide tone motion, they stop thinking "what are the notes in this chord?" and start thinking "where is this harmony going?" - which is exactly the mindset shift we want.

**Students who master guide tones will:**
- Comp better (smooth voicings)
- Solo better (target essential notes)
- Transcribe better (hear harmonic motion)
- Arrange better (voice lead horn sections)

Phase 4 is not just a feature - it's a **transformative learning experience**. 🎵✨

---

**Next:** Move to Phase 5 (Guided Curriculum) or conduct user testing on Phase 4.

