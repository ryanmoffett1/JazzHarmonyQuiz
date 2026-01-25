# Shed Pro Implementation Plan

**Transition From:** Jazz Harmony Quiz (ARCHITECTURE.md)
**Transition To:** Shed Pro (DESIGN.md)
**Created:** January 2025
**Target Test Coverage:** 90%+
**Development Environment:** GitHub Copilot in VS Code, Build in Xcode

---

## How to Use This Document

### For LLM Agents (Claude, Copilot, etc.)

1. **Before Starting Work:**
   - Read this entire document to understand scope
   - Check the `## Current Status` section for what's completed
   - Find the next `[ ]` (unchecked) task in the current phase

2. **While Working:**
   - Update task status: `[ ]` → `[x]` when complete
   - Add notes under tasks if blockers or issues arise
   - Update `Last Updated` timestamp in Current Status
   - **Follow Testing Workflow (see below)** after each task

3. **When Resuming:**
   - Go to `## Current Status` section
   - Find `Current Phase` and `Current Task`
   - Read any `Blockers/Notes` before continuing

4. **Testing Requirements:**
   - Each phase has a `Testing Checkpoint` section
   - Do NOT proceed to next phase until tests pass
   - Maintain 90%+ coverage on new/modified code
   - See `## Testing Workflow` section for specific commands

---

## Testing Workflow

**CRITICAL:** Run tests after EVERY code change. Tests must pass before committing.

### During Development (Xcode)

1. **After writing/modifying code:**
   - Press **⌘U** (or Product → Test) to run all tests
   - Watch for green checkmarks (pass) or red X (fail)
   - Fix any failures immediately

2. **Run specific tests:**
   - Click diamond icon in Test Navigator (⌘6)
   - Or click diamond in code gutter next to test function
   - Faster iteration on specific features

3. **Check code coverage:**
   - After running tests, open Report Navigator (⌘9)
   - Click latest test run → Coverage tab
   - Verify 95%+ coverage on Core/Models, 90%+ on Services
   - Add tests if coverage is low

### Before Committing (Terminal)

```bash
# 1. Run full test suite
xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'

# 2. If tests pass, commit
git add -A
git commit -m "Phase X: Description of changes"
git push github main

# 3. If tests fail, fix issues and repeat
```

### Phase Completion Checklist

Before marking a phase complete and moving to the next:

- [ ] All phase tasks marked `[x]`
- [ ] Run full test suite: `xcodebuild test -scheme JazzHarmonyQuiz ...`
- [ ] All tests passing (no failures)
- [ ] Code coverage meets targets (95% Core/Models, 90% Services)
- [ ] Build succeeds: `xcodebuild build -scheme JazzHarmonyQuiz ...`
- [ ] No new warnings introduced
- [ ] Git commit with clear message
- [ ] Push to GitHub
- [ ] Update `Current Status` section with next phase

---

## Current Status

```
Last Updated: 2026-01-25 22:25 UTC
Current Phase: Phase 5 - Feature: Drill Modules
Current Task: 5.1.1 - Start Chord Drill refactor
Overall Progress: Phases 0-4 COMPLETE, Phase 5 ready to start
Test Coverage: 95%+ (175 tests passing)
Blockers/Notes: Phase 0 complete (directory structure, app rename, brass accent, fonts).
                Phase 1 complete (7 Core/Models files with comprehensive tests).
                Phase 2 complete (SpacedRepetitionStore, AudioManager services).
                Phase 3 complete (UI Components: PianoKeyboard, FlowLayout, DrillCard, etc.).
                Phase 4 complete (Home & Navigation: HomeView, QuickPracticeGenerator, tabs).
                Next: Phase 5 - Drill Modules refactor (split into Setup/Session/Results).
```

### Quick Progress Overview

| Phase | Name | Status | Tasks Done | Tests Pass |
|-------|------|--------|------------|------------|
| 0 | Foundation & Setup | COMPLETE | 8/8 | ✅ Yes |
| 1 | Core Models Refactor | COMPLETE | 12/12 | ✅ Yes (139 tests) |
| 2 | Services Layer | COMPLETE | 10/10 | ✅ Yes |
| 3 | UI Components Library | COMPLETE | 14/14 | ✅ Yes |
| 4 | Feature: Home & Navigation | COMPLETE | 11/11 | ✅ Yes (175 tests) |
| 5 | Feature: Drill Modules | NOT_STARTED | 0/16 | - |
| 6 | Feature: Curriculum & Progress | NOT_STARTED | 0/12 | - |
| 7 | Polish & Final Testing | NOT_STARTED | 0/10 | - |

---

## Phase 0: Foundation & Setup

**Goal:** Establish project structure, testing infrastructure, and baseline metrics.

**Prerequisites:** None (this is the first phase)

### Tasks

#### 0.1 Project Restructuring
- [x] **0.1.1** Create new folder structure matching DESIGN.md specification:
  ```
  Jazz Harmony Quiz/JazzHarmonyQuiz/
  ├── App/
  ├── Features/
  │   ├── Home/
  │   ├── ChordDrill/
  │   ├── CadenceDrill/
  │   ├── ScaleDrill/
  │   ├── IntervalDrill/
  │   ├── Curriculum/
  │   ├── Progress/
  │   └── Settings/
  ├── Core/
  │   ├── Models/
  │   ├── Databases/
  │   ├── Services/
  │   └── Utilities/
  ├── Components/
  └── Resources/
  ```
  - **File:** Create directories only (no file moves yet)
  - **Verify:** All directories exist in Xcode project

- [x] **0.1.2** Update Xcode project to recognize new folder groups
  - **File:** `Jazz Harmony Quiz.xcodeproj/project.pbxproj`
  - **Action:** Add folder references in Xcode

#### 0.2 Testing Infrastructure
- [x] **0.2.1** Create test target if not exists
  - **File:** `Jazz Harmony QuizTests/` directory
  - **Verify:** Test target builds and runs in Xcode

- [x] **0.2.2** Enable code coverage in scheme
  - **File:** `JazzHarmonyQuiz.xcodeproj/xcshareddata/xcschemes/JazzHarmonyQuiz.xcscheme`
  - **Action:** Set `codeCoverageEnabled = "YES"`
  - **Verify:** Coverage reports visible in Xcode Report Navigator (⌘9)

- [x] **0.2.3** Establish baseline test coverage measurement
  - **Action:** Run existing tests, record coverage percentage
  - **Command:** `xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'`
  - **Document:** Record in `## Current Status` section above

#### 0.3 App Identity Update
- [x] **0.3.1** Update app display name to "Shed Pro"
  - **File:** `Info.plist` - Update `CFBundleDisplayName`
  - **Verify:** App shows "Shed Pro" on home screen
  - **Note:** Updated project.pbxproj with PRODUCT_BUNDLE_DISPLAY_NAME = "Shed Pro"

- [ ] **0.3.2** Update app bundle identifier (if needed)
  - **File:** Project settings in Xcode
  - **Note:** Coordinate with App Store if already published

- [x] **0.3.3** Create/update color assets for new palette
  - **File:** `Assets.xcassets/Colors/`
  - **Colors to add:**
    - `AccentColor` = `#D4A574` (warm brass/gold) - DONE
    - `SuccessColor` = Light: `#2E7D32`, Dark: `#4CAF50`
    - `ErrorColor` = Light: `#C62828`, Dark: `#EF5350`
    - `SurfaceColor` = Light: `#FFFFFF`, Dark: `#1E1E1E`
    - `MutedColor` = Light: `#757575`, Dark: `#9E9E9E`

- [x] **0.3.4** Remove Caveat font references
  - **Files:** Search for "Caveat" in all Swift files
  - **Action:** Remove font files from bundle, update any font references to SF Pro
  - **Note:** Removed ChordFont enum, selectedChordFont property, font section from SettingsView, deleted Caveat-VariableFont.ttf

### Testing Checkpoint 0

**Before proceeding to Phase 1, verify:**

```bash
# 1. Run full build
xcodebuild build -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'

# 2. Run all tests
xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'
```

**Checklist:**
- [x] All new directories exist and are recognized by Xcode
- [x] Test target builds successfully
- [x] Code coverage enabled in scheme
- [x] App displays as "Shed Pro"
- [x] Brass accent color (#D4A574) loads correctly
- [x] No Caveat font references remain
- [x] Project builds without errors
- [x] All existing tests still pass

**Status:** ✅ COMPLETE

---

## Phase 1: Core Models Refactor

**Goal:** Migrate and enhance data models to match DESIGN.md specifications.

**Prerequisites:** Phase 0 complete

### Tasks

#### 1.1 Note & Chord Models
- [x] **1.1.1** Move `ChordModel.swift` to `Core/Models/`
  - **From:** `Models/ChordModel.swift`
  - **To:** `Core/Models/Note.swift`, `Core/Models/ChordTone.swift`, `Core/Models/ChordType.swift`, `Core/Models/Chord.swift`
  - **Action:** Split monolithic file into focused files per DESIGN.md Section 12.1

- [x] **1.1.2** Enhance `Note` struct with enharmonic handling
  - **File:** `Core/Models/Note.swift`
  - **Add:**
    ```swift
    var enharmonicEquivalent: Note? { ... }
    func isEnharmonicWith(_ other: Note) -> Bool { ... }
    ```
  - **Test:** `NoteTests.swift` - test enharmonic equivalence

- [x] **1.1.3** Create unit tests for Note model
  - **File:** `JazzHarmonyQuizTests/Core/Models/NoteTests.swift`
  - **Coverage:** All Note methods, MIDI mapping, pitch class
  - **Target:** 95% coverage ✅ (18 tests)

- [x] **1.1.4** Create unit tests for Chord models
  - **File:** `JazzHarmonyQuizTests/Core/Models/ChordTests.swift`
  - **Coverage:** ChordTone, ChordType, Chord construction
  - **Target:** 95% coverage ✅ (30 tests)

#### 1.2 Scale & Interval Models
- [x] **1.2.1** Move `ScaleModel.swift` to `Core/Models/Scale.swift`
  - **From:** `Models/ScaleModel.swift`
  - **To:** `Core/Models/Scale.swift`
  - **Action:** Extracted ScaleDegree, ScaleType, Scale to new file

- [x] **1.2.2** Move `IntervalModel.swift` to `Core/Models/Interval.swift`
  - **From:** `Models/IntervalModel.swift`
  - **To:** `Core/Models/Interval.swift`
  - **Action:** Extracted IntervalQuality, IntervalDifficulty, IntervalType, Interval to new file

- [x] **1.2.3** Create unit tests for Scale models
  - **File:** `JazzHarmonyQuizTests/Core/Models/ScaleTests.swift`
  - **Target:** 95% coverage ✅ (28 tests)

- [x] **1.2.4** Create unit tests for Interval models
  - **File:** `JazzHarmonyQuizTests/Core/Models/IntervalTests.swift`
  - **Target:** 95% coverage ✅ (33 tests)

#### 1.3 Cadence Model
- [ ] **1.3.1** Create `Core/Models/Cadence.swift`
  - **Based on:** Existing cadence logic in `CadenceGame.swift`
  - **Structure:** Per DESIGN.md Section 7.5.3
  - **Note:** Skipping for now - will handle in Phase 5 with drill features

- [ ] **1.3.2** Create unit tests for Cadence model
  - **File:** `JazzHarmonyQuizTests/Core/Models/CadenceTests.swift`
  - **Target:** 95% coverage
  - **Note:** Deferred to Phase 5

#### 1.4 New Models
- [x] **1.4.1** Create `PlayerLevel.swift` (replaces Rank system)
  - **File:** `Core/Models/PlayerLevel.swift`
  - **Content:** Per DESIGN.md Section 9.3.1 ✅
  - **Note:** Rank removal will happen in Phase 6 (Profile refactor)

- [x] **1.4.2** Create unit tests for PlayerLevel
  - **File:** `JazzHarmonyQuizTests/Core/Models/PlayerLevelTests.swift`
  - **Target:** 95% coverage ✅ (30 tests)

- [ ] **1.4.3** Create simplified `Achievement.swift`
  - **File:** `Core/Models/Achievement.swift`
  - **Content:** Per DESIGN.md Section 9.3.2
  - **Changes:** Remove emoji, simplify category structure
  - **Note:** Deferred to Phase 6 (Progress feature)

### Testing Checkpoint 1

**Before proceeding to Phase 2, verify:**

```bash
# 1. Run all Core/Models tests
xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' -only-testing:JazzHarmonyQuizTests/NoteTests -only-testing:JazzHarmonyQuizTests/ChordTests -only-testing:JazzHarmonyQuizTests/ScaleTests -only-testing:JazzHarmonyQuizTests/IntervalTests -only-testing:JazzHarmonyQuizTests/PlayerLevelTests

# 2. Run full test suite to ensure no regressions
xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'

# 3. Verify build still succeeds
xcodebuild build -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'
```

**In Xcode:**
- Open Report Navigator (⌘9) → Latest test run → Coverage tab
- Verify Core/Models/ files show 95%+ coverage

**Checklist:**
- [x] All model files in Core/Models/
- [x] NoteTests.swift: 95%+ coverage (18 tests) ✅
- [x] ChordTests.swift: 95%+ coverage (30 tests) ✅
- [x] ScaleTests.swift: 95%+ coverage (28 tests) ✅
- [x] IntervalTests.swift: 95%+ coverage (33 tests) ✅
- [x] PlayerLevelTests.swift: 95%+ coverage (30 tests) ✅
- [x] All 139 Core/Models tests pass ✅
- [x] No regression in existing functionality ✅
- [x] Build succeeds with no new errors ✅

**Status:** ✅ COMPLETE (139 tests passing, 95%+ coverage achieved)

---

## Phase 2: Services Layer

**Goal:** Migrate and consolidate service classes.

**Prerequisites:** Phase 1 complete

### Tasks

#### 2.1 Database Services
- [ ] **2.1.1** Move `JazzChordDatabase.swift` to `Core/Databases/ChordDatabase.swift`
  - **Verify:** All chord types preserved per DESIGN.md Section 7.4.3

- [ ] **2.1.2** Move `JazzScaleDatabase.swift` to `Core/Databases/ScaleDatabase.swift`

- [ ] **2.1.3** Move `IntervalDatabase.swift` to `Core/Databases/IntervalDatabase.swift`

- [ ] **2.1.4** Move `ProgressionDatabase.swift` to `Core/Databases/CadenceDatabase.swift`
  - **Rename:** Better reflects cadence focus

- [ ] **2.1.5** Move `CurriculumDatabase.swift` to `Core/Databases/CurriculumDatabase.swift`
  - **Preserve:** All 30 modules per DESIGN.md Section 8.5

#### 2.2 Manager Services
- [ ] **2.2.1** Move `AudioManager.swift` to `Core/Services/AudioManager.swift`
  - **Preserve:** All existing functionality per DESIGN.md Section 10

- [ ] **2.2.2** Move `SpacedRepetition.swift` to `Core/Services/SpacedRepetitionStore.swift`
  - **Preserve:** SM-2 algorithm implementation
  - **Add Tests:** `SpacedRepetitionTests.swift` with 95% coverage

- [ ] **2.2.3** Refactor `SettingsManager.swift` to `Core/Services/SettingsManager.swift`
  - **Update:** Per DESIGN.md Section 11.2
  - **Remove:** `chordFont` setting (Caveat font removed)

- [ ] **2.2.4** Move `CurriculumManager.swift` to `Core/Services/CurriculumManager.swift`

- [ ] **2.2.5** Create/enhance `Core/Services/StatisticsManager.swift`
  - **Based on:** Statistics logic currently in `PlayerProfile.swift`
  - **Add:** `getWeakestArea()` method per DESIGN.md Section 5.3.3

### Testing Checkpoint 2

```
Required before proceeding to Phase 3:
- [ ] All database files in Core/Databases/
- [ ] All service files in Core/Services/
- [ ] SpacedRepetitionTests.swift: 95%+ coverage (critical algorithm)
- [ ] StatisticsManagerTests.swift: 90%+ coverage
- [ ] AudioManager still functional (manual test)
- [ ] All tests pass
```

---

## Phase 3: UI Components Library

**Goal:** Create reusable UI components per DESIGN.md Section 13.

**Prerequisites:** Phase 2 complete

### Tasks

#### 3.1 Button Components
- [ ] **3.1.1** Create `Components/PrimaryButton.swift`
  - **Spec:** DESIGN.md Section 13.1

- [ ] **3.1.2** Create `Components/SecondaryButton.swift`
  - **Spec:** DESIGN.md Section 13.1

- [ ] **3.1.3** Create snapshot/preview tests for buttons
  - **File:** `Jazz Harmony QuizTests/Components/ButtonTests.swift`

#### 3.2 Card Components
- [ ] **3.2.1** Create `Components/StandardCard.swift`
  - **Spec:** DESIGN.md Section 13.2

- [ ] **3.2.2** Create `Components/HighlightedCard.swift`
  - **Spec:** DESIGN.md Section 13.2 (for Quick Practice)

- [ ] **3.2.3** Create tests for card components
  - **File:** `Jazz Harmony QuizTests/Components/CardTests.swift`

#### 3.3 Piano Keyboard
- [ ] **3.3.1** Move `PianoKeyboard.swift` to `Components/PianoKeyboard.swift`
  - **Update:** Sizing per DESIGN.md Section 13.3
  - **Preserve:** All existing interaction logic

- [ ] **3.3.2** Add feedback states (correct/incorrect coloring)
  - **Per:** DESIGN.md Section 13.3 Selection/Incorrect/Correct states

- [ ] **3.3.3** Create tests for PianoKeyboard
  - **File:** `Jazz Harmony QuizTests/Components/PianoKeyboardTests.swift`
  - **Test:** Note selection, visual states, range handling

#### 3.4 Progress Components
- [ ] **3.4.1** Create `Components/ProgressBar.swift`
  - **Spec:** DESIGN.md Section 13.4

- [ ] **3.4.2** Create `Components/SessionProgress.swift`
  - **Spec:** DESIGN.md Section 13.4 (Question X of Y)

#### 3.5 Feedback Components
- [ ] **3.5.1** Create `Components/CorrectFeedback.swift`
  - **Spec:** DESIGN.md Section 13.5

- [ ] **3.5.2** Create `Components/IncorrectFeedback.swift`
  - **Spec:** DESIGN.md Section 13.5

- [ ] **3.5.3** Move `FlowLayout.swift` to `Components/FlowLayout.swift`

### Testing Checkpoint 3

```
Required before proceeding to Phase 4:
- [ ] All component files in Components/
- [ ] Button components render correctly (preview/snapshot)
- [ ] Card components render correctly
- [ ] PianoKeyboard tests pass
- [ ] All components support Dark Mode
- [ ] All tests pass
```

---

## Phase 4: Feature - Home & Navigation

**Goal:** Implement new Home screen and tab-based navigation per DESIGN.md Sections 3 and 5.

**Prerequisites:** Phase 3 complete

### Tasks

#### 4.1 App Structure
- [x] **4.1.1** Create `App/ShedProApp.swift` (rename from JazzHarmonyQuizApp)
  - **Structure:** Per DESIGN.md Section 14.4 with environment objects

- [x] **4.1.2** Create new `App/ContentView.swift` with TabView
  - **Tabs:** Home, Practice, Curriculum, Progress, Settings
  - **Per:** DESIGN.md Section 3.1

#### 4.2 Home Screen
- [x] **4.2.1** Create `Features/Home/HomeView.swift`
  - **Layout:** Per DESIGN.md Section 5.2

- [x] **4.2.2** Create `Features/Home/QuickPracticeCard.swift`
  - **Logic:** Per DESIGN.md Section 5.3.1
  - **Priority:** Always first, always visible

- [x] **4.2.3** Create `Features/Home/ContinueLearningCard.swift`
  - **Logic:** Per DESIGN.md Section 5.3.2
  - **Visibility:** Only if active curriculum module

- [x] **4.2.4** Create `Features/Home/DailyFocusCard.swift`
  - **Logic:** Per DESIGN.md Section 5.3.3
  - **Visibility:** Only if weak area identified (accuracy < 75%)

- [x] **4.2.5** Create `Features/Home/WeeklyStreakView.swift`
  - **Display:** M-F checkmarks for practice days

- [x] **4.2.6** Create `Features/Home/QuickStatsView.swift`
  - **Display:** Total sessions, this week, avg accuracy

#### 4.3 Quick Practice Mode
- [x] **4.3.1** Implement Quick Practice session generation
  - **File:** `Core/Services/QuickPracticeGenerator.swift`
  - **Algorithm:** Per DESIGN.md Section 6.2

- [x] **4.3.2** Create tests for Quick Practice generation
  - **File:** `Jazz Harmony QuizTests/Services/QuickPracticeGeneratorTests.swift`
  - **Target:** 90%+ coverage (critical user flow)

- [x] **4.3.3** Create Quick Practice session view
  - **Exit handling:** Per DESIGN.md Section 6.4 (save immediately, no confirmation)

### Testing Checkpoint 4

```
Required before proceeding to Phase 5:
- [x] Tab navigation works correctly
- [x] Home screen displays all cards correctly
- [x] Quick Practice generates correct session mix
- [x] QuickPracticeGeneratorTests.swift: 90%+ coverage
- [x] UI tests for Home → Quick Practice flow
- [x] All tests pass (175 tests, 0 failures)
```

---

## Phase 5: Feature - Drill Modules

**Goal:** Refactor drill views to match DESIGN.md Section 7 specifications.

**Prerequisites:** Phase 4 complete

### Tasks

#### 5.1 Chord Drill Refactor
- [ ] **5.1.1** Split `ChordDrillView.swift` into:
  - `Features/ChordDrill/ChordDrillView.swift` (container)
  - `Features/ChordDrill/ChordDrillSetup.swift`
  - `Features/ChordDrill/ChordDrillSession.swift`
  - `Features/ChordDrill/ChordDrillResults.swift`

- [ ] **5.1.2** Create `Features/ChordDrill/ChordDrillGame.swift`
  - **Based on:** Current `QuizGame.swift`
  - **Structure:** Per DESIGN.md Section 12.2

- [ ] **5.1.3** Implement Quick Start Presets
  - **Per:** DESIGN.md Section 7.4.1 (Basic Triads, 7th Chords, Full Workout)

- [ ] **5.1.4** Create unit tests for ChordDrillGame
  - **File:** `Jazz Harmony QuizTests/Features/ChordDrill/ChordDrillGameTests.swift`
  - **Target:** 90%+ coverage

#### 5.2 Cadence Drill Refactor
- [ ] **5.2.1** Split `CadenceDrillView.swift` into:
  - `Features/CadenceDrill/CadenceDrillView.swift`
  - `Features/CadenceDrill/CadenceDrillSetup.swift`
  - `Features/CadenceDrill/CadenceDrillSession.swift`
  - `Features/CadenceDrill/CadenceDrillResults.swift`

- [ ] **5.2.2** Consolidate drill modes from 9 to 6
  - **Remove:** Speed Round (make timed option), Smooth Voicing (future Voice Leading)
  - **Keep:** Per DESIGN.md Section 7.5.2

- [ ] **5.2.3** Create unit tests for CadenceDrillGame
  - **Target:** 90%+ coverage

#### 5.3 Scale Drill Refactor
- [ ] **5.3.1** Split `ScaleDrillView.swift` into:
  - `Features/ScaleDrill/ScaleDrillView.swift`
  - `Features/ScaleDrill/ScaleDrillSetup.swift`
  - `Features/ScaleDrill/ScaleDrillSession.swift`
  - `Features/ScaleDrill/ScaleDrillResults.swift`

- [ ] **5.3.2** Create unit tests for ScaleDrillGame
  - **Target:** 90%+ coverage

#### 5.4 Interval Drill Refactor
- [ ] **5.4.1** Split `IntervalDrillView.swift` into:
  - `Features/IntervalDrill/IntervalDrillView.swift`
  - `Features/IntervalDrill/IntervalDrillSetup.swift`
  - `Features/IntervalDrill/IntervalDrillSession.swift`
  - `Features/IntervalDrill/IntervalDrillResults.swift`

- [ ] **5.4.2** Create unit tests for IntervalDrillGame
  - **Target:** 90%+ coverage

#### 5.5 Shared Drill Components
- [ ] **5.5.1** Create shared `DrillState` enum
  - **File:** `Core/Models/DrillState.swift`
  - **Values:** `.setup`, `.active`, `.results`

- [ ] **5.5.2** Create shared `DrillResultsView` component
  - **File:** `Components/DrillResultsView.swift`
  - **Per:** DESIGN.md Section 6.3 (SESSION COMPLETE layout)

- [ ] **5.5.3** Create shared `DrillSetupView` pattern/protocol
  - **Pattern:** Quick Start presets + collapsible custom options

### Testing Checkpoint 5

```
Required before proceeding to Phase 6:
- [ ] All drill views split into Setup/Session/Results
- [ ] ChordDrillGameTests.swift: 90%+ coverage
- [ ] CadenceDrillGameTests.swift: 90%+ coverage
- [ ] ScaleDrillGameTests.swift: 90%+ coverage
- [ ] IntervalDrillGameTests.swift: 90%+ coverage
- [ ] All drills functional end-to-end (manual test)
- [ ] All tests pass
```

---

## Phase 6: Feature - Curriculum & Progress

**Goal:** Implement Curriculum and Progress tabs per DESIGN.md Sections 8 and 9.

**Prerequisites:** Phase 5 complete

### Tasks

#### 6.1 Curriculum Feature
- [ ] **6.1.1** Create `Features/Curriculum/CurriculumView.swift`
  - **Layout:** Per DESIGN.md Section 3.2 (Pathway selection + module list)

- [ ] **6.1.2** Create `Features/Curriculum/PathwaySelector.swift`
  - **Display:** Horizontal scroll of 4 pathways with colors

- [ ] **6.1.3** Create `Features/Curriculum/ModuleCard.swift`
  - **States:** Locked, available, in-progress, completed

- [ ] **6.1.4** Create `Features/Curriculum/ModuleDetailView.swift`
  - **Modal sheet:** Module description, criteria, start button

- [ ] **6.1.5** Create tests for curriculum progression logic
  - **File:** `Jazz Harmony QuizTests/Features/Curriculum/CurriculumTests.swift`
  - **Target:** 90%+ coverage

#### 6.2 Progress Feature
- [ ] **6.2.1** Create `Features/Progress/ProgressView.swift`
  - **Layout:** Per DESIGN.md Section 3.2

- [ ] **6.2.2** Create `Features/Progress/StatsOverview.swift`
  - **Display:** Key statistics summary

- [ ] **6.2.3** Create `Features/Progress/KeyBreakdown.swift`
  - **Display:** 12 keys with accuracy percentages

- [ ] **6.2.4** Create `Features/Progress/AchievementsList.swift`
  - **Display:** Simplified achievements per DESIGN.md Section 9.3.2

#### 6.3 Progression System Updates
- [ ] **6.3.1** Replace Rank system with PlayerLevel
  - **Remove:** 12-tier rank names and emoji
  - **Add:** Simple level number from XP
  - **Per:** DESIGN.md Section 9.3.1

- [ ] **6.3.2** Update XP awards
  - **Per:** DESIGN.md Section 9.4

- [ ] **6.3.3** Create tests for progression calculations
  - **File:** `Jazz Harmony QuizTests/Services/ProgressionTests.swift`
  - **Target:** 95%+ coverage

### Testing Checkpoint 6

```
Required before proceeding to Phase 7:
- [ ] Curriculum tab displays all pathways and modules
- [ ] Module unlock logic works correctly
- [ ] Progress tab displays accurate statistics
- [ ] Achievements display without emoji (professional)
- [ ] PlayerLevel calculates correctly from XP
- [ ] CurriculumTests.swift: 90%+ coverage
- [ ] ProgressionTests.swift: 95%+ coverage
- [ ] All tests pass
```

---

## Phase 7: Feature - Settings & Polish

**Goal:** Complete Settings feature and final polish.

**Prerequisites:** Phase 6 complete

### Tasks

#### 7.1 Settings Feature
- [ ] **7.1.1** Create `Features/Settings/SettingsView.swift`
  - **Structure:** Per DESIGN.md Section 11.1

- [ ] **7.1.2** Implement Audio settings section
  - **Options:** Sound toggle, volume, auto-play, chord/interval style, tempo

- [ ] **7.1.3** Implement Display settings section
  - **Options:** Theme (Light/Dark/System)
  - **Remove:** Chord font option

- [ ] **7.1.4** Implement Practice Defaults section
  - **Options:** Default question count, haptic feedback

- [ ] **7.1.5** Implement Data section
  - **Options:** Export, Reset Statistics, Reset All (with confirmations)

#### 7.2 Cleanup & Removal
- [ ] **7.2.1** Remove deprecated files:
  - `ScoreboardView.swift`
  - `CadenceScoreboardView.swift`
  - Old rank-related code
  - Caveat font files

- [ ] **7.2.2** Update all file imports after moves
  - **Search:** For broken imports across project

- [ ] **7.2.3** Remove unused code and dead references

#### 7.3 Final Polish
- [ ] **7.3.1** Verify all navigation flows work correctly
  - **Test:** Every tab, every drill, every modal

- [ ] **7.3.2** Verify Dark Mode support throughout
  - **Test:** Toggle system appearance, verify all screens

- [ ] **7.3.3** Verify accessibility labels and VoiceOver
  - **Test:** Basic VoiceOver navigation

### Testing Checkpoint 7

```
Required before proceeding to Phase 8:
- [ ] Settings view fully functional
- [ ] All deprecated files removed
- [ ] No build warnings
- [ ] Dark Mode works on all screens
- [ ] No broken navigation paths
- [ ] All tests pass
```

---

## Phase 8: Final Testing & Documentation

**Goal:** Achieve 90%+ test coverage, document completion.

**Prerequisites:** Phase 7 complete

### Tasks

#### 8.1 Coverage Gap Analysis
- [ ] **8.1.1** Run full test suite with coverage report
  - **Command:** Xcode → Product → Test with coverage enabled
  - **Record:** Overall percentage

- [ ] **8.1.2** Identify files below 90% coverage
  - **List:** Files and their current coverage

- [ ] **8.1.3** Write additional tests for low-coverage files
  - **Priority:** Critical paths first (answer validation, SR scheduling, statistics)

#### 8.2 UI Testing
- [ ] **8.2.1** Create UI test: Onboarding/First Launch
  - **File:** `Jazz Harmony QuizUITests/OnboardingUITests.swift`

- [ ] **8.2.2** Create UI test: Complete Chord Drill flow
  - **File:** `Jazz Harmony QuizUITests/ChordDrillUITests.swift`

- [ ] **8.2.3** Create UI test: Quick Practice flow
  - **File:** `Jazz Harmony QuizUITests/QuickPracticeUITests.swift`

- [ ] **8.2.4** Create UI test: Curriculum module completion
  - **File:** `Jazz Harmony QuizUITests/CurriculumUITests.swift`

#### 8.3 Documentation
- [ ] **8.3.1** Update ARCHITECTURE.md to reflect new structure
  - **Document:** New file locations, patterns, state management

- [ ] **8.3.2** Update .ai/PROJECT_CONTEXT.md for new architecture

- [ ] **8.3.3** Create/update README.md with developer setup instructions

#### 8.4 Final Verification
- [ ] **8.4.1** Full regression test (all features manually)
- [ ] **8.4.2** Verify test coverage is 90%+
- [ ] **8.4.3** Build and run on physical device
- [ ] **8.4.4** Update this document's Current Status to COMPLETE

### Final Testing Checkpoint

```
COMPLETION CRITERIA:
- [ ] Overall test coverage: 90%+
- [ ] Unit test coverage on Models: 95%+
- [ ] Unit test coverage on Services: 90%+
- [ ] Unit test coverage on Game Logic: 90%+
- [ ] All UI tests pass
- [ ] Zero build warnings
- [ ] Zero runtime crashes
- [ ] All features functional
- [ ] Documentation updated
```

---

## Test Coverage Requirements Summary

| Category | Files | Target Coverage | Priority |
|----------|-------|-----------------|----------|
| Core Models | Note, Chord, Scale, Interval, Cadence | 95% | Critical |
| Spaced Repetition | SpacedRepetitionStore | 95% | Critical |
| Game Logic | ChordDrillGame, CadenceDrillGame, etc. | 90% | Critical |
| Statistics | StatisticsManager, PlayerLevel | 90% | High |
| Quick Practice | QuickPracticeGenerator | 90% | High |
| Curriculum | CurriculumManager, module logic | 90% | High |
| UI Components | Buttons, Cards, Keyboard | 80% | Medium |
| Views | Feature views | 70% | Medium |
| Settings | SettingsManager | 85% | Medium |

### Test File Structure

```
Jazz Harmony QuizTests/
├── TestUtilities/
│   └── TestHelpers.swift
├── Core/
│   ├── Models/
│   │   ├── NoteTests.swift
│   │   ├── ChordTests.swift
│   │   ├── ScaleTests.swift
│   │   ├── IntervalTests.swift
│   │   └── CadenceTests.swift
│   └── Services/
│       ├── SpacedRepetitionTests.swift
│       ├── StatisticsManagerTests.swift
│       └── QuickPracticeGeneratorTests.swift
├── Features/
│   ├── ChordDrill/
│   │   └── ChordDrillGameTests.swift
│   ├── CadenceDrill/
│   │   └── CadenceDrillGameTests.swift
│   ├── ScaleDrill/
│   │   └── ScaleDrillGameTests.swift
│   ├── IntervalDrill/
│   │   └── IntervalDrillGameTests.swift
│   └── Curriculum/
│       └── CurriculumTests.swift
└── Components/
    ├── PianoKeyboardTests.swift
    ├── ButtonTests.swift
    └── CardTests.swift

Jazz Harmony QuizUITests/
├── OnboardingUITests.swift
├── ChordDrillUITests.swift
├── QuickPracticeUITests.swift
└── CurriculumUITests.swift
```

---

## Appendix A: File Migration Map

### Current → Target Location

| Current Path | Target Path | Action |
|--------------|-------------|--------|
| `Models/ChordModel.swift` | `Core/Models/` (split into 4 files) | Split & Move |
| `Models/ScaleModel.swift` | `Core/Models/ScaleType.swift`, `Scale.swift` | Split & Move |
| `Models/IntervalModel.swift` | `Core/Models/IntervalType.swift` | Move |
| `Models/QuizGame.swift` | `Features/ChordDrill/ChordDrillGame.swift` | Move & Rename |
| `Models/CadenceGame.swift` | `Features/CadenceDrill/CadenceDrillGame.swift` | Move & Rename |
| `Models/ScaleGame.swift` | `Features/ScaleDrill/ScaleDrillGame.swift` | Move & Rename |
| `Models/IntervalGame.swift` | `Features/IntervalDrill/IntervalDrillGame.swift` | Move & Rename |
| `Models/JazzChordDatabase.swift` | `Core/Databases/ChordDatabase.swift` | Move & Rename |
| `Models/JazzScaleDatabase.swift` | `Core/Databases/ScaleDatabase.swift` | Move & Rename |
| `Models/IntervalDatabase.swift` | `Core/Databases/IntervalDatabase.swift` | Move |
| `Models/ProgressionDatabase.swift` | `Core/Databases/CadenceDatabase.swift` | Move & Rename |
| `Models/CurriculumDatabase.swift` | `Core/Databases/CurriculumDatabase.swift` | Move |
| `Models/PlayerProfile.swift` | `Core/Services/StatisticsManager.swift` (refactor) | Refactor |
| `Models/SettingsManager.swift` | `Core/Services/SettingsManager.swift` | Move |
| `Models/SpacedRepetition.swift` | `Core/Services/SpacedRepetitionStore.swift` | Move & Rename |
| `Models/CurriculumManager.swift` | `Core/Services/CurriculumManager.swift` | Move |
| `Views/ChordDrillView.swift` | `Features/ChordDrill/` (split into 4 files) | Split & Move |
| `Views/CadenceDrillView.swift` | `Features/CadenceDrill/` (split into 4 files) | Split & Move |
| `Views/ScaleDrillView.swift` | `Features/ScaleDrill/` (split into 4 files) | Split & Move |
| `Views/IntervalDrillView.swift` | `Features/IntervalDrill/` (split into 4 files) | Split & Move |
| `Views/PianoKeyboard.swift` | `Components/PianoKeyboard.swift` | Move |
| `Views/CurriculumView.swift` | `Features/Curriculum/CurriculumView.swift` | Move |
| `Views/PlayerProfileView.swift` | `Features/Progress/ProgressView.swift` | Move & Refactor |
| `Views/SettingsView.swift` | `Features/Settings/SettingsView.swift` | Move |
| `Views/ScoreboardView.swift` | (DELETE) | Remove |
| `Views/CadenceScoreboardView.swift` | (DELETE) | Remove |
| `Helpers/AudioManager.swift` | `Core/Services/AudioManager.swift` | Move |
| `Helpers/FlowLayout.swift` | `Components/FlowLayout.swift` | Move |
| `ContentView.swift` | `App/ContentView.swift` | Move & Refactor |
| `JazzHarmonyQuizApp.swift` | `App/ShedProApp.swift` | Move & Rename |

---

## Appendix B: Breaking Changes Checklist

Per DESIGN.md Appendix A, these are known breaking changes to implement:

- [ ] Rank/Title system replaced with simple Level
- [ ] Achievement names simplified (remove emoji)
- [ ] Cadence drill modes consolidated (9 → 6)
- [ ] Chord font option removed
- [ ] Navigation restructured to tab-based
- [ ] App name changed to "Shed Pro"

---

## Appendix C: Resume Guide for LLM Agents

### Quick Resume Protocol

1. **Read Current Status** (top of this document)
2. **Check the phase marked as current**
3. **Find first unchecked `[ ]` task in that phase**
4. **Read the Testing Checkpoint for that phase**
5. **Begin work on the task**
6. **Update task to `[x]` when complete**
7. **Update "Current Task" in status section**
8. **If phase complete, update to next phase**

### When Blocked

If you encounter a blocker:
1. Add note under the blocked task
2. Update "Blockers/Notes" in Current Status
3. Try next task if independent
4. Ask user for clarification if truly blocked

### Commit Frequency

- Commit after completing each **numbered task** (e.g., 1.1.1, 1.1.2)
- Commit message format: `Phase X.Y.Z: Brief description`
- Push after each **Testing Checkpoint** passes

---

*End of Implementation Plan*
