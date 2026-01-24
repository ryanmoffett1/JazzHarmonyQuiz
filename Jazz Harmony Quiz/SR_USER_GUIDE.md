# How to Use the Spaced Repetition System

**Last Updated:** January 23, 2026

---

## What is Spaced Repetition?

Spaced Repetition (SR) is a learning technique that schedules reviews of material at increasing intervals. Instead of randomly practicing chords you already know, the app automatically:

- **Resurfaces items you got wrong** — bringing them back sooner
- **Spaces out items you mastered** — reviewing them less frequently
- **Optimizes your practice time** — focusing on what you need most

This is based on the **SuperMemo SM-2 algorithm**, proven to maximize long-term retention.

---

## How It Works Automatically

### 1. **Every Quiz Builds Your Review Queue**

When you complete any quiz (chord, cadence, scale, or interval drill), the app automatically tracks each question as an SR item:

**Example:** You complete a chord drill with these questions:
- Cmaj7 (single tone - 7th) → **Correct** ✅
- F#m7b5 (all tones) → **Incorrect** ❌
- Bbmaj9 (single tone - 9th) → **Correct** ✅

**What happens behind the scenes:**
```
Cmaj7 - 7th → Scheduled for review in 6 days
F#m7b5 - all tones → Scheduled for review in 1 day (tomorrow!)
Bbmaj9 - 9th → Scheduled for review in 6 days
```

### 2. **Items You Master Space Out Further**

Each time you answer correctly, the interval grows exponentially:

| Repetition | Correct Answer → Next Review |
|------------|------------------------------|
| 1st time   | 1 day later                  |
| 2nd time   | 6 days later                 |
| 3rd time   | ~15 days later               |
| 4th time   | ~36 days later               |
| 5th time   | ~90 days later               |

**Wrong answers reset the item back to 1 day.**

### 3. **Your Practice Due Queue Grows**

The next day, items are "due for review" and appear in the **Practice Due** card on the home screen.

---

## Using the Practice Due Card

### **On the Home Screen**

After your first quiz, you'll see a new card appear between your stats and quick actions:

```
┌─────────────────────────────────────┐
│ 🕐 Practice Due                     │
│ 12 items ready to review            │
│                                     │
│ 🎹 Chord Drill         5            │
│ 🔄 Cadence Drill       3            │
│ 🎼 Scale Drill         2            │
│ 👂 Interval Drill      2            │
└─────────────────────────────────────┘
```

### **What the Numbers Mean**

- **Total count:** "12 items ready to review" — how many SR items are due today
- **Per-mode breakdown:** Shows which practice modes have due items

### **When Nothing is Due**

When you're all caught up, the card shows green and displays stats:

```
┌─────────────────────────────────────┐
│ ✅ Practice Due                     │
│ All caught up!                      │
│                                     │
│ Total Items: 47    Avg Accuracy: 82%│
│                                     │
│ New: 12  Learning: 18              │
│ Young: 10  Mature: 7                │
└─────────────────────────────────────┘
```

**Maturity Levels:**
- **New:** Never reviewed (< 1 day interval)
- **Learning:** Reviewed 1-2 times (< 7 day interval)
- **Young:** Getting there (7-21 day interval)
- **Mature:** Mastered! (21+ day interval)

---

## How to Practice Due Items

### **Current Workflow** (Phase 1)

Right now, tapping the "Practice Due" card launches Quick Practice. This will practice a mix of items, including some due items.

### **Recommended Workflow**

1. **Check the Practice Due card each day** — see what needs review
2. **Tap a specific drill mode** (Chord, Cadence, Scale, or Interval)
3. **Start a quiz** — the app will naturally include due items in the mix
4. **Complete the quiz** — SR automatically updates schedules

### **Coming Soon** (Phase 1 completion)

A dedicated "Practice Due" mode that:
- Pulls **only** items from your due queue
- Mixes modes (chord + cadence + scale in one session)
- Shows "X items remaining" progress
- Automatically marks items as reviewed

---

## Understanding the Scheduling

### **Speed Matters**

The app tracks how fast you answer each question:

| Response Time | Quality Score | Effect on Interval |
|---------------|---------------|-------------------|
| < 2 seconds   | Perfect (5)   | Maximum growth    |
| 2-5 seconds   | Good (4)      | Strong growth     |
| 5-10 seconds  | Okay (3)      | Moderate growth   |
| 10-20 seconds | Hard (2.5)    | Slower growth     |
| 20+ seconds   | Very Hard (2) | Minimal growth    |

**Fast correct answers = longer intervals = less drilling needed.**

### **Ease Factor (Hidden)**

Each item has an "ease factor" (1.3 to 3.0) that adjusts how quickly intervals grow:

- **Start:** 2.5 (default)
- **Fast correct answers:** Ease increases → intervals grow faster
- **Slow/incorrect answers:** Ease decreases → intervals grow slower

This means items you consistently nail quickly will fade away, while challenging items stick around.

---

## Practical Examples

### **Scenario 1: Learning a New Chord Type**

**Day 1:** You drill altered dominants (7b9, 7#9, 7b5, etc.)
- All 5 chord types are new
- You get 3 correct, 2 wrong
- **Result:** 2 chords scheduled for tomorrow, 3 for 6 days from now

**Day 2:** Practice Due shows "2 items"
- You re-drill the 2 you missed yesterday
- You get them both correct this time
- **Result:** Both scheduled for 6 days from now

**Day 7:** Practice Due shows "5 items" (all your altered dominants)
- You drill all 5
- You get 4 correct, 1 wrong
- **Result:** 1 chord scheduled for tomorrow, 4 for ~15 days

**Day 22:** Practice Due shows "4 items"
- You nail all 4 altered dominants quickly
- **Result:** All scheduled for ~36 days

**Day 58:** Practice Due shows "4 items"
- You still remember them!
- **Result:** Now scheduled for ~90 days

**→ You've converted "new and shaky" into "long-term memory" in 2 months.**

---

### **Scenario 2: Targeting Weak Keys**

**Problem:** You're great at C, F, G but struggle with F#, Db, Ab

**What SR does:**
- F# major ii-V-I → you miss it → **scheduled for tomorrow**
- C major ii-V-I → you nail it → **scheduled for 6 days**
- Db major ii-V-I → you miss it → **scheduled for tomorrow**
- Ab major ii-V-I → you get it slowly → **scheduled for 3 days**

**After 2 weeks:**
- You've drilled F#, Db, Ab **5-7 times each**
- You've drilled C, F, G **only 2 times each**
- Result: Your weak keys improve, strong keys stay sharp with minimal effort

---

## Best Practices

### **1. Practice Daily (Even Just 5 Minutes)**

SR works best with consistency:
- **Ideal:** Practice due items every day
- **Good:** Practice 4+ days per week
- **Minimum:** Practice 2-3 days per week

**Why:** Intervals are tuned for daily review. Skipping days causes items to pile up.

### **2. Check the Practice Due Card First**

Make it part of your routine:
1. Open app
2. Check Practice Due count
3. If items are due → prioritize those
4. If caught up → practice new material or weak areas

### **3. Trust the System**

Don't manually re-drill items the app hasn't surfaced:
- ❌ "I should practice all my diminished chords again"
- ✅ "The app will bring them back when I'm about to forget"

The algorithm is tuned to catch you **just before** you'd forget, maximizing retention.

### **4. Mix Modes**

The SR queue tracks items across all 4 modes:
- Don't just drill chords every day
- Rotate through cadences, scales, intervals
- Let the Practice Due card guide your variety

---

## Monitoring Your Progress

### **Via the Practice Due Card**

Watch your maturity levels shift over weeks:

**Week 1:**
- New: 40, Learning: 5, Young: 0, Mature: 0

**Week 4:**
- New: 10, Learning: 25, Young: 10, Mature: 5

**Week 12:**
- New: 5, Learning: 15, Young: 20, Mature: 30

**Goal:** Most items in "Young" or "Mature" = efficient practice.

### **Via Your Stats**

The app also tracks (in PlayerProfile and per-mode stats):
- Total questions answered
- Accuracy percentage
- Time spent practicing
- XP and rank progression

**SR amplifies these by focusing your time on high-impact items.**

---

## Troubleshooting

### **"My Practice Due count is overwhelming (50+ items)"**

**Cause:** You took a break or practiced a lot of new material quickly.

**Fix:**
- Do **multiple short sessions** per day (10 items each)
- Don't try to clear it all at once
- The queue will stabilize in 3-4 days

### **"I keep getting the same items over and over"**

**Cause:** You're missing them repeatedly, resetting them to 1 day.

**Solution:**
- Use hints (in cadence mode)
- Slow down and think through the answer
- Review the explanation in the results screen
- Once you get it right 2-3 times, it will space out

### **"Nothing shows as due for days"**

**Cause:** You've mastered everything recently drilled!

**This is good!** It means:
- Your practice was effective
- Items are in long-term memory
- You can focus on new material

**What to do:**
- Practice new difficulty levels
- Try different question types
- Explore weak areas (app suggests them)

---

## Advanced: Under the Hood

### **What Gets Tracked as an SR Item**

Every SR item has a unique ID:

**SRItemID Structure:**
```swift
mode: .chordDrill / .cadenceDrill / .scaleDrill / .intervalDrill
topic: chord symbol / cadence type / scale name / interval name
key: root note (C, F#, Bb, etc.)
variant: question type variant
```

**Examples:**

| Quiz Question | SR Item |
|---------------|---------|
| "What is the 7th of Cmaj7?" | mode: chord, topic: "maj7", key: "C", variant: "single-7th" |
| "Spell F# minor ii-V-i" | mode: cadence, topic: "minor", key: "F#", variant: "full" |
| "Play all notes in G Dorian" | mode: scale, topic: "dorian", key: "G", variant: "all-degrees" |
| "Build a major 6th above A" | mode: interval, topic: "M6", key: "A", variant: "build" |

This means the app tracks **very specific** practice items, not just "chords in general."

### **Storage**

All schedules are stored in **UserDefaults** as JSON.

**Location:** 
- Key: `"SpacedRepetitionSchedules"`
- Format: Dictionary of `[SRItemID: SRSchedule]`

**Data persists across:**
- App restarts
- iOS updates
- Device backups (via iCloud if enabled)

**Migration:** If you switch devices, SR data transfers via iCloud backup.

---

## FAQ

### **Q: Can I reset my SR queue?**
**A:** Not yet via UI. Coming in a future update. For now, it's automatic.

### **Q: Can I manually mark an item as "mastered"?**
**A:** Not yet. The algorithm decides based on your performance.

### **Q: What happens if I don't practice for a week?**
**A:** Items pile up as "due." When you return, prioritize the oldest/most overdue items first (they're at risk of being forgotten).

### **Q: Does SR replace my regular practice?**
**A:** No! SR is for **review and retention**. You still need to:
- Learn new material (new chord types, keys, concepts)
- Practice weak areas (suggested by the app)
- Do daily challenges and streaks

**SR ensures what you've learned sticks.**

### **Q: Can I practice items that aren't due yet?**
**A:** Yes! Regular quizzes include both due and non-due items. SR just guides **priority**, it doesn't restrict practice.

---

## Summary: Quick Start Guide

1. **Complete any quiz** (chord, cadence, scale, interval) → SR tracking starts automatically
2. **Check home screen next day** → See "Practice Due" card with count
3. **Practice regularly** → Due items resurface, mastered items fade
4. **Watch maturity levels grow** → New → Learning → Young → Mature
5. **Trust the algorithm** → It brings back items just before you'd forget them

**That's it!** You don't need to do anything special. Just practice normally, and SR optimizes your retention in the background. 🎉

---

## Coming Soon (Phase 1 Completion)

- **Dedicated "Practice Due" mode** — quiz that pulls only from SR queue
- **Badge indicators** — show due count on each drill button
- **SR insights screen** — detailed stats, hardest items, calendar view
- **Manual controls** — reset items, adjust due dates, bulk operations

---

**Questions?** The SR system is designed to be invisible but powerful. Just keep practicing, and it works behind the scenes! 🚀
