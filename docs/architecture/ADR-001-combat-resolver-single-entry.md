# ADR-001: CombatResolver as Single Damage Entry Point

**Date**: 2026-06-07
**Status**: Accepted

## Context

Multiple systems deal damage to units: player attacks, enemy attacks, and hazards. Early implementation called `Unit.take_damage()` directly from call sites. This created a risk that future systems (status effects, resistances, damage modifiers) would need to be wired into every call site independently.

## Decision

All damage routes through `CombatResolver.resolve_damage(target, amount)`. No code outside `CombatResolver` calls `Unit.take_damage()` directly.

```gdscript
# Correct
CombatResolver.resolve_damage(target, dmg)

# Forbidden
target.take_damage(dmg)
```

## Consequences

- Any future modifier (resistance, cover bonus, status effect) is added once in `CombatResolver`, not at every call site.
- `Unit.take_damage()` remains public (GDScript has no access modifiers) but is treated as package-private by convention — never called directly.
- Hazard damage (`HazardSystem`) must route through `CombatResolver` for the same reason.
- The cutaway system (`CombatCutaway`) captures `pre_tgh` before calling `CombatResolver`, not before calling `Unit.take_damage()`.
