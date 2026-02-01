# Test Audit: Why Tests Pass But App Is Broken

## Date: January 31, 2026

## Executive Summary

Our tests are **unit tests on ViewModels** that verify data correctness but don't verify **actual View rendering** or **SwiftUI lifecycle behavior**. This is why they pass while the app has critical UI bugs.

---

## BUG #1: Custom Ad-Hoc Shows Blank Screen

### What the User Sees
- Tap "Custom Ad-Hoc" → Sheet appears but is BLANK
- No form, no fields, nothing

### Root Cause (Suspected)
The sheet presentation uses an `if let` guard:

```swift
.sheet(isPresented: $showingSetup) {
    if let mode = setupMode {
        ChordDrillSetupView(mode: mode) { result in
            handleSetupResult(result)
        }
    }
}
```

**Timing issue**: If `showingSetup` becomes `true` before `setupMode` is set (or if there's a race condition), the sheet shows with `mode == nil`, resulting in an empty view.

### Why Our Test Passes

```swift
func test_setupView_adHocMode_hasVisibleContent() {
    let viewModel = ChordDrillSetupViewModelNew(mode: .adHoc, presetStore: presetStore)
    XCTAssertFalse(viewModel.availableChordDifficulties.isEmpty)
    // ... more ViewModel property checks
}
```

This test:
1. ✅ Creates a ViewModel directly with `.adHoc` mode
2. ✅ Verifies the ViewModel has data
3. ❌ Does NOT verify the View actually renders
4. ❌ Does NOT verify the sheet presentation logic
5. ❌ Does NOT verify the `if let mode` guard

### What We Should Test

```swift
func test_customAdHoc_actualViewRendering() {
    // INTEGRATION TEST:
    // 1. Simulate tapping Custom Ad-Hoc button
    // 2. Verify setupMode is set BEFORE showingSetup
    // 3. Verify sheet content is non-nil
    // 4. Verify Form actually renders with sections
}
```

---

## BUG #2: Create Preset Keyboard Freezes

### What the User Sees
- Tap "Create Custom Preset" → Sheet appears
- Start typing preset name → **App freezes immediately**

### Root Cause (Suspected - Multiple Issues)

#### Issue 2a: StateObject Recreation
The wrapper pattern is correct, but SwiftUI might still be recreating the StateObject on every keystroke if:
- The parent view re-renders
- The `mode` parameter changes (it shouldn't, but...)
- Something invalidates the view hierarchy

#### Issue 2b: Expensive Computed Properties
The ViewModel has computed properties accessed on every render:

```swift
var allChordTypes: [ChordType] {
    ChordType.allCases  // 50+ chord types
}

var allKeys: [Note] {
    Note.allNotes  // All 12 keys
}
```

If these are being called on every keystroke AND the StateObject is being recreated, it's O(n²) performance.

### Why Our Test Passes

```swift
func test_setupView_createMode_typingIsFast() {
    let viewModel = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: presetStore)
    
    let start = CFAbsoluteTimeGetCurrent()
    for char in "MyPresetName1234" {
        viewModel.presetName.append(char)
        let _ = viewModel.canPerformPrimaryAction
        // ...
    }
    let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
    XCTAssertLessThan(elapsed, 100)
}
```

This test:
1. ✅ Creates ONE ViewModel instance
2. ✅ Modifies it directly (bypassing SwiftUI)
3. ❌ Does NOT test SwiftUI's TextField binding
4. ❌ Does NOT test StateObject lifecycle
5. ❌ Does NOT test view re-rendering
6. ❌ Does NOT test the actual sheet presentation

### What We Should Test

```swift
func test_createPreset_textFieldBinding_doesNotRecreateViewModel() {
    // INTEGRATION TEST:
    // 1. Present the actual sheet
    // 2. Get reference to the ViewModel instance
    // 3. Type in TextField
    // 4. Verify ViewModel instance is THE SAME
    // 5. Measure actual time between keystrokes
}
```

---

## Fundamental Problem: Unit Tests vs Integration Tests

### What We Have (Unit Tests)
```
User Tap → ViewModel Method → Assert Data Correctness ✅
```

### What We Need (Integration Tests)
```
User Tap → SwiftUI View Update → Sheet Presentation → View Rendering → User Interaction → Assert UI State ✅
```

---

## Test Strategy Going Forward

### Phase 1: Add Integration Tests That FAIL
1. Test actual sheet presentation logic
2. Test view rendering with ViewInspector or similar
3. Test StateObject lifecycle
4. Test TextField performance in real SwiftUI context

### Phase 2: Fix Implementation
Only after we have failing tests that capture the exact bugs

### Phase 3: Verify Tests Pass
Ensure the integration tests now pass

---

## Proposed Test Types

### 1. View State Tests (Integration)
```swift
// Tests the actual sheet presentation state machine
func test_customAdHoc_sheetPresentation() {
    // Verify setupMode is set before showingSetup
    // Verify sheet content is not nil
}
```

### 2. View Rendering Tests (Integration)
```swift
// Tests that Form actually renders with sections
func test_customAdHoc_formHasSections() {
    // Use ViewInspector or manual view inspection
    // Verify Form has expected sections
}
```

### 3. Performance Tests (Integration)
```swift
// Tests actual TextField performance in SwiftUI context
func test_createPreset_actualTextFieldPerformance() {
    // Measure time between TextField updates
    // Verify no StateObject recreation
}
```

### 4. StateObject Lifecycle Tests
```swift
// Tests that StateObject is not recreated on re-render
func test_setupView_stateObjectLifecycle() {
    // Get instance ID
    // Trigger re-render
    // Verify same instance ID
}
```

---

## Action Items

1. ✅ Audit complete - understand why tests pass but app fails
2. ⏳ Write integration tests that FAIL (catch the bugs)
3. ⏳ Verify tests fail for the right reasons
4. ⏳ Fix implementation
5. ⏳ Verify tests pass
6. ⏳ Add regression tests for these patterns

---

## Lessons Learned

1. **ViewModel tests ≠ View tests**
   - Just because the ViewModel has data doesn't mean the View shows it
   
2. **SwiftUI lifecycle is complex**
   - StateObject, sheet presentation, timing - all can break in ways unit tests miss
   
3. **Performance tests need real context**
   - Testing ViewModel in isolation misses SwiftUI overhead
   
4. **Integration tests are essential**
   - For UI frameworks, you MUST test the actual rendering path

---

## Next Steps

Implement integration tests that:
1. Actually present sheets
2. Actually interact with TextFields
3. Actually measure SwiftUI performance
4. Actually verify view rendering

These tests MUST fail until we fix the implementation.
