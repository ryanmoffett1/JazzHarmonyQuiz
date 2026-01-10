# Jazz Harmony Quiz Tests

This directory contains comprehensive unit tests for the Jazz Harmony Quiz app.

## Test Files

### ChordModelTests.swift
Tests for the core data models:
- **Note Tests**: Equality, MIDI conversion, enharmonic equivalents, octave wrapping
- **ChordTone Tests**: Degree definitions, semitones, altered tones
- **ChordType Tests**: Major triads, dominant 7ths, and other chord type structures
- **Chord Tests**: Chord construction, display names, tonality preferences, chord tone retrieval
- **QuizQuestion Tests**: Single tone, all tones, and chord spelling question creation
- **QuizResult Tests**: Result creation, accuracy calculation, encoding/decoding

### JazzChordDatabaseTests.swift
Tests for the chord database:
- **Database Initialization**: Verifies database setup and chord type count
- **Chord Type Filtering**: Tests filtering by difficulty (beginner, intermediate, advanced, expert)
- **Specific Chord Types**: Validates existence of specific chords (Major Triad, Dom7, Half Diminished, etc.)
- **Chord Generation**: Tests generation of all chords and chord filtering
- **Random Chord Tests**: Verifies random chord selection with and without difficulty filters
- **Chord Root Coverage**: Ensures all roots (sharps and flats) are covered
- **Validation Tests**: Validates chord type structure and difficulty progression

### QuizGameTests.swift
Tests for the quiz game logic:
- **Initialization**: Verifies quiz state on startup
- **Quiz Start**: Tests quiz initialization with different configurations
- **Question Generation**: Validates question generation for different question types
- **Answer Submission**: Tests answer recording and progression
- **Answer Correctness**: Verifies correct/incorrect answer detection including octave wrapping
- **Navigation**: Tests question navigation (next/previous)
- **Progress Tracking**: Validates progress calculation and statistics
- **Statistics**: Tests score calculation and time tracking
- **Reset**: Verifies quiz state reset
- **Leaderboard**: Tests leaderboard saving, sorting, and max size
- **Edge Cases**: Tests empty answers, all wrong answers, single question quizzes, etc.

## Running Tests

### In Xcode
1. Open `JazzHarmonyQuiz.xcodeproj` in Xcode
2. Select the test navigator (⌘5)
3. Click the play button next to "JazzHarmonyQuizTests" to run all tests
4. Or click individual test files or test methods to run specific tests

### Using Command Line
```bash
cd "Jazz Harmony Quiz"
xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 15'
```

## Test Coverage

The tests cover:
- ✅ Note creation and enharmonic equivalents
- ✅ MIDI number conversion and octave wrapping
- ✅ Chord tone definitions and calculations
- ✅ Chord construction with correct tonality
- ✅ Quiz question generation for all question types
- ✅ Quiz result tracking and statistics
- ✅ Chord database initialization and filtering
- ✅ Random chord selection
- ✅ Quiz game state management
- ✅ Answer validation and scoring
- ✅ Leaderboard management
- ✅ Edge cases and error handling

## Adding New Tests

To add new tests:

1. Open the appropriate test file or create a new one
2. Follow the existing test naming convention: `test[WhatYouAreTesting]()`
3. Use `XCTAssert` methods to validate expectations
4. Group related tests with `// MARK: -` comments
5. Use `setUp()` and `tearDown()` for test initialization and cleanup

Example:
```swift
func testMyNewFeature() {
    // Arrange
    let expectedValue = 10
    
    // Act
    let actualValue = myFunction()
    
    // Assert
    XCTAssertEqual(actualValue, expectedValue, "The function should return 10")
}
```

## Test Principles

These tests follow best practices:
- **Arrange-Act-Assert**: Clear test structure
- **Independence**: Each test runs independently
- **Fast**: Tests run quickly without external dependencies
- **Descriptive Names**: Test names clearly describe what they test
- **Comprehensive**: Cover both happy paths and edge cases
