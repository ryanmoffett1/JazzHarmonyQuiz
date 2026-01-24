# Jazz Harmony Quiz - Pedagogical Enhancement Plan

**Created:** January 19, 2026  
**Perspective:** Master jazz educator consultation  
**Goal:** Transform the app from drill-focused to comprehensive jazz pedagogy tool

---

## Executive Summary

Jazz Harmony Quiz has strong foundations in chord/scale/cadence drilling with excellent motivational infrastructure (XP, ranks, streaks, stats). However, the biggest gap is **transfer to music**: students can spell chords in isolation but struggle with ear-first recognition, functional context, voice-leading, and knowing what to practice next.

This plan prioritizes six high-ROI enhancements that bridge theory → musicality.

---

## Current State Assessment

### ✅ What's Working Well

**Cadence Mode** (the flagship feature):
- Progressive key difficulty (accidental fluency)
- Daily challenge + streaks (habit formation)
- Hints with partial credit (scaffolded learning)
- Speed rounds (retrieval under time pressure)
- Real jazz vocabulary (tritone sub, backdoor, bird changes)
- Audio playback + haptics (multi-sensory)
- Mistake re-drill + weak-key detection (adaptive practice)
- Common-tone drills (voice-leading awareness)

**Chord & Scale Drills**:
- Multiple question types (single tone, all tones, spelling)
- Comprehensive databases (beginner → expert)
- Rating system with encouraging ranks

**Infrastructure**:
- PlayerProfile with RPG-style stats
- Per-mode statistics tracking
- AudioManager for playback
- Clean SwiftUI + ObservableObject architecture

### ❌ What's Missing for Real Jazz Fluency

1. **Ear-first learning:** Everything is visual; no "hear → identify → play" loop
2. **Functional context:** Chords are drilled in isolation, not in musical roles
3. **Voice-leading fluency:** Guide tones and smooth movement are underemphasized
4. **Spaced repetition:** Random practice instead of optimal scheduling
5. **Curriculum guidance:** No clear "what should I practice next?" pathway
6. **Conceptual explanations:** Missed answers don't explain *why* that chord exists

---

## Phase 1: Spaced Repetition System (Highest ROI)

### Pedagogical Rationale
Jazz harmony is 80% memory + recall speed. Spaced repetition (SR) converts random drilling into reliable long-term retention. Without SR, students keep drilling what they're comfortable with instead of what they need.

### Implementation

#### 1.1 Data Model
Create `Models/SpacedRepetition.swift`:

```swift
// SR item identifier (works across all modes)
struct SRItemID: Hashable, Codable {
    let mode: PracticeMode
    let topic: String      // chord symbol, scale name, cadence type, interval
    let key: String?       // optional root note/key
    let variant: String?   // optional (e.g., "V7b9", "ascending", etc.)
}

// SR schedule using simplified SM-2 algorithm
struct SRSchedule: Codable {
    var easeFactor: Double = 2.5
    var intervalDays: Double = 1.0
    var repetitions: Int = 0
    var dueDate: Date
    var lastReviewedDate: Date?
    var lastResultWasCorrect: Bool = false
}

// SR store (ObservableObject)
class SpacedRepetitionStore: ObservableObject {
    @Published var schedules: [SRItemID: SRSchedule] = [:]
    
    func dueItems(for date: Date = Date()) -> [SRItemID]
    func recordResult(itemID: SRItemID, wasCorrect: Bool, responseTime: TimeInterval)
    func resetItem(_ itemID: SRItemID)
    
    // Persistence
    func save()
    func load()
}
```

#### 1.2 Integration Points
- Hook `recordResult()` at the end of each quiz completion:
  - `CadenceGame.finishQuiz()` → record each cadence/key combo
  - `QuizGame.checkAnswer()` → record each chord
  - `ScaleGame.finishQuiz()` → record each scale/key
  - `IntervalGame.finishQuiz()` → record each interval

#### 1.3 UI Changes
- Add **"Practice Due"** card to `ContentView.swift`:
  - Shows count: "12 items due: 5 chords, 3 cadences, 2 scales, 2 intervals"
  - Tapping starts a mixed drill session from due items
- Add "Due count" badge to each mode button
- Show SR status in results: "This item next due in 3 days"

### Success Metrics
- Students see measurably better retention after 2 weeks
- "Practice Due" becomes the primary entry point (>50% of sessions)
- Weak items resurface automatically without manual tracking

---

## Phase 2: Ear Training Integration

### Pedagogical Rationale
Jazz is heard before it's analyzed. Students who can spell V7♭9 but can't *recognize* it by ear will struggle on gigs. Ear-first modes create the crucial "sound → symbol → structure" connection.

### Implementation

#### 2.1 Interval Ear Training (already planned)
- Implement `IntervalQuestionType.aurally` from `INTERVAL_DRILL_PLAN.md`
- "Hear two notes → identify interval" (harmonic & melodic)
- Use `AudioManager` with configurable playback styles:
  - Melodic ascending/descending
  - Harmonic (simultaneous)
  - Tempo control

#### 2.2 Chord Ear Training
Extend `ChordDrillView` with ear mode:

```swift
enum ChordDrillMode {
    case visual        // Current: see symbol, spell it
    case aurally       // Hear chord, identify quality OR spell tones
    case callResponse  // Hear chord, play it back on keyboard
}
```

**Question types:**
- Hear chord → Choose quality (multiple choice: maj7, m7, 7, m7♭5, etc.)
- Hear chord → Spell all tones on keyboard
- Hear chord → Identify specific extension (hear Cmaj9 → "what's the 9th?")

**Playback styles:**
- Block chord (all notes at once)
- Arpeggio up/down
- Guide tones only (3rd & 7th)

#### 2.3 Cadence Ear Training
Add to `CadenceGame`:

```swift
@Published var earTrainingEnabled: Bool = false
```

**Workflow:**
1. Play progression audio first (ii → V → I)
2. Student identifies cadence type (major/minor/tritone/backdoor/bird)
3. Then spell each chord (or just the altered one)

**Advanced variant:**
- Play progression but mute one chord
- Student fills in the missing chord

### Success Metrics
- Students can identify intervals by ear at 70%+ accuracy
- Chord quality recognition reaches 60%+ (this is genuinely hard)
- Students report "recognizing changes in songs" (qualitative)

---

## Phase 3: Functional Progression Drills

### Pedagogical Rationale
ii–V–I is necessary but not sufficient. Real jazz uses turnarounds, rhythm changes, secondary dominants, and minor-key movements. Students need pattern fluency over complete *musical phrases*, not isolated cadences.

### Implementation

#### 3.1 Data Model
Create `Models/ProgressionDatabase.swift`:

```swift
struct ProgressionTemplate: Identifiable, Codable {
    let id: UUID
    let name: String
    let description: String
    let chords: [FunctionalChordSpec]
    let difficulty: Difficulty
    let category: ProgressionCategory
}

struct FunctionalChordSpec: Codable {
    let function: RomanNumeral  // I, ii, V, VI, etc.
    let quality: ChordQuality   // maj7, m7, 7, m7♭5, dim7
    let alterations: [ChordTone]? // optional [.flatNine, .sharpEleven]
    let duration: Int  // bars (for rhythm/form awareness)
}

enum ProgressionCategory: String, CaseIterable {
    case turnarounds = "Turnarounds"
    case rhythmChanges = "Rhythm Changes"
    case standards = "Standard Progressions"
    case minorKey = "Minor Key Progressions"
    case diatonicHarmony = "Diatonic Harmony"
    case secondaryDominants = "Secondary Dominants"
}
```

#### 3.2 Progression Templates (Priority Order)

**Phase 1 - Turnarounds:**
- I–vi–ii–V (basic)
- I–VI7–ii–V (with secondary dominant)
- I–I7–IV–iv (chromatic approach)
- Minor turnaround: i–viø7–iiø7–V7alt

**Phase 2 - Rhythm Changes:**
- A section: I–VI7–ii–V (in multiple keys)
- Bridge: III7–VI7–II7–V7 (cycle of dominants)

**Phase 3 - Standards Fragments:**
- "Autumn Leaves" progression (bars 1-8)
- "All The Things You Are" modulation
- Blues with jazz substitutions

**Phase 4 - Diatonic Harmony:**
- All diatonic 7ths in a major key (Imaj7, iim7, iiim7, IVmaj7, V7, vim7, viiø7)
- "Harmonize the major scale" drill
- Same for harmonic/melodic minor

#### 3.3 Game Logic
Create `Models/ProgressionGame.swift` (pattern after `CadenceGame`):

```swift
@MainActor
class ProgressionGame: ObservableObject {
    @Published var currentProgression: ProgressionQuestion?
    @Published var currentChordIndex: Int = 0
    @Published var userAnswers: [[Note]] = []
    // ...similar to CadenceGame
}
```

#### 3.4 View
Create `Views/ProgressionDrillView.swift`:
- Shows full progression with current chord highlighted
- Reuses `PianoKeyboard` for input
- Shows bar numbers and chord durations
- Audio plays the full progression, then isolates each chord

### Success Metrics
- Students can spell full turnarounds at 80%+ accuracy
- Rhythm changes A section becomes automatic
- Students report "recognizing these in songs"

---

## Phase 4: Guide Tone & Voice-Leading Drills

### Pedagogical Rationale
Guide tones (3rds & 7ths) are the secret to jazz comping and understanding function. When a student knows that the 3rd of V7 resolves to the 7th of Imaj7, harmony stops being abstract symbols and becomes *motion*.

### Implementation

#### 4.1 Extend Common Tone Mode
Current `CadenceGame` has `commonTones` mode—expand it:

```swift
enum VoiceLeadingQuestionType {
    case commonTones       // Current: find shared notes
    case guideTones        // NEW: play only 3rd & 7th of each chord
    case resolutionTargets // NEW: "where does the 7th of V7 resolve?"
    case smoothVoicing     // NEW: minimal motion between chords
}
```

**Example drills:**
- "Play the guide tones (3 & 7) for this ii–V–I"
- "The 3rd of Dm7 is F. Where does it move in G7?"
- "Find the common tone between G7 and Cmaj7"
- "Voice Cmaj7 so the top note moves by half-step to Fmaj7"

#### 4.2 Visual Feedback
Enhance `PianoKeyboard`:
- Show "ghost notes" for previous chord to visualize movement
- Color-code guide tones vs extensions
- Animate resolution (3→7 movement)

#### 4.3 Guide Tone Line Builder
Advanced drill: given a progression, build the smoothest soprano guide-tone line

**Example:**
- Dm7 → G7 → Cmaj7
- Student plays: F (3rd of Dm7) → F (7th of G7) → E (3rd of Cmaj7)
- App validates smoothness + correctness

### Success Metrics
- Students can isolate guide tones at 80%+ accuracy
- Resolution targets become automatic (V7→I, ii7→V7)
- Students report "hearing the voice leading in songs"

---

## Phase 5: Guided Curriculum ("What Should I Practice Next?")

### Pedagogical Rationale
Students don't fail from lack of content—they fail from lack of *sequence*. A clear learning pathway prevents overwhelm and builds confidence through progressive mastery.

### Implementation

#### 5.1 Data Model
Create `Models/CurriculumModule.swift`:

```swift
struct CurriculumModule: Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String
    let emoji: String
    let pathway: CurriculumPathway
    let level: Int  // order in pathway
    
    let mode: PracticeMode
    let recommendedConfig: ModuleConfig  // drill settings
    
    let prerequisiteModuleIDs: [UUID]
    let completionCriteria: CompletionCriteria
    
    var isUnlocked: Bool  // computed from prerequisites
    var isCompleted: Bool  // computed from stats
    var progress: Double  // 0.0 to 1.0
}

enum CurriculumPathway: String, CaseIterable {
    case harmonyFoundations = "Harmony Foundations"
    case functionalHarmony = "Functional Harmony"
    case earTraining = "Ear Training"
    case advancedSubstitutions = "Advanced Substitutions"
}

struct CompletionCriteria: Codable {
    let accuracyThreshold: Double  // e.g., 0.90
    let minimumAttempts: Int       // e.g., 30 questions
    let perfectSessions: Int?      // optional: require X perfect sessions
    let srMastery: Bool            // optional: SR items must be "mature"
}
```

#### 5.2 Example Pathway: "Harmony Foundations"

**Level 1: Triads (Beginner)**
- Module 1.1: Major & minor triads in C, F, G
- Module 1.2: Diminished & augmented triads in easy keys
- Module 1.3: All triads in all keys

**Level 2: 7th Chords (Beginner → Intermediate)**
- Module 2.1: maj7, m7, 7 in easy keys
- Module 2.2: m7♭5, dim7 in medium keys
- Module 2.3: All basic 7ths in all keys

**Level 3: Functional Cadences (Intermediate)**
- Module 3.1: Major ii–V–I in all keys
- Module 3.2: Minor ii–V–i with V7♭9
- Module 3.3: Tritone substitution cadences

**Level 4: Extensions (Intermediate → Advanced)**
- Module 4.1: 9th chords (maj9, m9, 9)
- Module 4.2: Altered dominants (♭9, ♯9, ♭5, ♯5)
- Module 4.3: 11th and 13th chords

**Level 5: Progressions (Advanced)**
- Module 5.1: Turnarounds
- Module 5.2: Rhythm changes
- Module 5.3: Standard fragments

**Level 6: Voice Leading (Advanced)**
- Module 6.1: Guide tones
- Module 6.2: Common tones
- Module 6.3: Smooth voicing

#### 5.3 UI
Create `Views/CurriculumView.swift`:
- Tab/section in `ContentView`
- Shows pathways as vertical timelines
- Modules appear as cards with:
  - Lock icon (if locked)
  - Progress bar
  - Checkmark (if completed)
  - "Start" or "Continue" button
- Tapping a module auto-configures the drill with recommended settings

#### 5.4 "Recommended Next" on Home
Add to `ContentView`:
```swift
if let nextModule = CurriculumManager.shared.recommendedNextModule {
    CurriculumModuleCard(module: nextModule)
        .onTap { startModule(nextModule) }
}
```

### Success Metrics
- Students follow the pathway instead of random drilling (>60% of sessions)
- Completion rate increases (students see clear finish lines)
- Retention improves (structured learning beats random)

---

## Phase 6: Contextual Micro-Lessons ("Explain Why")

### Pedagogical Rationale
When a student misses V7♭9 in minor, they often missed the *concept*, not the spelling. A tiny explanation at the point of failure fixes mental models, not just surface errors.

### Implementation

#### 6.1 Data Model
Create `Models/ConceptLibrary.swift`:

```swift
struct ConceptBlurb: Identifiable, Codable {
    let id: UUID
    let title: String
    let explanation: String
    let relatedItems: [SRItemID]
    let category: ConceptCategory
}

enum ConceptCategory: String, CaseIterable {
    case chordFunction = "Chord Function"
    case voiceLeading = "Voice Leading"
    case alterations = "Alterations"
    case substitutions = "Substitutions"
    case scaleChoices = "Scale Choices"
}
```

#### 6.2 Example Blurbs

**V7♭9 in Minor:**
```
Title: "Why V7♭9 in minor?"
Explanation: "In minor keys, V7♭9 comes from harmonic minor. The ♭9 creates 
a half-step resolution to the root of i, increasing the pull. This is the 
standard dominant sound in jazz minor."
Related: [V7♭9 in all minor keys, harmonic minor scale]
```

**Backdoor Cadence:**
```
Title: "The Backdoor Resolution"
Explanation: "The ♭VII7 → Imaj7 cadence (e.g., B♭7 → Cmaj7) borrows from 
parallel minor. The ♭VII7 contains the ♭7 scale degree, which resolves down 
to the major 3rd of I. Common in standards like 'Ladybird.'"
Related: [backdoor cadences in all keys, parallel minor borrowing]
```

**Guide Tones:**
```
Title: "Guide Tones Define Function"
Explanation: "The 3rd and 7th of a chord define its quality and function. 
In V7 → Imaj7, the 7th (F in G7) resolves down to the 3rd (E in Cmaj7). 
This is the strongest voice-leading move in jazz."
Related: [guide tone drills, ii–V–I voice leading]
```

#### 6.3 Integration
- Add to `ResultsView.swift`:
  ```swift
  if let blurb = ConceptLibrary.shared.blurbForMissedItem(itemID) {
      ConceptCard(blurb: blurb)
          .padding()
  }
  ```
- Add "Try Again" button that starts a short drill on that concept
- Track which blurbs have been read (unlock achievements)

### Success Metrics
- Students read >50% of shown blurbs
- "Try Again" after reading shows improved accuracy
- Students report "understanding *why* not just *what*"

---

## Implementation Priority & Sequencing

### Phase 1 (Weeks 1-2): Foundation
**Goal:** SR infrastructure + first ear mode
1. Build `SpacedRepetition.swift` data model + store
2. Hook SR recording into `CadenceGame` (easiest integration)
3. Add "Practice Due" card to `ContentView`
4. Implement interval ear training (already planned)
5. Test with real usage for 1 week

### Phase 2 (Weeks 3-4): Expand Ear Training
**Goal:** Chord + cadence ear modes
6. Add chord ear training (hear → identify quality)
7. Add cadence ear training (hear → identify type)
8. Refine audio playback styles (block, arpeggio, guide tones)
9. Extend SR to chord/scale/interval modes

### Phase 3 (Weeks 5-6): Progressions
**Goal:** Move beyond isolated cadences
10. Build `ProgressionDatabase.swift` with turnaround templates
11. Create `ProgressionGame.swift` (pattern after `CadenceGame`)
12. Build `ProgressionDrillView.swift`
13. Start with I–vi–ii–V, I–VI7–ii–V, minor turnarounds

### Phase 4 (Weeks 7-8): Voice Leading
**Goal:** Guide tones + smooth movement
14. Extend common-tone mode to guide-tone drills
15. Add resolution-target questions
16. Visual improvements to `PianoKeyboard` (ghost notes, colors)
17. Guide-tone line builder (advanced)

### Phase 5 (Weeks 9-10): Curriculum
**Goal:** Clear learning pathway
18. Build `CurriculumModule.swift` data model
19. Define "Harmony Foundations" pathway (6 levels)
20. Create `CurriculumView.swift` with timeline UI
21. Add "Recommended Next" to home screen
22. Hook completion tracking from stats

### Phase 6 (Weeks 11-12): Polish
**Goal:** Micro-lessons + UX refinement
23. Build `ConceptLibrary.swift` with 20-30 core blurbs
24. Integrate into `ResultsView` and review flows
25. Add "Try Again" quick drills
26. Final UX pass: accessibility, animations, haptics
27. User testing & iteration

---

## Technical Architecture Notes

### Existing Patterns to Follow
- **ObservableObject** for all game/store classes
- **UserDefaults** for persistence (migrate to files only if necessary)
- **Codable** for all data models
- **@MainActor** for game classes
- **AudioManager** singleton for playback
- **PlayerProfile** for unified stats/XP tracking

### New Files to Create
```
Models/
  SpacedRepetition.swift          // SR engine
  ProgressionDatabase.swift       // Progression templates
  ProgressionGame.swift           // Progression quiz logic
  CurriculumModule.swift          // Curriculum pathway
  ConceptLibrary.swift            // Micro-lessons

Views/
  ProgressionDrillView.swift      // Progression quiz UI
  CurriculumView.swift            // Learning pathway UI
  ConceptCard.swift               // Explanation card component
  PracticeDueCard.swift           // Home screen "due" widget

Helpers/
  SRAlgorithm.swift               // SM-2 or similar scheduling
```

### Shared Component Enhancements
- **PianoKeyboard.swift:** Add ghost notes, color-coding, animations
- **ResultsView.swift:** Add concept blurbs, "Try Again" button
- **ContentView.swift:** Add "Practice Due" card, curriculum tab
- **PlayerProfile.swift:** Track blurbs read, pathway progress

---

## Success Metrics (Overall)

### Quantitative
- **Retention:** Students still active after 30 days: >40% (from ~20%)
- **Practice frequency:** Average 4+ sessions/week (from ~2)
- **SR compliance:** >60% of sessions are "Practice Due"
- **Accuracy improvement:** Average +15% over 4 weeks for weak items
- **Curriculum completion:** >30% complete at least one pathway

### Qualitative
- Students report "recognizing chords in songs"
- Students report "understanding *why* not just *what*"
- Students report "knowing what to practice"
- App reviews mention "better than private lessons" or "finally clicked"

---

## What NOT to Add (Anti-Scope Creep)

### Avoid (for now)
- **Giant chord-scale libraries:** Wait until progressions + ear training are solid
- **Social features:** Focus on individual learning first
- **Multiple instruments (guitar/bass):** Piano is correct for harmony foundations
- **Video lessons:** Micro-lessons are faster to produce and integrate
- **AI-generated feedback:** Simple rules-based explanations are sufficient
- **Composition tools:** Stay focused on recognition, not creation

### Why Not
These are all *good ideas*, but they:
1. Don't directly address the "transfer to music" gap
2. Add complexity without proportional learning gains
3. Can be added later once core pedagogy is proven

---

## Validation Approach

### Week 4 Check-In
- Is SR driving >30% of sessions?
- Is interval ear training usable and effective?
- Are students completing more drills than before?

### Week 8 Check-In
- Are progression drills being used?
- Is chord ear training showing improvement?
- Are guide-tone drills making sense?

### Week 12 Check-In
- Is curriculum driving practice decisions?
- Are concept blurbs being read?
- Do students report improvement in real music situations?

### Pivot Triggers
- **If SR isn't used:** Make it more visible, or auto-enable
- **If ear training feels too hard:** Add more scaffolding (start with just 3 intervals)
- **If progressions confuse users:** Add more explanation, slow down tempo
- **If curriculum feels overwhelming:** Simplify to 3 pathways max

---

## Final Note: The North Star

The goal isn't "more features"—it's **"can a student use this app for 3 months and then sit in on a jam session without freezing?"**

That means:
- They can *hear* ii–V–I and *know* it's ii–V–I
- They can *spell* altered dominants without hesitation
- They *understand* why that chord exists and where it goes
- They've built the *habit* of daily practice
- They have a *clear path* from beginner to competent

Every feature in this plan serves that north star.

---

## Progress Tracking

| Phase | Feature | Status | Completed |
|-------|---------|--------|-----------|
| 1 | SR Data Model | ⬜️ Not Started | - |
| 1 | SR Integration (Cadence) | ⬜️ Not Started | - |
| 1 | Practice Due UI | ⬜️ Not Started | - |
| 1 | Interval Ear Training | ⬜️ Not Started | - |
| 2 | Chord Ear Training | ⬜️ Not Started | - |
| 2 | Cadence Ear Training | ⬜️ Not Started | - |
| 2 | SR Expansion (All Modes) | ⬜️ Not Started | - |
| 3 | Progression Database | ⬜️ Not Started | - |
| 3 | Progression Game Logic | ⬜️ Not Started | - |
| 3 | Progression Drill View | ⬜️ Not Started | - |
| 4 | Guide Tone Drills | ⬜️ Not Started | - |
| 4 | Voice Leading Visuals | ⬜️ Not Started | - |
| 5 | Curriculum Data Model | ⬜️ Not Started | - |
| 5 | Curriculum View | ⬜️ Not Started | - |
| 5 | Pathway Definition | ⬜️ Not Started | - |
| 6 | Concept Library | ⬜️ Not Started | - |
| 6 | Micro-Lesson Integration | ⬜️ Not Started | - |

---

**Last Updated:** January 19, 2026
