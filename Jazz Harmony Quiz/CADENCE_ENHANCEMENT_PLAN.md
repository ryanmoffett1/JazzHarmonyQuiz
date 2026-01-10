# Cadence Drill Enhancement Plan

**Created:** January 10, 2026  
**Goal:** Increase students' ability to spell jazz chords through speed and accuracy

---

## Current Implementation

- Major ii-V-I (iim7, V7, Imaj7)
- Minor ii-V-I (iiø7, V7b9, im7) - **Updated Jan 2026**: V7b9 used 80% of the time
- Users spell all 3 chords in a progression
- Quiz tracks accuracy and time
- Leaderboard for results

---

## Phase 1: Low Effort, High Impact ✅ COMPLETE

### 1.1 Isolated Chord Focus Mode ✅
- [x] Add `CadenceDrillMode` enum with `fullProgression` and `isolatedChord` options
- [x] Allow user to select which chord position to drill (ii, V, or I)
- [x] Generate questions that only quiz the selected chord across all keys
- **Benefit:** Deep mastery of one chord type before combining

### 1.2 Key Difficulty Tiers ✅
- [x] Add `KeyDifficulty` enum: `easy` (C, F, G), `medium` (Bb, Eb, D, A), `hard` (Ab, Db, E, B), `expert` (F#/Gb)
- [x] Allow user to select difficulty tier in setup
- [x] Filter root notes based on selected difficulty
- **Benefit:** Progressive accidental fluency

### 1.3 Daily Challenge ✅
- [x] Generate deterministic daily challenge using date as seed
- [x] Same cadence/key combination for all users each day
- [x] Separate "Daily Challenge" button in setup view
- **Benefit:** Competition and routine building

### 1.4 Streak Counter ✅
- [x] Track consecutive days practiced
- [x] Persist to UserDefaults
- [x] Display streak in UI with 🔥 emoji
- **Benefit:** Habit building motivation

### 1.5 Progressive Hints ✅
- [x] Add hint system with 3 levels: formula → intervals → first note
- [x] Track hints used per question
- [x] Apply accuracy penalty for hint usage (75%/50%/25% credit)
- **Benefit:** Self-guided learning without giving up

---

## Phase 2: Medium Effort ✅ COMPLETE

### 2.1 Tritone Substitution Cadence ✅
- [x] Add `CadenceType.tritoneSubstitution`
- [x] Formula: iim7 → bII7 (SubV7) → Imaj7
- **Teaches:** Chromatic bass movement, altered dominant sounds

### 2.2 Backdoor ii-V Cadence ✅
- [x] Add `CadenceType.backdoor`
- [x] Formula: ivm7 → bVII7 → Imaj7
- **Teaches:** Alternative resolution paths common in jazz standards

### 2.3 Speed Round Mode ✅
- [x] Add `CadenceDrillMode.speedRound`
- [x] Configurable timer per chord (3-15 seconds)
- [x] Auto-submit when timer expires
- [x] Visual timer with progress bar and warning state
- **Teaches:** Fast recall under pressure

### 2.4 Mixed Cadences Option ✅
- [x] Toggle to enable mixed mode
- [x] Multi-select cadence types to include
- [x] Random selection from chosen types during quiz
- **Teaches:** Context switching between cadence types

### 2.5 Mistake Review Drill ✅
- [x] After quiz completion, option to re-drill only missed chords
- [x] "Drill Missed Chords" button in results view
- [x] Shows count of missed questions
- **Teaches:** Targeted improvement on weak areas

---

## Phase 3: Higher Effort ✅ COMPLETE

### 3.1 Extended V Chord Options ✅
- [x] Add V9, V13, V7b9, V7#9 as configurable options
- [x] Toggle to enable extended V chords in setup
- [x] Picker to select which extended V chord type to use
- **Teaches:** Upper structure chord spelling

### 3.2 Common Tone Quiz Mode ✅
- [x] Add `CadenceDrillMode.commonTones`
- [x] Add `CommonTonePair` enum (ii→V, V→I, Random)
- [x] Chord struct method to find common tones
- [x] Updated UI to show two chords and ask for shared notes
- **Teaches:** Voice leading awareness

### 3.3 Bird Changes Cadence ✅
- [x] Add `CadenceType.birdChanges`
- [x] Formula: iiim7 → VI7 → iim7 → V7 → Imaj7
- [x] Updated UI to handle 5 chords instead of 3
- **Teaches:** Extended turnarounds (Confirmation changes)

### 3.4 Audio Playback ✅
- [x] Create AudioManager with AVFoundation
- [x] Play chord audio when answered correctly
- [x] Audio settings in SettingsView (enable/disable, volume)
- [x] Test sound button in settings
- **Teaches:** Ear-theory connection

---

## Phase 4: Polish & Quality of Life ✅ COMPLETE

### 4.1 Statistics Tracking ✅
- [x] Track lifetime questions answered
- [x] Track overall accuracy percentage
- [x] Track stats per cadence type
- [x] Track stats per key
- [x] Display stats in setup view header
- **Benefit:** Progress visibility and motivation

### 4.2 Quick Practice Mode ✅
- [x] One-tap "Quick Practice" button for rapid 5-question session
- [x] Uses last quiz settings automatically
- [x] Saves settings after each quiz
- [x] Minimal setup friction
- **Benefit:** Reduces friction for quick practice sessions

### 4.3 Personal Best Infrastructure ✅
- [x] Data structure for tracking personal bests per cadence/key combo
- [x] Method to check and update personal bests
- **Benefit:** Foundation for PB celebrations (UI can be added later)

### 4.4 Chord Voicing Display ✅
- [x] ChordVoicingView component shows mini piano with highlighted notes
- [x] Visual feedback for learning correct chord shapes
- **Benefit:** Visual reinforcement of chord voicings

---

## Phase 5: Learning & UX Polish ✅ COMPLETE

### 5.1 Encouragement Messages ✅
- [x] Show contextual encouragement based on performance
- [x] Celebrate milestones (first perfect score, 100/500/1000 questions, 10 quizzes)
- [x] Motivational messages on streak milestones (3, 7, 14, 30, 100 days)
- [x] Different message types: celebration, positive, encouraging, milestone
- **Benefit:** Emotional engagement and motivation

### 5.2 Weak Key Detection ✅
- [x] Analyze stats to identify weakest keys (lowest accuracy with 5+ attempts)
- [x] Display weak keys in "Practice Weak Keys" button
- [x] "Practice Weak Keys" quick action generates focused practice
- [x] Also tracks strongest keys and under-practiced keys
- **Benefit:** Targeted improvement on problem areas

### 5.3 Session Summary ✅
- [x] Show encouragement based on performance in results
- [x] Display milestone celebrations when achieved
- [x] Streak milestone messages
- **Benefit:** Progress visibility and celebration

### 5.4 Haptic Feedback ✅
- [x] Success haptic on correct answer
- [x] Error haptic on incorrect answer
- [x] Medium haptic on next chord
- [x] Light haptic on clear selection
- **Benefit:** Tactile feedback enhances learning

---

## Implementation Notes

### Key Difficulty Tiers Definition
```swift
enum KeyDifficulty: String, CaseIterable {
    case easy = "Easy"      // C, F, G (0-1 accidentals)
    case medium = "Medium"  // Bb, Eb, D, A (2-3 accidentals)
    case hard = "Hard"      // Ab, Db, E, B (4-5 accidentals)
    case expert = "Expert"  // F#/Gb (6 accidentals)
    case all = "All Keys"
}
```

### Daily Challenge Seeding
```swift
// Use date components to create deterministic seed
let calendar = Calendar.current
let components = calendar.dateComponents([.year, .month, .day], from: Date())
let seed = (components.year! * 10000) + (components.month! * 100) + components.day!
```

### Hint Levels
1. **Formula Hint:** "m7 = R - m3 - 5 - m7"
2. **Interval Hint:** "Root + 3 semitones + 7 semitones + 10 semitones"
3. **First Note Hint:** "Starts on D"

---

## Progress Tracking

| Feature | Status | Date Completed |
|---------|--------|----------------|
| V7b9 for minor ii-V-I | ✅ Done | Jan 10, 2026 |
| CadenceDrillMode enum | ✅ Done | Jan 10, 2026 |
| IsolatedChordPosition enum | ✅ Done | Jan 10, 2026 |
| KeyDifficulty enum | ✅ Done | Jan 10, 2026 |
| Daily Challenge | ✅ Done | Jan 10, 2026 |
| Streak Counter | ✅ Done | Jan 10, 2026 |
| Progressive Hints | ✅ Done | Jan 10, 2026 |
| Updated CadenceSetupView | ✅ Done | Jan 10, 2026 |
| Updated ActiveCadenceQuizView | ✅ Done | Jan 10, 2026 |
| Tritone Substitution | ✅ Done | Jan 10, 2026 |
| Backdoor ii-V | ✅ Done | Jan 10, 2026 |
| Speed Round Mode | ✅ Done | Jan 10, 2026 |
| Mixed Cadences | ✅ Done | Jan 10, 2026 |
| Mistake Review Drill | ✅ Done | Jan 10, 2026 |
| Extended V Chords (V9, V13, V7b9, V7#9) | ✅ Done | Jan 10, 2026 |
| Bird Changes | ✅ Done | Jan 10, 2026 |
| Lifetime Statistics Tracking | ✅ Done | Jan 10, 2026 |
| Quick Practice Mode | ✅ Done | Jan 10, 2026 |
| Personal Best Infrastructure | ✅ Done | Jan 10, 2026 |
| Encouragement Messages | ✅ Done | Jan 10, 2026 |
| Weak Key Detection | ✅ Done | Jan 10, 2026 |
| Haptic Feedback | ✅ Done | Jan 10, 2026 |
| Common Tone Quiz | ✅ Done | Jan 10, 2026 |
| Audio Playback | ✅ Done | Jan 10, 2026 |
| Chord Voicing Display | ✅ Done | Jan 10, 2026 |