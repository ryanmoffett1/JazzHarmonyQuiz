# Jazz Harmony App: Strategic Analysis & Product Direction

**Consultation Date:** January 2025
**Prepared by:** Product & Jazz Pedagogy Specialist

---

## Executive Summary

This is a **technically sophisticated** iOS application with solid architectural foundations, but it suffers from **identity confusion** and **feature sprawl** that dilutes its potential impact. The core mechanics are sound, but the app needs a clearer value proposition and tighter focus to compete meaningfully in the jazz education space.

---

## Part 1: Current State Assessment

### What's Been Built (The Good)

**Strong Technical Foundation:**
- Clean SwiftUI architecture with proper state management (ObservableObject, @EnvironmentObject)
- SM-2 spaced repetition algorithm implementation
- Comprehensive chord database (30+ chord types across 4 difficulty tiers)
- 4 learning pathways with 30 curriculum modules
- Audio synthesis via AVAudioUnitSampler with configurable playback styles
- Per-key and per-chord statistics tracking
- XP/ranking progression system with 12 tiers

**Content Depth:**
- Chords: Triads through 13th chords, altered dominants, all extensions
- Scales: All 7 modes, melodic/harmonic minor, symmetrical scales
- Cadences: ii-V-I (major/minor), tritone subs, backdoor, Bird changes
- Intervals: Full chromatic coverage with aural recognition
- Functional harmony: Guide tones, common tones, voice leading

**Gamification Elements:**
- XP system with rank progression ("Shed Rat" → "Living Legend")
- 20+ achievements
- Daily streaks
- Weak key targeting
- Speed rounds

### What's Falling Flat

#### 1. Identity Crisis: "Quiz" vs. "Training" vs. "Study Tool"

The app can't decide what it is. The name "Jazz Harmony Quiz" suggests trivia, but the content is serious pedagogy. The UI tries to be gamified with emojis and ranks, but the setup screens are overwhelming with options. This creates cognitive dissonance.

#### 2. Overwhelming Setup Friction

The cadence drill setup screen has:
- 9 drill modes in a grid
- Isolated chord position picker
- Common tone pair picker
- Speed round timer
- Key difficulty selector
- Number of questions
- Mixed cadences toggle
- Multi-select cadence types
- Extended V chord options

This is **expert-level configuration** presented to a beginner. Total Harmony Pro succeeds because it progressively reveals complexity.

#### 3. Disconnected Drill Modes

Each drill (Chord, Cadence, Scale, Interval, Progression) feels like a separate mini-app. There's no narrative thread connecting "why am I learning Dm7b5" to "how does this apply to a ii-V-i in C minor." The curriculum system attempts this but isn't surfaced prominently.

#### 4. No Real Jazz Standards Integration

iReal Pro dominates because it connects theory to **actual tunes**. This app drills abstractions (spell C7b9) without connecting to "this is what you play over bar 5 of 'All The Things You Are'." Jazz musicians learn by playing tunes, not isolated exercises.

#### 5. Passive Ear Training

The aural components ask users to identify what they hear, but don't help them **sing/internalize** intervals and chord qualities. The best ear training (Chet, SoundGym) makes you produce sounds, not just recognize them.

#### 6. No Social/Comparative Element

The scoreboard shows personal bests but there's no:
- Leaderboards (even anonymous)
- Daily challenges with global participation
- Teacher/student pairing
- Shared progress in ensemble/class settings

#### 7. Missing "Quick Session" Mode

When you have 3 minutes waiting for coffee, you want to tap one button and start drilling your weak areas. Currently requires navigating through setup screens.

---

## Part 2: Competitive Analysis

### Total Harmony Pro
| Aspect | Assessment |
|--------|------------|
| **Strengths** | Elegant progressive disclosure, clean UI, comprehensive theory coverage |
| **Weakness** | Not jazz-specific, no ear training, no standards integration |
| **Our Opportunity** | Jazz specialization with deeper ii-V-I focus |

### Chet (Voice Leading/Ear Training)
| Aspect | Assessment |
|--------|------------|
| **Strengths** | Forces singing/vocalization, beautiful design, focused scope |
| **Weakness** | Primarily ear training, no chord spelling, no standards |
| **Our Opportunity** | Complement Chet by covering cognitive/theoretical side |

### iReal Pro
| Aspect | Assessment |
|--------|------------|
| **Strengths** | Real tunes, play-along, chord charts, massive community |
| **Weakness** | Not pedagogical - assumes you already know the chords |
| **Our Opportunity** | Be the "training grounds" before you open iReal Pro |

### Functional Ear Trainer
| Aspect | Assessment |
|--------|------------|
| **Strengths** | Interval recognition in tonal context |
| **Weakness** | Not jazz-specific, no chords/voicings |
| **Our Opportunity** | Jazz-specific chord quality recognition |

---

## Part 3: Recommended App Name

### Top Recommendations

1. **"Shed"** - Jazz slang for practicing ("I'm going to the woodshed"). Short, memorable, insider terminology that signals jazz credibility. Could use tagline: "Your pocket practice room."

2. **"Shed Pro"** - If trademark concerns with "Shed"

3. **"Bebop Theory"** - Clear what it is, jazz-specific, implies serious study

4. **"Jazz Fluency"** - Emphasizes the goal (fluency in the harmonic language)

5. **"Harmony Shed"** - Combines focus area with jazz terminology

### Names to Avoid
- "Jazz Harmony Quiz" - trivializes serious content
- Anything with "Learn" or "Easy" - jazz musicians want rigor, not dumbing down
- "Pro" standalone - overused

### Recommendation
**"Shed"** with tagline "Jazz Harmony Training"

---

## Part 4: Refined Vision Statement

### Current Implicit Vision
"A quiz app that tests jazz theory knowledge across multiple topics"

### Refined Vision

> **"Shed is the definitive tool for building jazz harmonic fluency—turning abstract theory into instant, instinctive musical vocabulary through focused drilling, intelligent repetition, and contextual learning tied to the jazz repertoire."**

### Core Principles

1. **Fluency, Not Knowledge** - The goal isn't to know that Dm7b5 contains D-F-Ab-C; it's to instantly *think* and *hear* those notes when you see the symbol on a chart.

2. **Context Is King** - Every concept connects to real jazz situations. Why learn tritone substitution? Because bar 9 of "Autumn Leaves" uses it.

3. **Progressive Mastery** - Start simple, earn complexity. Don't show 9 drill modes on day one.

4. **The 5-Minute Session** - Designed for real life. Quick wins, clear progress, daily practice habit.

5. **Complement, Don't Replace** - Work alongside iReal Pro, not against it. We're the gym; iReal is the gig.

---

## Part 5: Strategic Product Direction

### Phase 1: Focus & Polish (Immediate)

#### 1. Introduce "Quick Practice" Mode
One-tap access from home screen that:
- Automatically selects content based on spaced repetition due items
- Falls back to weak areas
- 5-10 questions, immediate feedback
- No setup friction

#### 2. Simplify Drill Setup
Hide advanced options behind "Custom" toggle:
- Default: "Practice ii-V-I in Major Keys" (one tap)
- Custom: Full configuration for power users
- Reference: How Total Harmony Pro progressively reveals complexity

#### 3. Strengthen Curriculum as Primary Path
Make curriculum the **default entry point** for new users:
- Guided onboarding: "Let's assess your current level"
- Daily recommendations front and center
- Achievement unlocks tied to curriculum completion

#### 4. Connect Theory to Tunes
Add "In the Wild" examples:
- After learning ii-V-I: "This appears in bars 1-2 of 'Autumn Leaves' and bars 5-8 of 'All The Things You Are'"
- Future: Link to iReal Pro charts via URL scheme

### Phase 2: Differentiation (Medium-term)

#### 1. Voice Leading Trainer
Jazz-specific voice leading is under-served:
- Given Dm7 → G7, voice the G7 with minimal motion
- Highlight 3-7 guide tone resolution
- This is directly applicable to comping

#### 2. Standard-Based Drilling
"Practice the changes to 'Take the A Train'"
- Generates drill questions from a progression
- Covers all the chords in context
- Tracks mastery of specific tunes

#### 3. Transcription Helper
"What chord contains C-E-Bb-D?"
- Inverse lookup from notes to chord symbol
- Essential for learning from recordings

#### 4. Community Challenges
- Daily challenge: "Spell all chords in today's progression"
- Weekly leaderboards
- Shared classroom mode for teachers

### Phase 3: Platform (Long-term)

#### 1. iPad/Mac Optimization
- Larger keyboard for iPad
- Piano keyboard MIDI input

#### 2. Teacher Dashboard
- Assign curriculum modules
- Track student progress
- Custom exercise creation

#### 3. Integration APIs
- iReal Pro: Open tune, see drill for those changes
- Notion/Anki: Export spaced repetition cards
- Music XML: Import custom progressions

---

## Part 6: Specific UI/UX Recommendations

### Home Screen Redesign

**Current:** Dense stats + 6 practice modes + curriculum link

**Proposed:**

```
┌─────────────────────────────────┐
│  🔥 5 day streak    🏆 1,247 XP │
├─────────────────────────────────┤
│  ┌─────────────────────────────┐│
│  │   QUICK PRACTICE            ││
│  │   12 items due              ││
│  │   [Start 5 min session]     ││
│  └─────────────────────────────┘│
├─────────────────────────────────┤
│  Continue: Major ii-V-I         │
│  ████████░░ 73% complete        │
│  [Continue Curriculum]          │
├─────────────────────────────────┤
│  Today's Challenge              │
│  "Spell all altered doms"       │
│  [Take Challenge]               │
├─────────────────────────────────┤
│  ─ Practice Modes ──            │
│  [Chords] [Cadences] [Scales]   │
│  [Intervals] [Custom]           │
└─────────────────────────────────┘
```

### Drill Setup Simplification

**Before (Current):**
- 15+ configuration options visible
- User must understand all parameters

**After:**
```
┌─────────────────────────────────┐
│  CHORD DRILL                    │
├─────────────────────────────────┤
│  Quick Start:                   │
│  [Basic 7ths] [Extended] [All]  │
├─────────────────────────────────┤
│  ▼ Custom Options               │
│    (collapsed by default)       │
└─────────────────────────────────┘
```

---

## Part 7: Naming Convention for Drill Modes

Current naming is inconsistent and unintuitive:

| Current | Proposed | Why |
|---------|----------|-----|
| Chord Drill | Chord Spelling | Clearer action |
| Harmony Practice | Cadence Drill | Consistent naming |
| Scale Drill | Scale Spelling | Parallel structure |
| Interval Drill | Interval Training | Covers visual + aural |

---

## Part 8: Monetization Strategy

### Option A: Freemium Model
- **Free:** Basic chord/interval drills, limited curriculum
- **Pro ($4.99/mo or $29.99/yr):** Full curriculum, all modes, statistics, standards-based drilling

### Option B: One-time Purchase ($9.99)
- Full app access
- More aligned with music app expectations
- Lower friction for musicians

### Recommendation
One-time purchase at launch, consider subscription for advanced features (teacher dashboard, community features) later.

---

## Part 9: Success Metrics

| Metric | Target | Why It Matters |
|--------|--------|----------------|
| Daily Active Users (DAU) | 40% of MAU | Measures habit formation |
| Average Session Duration | 5+ minutes | Meaningful practice time |
| 7-Day Retention | 35%+ | Early engagement indicator |
| Curriculum Module Completion | 60% complete first pathway | Learning journey success |
| App Store Rating | 4.7+ | Market perception |

---

## Part 10: Implementation Priority Matrix

### Must Do (Critical Path)
| Priority | Item | Effort | Impact |
|----------|------|--------|--------|
| 1 | Rename app to "Shed" or similar | Low | High |
| 2 | Add one-tap Quick Practice from home screen | Medium | High |
| 3 | Collapse advanced options in drill setup | Medium | High |
| 4 | Make curriculum the guided path for new users | Medium | High |

### Should Do (High Value)
| Priority | Item | Effort | Impact |
|----------|------|--------|--------|
| 5 | Add tune-based context ("This chord appears in...") | Medium | High |
| 6 | Implement voice leading trainer | High | High |
| 7 | Add inverse chord lookup (notes → symbol) | Medium | Medium |
| 8 | Daily challenges with social element | High | Medium |

### Could Do (Differentiation)
| Priority | Item | Effort | Impact |
|----------|------|--------|--------|
| 9 | Standards-based drilling mode | High | High |
| 10 | Teacher/classroom features | High | Medium |
| 11 | iPad optimization with MIDI input | Medium | Medium |
| 12 | iReal Pro integration | Medium | Medium |

---

## Part 11: Technical Recommendations

### Code Quality Observations

**Strengths:**
- Clean separation of concerns (Models, Views, Helpers)
- Proper use of SwiftUI patterns (@StateObject, @EnvironmentObject)
- Comprehensive data modeling for musical concepts
- Good use of enums for type safety

**Areas for Improvement:**
- Some view files are very large (CadenceDrillView.swift is 1000+ lines)
- Consider extracting reusable components
- Add unit tests for game logic and spaced repetition
- Consider MVVM pattern more strictly for testability

### Recommended Refactoring

1. **Extract QuickPracticeEngine** - Encapsulate the logic for selecting items based on SR schedule and weak areas

2. **Create DrillConfigurationPresets** - Pre-built configurations for common use cases to reduce setup friction

3. **Implement TuneDatabase** - Model for storing standard progressions with bar numbers for contextual learning

4. **Add Analytics Layer** - Track user behavior to identify friction points and optimize UX

---

## Conclusion

This app has **strong bones**. The chord database, spaced repetition, and drill mechanics are solid. What's missing is **focus and narrative**. Jazz musicians need to feel like this app understands their world—the shed, the gig, the chart.

By simplifying the UX, strengthening the curriculum-first approach, and connecting abstract theory to real jazz situations, this can become an essential tool alongside iReal Pro and Chet—not as a replacement, but as the **missing piece** that makes the others more useful.

### The Aspiration

> *"Before I open iReal Pro to practice a tune, I open Shed to make sure I know the changes cold."*

---

## Appendix: Jazz Standards for Contextual Learning

High-priority tunes for "In the Wild" feature:

| Tune | Key Concepts | Difficulty |
|------|--------------|------------|
| Autumn Leaves | ii-V-I major/minor, relative major/minor | Beginner |
| All The Things You Are | ii-V-I chains, key centers | Intermediate |
| Blue Bossa | Minor ii-V-i, key change | Beginner |
| Take The A Train | Basic changes, bridge contrast | Beginner |
| Stella By Starlight | Extended ii-V patterns | Intermediate |
| Giant Steps | Coltrane changes, major thirds | Advanced |
| Moment's Notice | ii-V patterns, chromaticism | Advanced |
| Body and Soul | Key changes, substitutions | Intermediate |
| Cherokee | Fast changes, bridge workout | Advanced |
| Confirmation | Bebop harmony, substitutions | Intermediate |

---

*End of Consultation Document*
