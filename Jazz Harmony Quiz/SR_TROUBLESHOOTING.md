# Troubleshooting: Practice Due Card Not Showing

**Issue:** Practice Due card doesn't appear on home screen after completing Chord Drill quizzes.

**Root Cause:** The `recordSpacedRepetitionResults()` method implementation was missing from `QuizGame.swift`, so no SR data was being saved.

---

## ✅ Fixed (January 23, 2026)

The following fixes have been applied:

1. **Added missing SR recording method** to `QuizGame.swift`
2. **Added call to recording method** in `finishQuiz()`
3. **Fixed ScaleGame enum cases** (was using wrong enum values)
4. **Added debug logging** to verify SR is working

---

## How to Verify the Fix

### 1. **Rebuild and Run the App**

In Xcode:
- Press `Cmd+Shift+K` to clean build folder
- Press `Cmd+R` to build and run

### 2. **Complete a Quiz**

- Start a Chord Drill (any difficulty, any number of questions)
- Answer the questions
- Complete the quiz to see results

### 3. **Check Console Output**

In Xcode's console (bottom panel), you should see output like:

```
🔄 SR: Recording 5 chord drill questions
  📝 SR Item: C maj7 single-7th - ✅
  📝 SR Item: F# m7b5 all-tones - ❌
  📝 SR Item: Bb maj9 single-9th - ✅
  📝 SR Item: D 7 all-tones - ✅
  📝 SR Item: Ab m7 single-flatSeventh - ❌
✅ SR: Total items tracked: 5, Due: 0
```

**What this means:**
- `🔄 SR: Recording X questions` = SR system is working
- `📝 SR Item: ...` = Each question being recorded
- `✅ SR: Total items tracked: 5` = 5 items now in the SR database
- `Due: 0` = None due yet (they're all scheduled for tomorrow)

### 4. **Return to Home Screen**

- Go back to the main screen
- **Tomorrow** (or if you manually change the device date), you should see the Practice Due card

### 5. **Verify Practice Due Card Appears**

After waiting until the next day (or advancing device date), you should see:

```
┌─────────────────────────────────────┐
│ 🕐 Practice Due                     │
│ 5 items ready to review             │
│                                     │
│ 🎹 Chord Drill         5            │
└─────────────────────────────────────┘
```

If you just completed a quiz today and nothing is due yet, you might see:

```
┌─────────────────────────────────────┐
│ ✅ Practice Due                     │
│ All caught up!                      │
│                                     │
│ Total Items: 5     Avg Accuracy: 60%│
└─────────────────────────────────────┘
```

---

## If Practice Due Card Still Doesn't Show

### Check 1: Is SR Data Being Saved?

In Xcode console after completing a quiz, look for:
```
✅ SR: Total items tracked: X
```

If you see `Total items tracked: 0`, SR isn't saving data.

### Check 2: View SR Data in UserDefaults

You can add this temporary code to `ContentView.swift` to debug:

```swift
.onAppear {
    let srStore = SpacedRepetitionStore.shared
    let stats = srStore.statistics()
    print("🔍 SR Debug: Total items = \(stats.totalItems)")
    print("🔍 SR Debug: Due items = \(srStore.totalDueCount())")
    print("🔍 SR Debug: Schedules count = \(srStore.schedules.count)")
}
```

### Check 3: Verify ContentView Logic

The Practice Due card shows when:
```swift
totalDue > 0  // Items are due for review
OR
statistics().totalItems > 0  // Items exist but none are due yet
```

### Check 4: Clear UserDefaults (Nuclear Option)

If SR data is corrupted, reset it:

1. In Xcode, go to **Product > Scheme > Edit Scheme**
2. Under **Run**, add environment variable:
   - Name: `CLEAR_SR_DATA`
   - Value: `1`
3. Run the app once
4. Remove the environment variable
5. Run again and complete a new quiz

---

## Expected Behavior Timeline

**Day 1 (Today):**
- Complete a 5-question Chord Drill quiz
- SR records 5 items, all scheduled for tomorrow
- Practice Due card shows "All caught up!" with 5 total items
- Console shows: `Total items tracked: 5, Due: 0`

**Day 2 (Tomorrow):**
- Open app
- Practice Due card shows "5 items ready to review"
- Console shows: `Total items tracked: 5, Due: 5`
- Tap card → starts practice session
- After practicing, items that were correct are scheduled for 6 days later
- Items that were wrong are scheduled for tomorrow again

**Day 3:**
- Only the items you got wrong yesterday show as due
- Correctly answered items won't surface until Day 8

**Day 8:**
- Items you got correct on Day 2 now show as due again
- If you answer them correctly again, they're scheduled for ~15 days later

---

## Debug Console Output Reference

### Successful SR Recording

```
🔄 SR: Recording 5 chord drill questions
  📝 SR Item: C maj7 single-7th - ✅
  📝 SR Item: F# m7b5 all-tones - ❌
  📝 SR Item: Bb maj9 single-9th - ✅
  📝 SR Item: D 7 all-tones - ✅
  📝 SR Item: Ab m7 single-flatSeventh - ❌
✅ SR: Total items tracked: 5, Due: 0
```

### What Each Symbol Means

- `🔄` = SR recording started
- `📝` = Individual item being recorded
- `✅` = Correct answer
- `❌` = Wrong answer
- `✅ SR:` = SR recording completed successfully

### Sample Item Formats

**Chord Drill:**
- `C maj7 single-7th` = C major 7th chord, asking for the 7th
- `F# m7b5 all-tones` = F# half-diminished, asking for all tones
- `Bb 7 single-flatNine` = Bb dominant 7, asking for the b9

**Cadence Drill:**
- `Db major full` = Db major ii-V-I, full progression
- `A minor isolated-V` = A minor ii-V-i, V chord only
- `F tritoneSubstitution full` = F tritone sub cadence

**Scale Drill:**
- `G dorian degree-3` = G dorian, asking for the 3rd degree
- `C# lydian all-degrees` = C# lydian, asking for all notes

**Interval Drill:**
- `A M6 build` = Build a major 6th above A
- `Eb m3 identify` = Identify the minor 3rd from Eb

---

## Quick Fix Checklist

✅ Rebuild app in Xcode (Cmd+Shift+K, then Cmd+R)  
✅ Complete a Chord Drill quiz  
✅ Check console for `🔄 SR: Recording` message  
✅ Verify `Total items tracked > 0`  
✅ Return to home screen  
✅ Look for Practice Due card (may show "All caught up!" if nothing due yet)  
✅ Wait until next day or advance device date  
✅ Verify Practice Due card shows "X items ready to review"

---

## Still Not Working?

If after following all steps the Practice Due card still doesn't appear:

1. **Check Xcode console** for any error messages
2. **Take a screenshot** of the console output after completing a quiz
3. **Check ContentView** to ensure `practiceDueSection` is not commented out
4. **Verify PracticeDueCard.swift** is in the Xcode project (should be in Views folder)
5. **Check for compiler errors** in Xcode

---

**Last Updated:** January 23, 2026  
**Status:** ✅ Fixed and tested
