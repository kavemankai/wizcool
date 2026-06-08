# ADR-004: cutaway_queue Typed as Object in Static AI Functions

**Date**: 2026-06-07
**Status**: Accepted

## Context

`EnemyAI.do_attack()` and the three archetype `take_turn()` functions accept an optional reference to the `CombatCutaway` node so they can queue cutaway events. The natural type would be `CombatCutaway`, but this causes a parser error: static functions in GDScript cannot reference class names that haven't been fully parsed yet, and the dependency graph between `EnemyAI` → `CombatCutaway` creates a forward-reference.

## Decision

The `cutaway_queue` parameter is typed as `Object` with a default of `null`:

```gdscript
static func do_attack(attacker: Unit, target: Unit, cutaway_queue: Object = null) -> int:
    ...
    if cutaway_queue != null:
        cutaway_queue.queue_event(attacker, target, dmg, result, pre_tgh)
```

Call sites pass the actual `CombatCutaway` node reference or `null`. Duck typing handles the method call.

## Consequences

- No forward-reference parser error at load time.
- Type safety for `cutaway_queue` is lost — a wrong object type would fail silently at the `queue_event` call rather than at the function signature.
- All existing call sites that don't pass a cutaway ref (e.g., tests, non-combat AI utility calls) remain valid — `null` default means no change to signature compatibility.
- If GDScript adds a solution to circular class references in a future Godot version, this can be revisited.
