# FINAL ROOT CAUSE ANALYSIS

## Bug #3: Custom Ad-Hoc Blank Screen

### Root Cause: SwiftUI Sheet Presentation Pattern
**File:** `ChordDrillPresetSelectionView.swift` lines 44-48

**Problem Code:**
```swift
@State private var showingSetup = false
@State private var setupMode: SetupMode?

.sheet(isPresented: $showingSetup) {
    if let mode = setupMode {
        ChordDrillSetupView(mode: mode) { result in
            handleSetupResult(result)
        }
    }
}
```

**Why It Fails:**
- SwiftUI's state updates are batched and asynchronous
- When `showingSetup = true` triggers sheet presentation
- The sheet closure evaluates `if let mode = setupMode`
- Due to state batching, `setupMode` might still be `nil`
- Result: Empty sheet content (the `if let` fails)

**Fix: Use `.sheet(item:)` instead**
```swift
// Remove showingSetup, keep only:
@State private var setupMode: SetupMode?

.sheet(item: $setupMode) { mode in  // mode is guaranteed non-nil
    ChordDrillSetupView(mode: mode) { result in
        handleSetupResult(result)
    }
}
```

---

## Bug #4: Create Preset Keyboard Freeze  

### Root Cause: Navigation Title Computation
**File:** `ChordDrillSetupView.swift` lines 85-90

**Problem Code:**
```swift
private var navigationTitle: String {
    if viewModel.showsPresetNameField {
        return viewModel.presetName.isEmpty ? "New Preset" : viewModel.presetName
    }
    return "Custom Ad-Hoc Drill"
}

// Used at line 66:
.navigationTitle(navigationTitle)
```

**Why It Freezes:**
1. User types character → `@Published var presetName` updates
2. ViewModel's `objectWillChange` fires
3. SwiftUI re-renders entire view
4. `navigationTitle` computed property is evaluated
5. **It reads `viewModel.presetName`** - which just changed!
6. This triggers another observation/re-render cycle
7. The Form re-evaluates all sections (even hidden ones)
8. This happens **on every keystroke**

**Additional Performance Issue:**
Even though `customChordTypesSection` is conditionally shown (line 44):
```swift
if viewModel.showsChordTypePicker {
    customChordTypesSection  // LazyVGrid with 50+ items
}
```

SwiftUI still evaluates the computed property `customChordTypesSection` even if it's not rendered. While the actual rendering is lazy, the property access itself happens on every view update.

**Fix Options:**

#### Option 1: Don't use presetName in navigation title
```swift
private var navigationTitle: String {
    if viewModel.showsPresetNameField {
        return "New Preset"  // Static, doesn't change
    }
    return "Custom Ad-Hoc Drill"
}
```

#### Option 2: Use @State for the title, update it explicitly
```swift
@State private var navTitle = "New Preset"

TextField("Preset Name", text: $viewModel.presetName)
    .onChange(of: viewModel.presetName) { newValue in
        // Only update title occasionally, not on every keystroke
        if !newValue.isEmpty {
            navTitle = newValue
        }
    }
```

#### Option 3: Debounce the title update
```swift
TextField("Preset Name", text: $viewModel.presetName)
    .onChange(of: viewModel.presetName) { newValue in
        // Use a Task with delay to debounce
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: 300_000_000) // 300ms
            navTitle = newValue
        }
    }
```

---

## Why Our Tests Don't Catch These

### Bug #3 (Blank Sheet)
**What we test:**
```swift
let action = viewModel.selectBuiltInPreset(.customAdHoc)
guard case .openSetup(let mode) = action else { XCTFail(); return }
XCTAssertEqual(mode, .adHoc)
```

**What we DON'T test:**
- SwiftUI state synchronization timing
- Sheet presentation with multiple state variables
- The `if let` guard evaluation at presentation time

**Can't be unit tested because:** SwiftUI's rendering engine and state batching are internal

### Bug #4 (Keyboard Freeze)
**What we test:**
```swift
for char in "MyPresetName1234" {
    viewModel.presetName.append(char)
    let _ = viewModel.canPerformPrimaryAction
}
// Passes: < 100ms
```

**What we DON'T test:**
- SwiftUI view re-rendering on every keystroke
- Navigation title computation triggering extra updates
- Form section evaluation even when hidden
- StateObject observation overhead
- The actual TextField binding in a real view hierarchy

**Can't be unit tested because:** SwiftUI's view rendering, observation system, and lifecycle are internal

---

## Required Implementation Fixes

### 1. Fix Custom Ad-Hoc Blank Screen (ChordDrillPresetSelectionView.swift)

```swift
// REMOVE these lines:
@State private var showingSetup = false

// KEEP this:
@State private var setupMode: SetupMode?

// CHANGE from:
.sheet(isPresented: $showingSetup) {
    if let mode = setupMode {
        ChordDrillSetupView(mode: mode) { result in
            handleSetupResult(result)
        }
    }
}

// TO:
.sheet(item: $setupMode) { mode in
    ChordDrillSetupView(mode: mode) { result in
        handleSetupResult(result)
    }
}

// UPDATE handleAction:
case .openSetup(let mode):
    setupMode = mode  // Remove: showingSetup = true

// UPDATE handleSetupResult:
private func handleSetupResult(_ result: SetupActionResult) {
    setupMode = nil  // Remove: showingSetup = false
    // ... rest stays the same
}
```

### 2. Fix Create Preset Keyboard Freeze (ChordDrillSetupView.swift)

```swift
// CHANGE from:
private var navigationTitle: String {
    if viewModel.showsPresetNameField {
        return viewModel.presetName.isEmpty ? "New Preset" : viewModel.presetName
    }
    return "Custom Ad-Hoc Drill"
}

// TO (simplest fix):
private var navigationTitle: String {
    if viewModel.showsPresetNameField {
        return "New Preset"  // Static - no dependency on changing state
    }
    return "Custom Ad-Hoc Drill"
}
```

---

## Test Updates

Update the test comments to document the limitations:

```swift
func test_customAdHoc_sheetPresentationLogic() {
    // ⚠️  NOTE: This test cannot catch the actual bug.
    // ⚠️  The bug is SwiftUI state synchronization (untestable in unit tests).
    // ⚠️  Required fix: Use .sheet(item:) instead of .sheet(isPresented:)
    //
    // This test verifies the ViewModel behavior is correct:
    let selectionViewModel = ChordDrillPresetSelectionViewModel(presetStore: presetStore)
    let action = selectionViewModel.selectBuiltInPreset(.customAdHoc)
    
    guard case .openSetup(let mode) = action else {
        XCTFail("Custom Ad-Hoc should return .openSetup action")
        return
    }
    
    XCTAssertEqual(mode, .adHoc)
}
```

```swift
func test_createPreset_typingPerformance() {
    // ⚠️  NOTE: This test cannot catch the actual freeze.
    // ⚠️  The freeze is caused by navigationTitle reading presetName (untestable).
    // ⚠️  Required fix: Make navigationTitle static, don't read presetName
    //
    // This test verifies ViewModel performance is acceptable:
    let viewModel = ChordDrillSetupViewModelNew(mode: .createPreset, presetStore: presetStore)
    
    let start = CFAbsoluteTimeGetCurrent()
    for char in "MyPresetName1234" {
        viewModel.presetName.append(char)
        let _ = viewModel.canPerformPrimaryAction
    }
    let elapsed = (CFAbsoluteTimeGetCurrent() - start) * 1000
    
    XCTAssertLessThan(elapsed, 100)
}
```

---

## Verification Steps (Manual QA)

After implementing the fixes:

1. **Custom Ad-Hoc:**
   - Tap "Custom Ad-Hoc"
   - ✅ Setup sheet should appear with Form content (not blank)
   - ✅ Should see sections for Chord Difficulty, Key Difficulty, etc.

2. **Create Preset:**
   - Tap "Create Custom Preset"
   - ✅ Setup sheet should appear
   - Type in preset name field
   - ✅ Should be responsive, no freeze
   - ✅ Each keystroke should feel instant

3. **Quit/New Quiz:**
   - Start "Basic Triads" drill
   - Tap "Quit"
   - ✅ Should see setup screen (not "Module not found")
   - Complete quiz
   - Tap "New Quiz"
   - ✅ Should see setup screen (not "Module not found")

