# GDD — Gear Economy

## Overview

Gear is the only progression vector. No XP, no leveling. Characters have fixed base stats; gear modifies them. Gear degrades through three states across missions, creating persistent consequence.

## Player Fantasy

Every mission puts your gear at risk. Choosing which gear to bring, managing fractures mid-mission, deciding whether to field-patch or conserve the kit — these are the strategic layer. The Terminal Hub is relief: spend credits to repair, knowing the next job will cost you again.

## Detailed Rules

### Gear States
| State | Modifier | Combat Status |
|---|---|---|
| INTACT | Full modifier | Active |
| FRACTURED | 0 (50% if field-patched this mission) | Degraded |
| BROKEN | 0, slot effectively empty | Inactive |

### Gear Slots
- `weapon` — provides damage and combat_skill modifier
- `armor` — provides speed modifier, absorbs first fracture hit
- `medical` — enables Field Patch action, consumed on use

### State Transitions
- Mission damage: INTACT → FRACTURED (armor first, then weapon)
- Mission damage: FRACTURED → BROKEN (breaks whichever is fractured)
- Field Patch (in-mission): FRACTURED → patched (50% modifier, cannot transition again this mission)
- Terminal Hub repair: BROKEN → INTACT (credit cost)
- Mission failure penalty: all INTACT gear → FRACTURED across all crew

### Starting Fractured Gear (ALPHA only)
ALPHA begins each mission with her lowest-modifier non-medical gear already Fractured. Represents accumulated wear. Creates immediate tension.

### Persistence
Gear states save to `GameState.crew` via SaveManager between missions.
BROKEN items move to `GameState.broken_inventory`, available for repair at Terminal Hub.

## Formulas

```
Effective modifier:
  INTACT:    modifier
  FRACTURED: 0 (or modifier/2 if patched_this_mission)
  BROKEN:    0

Repair cost: [not yet implemented — placeholder for Phase 12+]
Danger Pay:  150 credits on success, 0 on failure
```

## Edge Cases

- Unit with no gear (all broken): base stats only, weapon damage = 1
- Medical kit patching armor that was already field-patched: prevented by `patched_this_mission` flag
- BROKEN gear dropped as loot by Tactical enemies on defeat
- Vanguard rank 2+: VANGUARD-2 spawns with BALLISTIC-PLATE armor (armor slot)
- Vanguard rank 3+: VANGUARD-3 spawns with VANGUARD-MEDKIT (medical slot)

## Dependencies

- Unit (gear array, get_effective_combat_skill, get_effective_speed, get_weapon_damage)
- CombatResolver (fracture cascade logic lives in Unit.take_damage)
- GameState (crew persistence)
- SaveManager (serialisation)
- TerminalHub (repair UI)
- ManifestScreen (gear selection before mission)

## Tuning Knobs

- `modifier / 2` in `GearItem.get_effective_modifier()` for patched state
- Danger Pay: `DANGER_PAY = 150` in Main.gd
- Starting fractured gear: lowest-modifier non-medical item (configurable per unit)

## Acceptance Criteria

- [x] Gear fractures in correct priority (armor before weapon)
- [x] Fractured gear provides 0 modifier unless patched
- [x] Patched gear provides 50% modifier
- [x] Broken gear is absent from stat calculations
- [x] Mission failure fractures all Intact gear
- [x] ALPHA starts each mission with lowest-modifier gear Fractured
- [x] Gear states persist across missions via SaveManager
