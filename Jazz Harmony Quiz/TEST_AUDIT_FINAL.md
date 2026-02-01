# Test Audit Summary: Why Tests Pass But App Is Broken

## Executive Summary

**The fundamental problem:** Our tests are **unit tests** that verify **ViewModel logic**, but the bugs are in the **View layer** (SwiftUI presentation and lifecycle), which unit tests **cannot catch**.

---

## Bug #1 & #2: presetLaunch Quit/New Quiz

### Status: ✅ FIXED (already)
- **Fix applied:** Changed `DrillLaunchMode.presetLaunch.showsSetupScreen` to `true`
- **Tests:** Now passing
- **App:** Should work (needs verification)

---

## Bug #3: Custom Ad-Hoc Shows Blank Screen

### Root Cause: SwiftUI Sheet Presentation Pattern Bug

**The buggy code** (ChordDrillPresetSelectionView.swift:44-48):
```swift
.sheet(isPresented: $showingSetup) {
    if let mode = setupMode {
        ChordDrillSetupView(mode: mode) { ... }
    }
}
```

**The problem:**
1. When `.sheet(isPresented:)` uses `Bool` binding
2. And the content has an `if let` guard on separate state
3. SwiftUI's state batching can cause `setupMode` to be `nil` when sheet renders
4. Result: Empty sheet content (the `if let` fails)

### Why Our Tests Pass

```swift
func test_customAdHoc_sheetPresentationLogic() {
    let action = viewModel.selectBuiltInPreset(.customAdHoc)
    guard case .openSetup(let mode) = action else { XCTFail(); return }
    XCTAssertEqual(mode, .adHoc)  // ✅ PASSES
}
```

This test:
- ✅ Verifies ViewModel returns correct action
- ✅ Verifies action contains `.adHoc` mode
- ❌ Does NOT test SwiftUI state synchronization
- ❌ Does NOT test actual sheet presentation
- ❌ Does NOT test the `if let` guard timing

### Why This Bug Is Untestable

**SwiftUI state synchronization cannot be unit tested** because:
1. State updates are batched and asynchronous
2. Sheet presentation timing is internal to SwiftUI
3. The `if let` evaluation happens in the View layer
4. Unit tests don't have access to SwiftUI's rendering engine

### The Fix

**Replace** `.sheet(isPresented:)` **with** `.sheet(item:)`:

```swift
// BEFORE (buggy):
@State private var showingSetup = false
@State private var setupMode: SetupMode?

.sheet(isPresented: $showingSetup) {
    if let mode = setupMode {  // ← Can be nil!
        ChordDrillSetupView(mode: mode) { ... }
    }
}

// AFTER (fixed):
@State private var setupMode: SetupMode?  // Remove showingSetup

.sheet(item: $setupMode) { mode in  // ← Guaranteed non-nil
    ChordDrillSetupView(mode: mode) { ... }
}
```

**Benefits:**
- Sheet only presents when `setupMode` is non-nil
- `mode` parameter is guaranteed to be non-nil in the closure
- Automatically dismisses when `setupMode` becomes `nil`
- Eliminates the race condition by design

---

## Bug #4: Create Preset Keyboard Freezes

### Root Cause Analysis

Let me investigate the actual freeze by looking at the StateObject pattern and property access.

### Possible Causes

#### Hypothesis 1: StateObject Recreation
The wrapper pattern should prevent this, but maybe there's still an issue.

#### Hypothesis 2: Expensive Computed Properties
Even with cached properties, SwiftUI might be accessing them too frequently.

### Why Our Tests Pass

```swift
func test_createPreset_typingSimulationIsFast() {
    let viewModel = ChordDrillSetupViewModelNew(mode: .createPreset)
    for char in "MyPresetName1234" {
        viewModel.presetName.append(char)
        let _ = viewModel.canPerformPrimaryAction  // ✅ Fast in isolation
    }
    // Passes: 16 keystrokes < 100ms
}
```

This test:
- ✅ Tests ViewModel performance
- ✅ Verifies property access is fast
- ❌ Does NOT test SwiftUI TextField binding
- ❌ Does NOT test actual view re-rendering
- ❌ Does NOT test StateObject lifecycle in real UI
- ❌ Does NOT test SwiftUI's observation system overhead

### Why This Bug Is Harder To Test

**SwiftUI view re-rendering cannot be unit tested** because:
1. TextField binding triggers SwiftUI's observation system
2. View re-renders involve the entire hierarchy
3. StateObject lifetime is managed by SwiftUI
4. Unit tests bypass all SwiftUI rendering

### Investigation Needed

I need to check:
1. Is the wrapper pattern actually being used correctly?
2. Are computed properties truly cached?
3. Is there something in the Form that's expensive?
4. Is the StateObject being recreated despite the wrapper?

Let me check the actual ViewModel implementation...

---

## Fundamental Lesson

**Unit tests cannot catch View-layer bugs in SwiftUI.**

### What Unit Tests CAN Test
- ✅ ViewModel logic (data transformations)
- ✅ Business rules (validation, calculations)
- ✅ Model behavior (state machines, algorithms)
- ✅ Service layer (API calls, storage)

### What Unit Tests CANNOT Test
- ❌ SwiftUI state synchronization
- ❌ View lifecycle (appear/disappear)
- ❌ Sheet/alert presentation timing
- ❌ Binding performance in real UI
- ❌ View rendering and re-rendering
- ❌ StateObject creation/retention
- ❌ User interaction flows

---

## Required Fixes

### 1. Custom Ad-Hoc Blank Screen (MANDATORY FIX)

**File:** `ChordDrillPresetSelectionView.swift`

**Change:**
```swift
// Remove this state variable:
@State private var showingSetup = false  // DELETE

// Keep this:
@State private var setupMode: SetupMode?  // KEEP

// Replace .sheet(isPresented:) with .sheet(item:):
.sheet(item: $setupMode) { mode in  // Changed from isPresented
    ChordDrillSetupView(mode: mode) { result in
        handleSetupResult(result)
    }
}

// Update handleAction to only set setupMode:
case .openSetup(let mode):
    setupMode = mode  // No need to set showingSetup anymore
```

### 2. Create Preset Keyboard Freeze (INVESTIGATE FIRST)

Need to:
1. Verify the wrapper pattern is correct
2. Check if computed properties are truly cached
3. Profile actual TextField performance
4. Investigate StateObject lifecycle

---

## Test Strategy Going Forward

### For UI Bugs: Document, Don't Test

Since SwiftUI View-layer bugs can't be unit tested:

1. **Document the bug** in test comments
2. **Document the fix** in test comments
3. **Test the ViewModel** behavior (which we can test)
4. **Manual QA** for the actual UI behavior

### Example Test Pattern

```swift
func test_customAdHoc_viewModelBehavior() {
    // ⚠️  NOTE: This test verifies ViewModel logic only.
    // ⚠️  The actual bug is in SwiftUI sheet presentation (untestable).
    // ⚠️  Required fix: Use .sheet(item:) instead of .sheet(isPresented:)
    
    let viewModel = ChordDrillPresetSelectionViewModel()
    let action = viewModel.selectBuiltInPreset(.customAdHoc)
    
    // Verify ViewModel returns correct action
    guard case .openSetup(let mode) = action else {
        XCTFail("Should return .openSetup action")
        return
    }
    
    XCTAssertEqual(mode, .adHoc)
}
```

---

## Next Steps

1. ✅ Audit complete - documented why tests pass but app fails
2. ⏳ Fix Custom Ad-Hoc sheet presentation (use `.sheet(item:)`)
3. ⏳ Investigate Create Preset freeze (check ViewModel implementation)
4. ⏳ Manual QA to verify fixes
5. ⏳ Update tests with documentation about View-layer limitations

