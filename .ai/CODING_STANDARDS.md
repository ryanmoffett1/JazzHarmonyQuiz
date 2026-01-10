# Coding Standards - Jazz Harmony Quiz

**Purpose:** Swift and SwiftUI conventions for this project
**For:** AI agents and human developers
**Updated:** 2026-01-10

---

## Swift Language Standards

### Naming Conventions

#### Types (Structs, Classes, Enums, Protocols)
**Use PascalCase**

```swift
// ✅ Good
struct ChordType { }
class QuizGame { }
enum Note { }
protocol Playable { }

// ❌ Bad
struct chordType { }
class quiz_game { }
enum NOTE { }
```

#### Variables, Functions, Parameters
**Use camelCase**

```swift
// ✅ Good
var currentQuestion: QuizQuestion?
func startQuiz(difficulty: ChordType.Difficulty) { }
let questionCount = 10

// ❌ Bad
var CurrentQuestion: QuizQuestion?
func start_quiz(Difficulty: ChordType.Difficulty) { }
let question_count = 10
```

#### Constants
**Use camelCase (not SCREAMING_CASE)**

```swift
// ✅ Good
let maxQuestionCount = 20
let defaultDifficulty: ChordType.Difficulty = .beginner

// ❌ Bad
let MAX_QUESTION_COUNT = 20
let DEFAULT_DIFFICULTY: ChordType.Difficulty = .beginner
```

#### Enum Cases
**Use camelCase starting with lowercase**

```swift
// ✅ Good
enum QuestionType {
    case singleTone(ChordTone)
    case allTones
    case chordSpelling
}

// ❌ Bad
enum QuestionType {
    case SingleTone(ChordTone)
    case AllTones
    case ChordSpelling
}
```

#### Boolean Properties
**Use `is`, `has`, `should` prefixes for clarity**

```swift
// ✅ Good
var isCorrect: Bool
var hasAnswered: Bool
var shouldShowHint: Bool

// ❌ Bad
var correct: Bool
var answered: Bool
var showHint: Bool
```

---

### Type Annotations

#### When to Include

**Always annotate:**
- Property declarations in types
- Function return types
- Published properties
- State properties

```swift
// ✅ Good
struct QuizQuestion {
    let id: UUID
    let chord: Chord
    let questionType: QuestionType
}

class QuizGame: ObservableObject {
    @Published var currentQuestion: QuizQuestion?
    @Published var userAnswer: Set<Note> = []
}

func correctAnswer() -> Set<Note> {
    return chord.tones()
}
```

**Can omit when obvious:**
- Simple literal assignments
- Closure parameters when type is inferred

```swift
// ✅ Good (inference is clear)
let count = 10  // Obviously Int
let name = "C major"  // Obviously String
let notes = Set<Note>()  // Explicit type in initializer

// ✅ Also good (explicit)
let count: Int = 10
let name: String = "C major"
```

---

### Optional Handling

#### Use Optional Binding (if let, guard let)

```swift
// ✅ Good - Safe unwrapping
if let question = game.currentQuestion {
    print(question.chord.displayName())
}

guard let question = game.currentQuestion else {
    return
}
// Use question safely here

// ❌ Bad - Force unwrapping
let question = game.currentQuestion!  // Will crash if nil
```

#### When Force Unwrapping is Acceptable

**Only when:**
1. Logic guarantees non-nil
2. Failure is a programmer error (should crash)
3. Documented with comment

```swift
// ✅ Acceptable with justification
// currentQuestion is always set before this view appears
let question = game.currentQuestion!

// ✅ Better - make it non-optional
struct ActiveQuizView: View {
    let question: QuizQuestion  // Non-optional, required in init
}
```

#### Use Optional Chaining

```swift
// ✅ Good
let displayName = game.currentQuestion?.chord.displayName()

// ❌ Bad - Nested if-lets
if let question = game.currentQuestion {
    if let chord = question.chord {
        let name = chord.displayName()
    }
}
```

#### Use Nil Coalescing

```swift
// ✅ Good
let accuracy = result.accuracy ?? 0.0
let userName = user.name ?? "Anonymous"

// ❌ Bad
let accuracy = result.accuracy != nil ? result.accuracy! : 0.0
```

---

### Collections

#### Prefer Specific Collection Types

```swift
// ✅ Good - Use Set for unique items
var selectedNotes: Set<Note> = []
var answeredQuestions: [UUID: Set<Note>] = [:]

// ❌ Bad - Array allows duplicates
var selectedNotes: [Note] = []  // Can accidentally add same note twice
```

#### Use isEmpty Instead of count == 0

```swift
// ✅ Good
if selectedNotes.isEmpty {
    // Handle empty case
}

// ❌ Bad
if selectedNotes.count == 0 {
    // Less efficient, less idiomatic
}
```

#### Use for-in for Iteration

```swift
// ✅ Good
for question in allQuestions {
    print(question.chord.displayName())
}

// ❌ Bad - Imperative style
for i in 0..<allQuestions.count {
    print(allQuestions[i].chord.displayName())
}
```

---

### Functions and Methods

#### Keep Functions Focused

**Good function:**
- Does one thing
- < 30 lines (guideline, not rule)
- Clear name describing purpose

```swift
// ✅ Good - Focused, clear purpose
func checkAnswer() -> Bool {
    guard let question = currentQuestion else { return false }
    let correctPitchClasses = Set(question.correctAnswer().map { $0.pitchClass })
    let userPitchClasses = Set(userAnswer.map { $0.pitchClass })
    return correctPitchClasses == userPitchClasses
}

// ❌ Bad - Does too much
func handleQuizFlow() {
    // Checks answer
    // Updates score
    // Advances question
    // Saves to database
    // Shows UI feedback
    // ... 100 lines of code
}
```

#### Use Descriptive Parameter Names

```swift
// ✅ Good - Reads like English
func startQuiz(difficulty: ChordType.Difficulty, questionCount: Int, questionTypes: Set<QuestionType>)

// Usage reads naturally:
startQuiz(difficulty: .intermediate, questionCount: 10, questionTypes: [.allTones])

// ❌ Bad - Unclear parameters
func startQuiz(_ d: Int, _ c: Int, _ t: [Int])

// Usage is cryptic:
startQuiz(1, 10, [0, 2])
```

#### Use Guard for Early Returns

```swift
// ✅ Good - Guard for preconditions
func nextQuestion() -> Bool {
    guard currentQuestionIndex < allQuestions.count - 1 else {
        return false  // No more questions
    }

    currentQuestionIndex += 1
    currentQuestion = allQuestions[currentQuestionIndex]
    return true
}

// ❌ Bad - Nested if
func nextQuestion() -> Bool {
    if currentQuestionIndex < allQuestions.count - 1 {
        currentQuestionIndex += 1
        currentQuestion = allQuestions[currentQuestionIndex]
        return true
    } else {
        return false
    }
}
```

---

### Enums

#### Use Associated Values for Context

```swift
// ✅ Good - Associated value provides context
enum QuestionType: Codable, Hashable {
    case singleTone(ChordTone)
    case allTones
    case chordSpelling
}

// Usage:
let question = QuizQuestion(
    chord: chord,
    questionType: .singleTone(.flatNine)
)
```

#### Conform to Protocols When Appropriate

**Common protocols:**
- `Codable` for persistence
- `Hashable` for Set/Dictionary usage
- `CaseIterable` for looping all cases
- `Identifiable` for SwiftUI lists

```swift
// ✅ Good
enum Note: Int, CaseIterable, Codable, Hashable {
    case C = 60
    case Cs = 61
    // ...
}

// Enables:
for note in Note.allCases {
    print(note)
}
```

---

### Error Handling

#### Use Optionals for Expected Failures

```swift
// ✅ Good - Optional for expected case
func chordType(withSymbol symbol: String) -> ChordType? {
    return allChordTypes.first { $0.symbol == symbol }
}

// Usage:
if let chordType = database.chordType(withSymbol: "maj7") {
    // Found
} else {
    // Not found - expected possibility
}
```

#### Use throws for Exceptional Failures

```swift
// ✅ Good - Throw for unexpected errors
enum PersistenceError: Error {
    case encodingFailed
    case saveFailed
}

func saveLeaderboard() throws {
    let encoder = JSONEncoder()
    guard let data = try? encoder.encode(leaderboard) else {
        throw PersistenceError.encodingFailed
    }
    UserDefaults.standard.set(data, forKey: "JazzHarmonyLeaderboard")
}
```

---

### Comments and Documentation

#### Use MARK for Organization

```swift
// ✅ Good - Organized with MARK comments
class QuizGame: ObservableObject {

    // MARK: - Published Properties

    @Published var currentQuestion: QuizQuestion?
    @Published var userAnswer: Set<Note> = []

    // MARK: - Quiz Management

    func startQuiz(difficulty: ChordType.Difficulty, questionCount: Int) {
        // ...
    }

    func nextQuestion() -> Bool {
        // ...
    }

    // MARK: - Scoring

    func checkAnswer() -> Bool {
        // ...
    }

    // MARK: - Persistence

    func saveLeaderboard() {
        // ...
    }
}
```

**MARK Hierarchy:**
```swift
// MARK: - Section (with dash for separator in Xcode)
// MARK: Subsection (without dash)
```

#### Comment Complex Logic, Not Obvious Code

```swift
// ✅ Good - Explains WHY
// Use pitch-class comparison to allow answers in any octave
let correctPitchClasses = Set(correctNotes.map { $0.pitchClass })
let userPitchClasses = Set(userAnswer.map { $0.pitchClass })

// ❌ Bad - Explains WHAT (already obvious)
// Set the current question to the next question
currentQuestion = allQuestions[currentQuestionIndex]
```

#### Use Documentation Comments for Public APIs

```swift
/// Generates a random quiz question for the specified difficulty level.
///
/// - Parameters:
///   - difficulty: The difficulty level for chord selection
///   - questionTypes: Set of allowed question types
/// - Returns: A randomly generated quiz question
func generateQuestion(difficulty: ChordType.Difficulty,
                     questionTypes: Set<QuestionType>) -> QuizQuestion {
    // Implementation
}
```

---

## SwiftUI Conventions

### Property Wrappers

#### Choose the Right Property Wrapper

```swift
// ✅ @State for view-local state
struct MyView: View {
    @State private var isShowingAlert = false
    @State private var selectedNotes: Set<Note> = []
}

// ✅ @Binding for two-way parent-child communication
struct ChildView: View {
    @Binding var selectedNotes: Set<Note>
}

// ✅ @StateObject for owning an ObservableObject
struct MainMenuView: View {
    @StateObject var game = QuizGame()
}

// ✅ @EnvironmentObject for shared app state
struct ActiveQuizView: View {
    @EnvironmentObject var game: QuizGame
}

// ✅ @ObservedObject when parent owns the object
struct DetailView: View {
    @ObservedObject var game: QuizGame  // Passed from parent
}
```

#### Mark @State as private

```swift
// ✅ Good - State is private to view
@State private var selectedDifficulty: ChordType.Difficulty = .beginner

// ❌ Bad - State should not be public
@State var selectedDifficulty: ChordType.Difficulty = .beginner
```

---

### View Structure

#### Keep Views Small and Focused

**Target:** < 200 lines per view
**Split when:**
- View has multiple responsibilities
- Reusable component identified
- Code becomes hard to understand

```swift
// ✅ Good - Focused views
struct ResultsView: View {
    var body: some View {
        VStack {
            ResultsSummary(result: result)
            PerformanceBar(percentage: result.accuracy)
            NavigationLink(destination: ReviewView(result: result)) {
                Text("Review Answers")
            }
        }
    }
}

struct ResultsSummary: View {
    let result: QuizResult

    var body: some View {
        // Summary UI
    }
}

// ❌ Bad - Monolithic view
struct ResultsView: View {
    var body: some View {
        VStack {
            // 300 lines of UI code for everything
        }
    }
}
```

#### Use Computed Properties for Complex Views

```swift
// ✅ Good - Extracted to computed property
struct QuizSetupView: View {
    @Binding var selectedDifficulty: ChordType.Difficulty

    var body: some View {
        VStack {
            difficultyPicker
            questionCountSlider
            questionTypeToggles
            startButton
        }
    }

    private var difficultyPicker: some View {
        Picker("Difficulty", selection: $selectedDifficulty) {
            ForEach(ChordType.Difficulty.allCases, id: \.self) { difficulty in
                Text(difficulty.rawValue)
            }
        }
    }

    // ... other computed properties
}
```

#### Use ViewBuilder for Conditional Views

```swift
// ✅ Good - Clean conditional rendering
@ViewBuilder
var questionText: some View {
    if let question = game.currentQuestion {
        switch question.questionType {
        case .singleTone(let tone):
            Text("What is the \(tone.rawValue) of \(question.chord.displayName())?")
        case .allTones:
            Text("Play all tones of \(question.chord.displayName())")
        case .chordSpelling:
            Text("Spell \(question.chord.displayName())")
        }
    } else {
        Text("Loading...")
    }
}
```

---

### Modifiers

#### Order Modifiers Logically

**Recommended order:**
1. Layout (frame, padding, offset)
2. Visual (background, foreground, border)
3. Interaction (onTapGesture, gesture)
4. Accessibility (accessibilityLabel)

```swift
// ✅ Good - Logical order
Text("Submit Answer")
    .font(.headline)
    .padding()
    .frame(maxWidth: .infinity)
    .background(Color.blue)
    .foregroundColor(.white)
    .cornerRadius(10)
    .onTapGesture {
        submitAnswer()
    }

// ❌ Bad - Random order
Text("Submit Answer")
    .onTapGesture {
        submitAnswer()
    }
    .background(Color.blue)
    .padding()
    .foregroundColor(.white)
    .frame(maxWidth: .infinity)
    .font(.headline)
    .cornerRadius(10)
```

#### Extract Repeated Modifiers

```swift
// ✅ Good - Custom ViewModifier
struct CardStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 5)
    }
}

extension View {
    func cardStyle() -> some View {
        modifier(CardStyle())
    }
}

// Usage:
VStack {
    Text("Question 1")
}
.cardStyle()

// ❌ Bad - Repeated modifiers everywhere
VStack {
    Text("Question 1")
}
.padding()
.background(Color.white)
.cornerRadius(10)
.shadow(radius: 5)
```

---

### Layout

#### Use Spacing Parameters

```swift
// ✅ Good - Explicit spacing
VStack(spacing: 20) {
    Text("Title")
    Text("Subtitle")
}

HStack(spacing: 10) {
    Image(systemName: "star")
    Text("Rating")
}

// ❌ Bad - Manual padding
VStack {
    Text("Title")
        .padding(.bottom, 20)
    Text("Subtitle")
}
```

#### Use GeometryReader for Responsive Layouts

```swift
// ✅ Good - Responsive piano keyboard
GeometryReader { geometry in
    let whiteKeyWidth = geometry.size.width / CGFloat(whiteKeyCount)

    HStack(spacing: 0) {
        ForEach(whiteKeys) { note in
            WhiteKeyView(note: note)
                .frame(width: whiteKeyWidth)
        }
    }
}

// ❌ Bad - Fixed sizes (won't scale)
HStack(spacing: 0) {
    ForEach(whiteKeys) { note in
        WhiteKeyView(note: note)
            .frame(width: 50)  // Fixed width
    }
}
```

---

### State Management

#### Update @Published on Main Thread

```swift
// ✅ Good - Ensure main thread for UI updates
@MainActor
class QuizGame: ObservableObject {
    @Published var currentQuestion: QuizQuestion?

    func startQuiz() {
        // All updates automatically on main thread
        currentQuestion = allQuestions.first
    }
}

// ❌ Bad - Can cause crashes if called from background
class QuizGame: ObservableObject {
    @Published var currentQuestion: QuizQuestion?

    func startQuiz() {
        DispatchQueue.global().async {
            // CRASH: Publishing changes from background thread
            self.currentQuestion = self.allQuestions.first
        }
    }
}
```

#### Don't Mutate @Published in Computed Properties

```swift
// ✅ Good - Read-only computed property
var isQuizComplete: Bool {
    currentQuestionIndex >= allQuestions.count
}

// ❌ Bad - Side effects in computed property
var isQuizComplete: Bool {
    let complete = currentQuestionIndex >= allQuestions.count
    if complete {
        finishQuiz()  // Side effect! Don't do this.
    }
    return complete
}
```

---

### Performance

#### Use LazyVStack for Long Lists

```swift
// ✅ Good - Lazy loading for performance
ScrollView {
    LazyVStack {
        ForEach(leaderboard) { result in
            LeaderboardRowView(result: result)
        }
    }
}

// ⚠️ OK for small lists (< 20 items)
ScrollView {
    VStack {
        ForEach(leaderboard) { result in
            LeaderboardRowView(result: result)
        }
    }
}
```

#### Avoid Expensive Computations in Body

```swift
// ✅ Good - Cached in computed property
var sortedResults: [QuizResult] {
    leaderboard.sorted { $0.accuracy > $1.accuracy }
}

var body: some View {
    ForEach(sortedResults) { result in
        // ...
    }
}

// ❌ Bad - Sorts every time body is called
var body: some View {
    ForEach(leaderboard.sorted { $0.accuracy > $1.accuracy }) { result in
        // ...
    }
}
```

---

## Project-Specific Conventions

### Music Theory Accuracy

#### Always Verify Chord Definitions

```swift
// ✅ Good - Verified against jazz theory
ChordType(
    symbol: "7",
    tones: [.root, .majThird, .fifth, .minSeventh],  // Dominant 7
    difficulty: .beginner
)

// ❌ Wrong - Major 7th in dominant chord
ChordType(
    symbol: "7",
    tones: [.root, .majThird, .fifth, .majSeventh],  // This is maj7!
    difficulty: .beginner
)
```

#### Use Enharmonic Equivalence Correctly

```swift
// ✅ Good - Respects key tonality
func name(preferSharps: Bool) -> String {
    switch self {
    case .Cs: return preferSharps ? "C#" : "Db"
    case .Ds: return preferSharps ? "D#" : "Eb"
    // ...
    }
}

// ❌ Bad - Always shows sharps
func name() -> String {
    switch self {
    case .Cs: return "C#"  // What about Db key signature?
    }
}
```

---

### Leaderboard Management

#### Always Keep Top 10 Only

```swift
// ✅ Good - Sorted and limited
leaderboard.sort { $0.accuracy > $1.accuracy || ($0.accuracy == $1.accuracy && $0.totalTime < $1.totalTime) }
leaderboard = Array(leaderboard.prefix(10))

// ❌ Bad - Unbounded growth
leaderboard.append(newResult)
leaderboard.sort { $0.accuracy > $1.accuracy }
// Could grow to thousands of results!
```

---

### UserDefaults Keys

#### Use String Constants

```swift
// ✅ Good - Centralized constant
extension UserDefaults {
    private static let leaderboardKey = "JazzHarmonyLeaderboard"

    func saveLeaderboard(_ results: [QuizResult]) {
        // Use leaderboardKey
    }
}

// ❌ Bad - String literals scattered
UserDefaults.standard.set(data, forKey: "JazzHarmonyLeaderboard")
// Later...
UserDefaults.standard.data(forKey: "JazzHarmonyLederboard")  // Typo!
```

---

## Code Review Checklist

Before committing, verify:

### Functionality
- [ ] Code compiles without warnings
- [ ] All new code is tested manually
- [ ] No force unwraps without justification
- [ ] Edge cases handled (empty arrays, nil values, etc.)

### Style
- [ ] Naming follows conventions (PascalCase, camelCase)
- [ ] MARK comments added for new sections
- [ ] No commented-out code (delete it)
- [ ] No debug print statements in final code

### SwiftUI
- [ ] @State marked as private
- [ ] @Published updates on main thread (@MainActor)
- [ ] Large views split into smaller components
- [ ] Modifiers in logical order

### Project-Specific
- [ ] Music theory accuracy verified (if applicable)
- [ ] No external dependencies added
- [ ] iOS 17.0+ compatibility maintained
- [ ] UserDefaults keys use constants

### Performance
- [ ] No expensive operations in view body
- [ ] Lazy loading used for long lists
- [ ] No memory leaks (strong reference cycles)

---

## Anti-Patterns to Avoid

### ❌ Massive View Files

```swift
// ❌ Bad - 800 line view
struct ChordDrillView: View {
    // Everything in one file
}

// ✅ Good - Split into focused views
struct ChordDrillView: View { }
struct QuizSetupView: View { }
struct ActiveQuizView: View { }
struct QuizResultsView: View { }
```

### ❌ Stringly-Typed Code

```swift
// ❌ Bad
func startQuiz(difficulty: String) {
    if difficulty == "beginner" { }  // Typo-prone
}

// ✅ Good
func startQuiz(difficulty: ChordType.Difficulty) {
    if difficulty == .beginner { }  // Type-safe
}
```

### ❌ Magic Numbers

```swift
// ❌ Bad
if timeInterval < 5.0 {  // What does 5.0 mean?
    showQuickAnswerBonus()
}

// ✅ Good
let quickAnswerThreshold: TimeInterval = 5.0
if timeInterval < quickAnswerThreshold {
    showQuickAnswerBonus()
}
```

### ❌ God Objects

```swift
// ❌ Bad - One class does everything
class QuizGame {
    func startQuiz() { }
    func checkAnswer() { }
    func playAudio() { }
    func syncToServer() { }
    func handlePayment() { }
    // ... 50 more methods
}

// ✅ Good - Focused responsibilities
class QuizGame { /* Quiz logic */ }
class AudioManager { /* Audio playback */ }
class NetworkManager { /* Server sync */ }
class PaymentManager { /* Payments */ }
```

---

## Resources

### Official Documentation
- [Swift Language Guide](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)

### Style Guides
- [Ray Wenderlich Swift Style Guide](https://github.com/raywenderlich/swift-style-guide)
- [Google Swift Style Guide](https://google.github.io/swift/)

### Music Theory
- "The Jazz Theory Book" by Mark Levine
- "The Jazz Piano Book" by Mark Levine

---

## Questions?

When in doubt:
1. Check existing code for patterns
2. Follow conventions in this document
3. Prefer clarity over cleverness
4. Ask the user if uncertain

**Remember:** Good code is read far more than it's written. Optimize for readability.
