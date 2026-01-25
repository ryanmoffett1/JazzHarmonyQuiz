# Shed Pro: Next-Generation Design Document

**Version:** 2.0
**Last Updated:** January 2025
**Status:** Authoritative Reference for Development

---

## Document Purpose

This document serves as the **authoritative design specification** for Shed Pro (formerly "Jazz Harmony Quiz"). All development work—whether by human developers or LLM agents—should reference this document for:

- Feature specifications and expected behavior
- UI/UX patterns and component design
- Data model structures
- Navigation flows
- Business logic rules

When in doubt, this document is the source of truth.

---

## Table of Contents

1. [App Identity](#1-app-identity)
2. [Core Principles](#2-core-principles)
3. [Information Architecture](#3-information-architecture)
4. [User Personas](#4-user-personas)
5. [Home Screen](#5-home-screen)
6. [Quick Practice Mode](#6-quick-practice-mode)
7. [Drill Modules](#7-drill-modules)
8. [Curriculum System](#8-curriculum-system)
9. [Progression System](#9-progression-system)
10. [Audio System](#10-audio-system)
11. [Settings](#11-settings)
12. [Data Models](#12-data-models)
13. [UI Component Library](#13-ui-component-library)
14. [Technical Requirements](#14-technical-requirements)

---

## 1. App Identity

### 1.1 Name
**Shed Pro**

Alternate acceptable names: "Shed", "The Shed"

"Shed" is jazz slang for the practice room (from "woodshedding"—isolating yourself to practice intensively). This name signals insider credibility to the target audience.

### 1.2 Tagline
"Jazz Harmony Training"

### 1.3 App Store Description
> Master jazz harmony through focused, intelligent practice. Shed Pro builds fluency in chord spelling, cadences, scales, intervals, and voice leading—the essential vocabulary every jazz musician needs. Powered by spaced repetition, Shed Pro ensures you practice what you need, when you need it. Whether you have 5 minutes or 50, make every session count.

### 1.4 Visual Identity

#### Color Palette
| Role | Light Mode | Dark Mode | Usage |
|------|------------|-----------|-------|
| Primary | `#1A1A2E` | `#E8E8F0` | Text, key UI elements |
| Accent | `#D4A574` | `#D4A574` | CTAs, highlights (warm brass/gold) |
| Success | `#2E7D32` | `#4CAF50` | Correct answers |
| Error | `#C62828` | `#EF5350` | Incorrect answers |
| Background | `#FAFAFA` | `#121212` | App background |
| Surface | `#FFFFFF` | `#1E1E1E` | Cards, elevated surfaces |
| Muted | `#757575` | `#9E9E9E` | Secondary text |

#### Typography
| Role | Font | Weight | Size |
|------|------|--------|------|
| Chord Symbols | SF Pro Rounded or System | Medium | 32-48pt |
| Headings | SF Pro Display | Semibold | 20-28pt |
| Body | SF Pro Text | Regular | 16-17pt |
| Caption | SF Pro Text | Regular | 13-14pt |

**Note:** Remove the "Caveat" handwritten font option. While aesthetically reminiscent of Real Book charts, it reduces legibility and signals informality. Chord symbols should be clear and professional.

#### Iconography
- Use SF Symbols exclusively
- Prefer outlined variants for navigation, filled for selected states
- No emoji in core UI (acceptable in achievements only if restrained)

---

## 2. Core Principles

These principles guide all design and development decisions:

### 2.1 Fluency Over Knowledge
The goal is not to know facts about chords—it's to **instantly recognize, spell, and hear** them. Every feature should build automatic, instinctive responses.

**Implication:** Favor speed and repetition over lengthy explanations. Theory explanations are secondary to drilling.

### 2.2 Progressive Disclosure
Never overwhelm the user with options. Reveal complexity as they demonstrate mastery.

**Implication:** Default configurations should work for 80% of sessions. Advanced options are hidden behind expandable sections.

### 2.3 The 5-Minute Session
The app must be useful in short bursts. A user waiting for coffee should be able to complete meaningful practice.

**Implication:** One-tap Quick Practice. No mandatory setup screens. Save state aggressively.

### 2.4 Context Is King
Abstract theory connects to real jazz situations. Every concept should eventually link to where it appears in the repertoire.

**Implication:** "In the Wild" feature showing which standards use each concept. Tune-based drilling.

### 2.5 Professional Tone
This is a serious practice tool for serious musicians. Respect the user's intelligence and commitment.

**Implication:** No patronizing language, minimal gamification chrome, clinical presentation of statistics.

### 2.6 Complement, Don't Replace
Shed Pro works alongside iReal Pro, not against it. We're the gym; they're the gig.

**Implication:** Future integration points. No play-along features (that's iReal's domain).

---

## 3. Information Architecture

### 3.1 Navigation Structure

```
Tab Bar (Primary Navigation)
├── Home (Default)
├── Practice (Drill Selection)
├── Curriculum
├── Progress
└── Settings
```

### 3.2 Screen Hierarchy

```
HOME
├── Quick Practice Card → Quick Practice Session
├── Continue Curriculum Card → Active Module Drill
├── Daily Focus Card → Targeted Drill
└── Stats Summary → Progress Tab

PRACTICE
├── Chord Spelling
│   ├── Quick Start (preset configs)
│   └── Custom Setup → Drill Session → Results
├── Cadence Training
│   ├── Quick Start
│   └── Custom Setup → Drill Session → Results
├── Scale Spelling
│   ├── Quick Start
│   └── Custom Setup → Drill Session → Results
├── Interval Training
│   ├── Quick Start
│   └── Custom Setup → Drill Session → Results
└── Voice Leading (Future)
    └── ...

CURRICULUM
├── Pathway Selection (horizontal scroll)
│   ├── Harmony Foundations
│   ├── Functional Harmony
│   ├── Ear Training
│   └── Advanced Topics
└── Module List → Module Detail → Drill Session

PROGRESS
├── Overview (key stats)
├── By Category (chords, scales, etc.)
├── By Key (12 keys breakdown)
├── History (calendar view)
└── Achievements

SETTINGS
├── Audio
├── Display
├── Practice Defaults
├── Data & Privacy
└── About
```

### 3.3 Navigation Patterns

| Pattern | Usage |
|---------|-------|
| Tab Bar | Primary navigation between main sections |
| Push Navigation | Drilling into detail (module → drill → results) |
| Modal Sheet | Settings, quick configuration, module detail |
| Full Screen Cover | Active drill sessions (no distractions) |

---

## 4. User Personas

### 4.1 Primary: "The Serious Student"
- Age: 18-35
- Background: Music school student or dedicated amateur
- Goal: Prepare for juries, auditions, or jam sessions
- Behavior: Daily practice, systematic approach
- Needs: Structured curriculum, progress tracking, spaced repetition

### 4.2 Secondary: "The Working Musician"
- Age: 25-55
- Background: Gigging professional, possibly rusty on theory
- Goal: Refresh fundamentals, fill gaps in knowledge
- Behavior: Sporadic but focused practice sessions
- Needs: Quick sessions, weak area targeting, no fluff

### 4.3 Tertiary: "The Theory Curious"
- Age: Any
- Background: Plays another genre, exploring jazz
- Goal: Understand jazz harmony vocabulary
- Behavior: Exploratory, may not commit long-term
- Needs: Gentle onboarding, clear explanations, early wins

---

## 5. Home Screen

### 5.1 Purpose
The Home screen is the **daily dashboard**—showing what needs attention and providing one-tap access to practice.

### 5.2 Layout Specification

```
┌─────────────────────────────────────────┐
│  HEADER                                 │
│  "Shed Pro"              [streak badge] │
├─────────────────────────────────────────┤
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  QUICK PRACTICE (Primary CTA)   │    │
│  │  ─────────────────────────────  │    │
│  │  14 items due for review        │    │
│  │  Estimated: 5 min               │    │
│  │                                 │    │
│  │  [Start Session]                │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  CONTINUE LEARNING              │    │
│  │  ─────────────────────────────  │    │
│  │  Major ii-V-I                   │    │
│  │  ████████░░░░ 67%               │    │
│  │                                 │    │
│  │  [Continue]                     │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │  DAILY FOCUS                    │    │
│  │  ─────────────────────────────  │    │
│  │  Weak area: Db key chords       │    │
│  │  Last accuracy: 62%             │    │
│  │                                 │    │
│  │  [Practice Db]                  │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ─── THIS WEEK ───                      │
│  ┌────┐ ┌────┐ ┌────┐ ┌────┐ ┌────┐    │
│  │ M  │ │ T  │ │ W  │ │ Th │ │ F  │    │
│  │ ✓  │ │ ✓  │ │ ✓  │ │    │ │    │    │
│  └────┘ └────┘ └────┘ └────┘ └────┘    │
│                                         │
│  ─── QUICK STATS ───                    │
│  Total Sessions: 47                     │
│  This Week: 5                           │
│  Avg Accuracy: 84%                      │
│                                         │
└─────────────────────────────────────────┘
```

### 5.3 Component Specifications

#### 5.3.1 Quick Practice Card
| Property | Value |
|----------|-------|
| Background | Accent color with 10% opacity |
| Border | 2px accent color |
| Corner Radius | 16pt |
| Priority | Always first, always visible |

**Content Logic:**
```swift
if spacedRepetition.dueItems.count > 0 {
    title = "Quick Practice"
    subtitle = "\(dueItems.count) items due for review"
    estimate = calculateEstimate(dueItems.count) // ~20 sec per item
} else if weakAreas.count > 0 {
    title = "Strengthen Weak Areas"
    subtitle = "Focus on \(weakAreas.first!.name)"
    estimate = "5 min"
} else {
    title = "Free Practice"
    subtitle = "All caught up! Keep building fluency."
    estimate = "5 min"
}
```

#### 5.3.2 Continue Learning Card
| Property | Value |
|----------|-------|
| Visibility | Only if active curriculum module exists |
| Background | Surface color |
| Border | 1px muted color |

**Content Logic:**
```swift
if let activeModule = curriculum.activeModule {
    title = activeModule.title
    progress = curriculum.getProgress(activeModule)
    showCard = true
} else if let recommended = curriculum.recommendedNext {
    title = "Start: \(recommended.title)"
    progress = 0
    showCard = true
} else {
    showCard = false
}
```

#### 5.3.3 Daily Focus Card
| Property | Value |
|----------|-------|
| Visibility | Only if weak area identified |
| Background | Surface color |

**Content Logic:**
```swift
let weakArea = statistics.getWeakestArea() // Key, chord type, or scale
if weakArea.accuracy < 0.75 {
    title = "Daily Focus"
    subtitle = "Weak area: \(weakArea.name)"
    detail = "Last accuracy: \(weakArea.accuracy)%"
    showCard = true
} else {
    showCard = false
}
```

#### 5.3.4 Streak Badge
| State | Display |
|-------|---------|
| No streak | Hidden |
| 1-6 days | "🔥 X days" (small, muted) |
| 7+ days | "🔥 X days" (small, slightly emphasized) |

**Note:** Streaks are shown but not celebrated excessively. No animations, no "streak freeze" purchases, no shame messaging for broken streaks.

---

## 6. Quick Practice Mode

### 6.1 Purpose
One-tap access to intelligent, personalized practice. No configuration required.

### 6.2 Session Generation Algorithm

```swift
func generateQuickPracticeSession() -> [PracticeItem] {
    var items: [PracticeItem] = []
    let targetCount = 15

    // Priority 1: Spaced repetition due items (up to 60%)
    let dueItems = spacedRepetition.getDueItems()
        .sorted { $0.overdueDays > $1.overdueDays }
        .prefix(Int(Double(targetCount) * 0.6))
    items.append(contentsOf: dueItems)

    // Priority 2: Weak areas (up to 25%)
    let weakItems = statistics.getWeakAreas()
        .flatMap { generateQuestionsForWeakArea($0, count: 2) }
        .prefix(Int(Double(targetCount) * 0.25))
    items.append(contentsOf: weakItems)

    // Priority 3: Reinforcement of recent learning (up to 15%)
    let recentItems = curriculum.getRecentlyLearnedItems()
        .prefix(Int(Double(targetCount) * 0.15))
    items.append(contentsOf: recentItems)

    // Fill remainder with general practice if needed
    while items.count < targetCount {
        items.append(generateRandomItem())
    }

    return items.shuffled()
}
```

### 6.3 Session Flow

```
[Start Session Button]
        │
        ▼
┌─────────────────────────────────────────┐
│  QUICK PRACTICE SESSION                 │
│  ─────────────────────────────────────  │
│  Question 3 of 15         [Exit ✕]      │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │                                 │    │
│  │   Spell: Dm7b5                  │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  ┌─────────────────────────────────┐    │
│  │   PIANO KEYBOARD                │    │
│  │   [Interactive - tap to select] │    │
│  └─────────────────────────────────┘    │
│                                         │
│  Selected: D, F, Ab                     │
│                                         │
│  [Check Answer]                         │
│                                         │
│  ━━━━━━━━░░░░░░░░░░░░ 3/15             │
└─────────────────────────────────────────┘
        │
        ▼ (after answer)
┌─────────────────────────────────────────┐
│  ✓ Correct!                             │
│                                         │
│  Dm7b5: D - F - Ab - C                  │
│                                         │
│  [▶ Play Chord]     [Next →]            │
└─────────────────────────────────────────┘
        │
        ▼ (after 15 questions)
┌─────────────────────────────────────────┐
│  SESSION COMPLETE                       │
│  ─────────────────────────────────────  │
│                                         │
│  Accuracy: 87% (13/15)                  │
│  Time: 4:32                             │
│                                         │
│  ─── BREAKDOWN ───                      │
│  Chords:    ████████░░ 90%              │
│  Intervals: ██████░░░░ 75%              │
│  Cadences:  ████████░░ 85%              │
│                                         │
│  ─── REVIEW MISSED ───                  │
│  • Bbm7b5 (you said: Bb-D-E-Ab)         │
│  • Minor 6th from G (you said: D#)      │
│                                         │
│  [Done]           [Practice Again]      │
└─────────────────────────────────────────┘
```

### 6.4 Exit Handling
If user exits mid-session:
- Save progress immediately
- Completed questions count toward statistics
- Incomplete questions are not penalized
- SR schedules update for answered items only
- No "are you sure?" modal (respect user agency)

---

## 7. Drill Modules

### 7.1 Module Overview

| Module | Purpose | Question Types |
|--------|---------|----------------|
| Chord Spelling | Spell chord notes from symbol | All tones, single tone, aural quality, aural spelling |
| Cadence Training | Identify/spell chords in progressions | Full progression, isolated chord, guide tones, common tones, aural ID |
| Scale Spelling | Spell scale degrees | All degrees, single degree, aural ID |
| Interval Training | Build/identify intervals | Build interval, name interval, aural ID |
| Voice Leading | (Future) Optimal voicing choices | Smooth voice leading, guide tone resolution |

### 7.2 Universal Drill Structure

All drills follow this state machine:

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  SETUP   │ ──▶ │  ACTIVE  │ ──▶ │ RESULTS  │
└──────────┘     └──────────┘     └──────────┘
     │                │                │
     │                │                │
     ▼                ▼                ▼
  Configure       Answer Qs        Review &
  or Quick        Get Feedback     Statistics
  Start
```

### 7.3 Setup Screen Pattern

**Critical Requirement:** Setup screens must support BOTH quick-start presets AND custom configuration.

```
┌─────────────────────────────────────────┐
│  ← Back           CHORD SPELLING        │
├─────────────────────────────────────────┤
│                                         │
│  ─── QUICK START ───                    │
│                                         │
│  ┌─────────┐ ┌─────────┐ ┌─────────┐   │
│  │ Basic   │ │ 7ths &  │ │ Full    │   │
│  │ Triads  │ │ Extns   │ │ Workout │   │
│  │         │ │         │ │         │   │
│  │ 10 Qs   │ │ 15 Qs   │ │ 20 Qs   │   │
│  └─────────┘ └─────────┘ └─────────┘   │
│                                         │
│  ─── OR CUSTOMIZE ───                   │
│                                         │
│  ▼ Custom Options                       │
│  ┌─────────────────────────────────┐    │
│  │ (Collapsed by default)          │    │
│  │                                 │    │
│  │ Chord Types: [Multi-select]     │    │
│  │ Keys: [Easy/Medium/Hard/All]    │    │
│  │ Question Type: [Picker]         │    │
│  │ Number of Questions: [Stepper]  │    │
│  │ Audio Playback: [Toggle]        │    │
│  │                                 │    │
│  └─────────────────────────────────┘    │
│                                         │
│  [Start Practice]                       │
│                                         │
└─────────────────────────────────────────┘
```

### 7.4 Chord Spelling Module

#### 7.4.1 Quick Start Presets

| Preset | Chord Types | Keys | Questions |
|--------|-------------|------|-----------|
| Basic Triads | major, minor, dim, aug | Easy | 10 |
| 7th Chords | maj7, m7, 7, m7b5, dim7 | Easy + Medium | 15 |
| Full Workout | All enabled | All | 20 |

#### 7.4.2 Question Types

**All Tones (Default)**
- Prompt: "Spell: Cmaj7"
- Input: Piano keyboard (multi-select)
- Answer: All chord tones (C, E, G, B)
- Feedback: Show correct vs. user selection

**Single Tone**
- Prompt: "What is the 3rd of Cmaj7?"
- Input: Piano keyboard (single-select)
- Answer: E
- Feedback: Show correct note, play chord

**Aural Quality**
- Prompt: [Plays chord sound]
- Input: Multiple choice buttons
- Answer: Select chord quality (maj7, m7, etc.)
- Feedback: Show correct quality, replay chord

**Aural Spelling**
- Prompt: [Plays chord sound]
- Input: Piano keyboard (multi-select)
- Answer: All chord tones
- Feedback: Show correct spelling, replay chord

#### 7.4.3 Chord Database (Preserve Existing)

Retain the current `JazzChordDatabase.swift` structure with these chord types:

**Beginner Tier:**
- major, minor, dim, aug
- maj7, m7, 7, m7b5, dim7

**Intermediate Tier:**
- aug7, maj6, m6
- 9, maj9, m9, add9
- 7sus4

**Advanced Tier:**
- 7b9, 7#9, 7b5, 7#5
- 7b9b5, 7#9#5, 7alt
- 11, m11, maj11

**Expert Tier:**
- 13, m13, maj13
- 7b13, 7#11
- Complex alterations

### 7.5 Cadence Training Module

#### 7.5.1 Quick Start Presets

| Preset | Cadence Types | Mode | Keys |
|--------|---------------|------|------|
| Major ii-V-I | Major only | Full progression | Easy |
| Minor ii-V-i | Minor only | Full progression | Easy |
| Mixed Cadences | Major, Minor, Tritone Sub | Full progression | Medium |

#### 7.5.2 Question Types (Simplified from Current 9)

**Core Modes (Always Available):**

| Mode | Description | Input |
|------|-------------|-------|
| Full Progression | Spell all chords in sequence | Piano keyboard per chord |
| Chord Identification | Name the chord at position X | Multiple choice |
| Aural Identification | Hear progression, identify type | Multiple choice |

**Advanced Modes (Unlocked via Curriculum):**

| Mode | Description | Input |
|------|-------------|-------|
| Guide Tones | Identify 3rd and 7th of each chord | Piano keyboard |
| Common Tones | Find shared notes between adjacent chords | Piano keyboard |
| Resolution Target | Where does the V7 want to resolve? | Piano keyboard |

**Removed/Consolidated:**
- "Speed Round" → Integrated as timed option in any mode
- "Smooth Voicing" → Moved to future Voice Leading module
- "Isolated Chord" → Consolidated into Full Progression with focus indicator

#### 7.5.3 Cadence Types

| Type | Progression | Example in C |
|------|-------------|--------------|
| Major ii-V-I | ii-7 → V7 → Imaj7 | Dm7 → G7 → Cmaj7 |
| Minor ii-V-i | iiø7 → V7b9 → i-7 | Dm7b5 → G7b9 → Cm7 |
| Tritone Sub | ii-7 → bII7 → Imaj7 | Dm7 → Db7 → Cmaj7 |
| Backdoor | iv-7 → bVII7 → Imaj7 | Fm7 → Bb7 → Cmaj7 |
| Bird Blues | I7 → IV7 → I7 etc. | Full blues changes |

### 7.6 Scale Spelling Module

#### 7.6.1 Quick Start Presets

| Preset | Scale Types | Keys |
|--------|-------------|------|
| Major Modes | Ionian through Locrian | Easy |
| Jazz Essentials | Major, Dorian, Mixolydian, Blues | All |
| Complete Scales | All scale types | All |

#### 7.6.2 Scale Types (Preserve Existing)

- Major / Ionian
- Dorian
- Phrygian
- Lydian
- Mixolydian
- Aeolian / Natural Minor
- Locrian
- Harmonic Minor
- Melodic Minor (Jazz)
- Blues
- Major Pentatonic
- Minor Pentatonic
- Whole Tone
- Diminished (Half-Whole)
- Diminished (Whole-Half)

### 7.7 Interval Training Module

#### 7.7.1 Quick Start Presets

| Preset | Intervals | Direction |
|--------|-----------|-----------|
| Basic | P1, m2, M2, m3, M3, P4, P5 | Ascending |
| All Simple | All within octave | Both |
| Complete | Including compounds | Both |

#### 7.7.2 Interval Types (Preserve Existing)

| Interval | Semitones | Difficulty |
|----------|-----------|------------|
| Unison | 0 | Beginner |
| Minor 2nd | 1 | Beginner |
| Major 2nd | 2 | Beginner |
| Minor 3rd | 3 | Beginner |
| Major 3rd | 4 | Beginner |
| Perfect 4th | 5 | Beginner |
| Tritone | 6 | Intermediate |
| Perfect 5th | 7 | Beginner |
| Minor 6th | 8 | Intermediate |
| Major 6th | 9 | Intermediate |
| Minor 7th | 10 | Intermediate |
| Major 7th | 11 | Intermediate |
| Octave | 12 | Beginner |

---

## 8. Curriculum System

### 8.1 Purpose
Guided learning pathways that progressively build skills. The curriculum provides structure for users who want direction rather than random drilling.

### 8.2 Pathways (Preserve Existing Structure)

| Pathway | Focus | Color |
|---------|-------|-------|
| Harmony Foundations | Chord spelling from triads to extensions | Blue |
| Functional Harmony | Cadences, voice leading, progressions | Green |
| Ear Training | Aural recognition of intervals, chords, cadences | Orange |
| Advanced Topics | Modes, melodic minor, Coltrane changes | Purple |

### 8.3 Module Completion Criteria

Each module has:
- **Accuracy Threshold:** Minimum accuracy % to pass (typically 70-90%)
- **Minimum Attempts:** Number of questions answered (typically 25-50)
- **Perfect Sessions (Optional):** Sessions with 100% accuracy required

```swift
struct CompletionCriteria {
    let accuracyThreshold: Double  // 0.0 - 1.0
    let minimumAttempts: Int
    let perfectSessionsRequired: Int?  // nil if not required
}

func isModuleComplete(_ module: Module, progress: ModuleProgress) -> Bool {
    guard progress.attempts >= module.completionCriteria.minimumAttempts else {
        return false
    }
    guard progress.accuracy >= module.completionCriteria.accuracyThreshold else {
        return false
    }
    if let perfectRequired = module.completionCriteria.perfectSessionsRequired {
        guard progress.perfectSessions >= perfectRequired else {
            return false
        }
    }
    return true
}
```

### 8.4 Module Prerequisites

Modules can require completion of previous modules:

```swift
struct CurriculumModule {
    let id: UUID
    let title: String
    let pathway: CurriculumPathway
    let level: Int
    let prerequisiteModuleIDs: [UUID]
    // ...
}

func isModuleUnlocked(_ module: Module) -> Bool {
    for prereqID in module.prerequisiteModuleIDs {
        if !isModuleComplete(getModule(prereqID)) {
            return false
        }
    }
    return true
}
```

### 8.5 Curriculum Modules (Preserve Existing)

Retain the 30 modules defined in `CurriculumDatabase.swift`. No changes to module structure or content.

---

## 9. Progression System

### 9.1 Philosophy
Track progress professionally. Show improvement. Avoid childish gamification while maintaining motivational feedback.

### 9.2 What to KEEP

#### 9.2.1 Spaced Repetition (SM-2)
The existing SM-2 implementation is correct and valuable. Preserve:
- Ease factor calculation
- Interval progression
- Due date scheduling
- Maturity levels (New → Learning → Young → Mature)

#### 9.2.2 Statistics Tracking
Preserve granular statistics:
- Per-chord-type accuracy
- Per-key accuracy
- Per-category accuracy (chords, scales, intervals, cadences)
- Session history
- Lifetime totals

#### 9.2.3 Streaks
Keep streak tracking as a secondary motivator:
- Daily streak counter
- Longest streak record
- Shown subtly in UI (not celebrated excessively)

### 9.3 What to CHANGE

#### 9.3.1 Ranking System

**Current (Remove):**
- "Shed Rat" → "Living Legend" with emoji
- XP-based progression through 12 tiers

**New (Simpler):**
- Single "Level" number based on XP
- No titles, no emoji
- Level shown in profile, not prominently featured

```swift
// Old
enum Rank {
    case shedRat        // 🐀
    case practiceRoomRegular  // 🎹
    // ... 10 more tiers
}

// New
struct PlayerLevel {
    let level: Int  // 1, 2, 3, ...
    let xp: Int
    let xpForNextLevel: Int

    static func levelFromXP(_ xp: Int) -> Int {
        // Simple formula: level = sqrt(xp / 100)
        // Level 1: 0-99 XP
        // Level 2: 100-399 XP
        // Level 3: 400-899 XP
        // etc.
        return max(1, Int(sqrt(Double(xp) / 100.0)) + 1)
    }
}
```

#### 9.3.2 Achievements

**Current (Simplify):**
- 20+ achievements with playful names
- Emoji-heavy presentation

**New (Professional):**
| Category | Achievement | Criteria | Display |
|----------|-------------|----------|---------|
| Milestones | 100 Chords | Spell 100 chords correctly | "100 Chords" |
| Milestones | 500 Chords | Spell 500 chords correctly | "500 Chords" |
| Milestones | 1000 Chords | Spell 1000 chords correctly | "1000 Chords" |
| Accuracy | 90% Session | Complete session with 90%+ | "90% Accuracy" |
| Accuracy | Perfect Session | Complete session with 100% | "Perfect Session" |
| Consistency | 7-Day Streak | Practice 7 consecutive days | "Week Streak" |
| Consistency | 30-Day Streak | Practice 30 consecutive days | "Month Streak" |
| Mastery | All Major Keys | 80%+ accuracy in all major keys | "Major Key Mastery" |
| Mastery | All Minor Keys | 80%+ accuracy in all minor keys | "Minor Key Mastery" |
| Mastery | 7th Chord Mastery | 85%+ accuracy on all 7th chord types | "7th Chord Mastery" |
| Curriculum | Pathway Complete | Complete any curriculum pathway | "Pathway Complete" |

**Presentation:**
- Simple icon + text
- No emoji in achievement names
- Shown in Progress tab, not interrupting drills
- No pop-up celebrations (optional subtle haptic on unlock)

### 9.4 XP Awards

| Action | XP |
|--------|-----|
| Correct answer (basic) | 10 |
| Correct answer (intermediate) | 15 |
| Correct answer (advanced) | 20 |
| Perfect session (10+ questions) | 50 bonus |
| Complete curriculum module | 100 bonus |
| Maintain streak (per day) | 5 |

---

## 10. Audio System

### 10.1 Architecture (Preserve Existing)

The current `AudioManager.swift` implementation is solid. Preserve:
- AVAudioEngine + AVAudioUnitSampler architecture
- SoundFont loading with fallback
- Chord playback styles (block, arpeggio)
- Interval playback styles (harmonic, melodic)
- BPM-controlled progression playback

### 10.2 Audio Behaviors

| Context | Behavior |
|---------|----------|
| Correct chord answer | Auto-play chord (if enabled in settings) |
| Incorrect chord answer | Play correct chord, then user's chord |
| Aural question | Auto-play on question appearance |
| Replay button | Always available during feedback |
| Cadence playback | Sequential with BPM control |

### 10.3 Settings Integration

```swift
struct AudioSettings {
    var isEnabled: Bool = true
    var volume: Float = 0.8  // 0.0 - 1.0
    var autoPlayOnCorrect: Bool = true
    var autoPlayAuralQuestions: Bool = true
    var chordPlaybackStyle: ChordPlaybackStyle = .block
    var intervalPlaybackStyle: IntervalPlaybackStyle = .melodic
    var defaultTempo: Double = 100  // BPM
}
```

---

## 11. Settings

### 11.1 Settings Structure

```
SETTINGS
├── Audio
│   ├── Sound Enabled [Toggle]
│   ├── Volume [Slider]
│   ├── Auto-play on Correct [Toggle]
│   ├── Chord Style [Picker: Block/Arpeggio]
│   └── Default Tempo [Slider: 60-180 BPM]
│
├── Display
│   ├── Theme [Picker: Light/Dark/System]
│   └── (Removed: Chord Font option)
│
├── Practice Defaults
│   ├── Default Question Count [Stepper: 10-30]
│   └── Haptic Feedback [Toggle]
│
├── Data
│   ├── Export Progress [Button]
│   ├── Reset Statistics [Button with confirmation]
│   └── Reset All Data [Button with confirmation]
│
└── About
    ├── Version
    ├── Send Feedback [Link]
    └── Rate App [Link]
```

### 11.2 Settings Persistence

Use `UserDefaults` for settings with `@AppStorage`:

```swift
class SettingsManager: ObservableObject {
    @AppStorage("audioEnabled") var audioEnabled = true
    @AppStorage("audioVolume") var audioVolume: Double = 0.8
    @AppStorage("autoPlayOnCorrect") var autoPlayOnCorrect = true
    @AppStorage("theme") var theme: AppTheme = .system
    @AppStorage("defaultQuestionCount") var defaultQuestionCount = 15
    @AppStorage("hapticFeedback") var hapticFeedback = true
}
```

---

## 12. Data Models

### 12.1 Core Musical Models (Preserve Existing)

```swift
// Note.swift
struct Note: Hashable, Codable {
    let name: String           // "C", "C#", "Db", etc.
    let midiNumber: Int        // 0-127
    let pitchClass: Int        // 0-11

    // Enharmonic handling
    var enharmonicEquivalent: Note? { ... }
    var isEnharmonicWith(_ other: Note) -> Bool { ... }
}

// ChordTone.swift
struct ChordTone: Codable {
    let degree: Int            // 1, 3, 5, 7, 9, 11, 13
    let name: String           // "Root", "3rd", "b7", "#9"
    let semitonesFromRoot: Int
}

// ChordType.swift
struct ChordType: Identifiable, Codable {
    let id: UUID
    let name: String           // "Major 7th"
    let symbol: String         // "maj7"
    let chordTones: [ChordTone]
    let difficulty: ChordDifficulty
}

// Chord.swift
struct Chord: Identifiable {
    let id: UUID
    let root: Note
    let chordType: ChordType

    var symbol: String { "\(root.name)\(chordType.symbol)" }
    var notes: [Note] { ... }
}
```

### 12.2 Game State Models (Preserve with Modifications)

```swift
// QuizGame.swift - Chord Drill State
@MainActor
class ChordDrillGame: ObservableObject {
    // Session configuration
    @Published var config: ChordDrillConfig

    // Question state
    @Published var questions: [ChordQuestion]
    @Published var currentIndex: Int = 0
    @Published var userAnswers: [UUID: Set<Note>] = [:]

    // Session state
    @Published var state: DrillState = .setup  // .setup, .active, .results

    // Results
    var correctCount: Int { ... }
    var accuracy: Double { ... }
    var sessionResults: SessionResults { ... }
}

struct ChordDrillConfig {
    var chordTypes: Set<ChordType>
    var keyDifficulty: KeyDifficulty
    var questionType: ChordQuestionType
    var questionCount: Int
    var audioEnabled: Bool
}

enum DrillState {
    case setup
    case active
    case results
}
```

### 12.3 Statistics Models (Preserve Existing)

```swift
// PlayerStats.swift
struct ChordTypeStatistics: Codable {
    var attempts: Int
    var correct: Int
    var accuracy: Double { Double(correct) / Double(max(attempts, 1)) }
    var lastPracticed: Date?
}

struct KeyStatistics: Codable {
    var attempts: Int
    var correct: Int
    var accuracy: Double { ... }
    var chordBreakdown: [String: ChordTypeStatistics]
}
```

### 12.4 Spaced Repetition Models (Preserve Existing)

```swift
// SpacedRepetition.swift
struct SRItemID: Hashable, Codable {
    let mode: PracticeMode      // .chords, .scales, etc.
    let topic: String           // "Cmaj7", "Dorian", etc.
    let key: String?            // "C", "F#", etc.
    let variant: String?        // Additional qualifier
}

struct SRSchedule: Codable {
    var easeFactor: Double      // 1.3 - 3.0 (SM-2)
    var intervalDays: Double    // Days until next review
    var repetitions: Int        // Times reviewed
    var dueDate: Date
    var maturityLevel: MaturityLevel
}

enum MaturityLevel: String, Codable {
    case new
    case learning
    case young
    case mature
}

@MainActor
class SpacedRepetitionStore: ObservableObject {
    @Published var schedules: [SRItemID: SRSchedule] = [:]

    func getDueItems(limit: Int = 50) -> [SRItemID] { ... }
    func recordReview(id: SRItemID, quality: Int) { ... }  // quality: 0-5
}
```

### 12.5 New/Modified Models

```swift
// PlayerLevel.swift (New - replaces Rank)
struct PlayerLevel {
    let level: Int
    let currentXP: Int
    let xpForNextLevel: Int

    var progressToNextLevel: Double {
        let xpIntoLevel = currentXP - xpForLevel(level)
        let xpNeeded = xpForNextLevel - xpForLevel(level)
        return Double(xpIntoLevel) / Double(xpNeeded)
    }

    private func xpForLevel(_ level: Int) -> Int {
        // Quadratic growth: level 1 = 0, level 2 = 100, level 3 = 400, etc.
        return (level - 1) * (level - 1) * 100
    }
}

// Achievement.swift (Simplified)
struct Achievement: Identifiable, Codable {
    let id: String              // "chords_100", "streak_7", etc.
    let title: String           // "100 Chords"
    let description: String     // "Spell 100 chords correctly"
    let category: AchievementCategory
    let icon: String            // SF Symbol name
    var unlockedDate: Date?
}

enum AchievementCategory: String, Codable {
    case milestone
    case accuracy
    case consistency
    case mastery
    case curriculum
}
```

---

## 13. UI Component Library

### 13.1 Buttons

#### Primary Button
```swift
struct PrimaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.accent)
                .cornerRadius(12)
        }
    }
}
```

#### Secondary Button
```swift
struct SecondaryButton: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.accent, lineWidth: 2)
                )
        }
    }
}
```

### 13.2 Cards

#### Standard Card
```swift
struct StandardCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .background(Color.surface)
            .cornerRadius(16)
            .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
```

#### Highlighted Card (for Quick Practice)
```swift
struct HighlightedCard<Content: View>: View {
    let content: Content

    var body: some View {
        content
            .padding(16)
            .background(Color.accent.opacity(0.1))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.accent, lineWidth: 2)
            )
    }
}
```

### 13.3 Piano Keyboard

Preserve existing `PianoKeyboard.swift` with these specifications:

| Property | Value |
|----------|-------|
| Range | A2 to E5 (practical piano range for chords) |
| White Key Width | 44pt (iPhone), 56pt (iPad) |
| Black Key Width | 60% of white key |
| Key Height | 180pt (white), 110pt (black) |
| Selection State | Filled accent color with checkmark |
| Incorrect State | Red fill (during feedback) |
| Correct State | Green fill (during feedback) |

### 13.4 Progress Indicators

#### Linear Progress Bar
```swift
struct ProgressBar: View {
    let progress: Double  // 0.0 - 1.0
    let color: Color

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .cornerRadius(4)

                Rectangle()
                    .fill(color)
                    .cornerRadius(4)
                    .frame(width: geometry.size.width * progress)
            }
        }
        .frame(height: 8)
    }
}
```

#### Session Progress (Question X of Y)
```swift
struct SessionProgress: View {
    let current: Int
    let total: Int

    var body: some View {
        VStack(spacing: 4) {
            ProgressBar(
                progress: Double(current) / Double(total),
                color: .accent
            )
            Text("\(current) of \(total)")
                .font(.caption)
                .foregroundColor(.muted)
        }
    }
}
```

### 13.5 Feedback States

#### Correct Answer Feedback
```swift
struct CorrectFeedback: View {
    let message: String
    let detail: String?

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.success)
                Text("Correct")
                    .font(.headline)
                    .foregroundColor(.success)
            }

            if let detail = detail {
                Text(detail)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.success.opacity(0.1))
        .cornerRadius(12)
    }
}
```

#### Incorrect Answer Feedback
```swift
struct IncorrectFeedback: View {
    let correctAnswer: String
    let userAnswer: String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.error)
                Text("Incorrect")
                    .font(.headline)
                    .foregroundColor(.error)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("Correct: \(correctAnswer)")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                Text("Your answer: \(userAnswer)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.error.opacity(0.1))
        .cornerRadius(12)
    }
}
```

---

## 14. Technical Requirements

### 14.1 Platform Requirements

| Requirement | Value |
|-------------|-------|
| Minimum iOS | 17.0 |
| Swift Version | 5.9+ |
| Xcode | 15.0+ |
| Frameworks | SwiftUI, AVFoundation, Combine |

### 14.2 Architecture Principles

1. **MVVM Pattern:** Views observe ObservableObject view models
2. **Single Source of Truth:** Game state in dedicated state managers
3. **Environment Injection:** Shared managers via @EnvironmentObject
4. **Persistence:** UserDefaults for settings, JSON files for statistics

### 14.3 File Organization

```
ShedPro/
├── App/
│   ├── ShedProApp.swift
│   └── ContentView.swift
│
├── Features/
│   ├── Home/
│   │   ├── HomeView.swift
│   │   ├── QuickPracticeCard.swift
│   │   ├── ContinueLearningCard.swift
│   │   └── DailyFocusCard.swift
│   │
│   ├── ChordDrill/
│   │   ├── ChordDrillView.swift
│   │   ├── ChordDrillSetup.swift
│   │   ├── ChordDrillSession.swift
│   │   ├── ChordDrillResults.swift
│   │   └── ChordDrillGame.swift
│   │
│   ├── CadenceDrill/
│   │   └── ... (parallel structure)
│   │
│   ├── ScaleDrill/
│   │   └── ...
│   │
│   ├── IntervalDrill/
│   │   └── ...
│   │
│   ├── Curriculum/
│   │   ├── CurriculumView.swift
│   │   ├── PathwaySelector.swift
│   │   ├── ModuleCard.swift
│   │   └── ModuleDetailView.swift
│   │
│   ├── Progress/
│   │   ├── ProgressView.swift
│   │   ├── StatsOverview.swift
│   │   ├── KeyBreakdown.swift
│   │   └── AchievementsList.swift
│   │
│   └── Settings/
│       └── SettingsView.swift
│
├── Core/
│   ├── Models/
│   │   ├── Note.swift
│   │   ├── ChordTone.swift
│   │   ├── ChordType.swift
│   │   ├── Chord.swift
│   │   ├── ScaleType.swift
│   │   ├── Scale.swift
│   │   ├── IntervalType.swift
│   │   └── Cadence.swift
│   │
│   ├── Databases/
│   │   ├── ChordDatabase.swift
│   │   ├── ScaleDatabase.swift
│   │   ├── IntervalDatabase.swift
│   │   ├── CadenceDatabase.swift
│   │   └── CurriculumDatabase.swift
│   │
│   ├── Services/
│   │   ├── AudioManager.swift
│   │   ├── SpacedRepetitionStore.swift
│   │   ├── StatisticsManager.swift
│   │   ├── CurriculumManager.swift
│   │   └── SettingsManager.swift
│   │
│   └── Utilities/
│       ├── Extensions.swift
│       └── Constants.swift
│
├── Components/
│   ├── PianoKeyboard.swift
│   ├── PrimaryButton.swift
│   ├── SecondaryButton.swift
│   ├── StandardCard.swift
│   ├── ProgressBar.swift
│   ├── FeedbackViews.swift
│   └── FlowLayout.swift
│
└── Resources/
    ├── Assets.xcassets/
    └── Sounds/
        └── Piano.sf2
```

### 14.4 State Management

```swift
@main
struct ShedProApp: App {
    @StateObject private var settings = SettingsManager.shared
    @StateObject private var statistics = StatisticsManager.shared
    @StateObject private var spacedRep = SpacedRepetitionStore.shared
    @StateObject private var curriculum = CurriculumManager.shared
    @StateObject private var audio = AudioManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(statistics)
                .environmentObject(spacedRep)
                .environmentObject(curriculum)
                .environmentObject(audio)
        }
    }
}
```

### 14.5 Testing Requirements

| Test Type | Coverage Target |
|-----------|-----------------|
| Unit Tests (Models) | 90% |
| Unit Tests (Game Logic) | 85% |
| Unit Tests (SR Algorithm) | 95% |
| UI Tests (Critical Flows) | Key user journeys |

Priority test cases:
1. Chord spelling answer validation
2. Spaced repetition scheduling
3. Statistics calculation
4. Curriculum progression logic
5. Quick Practice session generation

---

## Appendix A: Migration Notes

### From Current Codebase

#### Files to Keep (With Modifications)
- `ChordModel.swift` → Rename to `Core/Models/Chord.swift`
- `ScaleModel.swift` → `Core/Models/Scale.swift`
- `IntervalModel.swift` → `Core/Models/Interval.swift`
- `JazzChordDatabase.swift` → `Core/Databases/ChordDatabase.swift`
- `JazzScaleDatabase.swift` → `Core/Databases/ScaleDatabase.swift`
- `AudioManager.swift` → `Core/Services/AudioManager.swift`
- `SpacedRepetition.swift` → `Core/Services/SpacedRepetitionStore.swift`
- `CurriculumDatabase.swift` → `Core/Databases/CurriculumDatabase.swift`
- `PianoKeyboard.swift` → `Components/PianoKeyboard.swift`

#### Files to Refactor Significantly
- `ChordDrillView.swift` → Split into Setup/Session/Results
- `CadenceDrillView.swift` → Split and simplify drill modes
- `ContentView.swift` → Redesign for new home screen
- `PlayerProfile.swift` → Simplify, remove Rank system

#### Files to Remove
- `ScoreboardView.swift` (leaderboards not in v2.0)
- `CadenceScoreboardView.swift`

### Breaking Changes
1. Rank/Title system replaced with simple Level
2. Achievement names simplified
3. Cadence drill modes consolidated (9 → 6)
4. Chord font option removed
5. Navigation restructured to tab-based

---

## Appendix B: Future Considerations (Post v2.0)

These features are explicitly **not in scope** for v2.0 but should be considered for future releases:

1. **Voice Leading Trainer** - Dedicated drill for optimal voicing choices
2. **Tune-Based Drilling** - Practice changes for specific standards
3. **Transcription Helper** - Inverse lookup (notes → chord symbol)
4. **iReal Pro Integration** - URL scheme to open specific tunes
5. **Teacher Dashboard** - Assign modules, track student progress
6. **Daily Challenges** - Global challenges with anonymized leaderboards
7. **iPad Optimization** - Larger keyboard, side-by-side views
8. **MIDI Input** - Connect external keyboard for input
9. **Apple Watch** - Quick interval ear training on wrist

---

## Document History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2024 | Original | Initial implementation |
| 2.0 | Jan 2025 | Consultation | Complete redesign per strategic review |

---

*End of Design Document*
