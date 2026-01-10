# GitHub Copilot Instructions - Jazz Harmony Quiz

This file provides context-specific instructions for GitHub Copilot when working on the Jazz Harmony Quiz iOS application.

---

## Git Workflow

**IMPORTANT:** This is a git-tracked project. After completing significant work:
1. Stage changes with `git add -A`
2. Commit with descriptive messages summarizing the changes
3. Use conventional commit style when appropriate (feat:, fix:, refactor:, etc.)
4. Commit frequently - at least after each feature or bug fix is complete

---

## Project Overview

Jazz Harmony Quiz is a SwiftUI-based iOS educational app for learning jazz chord theory. Users answer questions about chord tones by selecting notes on an interactive piano keyboard.

**Key Technologies:**
- SwiftUI (iOS 17.0+)
- Swift 5.0+
- Pure native iOS (no external dependencies)

**Architecture:**
- Models/Views separation
- ObservableObject state management
- UserDefaults persistence

---

## Code Completion Guidelines

### Models Layer

When suggesting completions for files in `Models/`:

**ChordModel.swift:**
- Use MIDI number system for `Note` enum (60-71 for C4-B4)
- `ChordTone` semitone values: majThird=4, fifth=7, minSeventh=10, etc.
- Always verify chord theory accuracy (e.g., dominant 7 = root, maj3, 5th, min7)
- Use `pitchClass` for octave-agnostic comparison

**QuizGame.swift:**
- Mark all `@Published` properties appropriately
- Update state on main thread (class is `@MainActor`)
- Use pitch-class comparison in `checkAnswer()` for octave independence
- Keep top 10 leaderboard entries only

**JazzChordDatabase.swift:**
- Maintain singleton pattern (`static let shared`)
- Organize chords by difficulty (beginner → intermediate → advanced → expert)
- Verify all chord definitions against jazz theory standards

### Views Layer

When suggesting completions for files in `Views/`:

**General SwiftUI:**
- Mark `@State` as `private`
- Use `@EnvironmentObject` for `QuizGame` access
- Use `@Binding` for parent-child communication
- Prefer computed properties for complex views

**PianoKeyboard.swift:**
- White keys: 7 per octave (C, D, E, F, G, A, B)
- Black keys: 5 per octave (C#, D#, F#, G#, A#)
- Use `GeometryReader` for responsive sizing
- Selection is a `Set<Note>` (allows multiple selection)

**ChordDrillView.swift:**
- State machine: `.setup`, `.active`, `.results`
- Display question based on `QuestionType` (singleTone, allTones, chordSpelling)
- Update timer on question changes
- Auto-advance after answer submission

**ResultsView.swift:**
- Calculate accuracy from `QuizResult`
- Format time as MM:SS
- Provide encouragement based on accuracy percentage
- Link to ReviewView for detailed question review

**LeaderboardView.swift:**
- Support three sort options: accuracy, time, date
- Show medals for top 3 (🥇🥈🥉)
- Display empty state when no results

### Common Patterns

**Note Display:**
```swift
// Suggest this pattern for showing note names
note.name(preferSharps: true)  // Returns "C#" or "Db" based on parameter
```

**Chord Display:**
```swift
// Suggest this for showing chord names
chord.displayName(preferSharps: true)  // e.g., "C#maj7"
```

**Answer Checking:**
```swift
// Always use pitch-class comparison
let correctPitchClasses = Set(correctNotes.map { $0.pitchClass })
let userPitchClasses = Set(userAnswer.map { $0.pitchClass })
let isCorrect = correctPitchClasses == userPitchClasses
```

**Time Formatting:**
```swift
// Suggest this pattern for time display
let minutes = Int(timeInterval) / 60
let seconds = Int(timeInterval) % 60
return String(format: "%d:%02d", minutes, seconds)
```

---

## Naming Conventions

**Suggest these naming patterns:**

**Types:**
- PascalCase: `ChordType`, `QuizQuestion`, `LeaderboardView`

**Variables/Functions:**
- camelCase: `currentQuestion`, `startQuiz()`, `checkAnswer()`

**Booleans:**
- Prefix with `is`, `has`, `should`: `isCorrect`, `hasAnswered`, `shouldShowHint`

**Private State:**
- Always suggest `private` for `@State`:
  ```swift
  @State private var selectedNotes: Set<Note> = []
  ```

**Published Properties:**
- Keep public in ObservableObject:
  ```swift
  @Published var currentQuestion: QuizQuestion?
  ```

---

## Music Theory Context

When generating code involving music theory:

**Chord Intervals (Semitones from Root):**
- Root: 0
- Minor 3rd: 3
- Major 3rd: 4
- Fifth: 7
- Diminished 5th: 6
- Augmented 5th: 8
- Minor 7th: 10
- Major 7th: 11
- Flat 9: 13
- Natural 9: 14
- Sharp 9: 15
- 11th: 17
- Sharp 11: 18
- Flat 13: 20
- 13th: 21

**Common Chord Formulas:**
- Major triad: root, maj3, 5th
- Minor triad: root, min3, 5th
- Dominant 7: root, maj3, 5th, min7
- Major 7: root, maj3, 5th, maj7
- Minor 7: root, min3, 5th, min7
- Half-diminished: root, min3, dim5, min7
- Diminished 7: root, min3, dim5, dim7

**Always verify chord definitions are musically accurate!**

---

## Common Code Patterns

### Creating a New View

When creating a new SwiftUI view, suggest this structure:

```swift
struct MyNewView: View {
    // MARK: - Environment

    @EnvironmentObject var game: QuizGame

    // MARK: - State

    @State private var myState: String = ""

    // MARK: - Body

    var body: some View {
        VStack {
            // View content
        }
    }

    // MARK: - Subviews

    private var mySubview: some View {
        // Extracted subview
    }
}
```

### Adding a New Chord Type

When adding chord types to `JazzChordDatabase.swift`:

```swift
ChordType(
    symbol: "7#9",  // Chord symbol
    tones: [.root, .majThird, .fifth, .minSeventh, .sharpNine],
    difficulty: .advanced
)
```

### Creating a Quiz Question

```swift
// For single tone questions
let question = QuizQuestion(
    chord: chord,
    questionType: .singleTone(.flatNine),
    specificTone: .flatNine
)

// For all tones questions
let question = QuizQuestion(
    chord: chord,
    questionType: .allTones,
    specificTone: nil
)
```

### Leaderboard Operations

```swift
// Adding to leaderboard (always keep top 10)
leaderboard.append(newResult)
leaderboard.sort { $0.accuracy > $1.accuracy || ($0.accuracy == $1.accuracy && $0.totalTime < $1.totalTime) }
leaderboard = Array(leaderboard.prefix(10))
```

---

## SwiftUI Specific

### Property Wrappers

Suggest the appropriate wrapper based on context:

**View-local state:**
```swift
@State private var isShowing = false
```

**Shared observable state:**
```swift
@EnvironmentObject var game: QuizGame
```

**Parent-child binding:**
```swift
@Binding var selectedNotes: Set<Note>
```

**Owning an observable object:**
```swift
@StateObject var game = QuizGame()
```

### View Modifiers

Suggest modifiers in this order:
1. Layout (frame, padding, offset)
2. Visual (background, foreground, border)
3. Interaction (onTapGesture)
4. Accessibility

Example:
```swift
Text("Submit")
    .font(.headline)
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color.blue)
    .foregroundColor(.white)
    .cornerRadius(10)
    .onTapGesture {
        submitAnswer()
    }
```

---

## Anti-Patterns to Avoid

**Do NOT suggest:**

❌ Force unwrapping without justification:
```swift
let question = game.currentQuestion!  // Suggest optional binding instead
```

❌ External dependencies:
```swift
// Don't suggest adding Swift Package Manager dependencies
```

❌ Hardcoded values:
```swift
if timeInterval < 5.0 {  // Suggest named constant instead
```

❌ String literals for types:
```swift
func setDifficulty(_ diff: String) {  // Suggest enum instead
```

❌ Massive functions:
```swift
// Functions over 50 lines should be split into smaller functions
```

---

## Context-Aware Suggestions

### When in ChordModel.swift

- Suggest methods on `Chord` like `tones()`, `tone(for:)`, `displayName()`
- Suggest `pitchClass` for Note comparisons
- Suggest `semitones()` for ChordTone calculations

### When in QuizGame.swift

- Suggest `@Published` for new properties
- Suggest `@MainActor` compliance for UI updates
- Suggest validation before state changes
- Suggest UserDefaults for persistence

### When in View files

- Suggest `@EnvironmentObject var game: QuizGame` for accessing state
- Suggest breaking large views into smaller components
- Suggest computed properties for complex UI logic
- Suggest `GeometryReader` for responsive layouts

### When in PianoKeyboard.swift

- Suggest white key calculations: `whiteKeys = notes.filter { !$0.isBlackKey }`
- Suggest black key offset calculations based on position
- Suggest touch handling with `Set<Note>` for multi-selection

---

## File-Specific Hints

**JazzHarmonyQuizApp.swift:**
- This is the app entry point
- Minimal code here (just WindowGroup with ContentView)
- Don't add business logic to this file

**ContentView.swift:**
- Main navigation hub
- Creates and injects QuizGame as environment object
- Routes to ChordDrillView and LeaderboardView

**ChordDrillView.swift:**
- State machine with setup/active/results states
- Integrates PianoKeyboard for user input
- Handles quiz progression

**ResultsView.swift:**
- Displays QuizResult statistics
- Links to ReviewView for detailed review
- Shows encouragement based on performance

**LeaderboardView.swift:**
- Reads from game.leaderboard
- Supports multiple sort options
- Shows top 10 only

---

## Comment Suggestions

Suggest comments for:

**Complex Music Theory:**
```swift
// Use pitch-class comparison to allow answers in any octave
// (C4 and C5 are both considered "C" for quiz purposes)
let correctPitchClasses = Set(correctNotes.map { $0.pitchClass })
```

**Non-Obvious Logic:**
```swift
// Sort by accuracy (desc), then by time (asc) as tiebreaker
leaderboard.sort { $0.accuracy > $1.accuracy || ($0.accuracy == $1.accuracy && $0.totalTime < $1.totalTime) }
```

**MARK Sections:**
```swift
// MARK: - Published Properties
// MARK: - Quiz Management
// MARK: - Scoring
// MARK: - Persistence
```

Do NOT suggest comments for obvious code:
```swift
// BAD: Don't suggest this
currentQuestion = nextQuestion  // Set current question to next question
```

---

## Testing Patterns

When suggesting test-related code:

**Manual Testing:**
- Build and run in Xcode (Cmd+R)
- Test on iPhone 15 Pro simulator
- Test various difficulty levels
- Test edge cases (no selection, all keys selected, etc.)

**Verification:**
```swift
// Suggest validation before operations
guard !selectedNotes.isEmpty else {
    print("No notes selected")
    return
}
```

---

## Performance Hints

**For Lists:**
Suggest `LazyVStack` for long lists:
```swift
ScrollView {
    LazyVStack {
        ForEach(items) { item in
            ItemView(item: item)
        }
    }
}
```

**For Computed Properties:**
Suggest caching expensive computations:
```swift
// Instead of computing in body, suggest computed property
var sortedResults: [QuizResult] {
    leaderboard.sorted { $0.accuracy > $1.accuracy }
}
```

---

## User Experience

When suggesting UI code:

**Always consider:**
- Visual feedback (highlight selected notes)
- Clear action buttons (Submit, Clear, Next)
- Progress indication (X of Y questions)
- Encouraging messages (based on performance)
- Responsive layouts (works on all iPhone sizes)

**Suggest accessibility:**
```swift
.accessibilityLabel("Piano keyboard")
.accessibilityHint("Tap keys to select chord tones")
```

---

## Quick Reference for Copilot

**When user types:**

`// Create a new chord type` → Suggest ChordType with symbol, tones, difficulty

`// Check if answer is correct` → Suggest pitch-class comparison

`// Format time` → Suggest MM:SS formatting

`// Add to leaderboard` → Suggest append + sort + prefix(10)

`// Piano keyboard` → Suggest GeometryReader with white/black key layout

`// Question text` → Suggest switch on questionType with appropriate text

`// Observable state` → Suggest @Published var with @MainActor class

`// View state` → Suggest @State private var

`// Shared state` → Suggest @EnvironmentObject var game: QuizGame

---

## Additional Resources

For more detailed information, refer to:
- `.ai/AGENT_INSTRUCTIONS.md` - Comprehensive AI agent guidelines
- `.ai/PROJECT_CONTEXT.md` - Detailed architecture documentation
- `.ai/CODING_STANDARDS.md` - Swift/SwiftUI style guidelines
- `.ai/TODO_TEMPLATE.md` - Task tracking framework

---

## Final Notes

**Core Principles:**
1. Music theory accuracy is critical
2. SwiftUI best practices always
3. No external dependencies
4. iOS 17.0+ compatibility
5. Responsive layouts for all iPhone sizes

**When uncertain:**
- Check existing code for patterns
- Verify music theory against standards
- Prefer clarity over cleverness
- Ask for clarification if needed

Happy coding! 🎵
