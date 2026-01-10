# TODO Task Tracking Framework

**Purpose:** Structured framework for AI agents to track tasks and progress
**For:** Claude Code, GitHub Copilot, and human developers
**Updated:** 2026-01-10

---

## Overview

This document provides a template and guidelines for tracking development tasks in the Jazz Harmony Quiz project. Use this framework when working on multi-step features, bug fixes, or refactoring efforts.

---

## When to Create a TODO

### ✅ Create a TODO for:
- Multi-step features (3+ steps)
- Bug fixes requiring investigation
- Refactoring efforts
- Features spanning multiple files
- User-requested enhancements
- Performance optimizations
- Documentation updates

### ❌ Don't Create a TODO for:
- Single-file trivial changes
- Simple typo fixes
- One-line code corrections
- Immediate fixes (< 5 minutes)

---

## TODO Template

Copy and paste this template to `.ai/todos/[feature-name].md`

```markdown
# TODO: [Feature/Task Name]

**Created:** YYYY-MM-DD
**Status:** Not Started | In Progress | Blocked | Completed
**Priority:** Low | Medium | High | Critical
**Estimated Effort:** Small (< 1 hour) | Medium (1-4 hours) | Large (4+ hours)
**Assigned To:** AI Agent | Human Developer | [Name]

---

## Description

[Brief description of what needs to be done and why]

### Background
[Context about the feature/bug, user request, or technical need]

### Goals
- [Primary goal 1]
- [Primary goal 2]
- [Primary goal 3]

### Non-Goals
- [Explicitly out of scope item 1]
- [Explicitly out of scope item 2]

---

## Acceptance Criteria

- [ ] [Criterion 1: Specific, testable requirement]
- [ ] [Criterion 2: Specific, testable requirement]
- [ ] [Criterion 3: Specific, testable requirement]

---

## Implementation Plan

### Phase 1: Research & Design
- [ ] Read relevant existing code
- [ ] Understand current architecture
- [ ] Design approach
- [ ] Identify affected files

**Files to Read:**
- [ ] `path/to/file1.swift`
- [ ] `path/to/file2.swift`

**Estimated Time:** [X hours]

### Phase 2: Implementation
- [ ] [Subtask 1: Specific implementation step]
- [ ] [Subtask 2: Specific implementation step]
- [ ] [Subtask 3: Specific implementation step]

**Files to Modify/Create:**
- [ ] `path/to/file1.swift` - [Description of changes]
- [ ] `path/to/file2.swift` - [Description of changes]

**Estimated Time:** [X hours]

### Phase 3: Testing
- [ ] Build and run in Xcode
- [ ] Test happy path
- [ ] Test edge cases
- [ ] Test on simulator
- [ ] Test on device (if available)

**Test Cases:**
1. [Test case 1]
2. [Test case 2]
3. [Test case 3]

**Estimated Time:** [X hours]

### Phase 4: Documentation
- [ ] Update README.md (if user-facing)
- [ ] Add code comments
- [ ] Update AGENT_INSTRUCTIONS.md (if architectural)
- [ ] Update this TODO with outcomes

**Estimated Time:** [X hours]

---

## Technical Details

### Architecture Changes
[Describe any architectural changes or additions]

### Data Model Changes
[Describe changes to structs, classes, enums]

### UI Changes
[Describe changes to views or user interface]

### Dependencies
- [Dependency 1: Why it's needed]
- [Dependency 2: Why it's needed]

### Risks & Concerns
- [Risk 1: Mitigation strategy]
- [Risk 2: Mitigation strategy]

---

## Progress Log

### YYYY-MM-DD
- [Action taken]
- [Discovery or decision made]
- [Blocker encountered]

### YYYY-MM-DD
- [Action taken]
- [Progress update]

---

## Blockers

### Active Blockers
- [Blocker 1: Description and required action]
- [Blocker 2: Description and required action]

### Resolved Blockers
- [Blocker 1: How it was resolved]
- [Blocker 2: How it was resolved]

---

## Related Issues/Tasks
- [Link or reference to related TODO]
- [Link to GitHub issue if applicable]

---

## Completion Notes

[Added upon completion]

### What Was Implemented
- [Summary of implementation]

### What Changed from Plan
- [Deviations from original plan and why]

### Lessons Learned
- [Insight 1]
- [Insight 2]

### Future Enhancements
- [Potential improvement 1]
- [Potential improvement 2]

---

## Sign-off

**Completed By:** [AI Agent or Developer Name]
**Completed Date:** YYYY-MM-DD
**Tested By:** [Name or "Self-tested"]
**Reviewed By:** [Name or "Not reviewed"]
```

---

## Directory Structure

Create TODOs in the `.ai/todos/` directory:

```
.ai/
├── AGENT_INSTRUCTIONS.md
├── PROJECT_CONTEXT.md
├── CODING_STANDARDS.md
├── TODO_TEMPLATE.md (this file)
└── todos/
    ├── active/
    │   ├── add-audio-playback.md
    │   └── implement-voice-input.md
    ├── completed/
    │   ├── fix-leaderboard-sorting.md
    │   └── add-expert-chords.md
    └── blocked/
        └── sync-to-icloud.md
```

**Organization:**
- `active/` - Currently in progress
- `completed/` - Finished tasks (for reference)
- `blocked/` - Waiting on external factors

---

## Example TODO: Add Audio Playback

```markdown
# TODO: Add Chord Tone Audio Playback

**Created:** 2026-01-10
**Status:** In Progress
**Priority:** Medium
**Estimated Effort:** Large (6-8 hours)
**Assigned To:** AI Agent

---

## Description

Add audio playback functionality to play individual chord tones and full chords during quizzes to help users learn by ear.

### Background
Users have requested the ability to hear chord tones played back, which would enhance the learning experience by adding an auditory component to the visual quiz interface.

### Goals
- Play individual notes when tapped on piano keyboard
- Play all chord tones together when user presses "Play Chord" button
- Support playback during quiz and review modes

### Non-Goals
- MIDI file import/export
- Recording user audio
- Music notation display
- Background music

---

## Acceptance Criteria

- [ ] Tapping a piano key plays that note's sound
- [ ] "Play Chord" button plays all chord tones together
- [ ] Audio works on physical device (not just simulator)
- [ ] Audio respects device silent mode
- [ ] Audio stops when navigating away from quiz
- [ ] No audio glitches or latency issues

---

## Implementation Plan

### Phase 1: Research & Design
- [x] Research AVFoundation audio playback
- [x] Decide on audio generation approach (synthesized vs samples)
- [x] Design AudioManager architecture
- [ ] Identify all integration points in UI

**Files to Read:**
- [x] `Views/PianoKeyboard.swift` - Understand keyboard interaction
- [x] `Views/ChordDrillView.swift` - Identify where to add play button
- [ ] Apple AVFoundation documentation

**Estimated Time:** 2 hours
**Actual Time:** 1.5 hours

### Phase 2: Implementation
- [ ] Create AudioManager.swift in Models/
- [ ] Implement note synthesis using AVAudioEngine
- [ ] Add play functionality to PianoKeyboard
- [ ] Add "Play Chord" button to ActiveQuizView
- [ ] Handle audio session configuration
- [ ] Add audio settings to QuizSetupView (enable/disable)

**Files to Modify/Create:**
- [ ] `Models/AudioManager.swift` (new) - Audio engine and playback
- [ ] `Views/PianoKeyboard.swift` - Add tap-to-play
- [ ] `Views/ChordDrillView.swift` - Add play chord button
- [ ] `Views/QuizSetupView.swift` - Add audio toggle

**Estimated Time:** 4 hours

### Phase 3: Testing
- [ ] Build and run in Xcode
- [ ] Test note playback on all keys
- [ ] Test chord playback
- [ ] Test on physical device (simulator audio is limited)
- [ ] Test with device in silent mode
- [ ] Test with headphones connected
- [ ] Test navigation during playback

**Test Cases:**
1. Tap single key → Hear correct note
2. Tap multiple keys → Hear all selected notes
3. Press "Play Chord" → Hear all chord tones together
4. Enable silent mode → No audio plays
5. Navigate away during playback → Audio stops gracefully

**Estimated Time:** 2 hours

### Phase 4: Documentation
- [ ] Update README.md with audio feature
- [ ] Add comments to AudioManager
- [ ] Update AGENT_INSTRUCTIONS.md with audio architecture
- [ ] Update this TODO with outcomes

**Estimated Time:** 1 hour

---

## Technical Details

### Architecture Changes
- New `AudioManager` class to encapsulate AVFoundation logic
- Singleton pattern (similar to JazzChordDatabase)
- Injected as `@EnvironmentObject` for access throughout views

### Data Model Changes
None (AudioManager is separate from quiz data model)

### UI Changes
- Piano keyboard plays sound on tap
- New "Play Chord" button in ActiveQuizView
- New audio settings toggle in QuizSetupView
- Optional speaker icon indicator when audio is enabled

### Dependencies
- AVFoundation (native iOS framework, no external dependencies)

### Risks & Concerns
- **Latency:** Audio playback may have delay on device
  - **Mitigation:** Use AVAudioEngine for low-latency playback
- **Audio Quality:** Synthesized audio may sound artificial
  - **Mitigation:** Use sine wave + envelope for musical tone
- **Memory:** Loading many audio samples could increase memory
  - **Mitigation:** Generate tones on-demand rather than pre-loading
- **Testing:** Simulator has limited audio capabilities
  - **Mitigation:** Test on physical device frequently

---

## Progress Log

### 2026-01-10
- Created TODO
- Researched AVFoundation approaches
- Decided on AVAudioEngine with synthesized tones (no sample files needed)
- Read PianoKeyboard.swift to understand interaction model

### 2026-01-11
- Created AudioManager.swift (150 lines)
- Implemented tone synthesis using AVAudioPlayerNode
- Added play functionality to PianoKeyboard
- **Blocker:** Audio latency on first tap (cold start issue)

### 2026-01-12
- Resolved latency blocker by pre-warming audio engine
- Added "Play Chord" button to ActiveQuizView
- Tested on iPhone 15 Pro - works great!

---

## Blockers

### Active Blockers
None

### Resolved Blockers
- **Audio latency on first tap** - Resolved by initializing AVAudioEngine at app launch and keeping it running

---

## Related Issues/Tasks
- Consider adding visual waveform display (future enhancement)
- Investigate MIDI keyboard input support (future enhancement)

---

## Completion Notes

[To be added upon completion]

---

## Sign-off

**Completed By:**
**Completed Date:**
**Tested By:**
**Reviewed By:**
```

---

## Quick Reference Card

Use this for rapid task tracking:

### Minimal TODO

For simple tasks, use this abbreviated format:

```markdown
# TODO: [Task Name]

**Status:** [Status]
**Files:**
- [ ] `file1.swift` - [changes]
- [ ] `file2.swift` - [changes]

**Steps:**
1. [ ] [Step 1]
2. [ ] [Step 2]
3. [ ] [Step 3]

**Notes:**
- [Quick note 1]
- [Quick note 2]
```

---

## AI Agent Workflow

### Starting a New Task

1. **Receive task from user**
   ```
   User: "Add a timer display to show elapsed time per question"
   ```

2. **Assess complexity**
   - Simple (1-2 files, < 30 minutes)? → No TODO needed, just do it
   - Complex (3+ files, > 30 minutes)? → Create TODO

3. **Create TODO file**
   ```bash
   # AI Agent should suggest this file be created
   .ai/todos/active/add-question-timer-display.md
   ```

4. **Fill in template**
   - Copy TODO template
   - Fill in known information
   - Mark unknowns for investigation

5. **Begin work**
   - Follow implementation plan
   - Update progress log as you go
   - Check off completed items

6. **Complete task**
   - Fill in completion notes
   - Move to `completed/` directory
   - Inform user

### Handling Blockers

If you encounter a blocker:

1. **Document it immediately**
   ```markdown
   ### Active Blockers
   - **Audio samples not available** - Need user to provide or generate samples
   ```

2. **Move TODO to blocked/ directory**
   ```
   .ai/todos/active/add-audio.md → .ai/todos/blocked/add-audio.md
   ```

3. **Inform user**
   ```
   "I've encountered a blocker: [description].
    I've documented this in the TODO and moved it to blocked/.
    What would you like me to do?"
   ```

4. **Work on other tasks**
   - Switch to next priority
   - Return when blocker is resolved

---

## Best Practices

### ✅ Do:
- Create TODOs at start of complex tasks
- Update progress log daily
- Be specific in subtasks
- Document blockers immediately
- Move completed TODOs to completed/ directory
- Reference file paths and line numbers when relevant

### ❌ Don't:
- Create TODOs for trivial tasks
- Let TODOs get out of date
- Use vague descriptions ("fix stuff")
- Leave blockers undocumented
- Delete completed TODOs (move to completed/)

---

## Integration with Git

### Commit Messages Should Reference TODOs

```bash
# Good commit message
git commit -m "Add AudioManager for chord playback (TODO: add-audio-playback)"

# Even better with details
git commit -m "feat: implement AudioManager with AVAudioEngine

- Synthesizes tones using sine wave generator
- Pre-warms audio engine to reduce latency
- Supports polyphonic playback

TODO: .ai/todos/active/add-audio-playback.md (Phase 2 complete)"
```

### Branch Naming

Use TODO name in branch if appropriate:

```bash
# For feature branches
git checkout -b feature/add-audio-playback

# For bug fixes
git checkout -b fix/leaderboard-sorting-bug
```

---

## Reviewing Completed TODOs

Periodically review completed TODOs to:

1. **Extract patterns** - Common approaches that worked well
2. **Improve estimates** - Adjust effort estimates for future tasks
3. **Document lessons** - Add to AGENT_INSTRUCTIONS.md
4. **Archive old TODOs** - Move very old completed TODOs to archive

Suggested schedule: Review quarterly or after major milestones

---

## Questions?

If unclear about:
- **When to create a TODO:** If task takes > 30 min or touches 3+ files
- **How detailed to be:** More detail for complex tasks, less for simple
- **What to do with blockers:** Document and inform user immediately
- **How to track progress:** Update progress log daily with actions taken

**Remember:** TODOs are tools, not bureaucracy. Use them when they help, skip when they don't.
