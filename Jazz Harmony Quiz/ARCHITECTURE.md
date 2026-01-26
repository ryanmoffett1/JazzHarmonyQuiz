# Jazz Harmony Quiz - Architecture Documentation

> **Last Updated:** January 2026
> **Version:** 2.0
> **Platform:** iOS (SwiftUI)

## Table of Contents

1. [Overview](#overview)
2. [Technology Stack](#technology-stack)
3. [Project Structure](#project-structure)
4. [App Modes & Features](#app-modes--features)
5. [Data Models](#data-models)
6. [View Architecture](#view-architecture)
7. [Audio System](#audio-system)
8. [State Management](#state-management)
9. [Learning Systems](#learning-systems)
10. [Player Progression](#player-progression)
11. [Settings & Configuration](#settings--configuration)
12. [File Reference](#file-reference)

---

## Overview

Jazz Harmony Quiz is a comprehensive music education app designed to teach jazz harmony concepts through interactive drills and ear training exercises. The app features five primary practice modes, a structured curriculum system, spaced repetition for optimized learning, and gamification elements including achievements, ranks, and XP.

### Core Educational Goals

- **Chord Recognition**: Identify chord tones, qualities, and voicings
- **Cadence Mastery**: Learn ii-V-I progressions and jazz cadence patterns
- **Scale Fluency**: Practice modes, jazz scales, and scale degrees
- **Interval Training**: Develop ear training through interval identification
- **Progression Understanding**: Learn common jazz chord progressions

---

## Technology Stack

| Component | Technology |
|-----------|------------|
| **Framework** | SwiftUI |
| **Audio Engine** | AVFoundation (AVAudioEngine + AVAudioUnitSampler) |
| **Reactive State** | Combine Framework |
| **Persistence** | UserDefaults (JSON encoding) |
| **Sound Files** | SoundFont (.sf2) format |
| **Minimum iOS** | iOS 16+ |

---

## Project Structure

The project follows a Feature-based architecture for better modularity:

```
JazzHarmonyQuiz/
├── App/
│   ├── ShedProApp.swift              # App entry point
│   └── ContentView.swift             # Main navigation hub
│
├── Core/
│   ├── Databases/                    # Static data definitions
│   │   ├── CadenceDatabase.swift     # Cadence types
│   │   ├── ChordDatabase.swift       # 30+ chord types
│   │   ├── CurriculumDatabase.swift  # Learning modules
│   │   ├── IntervalDatabase.swift    # Interval definitions
│   │   └── ScaleDatabase.swift       # Jazz scale definitions
│   │
│   ├── Models/                       # Core data types
│   │   ├── Chord.swift               # Chord structure
│   │   ├── ChordTone.swift           # Individual chord tones
│   │   ├── ChordType.swift           # Chord type definitions
│   │   ├── DrillState.swift          # Drill state machine
│   │   ├── Interval.swift            # Interval structure
│   │   ├── Note.swift                # Note representation
│   │   ├── PlayerLevel.swift         # XP & leveling
│   │   └── Scale.swift               # Scale structure
│   │
│   └── Services/                     # Business logic
│       ├── AudioManager.swift        # MIDI synthesis
│       ├── CurriculumManager.swift   # Module progression
│       ├── QuickPracticeGenerator.swift # Smart practice sessions
│       ├── SettingsManager.swift     # App settings singleton
│       └── SpacedRepetitionStore.swift # SM-2 algorithm
│
├── Features/                         # Feature modules
│   ├── CadenceDrill/                 # Cadence practice
│   │   ├── CadenceDrillGame.swift
│   │   ├── CadenceDrillResults.swift
│   │   ├── CadenceDrillSession.swift
│   │   └── CadenceDrillSetup.swift
│   │
│   ├── ChordDrill/                   # Chord practice
│   │   ├── ChordDrillGame.swift
│   │   ├── ChordDrillResults.swift
│   │   ├── ChordDrillSession.swift
│   │   └── ChordDrillSetup.swift
│   │
│   ├── Curriculum/                   # Learning pathways
│   │   ├── CurriculumView.swift
│   │   ├── ModuleCard.swift
│   │   └── ModuleDetailView.swift
│   │
│   ├── Home/                         # Main navigation
│   │   └── HomeView.swift
│   │
│   ├── IntervalDrill/                # Interval practice
│   │   ├── IntervalDrillSession.swift
│   │   └── IntervalDrillSetup.swift
│   │
│   ├── Practice/                     # Quick practice
│   │   ├── QuickPracticeSession.swift
│   │   └── QuickPracticeView.swift
│   │
│   ├── Progress/                     # Player stats
│   │   └── ProgressView.swift
│   │
│   ├── ScaleDrill/                   # Scale practice
│   │   ├── ScaleDrillSession.swift
│   │   └── ScaleDrillSetup.swift
│   │
│   └── Settings/                     # App settings
│       └── SettingsView.swift
│
├── Components/                       # Shared UI components
│   ├── Buttons.swift
│   ├── Cards.swift
│   ├── Feedback.swift
│   ├── FlowLayout.swift
│   ├── PianoKeyboard.swift
│   └── Progress.swift
│
├── Helpers/                          # Utilities
│   └── EncouragementEngine.swift
│
├── Models/                           # Game state (legacy)
│   ├── CadenceGame.swift
│   ├── IntervalGame.swift
│   ├── QuizGame.swift
│   └── ScaleGame.swift
│
├── Fonts/                            # Custom fonts
│   └── Caveat-*.ttf
│
└── Assets.xcassets/                  # Images & colors
```

### Test Structure

```
JazzHarmonyQuizTests/
├── Core/
│   ├── Models/
│   │   ├── ChordTests.swift
│   │   ├── IntervalTests.swift
│   │   ├── NoteTests.swift
│   │   ├── PlayerLevelTests.swift
│   │   └── ScaleTests.swift
│   │
│   └── Services/
│       ├── QuickPracticeGeneratorTests.swift
│       ├── SettingsManagerTests.swift
│       └── SpacedRepetitionStoreTests.swift
│
└── Features/
    ├── ChordDrill/
    │   └── ChordDrillGameTests.swift
    ├── CadenceDrill/
    │   └── CadenceGameTests.swift
    ├── Curriculum/
    │   └── CurriculumTests.swift
    ├── IntervalDrill/
    │   └── IntervalGameTests.swift
    └── ScaleDrill/
        └── ScaleGameTests.swift
```

---

## App Modes & Features

### 1. Chord Drill (`ChordDrillView`)

Interactive chord identification and spelling practice.

#### Question Types

| Type | Description |
|------|-------------|
| **Single Tone** | Identify a specific chord tone (Root, 3rd, 5th, 7th, etc.) |
| **All Tones** | Identify all notes in the chord on a piano keyboard |
| **Aural Quality** | Hear a chord and identify its quality (ear training) |
| **Aural Spelling** | Hear a chord and identify all its notes by ear |

#### Difficulty Levels

| Level | Chord Types Included |
|-------|---------------------|
| **Beginner** | Major, Minor, Dominant 7 |
| **Intermediate** | + Maj7, Min7, Dim7, Half-Dim |
| **Advanced** | + Aug, Sus4, 9ths, 11ths |
| **Expert** | + Altered, 13ths, Polychords |

#### Features
- Interactive piano keyboard UI (A2-E5 range)
- Real-time audio playback (block/arpeggio styles)
- Key filtering by difficulty tier
- Chord symbol filtering for focused practice
- Visual feedback with color-coded correctness
- Rating-based scoring with difficulty multipliers

---

### 2. Cadence Drill (`CadenceDrillView`)

Master jazz cadences and ii-V-I progressions.

#### Cadence Types

| Type | Progression | Description |
|------|------------|-------------|
| **Major ii-V-I** | Dm7 → G7 → CMaj7 | Standard jazz cadence |
| **Minor ii-V-I** | Dm7♭5 → G7alt → Cm7 | Minor key resolution |
| **Tritone Substitution** | Dm7 → D♭7 → CMaj7 | ♭II7 replaces V7 |
| **Backdoor ii-V** | Fm7 → B♭7 → CMaj7 | ♭VII7 approach |
| **Bird Changes** | Complex bebop pattern | Advanced substitutions |

#### Drill Modes (9 total)

| Mode | Focus |
|------|-------|
| **Chord Identification** | Name individual chords in context |
| **Full Progression** | Identify entire cadence sequence |
| **Isolated Chord** | Focus on specific chord function |
| **Speed Round** | Timed rapid identification |
| **Common Tones** | Find shared notes between chords |
| **Aural Identify** | Ear training for cadences |
| **Guide Tones** | Identify 3rds and 7ths voice leading |
| **Resolution Targets** | Understand melodic destinations |
| **Smooth Voicing** | Practice voice leading principles |

#### Features
- 4-level hint system (subtle → explicit)
- Extended V chord options (♭9, #9, ♭13, etc.)
- Color-coded chord functions (tonic, subdominant, dominant)
- Visual guide tone highlighting
- Timer-based challenges
- BPM-controlled progression playback

---

### 3. Scale Drill (`ScaleDrillView`)

Practice scale degrees and modal recognition.

#### Question Types

| Type | Description |
|------|-------------|
| **All Degrees** | Identify all notes in a scale |
| **Single Degree** | Name a specific scale degree |
| **Identify Quality by Ear** | Hear scale and identify type |

#### Scale Types

| Category | Scales |
|----------|--------|
| **Basic** | Major, Natural Minor |
| **Modes** | Dorian, Phrygian, Lydian, Mixolydian, Aeolian, Locrian |
| **Jazz** | Blues, Pentatonic Major/Minor |
| **Advanced** | Harmonic Minor, Melodic Minor, Whole Tone, Diminished |

#### Difficulty Tiers (by Key)

| Tier | Keys |
|------|------|
| **Easy** | C, G, F (0-1 accidentals) |
| **Medium** | D, B♭, A, E♭ (2-3 accidentals) |
| **Hard** | E, A♭, B, D♭ (4-5 accidentals) |
| **Expert** | F#/G♭, C#/D♭ (6-7 accidentals) |

---

### 4. Interval Drill (`IntervalDrillView`)

Develop interval recognition through visual and aural training.

#### Question Types

| Type | Description |
|------|-------------|
| **Build Interval** | Select the correct note for an interval |
| **Identify Quality by Ear** | Hear interval, identify type |
| **Name Interval** | See two notes, name the interval |

#### Difficulty Levels

| Level | Intervals Included |
|-------|-------------------|
| **Beginner** | P1, M2, M3, P4, P5, M6, M7, P8 |
| **Intermediate** | + m2, m3, m6, m7, Aug4/Dim5 |
| **Advanced** | All intervals including compound |

#### Direction Options
- **Ascending**: Lower note first
- **Descending**: Higher note first
- **Both**: Random direction

#### Playback Styles
- **Harmonic**: Both notes simultaneously
- **Melodic**: Notes sequentially

---

### 5. Progression Drill (`ProgressionDrillView`)

Learn common jazz chord progressions beyond ii-V-I.

#### Categories

| Category | Examples |
|----------|----------|
| **Turnaround** | I-vi-ii-V, III-VI-II-V |
| **Suspension** | Sus4 resolutions, pedal tones |
| **Modulation** | Key change patterns |
| **Standard** | Common jazz standards patterns |

#### Practice Modes
- **Visual**: See and identify progressions
- **Aural**: Hear and identify progressions
- **Mixed**: Combination of both

---

## Data Models

### Core Musical Models

```
┌─────────────────────────────────────────────────────────────┐
│                        Note                                  │
│  - name: String (C, D, E, etc.)                             │
│  - octave: Int                                               │
│  - midiNumber: Int                                           │
│  - frequency: Double                                         │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      ChordTone                               │
│  - note: Note                                                │
│  - function: String (Root, 3rd, 5th, 7th, 9th, etc.)       │
│  - interval: Int (semitones from root)                      │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      ChordType                               │
│  - name: String (Major 7, Dominant 7, etc.)                 │
│  - symbol: String (Maj7, 7, m7, etc.)                       │
│  - intervals: [Int]                                          │
│  - difficulty: ChordDifficulty                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        Chord                                 │
│  - root: Note                                                │
│  - type: ChordType                                           │
│  - tones: [ChordTone]                                        │
│  - symbol: String (CMaj7, Dm7, G7, etc.)                    │
└─────────────────────────────────────────────────────────────┘
```

### Scale Models

```swift
struct Scale {
    let root: Note
    let type: ScaleType
    let degrees: [ScaleDegree]
}

enum ScaleType {
    case major, minor, dorian, phrygian, lydian
    case mixolydian, aeolian, locrian
    case blues, pentatonicMajor, pentatonicMinor
    case harmonicMinor, melodicMinor
    case wholeTone, diminished
}

struct ScaleDegree {
    let degree: Int          // 1-7
    let note: Note
    let quality: String      // "major", "minor", "perfect"
}
```

### Interval Models

```swift
struct Interval {
    let quality: IntervalQuality    // Perfect, Major, Minor, Augmented, Diminished
    let number: Int                 // 1-8 (unison to octave)
    let semitones: Int
    let name: String                // "Perfect Fifth", "Major Third"
}

enum IntervalDirection {
    case ascending, descending, both
}
```

### Cadence Models

```swift
struct CadenceProgression {
    let type: CadenceType
    let key: Note
    let chords: [Chord]
    let romanNumerals: [String]     // ["ii", "V", "I"]
    let functions: [ChordFunction]   // [.subdominant, .dominant, .tonic]
}

enum CadenceType {
    case majorTwoFiveOne
    case minorTwoFiveOne
    case tritoneSubstitution
    case backdoorTwoFive
    case birdChanges
}
```

### Game State Models

Each drill mode has a corresponding game model:

```swift
// Pattern followed by all game models
@MainActor
class QuizGame: ObservableObject {
    @Published var questions: [QuizQuestion] = []
    @Published var currentQuestionIndex: Int = 0
    @Published var answers: [UUID: UserAnswer] = [:]
    @Published var isComplete: Bool = false
    @Published var results: [QuizResult] = []

    // Configuration
    var difficulty: Difficulty
    var questionTypes: Set<QuestionType>
    var numberOfQuestions: Int

    // Scoring
    var totalCorrect: Int
    var accuracy: Double
    var ratingChange: Int
}
```

| Game Model | View | Purpose |
|------------|------|---------|
| `QuizGame` | ChordDrillView | Chord drill state |
| `CadenceGame` | CadenceDrillView | Cadence drill state |
| `ScaleGame` | ScaleDrillView | Scale drill state |
| `IntervalGame` | IntervalDrillView | Interval drill state |
| `ProgressionGame` | ProgressionDrillView | Progression drill state |

---

## View Architecture

### Navigation Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    ContentView (Home Hub)                    │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  StatsDashboardCard                                     ││
│  │  - Player avatar, rank, XP                              ││
│  │  - Current streak, daily stats                          ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │  DrillOptionsSection                                    ││
│  │  - 6 practice mode buttons                              ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │  ProgressCardsSection                                   ││
│  │  - Weekly stats, recommendations                        ││
│  └─────────────────────────────────────────────────────────┘│
│  ┌─────────────────────────────────────────────────────────┐│
│  │  PracticeDueCard (Spaced Repetition)                   ││
│  │  - Items due for review                                 ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
                              │
        ┌─────────────────────┼─────────────────────┐
        ▼                     ▼                     ▼
┌───────────────┐    ┌───────────────┐    ┌───────────────┐
│  ChordDrill   │    │  CadenceDrill │    │   ScaleDrill  │
│     View      │    │     View      │    │     View      │
└───────────────┘    └───────────────┘    └───────────────┘
        │                     │                     │
        └─────────────────────┼─────────────────────┘
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                    Drill View Pattern                        │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  ViewState.setup                                        ││
│  │  - Configuration options                                ││
│  │  - Difficulty, question types                           ││
│  │  - [Start Quiz] button                                  ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                               │
│                              ▼                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  ViewState.active                                       ││
│  │  - Current question display                             ││
│  │  - Interactive input (piano, buttons)                   ││
│  │  - Audio playback controls                              ││
│  │  - Progress indicator                                   ││
│  └─────────────────────────────────────────────────────────┘│
│                              │                               │
│                              ▼                               │
│  ┌─────────────────────────────────────────────────────────┐│
│  │  ViewState.results                                      ││
│  │  - Score summary                                        ││
│  │  - Rating change (+/- XP)                               ││
│  │  - Question breakdown                                   ││
│  │  - [New Quiz] / [Home] buttons                         ││
│  └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

### Reusable Components

| Component | File | Purpose |
|-----------|------|---------|
| `PianoKeyboard` | PianoKeyboard.swift | Interactive piano with selectable keys |
| `ChordSelectorView` | ChordSelectorView.swift | Root note + quality picker |
| `ResultsView` | ResultsView.swift | Generic quiz results display |
| `PracticeDueCard` | PracticeDueCard.swift | SR due items widget |
| `FlowLayout` | FlowLayout.swift | Flexible grid layout |

---

## Audio System

### AudioManager Architecture

```swift
class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private let audioEngine: AVAudioEngine
    private let sampler: AVAudioUnitSampler

    // State tracking
    @Published var isPlaying: Bool = false
    private var activeNotes: Set<UInt8> = []
    private var playbackGeneration: Int = 0  // For cancellation

    // Playback methods
    func playNote(_ midiNote: UInt8, velocity: UInt8, duration: TimeInterval)
    func playChord(_ notes: [UInt8], style: ChordStyle, tempo: Double)
    func playInterval(_ note1: UInt8, _ note2: UInt8, style: IntervalStyle)
    func playProgression(_ chords: [[UInt8]], bpm: Double)
    func stopAll()
}
```

### Sound Sources

1. **Bundled SoundFont** (Primary): `Piano.sf2` in app bundle
2. **System DLS** (Fallback): Built-in MIDI sounds (simulator)
3. **Sine Wave** (Emergency): Programmatic tone generation

### Playback Styles

```swift
enum ChordStyle {
    case block      // All notes simultaneously
    case arpeggio   // Notes in ascending sequence
}

enum IntervalStyle {
    case harmonic   // Both notes together
    case melodic    // Notes sequentially
}
```

### Audio Integration Points

| View | Audio Feature |
|------|---------------|
| ChordDrillView | Chord playback, correct answer feedback |
| CadenceDrillView | Progression playback, individual chord preview |
| ScaleDrillView | Scale playback (ascending/descending) |
| IntervalDrillView | Interval playback (harmonic/melodic) |
| ProgressionDrillView | Full progression playback |

---

## State Management

### Architecture Pattern

The app uses **MVVM with Reactive State** through SwiftUI's property wrappers and Combine.

### State Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│               JazzHarmonyQuizApp (Entry Point)               │
│                                                              │
│  @StateObject var quizGame = QuizGame()                     │
│  @StateObject var cadenceGame = CadenceGame()               │
│  @StateObject var scaleGame = ScaleGame()                   │
│  @StateObject var intervalGame = IntervalGame()             │
│  @StateObject var settings = SettingsManager.shared         │
│                                                              │
│  .environmentObject(quizGame)                               │
│  .environmentObject(cadenceGame)                            │
│  .environmentObject(scaleGame)                              │
│  .environmentObject(intervalGame)                           │
│  .environmentObject(settings)                               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                        ContentView                           │
│                                                              │
│  @EnvironmentObject var quizGame: QuizGame                  │
│  @EnvironmentObject var settings: SettingsManager           │
│                                                              │
│  @State var navigationPath: [String] = []                   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DrillViews                              │
│                                                              │
│  @EnvironmentObject var game: [Mode]Game                    │
│  @State var viewState: ViewState                            │
│  @State var selectedNotes: Set<Note>                        │
│  @State var showingHint: Bool                               │
└─────────────────────────────────────────────────────────────┘
```

### Singleton Managers

| Manager | Purpose | Persistence |
|---------|---------|-------------|
| `AudioManager.shared` | Audio playback | None (runtime only) |
| `PlayerProfile.shared` | XP, achievements, stats | UserDefaults |
| `SettingsManager.shared` | App preferences | UserDefaults |
| `SpacedRepetitionStore.shared` | SR schedules | UserDefaults |
| `CurriculumManager.shared` | Module progress | UserDefaults |

### Persistence Flow

```
Model Property Change
        │
        ▼
@Published didSet { save() }
        │
        ▼
JSONEncoder → Data
        │
        ▼
UserDefaults.standard.set(data, forKey: "key")
        │
        ▼
App Launch: loadFromUserDefaults()
        │
        ▼
Data → JSONDecoder → Model
```

---

## Learning Systems

### Curriculum System

#### Pathways (4 total)

| Pathway | Focus | Modules |
|---------|-------|---------|
| **Harmony Foundations** | Basic chord theory | Triads → 7th chords → Extensions |
| **Functional Harmony** | Chord progressions | ii-V-I → Substitutions → Standards |
| **Ear Training** | Aural skills | Intervals → Chords → Cadences |
| **Advanced Topics** | Complex concepts | Modes → Alterations → Polychords |

#### Module Structure

```swift
struct CurriculumModule: Identifiable {
    let id: UUID
    let name: String
    let description: String
    let pathway: CurriculumPathway
    let mode: CurriculumPracticeMode      // chords, scales, cadences, intervals
    let recommendedConfig: ModuleConfig    // Pre-configured drill settings
    let completionCriteria: CompletionCriteria
    let prerequisiteModuleIDs: [UUID]
}

struct CompletionCriteria {
    let minimumAttempts: Int       // e.g., 20 questions
    let minimumAccuracy: Double    // e.g., 0.80 (80%)
    let perfectSessions: Int       // e.g., 2 perfect scores
}

struct ModuleProgress {
    var attempts: Int
    var correctAnswers: Int
    var perfectSessions: Int
    var isCompleted: Bool
    var lastAttemptDate: Date?
}
```

### Spaced Repetition System

The app implements the **SM-2 algorithm** for optimized review scheduling.

#### SM-2 Algorithm Overview

```
On correct answer:
  - repetitions += 1
  - easeFactor += 0.1 (capped at 3.0)
  - intervalDays = previousInterval * easeFactor

On incorrect answer:
  - repetitions = 0
  - easeFactor -= 0.2 (minimum 1.3)
  - intervalDays = 1 (reset)

dueDate = lastReview + intervalDays
```

#### Maturity Levels

| Level | Criteria | Icon |
|-------|----------|------|
| **New** | Never reviewed | 🆕 |
| **Learning** | < 3 successful reviews | 📖 |
| **Young** | 3-7 successful reviews | 🌱 |
| **Mature** | 8+ successful reviews | 🌳 |

#### SR Item Identification

```swift
struct SRItemID: Hashable, Codable {
    let mode: PracticeMode        // .chords, .scales, .intervals, etc.
    let topic: String             // "CMaj7", "Dorian", "Perfect Fifth"
    let key: String?              // "C", "G", etc. (optional)
    let variant: String?          // "ascending", "harmonic" (optional)
}
```

---

## Player Progression

### Rating/XP System

- **Starting Rating**: 1000 XP ("Jam Session Ready")
- **Range**: 0 - 3000+ XP
- **Gain/Loss**: Based on question difficulty and performance

#### Rating Calculation

```swift
func calculateRatingChange(correct: Bool, difficulty: Difficulty, streak: Int) -> Int {
    let baseChange = difficulty.basePoints  // 10-40 based on difficulty
    let streakBonus = min(streak * 2, 20)   // Up to +20 for streaks

    if correct {
        return baseChange + streakBonus
    } else {
        return -(baseChange / 2)  // Lose half points for wrong
    }
}
```

### Rank System (12 Tiers)

| Tier | Rank Name | XP Required |
|------|-----------|-------------|
| 1 | Shed Rat | 0 |
| 2 | Practice Room Regular | 200 |
| 3 | Jam Session Ready | 500 |
| 4 | Gigging Musician | 800 |
| 5 | Session Player | 1100 |
| 6 | Bandleader | 1500 |
| 7 | Recording Artist | 1900 |
| 8 | Jazz Educator | 2400 |
| 9 | Clinician | 2900 |
| 10 | Master Class | 3500 |
| 11 | Jazz Legend | 4200 |
| 12 | Living Legend | 5000+ |

### Achievements (19 Types)

| Category | Achievements |
|----------|--------------|
| **Milestones** | First Quiz, 100 Questions, 500 Questions, 1000 Questions |
| **Accuracy** | Perfect Score, 10 Perfect Scores, 90% Accuracy |
| **Streaks** | 7-Day Streak, 30-Day Streak, 100-Day Streak |
| **Rank** | Reach each rank tier |
| **Mastery** | Master all chord types, all scales, all intervals |
| **Speed** | Complete speed round under time limit |
| **Variety** | Practice all 5 modes in one day |

### Player Stats Tracking

```swift
struct ModeStatistics: Codable {
    var totalQuestions: Int
    var correctAnswers: Int
    var totalTimeSeconds: Double
    var sessionsCompleted: Int
    var highScores: [ScoreEntry]

    var accuracy: Double {
        totalQuestions > 0 ? Double(correctAnswers) / Double(totalQuestions) : 0
    }
}

class PlayerProfile: ObservableObject {
    @Published var currentRating: Int = 1000
    @Published var currentStreak: Int = 0
    @Published var longestStreak: Int = 0
    @Published var unlockedAchievements: [Achievement] = []
    @Published var modeStats: [PracticeMode: ModeStatistics] = [:]
    @Published var lastPracticeDate: Date?
}
```

---

## Settings & Configuration

### Theme Settings

| Setting | Options | Default |
|---------|---------|---------|
| `appTheme` | Light, Dark, System | System |
| `chordFont` | System, Caveat | System |

### Audio Settings

| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `audioEnabled` | Bool | true | Master audio toggle |
| `audioVolume` | Double | 0.8 | Volume level (0-1) |
| `playChordOnCorrect` | Bool | true | Sound on correct answer |
| `autoPlayIntervals` | Bool | true | Auto-play interval on question |
| `autoPlayChords` | Bool | true | Auto-play chord on question |
| `autoPlayCadences` | Bool | true | Auto-play cadence on question |
| `defaultIntervalStyle` | IntervalStyle | .harmonic | Interval playback default |
| `defaultChordStyle` | ChordStyle | .block | Chord playback default |
| `intervalTempo` | Double | 1.0 | Interval note duration |
| `chordTempo` | Double | 1.0 | Chord note duration |
| `cadenceBPM` | Double | 120 | Cadence progression tempo |

### Per-Drill Configuration

Each drill stores session configuration:

```swift
// ChordDrill
@Published var difficulty: ChordDifficulty = .beginner
@Published var questionTypes: Set<ChordQuestionType> = [.singleTone]
@Published var keyDifficulty: KeyDifficulty = .all
@Published var selectedChordSymbols: Set<String> = []
@Published var numberOfQuestions: Int = 10

// CadenceDrill
@Published var cadenceType: CadenceType = .majorTwoFiveOne
@Published var drillMode: CadenceDrillMode = .chordIdentification
@Published var includeExtendedDominant: Bool = false
@Published var hintLevel: Int = 0

// Similar patterns for Scale, Interval, Progression drills
```

---

## File Reference

### Models (20 files)

| File | Lines | Purpose |
|------|-------|---------|
| `ChordModel.swift` | ~2000 | Core chord data structures, enums |
| `ScaleModel.swift` | ~400 | Scale data structures |
| `IntervalModel.swift` | ~300 | Interval data structures |
| `ProgressionProgression.swift` | ~80 | Progression data |
| `ConceptualExplanations.swift` | ~1200 | Theory content |
| `QuizGame.swift` | ~1500 | Chord drill game logic |
| `CadenceGame.swift` | ~2200 | Cadence drill game logic |
| `ScaleGame.swift` | ~900 | Scale drill game logic |
| `IntervalGame.swift` | ~500 | Interval drill game logic |
| `ProgressionGame.swift` | ~600 | Progression drill game logic |
| `JazzChordDatabase.swift` | ~900 | 30+ chord type definitions |
| `JazzScaleDatabase.swift` | ~500 | Scale definitions |
| `IntervalDatabase.swift` | ~300 | Interval definitions |
| `ProgressionDatabase.swift` | ~1900 | Progression templates |
| `CurriculumDatabase.swift` | ~1000 | Learning module definitions |
| `PlayerProfile.swift` | ~700 | Player stats, achievements |
| `SettingsManager.swift` | ~350 | App settings |
| `SpacedRepetition.swift` | ~400 | SM-2 algorithm |
| `CurriculumManager.swift` | ~250 | Module progression |
| `CurriculumModule.swift` | ~280 | Module structure |

### Views (14 files)

| File | Lines | Purpose |
|------|-------|---------|
| `ChordDrillView.swift` | ~2600 | Chord practice UI |
| `CadenceDrillView.swift` | ~4400 | Cadence practice UI (largest) |
| `ScaleDrillView.swift` | ~2600 | Scale practice UI |
| `IntervalDrillView.swift` | ~1500 | Interval practice UI |
| `ProgressionDrillView.swift` | ~1600 | Progression practice UI |
| `ChordSelectorView.swift` | ~350 | Chord picker component |
| `PianoKeyboard.swift` | ~400 | Piano keyboard component |
| `ResultsView.swift` | ~1100 | Results display |
| `CurriculumView.swift` | ~600 | Curriculum browser |
| `PlayerProfileView.swift` | ~550 | Profile & stats |
| `SettingsView.swift` | ~450 | Settings UI |
| `ScoreboardView.swift` | ~350 | High scores |
| `CadenceScoreboardView.swift` | ~350 | Cadence scores |
| `PracticeDueCard.swift` | ~250 | SR widget |

### Helpers (2 files)

| File | Lines | Purpose |
|------|-------|---------|
| `AudioManager.swift` | ~400 | MIDI audio synthesis |
| `FlowLayout.swift` | ~100 | Custom layout component |

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Total Swift Files** | 38 |
| **Estimated Lines of Code** | ~30,000+ |
| **Practice Modes** | 5 |
| **Question Types** | 15+ |
| **Chord Types** | 30+ |
| **Scale Types** | 12+ |
| **Interval Types** | 15 |
| **Cadence Types** | 5 |
| **Cadence Drill Modes** | 9 |
| **Achievements** | 19 |
| **Ranks** | 12 |
| **Curriculum Pathways** | 4 |

---

## Future Development Considerations

When extending the app, consider:

1. **Adding New Drills**: Follow the pattern of existing game models (ObservableObject with @Published state)
2. **New Chord/Scale Types**: Add to respective database files
3. **New Achievements**: Add to `AchievementType` enum in PlayerProfile
4. **Curriculum Expansion**: Add modules to CurriculumDatabase
5. **Audio Enhancements**: Extend AudioManager with new playback modes
6. **State Persistence**: Use the existing UserDefaults pattern with JSON encoding

---

*This document should be updated whenever significant architectural changes are made to the app.*
