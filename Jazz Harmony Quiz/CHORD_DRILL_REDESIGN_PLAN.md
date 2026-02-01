# Chord Drill Redesign Plan

## Overview

The Chord Drill feature should present users with a **simple, preset-based interface** that hides complexity from casual users while allowing power users to configure custom drills.

## Key Principles

1. **Simplicity First**: Casual users see preset cards and tap to start immediately
2. **Complexity On-Demand**: Setup screen only appears for Custom Ad-Hoc or preset creation
3. **No Expert Difficulty**: Remove Expert from both Chord Difficulty and Key Difficulty
4. **Two Screens**: Chord Drill (preset selection) and Chord Drill Setup (configuration)

---

## Screen 1: Chord Drill (Preset Selection)

### Layout

```
┌─────────────────────────────────────┐
│         Chord Spelling              │
├─────────────────────────────────────┤
│                                     │
│  ┌─────────────┐  ┌─────────────┐  │
│  │ Basic       │  │ 7th & 6th   │  │
│  │ Triads      │  │ Chords      │  │
│  │ ▶ Start     │  │ ▶ Start     │  │
│  └─────────────┘  └─────────────┘  │
│                                     │
│  ┌─────────────┐  ┌─────────────┐  │
│  │ Full        │  │ Custom      │  │
│  │ Workout     │  │ Ad-Hoc      │  │
│  │ ▶ Start     │  │ ⚙ Configure │  │
│  └─────────────┘  └─────────────┘  │
│                                     │
│  ─────── Saved Presets ───────     │
│                                     │
│  ┌─────────────┐  ┌─────────────┐  │
│  │ My Jazz     │  │ + Create    │  │
│  │ Practice    │  │   Preset    │  │
│  │ ▶ Start     │  │             │  │
│  └─────────────┘  └─────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

### Behaviors

| Action | Result |
|--------|--------|
| Tap "Basic Triads" | Starts drill immediately with beginner triads, easy keys |
| Tap "7th & 6th Chords" | Starts drill immediately with 7th/6th chords, medium keys |
| Tap "Full Workout" | Starts drill immediately with all chords, all keys |
| Tap "Custom Ad-Hoc" | Opens Setup Screen for one-time configuration |
| Tap saved preset | Starts drill immediately with saved configuration |
| Tap "+ Create Preset" | Opens Setup Screen to configure and save new preset |
| Long-press saved preset | Shows delete option |

### Built-In Presets (Not Editable, Not Deletable)

#### Basic Triads
- **Chord Difficulty**: Beginner (Major, Minor, Dim, Aug, Sus2, Sus4)
- **Key Difficulty**: Easy (C, G, D, F, Bb)
- **Question Types**: All Tones
- **Question Count**: 10
- **Description**: "Perfect for beginners. Basic triads in common keys."

#### 7th & 6th Chords
- **Chord Difficulty**: Intermediate (adds 7, maj7, m7, m7b5, dim7, 6, m6)
- **Key Difficulty**: Medium (adds A, E, Eb, Ab)
- **Question Types**: All Tones
- **Question Count**: 10
- **Description**: "Jazz essentials. Seventh and sixth chords."

#### Full Workout
- **Chord Difficulty**: Advanced (all chord types)
- **Key Difficulty**: All Keys (all 12)
- **Question Types**: All (Single Tone, All Tones, Aural Quality, Aural Spelling)
- **Question Count**: 15
- **Description**: "Complete challenge. All chords, all keys."

#### Custom Ad-Hoc
- **Behavior**: Opens Setup Screen
- **Does NOT save**: Configuration is one-time use
- **Description**: "Configure a custom drill without saving."

---

## Screen 2: Chord Drill Setup (Configuration)

### When Shown

1. User taps "Custom Ad-Hoc" → Opens in ad-hoc mode
2. User taps "+ Create Preset" → Opens in create mode
3. User edits existing preset → Opens in edit mode

### Layout

```
┌─────────────────────────────────────┐
│  ← Back     Setup     [Start/Save]  │
├─────────────────────────────────────┤
│                                     │
│  Preset Name (only in create/edit)  │
│  ┌─────────────────────────────────┐│
│  │ My Custom Preset                ││
│  └─────────────────────────────────┘│
│                                     │
│  Question Count                     │
│  ┌──────────────────────────┐      │
│  │  ◀  10 questions  ▶      │      │
│  └──────────────────────────┘      │
│                                     │
│  Chord Difficulty                   │
│  ┌────────┬────────┬────────┐      │
│  │Beginner│Intermed│Advanced│      │
│  └────────┴────────┴────────┘      │
│  [Custom] ← expands chord picker    │
│                                     │
│  Key Difficulty                     │
│  ┌────────┬────────┬────────┐      │
│  │  Easy  │ Medium │  All   │      │
│  └────────┴────────┴────────┘      │
│  [Custom] ← expands key picker      │
│                                     │
│  Question Types                     │
│  ☑ Single Tone                      │
│  ☑ All Tones                        │
│  ☐ Aural Quality                    │
│  ☐ Aural Spelling                   │
│                                     │
│  ┌─────────────────────────────────┐│
│  │ [Start Drill] or [Save Preset] ││
│  └─────────────────────────────────┘│
│                                     │
└─────────────────────────────────────┘
```

### Setup Modes

| Mode | Preset Name Field | Primary Button | Behavior |
|------|-------------------|----------------|----------|
| Ad-Hoc | Hidden | "Start Drill" | Starts drill, doesn't save |
| Create | Visible, required | "Save Preset" | Saves preset, returns to Chord Drill |
| Edit | Visible, pre-filled | "Save Changes" | Updates preset, returns to Chord Drill |

### Difficulty Options

#### Chord Difficulty (NO EXPERT)
- **Beginner**: Major, Minor, Dim, Aug, Sus2, Sus4
- **Intermediate**: + 7, maj7, m7, m7b5, dim7, 6, m6
- **Advanced**: + all remaining chord types (7b9, 7#9, etc.)
- **Custom**: User picks specific chord types

#### Key Difficulty (NO EXPERT)
- **Easy**: C, G, D, F, Bb (5 keys)
- **Medium**: + A, E, Eb, Ab (9 keys)
- **All Keys**: All 12 keys
- **Custom**: User picks specific keys

---

## Data Model

### ChordDrillPreset (Built-In)

```swift
enum ChordDrillPreset: String, CaseIterable {
    case basicTriads
    case seventhAndSixthChords
    case fullWorkout
    case customAdHoc  // Special case - opens setup
    
    var name: String
    var description: String
    var config: ChordDrillConfig?  // nil for customAdHoc
    var opensSetup: Bool  // true only for customAdHoc
}
```

### CustomChordDrillPreset (User-Created)

```swift
struct CustomChordDrillPreset: Identifiable, Codable {
    let id: UUID
    var name: String
    var config: ChordDrillConfig
    let createdAt: Date
}
```

### ChordDrillConfig

```swift
struct ChordDrillConfig: Codable, Equatable {
    var chordDifficulty: ChordDifficulty  // beginner, intermediate, advanced, custom
    var keyDifficulty: KeyDifficulty      // easy, medium, all, custom
    var customChordTypes: Set<String>?    // only when chordDifficulty == .custom
    var customKeys: Set<String>?          // only when keyDifficulty == .custom
    var questionTypes: Set<QuestionType>
    var questionCount: Int
}
```

### ChordDifficulty (NO EXPERT)

```swift
enum ChordDifficulty: String, CaseIterable, Codable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case custom = "Custom"
}
```

### KeyDifficulty (NO EXPERT)

```swift
enum KeyDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case medium = "Medium"
    case all = "All Keys"
    case custom = "Custom"
}
```

---

## TDD Test Plan

### Test File: ChordDrillPresetSelectionViewTests.swift

#### Initial State Tests
```swift
func test_initialState_showsFourBuiltInPresets()
func test_initialState_showsCreatePresetButton()
func test_initialState_showsNoSavedPresetsWhenEmpty()
func test_initialState_showsSavedPresetsWhenPresent()
```

#### Built-In Preset Tap Tests
```swift
func test_tapBasicTriads_startsDrillImmediately()
func test_tapBasicTriads_usesCorrectConfig()
func test_tapSeventhAndSixthChords_startsDrillImmediately()
func test_tapSeventhAndSixthChords_usesCorrectConfig()
func test_tapFullWorkout_startsDrillImmediately()
func test_tapFullWorkout_usesCorrectConfig()
func test_tapCustomAdHoc_opensSetupScreen()
func test_tapCustomAdHoc_doesNotStartDrill()
```

#### Saved Preset Tests
```swift
func test_tapSavedPreset_startsDrillImmediately()
func test_tapSavedPreset_usesCorrectConfig()
func test_longPressSavedPreset_showsDeleteOption()
func test_deleteSavedPreset_removesFromList()
func test_tapCreatePreset_opensSetupScreen()
```

### Test File: ChordDrillSetupViewTests.swift

#### Mode Tests
```swift
func test_adHocMode_hidesPresetNameField()
func test_adHocMode_showsStartDrillButton()
func test_createMode_showsPresetNameField()
func test_createMode_showsSavePresetButton()
func test_editMode_showsPrefilledPresetName()
func test_editMode_showsSaveChangesButton()
```

#### Chord Difficulty Tests
```swift
func test_chordDifficulty_hasNoExpertOption()
func test_chordDifficulty_beginner_showsCorrectChords()
func test_chordDifficulty_intermediate_showsCorrectChords()
func test_chordDifficulty_advanced_showsCorrectChords()
func test_chordDifficulty_custom_showsChordPicker()
func test_chordDifficulty_selectCustom_allowsIndividualChordSelection()
```

#### Key Difficulty Tests
```swift
func test_keyDifficulty_hasNoExpertOption()
func test_keyDifficulty_easy_uses5Keys()
func test_keyDifficulty_medium_uses9Keys()
func test_keyDifficulty_all_uses12Keys()
func test_keyDifficulty_custom_showsKeyPicker()
func test_keyDifficulty_selectCustom_allowsIndividualKeySelection()
```

#### Question Type Tests
```swift
func test_questionTypes_allowsMultipleSelection()
func test_questionTypes_requiresAtLeastOne()
func test_questionTypes_defaultsToAllTones()
```

#### Validation Tests
```swift
func test_createMode_requiresPresetName()
func test_createMode_preventsDuplicatePresetName()
func test_startDrill_requiresAtLeastOneQuestionType()
func test_customChordDifficulty_requiresAtLeastOneChord()
func test_customKeyDifficulty_requiresAtLeastOneKey()
```

#### Action Tests
```swift
func test_adHocMode_startDrill_navigatesToDrill()
func test_adHocMode_startDrill_doesNotSavePreset()
func test_createMode_savePreset_addsToSavedPresets()
func test_createMode_savePreset_navigatesBackToSelection()
func test_editMode_saveChanges_updatesExistingPreset()
func test_back_dismissesWithoutSaving()
```

### Test File: ChordDrillPresetStoreTests.swift

```swift
func test_savePreset_persistsToStorage()
func test_loadPresets_retrievesFromStorage()
func test_deletePreset_removesFromStorage()
func test_updatePreset_modifiesExisting()
func test_presets_sortedByCreationDate()
func test_maxPresets_enforced()
```

### Test File: ChordDrillEndToEndTests.swift

#### Flow: Basic Triads Quick Start
```swift
func test_flow_basicTriads_tapToStartToDrill() {
    // 1. Open Chord Drill
    // 2. Tap "Basic Triads"
    // 3. Verify drill starts with correct config
    // 4. Verify beginner chords only
    // 5. Verify easy keys only
}
```

#### Flow: Custom Ad-Hoc Drill
```swift
func test_flow_customAdHoc_configureAndStart() {
    // 1. Open Chord Drill
    // 2. Tap "Custom Ad-Hoc"
    // 3. Verify Setup screen opens
    // 4. Configure settings
    // 5. Tap "Start Drill"
    // 6. Verify drill starts with custom config
    // 7. Return to Chord Drill
    // 8. Verify no preset was saved
}
```

#### Flow: Create and Use Custom Preset
```swift
func test_flow_createPreset_saveAndUse() {
    // 1. Open Chord Drill
    // 2. Tap "+ Create Preset"
    // 3. Verify Setup screen opens
    // 4. Enter preset name "My Practice"
    // 5. Configure settings
    // 6. Tap "Save Preset"
    // 7. Verify returns to Chord Drill
    // 8. Verify "My Practice" appears in saved presets
    // 9. Tap "My Practice"
    // 10. Verify drill starts immediately with saved config
}
```

#### Flow: Delete Custom Preset
```swift
func test_flow_deletePreset() {
    // 1. Create and save a preset
    // 2. Long-press the saved preset
    // 3. Tap "Delete"
    // 4. Verify preset removed from list
}
```

---

## Implementation Phases

### Phase 1: Update Data Models
- [ ] Remove `expert` case from `ChordDifficulty`
- [ ] Remove `expert` case from `KeyDifficulty` (if exists)
- [ ] Update `ChordDrillConfig` to support custom chord/key selections
- [ ] Create `CustomChordDrillPreset` model
- [ ] Create `CustomPresetStore` for persistence

### Phase 2: Create Preset Selection Screen
- [ ] Create `ChordDrillPresetSelectionView`
- [ ] Implement built-in preset cards
- [ ] Implement saved preset cards
- [ ] Implement "+ Create Preset" button
- [ ] Implement long-press delete for saved presets

### Phase 3: Create Setup Screen
- [ ] Create `ChordDrillSetupView`
- [ ] Implement mode switching (ad-hoc, create, edit)
- [ ] Implement chord difficulty picker (NO EXPERT)
- [ ] Implement key difficulty picker (NO EXPERT)
- [ ] Implement custom chord/key pickers
- [ ] Implement question type selection
- [ ] Implement question count stepper

### Phase 4: Wire Up Navigation
- [ ] Built-in preset tap → Start drill
- [ ] Custom Ad-Hoc tap → Setup screen (ad-hoc mode)
- [ ] Create Preset tap → Setup screen (create mode)
- [ ] Saved preset tap → Start drill
- [ ] Setup "Start Drill" → Navigate to drill
- [ ] Setup "Save Preset" → Save and return to selection

### Phase 5: Integration Testing
- [ ] Verify all end-to-end flows
- [ ] Verify persistence across app restarts
- [ ] Verify no "Expert" options appear anywhere

---

## Files to Create/Modify

### New Files
- `JazzHarmonyQuiz/Features/ChordDrill/ChordDrillPresetSelectionView.swift`
- `JazzHarmonyQuiz/Features/ChordDrill/ChordDrillSetupView.swift`
- `JazzHarmonyQuiz/Features/ChordDrill/CustomPresetStore.swift` (already created)
- `JazzHarmonyQuizTests/Features/ChordDrill/ChordDrillPresetSelectionViewTests.swift`
- `JazzHarmonyQuizTests/Features/ChordDrill/ChordDrillSetupViewTests.swift`
- `JazzHarmonyQuizTests/Features/ChordDrill/ChordDrillEndToEndTests.swift`

### Files to Modify
- `JazzHarmonyQuiz/Core/Models/ChordType.swift` - Remove expert from ChordDifficulty
- `JazzHarmonyQuiz/Models/ChordModel.swift` - Remove expert from KeyDifficulty
- `JazzHarmonyQuiz/Features/ChordDrill/ChordDrillGame.swift` - Update config handling
- Navigation to use new preset selection as entry point

---

## Success Criteria

1. ✅ Opening Chord Drill shows preset cards, NOT setup form
2. ✅ Tapping built-in preset starts drill immediately
3. ✅ Tapping "Custom Ad-Hoc" opens setup screen
4. ✅ Setup screen has NO "Expert" difficulty options
5. ✅ Can create, save, and use custom presets
6. ✅ Can delete custom presets
7. ✅ All tests pass
8. ✅ Complexity hidden from casual users
