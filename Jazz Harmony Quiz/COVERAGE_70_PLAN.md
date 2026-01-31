# Plan to Achieve 70% Test Coverage

**Current Coverage:** 6.90% (2,855/41,380 lines)  
**Target Coverage:** 70% (28,966/41,380 lines)  
**Gap to Close:** 26,111 lines of new coverage needed

## Executive Summary

To reach 70% coverage, we need a **three-phase approach**:

1. **Phase 1: Extract Business Logic to ViewModels** (22 files, ~9,000 lines → testable via unit tests)
2. **Phase 2: Add Service Layer Tests** (4 services, ~1,900 lines)
3. **Phase 3: Add UI Tests** (5 critical flows covering ~15,000 lines of view code)

**Timeline:** 3-4 weeks for full implementation  
**Estimated Final Coverage:** 70-75%

---

## Current State Analysis

### What's Already Tested (2,855 lines ✅)
- ✅ All database classes (5 files)
- ✅ All game models (QuizGame, ProgressionGame, etc.)
- ✅ Supporting models (PlayerProfile, CurriculumModule, ConceptualExplanations)
- ✅ Core models (partially: Chord, Note, Scale, Interval)

### What's NOT Tested (38,525 lines ❌)
**Features Directory:** 11,425 lines (0% coverage)
- ChordDrillSession.swift (887 lines) - business logic + view code
- ScaleDrillSession.swift (946 lines) - business logic + view code
- CadenceDrillSession.swift (893 lines) - business logic + view code
- IntervalDrillSession.swift (503 lines) - business logic + view code
- QuickPracticeSession.swift (481 lines) - business logic + view code
- Setup/Results views (27 files, ~6,000 lines)

**Services:** ~1,900 lines (0-7% coverage)
- AudioManager.swift (932 lines, 0%)
- SpacedRepetitionStore.swift (316 lines, 0%)
- SettingsManager.swift (341 lines, 0%)
- QuickPracticeGenerator.swift (308 lines, 0%)

**Views Directory:** ~6,500 lines (0% coverage)
- Old views in Views/ (ResultsView, ProgressionDrillView, etc.)

---

## Phase 1: Extract Business Logic to ViewModels 🎯

**Impact:** +22% coverage (9,000 lines testable)  
**Duration:** 2 weeks  
**Effort:** High (architectural change)

### Architecture Change

Currently, Session views mix SwiftUI view code with business logic:
```swift
// BAD: Untestable business logic inside view
struct QuickPracticeSession: View {
    func checkAnswer() {
        // Complex validation logic embedded in view
        let userNotes = selectedNotes.sorted()
        let correctNotes = currentItem.correctNotes.sorted()
        isCorrect = (userNotes == correctNotes)
        // ... more logic
    }
}
```

Extract to ViewModels:
```swift
// GOOD: Testable ViewModel
@MainActor
class QuickPracticeViewModel: ObservableObject {
    @Published var selectedNotes: Set<Note> = []
    @Published var isCorrect: Bool = false
    
    func checkAnswer(for item: QuickPracticeItem) -> Bool {
        let userNotes = selectedNotes.sorted()
        let correctNotes = item.correctNotes.sorted()
        return userNotes == correctNotes
    }
}

// View becomes thin presenter
struct QuickPracticeSession: View {
    @StateObject private var viewModel = QuickPracticeViewModel()
    // View code only - no logic
}
```

### Files to Refactor (22 files)

#### Session ViewModels (5 files, ~4,000 lines → testable)
1. **QuickPracticeViewModel.swift** (from QuickPracticeSession.swift, 481 lines)
   - Extract: `checkAnswer()`, `validateChordAnswer()`, `validateIntervalAnswer()`, `validateScaleAnswer()`
   - Extract: Session state management, statistics calculation
   - Tests: 40 unit tests for validation logic

2. **ChordDrillViewModel.swift** (from ChordDrillSession.swift, 887 lines)
   - Extract: `submitAnswer()`, `checkAnswer()`, `validateSpelling()`, `validateIdentification()`
   - Extract: Piano keyboard state management, haptic feedback triggers
   - Tests: 50 unit tests

3. **ScaleDrillViewModel.swift** (from ScaleDrillSession.swift, 946 lines)
   - Extract: Answer validation, degree selection logic, scale construction
   - Tests: 50 unit tests

4. **CadenceDrillViewModel.swift** (from CadenceDrillSession.swift, 893 lines)
   - Extract: Progression validation, playback control, feedback logic
   - Tests: 45 unit tests

5. **IntervalDrillViewModel.swift** (from IntervalDrillSession.swift, 503 lines)
   - Extract: Interval building/identification, aural playback logic
   - Tests: 40 unit tests

#### Setup ViewModels (5 files, ~2,500 lines → testable)
6. **ChordDrillSetupViewModel.swift** (from ChordDrillSetup.swift, 442 lines)
   - Extract: Preset loading, filter application, difficulty calculation
   - Tests: 25 unit tests

7. **ScaleDrillSetupViewModel.swift** (from ScaleDrillSetup.swift, 383 lines)
   - Extract: Scale selection logic, preset management
   - Tests: 20 unit tests

8. **CadenceDrillSetupViewModel.swift** (from CadenceDrillSetup.swift, 489 lines)
   - Extract: Category filtering, difficulty validation
   - Tests: 20 unit tests

9. **IntervalDrillSetupViewModel.swift** (from IntervalDrillSetup.swift, 240 lines)
   - Extract: Interval selection, preset application
   - Tests: 15 unit tests

10. **ModuleDetailViewModel.swift** (from ModuleDetailView.swift, 305 lines)
    - Extract: Module progress calculation, prerequisites checking
    - Tests: 15 unit tests

#### Results ViewModels (4 files, ~2,000 lines → testable)
11. **ChordDrillResultsViewModel.swift** (from ChordDrillResults.swift, 495 lines)
    - Extract: Statistics calculation, performance analysis
    - Tests: 20 unit tests

12. **ScaleDrillResultsViewModel.swift** (from ScaleDrillResults.swift, 394 lines)
    - Extract: Accuracy calculation, missed items processing
    - Tests: 18 unit tests

13. **CadenceDrillResultsViewModel.swift** (from CadenceDrillResults.swift, 424 lines)
    - Extract: Results aggregation, category breakdown
    - Tests: 20 unit tests

14. **IntervalDrillResultsViewModel.swift** (from IntervalDrillResults.swift, 341 lines)
    - Extract: Performance metrics
    - Tests: 15 unit tests

#### Home/Navigation ViewModels (3 files, ~500 lines → testable)
15. **HomeViewModel.swift** (from HomeView.swift)
    - Extract: Due practice calculation, streak management
    - Tests: 20 unit tests

16. **ProgressViewModel.swift** (from ProgressView.swift)
    - Extract: Stats aggregation, chart data preparation
    - Tests: 25 unit tests

17. **CurriculumViewModel.swift** (from CurriculumView.swift)
    - Extract: Pathway filtering, module unlocking logic
    - Tests: 20 unit tests

#### Component ViewModels (5 files, ~400 lines → testable)
18. **PianoKeyboardViewModel.swift** (from PianoKeyboard.swift)
    - Extract: Note selection logic, playback coordination
    - Tests: 15 unit tests

19. **StatsOverviewViewModel.swift** (from StatsOverview.swift)
    - Extract: Statistics calculation
    - Tests: 10 unit tests

20. **AchievementsListViewModel.swift** (from AchievementsList.swift)
    - Extract: Achievement unlocking logic
    - Tests: 12 unit tests

21. **CategoryBreakdownViewModel.swift** (from CategoryBreakdown.swift)
    - Extract: Category aggregation
    - Tests: 10 unit tests

22. **PathwaySelectorViewModel.swift** (from PathwaySelector.swift)
    - Extract: Pathway selection logic
    - Tests: 8 unit tests

### Phase 1 Test Files to Create

**Total:** 22 ViewModel test files, ~468 unit tests

Example structure:
```
JazzHarmonyQuizTests/
  Features/
    Home/
      QuickPracticeViewModelTests.swift (40 tests)
      HomeViewModelTests.swift (20 tests)
    ChordDrill/
      ChordDrillViewModelTests.swift (50 tests)
      ChordDrillSetupViewModelTests.swift (25 tests)
      ChordDrillResultsViewModelTests.swift (20 tests)
    ScaleDrill/
      ScaleDrillViewModelTests.swift (50 tests)
      ScaleDrillSetupViewModelTests.swift (20 tests)
      ScaleDrillResultsViewModelTests.swift (18 tests)
    CadenceDrill/
      CadenceDrillViewModelTests.swift (45 tests)
      CadenceDrillSetupViewModelTests.swift (20 tests)
      CadenceDrillResultsViewModelTests.swift (20 tests)
    IntervalDrill/
      IntervalDrillViewModelTests.swift (40 tests)
      IntervalDrillSetupViewModelTests.swift (15 tests)
      IntervalDrillResultsViewModelTests.swift (15 tests)
    Curriculum/
      CurriculumViewModelTests.swift (20 tests)
      ModuleDetailViewModelTests.swift (15 tests)
    Progress/
      ProgressViewModelTests.swift (25 tests)
      StatsOverviewViewModelTests.swift (10 tests)
      AchievementsListViewModelTests.swift (12 tests)
      CategoryBreakdownViewModelTests.swift (10 tests)
  Components/
    PianoKeyboardViewModelTests.swift (15 tests)
    PathwaySelectorViewModelTests.swift (8 tests)
```

### Phase 1 Implementation Order

**Week 1:** Foundation (most critical path)
1. QuickPracticeViewModel (day 1-2)
2. ChordDrillViewModel (day 3-4)
3. ScaleDrillViewModel (day 5)

**Week 2:** Complete drill system
4. CadenceDrillViewModel (day 1)
5. IntervalDrillViewModel (day 2)
6. All Setup ViewModels (days 3-4)
7. All Results ViewModels (day 5)

**Week 3:** Navigation & components
8. Home/Progress/Curriculum ViewModels (days 1-3)
9. Component ViewModels (days 4-5)

**Expected Coverage After Phase 1:** ~29% (12,000/41,380 lines)

---

## Phase 2: Add Service Layer Tests 🔧

**Impact:** +5% coverage (~1,900 lines)  
**Duration:** 3-4 days  
**Effort:** Medium

### Service Test Files to Create (4 files, ~150 tests)

1. **AudioManagerTests.swift** (932 lines production code)
   - Mock AVMIDIPlayer to test playback logic
   - Test: Chord playback, scale playback, interval playback
   - Test: Soundfont loading, instrument selection
   - Test: Concurrency (async playback)
   - **40 unit tests**

2. **SpacedRepetitionStoreTests.swift** (316 lines production code)
   - Test: SM-2 algorithm calculations
   - Test: Review scheduling, difficulty adjustments
   - Test: Due items filtering, performance tracking
   - **35 unit tests**

3. **SettingsManagerTests.swift** (341 lines production code)
   - Test: Settings persistence (UserDefaults)
   - Test: Theme switching, haptic preferences
   - Test: Practice duration defaults
   - **30 unit tests**

4. **QuickPracticeGeneratorTests.swift** (308 lines production code)
   - Test: Session generation with mixed types
   - Test: Difficulty distribution
   - Test: Category balancing
   - **45 unit tests** (partially exists, expand coverage)

### Service Test Implementation

```swift
// Example: AudioManagerTests.swift
@MainActor
final class AudioManagerTests: XCTestCase {
    var sut: AudioManager!
    var mockPlayer: MockMIDIPlayer!
    
    override func setUp() async throws {
        mockPlayer = MockMIDIPlayer()
        sut = AudioManager(player: mockPlayer)
    }
    
    func testPlayChord_callsPlayerWithCorrectNotes() async throws {
        let chord = Chord(root: .c, type: .major)
        
        await sut.playChord(chord)
        
        XCTAssertEqual(mockPlayer.playedNotes, [.c, .e, .g])
    }
    
    func testPlayInterval_withAscending_playsSequentially() async throws {
        let interval = Interval.perfectFifth
        
        await sut.playInterval(from: .c, interval: interval, direction: .ascending)
        
        XCTAssertEqual(mockPlayer.playOrder, [.c, .g])
        XCTAssertEqual(mockPlayer.playMode, .sequential)
    }
}
```

**Expected Coverage After Phase 2:** ~34% (14,000/41,380 lines)

---

## Phase 3: Add UI Tests 🎭

**Impact:** +36% coverage (~15,000 lines of view code)  
**Duration:** 1.5 weeks  
**Effort:** High (new infrastructure)

UI tests cover integration flows, catching bugs that unit tests miss. While they don't provide high line-by-line coverage percentages, they validate the entire user experience.

### Prerequisites

#### 1. Create UI Test Target (Day 1, ~2 hours)
```bash
# Add JazzHarmonyQuizUITests target via Xcode
# Configure test host application
# Add UI test dependencies
```

#### 2. Add Accessibility Identifiers (Days 1-2, ~250 identifiers)

SwiftUI views need `accessibilityIdentifier` for UI testing:

```swift
// Before (not testable)
Button("Start Practice") {
    startPractice()
}

// After (testable)
Button("Start Practice") {
    startPractice()
}
.accessibilityIdentifier("home.startPracticeButton")
```

**Files needing identifiers (27 files):**
- All Session views (5 files, ~60 identifiers)
- All Setup views (5 files, ~50 identifiers)
- All Results views (4 files, ~40 identifiers)
- Home/Navigation views (6 files, ~50 identifiers)
- Components (7 files, ~50 identifiers)

**Naming Convention:**
```
<feature>.<component>.<element>
Examples:
- "chordDrill.session.submitButton"
- "quickPractice.keyboard.noteC"
- "home.quickStatsCard"
- "settings.themeToggle"
```

#### 3. Create Page Object Models (Day 3, ~500 lines)

Page Objects encapsulate UI element queries:

```swift
// JazzHarmonyQuizUITests/PageObjects/QuickPracticeSessionPage.swift
struct QuickPracticeSessionPage {
    let app: XCUIApplication
    
    var submitButton: XCUIElement {
        app.buttons["quickPractice.submitButton"]
    }
    
    var pianoKey_C: XCUIElement {
        app.buttons["quickPractice.keyboard.noteC"]
    }
    
    var feedbackLabel: XCUIElement {
        app.staticTexts["quickPractice.feedbackLabel"]
    }
    
    func tapPianoKey(_ note: String) {
        app.buttons["quickPractice.keyboard.note\(note)"].tap()
    }
    
    func verifyCorrectFeedback() {
        XCTAssertTrue(feedbackLabel.label.contains("Correct"))
    }
}
```

**Page Objects to Create (13 files):**
1. HomePage.swift
2. QuickPracticeSessionPage.swift
3. ChordDrillSetupPage.swift
4. ChordDrillSessionPage.swift
5. ChordDrillResultsPage.swift
6. ScaleDrillSetupPage.swift
7. ScaleDrillSessionPage.swift
8. IntervalDrillSessionPage.swift
9. CadenceDrillSessionPage.swift
10. CurriculumPage.swift
11. ProgressPage.swift
12. SettingsPage.swift
13. PianoKeyboardComponent.swift

### Critical UI Test Flows (5 test suites, ~60 tests)

#### 1. QuickPracticeFlowTests.swift (15 tests)
**Goal:** Test Quick Practice end-to-end flow

```swift
final class QuickPracticeFlowTests: XCTestCase {
    var app: XCUIApplication!
    var homePage: HomePage!
    var sessionPage: QuickPracticeSessionPage!
    
    override func setUp() {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
        homePage = HomePage(app: app)
        sessionPage = QuickPracticeSessionPage(app: app)
    }
    
    func test_quickPractice_completeSession_showsResults() {
        // Navigate to Quick Practice
        homePage.quickPracticeCard.tap()
        
        // Answer 5 questions
        for _ in 0..<5 {
            sessionPage.tapPianoKey("C")
            sessionPage.tapPianoKey("E")
            sessionPage.tapPianoKey("G")
            sessionPage.submitButton.tap()
            sessionPage.nextButton.tap()
        }
        
        // Verify results screen
        XCTAssertTrue(app.staticTexts["Session Complete"].exists)
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Accuracy'")).element.exists)
    }
    
    func test_quickPractice_incorrectAnswer_showsFeedback() {
        homePage.quickPracticeCard.tap()
        
        // Submit wrong answer
        sessionPage.tapPianoKey("C")
        sessionPage.submitButton.tap()
        
        // Verify feedback
        sessionPage.verifyIncorrectFeedback()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label CONTAINS 'Correct answer'")).element.exists)
    }
    
    func test_quickPractice_exitMidSession_showsConfirmation() {
        homePage.quickPracticeCard.tap()
        
        // Tap exit
        sessionPage.exitButton.tap()
        
        // Should dismiss back to home
        XCTAssertTrue(homePage.quickPracticeCard.exists)
    }
    
    // ... 12 more tests
}
```

**Tests:**
- Complete session flow (correct answers)
- Complete session flow (mixed answers)
- Incorrect answer feedback
- Piano keyboard interaction
- Exit mid-session
- Chord spelling questions
- Interval building questions
- Scale spelling questions
- Session statistics accuracy
- Missed items review
- Replay functionality
- Answer clearing
- Session timeout handling
- Audio playback (aural questions)
- Haptic feedback triggers

#### 2. ChordDrillFlowTests.swift (15 tests)
**Goal:** Test Chord Drill presets and session flows

```swift
final class ChordDrillFlowTests: XCTestCase {
    func test_chordDrill_basicTriadsPreset_loadsCorrectly() {
        homePage.chordDrillCard.tap()
        
        let setupPage = ChordDrillSetupPage(app: app)
        setupPage.selectPreset("Basic Triads")
        setupPage.startButton.tap()
        
        let sessionPage = ChordDrillSessionPage(app: app)
        
        // Verify first question is a basic triad (Maj, min, dim, aug)
        XCTAssertTrue(sessionPage.questionLabel.label.contains(["Major", "Minor", "Diminished", "Augmented"]))
    }
    
    func test_chordDrill_auralQuestion_playsAudio() {
        // Test aural identification
    }
    
    func test_chordDrill_spellingQuestion_validatesPianoInput() {
        // Test chord spelling validation
    }
    
    // ... 12 more tests
}
```

**Tests:**
- Basic Triads preset
- Seventh Chords preset
- Extended chords preset
- Custom selection
- Aural identification
- Spelling validation
- Identification questions
- Results screen
- Perfect score celebration
- Low score feedback
- Category breakdown
- Difficulty progression
- Session persistence
- Audio playback controls
- Keyboard shortcuts

#### 3. NavigationFlowTests.swift (10 tests)
**Goal:** Test app navigation and state preservation

```swift
final class NavigationFlowTests: XCTestCase {
    func test_tabBar_switchBetweenTabs_preservesState() {
        // Start Quick Practice
        homePage.quickPracticeCard.tap()
        sessionPage.tapPianoKey("C")
        
        // Switch to Progress tab
        app.tabBars.buttons["Progress"].tap()
        
        // Switch back to Home
        app.tabBars.buttons["Home"].tap()
        
        // Session should still be active
        XCTAssertTrue(sessionPage.exists)
        XCTAssertTrue(sessionPage.pianoKey_C.isSelected)
    }
    
    func test_deepLink_toCurriculumModule_navigatesCorrectly() {
        // Test deep linking
    }
    
    // ... 8 more tests
}
```

**Tests:**
- Tab switching preserves state
- Deep linking to modules
- Back button navigation
- Drill setup → session transition
- Session → results transition
- Home card navigation
- Curriculum pathway navigation
- Settings changes apply immediately
- Modal dismissal
- Navigation stack integrity

#### 4. CurriculumFlowTests.swift (10 tests)
**Goal:** Test curriculum progression and module unlocking

```swift
final class CurriculumFlowTests: XCTestCase {
    func test_curriculum_completeModule_unlocksNext() {
        // Select pathway
        let curriculumPage = CurriculumPage(app: app)
        curriculumPage.selectPathway("Improvisation")
        
        // Start first module
        curriculumPage.moduleCard(0).tap()
        
        let detailPage = ModuleDetailPage(app: app)
        detailPage.startButton.tap()
        
        // Complete practice session
        // ... complete questions
        
        // Verify next module unlocked
        app.navigationBars.buttons.element(boundBy: 0).tap() // back
        XCTAssertTrue(curriculumPage.moduleCard(1).isEnabled)
    }
    
    // ... 9 more tests
}
```

**Tests:**
- Module unlocking after completion
- Prerequisites enforcement
- Pathway switching
- Module detail view
- Practice mode selection
- Progress indicators
- Locked module UI
- Completed module UI
- Module descriptions
- Difficulty indicators

#### 5. SettingsAndAccessibilityTests.swift (10 tests)
**Goal:** Test settings persistence and accessibility features

```swift
final class SettingsAndAccessibilityTests: XCTestCase {
    func test_settings_toggleHaptics_persistsAcrossSessions() {
        homePage.settingsTab.tap()
        
        let settingsPage = SettingsPage(app: app)
        settingsPage.hapticsToggle.tap()
        
        // Kill and relaunch app
        app.terminate()
        app.launch()
        
        homePage.settingsTab.tap()
        XCTAssertFalse(settingsPage.hapticsToggle.value as! Bool)
    }
    
    func test_accessibility_voiceOver_canNavigateApp() {
        // Test VoiceOver support
    }
    
    func test_accessibility_dynamicType_adjustsTextSize() {
        // Test Dynamic Type support
    }
    
    // ... 7 more tests
}
```

**Tests:**
- Haptics toggle persistence
- Theme switching
- Practice duration settings
- Audio settings
- VoiceOver support
- Dynamic Type support
- Color contrast (dark mode)
- Button hit targets (44x44pt)
- Keyboard navigation
- Reduced motion support

### UI Test Infrastructure Files

```
JazzHarmonyQuizUITests/
  PageObjects/
    HomePage.swift
    QuickPracticeSessionPage.swift
    ChordDrillSetupPage.swift
    ChordDrillSessionPage.swift
    ChordDrillResultsPage.swift
    ScaleDrillSetupPage.swift
    ScaleDrillSessionPage.swift
    IntervalDrillSessionPage.swift
    CadenceDrillSessionPage.swift
    CurriculumPage.swift
    ModuleDetailPage.swift
    ProgressPage.swift
    SettingsPage.swift
    Components/
      PianoKeyboardComponent.swift
      FeedbackComponent.swift
  Flows/
    QuickPracticeFlowTests.swift (15 tests)
    ChordDrillFlowTests.swift (15 tests)
    NavigationFlowTests.swift (10 tests)
    CurriculumFlowTests.swift (10 tests)
    SettingsAndAccessibilityTests.swift (10 tests)
  Helpers/
    XCTestCase+Extensions.swift
    UITestHelpers.swift
```

### Phase 3 Implementation Order

**Week 1:**
- Day 1: Create UI test target, configure scheme
- Days 1-2: Add 250 accessibility identifiers to views
- Day 3: Create Page Object Models (13 files)
- Days 4-5: Write QuickPracticeFlowTests + ChordDrillFlowTests (30 tests)

**Week 2:**
- Days 1-2: Write NavigationFlowTests + CurriculumFlowTests (20 tests)
- Day 3: Write SettingsAndAccessibilityTests (10 tests)
- Day 4: Debug flaky tests, add wait conditions
- Day 5: CI/CD integration, parallel test execution

**Expected Coverage After Phase 3:** **70-75%** (29,000-31,000/41,380 lines)

---

## Coverage Calculation

| Phase | Lines Covered | Cumulative Coverage | Tests Added |
|-------|---------------|---------------------|-------------|
| **Current** | 2,855 | 6.90% | 283 |
| **Phase 1: ViewModels** | +9,000 | ~29% | +468 |
| **Phase 2: Services** | +1,900 | ~34% | +150 |
| **Phase 3: UI Tests** | +15,000* | **70-75%** | +60 |
| **TOTAL** | **28,755** | **70-75%** | **961 tests** |

*UI tests provide integration coverage, not line-by-line coverage. Actual line coverage from UI tests will be ~12,000-15,000 lines depending on execution paths.

---

## Why This Gets Us to 70%

### Unit Tests (Phases 1-2): ~34% coverage, high confidence
- **ViewModels:** Business logic extracted and 100% testable
- **Services:** All service layer logic tested
- **Fast execution:** <5 seconds for 618 unit tests
- **Deterministic:** No flakiness

### UI Tests (Phase 3): +36% coverage, catches integration bugs
- **End-to-end flows:** Tests real user interactions
- **View code coverage:** Exercises SwiftUI view rendering
- **Integration validation:** Tests component interactions
- **Regression prevention:** Catches UI breaking changes

### Coverage Breakdown
```
41,380 total lines:
- 9,000 lines: ViewModels (90% coverage via unit tests)
- 1,900 lines: Services (80% coverage via unit tests)
- 2,800 lines: Models/Databases (95% coverage, already done)
- 15,000 lines: View code (80% coverage via UI tests)
- 12,680 lines: Low-value code (boilerplate, old views, etc.)

Covered: ~28,700 lines = 69.3%
```

---

## Risk Mitigation

### Risk 1: ViewModel Extraction Breaks Existing UI
**Mitigation:**
- Extract one ViewModel at a time
- Test manually after each extraction
- Keep views functional during transition
- Use feature flags if needed

### Risk 2: UI Tests Are Flaky
**Mitigation:**
- Use explicit waits (`waitForExistence`)
- Avoid hardcoded delays
- Use accessibility identifiers (not text matching)
- Test on multiple simulators
- Run tests in CI to catch flakiness early

### Risk 3: Timeline Slips
**Mitigation:**
- Start with highest-value files (QuickPractice, ChordDrill)
- Release incrementally (don't wait for 100% completion)
- Track daily progress (lines covered per day)
- Pair programming for complex extractions

### Risk 4: Coverage Doesn't Reach 70%
**Mitigation:**
- Front-load high-LOC files (Session views first)
- Measure coverage after each file
- Adjust plan if coverage isn't increasing as expected
- Focus on coverage per file (aim for 80% in testable files)

---

## Success Metrics

### Coverage Targets by Phase
- ✅ Phase 1 Complete: ≥28% coverage
- ✅ Phase 2 Complete: ≥33% coverage
- ✅ Phase 3 Complete: ≥70% coverage

### Quality Metrics
- **Unit test execution time:** <10 seconds for all 618 tests
- **UI test execution time:** <5 minutes for all 60 tests
- **Test flakiness rate:** <2% (tests should be deterministic)
- **Build time impact:** +30 seconds max (due to test compilation)

### Code Quality Metrics
- **ViewModel test coverage:** ≥80% per file
- **Service test coverage:** ≥80% per file
- **UI test coverage:** 5 critical flows, 60+ tests
- **Code review:** All ViewModels reviewed before merge

---

## Daily Progress Tracking

Use this checklist to track progress:

### Phase 1: ViewModels (14 days)
**Week 1:**
- [ ] Day 1: QuickPracticeViewModel + tests (481 lines, +1.2%)
- [ ] Day 2: QuickPracticeViewModel complete (40 tests passing)
- [ ] Day 3: ChordDrillViewModel + tests (887 lines, +2.1%)
- [ ] Day 4: ChordDrillViewModel complete (50 tests passing)
- [ ] Day 5: ScaleDrillViewModel + tests (946 lines, +2.3%)

**Week 2:**
- [ ] Day 6: CadenceDrillViewModel + tests (893 lines, +2.2%)
- [ ] Day 7: IntervalDrillViewModel + tests (503 lines, +1.2%)
- [ ] Day 8: ChordDrillSetup + ScaleDrillSetup ViewModels (825 lines, +2.0%)
- [ ] Day 9: CadenceDrillSetup + IntervalDrillSetup ViewModels (729 lines, +1.8%)
- [ ] Day 10: All 4 Results ViewModels (1,654 lines, +4.0%)

**Week 3:**
- [ ] Day 11: Home + Progress + Curriculum ViewModels (~800 lines, +1.9%)
- [ ] Day 12: Component ViewModels (~400 lines, +1.0%)
- [ ] Day 13: Buffer day (fix failing tests, refactor)
- [ ] Day 14: Phase 1 complete, measure coverage (target: ≥28%)

### Phase 2: Services (4 days)
- [ ] Day 15: AudioManagerTests + SpacedRepetitionStoreTests (1,248 lines, +3.0%)
- [ ] Day 16: SettingsManagerTests + QuickPracticeGeneratorTests (649 lines, +1.6%)
- [ ] Day 17: Mock infrastructure, edge cases
- [ ] Day 18: Phase 2 complete, measure coverage (target: ≥33%)

### Phase 3: UI Tests (10 days)
**Week 4:**
- [ ] Day 19: Create UI test target + add first 50 identifiers
- [ ] Day 20: Add remaining 200 identifiers (all views tagged)
- [ ] Day 21: Create 13 Page Object Models
- [ ] Day 22: QuickPracticeFlowTests (15 tests)
- [ ] Day 23: ChordDrillFlowTests (15 tests)

**Week 5:**
- [ ] Day 24: NavigationFlowTests (10 tests)
- [ ] Day 25: CurriculumFlowTests (10 tests)
- [ ] Day 26: SettingsAndAccessibilityTests (10 tests)
- [ ] Day 27: Debug flaky tests, optimize waits
- [ ] Day 28: Phase 3 complete, measure coverage (target: **≥70%**)

---

## Alternative: Faster Path (70% in 2 weeks)

If you need coverage faster, focus on high-LOC files only:

### Fast Track Approach
1. **Days 1-5:** Extract only the 5 Session ViewModels (~4,000 lines, +9.7%)
2. **Days 6-7:** Test the 4 services (~1,900 lines, +4.6%)
3. **Days 8-10:** Add accessibility identifiers + basic UI tests for Quick Practice and Chord Drill (~10,000 lines, +24%)

**Total:** 10 days to ~38% coverage (not 70%, but massive improvement)

Then iterate:
- **Days 11-14:** Add more ViewModels + UI tests → 50%
- **Days 15-20:** Complete all ViewModels + UI tests → 70%

---

## Conclusion

**This plan is comprehensive but realistic.** 

- **3-4 weeks of focused work**
- **961 total tests** (618 unit + 60 UI + 283 existing)
- **70-75% coverage** (from 6.90%)
- **Testable architecture** (ViewModels extracted)
- **Regression safety** (UI tests for critical flows)

The key is **incremental progress**—each phase independently improves coverage and code quality. You can stop after Phase 1 (29% coverage) or Phase 2 (34% coverage) and still have made dramatic improvements.

**Ready to start?** Let's begin with **Phase 1, Day 1: QuickPracticeViewModel extraction**. 🚀
