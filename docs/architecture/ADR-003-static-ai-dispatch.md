# ADR-003: Static AI Dispatch per Archetype

**Date**: 2026-06-07
**Status**: Accepted

## Context

Enemy AI needs to vary significantly by archetype (Guardian patrols, Rampaging charges, Tactical holds and hunts). Options considered: a single AI class with branching logic, a class hierarchy with virtual methods, or separate static classes per archetype.

## Decision

Each archetype is a pure static class with no instance state. `Main.gd` dispatches to the correct class based on `unit.archetype`:

```gdscript
match enemy.archetype:
    Unit.Archetype.GUARDIAN:  GuardianAI.take_turn(unit, all_units, grid)
    Unit.Archetype.RAMPAGING: RampagingAI.take_turn(unit, all_units, grid)
    Unit.Archetype.TACTICAL:  TacticalAI.take_turn(unit, all_units, grid, round_num)
```

All AI state (patrol index, alert status, advance trigger) lives on the `Unit` node, not in the AI class.

## Consequences

- AI logic is isolated per archetype — modifying `TacticalAI` cannot regress `GuardianAI`.
- Static functions are pure: same inputs → same outputs, no hidden state. Straightforward to unit test.
- Adding a new archetype requires a new static class and one new `match` branch in `Main.gd`.
- `EnemyAI.gd` provides shared utilities (e.g., `do_attack()`) called by all three archetype classes.
- `cutaway_queue` parameter is typed `Object` (not `CombatCutaway`) on all static AI functions to avoid forward-reference issues in static context — see ADR-004.
