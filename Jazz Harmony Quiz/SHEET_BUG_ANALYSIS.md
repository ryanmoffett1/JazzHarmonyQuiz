# Real Bug Analysis: Custom Ad-Hoc Blank Screen

## The Problem

When using `.sheet(isPresented:)` with an optional binding inside the content closure, there's a race condition:

```swift
.sheet(isPresented: $showingSetup) {
    if let mode = setupMode {  // ← setupMode might be nil here!
        ChordDrillSetupView(mode: mode) { ... }
    }
}
```

**What happens:**
1. User taps "Custom Ad-Hoc"
2. `handleAction` is called
3. `setupMode = .adHoc` (sets state)
4. `showingSetup = true` (sets state)  
5. SwiftUI triggers sheet presentation
6. Sheet closure evaluates `if let mode = setupMode`
7. **BUG**: Due to SwiftUI's state batching, `setupMode` might still be `nil` when the sheet closure runs!

## The Fix

Use `.sheet(item:)` instead, which guarantees the item is non-nil:

```swift
.sheet(item: $setupMode) { mode in
    ChordDrillSetupView(mode: mode) { result in
        handleSetupResult(result)
    }
}
```

This pattern:
- Only presents when `setupMode` is non-nil
- Automatically dismisses when `setupMode` becomes `nil`
- Eliminates the race condition

## Why Our Test Didn't Catch It

Our test checked:
```swift
let action = viewModel.selectBuiltInPreset(.customAdHoc)
guard case .openSetup(let mode) = action else { ... }
```

This verifies the **ViewModel** returns the right action, but doesn't test the **SwiftUI state synchronization**.

We need a test that:
1. Simulates the actual state changes
2. Verifies sheet content is available at presentation time
3. Catches the `if let` guard failure

But this is nearly impossible to test without SwiftUI's actual rendering engine.

**Solution**: Fix the implementation to use `.sheet(item:)` which eliminates the bug by design.
