# Interval Drill Mode - Implementation Plan

## Overview

Add a new **Interval Drill** mode to Jazz Harmony Quiz that tests users on musical intervals. This mode will follow the same patterns established by Chord Drill, Scale Drill, and Cadence Mode, integrating with the existing rating system and leaderboard infrastructure.

---

## Feature Description

### What is an Interval?
An interval is the distance between two notes, measured in semitones. Intervals are fundamental to understanding chords, scales, and melody construction.

### Core Functionality
Users will be tested on their knowledge of intervals through multiple question types:
1. **Identify the Interval**: Given two notes on the keyboard, name the interval
2. **Build the Interval**: Given a root note and interval name, select the correct second note
3. **Ear Training** (optional): Hear two notes played, identify the interval

---

## Data Models

### IntervalModel.swift

```swift
import Foundation

// MARK: - Interval Type

/// Represents a musical interval with its properties
struct IntervalType: Identifiable, Hashable, Codable {
    let id = UUID()
    let name: String           // "Minor Third", "Perfect Fifth"
    let shortName: String      // "m3", "P5"
    let semitones: Int         // Distance in semitones
    let quality: IntervalQuality
    let number: Int            // Interval number (1-13)
    let difficulty: IntervalDifficulty
    
    static func == (lhs: IntervalType, rhs: IntervalType) -> Bool {
        lhs.semitones == rhs.semitones
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(semitones)
    }
}

// MARK: - Interval Quality

enum IntervalQuality: String, Codable, CaseIterable {
    case perfect = "Perfect"
    case major = "Major"
    case minor = "Minor"
    case augmented = "Augmented"
    case diminished = "Diminished"
    
    var abbreviation: String {
        switch self {
        case .perfect: return "P"
        case .major: return "M"
        case .minor: return "m"
        case .augmented: return "A"
        case .diminished: return "d"
        }
    }
}

// MARK: - Interval Difficulty

enum IntervalDifficulty: String, Codable, CaseIterable, Comparable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    
    static func < (lhs: IntervalDifficulty, rhs: IntervalDifficulty) -> Bool {
        let order: [IntervalDifficulty] = [.beginner, .intermediate, .advanced]
        return order.firstIndex(of: lhs)! < order.firstIndex(of: rhs)!
    }
}

// MARK: - Interval Instance

/// A specific interval between two notes
struct Interval: Identifiable {
    let id = UUID()
    let rootNote: Note
    let intervalType: IntervalType
    
    /// The second note of the interval
    var targetNote: Note {
        let targetMidi = rootNote.midiNumber + intervalType.semitones
        return Note.from(midiNumber: targetMidi)
    }
    
    /// Display name (e.g., "C to E - Major Third")
    var displayName: String {
        "\(rootNote.name) to \(targetNote.name) - \(intervalType.name)"
    }
}

// MARK: - Interval Direction

enum IntervalDirection: String, Codable, CaseIterable {
    case ascending = "Ascending"
    case descending = "Descending"
    case both = "Both"
}

// MARK: - Question Types

enum IntervalQuestionType: String, Codable, CaseIterable {
    case identifyInterval = "Identify Interval"    // See two notes, name the interval
    case buildInterval = "Build Interval"          // Given root + interval, find the note
    case aurally = "Ear Training"                  // Hear interval, identify it
    
    var description: String {
        switch self {
        case .identifyInterval:
            return "Name the interval between two notes"
        case .buildInterval:
            return "Find the note that creates the interval"
        case .aurally:
            return "Identify the interval by ear"
        }
    }
    
    var icon: String {
        switch self {
        case .identifyInterval: return "eyes"
        case .buildInterval: return "hammer"
        case .aurally: return "ear"
        }
    }
}

// MARK: - Interval Question

struct IntervalQuestion: Identifiable {
    let id = UUID()
    let interval: Interval
    let questionType: IntervalQuestionType
    let direction: IntervalDirection
    
    /// The correct answer note (for build questions)
    var correctNote: Note {
        interval.targetNote
    }
    
    /// Check if user's answer is correct (pitch-class comparison)
    func isCorrect(userAnswer: Note) -> Bool {
        userAnswer.pitchClass == correctNote.pitchClass
    }
    
    /// Check if user identified the correct interval type
    func isCorrect(userAnswer: IntervalType) -> Bool {
        userAnswer.semitones == interval.intervalType.semitones
    }
    
    /// Question text based on type
    var questionText: String {
        switch questionType {
        case .identifyInterval:
            return "What interval is \(interval.rootNote.name) to \(interval.targetNote.name)?"
        case .buildInterval:
            return "Find the \(interval.intervalType.name) above \(interval.rootNote.name)"
        case .aurally:
            return "What interval did you hear?"
        }
    }
}

// MARK: - Quiz Result

struct IntervalQuizResult: Identifiable, Codable {
    let id: UUID
    let date: Date
    let totalQuestions: Int
    let correctAnswers: Int
    let totalTime: TimeInterval
    let difficulty: IntervalDifficulty
    let questionTypes: [IntervalQuestionType]
    let ratingChange: Int
    
    var accuracy: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    var averageTimePerQuestion: TimeInterval {
        guard totalQuestions > 0 else { return 0 }
        return totalTime / Double(totalQuestions)
    }
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        totalQuestions: Int,
        correctAnswers: Int,
        totalTime: TimeInterval,
        difficulty: IntervalDifficulty,
        questionTypes: [IntervalQuestionType],
        ratingChange: Int = 0
    ) {
        self.id = id
        self.date = date
        self.totalQuestions = totalQuestions
        self.correctAnswers = correctAnswers
        self.totalTime = totalTime
        self.difficulty = difficulty
        self.questionTypes = questionTypes
        self.ratingChange = ratingChange
    }
}
```

---

### IntervalDatabase.swift

```swift
import Foundation

/// Database of all musical intervals organized by difficulty
class IntervalDatabase {
    static let shared = IntervalDatabase()
    
    private init() {}
    
    // MARK: - All Intervals
    
    /// Complete list of intervals from unison to compound intervals
    let allIntervals: [IntervalType] = [
        // Beginner - Perfect intervals and basic major/minor
        IntervalType(name: "Unison", shortName: "P1", semitones: 0, 
                     quality: .perfect, number: 1, difficulty: .beginner),
        IntervalType(name: "Minor Second", shortName: "m2", semitones: 1, 
                     quality: .minor, number: 2, difficulty: .intermediate),
        IntervalType(name: "Major Second", shortName: "M2", semitones: 2, 
                     quality: .major, number: 2, difficulty: .beginner),
        IntervalType(name: "Minor Third", shortName: "m3", semitones: 3, 
                     quality: .minor, number: 3, difficulty: .beginner),
        IntervalType(name: "Major Third", shortName: "M3", semitones: 4, 
                     quality: .major, number: 3, difficulty: .beginner),
        IntervalType(name: "Perfect Fourth", shortName: "P4", semitones: 5, 
                     quality: .perfect, number: 4, difficulty: .beginner),
        IntervalType(name: "Tritone", shortName: "TT", semitones: 6, 
                     quality: .augmented, number: 4, difficulty: .intermediate),
        IntervalType(name: "Perfect Fifth", shortName: "P5", semitones: 7, 
                     quality: .perfect, number: 5, difficulty: .beginner),
        IntervalType(name: "Minor Sixth", shortName: "m6", semitones: 8, 
                     quality: .minor, number: 6, difficulty: .intermediate),
        IntervalType(name: "Major Sixth", shortName: "M6", semitones: 9, 
                     quality: .major, number: 6, difficulty: .intermediate),
        IntervalType(name: "Minor Seventh", shortName: "m7", semitones: 10, 
                     quality: .minor, number: 7, difficulty: .intermediate),
        IntervalType(name: "Major Seventh", shortName: "M7", semitones: 11, 
                     quality: .major, number: 7, difficulty: .intermediate),
        IntervalType(name: "Octave", shortName: "P8", semitones: 12, 
                     quality: .perfect, number: 8, difficulty: .beginner),
        
        // Advanced - Compound intervals
        IntervalType(name: "Minor Ninth", shortName: "m9", semitones: 13, 
                     quality: .minor, number: 9, difficulty: .advanced),
        IntervalType(name: "Major Ninth", shortName: "M9", semitones: 14, 
                     quality: .major, number: 9, difficulty: .advanced),
        IntervalType(name: "Minor Tenth", shortName: "m10", semitones: 15, 
                     quality: .minor, number: 10, difficulty: .advanced),
        IntervalType(name: "Major Tenth", shortName: "M10", semitones: 16, 
                     quality: .major, number: 10, difficulty: .advanced),
        IntervalType(name: "Perfect Eleventh", shortName: "P11", semitones: 17, 
                     quality: .perfect, number: 11, difficulty: .advanced),
        IntervalType(name: "Augmented Eleventh", shortName: "A11", semitones: 18, 
                     quality: .augmented, number: 11, difficulty: .advanced),
        IntervalType(name: "Perfect Twelfth", shortName: "P12", semitones: 19, 
                     quality: .perfect, number: 12, difficulty: .advanced),
        IntervalType(name: "Minor Thirteenth", shortName: "m13", semitones: 20, 
                     quality: .minor, number: 13, difficulty: .advanced),
        IntervalType(name: "Major Thirteenth", shortName: "M13", semitones: 21, 
                     quality: .major, number: 13, difficulty: .advanced),
    ]
    
    // MARK: - Filtered Access
    
    func intervals(for difficulty: IntervalDifficulty) -> [IntervalType] {
        allIntervals.filter { $0.difficulty <= difficulty }
    }
    
    func intervals(withQualities qualities: Set<IntervalQuality>) -> [IntervalType] {
        allIntervals.filter { qualities.contains($0.quality) }
    }
    
    /// Get a random interval with optional filters
    func getRandomInterval(
        difficulty: IntervalDifficulty = .intermediate,
        rootNote: Note? = nil,
        qualities: Set<IntervalQuality>? = nil
    ) -> Interval {
        var candidates = intervals(for: difficulty)
        
        if let qualities = qualities, !qualities.isEmpty {
            candidates = candidates.filter { qualities.contains($0.quality) }
        }
        
        let intervalType = candidates.randomElement() ?? allIntervals[0]
        let root = rootNote ?? Note.allNotes.randomElement()!
        
        return Interval(rootNote: root, intervalType: intervalType)
    }
}
```

---

### IntervalGame.swift

```swift
import Foundation
import SwiftUI

/// Manages the Interval Drill quiz state and logic
@MainActor
class IntervalGame: ObservableObject {
    // MARK: - Published Properties
    
    @Published var currentQuestion: IntervalQuestion?
    @Published var questionNumber: Int = 0
    @Published var totalQuestions: Int = 10
    @Published var correctAnswers: Int = 0
    @Published var hasAnswered: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var elapsedTime: TimeInterval = 0
    @Published var isQuizActive: Bool = false
    @Published var showingResults: Bool = false
    @Published var leaderboard: [IntervalQuizResult] = []
    @Published var lastRatingChange: Int = 0
    
    // MARK: - Quiz Configuration
    
    var selectedDifficulty: IntervalDifficulty = .beginner
    var selectedQuestionTypes: Set<IntervalQuestionType> = [.buildInterval]
    var selectedDirection: IntervalDirection = .ascending
    var selectedKeyDifficulty: KeyDifficulty = .natural
    
    // MARK: - Private Properties
    
    private var questions: [IntervalQuestion] = []
    private var questionStartTime: Date?
    private var quizStartTime: Date?
    private var timer: Timer?
    private let database = IntervalDatabase.shared
    
    // MARK: - Persistence Keys
    
    private let leaderboardKey = "intervalLeaderboard"
    
    // MARK: - Initialization
    
    init() {
        loadLeaderboard()
    }
    
    // MARK: - Quiz Management
    
    func startQuiz(
        numberOfQuestions: Int,
        difficulty: IntervalDifficulty,
        questionTypes: Set<IntervalQuestionType>,
        direction: IntervalDirection,
        keyDifficulty: KeyDifficulty
    ) {
        self.totalQuestions = numberOfQuestions
        self.selectedDifficulty = difficulty
        self.selectedQuestionTypes = questionTypes
        self.selectedDirection = direction
        self.selectedKeyDifficulty = keyDifficulty
        
        // Generate questions
        questions = generateQuestions(count: numberOfQuestions)
        
        // Reset state
        questionNumber = 0
        correctAnswers = 0
        hasAnswered = false
        lastAnswerCorrect = false
        elapsedTime = 0
        showingResults = false
        isQuizActive = true
        quizStartTime = Date()
        
        // Start timer
        startTimer()
        
        // Load first question
        nextQuestion()
    }
    
    private func generateQuestions(count: Int) -> [IntervalQuestion] {
        var generatedQuestions: [IntervalQuestion] = []
        let availableRoots = selectedKeyDifficulty.availableRoots
        let questionTypesArray = Array(selectedQuestionTypes)
        
        for _ in 0..<count {
            let root = availableRoots.randomElement() ?? Note.c
            let interval = database.getRandomInterval(
                difficulty: selectedDifficulty,
                rootNote: root
            )
            
            let questionType = questionTypesArray.randomElement() ?? .buildInterval
            let direction: IntervalDirection = selectedDirection == .both 
                ? [.ascending, .descending].randomElement()! 
                : selectedDirection
            
            let question = IntervalQuestion(
                interval: interval,
                questionType: questionType,
                direction: direction
            )
            generatedQuestions.append(question)
        }
        
        return generatedQuestions
    }
    
    func nextQuestion() {
        guard questionNumber < questions.count else {
            endQuiz()
            return
        }
        
        currentQuestion = questions[questionNumber]
        questionNumber += 1
        hasAnswered = false
        questionStartTime = Date()
    }
    
    // MARK: - Answer Checking
    
    /// Check answer for "Build Interval" questions (user selects a note)
    func checkAnswer(selectedNote: Note) -> Bool {
        guard let question = currentQuestion, !hasAnswered else { return false }
        
        hasAnswered = true
        let isCorrect = question.isCorrect(userAnswer: selectedNote)
        lastAnswerCorrect = isCorrect
        
        if isCorrect {
            correctAnswers += 1
        }
        
        return isCorrect
    }
    
    /// Check answer for "Identify Interval" questions (user selects interval type)
    func checkAnswer(selectedInterval: IntervalType) -> Bool {
        guard let question = currentQuestion, !hasAnswered else { return false }
        
        hasAnswered = true
        let isCorrect = question.isCorrect(userAnswer: selectedInterval)
        lastAnswerCorrect = isCorrect
        
        if isCorrect {
            correctAnswers += 1
        }
        
        return isCorrect
    }
    
    // MARK: - Timer
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self, let startTime = self.quizStartTime else { return }
                self.elapsedTime = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - End Quiz
    
    func endQuiz() {
        stopTimer()
        isQuizActive = false
        showingResults = true
        
        // Calculate rating change
        let accuracy = Double(correctAnswers) / Double(totalQuestions)
        let ratingChange = PlayerStats.shared.calculateRatingChange(
            accuracy: accuracy,
            difficulty: difficultyMultiplier,
            questionCount: totalQuestions
        )
        
        // Update player stats
        PlayerStats.shared.updateRating(change: ratingChange)
        PlayerStats.shared.recordQuizCompletion(
            mode: "interval",
            questionsAnswered: totalQuestions,
            correctAnswers: correctAnswers,
            timeSpent: elapsedTime
        )
        
        lastRatingChange = ratingChange
        
        // Save result
        let result = IntervalQuizResult(
            totalQuestions: totalQuestions,
            correctAnswers: correctAnswers,
            totalTime: elapsedTime,
            difficulty: selectedDifficulty,
            questionTypes: Array(selectedQuestionTypes),
            ratingChange: ratingChange
        )
        
        addToLeaderboard(result)
    }
    
    private var difficultyMultiplier: Double {
        switch selectedDifficulty {
        case .beginner: return 0.8
        case .intermediate: return 1.0
        case .advanced: return 1.3
        }
    }
    
    // MARK: - Leaderboard
    
    private func addToLeaderboard(_ result: IntervalQuizResult) {
        leaderboard.append(result)
        leaderboard.sort { 
            $0.accuracy > $1.accuracy || 
            ($0.accuracy == $1.accuracy && $0.totalTime < $1.totalTime) 
        }
        leaderboard = Array(leaderboard.prefix(10))
        saveLeaderboard()
    }
    
    // MARK: - Persistence
    
    private func loadLeaderboard() {
        if let data = UserDefaults.standard.data(forKey: leaderboardKey),
           let decoded = try? JSONDecoder().decode([IntervalQuizResult].self, from: data) {
            leaderboard = decoded
        }
    }
    
    private func saveLeaderboard() {
        if let encoded = try? JSONEncoder().encode(leaderboard) {
            UserDefaults.standard.set(encoded, forKey: leaderboardKey)
        }
    }
    
    func resetQuiz() {
        stopTimer()
        currentQuestion = nil
        questionNumber = 0
        correctAnswers = 0
        hasAnswered = false
        lastAnswerCorrect = false
        elapsedTime = 0
        isQuizActive = false
        showingResults = false
        questions = []
    }
}
```

---

## Views

### IntervalDrillView.swift Structure

```
IntervalDrillView
├── ViewState: .setup | .active | .results
│
├── SetupView
│   ├── Difficulty Picker (Beginner/Intermediate/Advanced)
│   ├── Question Count Slider (5-20)
│   ├── Question Types Toggle (Identify/Build/Ear Training)
│   ├── Direction Picker (Ascending/Descending/Both)
│   ├── Key Difficulty (Natural/Sharps/Flats/All)
│   └── Start Button
│
├── ActiveView
│   ├── Progress Bar
│   ├── Timer Display
│   ├── Question Text
│   ├── Visual Display (shows two notes for identify, one note for build)
│   │
│   ├── Answer Input
│   │   ├── For "Build": PianoKeyboard (tap to select note)
│   │   └── For "Identify": IntervalPicker (grid of interval buttons)
│   │
│   ├── Feedback Animation (correct/incorrect)
│   └── Next Button
│
└── ResultsView
    ├── Score Display (X/Y correct)
    ├── Accuracy Percentage
    ├── Time Taken
    ├── Rating Change (+/- points)
    ├── Rank Up Celebration (if applicable)
    ├── Review Missed Questions Button
    └── Play Again / Back to Menu
```

### Key UI Components

#### IntervalPicker (for Identify questions)
```swift
struct IntervalPicker: View {
    let intervals: [IntervalType]
    let onSelect: (IntervalType) -> Void
    @State private var selectedInterval: IntervalType?
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 12) {
            ForEach(intervals) { interval in
                Button(action: { onSelect(interval) }) {
                    VStack {
                        Text(interval.shortName)
                            .font(.headline)
                        Text(interval.name)
                            .font(.caption)
                    }
                    .padding()
                    .background(/* styling */)
                    .cornerRadius(8)
                }
            }
        }
    }
}
```

#### Interval Visual Display
```swift
struct IntervalDisplayView: View {
    let rootNote: Note
    let targetNote: Note?  // nil for "build" questions until answered
    let showTarget: Bool
    
    var body: some View {
        // Mini piano keyboard highlighting the two notes
        // Or staff notation showing the interval
    }
}
```

---

## Audio Integration

### AudioManager Extensions

```swift
extension AudioManager {
    /// Play an interval (two notes in sequence or simultaneously)
    func playInterval(_ interval: Interval, style: IntervalPlayStyle = .melodic) {
        guard isEnabled else { return }
        
        switch style {
        case .melodic:
            // Play notes sequentially
            playNote(UInt8(interval.rootNote.midiNumber), velocity: 80)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.playNote(UInt8(interval.targetNote.midiNumber), velocity: 80)
            }
        case .harmonic:
            // Play notes simultaneously
            let notes = [interval.rootNote, interval.targetNote]
            playChord(notes, duration: 1.0)
        }
    }
    
    enum IntervalPlayStyle {
        case melodic   // Notes played one after another
        case harmonic  // Notes played together
    }
}
```

---

## Integration Points

### 1. App Entry Point (JazzHarmonyQuizApp.swift)
```swift
@StateObject private var intervalGame = IntervalGame()
// ...
.environmentObject(intervalGame)
```

### 2. ContentView Navigation
```swift
case "intervalDrill":
    IntervalDrillView()
```

### 3. DrillOptionsSection Button
```swift
Button(action: { navigationPath.append("intervalDrill") }) {
    DrillOptionCard(
        icon: "arrow.up.arrow.down",
        title: "Interval Drill",
        subtitle: "Master musical intervals",
        color: .green
    )
}
```

### 4. PlayerStats Integration
- Add interval-specific stats tracking
- Track most-missed intervals
- Track improvement over time

---

## Difficulty Progression

### Beginner
- Perfect intervals (unison, 4th, 5th, octave)
- Major/minor 2nds and 3rds
- Ascending only
- Natural keys only (C, F, G)
- "Build Interval" questions only

### Intermediate
- All intervals up to octave
- Both ascending and descending
- All keys
- Both "Build" and "Identify" questions
- Introduce tritone

### Advanced
- Compound intervals (9th, 10th, 11th, 13th)
- Ear training questions
- All directions and keys
- Speed challenges
- Mixed question types

---

## File Checklist

### Models (to create)
- [ ] `IntervalModel.swift` - Interval, IntervalType, IntervalQuestion, etc.
- [ ] `IntervalDatabase.swift` - All interval definitions
- [ ] `IntervalGame.swift` - Quiz game logic

### Views (to create)
- [ ] `IntervalDrillView.swift` - Main view with setup/active/results states
- [ ] `IntervalLeaderboardView.swift` - Interval-specific leaderboard

### Modifications (to existing files)
- [ ] `JazzHarmonyQuizApp.swift` - Add IntervalGame environment object
- [ ] `ContentView.swift` - Add navigation destination and menu option
- [ ] `AudioManager.swift` - Add interval playback methods
- [ ] `PlayerStats.swift` - Add interval stats tracking
- [ ] `project.pbxproj` - Add new files to Xcode project

---

## Testing Checklist

- [ ] All intervals sound correct when played
- [ ] Answer checking works for all question types
- [ ] Pitch-class comparison allows any octave for answers
- [ ] Timer works correctly
- [ ] Rating changes calculate properly
- [ ] Leaderboard saves and loads
- [ ] Navigation works from home screen
- [ ] All difficulty levels generate appropriate questions
- [ ] Ear training plays intervals before showing answer options
- [ ] UI responsive on all iPhone sizes

---

## Future Enhancements

1. **Interval Song References**
   - Associate famous melodies with intervals
   - "Here Comes the Bride" = Perfect 4th
   - "Star Wars" = Perfect 5th

2. **Interval Chains**
   - Given a starting note, build a series of intervals
   - Tests sequential interval recognition

3. **Inversion Training**
   - Identify inverted intervals (m3 inverts to M6)

4. **Custom Interval Sets**
   - Let users focus on specific intervals they're learning

---

## Estimated Effort

| Task | Estimate |
|------|----------|
| IntervalModel.swift | 1 hour |
| IntervalDatabase.swift | 30 min |
| IntervalGame.swift | 2 hours |
| IntervalDrillView.swift | 3 hours |
| IntervalLeaderboardView.swift | 1 hour |
| AudioManager extensions | 30 min |
| Integration & testing | 2 hours |
| **Total** | **~10 hours** |

---

## Notes

- Reuse existing patterns from ChordDrillView and ScaleDrillView
- Follow established naming conventions
- Use same rating calculation as other modes for consistency
- Consider color theme: green (to differentiate from blue chords, teal scales, purple cadences)
