# Jazz Harmony Quiz - Refactor Plan

## Problem Summary
The app freezes/crashes when navigating to "Cadence Drill" due to architectural issues with state management and navigation patterns.

## Root Causes Identified

### Issue 1: Inconsistent State Ownership
- `CadenceDrillView` creates its own `@StateObject private var cadenceGame = CadenceGame()`
- But then tries to pass it to child views via `.environmentObject(cadenceGame)`
- This creates confusion about state ownership and can cause threading issues

### Issue 2: Force Unwrapping in CadenceProgression.init()
- Code uses `JazzChordDatabase.shared.getChordType(symbol: "m7")!`
- If symbol lookup fails, app crashes

### Issue 3: Duplicate Environment Object Injection
- Child views receive `.environmentObject()` multiple times
- This is unnecessary and can cause issues

---

## Execution Plan

### Step 1: Fix App Entry Point
**File:** `JazzHarmonyQuizApp.swift`
**Status:** [ ] NOT STARTED
**Changes:**
- Create `CadenceGame` as `@StateObject` at app level
- Inject both `quizGame` and `cadenceGame` as environment objects

### Step 2: Update ContentView Navigation
**File:** `ContentView.swift`  
**Status:** [ ] NOT STARTED
**Changes:**
- Add `@EnvironmentObject var cadenceGame: CadenceGame`
- Ensure `cadenceGame` is passed to `CadenceDrillView`

### Step 3: Refactor CadenceDrillView
**File:** `Views/CadenceDrillView.swift`
**Status:** [ ] NOT STARTED
**Changes:**
- Change `@StateObject private var cadenceGame = CadenceGame()` to `@EnvironmentObject var cadenceGame: CadenceGame`
- Remove redundant `.environmentObject()` calls on child views (they inherit from parent)

### Step 4: Add Safety Guards in CadenceProgression
**File:** `Models/ChordModel.swift`
**Status:** [ ] NOT STARTED
**Changes:**
- Replace force unwraps with safe optional handling
- Add fallback chord types if lookup fails

### Step 5: Verify ChordDrillView Consistency
**File:** `Views/ChordDrillView.swift`
**Status:** [ ] NOT STARTED
**Changes:**
- Ensure it follows the same pattern as CadenceDrillView
- Remove any redundant environment object injections

### Step 6: Clean Up Models
**Files:** `Models/QuizGame.swift`, `Models/CadenceGame.swift`, `Models/SettingsManager.swift`
**Status:** [ ] NOT STARTED
**Changes:**
- Remove `@MainActor` annotations (not needed for simple ObservableObject)
- Ensure consistent patterns across all models

---

## Current Progress
- [x] Analysis complete
- [x] Step 1: Fix App Entry Point - Added CadenceGame as @StateObject
- [x] Step 2: Update ContentView Navigation - Added cadenceGame as @EnvironmentObject
- [x] Step 3: Refactor CadenceDrillView - Changed to @EnvironmentObject, removed redundant injections
- [x] Step 4: Add Safety Guards - Removed force unwraps in CadenceProgression.init()
- [x] Step 5: Verify ChordDrillView - Already consistent
- [x] Step 6: Clean Up Models - No @MainActor, clean ObservableObject pattern
- [x] Final Testing - APP NOW WORKING ✅

## Root Cause Summary
The crash was caused by:
1. **Incorrect state ownership** - CadenceDrillView was creating its own @StateObject instead of receiving via @EnvironmentObject
2. **Force unwraps** - CadenceProgression.init() used force unwraps that could fail
3. **Missing safety checks** - Views accessed arrays without bounds checking
4. **Order of operations** - viewState was being set to .active before questions were generated

---

## Notes
- Do NOT use `@MainActor` on ObservableObject classes - SwiftUI handles this automatically
- Environment objects flow down the view hierarchy automatically
- Only create `@StateObject` once at the top level, use `@EnvironmentObject` everywhere else
