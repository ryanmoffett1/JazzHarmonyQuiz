# Chord Drill Enhancement Plan

**Created:** January 10, 2026  
**Goal:** Elevate the chord drill feature to match cadence mode quality, with filtering options, progress tracking, ratings, and an engaging rank system.

---

## Current State

- Basic chord drill with difficulty levels (beginner → expert)
- Question types: Single Tone, All Tones, Chord Spelling
- Simple leaderboard (top 10)
- No filtering by chord type or key
- No daily challenge
- No streak tracking
- No rating/rank system

---

## Phase 1: Filtering & Selection Options

### 1.1 Chord Type Filtering
- [ ] Add `ChordTypeCategory` enum (Triads, 7ths, Extensions, Altered, All)
- [ ] Allow user to select specific chord types to drill
  - Major, Minor, Diminished, Augmented (Triads)
  - maj7, m7, 7, m7b5, dim7 (7th chords)
  - 9, m9, maj9, 11, 13 (Extensions)
  - 7b9, 7#9, 7alt, etc. (Altered)
- [ ] Multi-select UI with categories
- **Benefit:** Focused practice on specific chord qualities

### 1.2 Key/Root Filtering
- [ ] Add key selection (same `KeyDifficulty` tiers as cadence mode)
  - Easy: C, F, G
  - Medium: Bb, Eb, D, A
  - Hard: Ab, Db, E, B
  - Expert: F#/Gb
  - All Keys
- [ ] Option to select specific root notes
- **Benefit:** Progressive key mastery

### 1.3 Question Type Enhancements
- [ ] Add "Chord Symbol Reading" - show chord, spell it
- [ ] Add "Reverse" mode - show notes, name the chord
- [ ] Add "Interval Identification" - identify specific intervals in chord
- **Benefit:** Multiple ways to test knowledge

---

## Phase 2: Daily Challenge & Streaks

### 2.1 Daily Challenge
- [ ] Deterministic daily challenge using date seed
- [ ] Fixed configuration each day (same for all users)
- [ ] Special "Daily Challenge" badge/indicator
- [ ] Track daily challenge completions separately
- **Benefit:** Routine building, competition

### 2.2 Streak System
- [ ] Track consecutive days practiced
- [ ] Display streak with 🔥 emoji
- [ ] Streak milestones (3, 7, 14, 30, 100 days)
- [ ] Persist to UserDefaults
- **Benefit:** Habit formation

### 2.3 Practice Log
- [ ] Log each practice session (date, duration, accuracy, chords practiced)
- [ ] Weekly/monthly summary views
- [ ] Track total chords drilled, total time spent
- **Benefit:** Progress visibility

---

## Phase 3: Rating & Rank System

### 3.1 Rating Calculation
- [ ] Implement Elo-like rating system (start at 1000)
- [ ] Rating changes based on:
  - Accuracy (more points for higher accuracy)
  - Difficulty level (harder = more points)
  - Speed (bonus for fast correct answers)
  - Streak bonus (consecutive correct answers)
- [ ] Rating persisted to UserDefaults

### 3.2 Rank Titles (Jazz-Themed, Encouraging)
Ranks should be fun, jazz-themed, and encouraging:

| Rating Range | Rank Title | Emoji |
|-------------|------------|-------|
| 0-500 | Shed Rat | 🐀 |
| 501-750 | Practice Room Regular | 🎹 |
| 751-1000 | Jam Session Ready | 🎤 |
| 1001-1250 | Gigging Musician | 🎷 |
| 1251-1500 | Session Cat | 🐱 |
| 1501-1750 | Bebop Scholar | 📚 |
| 1751-2000 | Harmony Hipster | 😎 |
| 2001-2250 | Chord Wizard | 🧙 |
| 2251-2500 | Voicing Virtuoso | ✨ |
| 2501-2750 | Jazz Elder | 🎩 |
| 2751-3000 | Harmony Master | 👑 |
| 3001+ | Living Legend | 🌟 |

### 3.3 Rank Progression
- [ ] Show current rank prominently on home screen
- [ ] Animate rank changes
- [ ] "Next rank in X points" progress indicator
- [ ] Celebration when ranking up
- **Benefit:** Gamification, motivation

---

## Phase 4: Home Screen / Landing Page

### 4.1 Stats Dashboard
Display at top of home screen:
- [ ] Current rating and rank (with emoji)
- [ ] Current streak 🔥
- [ ] Today's practice: X chords, Y% accuracy
- [ ] This week: total chords, avg accuracy, time spent

### 4.2 Quick Actions
- [ ] "Quick Practice" - 5 chords with last settings
- [ ] "Daily Challenge" - prominent button
- [ ] "Practice Weak Areas" - auto-select struggling chord types/keys

### 4.3 Progress Cards
- [ ] "Strongest Chord Types" card
- [ ] "Needs Work" card (lowest accuracy areas)
- [ ] "Recent Activity" feed
- [ ] Weekly goal progress (e.g., "Practice 7 days this week")

### 4.4 Achievements/Badges
- [ ] First Perfect Score
- [ ] 100 Chords Drilled
- [ ] 7-Day Streak
- [ ] Master of [Chord Type]
- [ ] All Keys Conquered
- **Benefit:** Long-term goals

---

## Phase 5: Audio & Feedback Enhancements

### 5.1 Chord Playback
- [ ] Play chord on correct answer (like cadence mode)
- [ ] Option to hear chord before answering (ear training mode)
- [ ] Use user's entered voicing for playback

### 5.2 Haptic Feedback
- [ ] Success/error haptics (already in cadence mode)
- [ ] Apply to chord drill

### 5.3 Encouragement System
- [ ] Contextual messages based on performance
- [ ] Milestone celebrations
- [ ] Rank-up animations

---

## Phase 6: UI/UX Polish

### 6.1 Consistent Design
- [ ] Match cadence mode visual style
- [ ] Gradient buttons for quick actions
- [ ] Smooth animations and transitions

### 6.2 Settings Integration
- [ ] Audio settings apply to chord drill
- [ ] Theme settings consistent

### 6.3 Review Mode
- [ ] Review wrong answers with explanations
- [ ] "Drill Missed Chords" option
- [ ] Show chord formula for learning

---

## Implementation Priority

### High Priority (Do First)
1. Phase 3.1-3.2: Rating & Rank System (core engagement)
2. Phase 2.1-2.2: Daily Challenge & Streaks
3. Phase 4.1: Stats Dashboard on home screen

### Medium Priority
4. Phase 1.1-1.2: Filtering options
5. Phase 4.2-4.3: Quick actions & progress cards
6. Phase 5.1-5.2: Audio & haptic feedback

### Lower Priority (Polish)
7. Phase 1.3: Additional question types
8. Phase 4.4: Achievements
9. Phase 6: UI polish

---

## Data Models Needed

### ChordDrillStats (New)
```swift
struct ChordDrillStats: Codable {
    var totalChordsAnswered: Int
    var totalCorrectAnswers: Int
    var totalPracticeTime: TimeInterval
    var currentRating: Int  // Elo-like rating
    var currentStreak: Int
    var longestStreak: Int
    var lastPracticeDate: Date?
    var dailyChallengeCompletedToday: Bool
    var dailyChallengeStreak: Int
    
    // Per-chord-type stats
    var statsByChordType: [String: ChordTypeStats]
    
    // Per-key stats  
    var statsByKey: [String: KeyStats]
    
    // Practice log
    var practiceLog: [PracticeSession]
}

struct PracticeSession: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let questionsAnswered: Int
    let correctAnswers: Int
    let chordTypes: [String]
    let keys: [String]
    let ratingChange: Int
}
```

### Rank (New)
```swift
struct Rank {
    let title: String
    let emoji: String
    let minRating: Int
    let maxRating: Int
    
    static func forRating(_ rating: Int) -> Rank
}
```

---

## Progress Tracking

| Feature | Status | Date Completed |
|---------|--------|----------------|
| Rating System | ✅ Done | Jan 10, 2026 |
| Rank Titles | ✅ Done | Jan 10, 2026 |
| Daily Challenge | ✅ Done | Jan 10, 2026 |
| Streak System | ✅ Done | Jan 10, 2026 |
| Stats Dashboard | ✅ Done | Jan 10, 2026 |
| Quick Practice | ✅ Done | Jan 10, 2026 |
| Practice Session Log | ✅ Done | Jan 10, 2026 |
| Rating Change Display | ✅ Done | Jan 10, 2026 |
| Rank Up Celebration | ✅ Done | Jan 10, 2026 |
| Chord Type Filtering | ⬜ Pending | |
| Key Filtering | ⬜ Pending | |
| Audio Feedback | ⬜ Pending | |
| Haptic Feedback | ⬜ Pending | |
| Achievements | ⬜ Pending | |

---

## Notes

- Rating system should feel rewarding - gains should outweigh losses for average play
- Rank titles should never feel insulting - "Shed Rat" is affectionate jazz slang for someone who practices a lot
- All stats should persist to UserDefaults
- Consider iCloud sync for cross-device in future
