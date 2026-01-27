# JazzHarmonyQuiz UI Rules (Shed UI)

## Goal
Modern, fully flat, practice-first UI. No texture, no metallic effects, no skeuomorphism.

## Non-negotiables
- Use design tokens from `ShedTheme` for ALL colors, fonts, spacing, radius, and strokes.
- No gradients (unless explicitly requested for a specific component).
- No shadows. No inner shadows. No "glass" blur materials.
- No textured backgrounds, noise, vignettes, or metallic effects.
- Accent color (brass) is used sparingly: CTA buttons, progress, key emphasis only.

## Layout rules
- Prefer `ScrollView + LazyVStack` over `List`.
- Avoid `Form`.
- Prefer large whitespace and clear hierarchy:
  - section padding: `Space.l`
  - card padding: `Space.m`
  - vertical rhythm: `Space.s`/`Space.m`

## Typography rules
- Use `ShedTheme.Type.*` only.
- Headlines are minimal. Body copy is short and calm.

## Components
- Do not use default-styled controls directly. Wrap them:
  - Buttons => `ShedButton` (or `ButtonStyle` named `ShedButtonStyle`)
  - Cards/panels => `ShedCard`
  - Rows => `ShedRow`
  - Headers => `ShedHeader`

## Feedback rules
- Correct/incorrect feedback is calm:
  - Avoid celebratory confetti, bursts, sparkles.
  - Use subtle color + short text + optional haptic.
- Animations are subtle: `ShedTheme.Motion.*`

## Navigation rules
- Avoid default NavigationBar chrome where possible.
- Use a simple custom header with back button and title.

## When adding a new screen
- Start by composing existing components.
- If a new component is required, define it in `/UI/Components/` and ensure it uses tokens.