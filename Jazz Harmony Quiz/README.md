# Jazz Harmony Quiz

A comprehensive iOS app for learning and practicing jazz chord theory through interactive quizzes and piano keyboard input.

## Features

### 🎵 Chord Drill Mode
- **Single Tone Questions**: Identify specific chord tones (e.g., "What is the b9 of D7b9?")
- **All Tones Questions**: Play all chord tones for a given chord
- **Chord Spelling**: Spell entire chords by selecting all chord tones

### 🎹 Interactive Piano Keyboard
- Visual piano keyboard with white and black keys
- Touch input for chord tone selection
- Visual feedback for selected notes
- Support for multiple note selection

### 📊 Comprehensive Chord Database
- **Beginner**: Major/minor triads, dominant 7th, major 7th, minor 7th
- **Intermediate**: Minor major 7th, half diminished, diminished 7th, augmented 7th, 9th chords
- **Advanced**: Altered dominants (b9, #9, b5, #5, b9#9, etc.)
- **Expert**: 11th and 13th chords, complex alterations

### ⏱️ Timing and Scoring
- Real-time timing for each question
- Overall quiz timing
- Accuracy scoring
- Performance tracking

### 🏆 Leaderboard System
- Top 10 scores tracking
- Multiple sorting options (best score, best time, most recent)
- Persistent storage using UserDefaults
- Visual ranking with trophies for top 3

### 📈 Results and Review
- Detailed results screen with performance breakdown
- Review incorrect answers with explanations
- Visual comparison of user answers vs. correct answers
- Encouragement messages based on performance

## Technical Architecture

### Models
- **ChordModel.swift**: Core data structures for notes, chord tones, and chords
- **QuizGame.swift**: Game logic, timing, scoring, and leaderboard management
- **JazzChordDatabase.swift**: Comprehensive database of jazz chord types

### Views
- **ContentView.swift**: Main navigation and app entry point
- **ChordDrillView.swift**: Quiz setup and active quiz interface
- **PianoKeyboard.swift**: Interactive piano keyboard component
- **ResultsView.swift**: Results display and answer review
- **LeaderboardView.swift**: Score tracking and statistics

### Key Features
- **SwiftUI**: Modern declarative UI framework
- **ObservableObject**: Reactive state management
- **UserDefaults**: Persistent leaderboard storage
- **Codable**: Data serialization for saving/loading
- **Timer**: Real-time quiz timing

## Chord Types Included

### Beginner (5 types)
- Major Triad, Minor Triad, Dominant 7th, Major 7th, Minor 7th

### Intermediate (7 types)
- Minor Major 7th, Half Diminished 7th, Diminished 7th, Augmented 7th, Major 9th, Dominant 9th, Minor 9th

### Advanced (8 types)
- Dominant 7th b9, Dominant 7th #9, Dominant 7th b5, Dominant 7th #5, Dominant 7th b9#9, Dominant 7th b9b5, Dominant 7th #9#5

### Expert (10 types)
- Complex altered dominants, Major 11th, Dominant 11th, Minor 11th, Major 13th, Dominant 13th, Minor 13th, Dominant 7th b13, Dominant 7th #13

## Usage

1. **Setup Quiz**: Choose number of questions (5-30), difficulty level, and question types
2. **Take Quiz**: Answer questions using the piano keyboard interface
3. **Review Results**: See detailed performance breakdown and review incorrect answers
4. **Track Progress**: View leaderboard and statistics to monitor improvement

## Requirements

- iOS 17.0+
- Xcode 15.0+
- Swift 5.0+

## Installation

1. Open `JazzHarmonyQuiz.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run the project (⌘+R)

## Future Enhancements

- Audio playback for chord tones
- More question types (chord progressions, voice leading)
- Custom chord creation
- Social features and sharing
- Advanced statistics and analytics
- Multiple instrument support (guitar, bass)

## License

This project is created for educational purposes. Feel free to use and modify as needed.
