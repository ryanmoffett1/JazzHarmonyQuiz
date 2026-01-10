# AI Agent Instructions - Jazz Harmony Quiz

**Last Updated:** 2026-01-10
**Project Type:** iOS SwiftUI Application
**Language:** Swift 5.0+
**Target:** iOS 17.0+

## Quick Start for AI Agents

Welcome! This file provides comprehensive guidance for AI assistants (Claude Code, GitHub Copilot, etc.) working on the Jazz Harmony Quiz iOS application.

### 📋 Required Reading Order

1. **This file** - Overview and general guidelines
2. `PROJECT_CONTEXT.md` - Architecture and component details
3. `CODING_STANDARDS.md` - Swift/SwiftUI conventions
4. `TODO_TEMPLATE.md` - Task tracking framework

---

## Project Overview

Jazz Harmony Quiz is an educational iOS app that teaches jazz chord theory through interactive quizzes. Users play chord tones on a visual piano keyboard, testing their knowledge across four difficulty levels (Beginner → Expert).

**Key Stats:**
- ~2,900 lines of Swift code
- Pure SwiftUI (no external dependencies)
- Models/Views architecture
- 30 chord types across 4 difficulty levels
- Persistent leaderboard system

---

## Core Principles for AI Agents

### 1. **Always Read Before Modifying**
Never propose changes to code you haven't read. Always use file reading tools to understand existing implementations before suggesting modifications.

### 2. **Maintain SwiftUI Best Practices**
- Use `@StateObject`, `@EnvironmentObject`, `@State`, and `@Binding` appropriately
- Prefer computed properties over imperative logic
- Keep views focused and composable
- Use `MARK:` comments for organization

### 3. **Preserve Music Theory Accuracy**
This app teaches real music theory. Any changes to chord definitions, note calculations, or theory logic must be musically accurate. When uncertain about music theory, ask for clarification.

### 4. **No External Dependencies Without Discussion**
This project intentionally has zero external dependencies. Do not add Swift Package Manager dependencies, CocoaPods, or third-party frameworks without explicit approval.

### 5. **Maintain iOS 17.0+ Compatibility**
All code must work on iOS 17.0 and later. Use appropriate availability checks for newer iOS features.

---

## Project Structure

```
JazzHarmonyQuiz/
├── .ai/                           # AI agent instructions (you are here!)
├── .github/                       # GitHub-specific configurations
├── Jazz Harmony Quiz/
│   ├── README.md                  # User-facing documentation
│   └── JazzHarmonyQuiz/
│       ├── JazzHarmonyQuizApp.swift     # App entry point
│       ├── ContentView.swift            # Main menu/navigation
│       ├── Models/
│       │   ├── ChordModel.swift         # Core data structures
│       │   ├── QuizGame.swift           # Game state & logic
│       │   └── JazzChordDatabase.swift  # 30 chord type definitions
│       └── Views/
│           ├── ChordDrillView.swift     # Quiz interface
│           ├── PianoKeyboard.swift      # Interactive keyboard
│           ├── ResultsView.swift        # Quiz results & review
│           └── LeaderboardView.swift    # Top 10 scores
```

---

## Common Tasks & Guidelines

### Adding a New Feature

1. **Understand the Architecture** - Read `PROJECT_CONTEXT.md` to understand data flow
2. **Check Existing Patterns** - Look for similar features already implemented
3. **Model First** - Add necessary data structures to Models/ if needed
4. **View Second** - Create or modify views in Views/
5. **Test Thoroughly** - Build and run in Xcode, test on simulator and device
6. **Update Documentation** - Update README.md if user-facing changes

### Modifying Chord Theory Logic

**CRITICAL:** Changes to chord definitions must be musically accurate.

- `ChordModel.swift` - Contains note and chord tone enums
- `JazzChordDatabase.swift` - All 30 chord type definitions
- Verify changes against standard jazz theory textbooks or ask for validation

### Working with State Management

```swift
// App-level state (QuizGame)
@StateObject var game = QuizGame()

// Passed to child views
@EnvironmentObject var game: QuizGame

// View-local state
@State private var selectedNotes: Set<Note> = []

// Binding from parent
@Binding var isPresented: Bool
```

### Adding UI Components

- Follow existing SwiftUI view patterns in Views/
- Use `GeometryReader` for responsive layouts
- Maintain consistency with existing color scheme and styling
- Keep views under 300 lines when possible (split into smaller components)

### Debugging Common Issues

**Build Errors:**
- Clean build folder: Product → Clean Build Folder (Shift+Cmd+K)
- Check for typos in variable names (Swift is case-sensitive)
- Ensure all files are added to the target

**Runtime Issues:**
- Check Xcode console for error messages
- Verify `@Published` properties are being updated on main thread
- Ensure UserDefaults keys match between read/write operations

---

## File Modification Guidelines

### When Modifying Models/

**ChordModel.swift** - Contains fundamental data structures:
- `Note` enum (C through B with MIDI numbers)
- `ChordTone` enum (root, 3rd, 5th, 7th, extensions, alterations)
- `ChordType` struct (defines chord structure)
- `Chord` struct (root + type = concrete chord)
- `QuizQuestion`, `QuizResult` (quiz data)

**Changes here affect the entire app.** Test thoroughly after modifications.

**QuizGame.swift** - ObservableObject managing all game state:
- Question generation and validation
- Scoring and timing logic
- Leaderboard persistence
- State transitions

**This is the app's brain.** Understand the full workflow before making changes.

**JazzChordDatabase.swift** - Singleton with all chord definitions:
- 30 chord types organized by difficulty
- Each chord has symbol and tone array
- Random chord generation

**Verify music theory accuracy for any changes here.**

### When Modifying Views/

**PianoKeyboard.swift** - Interactive piano component:
- Handles touch input and visual feedback
- Configurable octave range and note display
- Used by ChordDrillView for user input

**ChordDrillView.swift** - Main quiz interface:
- Setup → Active → Results state machine
- Question display and answer submission
- Keyboard integration

**ResultsView.swift** - Quiz completion screen:
- Performance summary with accuracy/time
- Detailed review of each question
- Navigation back to menu

**LeaderboardView.swift** - Top 10 scores display:
- Sortable by accuracy, time, or date
- Medal icons for top 3
- Empty state handling

---

## Testing Workflow

### Building the App

```bash
# From project root
cd "Jazz Harmony Quiz"
xcodebuild -project JazzHarmonyQuiz.xcodeproj -scheme JazzHarmonyQuiz -configuration Debug
```

### Running in Simulator

1. Open `JazzHarmonyQuiz.xcodeproj` in Xcode
2. Select target device (e.g., iPhone 15 Pro)
3. Press Cmd+R to build and run

### Manual Testing Checklist

- [ ] App launches without crashes
- [ ] Quiz setup allows difficulty and question type selection
- [ ] Piano keyboard responds to touches correctly
- [ ] Answer validation works (correct/incorrect detection)
- [ ] Timer displays and updates
- [ ] Results screen shows accurate statistics
- [ ] Leaderboard persists between app launches
- [ ] Review screen displays correct answers vs user answers

---

## Code Review Checklist

Before committing changes, verify:

- [ ] Code builds without warnings or errors
- [ ] No force unwrapping (`!`) without clear safety justification
- [ ] Published properties only modified on main thread
- [ ] MARK comments added for new sections (3+ functions)
- [ ] No hardcoded values that should be configurable
- [ ] Music theory logic is accurate (for chord-related changes)
- [ ] SwiftUI previews still compile (if modified)
- [ ] No console warnings when running
- [ ] No memory leaks (check Instruments if adding complex logic)
- [ ] Maintains iOS 17.0+ compatibility

---

## Git Workflow

### Branch Naming
- Feature branches: `feature/description`
- Bug fixes: `fix/description`
- Claude-specific branches: `claude/description-{sessionId}`

### Commit Messages
Follow conventional commits:
```
feat: Add audio playback for chord tones
fix: Correct enharmonic spelling for Db major
refactor: Extract keyboard logic into separate component
docs: Update README with new features
```

### Before Pushing
1. Ensure all files compile
2. Test in Xcode simulator
3. Check for uncommitted changes with `git status`
4. Review diff with `git diff`

---

## AI Agent Collaboration Tips

### For Claude Code

**When asked to implement a feature:**
1. Read relevant files first (use Read tool)
2. Understand existing patterns
3. Propose approach before implementing
4. Make focused changes (avoid over-engineering)
5. Test the build after changes
6. Create clear commit messages

**When asked to fix a bug:**
1. Ask for reproduction steps if not clear
2. Read the relevant code paths
3. Identify root cause before proposing fix
4. Consider edge cases
5. Verify fix doesn't break other functionality

### For GitHub Copilot

**Context to provide in comments:**
```swift
// This function generates a random quiz question for the given difficulty level
// It should select a random chord from JazzChordDatabase and create either
// a single tone, all tones, or chord spelling question type
func generateQuestion(difficulty: ChordType.Difficulty) -> QuizQuestion {
    // Copilot will suggest implementation based on this context
}
```

**Better autocomplete suggestions:**
- Use descriptive variable names
- Add type annotations even when inferred
- Include MARK comments before sections
- Reference related functions in comments

---

## Feature Request Evaluation

When asked to add a new feature, consider:

1. **Alignment with App Purpose** - Does it help users learn jazz harmony?
2. **Scope** - Is this a small enhancement or major feature?
3. **Dependencies** - Can it be built with existing tools/frameworks?
4. **Music Theory** - Does it require music theory expertise?
5. **User Experience** - Does it fit naturally into current workflow?
6. **Maintenance** - Will it require ongoing updates?

**Examples:**
- ✅ Add audio playback of chord tones (aligned, feasible)
- ✅ Add more chord types (aligned, straightforward)
- ✅ Improve keyboard visual feedback (aligned, small scope)
- ⚠️ Add social sharing (requires external services, scope creep)
- ⚠️ Support guitar fretboard (major feature, new domain knowledge)
- ❌ Add unrelated game mechanics (not aligned with purpose)

---

## Getting Help

### Music Theory Questions
- Reference: "The Jazz Theory Book" by Mark Levine
- Verify chord spellings against standard references
- Ask the user for clarification on jazz-specific concepts

### Swift/SwiftUI Questions
- Apple Developer Documentation: https://developer.apple.com/documentation/
- SwiftUI by Tutorials (raywenderlich.com)
- Swift Language Guide: https://docs.swift.org/swift-book/

### Xcode Build Issues
- Check Build Settings in .xcodeproj
- Verify file target membership
- Clean derived data if persistent issues

---

## Workflow for Complex Tasks

### Example: Adding Audio Playback

**Step 1: Plan the Task**
- Identify components needed (AVFoundation framework)
- Determine where audio logic belongs (new AudioManager class?)
- Consider UI changes (play button, audio indicators)
- Plan for background audio, interruptions, permissions

**Step 2: Create a TODO**
Use the TODO_TEMPLATE.md framework:
```markdown
# TODO: Add Chord Tone Audio Playback

## Status
In Progress

## Description
Implement audio playback for individual chord tones and full chords

## Subtasks
- [ ] Create AudioManager class with AVFoundation
- [ ] Generate/load audio samples for each note
- [ ] Add play button to ActiveQuizView
- [ ] Handle audio session management
- [ ] Add audio settings to setup screen
- [ ] Test on device (simulator has audio limitations)

## Dependencies
- AVFoundation framework (native to iOS)
- Audio samples (synthesized or recorded)

## Estimated Complexity
Medium-High (3-5 hours)
```

**Step 3: Implement Incrementally**
- Start with minimal implementation (play middle C)
- Expand to all notes
- Add to UI
- Handle edge cases
- Test thoroughly

**Step 4: Document and Commit**
- Update README.md with new feature
- Add code comments for complex audio logic
- Commit with descriptive message

---

## Anti-Patterns to Avoid

### ❌ Don't: Modify chord definitions without verification
```swift
// WRONG - This is not a dominant 7 chord!
ChordType(symbol: "7", tones: [.root, .majThird, .fifth, .majSeventh], difficulty: .beginner)
```

### ✅ Do: Verify against music theory references
```swift
// CORRECT - Dominant 7 has a minor 7th
ChordType(symbol: "7", tones: [.root, .majThird, .fifth, .minSeventh], difficulty: .beginner)
```

### ❌ Don't: Add force unwrapping without safety
```swift
// WRONG - Will crash if no current question
let question = game.currentQuestion!
```

### ✅ Do: Use optional binding
```swift
// CORRECT - Safe unwrapping
if let question = game.currentQuestion {
    // Use question safely
}
```

### ❌ Don't: Create massive view files
```swift
// WRONG - 800-line view file with everything
struct MassiveQuizView: View {
    // Setup logic
    // Quiz logic
    // Results logic
    // Keyboard logic
    // ... everything
}
```

### ✅ Do: Split into focused components
```swift
// CORRECT - Separate concerns
struct QuizSetupView: View { }
struct ActiveQuizView: View { }
struct QuizResultsView: View { }
struct PianoKeyboard: View { }
```

---

## Quick Reference

### Important File Locations
- App entry: `JazzHarmonyQuiz/JazzHarmonyQuizApp.swift`
- Main navigation: `JazzHarmonyQuiz/ContentView.swift`
- Game logic: `JazzHarmonyQuiz/Models/QuizGame.swift`
- Chord data: `JazzHarmonyQuiz/Models/JazzChordDatabase.swift`
- User documentation: `Jazz Harmony Quiz/README.md`

### Key Data Structures
- `Note` - Musical note (C, C#, D, etc.)
- `ChordTone` - Interval in chord (root, 3rd, 5th, etc.)
- `ChordType` - Definition of chord structure
- `Chord` - Specific chord instance (e.g., Cmaj7)
- `QuizQuestion` - Question with correct answer
- `QuizResult` - Completed quiz with scoring

### Useful Xcode Shortcuts
- `Cmd+B` - Build
- `Cmd+R` - Run
- `Cmd+.` - Stop
- `Shift+Cmd+K` - Clean build folder
- `Cmd+/` - Toggle comment
- `Cmd+Shift+O` - Open quickly (find file)

---

## Version History

- **2026-01-10** - Initial AI agent setup with comprehensive instructions

---

## Questions?

If you encounter situations not covered here:
1. Check PROJECT_CONTEXT.md for architecture details
2. Check CODING_STANDARDS.md for style guidance
3. Read the relevant source files
4. Ask the user for clarification

Remember: **Read before you write.** Understanding the existing code is always step one.
