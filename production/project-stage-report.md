# Project Stage Analysis — Fringe Ledger

**Date**: 2026-06-07
**Stage**: PRODUCTION
**Stage Confidence**: PASS — clearly detected. 25 source files, 15+ systems implemented, active sprint in flight.

---

## Completeness Overview

| Domain | Status | Detail |
|--------|--------|--------|
| **Design** | 55% | 4 GDD docs (systems-index, combat, gear-economy, combat-cutaway). No game-concept doc, no narrative, no level design docs. |
| **Code** | 70% | 25 `.gd` files (~2.2k LOC). Phases 1–10 complete. Phase 11 (combat feel) ~95% done. Phase 12 (audio) not started. |
| **Architecture** | 20% | 0 formal ADRs. 4 critical decisions captured in `active.md` but not in `docs/architecture/`. Engine reference pinned. |
| **Production** | 60% | 1 active sprint (11/13 stories done). Session state tracked. No QA evidence artifacts recorded yet. |
| **Tests** | 0% | No automated tests. All testing is manual in-editor. Combat math and gear state logic unverified by automation. |

---

## System Inventory

### Implemented (Phases 1–10 + Phase 11)

| System | File(s) | GDD |
|--------|---------|-----|
| Grid (tiles, positions, movement) | `core/GridPos.gd`, `GridManager.gd`, `MovementRange.gd` | systems-index |
| Line of sight | `core/LOSCalculator.gd` | systems-index |
| Turn management | `core/TurnManager.gd` | systems-index |
| Units (stats, gear, draw) | `units/Unit.gd`, `GearItem.gd` | combat.md, gear-economy.md |
| Combat resolution | `systems/CombatResolver.gd` | combat.md |
| Gear economy | `systems/GearSystem.gd` | gear-economy.md |
| Hazards | `systems/HazardSystem.gd` | — |
| Mission logic | `systems/MissionSystem.gd` | — |
| Rival system | `systems/RivalSystem.gd` | — |
| Enemy AI (3 archetypes) | `units/ai/GuardianAI.gd`, `RampagingAI.gd`, `TacticalAI.gd`, `EnemyAI.gd` | — |
| HUD | `ui/HUD.gd` | — |
| Combat cutaway | `ui/CombatCutaway.gd`, `CutawayUnit.gd` | combat-cutaway.md |
| Manifest screen | `ui/ManifestScreen.gd` | — |
| Post-mission screen | `ui/PostMissionScreen.gd` | — |
| Terminal Hub | `ui/TerminalHub.gd` | — |
| Game state + save | `data/GameState.gd`, `SaveManager.gd` | — |
| Main loop | `Main.gd` | — |

### Stub / Not Yet Implemented

| System | Status |
|--------|--------|
| Audio | Phase 12 candidate — not started |
| Automated tests | Not planned yet |

---

## Gaps Identified

### 1. No Game Concept Document
`design/game-concept.md` does not exist. The pillar statement, elevator pitch, and design philosophy are known but not formalized. Low urgency for solo dev; would be valuable before any external collaboration.

→ *Run `/quick-design` or `/brainstorm` to author a one-page concept doc when ready.*

### 2. Zero Automated Tests
The coding standards require unit tests for combat math, gear state transitions, and AI logic. Current coverage is 0%. This is a known and accepted risk for prototype/early-production scale — manual testing fills the gap.

→ *Run `/test-setup` to scaffold a gdUnit4 test framework when ready to close this gap.*

### 3. No Architecture Decision Records
Four critical decisions are documented in `active.md` but should be formal ADRs in `docs/architecture/`:
- CombatResolver as single damage routing point (ADR-001)
- CanvasLayer UI with programmatic node construction (ADR-002)
- Static AI dispatch per archetype (ADR-003)
- `cutaway_queue: Object` to avoid forward-reference (ADR-004)

→ *Run `/architecture-decision` four times to lock these in.*

### 4. QA Evidence Not Recorded
`production/qa/evidence/` exists but is empty. S012 (play session verification) is the pending gate before Sprint 001 is complete.

→ *Run S012 playtest, then record findings in `production/qa/evidence/sprint-001-s012.md`.*

### 5. No Narrative / Level Scope
`design/narrative/` and `design/levels/` are absent. Intentional for current phase — Fringe Ledger is mechanics-first. Defer until Phase 12+.

---

## Recommended Next Steps

**Immediate (Sprint 001 close-out):**
1. Run S012 live play session — verify all Phase 11 features, no regressions
2. Record QA evidence in `production/qa/evidence/`
3. Mark Sprint 001 complete in `production/sprints/sprint-001.md`

**Before Phase 12 starts:**
4. Write 4 ADRs (see gap 3 above) — 30 min, high leverage for code maintainability
5. Decide audio priority order: attack SFX first vs. music/ambience first (open question in `active.md`)

**Phase 12 candidates:**
- Audio foundation (`/audio-system` skill available via GodotPrompter)
- Test scaffolding for combat math and gear logic (`/test-setup`)
- Game concept doc (`/quick-design`)

---

## Sprint 001 Status

**Sprint**: Combat Feel Polish
**Stories**: 11 DONE / 13 total

| Story | Status |
|-------|--------|
| S001 Enemy inspection — click to view stats | DONE |
| S002 Slow enemy phase — 0.8s gaps, acting ring | DONE |
| S003 SKIP button | DONE |
| S004 CombatCutaway overlay | DONE |
| S005 CutawayUnit placeholder sprites | DONE |
| S006 Melee animation (lunge + shake) | DONE |
| S007 Ranged animation (bullet travel) | DONE |
| S008 Health bar animation | DONE |
| S009 Click-to-dismiss / auto-dismiss | DONE |
| S010 Input blocked during cutaway | DONE |
| S011 Fade in/out, result slam, gear badge, CUTAWAY toggle | DONE |
| S012 Play session verification — live playtest | **TODO** |
| S013 Audio foundation | TODO |

---

## Open Questions

1. Should the CUTAWAY toggle setting persist via `GameState`/`SaveManager` across sessions?
2. Audio phase priority: attack SFX first, or music/ambience first?

---

*Generated by `/project-stage-detect` on 2026-06-07. Update after each sprint close-out.*
