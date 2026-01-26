# Jazz Harmony Quiz (Shed Pro)

A comprehensive iOS app for learning and practicing jazz harmony through interactive drills, ear training, and a structured curriculum system.

## Features

### 🎵 Practice Modes

| Mode | Description |
|------|-------------|
| **Chord Drill** | Identify chord tones, qualities, and voicings |
| **Cadence Drill** | Master ii-V-I progressions and jazz cadences |
| **Scale Drill** | Practice modes, jazz scales, and scale degrees |
| **Interval Drill** | Ear training for interval identification |
| **Quick Practice** | AI-generated sessions based on your weak areas |

### 📚 Curriculum System

Four structured learning pathways:
- **Harmony Foundations** - Triads, 7th chords, extensions
- **Functional Harmony** - Cadences, voice leading, progressions  
- **Ear Training** - Aural recognition, interval hearing
- **Advanced Topics** - Alterations, substitutions, modern jazz

### 🧠 Spaced Repetition

SM-2 algorithm for optimized learning:
- Automatic scheduling based on performance
- Due items highlighted for review
- Progress tracking per concept

### 🎹 Interactive Piano Keyboard

- Visual feedback for selected notes
- MIDI synthesis for realistic sound
- Multiple playback styles (block/arpeggio)

### 📊 Progress Tracking

- XP-based leveling system
- Accuracy statistics per topic
- Achievement badges
- Practice streaks

## Technical Architecture

### Project Structure

```
JazzHarmonyQuiz/
├── App/                    # Entry point
├── Core/                   # Databases, Models, Services
├── Features/               # Feature modules (Chord, Cadence, etc.)
├── Components/             # Shared UI components
├── Helpers/                # Utilities
└── Models/                 # Game state classes
```

See [ARCHITECTURE.md](ARCHITECTURE.md) for detailed documentation.

## Requirements

- iOS 16.0+
- Xcode 16.0+
- Swift 5.0+

## Developer Setup

### 1. Clone and Open

```bash
git clone https://github.com/ryanmoffett1/JazzHarmonyQuiz.git
cd JazzHarmonyQuiz
open JazzHarmonyQuiz.xcodeproj
```

### 2. SoundFont Setup (Required for Audio)

The app requires a `.sf2` SoundFont file for MIDI playback:

1. Download a piano SoundFont (e.g., GeneralUser GS, Yamaha Grand)
2. Rename to `GeneralUser GS.sf2`
3. Add to the Resources folder in Xcode
4. Ensure it's included in the target's "Copy Bundle Resources"

See [SOUNDFONT_SETUP_INSTRUCTIONS.md](SOUNDFONT_SETUP_INSTRUCTIONS.md) for details.

### 3. Build and Run

1. Select your target device (iPhone 16 recommended)
2. Press `⌘+R` to build and run

### 4. Running Tests

```bash
# Run all tests
xcodebuild test -scheme JazzHarmonyQuiz \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'

# Run specific test suite
xcodebuild test -scheme JazzHarmonyQuiz \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' \
  -only-testing:JazzHarmonyQuizTests/ChordDrillGameTests
```

Or in Xcode: `⌘+U` to run all tests

## Development Guidelines

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code style conventions
- Commit message format  
- Testing requirements
- Pull request process

## Documentation

| Document | Purpose |
|----------|---------|
| [ARCHITECTURE.md](ARCHITECTURE.md) | Technical architecture & file reference |
| [DESIGN.md](DESIGN.md) | UI/UX design specifications |
| [IMPLEMENTATION_PLAN.md](IMPLEMENTATION_PLAN.md) | Development roadmap |

## License

Private repository. All rights reserved.
- Social features and sharing
- Advanced statistics and analytics
- Multiple instrument support (guitar, bass)

## License

This project is created for educational purposes. Feel free to use and modify as needed.
