# Project Context - Jazz Harmony Quiz

**Purpose:** Detailed architecture documentation for AI agents
**Audience:** Claude Code, GitHub Copilot, and other AI assistants
**Updated:** 2026-01-10

---

## Architecture Overview

Jazz Harmony Quiz follows a **Models-Views** architecture pattern using SwiftUI's reactive data flow. State is centralized in the `QuizGame` ObservableObject and propagated to views through `@EnvironmentObject`.

### Data Flow Diagram

```
User Interaction
       ↓
   SwiftUI View
       ↓
  @EnvironmentObject (QuizGame)
       ↓
   Update State (@Published properties)
       ↓
   View Auto-Refreshes
```

---

## Core Components

### 1. Models Layer

#### ChordModel.swift (288 lines)

**Purpose:** Fundamental data structures for music theory and quiz logic

**Key Types:**

##### Note Enum
```swift
enum Note: Int, CaseIterable, Codable, Hashable {
    case C = 60   // MIDI note numbers
    case Cs = 61  // C# / Db
    case D = 62
    // ... through B = 71
}
```

**Responsibilities:**
- MIDI number mapping (60-71 = C4-B4)
- Enharmonic equivalence (C# vs Db)
- Pitch class calculations
- Note name display with optional sharps/flats

**Important Methods:**
- `name(preferSharps:)` - Returns note name (e.g., "C#" or "Db")
- `pitchClass` - Computed property (0-11 for octave-agnostic comparison)

##### ChordTone Enum
```swift
enum ChordTone: String, Codable, CaseIterable, Hashable {
    case root, majThird, minThird, fifth, dimFifth, augFifth
    case majSeventh, minSeventh, dimSeventh
    case flatNine, nine, sharpNine
    case eleven, sharpEleven
    case flatThirteen, thirteen
}
```

**Responsibilities:**
- Defines all possible chord intervals
- Used to construct ChordType definitions
- Provides semitone offset from root

**Important Methods:**
- `semitones()` - Returns half-steps from root (e.g., majThird = 4)

##### ChordType Struct
```swift
struct ChordType: Identifiable, Hashable, Codable {
    let id: UUID
    let symbol: String          // e.g., "maj7", "7b9", "min7"
    let tones: [ChordTone]      // Array of intervals
    let difficulty: Difficulty  // .beginner through .expert
}
```

**Responsibilities:**
- Defines chord structure abstractly (no specific root)
- Organizes chords by difficulty
- Used by JazzChordDatabase

**Example:**
```swift
ChordType(
    symbol: "maj7",
    tones: [.root, .majThird, .fifth, .majSeventh],
    difficulty: .beginner
)
```

##### Chord Struct
```swift
struct Chord: Identifiable, Hashable, Codable {
    let id: UUID
    let root: Note
    let type: ChordType
}
```

**Responsibilities:**
- Concrete chord instance (e.g., Cmaj7, D7b9)
- Calculates actual notes from root + chord type
- Display name generation

**Important Methods:**
- `tones()` - Returns Set<Note> of all chord tones
- `tone(for:)` - Returns specific Note for a ChordTone (e.g., "what is the b9?")
- `displayName(preferSharps:)` - Full chord name (e.g., "C#maj7")

##### QuizQuestion Struct
```swift
struct QuizQuestion: Identifiable, Codable {
    let id: UUID
    let chord: Chord
    let questionType: QuestionType
    let specificTone: ChordTone?  // For .singleTone questions
}
```

**Responsibilities:**
- Encapsulates a single quiz question
- Stores question type and parameters
- Provides correct answer via `correctAnswer()` method

**Question Types:**
- `.singleTone(ChordTone)` - "What is the b9 of D7b9?"
- `.allTones` - "Play all tones of Cmaj7"
- `.chordSpelling` - "Spell Gmaj7" (same as allTones, different presentation)

##### QuizResult Struct
```swift
struct QuizResult: Identifiable, Codable {
    let id: UUID
    let questions: [QuizQuestion]
    let userAnswers: [UUID: Set<Note>]  // QuestionID -> User's selected notes
    let timePerQuestion: [UUID: TimeInterval]
    let totalTime: TimeInterval
    let date: Date
}
```

**Responsibilities:**
- Stores completed quiz data
- Calculates accuracy and statistics
- Persists to UserDefaults for leaderboard
- Provides detailed review data

**Important Properties:**
- `accuracy` - Percentage of correct answers
- `averageTimePerQuestion` - Mean response time
- `correctCount` - Number of correct answers

---

#### QuizGame.swift (295 lines)

**Purpose:** Central state management for quiz lifecycle

**Class Definition:**
```swift
@MainActor
class QuizGame: ObservableObject {
    // Published state
    @Published var currentQuestion: QuizQuestion?
    @Published var userAnswer: Set<Note> = []
    @Published var currentQuestionStartTime: Date?
    @Published var quizStartTime: Date?
    @Published var allQuestions: [QuizQuestion] = []
    @Published var answeredQuestions: [UUID: Set<Note>] = [:]
    @Published var questionTimes: [UUID: TimeInterval] = [:]
    @Published var currentQuestionIndex: Int = 0
    @Published var leaderboard: [QuizResult] = []
}
```

**State Management:**
- All properties marked `@Published` trigger view updates
- `@MainActor` ensures UI updates on main thread
- Injected as `@EnvironmentObject` into all views

**Key Responsibilities:**

1. **Quiz Generation**
   - `startQuiz(difficulty:questionCount:types:)` - Creates quiz with random questions
   - Filters chords by difficulty level
   - Selects question types based on user preferences

2. **Answer Validation**
   - `checkAnswer()` - Compares user's notes to correct answer
   - Uses pitch-class comparison (octave-agnostic)
   - Records answer and timing data

3. **Question Navigation**
   - `nextQuestion()` - Advances to next question
   - `moveToQuestion(at:)` - Jump to specific question
   - Tracks timing for each question

4. **Results & Scoring**
   - `finishQuiz()` - Creates QuizResult and updates leaderboard
   - Maintains top 10 scores only
   - Sorts by accuracy, then time

5. **Leaderboard Persistence**
   - `saveLeaderboard()` - Writes to UserDefaults
   - `loadLeaderboard()` - Reads from UserDefaults
   - Key: "JazzHarmonyLeaderboard"
   - Custom Codable implementation for encoding/decoding

**Important Methods:**

```swift
// Start a new quiz
func startQuiz(difficulty: ChordType.Difficulty,
               questionCount: Int,
               questionTypes: Set<QuestionType>)

// Validate user's answer
func checkAnswer() -> Bool

// Move to next question (returns false if quiz complete)
func nextQuestion() -> Bool

// Complete quiz and save to leaderboard
func finishQuiz() -> QuizResult

// Reset for new quiz
func reset()
```

**Data Flow Example:**
```
1. User selects difficulty + question count
2. startQuiz() → generates random questions
3. currentQuestion set → view updates
4. User selects notes → userAnswer updated
5. checkAnswer() → stores result
6. nextQuestion() → advances or completes
7. finishQuiz() → creates QuizResult, updates leaderboard
```

---

#### JazzChordDatabase.swift (461 lines)

**Purpose:** Centralized repository of all chord type definitions

**Structure:**
```swift
class JazzChordDatabase {
    static let shared = JazzChordDatabase()  // Singleton

    let allChordTypes: [ChordType]  // All 30 chord types

    private init() {
        // Initialize chord database
    }
}
```

**Chord Organization (30 Total):**

**Beginner (5 chords):**
- Major triad, Minor triad
- Dominant 7th, Major 7th, Minor 7th

**Intermediate (7 chords):**
- Minor-major 7th, Half-diminished
- Diminished 7th, Augmented triad
- Augmented major 7th, Sus4, 6th chord

**Advanced (8 chords):**
- Dominant 7b9, Dominant 7#9
- Dominant 7b5, Dominant 7#5
- Minor 7b5, Minor 9
- Major 9, Minor 6

**Expert (10 chords):**
- Dominant 7#11, Dominant 7b9#11
- Dominant 13, Dominant 7#9b13
- Major 7#11, Minor 11
- Minor 13, Major 13
- Altered dominant (7alt)
- Minor 7#5

**Important Methods:**

```swift
// Get all chord types at or below difficulty level
func chordTypes(forDifficulty: ChordType.Difficulty) -> [ChordType]

// Generate random chord at difficulty level
func randomChord(difficulty: ChordType.Difficulty) -> Chord

// Get specific chord type by symbol
func chordType(withSymbol: String) -> ChordType?
```

**Usage Pattern:**
```swift
let database = JazzChordDatabase.shared
let beginnerChords = database.chordTypes(forDifficulty: .beginner)
let randomChord = database.randomChord(difficulty: .intermediate)
```

---

### 2. Views Layer

#### PianoKeyboard.swift (295 lines)

**Purpose:** Interactive visual piano keyboard for note input

**Component Hierarchy:**
```
PianoKeyboard
├── ForEach(whiteKeys) → WhiteKeyView
└── ForEach(blackKeys) → BlackKeyView
```

**PianoKeyboard (Main Component):**
```swift
struct PianoKeyboard: View {
    @Binding var selectedNotes: Set<Note>  // Two-way binding
    let lowestNote: Note                    // Start of octave range
    let highestNote: Note                   // End of octave range
    let showNoteNames: Bool                 // Display C, D, E labels
}
```

**Responsibilities:**
- Renders white keys (7 per octave)
- Overlays black keys at correct positions
- Handles touch input and selection state
- Provides visual feedback (highlights selected notes)

**Layout Strategy:**
```swift
GeometryReader { geometry in
    ZStack {
        // Layer 1: White keys (full height)
        HStack(spacing: 0) {
            ForEach(whiteKeys) { note in
                WhiteKeyView(note: note, ...)
            }
        }

        // Layer 2: Black keys (60% height, absolute positioning)
        ForEach(blackKeys) { note in
            BlackKeyView(note: note, ...)
                .offset(x: blackKeyOffset(note))
        }
    }
}
```

**Key Sizing:**
- White key width: `geometry.width / CGFloat(whiteKeyCount)`
- White key height: Fills available height
- Black key width: 60% of white key width
- Black key height: 60% of white key height

**Selection Logic:**
```swift
// When user taps key
if selectedNotes.contains(note) {
    selectedNotes.remove(note)  // Deselect
} else {
    selectedNotes.insert(note)  // Select
}
```

**WhiteKeyView:**
- Rectangle with rounded corners
- White fill, black border
- Highlights when selected (blue overlay)
- Optional note name label

**BlackKeyView:**
- Rectangle with rounded corners
- Black fill
- Positioned between white keys
- Highlights when selected (lighter shade)

**Usage in Quiz:**
```swift
@State private var selectedNotes: Set<Note> = []

PianoKeyboard(
    selectedNotes: $selectedNotes,
    lowestNote: .C,
    highestNote: .B,
    showNoteNames: true
)
```

---

#### ChordDrillView.swift (506 lines)

**Purpose:** Main quiz interface with state machine

**State Machine:**
```swift
enum QuizState {
    case setup    // User configures quiz
    case active   // Quiz in progress
    case results  // Quiz completed
}

@State private var quizState: QuizState = .setup
```

**Component Breakdown:**

##### ChordDrillView (Container)
- Manages quiz state transitions
- Injects QuizGame environment object
- Handles navigation between setup/active/results

##### QuizSetupView
```swift
struct QuizSetupView: View {
    @Binding var selectedDifficulty: ChordType.Difficulty
    @Binding var questionCount: Int
    @Binding var selectedQuestionTypes: Set<QuestionType>
    let onStartQuiz: () -> Void
}
```

**UI Elements:**
- Difficulty picker (Beginner/Intermediate/Advanced/Expert)
- Question count slider (5-20 questions)
- Question type toggles (Single Tone / All Tones / Chord Spelling)
- Start button

**Validation:**
- At least one question type must be selected
- Question count must be 5-20

##### ActiveQuizView
```swift
struct ActiveQuizView: View {
    @EnvironmentObject var game: QuizGame
    @State private var selectedNotes: Set<Note> = []
    @State private var showingAnswer: Bool = false
}
```

**UI Layout:**
```
┌─────────────────────────────────┐
│ Question 3 of 10                │ ← Progress indicator
├─────────────────────────────────┤
│ What is the b9 of D7b9?         │ ← Question text
├─────────────────────────────────┤
│ ░░░░░░░░░░░░░░░░                │ ← Progress bar
├─────────────────────────────────┤
│   🎹 Piano Keyboard             │ ← Note selection
├─────────────────────────────────┤
│ [Selected: C, E, G]             │ ← Feedback area
├─────────────────────────────────┤
│ [Clear] [Submit Answer]         │ ← Actions
└─────────────────────────────────┘
```

**Interaction Flow:**
1. Display current question from `game.currentQuestion`
2. User selects notes on piano keyboard
3. Submit button triggers `game.checkAnswer()`
4. Show correct/incorrect feedback
5. Auto-advance after 2 seconds OR manual next button
6. Repeat until all questions answered
7. Transition to results state

**Important Features:**
- Timer display (per question and total)
- Progress bar (X of Y questions)
- Clear button to reset selection
- Visual feedback on answer correctness
- Review mode (show correct answer after submission)

---

#### ResultsView.swift (552 lines)

**Purpose:** Display quiz completion statistics and detailed review

**Component Hierarchy:**
```
ResultsView
├── Summary Section
│   ├── Accuracy (percentage)
│   ├── Total time
│   ├── Average time per question
│   └── Encouragement message
├── PerformanceBar (visual accuracy indicator)
└── NavigationLink → ReviewView
```

**ResultsView:**
```swift
struct ResultsView: View {
    let result: QuizResult
    @EnvironmentObject var game: QuizGame
    let onReturnToMenu: () -> Void
}
```

**UI Elements:**

1. **Accuracy Display**
   - Large percentage (e.g., "85%")
   - Color-coded (green > 80%, yellow > 60%, red otherwise)

2. **Time Statistics**
   - Total time in MM:SS format
   - Average per question in seconds

3. **Performance Metrics**
   - Correct count / Total count
   - Visual progress bar

4. **Encouragement Message**
   - Based on accuracy:
     - 100%: "Perfect! Outstanding work!"
     - 80-99%: "Great job! Keep it up!"
     - 60-79%: "Good effort! Practice makes perfect."
     - < 60%: "Keep practicing! You'll improve."

5. **Action Buttons**
   - Review Answers (NavigationLink to ReviewView)
   - Return to Menu

**PerformanceBar:**
```swift
struct PerformanceBar: View {
    let percentage: Double  // 0.0 to 1.0
    let color: Color        // Visual indicator color
}
```

Renders a horizontal bar filled to `percentage` width.

**ReviewView:**
```swift
struct ReviewView: View {
    let result: QuizResult
}
```

**Purpose:** Detailed question-by-question breakdown

**UI Layout:**
```
┌─────────────────────────────────┐
│ Question 1 ✓                    │
│ What is the b9 of D7b9?         │
│ Correct Answer: Eb              │
│ Your Answer: Eb                 │
│ Time: 5.2s                      │
├─────────────────────────────────┤
│ Question 2 ✗                    │
│ Play all tones of Cmaj7         │
│ Correct Answer: C, E, G, B      │
│ Your Answer: C, E, G, Bb        │
│ Time: 8.1s                      │
└─────────────────────────────────┘
```

**QuestionReviewCard:**
- Displays question text
- Shows correct answer (green)
- Shows user's answer (red if incorrect)
- Highlights differences
- Shows time taken
- Checkmark/X icon for correct/incorrect

---

#### LeaderboardView.swift (248 lines)

**Purpose:** Display top 10 quiz scores with sorting options

**LeaderboardView:**
```swift
struct LeaderboardView: View {
    @EnvironmentObject var game: QuizGame
    @State private var sortOption: SortOption = .date
}

enum SortOption {
    case accuracy    // Highest accuracy first
    case time        // Fastest time first
    case date        // Most recent first
}
```

**UI Layout:**
```
┌─────────────────────────────────┐
│ 🏆 Leaderboard                  │
│ [Sort: Accuracy ▼]              │
├─────────────────────────────────┤
│ 🥇 1. 100% | 2:45 | Jan 10      │
│ 🥈 2.  95% | 3:12 | Jan  9      │
│ 🥉 3.  90% | 2:58 | Jan  8      │
│    4.  85% | 4:21 | Jan  7      │
│    5.  80% | 3:45 | Jan  6      │
│   ...                           │
└─────────────────────────────────┘
```

**Features:**

1. **Sorting Options**
   - Accuracy (descending)
   - Time (ascending - faster is better)
   - Date (descending - most recent first)

2. **Visual Indicators**
   - 🥇 Gold medal for 1st place
   - 🥈 Silver medal for 2nd place
   - 🥉 Bronze medal for 3rd place
   - Number for 4th-10th place

3. **Row Information**
   - Accuracy percentage
   - Total time
   - Date completed

4. **Empty State**
   - `EmptyLeaderboardView` when no scores exist
   - Encourages user to take first quiz

**LeaderboardRowView:**
```swift
struct LeaderboardRowView: View {
    let result: QuizResult
    let rank: Int
}
```

Renders a single leaderboard entry with medal/rank, stats, and date.

---

#### ContentView.swift (201 lines)

**Purpose:** App navigation and main menu

**MainMenuView:**
```swift
struct MainMenuView: View {
    @StateObject var game = QuizGame()
}
```

**UI Layout:**
```
┌─────────────────────────────────┐
│  🎵 Jazz Harmony Quiz           │
│                                 │
│  Test your jazz chord knowledge │
│                                 │
│  [Start Chord Drill]            │
│  [View Leaderboard]             │
│                                 │
│  About:                         │
│  Learn jazz harmony through     │
│  interactive quizzes...         │
└─────────────────────────────────┘
```

**Navigation:**
- NavigationLink to ChordDrillView
- NavigationLink to LeaderboardView
- Injects `game` as `environmentObject` for entire app

**ContentView (App Root):**
```swift
struct ContentView: View {
    var body: some View {
        NavigationView {
            MainMenuView()
        }
    }
}
```

Provides NavigationView wrapper for entire app.

---

### 3. App Entry Point

#### JazzHarmonyQuizApp.swift (15 lines)

```swift
@main
struct JazzHarmonyQuizApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

Standard SwiftUI app structure. Entry point for iOS app lifecycle.

---

## State Flow Patterns

### Quiz Lifecycle State Flow

```
┌──────────┐
│  Setup   │ ← User configures quiz
└────┬─────┘
     │ startQuiz()
     ↓
┌──────────┐
│  Active  │ ← User answers questions
└────┬─────┘
     │ finishQuiz()
     ↓
┌──────────┐
│ Results  │ ← Display statistics & review
└──────────┘
```

### Data Binding Patterns

**One-Way Data Flow:**
```swift
// Game → View (read-only)
@EnvironmentObject var game: QuizGame
Text("Score: \(game.currentScore)")
```

**Two-Way Data Flow:**
```swift
// View ↔ View (bidirectional)
@Binding var selectedNotes: Set<Note>
PianoKeyboard(selectedNotes: $selectedNotes)
```

**Local View State:**
```swift
// View internal state
@State private var showingAlert = false
```

---

## Data Persistence

### UserDefaults Storage

**Key:** `"JazzHarmonyLeaderboard"`
**Data Type:** `[QuizResult]` encoded as JSON
**Max Size:** Top 10 results only

**Save Flow:**
```
1. finishQuiz() creates QuizResult
2. Append to game.leaderboard array
3. Sort by accuracy (desc), then time (asc)
4. Keep only top 10
5. Encode to JSON
6. Save to UserDefaults
```

**Load Flow:**
```
1. App launch
2. QuizGame.init() called
3. loadLeaderboard() attempts to read from UserDefaults
4. Decode JSON to [QuizResult]
5. Populate game.leaderboard
6. Views display leaderboard
```

**Custom Codable Implementation:**
```swift
extension QuizResult {
    enum CodingKeys: String, CodingKey {
        case id, questions, userAnswers, timePerQuestion, totalTime, date
    }

    func encode(to encoder: Encoder) throws {
        // Custom encoding for UUID keys in userAnswers dictionary
    }

    init(from decoder: Decoder) throws {
        // Custom decoding for UUID keys
    }
}
```

---

## Important Algorithms

### Pitch-Class Comparison

**Purpose:** Check if user's notes match correct answer (octave-agnostic)

```swift
// In QuizQuestion
func correctAnswer() -> Set<Note> {
    // Returns the correct notes
}

// In QuizGame.checkAnswer()
let correctPitchClasses = Set(correctNotes.map { $0.pitchClass })
let userPitchClasses = Set(userAnswer.map { $0.pitchClass })

let isCorrect = correctPitchClasses == userPitchClasses
```

**Why:** Users can play notes in any octave (C4 or C5 are both "C")

### Random Question Generation

```swift
// In QuizGame.startQuiz()
let availableChords = JazzChordDatabase.shared.chordTypes(forDifficulty: difficulty)

for _ in 0..<questionCount {
    let randomChord = database.randomChord(difficulty: difficulty)
    let randomQuestionType = selectedQuestionTypes.randomElement()!

    let question: QuizQuestion
    if randomQuestionType == .singleTone {
        let randomTone = randomChord.type.tones.randomElement()!
        question = QuizQuestion(chord: randomChord, questionType: .singleTone(randomTone))
    } else {
        question = QuizQuestion(chord: randomChord, questionType: randomQuestionType)
    }

    allQuestions.append(question)
}
```

### Timing Calculation

```swift
// Start question timer
currentQuestionStartTime = Date()

// On answer submission
let elapsed = Date().timeIntervalSince(currentQuestionStartTime!)
questionTimes[currentQuestion!.id] = elapsed

// Total quiz time
let totalTime = Date().timeIntervalSince(quizStartTime!)
```

---

## Extension Points

### Adding a New Chord Type

**Location:** `JazzChordDatabase.swift`

**Steps:**
1. Define new `ChordType` with symbol, tones, difficulty
2. Add to appropriate difficulty array
3. Update documentation

**Example:**
```swift
let dominant7sharp11 = ChordType(
    symbol: "7#11",
    tones: [.root, .majThird, .fifth, .minSeventh, .sharpEleven],
    difficulty: .expert
)
```

### Adding a New Question Type

**Locations:**
- `ChordModel.swift` - Add case to `QuestionType` enum
- `QuizGame.swift` - Update question generation logic
- `ActiveQuizView.swift` - Update question text display
- `QuizQuestion.swift` - Update `correctAnswer()` method

**Example:**
```swift
// New question type: "What is the interval between two tones?"
enum QuestionType {
    case singleTone(ChordTone)
    case allTones
    case chordSpelling
    case intervalBetween(ChordTone, ChordTone)  // NEW
}
```

### Adding Audio Playback

**Approach:**
1. Create `AudioManager` class with AVFoundation
2. Add to Models layer
3. Inject as environment object
4. Add play buttons to ActiveQuizView
5. Handle audio session lifecycle

**Considerations:**
- Audio samples (synthesized vs recorded)
- Background audio handling
- Audio session interruptions (phone calls, etc.)
- Device vs simulator testing (simulator audio limitations)

---

## Common Development Scenarios

### Scenario 1: Modifying Quiz Scoring

**Goal:** Change scoring to penalize incorrect answers

**Files to Modify:**
- `QuizGame.swift` - Update checkAnswer() logic
- `QuizResult.swift` - Add new scoring properties
- `ResultsView.swift` - Display new scoring metrics

**Steps:**
1. Read current scoring implementation in QuizGame.swift:712-750
2. Add penalty calculation to checkAnswer()
3. Store penalty data in QuizResult
4. Update UI to show new scoring
5. Test with various answer patterns

### Scenario 2: Adding a New Difficulty Level

**Goal:** Add "Master" difficulty above Expert

**Files to Modify:**
- `ChordModel.swift` - Add `.master` to Difficulty enum
- `JazzChordDatabase.swift` - Add master-level chord definitions
- `QuizSetupView.swift` - Add Master to difficulty picker
- Update this documentation

**Steps:**
1. Define new chord types for master level
2. Update difficulty enum and sorting
3. Test chord generation and quiz flow
4. Update UI to accommodate new option

### Scenario 3: Changing Keyboard Layout

**Goal:** Add guitar fretboard option

**Approach:**
1. Create `GuitarFretboard.swift` in Views/
2. Similar interface to PianoKeyboard (Binding to Set<Note>)
3. Add instrument picker to QuizSetupView
4. Conditionally render keyboard vs fretboard in ActiveQuizView

**Considerations:**
- String tuning (standard vs alternate)
- Fret range (0-12 vs 0-24)
- Visual layout (6 horizontal strings)
- Touch interaction (smaller tap targets)

---

## Performance Considerations

### Current Performance Profile

**App Launch:**
- Fast (<1 second)
- Loads leaderboard from UserDefaults
- Initializes JazzChordDatabase singleton

**Quiz Generation:**
- Fast (instant for up to 20 questions)
- Random selection is O(1) per question
- No database queries or network calls

**View Rendering:**
- Piano keyboard: 12 keys (7 white + 5 black)
- SwiftUI auto-optimizes redraws
- No performance issues on any supported devices

### Potential Bottlenecks

**If Adding Audio:**
- Loading audio samples (use lazy loading)
- Memory pressure from large audio files (use compressed formats)
- Audio latency (use AVAudioEngine for low-latency playback)

**If Adding Animation:**
- Complex animations on keyboard (use .animation() modifier sparingly)
- Particle effects for correct answers (use Canvas API in iOS 17+)

**If Adding Networking:**
- Leaderboard sync to server (use background URLSession)
- Chord data download (cache aggressively)

---

## Testing Strategy

### Manual Testing Checklist

**Quiz Flow:**
- [ ] Start quiz with each difficulty level
- [ ] Answer questions correctly and incorrectly
- [ ] Complete full quiz and verify results
- [ ] Verify timing accuracy
- [ ] Check leaderboard updates correctly
- [ ] Test with different question counts (5, 10, 15, 20)
- [ ] Test each question type independently

**Edge Cases:**
- [ ] Select no notes and submit (should handle gracefully)
- [ ] Select all notes on keyboard
- [ ] Background app during quiz (timer should pause)
- [ ] Kill app during quiz (state should reset)
- [ ] Fill leaderboard to 10+ entries (should keep only top 10)

**UI/UX:**
- [ ] Keyboard responds to all key presses
- [ ] Selected notes highlight correctly
- [ ] Navigation works throughout app
- [ ] Text is readable on all supported screen sizes
- [ ] Dark mode support (if implemented)

### Automated Testing (Future)

**Unit Tests:**
- Chord tone calculation
- Pitch-class comparison
- Scoring algorithms
- Difficulty filtering

**UI Tests:**
- Quiz completion flow
- Navigation between screens
- Keyboard interaction
- Leaderboard sorting

---

## Dependencies

**Current:** Zero external dependencies

**Native Frameworks Used:**
- SwiftUI (UI framework)
- Foundation (data structures, UserDefaults)
- Combine (reactive state management)

**If Adding Features:**
- AVFoundation (audio playback)
- StoreKit (in-app purchases, if monetizing)
- CloudKit (iCloud leaderboard sync)
- WidgetKit (home screen widget)

---

## Version Compatibility

**Minimum iOS:** 17.0
**Reason:** Uses SwiftUI features from iOS 17

**iOS Version Usage:**
- iOS 17+: All features
- iOS 16 and below: Not supported

**Swift Version:** 5.0+
**Xcode Version:** 15.0+

---

## Glossary

**Terms AI Agents Should Know:**

- **Pitch Class:** Note without octave (C, C#, D, etc. - ignores C4 vs C5)
- **Enharmonic:** Same pitch, different name (C# = Db)
- **Root:** The foundational note of a chord (e.g., C in Cmaj7)
- **Chord Tone:** Interval from root (3rd, 5th, 7th, etc.)
- **Altered Chord:** Chord with raised or lowered tones (b9, #5, etc.)
- **Voice Leading:** Movement between chord tones (not yet implemented)
- **Inversion:** Chord with non-root bass note (not yet implemented)
- **MIDI Number:** Standard numbering for pitches (60 = middle C)

---

## Questions for AI Agents

**When uncertain about:**

**Music Theory:** Ask the user or reference standard jazz theory resources
**UI/UX Design:** Follow existing patterns unless explicitly asked to change
**Architecture Changes:** Propose approach before implementing
**New Dependencies:** Discuss trade-offs with user before adding

**Always read before writing.** Understanding context is step one.
