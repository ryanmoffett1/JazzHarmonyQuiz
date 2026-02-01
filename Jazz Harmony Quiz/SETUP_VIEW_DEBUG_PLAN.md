# ChordDrillSetupView Debug Plan

## Status: ✅ COMPLETED

## Reported Issues

### Issue 1: Custom Ad-Hoc Shows Blank Screen
- **Symptom**: When tapping "Custom Ad-Hoc" from preset selection, the sheet appears blank
- **Expected**: Sheet should show Form with configuration options immediately
- **Status**: ✅ Fixed

### Issue 2: Create Preset Screen - Slow Display & Keyboard Freeze
- **Symptom**: Create Preset screen takes very long to display, then keyboard input freezes
- **Expected**: Screen should appear instantly, keyboard input should be responsive
- **Status**: ✅ Fixed

## Root Cause Analysis

### Primary Issue: Incorrect StateObject Initialization

**Current Code (BROKEN)**:
```swift
struct ChordDrillSetupView: View {
    @StateObject private var viewModel: ChordDrillSetupViewModelNew
    
    init(mode: SetupMode, onComplete: @escaping (SetupActionResult) -> Void) {
        // ❌ WRONG - This creates a new ViewModel on EVERY render
        self._viewModel = StateObject(wrappedValue: ChordDrillSetupViewModelNew(mode: mode))
        self.onComplete = onComplete
    }
}
```

**Why This Breaks**:
1. SwiftUI may call `init` multiple times during rendering
2. Each call creates a new `ChordDrillSetupViewModelNew`
3. Each `ChordDrillSetupViewModelNew` creates a new `CustomPresetStore`
4. Each `CustomPresetStore` calls `loadPresets()` from UserDefaults
5. The `allChordTypes` computed property calls `JazzChordDatabase.shared.chordTypes.map { $0.symbol }` on every access

This causes:
- **Blank screen**: View renders before ViewModel finishes initializing
- **Keyboard freeze**: Every keystroke triggers re-render → new ViewModel → heavy computation

### Secondary Issue: Heavy Computed Properties

The ViewModel has computed properties that access `JazzChordDatabase.shared` on every call:
```swift
var allChordTypes: [String] {
    JazzChordDatabase.shared.chordTypes.map { $0.symbol }  // Called repeatedly!
}
```

## Fix Plan

### Fix 1: Correct StateObject Initialization Pattern

Use SwiftUI's proper pattern for parameterized StateObject:

**Option A - Wrapper struct (Recommended)**:
```swift
struct ChordDrillSetupView: View {
    let mode: SetupMode
    let onComplete: (SetupActionResult) -> Void
    
    var body: some View {
        ChordDrillSetupViewContent(mode: mode, onComplete: onComplete)
    }
}

private struct ChordDrillSetupViewContent: View {
    @StateObject private var viewModel: ChordDrillSetupViewModelNew
    let onComplete: (SetupActionResult) -> Void
    
    init(mode: SetupMode, onComplete: @escaping (SetupActionResult) -> Void) {
        _viewModel = StateObject(wrappedValue: ChordDrillSetupViewModelNew(mode: mode))
        self.onComplete = onComplete
    }
    
    var body: some View { ... }
}
```

**Option B - Use @State for mode then initialize on appear**:
```swift
struct ChordDrillSetupView: View {
    let mode: SetupMode
    let onComplete: (SetupActionResult) -> Void
    
    @State private var viewModel: ChordDrillSetupViewModelNew?
    
    var body: some View {
        Group {
            if let viewModel {
                // ... actual form
            } else {
                ProgressView()
            }
        }
        .task {
            if viewModel == nil {
                viewModel = ChordDrillSetupViewModelNew(mode: mode)
            }
        }
    }
}
```

### Fix 2: Cache Static Data in ViewModel

Convert computed properties to lazy stored properties:

```swift
class ChordDrillSetupViewModelNew: ObservableObject {
    // Cache chord types - they never change
    private lazy var _allChordTypes: [String] = {
        JazzChordDatabase.shared.chordTypes.map { $0.symbol }
    }()
    
    var allChordTypes: [String] { _allChordTypes }
}
```

## Test Gaps Identified

### Missing Tests for UI Responsiveness

1. **Test: ViewModel initialization is fast**
   - Measure time to create ViewModel
   - Should be < 10ms

2. **Test: View can handle re-renders without re-creating ViewModel**
   - Verify ViewModel identity is preserved across re-renders

3. **Test: Text input doesn't trigger expensive computations**
   - Verify changing `presetName` doesn't re-compute `allChordTypes`

## Implementation Order

1. **Add performance tests** (capture current broken behavior)
2. **Fix StateObject initialization pattern**
3. **Cache static data in ViewModel**
4. **Verify tests pass**
5. **Manual verification**
