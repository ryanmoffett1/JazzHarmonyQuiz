# Contributing to Shed Pro (Jazz Harmony Quiz)

This document outlines the Software Development Lifecycle (SDLC) rules for this project. Both human developers and AI agents must follow these practices.

---

## Core Principles

### 1. Tests Are Sacred

**Never modify a test to make it pass.**

- If a test fails, the **code under test** is likely wrong
- If you believe the test itself is wrong, you must:
  1. Understand *why* it's wrong
  2. Document the reasoning
  3. Get approval before changing it
- A failing test is a signal to investigate, not a problem to work around

### 2. Tests Must Pass Before Committing

Every commit must have all tests passing. No exceptions.

```bash
# Full test suite must pass before ANY commit
xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'
```

### 3. Test After Every Change

Run tests frequently during development, not just before committing:
- After implementing a feature
- After refactoring
- After fixing a bug
- Before and after merging

---

## Development Workflow

### Standard Commit Cycle

```
1. Make changes
2. Build: xcodebuild build -scheme JazzHarmonyQuiz ...
3. Test:  xcodebuild test -scheme JazzHarmonyQuiz ...
4. All tests pass? → git add -A && git commit
5. Push: git push github main
```

### When a Test Fails

**DO:**
1. Read the failure message carefully
2. Understand what the test is checking
3. Investigate the code under test
4. Fix the root cause in the production code
5. Verify the fix by running the test again

**DON'T:**
- Comment out the failing test
- Add `skip` or `disabled` attributes
- Modify assertions to match broken behavior
- Use workarounds like `?? defaultValue` to silence type errors

### When You Think the Test is Wrong

Before changing any test, answer these questions:

1. **What is the test actually testing?** (Read the test name and assertions)
2. **What behavior does the test expect?** (Trace through the assertions)
3. **Is the expected behavior correct per the spec?** (Check DESIGN.md)
4. **Why was this test written this way?** (Check git blame/history)

If after this analysis you're confident the test is wrong:
1. Document the issue
2. Explain why the current test is incorrect
3. Explain what the correct behavior should be
4. Make the change with a clear commit message

---

## Test Writing Standards

### Proper Optional Handling

**Wrong:**
```swift
// Silently passes if result is nil (comparing 0.0 to expected)
XCTAssertEqual(game.result?.accuracy ?? 0.0, 1.0, accuracy: 0.01)
```

**Correct:**
```swift
// Explicitly fails if result is nil
guard let result = game.result else {
    XCTFail("Expected result to be non-nil")
    return
}
XCTAssertEqual(result.accuracy, 1.0, accuracy: 0.01)
```

### Test Structure

```swift
func testFeatureBehavior() {
    // Arrange - Set up preconditions
    let game = GameClass()
    
    // Act - Perform the action being tested
    game.performAction()
    
    // Assert - Verify the expected outcome
    XCTAssertEqual(game.state, .expected)
}
```

### Test Naming

- Test names should describe the behavior being tested
- Format: `test[MethodOrFeature]_[Scenario]_[ExpectedResult]`
- Examples:
  - `testStartNewQuiz_withValidConfig_setsActiveState()`
  - `testSubmitAnswer_whenCorrect_incrementsScore()`
  - `testFinishDrill_updatesCurrentIndexToPreventInfiniteLoop()`

---

## For AI Agents

### Before Starting Work

1. Read `IMPLEMENTATION_PLAN.md` to understand current phase and task
2. Read this document (`CONTRIBUTING.md`) for SDLC rules
3. Check `DESIGN.md` for feature specifications

### During Development

1. Follow the Standard Commit Cycle above
2. Run tests after EVERY code change
3. If tests fail, fix the code—don't modify tests
4. Update `IMPLEMENTATION_PLAN.md` progress as tasks complete

### When Tests Hang or Timeout

Common causes and fixes:
1. **Infinite loops** - Check for missing state updates (e.g., `currentIndex` not advancing)
2. **Async deadlocks** - Avoid `@MainActor` with `async throws` setUp/tearDown in XCTest
3. **UI blocking** - Ensure no synchronous waits on main thread

### Red Flags to Watch For

- Wanting to change a test assertion to match current behavior
- Using `?? defaultValue` to silence optional-related errors in tests
- Adding `try?` or `catch` that silently ignores errors
- Commenting out test code

If you encounter these urges, STOP and investigate the root cause.

---

## Code Coverage Targets

| Component | Target Coverage |
|-----------|-----------------|
| Core/Models | 95%+ |
| Core/Services | 90%+ |
| Features (Game logic) | 90%+ |
| Views | Not required |

---

## Git Commit Messages

Format:
```
Phase X.Y.Z: Brief description

- Bullet points for details
- Include test count changes if relevant
```

Examples:
```
Phase 5.2.3: Add CadenceGameTests with 87 tests (210->297 total)

Fix: Properly unwrap optional in testPerfectScoreResult

Phase 5.2.2: Consolidate cadence drill modes from 9 to 6
- Removed: isolatedChord, speedRound, smoothVoicing
- Updated all switch statements and view bindings
```

---

## Quick Reference

### Test Commands

```bash
# Full test suite
xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'

# Specific test class
xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' -only-testing:JazzHarmonyQuizTests/ChordDrillGameTests

# Specific test method
xcodebuild test -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6' -only-testing:JazzHarmonyQuizTests/ChordDrillGameTests/testInitialState
```

### Build Command

```bash
xcodebuild build -scheme JazzHarmonyQuiz -destination 'platform=iOS Simulator,name=iPhone 16,OS=18.6'
```

---

## Summary

1. **Tests are truth** - They define correct behavior
2. **Never modify tests to pass** - Fix the code instead
3. **Test constantly** - After every change
4. **Commit only when green** - All tests must pass
5. **When in doubt, investigate** - Understand before changing
