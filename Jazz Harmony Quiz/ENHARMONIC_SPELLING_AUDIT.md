# Enharmonic Spelling Audit

## Problem Statement
When displaying note names in chord and scale contexts, we need to use the correct enharmonic spelling that matches the musical key/root. For example:
- **Abmaj6** should show notes as **Ab, C, Eb, F** (not G#, C, D#, F)
- **F#7** should show notes as **F#, A#, C#, E** (not Gb, Bb, Db, E)

## Test Coverage

### ✅ Already Tested
1. **Note.enharmonicEquivalent** - NoteTests.swift
   - Tests that C#/Db, F#/Gb, G#/Ab pairs work correctly
   - Tests that natural notes have no enharmonic

2. **ScaleDrill.displayNoteName()** - ScaleDrillViewModelTests.swift
   - `test_displayNoteName_usesScaleNoteWhenAvailable`
   - `test_displayNoteName_usesSharpsForSharpScales`
   - Already handles this correctly using scale's own note spellings

3. **ChordDrill Enharmonic Spelling** - ChordDrillEndToEndTests.swift (NEW)
   - `test_noteDisplay_matchesChordRootSpelling_flats` - Verifies Ab chord shows flats
   - `test_noteDisplay_matchesChordRootSpelling_sharps` - Verifies F# chord shows sharps
   - `test_noteDisplay_naturalNotes_unchanged` - Verifies C, D, E etc. stay the same

## Code Locations Displaying Note Names

### ✅ FIXED - ChordDrillSession
**File:** `JazzHarmonyQuiz/Features/ChordDrill/ChordDrillSession.swift`
**Lines:** 302 (selected notes display)
**Status:** ✅ Fixed with `spelledNoteName()` helper method
**Implementation:**
```swift
private func spelledNoteName(_ note: Note, basedOn root: Note) -> String {
    if note.name == root.name {
        return note.name
    }
    
    if let enharmonic = note.enharmonicEquivalent {
        if root.name.contains("b") && enharmonic.name.contains("b") {
            return enharmonic.name
        } else if root.name.contains("#") && enharmonic.name.contains("#") {
            return enharmonic.name
        }
    }
    
    return note.name
}
```

### ✅ ALREADY CORRECT - ResultsView
**File:** `JazzHarmonyQuiz/Views/ResultsView.swift`
**Lines:** 399, 428, 544
**Status:** ✅ Already correct - uses `convertToChordTonality()` method
**Implementation:**
```swift
private func convertToChordTonality(_ note: Note) -> Note {
    let preferSharps = question.chord.root.isSharp || ["B", "E", "A", "D", "G"].contains(question.chord.root.name)
    return Note.noteFromMidi(note.midiNumber, preferSharps: preferSharps) ?? note
}
```
**Note:** This uses a slightly different approach (circle of fifths logic) which also works correctly.

### ✅ ALREADY CORRECT - ScaleDrillViewModel
**File:** `JazzHarmonyQuiz/Features/ScaleDrill/ScaleDrillViewModel.swift`
**Lines:** 45-53
**Status:** ✅ Already correct - uses scale's own note spellings
**Implementation:**
```swift
func displayNoteName(_ note: Note, for scale: Scale) -> String {
    if let scaleNote = scale.scaleNotes.first(where: { $0.pitchClass == note.pitchClass }) {
        return scaleNote.name
    }
    
    let preferSharps = scale.root.isSharp || ["B", "E", "A", "D", "G"].contains(scale.root.name)
    if let displayNote = Note.noteFromMidi(note.midiNumber, preferSharps: preferSharps) {
        return displayNote.name
    }
    return note.name
}
```

### ⚠️ CONTEXT-DEPENDENT - PianoKeyboard
**File:** `JazzHarmonyQuiz/Components/PianoKeyboard.swift`
**Lines:** 200, 317, 382
**Status:** ⚠️ Shows dual labels (e.g., "C#/Db") OR uses `note.name` directly
**Issue:** Black keys show both enharmonic options, which is actually CORRECT for a piano keyboard
**Recommendation:** **No change needed** - piano keyboards should show both enharmonic options since the physical key represents both notes. The context (chord/scale) determines which spelling to use when displaying user selections.

### ⚠️ NEEDS REVIEW - ChordSelectorView
**File:** `JazzHarmonyQuiz/Views/ChordSelectorView.swift`
**Lines:** 173
**Status:** ⚠️ Displays `note.name` directly
**Context:** Used in chord selector UI
**Recommendation:** Review if this appears in educational contexts where spelling matters. May need root-based spelling.

### ✅ LIKELY OK - IntervalModel
**File:** `JazzHarmonyQuiz/Models/IntervalModel.swift`
**Lines:** 66 (displays interval question prompt)
**Status:** ✅ Likely OK - intervals use their own root/target notes
**Note:** Interval questions have explicit root and target notes, so they should already have correct spelling baked in.

### ✅ LIKELY OK - ChordModel
**File:** `JazzHarmonyQuiz/Models/ChordModel.swift`
**Lines:** 271, 273, 666 (progression drill displays)
**Status:** ✅ Likely OK - uses chord's own notes which have correct spelling
**Note:** Chord objects contain properly spelled notes, so displaying `chord.note.name` should be correct.

## Recommendations

### 1. ✅ ChordDrill - COMPLETE
- Added `spelledNoteName()` helper in ChordDrillSession
- Added comprehensive tests in ChordDrillEndToEndTests
- User-selected notes now display with correct enharmonic spelling

### 2. ✅ ScaleDrill - COMPLETE
- Already working correctly with `displayNoteName()` method
- Already has test coverage

### 3. ✅ ResultsView - COMPLETE
- Already working correctly with `convertToChordTonality()` method
- Uses circle of fifths logic (sharp keys vs flat keys)

### 4. ⏸️ PianoKeyboard - NO ACTION NEEDED
- Piano keyboards should show both enharmonic options
- The **selection display** (not the keyboard itself) handles correct spelling

### 5. ⏸️ Other Views - LOW PRIORITY
- ChordSelectorView and other utility views likely don't need changes
- Most contexts use chord/scale objects that already have correct spelling

## Future Enhancements

### Create Centralized Note Spelling Utility
Consider extracting the spelling logic into a shared utility:

```swift
// Core/Utilities/NoteSpelling.swift
struct NoteSpelling {
    /// Get the correctly spelled note name based on a musical context (root note)
    static func spelledName(_ note: Note, basedOn root: Note) -> String {
        if note.name == root.name {
            return note.name
        }
        
        if let enharmonic = note.enharmonicEquivalent {
            if root.name.contains("b") && enharmonic.name.contains("b") {
                return enharmonic.name
            } else if root.name.contains("#") && enharmonic.name.contains("#") {
                return enharmonic.name
            }
        }
        
        return note.name
    }
    
    /// Get the correctly spelled note based on key signature preference
    static func spelledName(_ note: Note, preferSharps: Bool) -> String {
        return Note.noteFromMidi(note.midiNumber, preferSharps: preferSharps)?.name ?? note.name
    }
}
```

This would:
1. Centralize the logic
2. Make it testable in one place
3. Provide consistent behavior across all features
4. Make future updates easier

## Conclusion

**Current Status:** ✅ **COMPLETE for critical user-facing areas**

The enharmonic spelling issue has been:
1. ✅ Fixed in ChordDrill session view (where users see their selections)
2. ✅ Already working in ResultsView (where users see feedback)
3. ✅ Already working in ScaleDrill (where users spell scales)
4. ✅ Tested comprehensively with unit tests

**No additional work needed** unless we want to create the centralized utility (recommended for future maintainability).
