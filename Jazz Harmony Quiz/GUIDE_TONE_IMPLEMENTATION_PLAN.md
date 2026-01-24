# Phase 4: Guide Tone & Voice-Leading Drills - Implementation Plan

**Date:** January 24, 2026  
**Estimated Time:** 6-8 hours  
**Priority:** High (core jazz skill)

---

## Overview

Guide tones (3rds and 7ths) are the SECRET to understanding jazz harmony. When students learn that the 3rd of Dm7 (F) moves to the 7th of G7 (F), and the 7th of Dm7 (C) moves to the 3rd of G7 (B), harmony stops being abstract and becomes MOTION.

---

## What We're Building

### 1. New Drill Modes (extend CadenceDrillMode)

```swift
enum CadenceDrillMode {
    // Existing:
    case fullProgression
    case isolatedChord
    case speedRound
    case commonTones      // Find shared notes
    case auralIdentify
    case chordIdentification
    
    // NEW:
    case guideTones       // Play only 3rd & 7th of each chord
    case resolutionTargets // "Where does this note resolve?"
    case smoothVoicing    // Voice with minimal motion
}
```

### 2. Guide Tone Drill
**Goal:** Isolate the essential tones that define chord quality and function

**Question:** "Play the guide tones (3rd and 7th) for each chord"

**Example - ii-V-I in C major:**
- Dm7: Play F (3rd) and C (7th)
- G7: Play B (3rd) and F (7th)  
- Cmaj7: Play E (3rd) and B (7th)

**Visual feedback:**
- Show ii-V-I chord symbols
- Piano keyboard - only guide tones are correct answers
- Other chord tones are marked wrong
- Color code: 3rds in blue, 7ths in green

### 3. Resolution Target Drill
**Goal:** Understand how guide tones resolve between chords

**Question types:**
- "The 7th of Dm7 is C. Where does it resolve in G7?"  
  Answer: B (3rd of G7)
  
- "The 3rd of G7 is B. Where does it resolve in Cmaj7?"  
  Answer: B (7th of Cmaj7) - common tone!
  
- "Find the resolution target for the highlighted note"  
  (Shows Dm7 with C highlighted, must play B in G7)

**Variations:**
- Forward resolution (ii→V, V→I)
- Backward tracing ("This note came from where?")
- Multiple choice (easier) or keyboard input (harder)

### 4. Smooth Voicing Drill
**Goal:** Voice chords with minimal finger movement

**Question:** "Voice Cmaj7 so the top note moves by half-step to Fmaj7"

**Example:**
- Cmaj7: Play E-G-B-C (top note is C)
- Fmaj7: Should play C-E-A-B (top note is B, moved down half-step)

**Constraints:**
- All chord tones must be present
- Top voice must move by specified interval (half-step, whole-step, or stay)
- Validates smoothness score (fewer half-steps = better)

### 5. Visual Enhancements

**PianoKeyboard improvements:**
- **Ghost notes:** Show previous chord in light gray
- **Color coding:** 
  - 3rds in blue
  - 7ths in green
  - Other tones in yellow
  - Non-chord tones in red
- **Motion arrows:** Animated arrows showing resolution paths
- **Voice leading lines:** Connect notes between chords

---

## Implementation Steps

### Step 1: Extend CadenceDrillMode Enum (1 hour)

**Files to modify:**
- `Models/ChordModel.swift`

**Changes:**
```swift
enum CadenceDrillMode: String, CaseIterable, Codable, Equatable {
    // ... existing cases
    case guideTones = "Guide Tones"
    case resolutionTargets = "Resolution Targets"
    case smoothVoicing = "Smooth Voicing"
    
    var description: String {
        switch self {
        // ... existing cases
        case .guideTones:
            return "Identify and play the guide tones (3rd and 7th) for each chord"
        case .resolutionTargets:
            return "Find where guide tones resolve in the next chord"
        case .smoothVoicing:
            return "Voice chords with minimal finger movement"
        }
    }
    
    var icon: String {
        switch self {
        // ... existing cases
        case .guideTones: return "circle.hexagongrid.fill"
        case .resolutionTargets: return "arrow.triangle.branch"
        case .smoothVoicing: return "slider.horizontal.3"
        }
    }
}
```

### Step 2: Extend CadenceQuestion Model (1 hour)

**Files to modify:**
- `Models/ChordModel.swift`

**Add resolution tracking:**
```swift
struct CadenceQuestion {
    // ... existing properties
    
    // Guide tone drill properties
    var guideTonePairs: [(source: Note, target: Note?)]?  // For resolution targets
    var voicingConstraint: VoicingConstraint?             // For smooth voicing
    
    // Helper computed properties
    var allGuideTones: [Note] {
        // Returns 3rds and 7ths from all three chords
    }
    
    func guideTonesForChord(_ index: Int) -> [Note] {
        // Returns 3rd and 7th for specific chord (0=ii, 1=V, 2=I)
    }
    
    func resolutionTarget(for note: Note, fromChord: Int, toChord: Int) -> Note? {
        // Finds where a guide tone resolves
    }
}

struct VoicingConstraint: Codable {
    let topVoiceMotion: VoiceMotion  // half-step up, whole-step down, etc.
    let maxTotalMotion: Int          // semitones moved across all voices
}

enum VoiceMotion: String, Codable {
    case halfStepUp = "↑½"
    case halfStepDown = "↓½"
    case wholeStepUp = "↑1"
    case wholeStepDown = "↓1"
    case common = "="  // stays on same note
}
```

### Step 3: Update CadenceGame Logic (2 hours)

**Files to modify:**
- `Models/CadenceGame.swift`

**Generate guide tone questions:**
```swift
func generateQuestions() {
    // ... existing code
    
    if selectedDrillMode == .guideTones {
        question = CadenceQuestion(
            cadence: cadence,
            drillMode: .guideTones
        )
    } else if selectedDrillMode == .resolutionTargets {
        // Generate resolution pairs
        let pairs = generateResolutionPairs(for: cadence)
        question = CadenceQuestion(
            cadence: cadence,
            drillMode: .resolutionTargets,
            guideTonePairs: pairs
        )
    } else if selectedDrillMode == .smoothVoicing {
        let constraint = generateVoicingConstraint()
        question = CadenceQuestion(
            cadence: cadence,
            drillMode: .smoothVoicing,
            voicingConstraint: constraint
        )
    }
}

func generateResolutionPairs(for cadence: CadenceProgression) -> [(Note, Note?)] {
    // Create pairs of guide tones and their resolution targets
    // Example: [(F from Dm7, B in G7), (C from Dm7, B in G7)]
}

func checkGuideToneAnswer(userNotes: [Note], chordIndex: Int) -> Bool {
    // Validate user played ONLY 3rd and 7th for specific chord
}

func checkResolutionAnswer(sourceNote: Note, targetNote: Note, fromChord: Int, toChord: Int) -> Bool {
    // Validate correct resolution target
}

func checkSmoothVoicing(userVoicing: [Note], constraint: VoicingConstraint) -> (isValid: Bool, smoothnessScore: Int) {
    // Check if voicing meets constraint and calculate motion
}
```

### Step 4: Update CadenceDrillView UI (2 hours)

**Files to modify:**
- `Views/CadenceDrillView.swift`

**Add guide tone displays:**
```swift
// In ActiveCadenceQuizView:

if question.drillMode == .guideTones {
    VStack {
        Text("Play the guide tones (3rd and 7th) for each chord")
            .font(.headline)
        
        HStack {
            ForEach(0..<3) { index in
                GuideToneChordCard(
                    chord: question.cadence.chords[index],
                    isActive: currentChordIndex == index,
                    showAnswer: hasSubmitted
                )
            }
        }
        
        PianoKeyboard(
            selectedNotes: $selectedNotes,
            highlightedNotes: guideToneHints,
            colorScheme: .guideTones  // Blue for 3rds, green for 7ths
        )
    }
}

if question.drillMode == .resolutionTargets {
    VStack {
        Text("Where does this note resolve?")
            .font(.headline)
        
        ResolutionTargetView(
            sourcePair: currentResolutionPair,
            sourceChord: question.cadence.chords[sourceChordIndex],
            targetChord: question.cadence.chords[targetChordIndex],
            showAnswer: hasSubmitted
        )
        
        PianoKeyboard(
            selectedNotes: $selectedNote,  // Single note
            ghostNotes: previousChordNotes,  // Show previous chord
            motionArrows: showMotionArrows
        )
    }
}

if question.drillMode == .smoothVoicing {
    VStack {
        Text("Voice with minimal motion: \(constraint.topVoiceMotion.rawValue)")
            .font(.headline)
        
        SmoothVoicingView(
            chords: [currentChord, nextChord],
            constraint: constraint,
            userVoicing: selectedNotes,
            showScore: hasSubmitted
        )
        
        PianoKeyboard(
            selectedNotes: $selectedNotes,
            ghostNotes: previousVoicing,
            voiceLeadingLines: true
        )
    }
}
```

### Step 5: Enhance PianoKeyboard Component (2 hours)

**Files to modify:**
- `Views/PianoKeyboard.swift`

**Add new visual modes:**
```swift
struct PianoKeyboard: View {
    // ... existing bindings
    
    // NEW: Visual enhancement options
    var ghostNotes: Set<Note> = []           // Previous chord in light gray
    var colorScheme: KeyColorScheme = .default
    var motionArrows: [NoteMotion] = []      // Arrows showing resolution
    var voiceLeadingLines: Bool = false      // Lines connecting voices
    
    enum KeyColorScheme {
        case default        // Selected = blue
        case guideTones     // 3rds = blue, 7ths = green
        case resolution     // Source = blue, target = green
        case voicing        // Color by voice (soprano/alto/tenor/bass)
    }
    
    // In body:
    ForEach(keys) { key in
        PianoKey(
            note: key,
            isSelected: selectedNotes.contains(key),
            isGhost: ghostNotes.contains(key),
            color: keyColor(for: key),
            showMotionArrow: motionArrows.contains { $0.source == key }
        )
        .overlay(
            voiceLeadingLine(for: key)
        )
    }
    
    func keyColor(for note: Note) -> Color {
        switch colorScheme {
        case .guideTones:
            if isThird(note) { return .blue }
            if isSeventh(note) { return .green }
            return .yellow
        case .resolution:
            // Color based on resolution role
        default:
            return selectedNotes.contains(note) ? .blue : .gray
        }
    }
}

struct NoteMotion: Identifiable {
    let id = UUID()
    let source: Note
    let target: Note
    let interval: Int  // semitones
}
```

### Step 6: Add Educational Tooltips (1 hour)

**Files to modify:**
- `Views/CadenceDrillView.swift`
- `Models/ConceptualExplanations.swift`

**Add guide tone explanations:**
```swift
// In ConceptualExplanations.swift:

let guideToneConcepts: [String: String] = [
    "guide_tones_intro": """
        Guide tones (3rds and 7ths) are the essential notes that define a chord's 
        quality and function. Everything else is decoration!
        """,
    
    "ii_to_V_resolution": """
        In ii-V, the guide tones move smoothly:
        • 3rd of ii → 7th of V (whole step down)
        • 7th of ii → 3rd of V (half step down)
        This smooth motion is why ii-V sounds so natural!
        """,
    
    "V_to_I_resolution": """
        In V-I, the tritone resolves:
        • 3rd of V → 7th of I (half step up)
        • 7th of V → 3rd of I (half step down)
        This is the strongest resolution in music!
        """
]
```

---

## Testing Plan

### Unit Tests
1. Guide tone identification for all chord types
2. Resolution target calculation (ii→V, V→I, V→vi, etc.)
3. Smooth voicing validation and scoring
4. Edge cases (augmented, diminished, sus chords)

### User Flow Tests
1. Complete guide tone drill for ii-V-I in C major
2. Complete resolution target drill with all pairs
3. Complete smooth voicing drill with different constraints
4. Switch between drill modes mid-quiz
5. SR integration for guide tone practice

### Visual Tests
1. Ghost notes display correctly
2. Color coding matches tone function
3. Motion arrows point in correct direction
4. Voice leading lines don't overlap
5. Works on different screen sizes

---

## Success Metrics

### Immediate (After 1 week)
- Students complete 50+ guide tone drills
- Average accuracy >70% on guide tone identification
- Students use the hint system <30% of the time

### Medium-term (After 1 month)
- 80% accuracy on resolution targets
- Students report "seeing the patterns" in progressions
- Guide tone drills become 20%+ of cadence practice

### Long-term (After 3 months)
- Students can identify guide tones by ear
- Improved scores on full progression drills (transfer effect)
- Students report applying voice leading to real music

---

## Pedagogical Notes

### Why This Matters
1. **Function over formula:** Students learn WHY chords work, not just WHAT they are
2. **Transfer to performance:** Guide tones are what pianists/guitarists voice
3. **Ear training foundation:** Hearing guide tones is key to transcription
4. **Improvisation:** Soloists target guide tones for strong melodic lines

### Teaching Sequence
1. **Start with guide tones:** Master identification before resolution
2. **Add resolution:** Once students can ID guide tones, show where they go
3. **Smooth voicing:** Advanced application of resolution concepts
4. **Ear mode:** Eventually add aural guide tone recognition

### Common Student Mistakes
- Playing root and 5th instead of 3rd and 7th
- Confusing which is 3rd and which is 7th
- Missing the half-step resolutions (V→I)
- Over-voicing (playing too many notes)

### Hints System
**Level 1:** "Guide tones are the 3rd and 7th"
**Level 2:** "In Dm7, the 3rd is F and the 7th is C"
**Level 3:** Highlight the guide tones on the keyboard

---

## Future Enhancements (Post-MVP)

### Advanced Features
- **Guide tone line builder:** Compose a soprano line using guide tones
- **Chord substitution:** Show how guide tones enable reharmonization
- **Four-part harmony:** Extend to SATB voicing
- **Drop 2 voicings:** Jazz piano/guitar specific voicings
- **Ear training:** Hear guide tones, identify resolution

### Content Expansion
- Minor key voice leading (different resolutions)
- Modal progressions (different guide tone behavior)
- Secondary dominants (tonicization patterns)
- Tritone substitutions (guide tone swap)

---

## File Changes Summary

### New Files (0)
None - extends existing infrastructure

### Modified Files (4)
1. **Models/ChordModel.swift**
   - Add 3 new CadenceDrillMode cases
   - Extend CadenceQuestion with guide tone properties
   - Add VoicingConstraint and VoiceMotion enums

2. **Models/CadenceGame.swift**
   - Add guide tone question generation
   - Add resolution pair generation
   - Add answer validation for guide tones/resolution/voicing

3. **Views/CadenceDrillView.swift**
   - Add UI for guideTones mode
   - Add UI for resolutionTargets mode
   - Add UI for smoothVoicing mode

4. **Views/PianoKeyboard.swift**
   - Add ghost notes rendering
   - Add color scheme options (guide tones, resolution, etc.)
   - Add motion arrows
   - Add voice leading lines

5. **Models/ConceptualExplanations.swift**
   - Add guide tone concept explanations

---

**Ready to implement?** This is a CORE jazz skill that will significantly improve student understanding.

