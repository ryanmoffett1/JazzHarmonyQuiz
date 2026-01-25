# Jazz Harmony Quiz - Comprehensive Testing Plan

## Overview

This document outlines the strategy for implementing a robust test suite for the Jazz Harmony Quiz iOS app. The goal is to achieve **90%+ code coverage** with tests that validate intended behaviors across happy paths, sad paths, and edge cases.

---

## iOS Testing Frameworks

### XCTest (Apple's Built-in Framework)
- **Unit Tests**: Test individual functions, methods, and classes in isolation
- **Integration Tests**: Test how components work together
- **UI Tests**: Test the user interface and user interactions
- **Performance Tests**: Measure execution time of code blocks

### How Testing Works in Xcode
1. **Test Target**: A separate build target containing test files
2. **Test Classes**: Subclasses of `XCTestCase`
3. **Test Methods**: Functions starting with `test` prefix
4. **Running Tests**: `Cmd+U` in Xcode or `xcodebuild test` from terminal
5. **Coverage Reports**: Enabled in scheme settings, shows which lines are exercised

---

## Phase 1: Infrastructure Setup (Start Small)

### Step 1.1: Create Test Target
Add a test target to the Xcode project:
- Target name: `JazzHarmonyQuizTests`
- Will contain all unit tests
- Configured to access `@testable import JazzHarmonyQuiz`

### Step 1.2: Verify Test Harness Works
Create a minimal "canary" test to validate the setup:

```swift
import XCTest
@testable import JazzHarmonyQuiz

final class SanityTests: XCTestCase {
    
    func testTrueIsTrue() {
        // Simplest possible test to verify harness works
        XCTAssertTrue(true)
    }
    
    func testCanImportMainModule() {
        // Verify we can access app code
        let note = Note(name: "C", midiNumber: 60, isSharp: false)
        XCTAssertEqual(note.name, "C")
    }
}
```

### Step 1.3: Run Tests from Terminal
```bash
xcodebuild test \
  -project JazzHarmonyQuiz.xcodeproj \
  -scheme JazzHarmonyQuiz \
  -destination 'platform=iOS Simulator,name=iPhone 15'
```

---

## Phase 2: Model Layer Testing (Priority 1 - Highest Value)

Models contain pure business logic with no UI dependencies. These are the easiest to test and provide the highest value.

### 2.1 ChordModel.swift (~1390 lines)
**Key Behaviors to Test:**

#### Note Struct
| Test Case | Type | Description |
|-----------|------|-------------|
| `testNotePitchClassCalculation` | Happy | MIDI 60 → pitch class 0 |
| `testNotePitchClassOctaveWrap` | Happy | MIDI 72 → pitch class 0 |
| `testNoteEquality` | Happy | Two notes with same MIDI are equal |
| `testNoteEqualityDifferentNames` | Edge | C# (61) == Db (61) |
| `testNoteFromMidiValidNote` | Happy | midiNumber 60 → Note "C" |
| `testNoteFromMidiPreferSharps` | Happy | midiNumber 61 + preferSharps → "C#" |
| `testNoteFromMidiPreferFlats` | Happy | midiNumber 61 + !preferSharps → "Db" |
| `testNoteFromMidiInvalidNumber` | Negative | midiNumber -1 → nil |
| `testNoteFromMidiHighOctave` | Edge | midiNumber 96 → valid note |

#### ChordTone Struct
| Test Case | Type | Description |
|-----------|------|-------------|
| `testChordToneRoot` | Happy | Root has 0 semitones |
| `testChordTone3rd` | Happy | 3rd has 4 semitones |
| `testChordToneFlatFive` | Happy | b5 has 6 semitones |
| `testChordToneIsAlteredFlag` | Happy | b5 is altered, 5th is not |

#### ChordType Struct
| Test Case | Type | Description |
|-----------|------|-------------|
| `testChordTypeInit` | Happy | Creates chord type with correct properties |
| `testChordTypeDifficulty` | Happy | Difficulty levels are correct |

#### Chord Struct
| Test Case | Type | Description |
|-----------|------|-------------|
| `testChordDisplayName` | Happy | C + maj7 → "Cmaj7" |
| `testChordFullName` | Happy | C + maj7 → "C Major 7th" |
| `testChordToneCalculation` | Happy | Cmaj7 contains C, E, G, B |
| `testChordToneEnharmonicSpelling` | Edge | F# chord uses sharps, Bb chord uses flats |
| `testChordRootInDifferentOctaves` | Edge | Chord works with roots in different octaves |

#### QuizQuestion (if present)
| Test Case | Type | Description |
|-----------|------|-------------|
| `testQuestionGeneration` | Happy | Creates valid question |
| `testAnswerValidation` | Happy | Correct answer validates true |
| `testAnswerValidationIncorrect` | Sad | Wrong answer validates false |
| `testAnswerValidationPartial` | Edge | Partial answer handling |

### 2.2 ScaleModel.swift
**Key Behaviors to Test:**

#### ScaleDegree Struct
| Test Case | Type | Description |
|-----------|------|-------------|
| `testScaleDegreeInit` | Happy | Creates degree with correct interval |
| `testScaleDegreeAlteredNaming` | Happy | b3 named correctly |

#### ScaleType Struct  
| Test Case | Type | Description |
|-----------|------|-------------|
| `testMajorScaleIntervals` | Happy | Major scale has correct degrees |
| `testMinorScaleIntervals` | Happy | Natural minor has correct degrees |
| `testModeIntervals` | Happy | Dorian, Mixolydian, etc. |

#### Scale Struct
| Test Case | Type | Description |
|-----------|------|-------------|
| `testScaleNoteGeneration` | Happy | C Major → C D E F G A B |
| `testScaleInFlatKey` | Edge | Bb Major uses flats |
| `testScaleInSharpKey` | Edge | F# Major uses sharps |

### 2.3 IntervalModel.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testIntervalSemitones` | Happy | Minor 3rd = 3 semitones |
| `testIntervalFromNotes` | Happy | C to E = Major 3rd |
| `testIntervalDescending` | Edge | E to C = Major 3rd descending |
| `testTritoneBothDirections` | Edge | Tritone ambiguous |

### 2.4 SpacedRepetition.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testSRItemIDEquality` | Happy | Same mode/topic/key → equal |
| `testSRItemIDDifferentMode` | Sad | Different mode → not equal |
| `testSRScheduleIsDue` | Happy | Past date is due |
| `testSRScheduleNotDue` | Happy | Future date is not due |
| `testSRScheduleEaseFactorBounds` | Edge | Ease factor stays 1.3-3.0 |
| `testSRRecordCorrectAnswer` | Happy | Correct increases interval |
| `testSRRecordIncorrectAnswer` | Sad | Incorrect resets interval |
| `testSRMaturityLevels` | Happy | Correct maturity for interval |

### 2.5 PlayerProfile.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testRatingChange` | Happy | Win increases rating |
| `testRatingChangeLoss` | Sad | Loss decreases rating |
| `testRatingFloor` | Edge | Rating doesn't go below 0 |
| `testStreakIncrement` | Happy | Consecutive wins increase streak |
| `testStreakReset` | Sad | Loss resets streak |
| `testAchievementUnlock` | Happy | Meeting criteria unlocks achievement |
| `testAchievementNotDuplicated` | Edge | Same achievement not unlocked twice |
| `testPersistenceSaveLoad` | Integration | Save and load roundtrip |

---

## Phase 3: Game Logic Testing (Priority 2)

### 3.1 QuizGame.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testStartNewQuiz` | Happy | Initializes with correct question count |
| `testQuestionGeneration` | Happy | Generates unique questions |
| `testSubmitCorrectAnswer` | Happy | Correct answer recorded properly |
| `testSubmitIncorrectAnswer` | Sad | Incorrect answer recorded |
| `testQuizCompletion` | Happy | Quiz ends after all questions |
| `testScoreCalculation` | Happy | Accuracy calculated correctly |
| `testRatingChangeCalculation` | Happy | Rating change based on performance |
| `testMoveToNextQuestion` | Happy | Advances question index |
| `testQuizNotActiveAfterComplete` | Edge | isQuizActive false after finish |

### 3.2 ScaleGame.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testStartScaleQuiz` | Happy | Initializes scale quiz |
| `testEarTrainingAnswerTracking` | Happy | Ear training answers stored correctly |
| `testCorrectAnswersCalculation` | Happy | Mix of ear/visual counted correctly |
| `testSpacedRepetitionRecording` | Integration | Results saved to SR store |

### 3.3 CadenceGame.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testCadenceGeneration` | Happy | Generates valid cadence |
| `testCadenceAnswerValidation` | Happy | Correct answer validates |
| `testCadenceTypeFiltering` | Happy | Only selected types generated |

### 3.4 IntervalGame.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testIntervalQuizGeneration` | Happy | Generates interval questions |
| `testIntervalAnswerValidation` | Happy | Correct interval identified |

---

## Phase 4: Database Testing (Priority 3)

### 4.1 JazzChordDatabase.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testAllChordsExist` | Happy | Database has all expected chords |
| `testChordsByDifficulty` | Happy | Filtering by difficulty works |
| `testChordToneCorrectness` | Validation | Each chord has correct tones |
| `testNoEmptyChords` | Negative | No chord has 0 tones |

### 4.2 JazzScaleDatabase.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testAllScalesExist` | Happy | Database has all scales |
| `testScaleDegreeCorrectness` | Validation | Each scale has correct degrees |
| `testScalesByDifficulty` | Happy | Filtering works |

### 4.3 IntervalDatabase.swift
| Test Case | Type | Description |
|-----------|------|-------------|
| `testAllIntervalsExist` | Happy | All 12 intervals present |
| `testIntervalSemitoneMapping` | Validation | Each interval has correct semitones |

---

## Phase 5: Integration Testing (Priority 4)

### 5.1 Quiz Flow Integration
| Test Case | Description |
|-----------|-------------|
| `testCompleteChordQuizFlow` | Start quiz → answer all → view results |
| `testQuizWithSpacedRepetition` | Answers update SR store |
| `testQuizWithPlayerProfile` | Answers update profile stats |

### 5.2 Persistence Integration
| Test Case | Description |
|-----------|-------------|
| `testUserDefaultsRoundTrip` | Save data, reload, verify |
| `testDataMigration` | Old format migrates to new |

---

## Phase 6: UI Testing (Priority 5 - Lower)

UI tests are more brittle and slower. Focus on critical user journeys:

| Test Case | Description |
|-----------|-------------|
| `testNavigateToChordDrill` | Can reach chord drill from home |
| `testCompleteQuizUI` | Can complete a full quiz via UI |
| `testSettingsAccessible` | Settings view opens correctly |

---

## Testing Best Practices

### 1. Test Naming Convention
```swift
func test_[UnitOfWork]_[StateUnderTest]_[ExpectedBehavior]()
// Example:
func test_submitAnswer_withCorrectNotes_returnsTrue()
```

### 2. AAA Pattern (Arrange-Act-Assert)
```swift
func testChordDisplayName() {
    // Arrange
    let root = Note(name: "C", midiNumber: 60, isSharp: false)
    let chordType = ChordType(name: "Major 7th", symbol: "maj7", ...)
    let chord = Chord(root: root, chordType: chordType)
    
    // Act
    let displayName = chord.displayName
    
    // Assert
    XCTAssertEqual(displayName, "Cmaj7")
}
```

### 3. Test Independence
- Each test should be independent
- Use `setUp()` and `tearDown()` for common setup
- Don't rely on test execution order

### 4. Mock Dependencies
For components with external dependencies (AudioManager, UserDefaults):
```swift
protocol AudioManagerProtocol {
    func playNote(_ midiNumber: Int, velocity: Int)
}

class MockAudioManager: AudioManagerProtocol {
    var playedNotes: [Int] = []
    func playNote(_ midiNumber: Int, velocity: Int) {
        playedNotes.append(midiNumber)
    }
}
```

### 5. Test Coverage Goals
| Category | Target Coverage |
|----------|----------------|
| Models | 95%+ |
| Game Logic | 90%+ |
| Databases | 85%+ |
| Views | 50%+ (focus on logic in views) |
| Overall | 90%+ |

---

## Implementation Order

### Week 1: Foundation
1. ✅ Create test target in Xcode
2. ✅ Verify sanity test passes
3. ✅ Test `Note` struct completely
4. ✅ Test `ChordTone` struct completely

### Week 2: Core Models
1. Test `ChordType` struct
2. Test `Chord` struct
3. Test `ScaleDegree` and `ScaleType`
4. Test `Scale` struct

### Week 3: Spaced Repetition & Profile
1. Test `SRItemID`
2. Test `SRSchedule`
3. Test `SpacedRepetitionStore`
4. Test `PlayerProfile`

### Week 4: Game Logic
1. Test `QuizGame`
2. Test `ScaleGame`
3. Test `CadenceGame`
4. Test `IntervalGame`

### Week 5: Databases & Integration
1. Test all databases
2. Integration tests for quiz flows
3. Persistence tests

### Week 6: Polish & UI
1. Fill coverage gaps
2. Add edge case tests found during development
3. Basic UI tests for critical paths

---

## Continuous Integration

### Keeping Tests Up to Date
1. **Pre-commit hook**: Run tests before allowing commits
2. **PR requirement**: All tests must pass
3. **Coverage enforcement**: Fail build if coverage drops below threshold
4. **New feature requirement**: Every new feature must include tests

### Test Maintenance Rules
1. When fixing a bug, add a test that would have caught it
2. When adding a feature, write tests first (TDD) or immediately after
3. Review test coverage weekly
4. Refactor tests when refactoring code

---

## Getting Started Checklist

- [ ] Create `JazzHarmonyQuizTests` target in Xcode
- [ ] Add first sanity test
- [ ] Run tests via Cmd+U
- [ ] Enable code coverage in scheme
- [ ] View coverage report
- [ ] Add tests for `Note` struct
- [ ] Verify coverage improves
- [ ] Continue with testing plan

---

## Next Steps

Ready to begin? The first action is to:
1. Open the project in Xcode
2. Add a test target (File → New → Target → Unit Testing Bundle)
3. Create the first test file
4. Run tests to verify the harness works

Would you like me to create the test target and initial test files?
