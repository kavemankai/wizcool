# GDD — Combat System

## Overview

Turn-based grid combat. Player and enemies take turns acting. Each unit can move and attack once per turn. All damage routes through CombatResolver to ensure gear-fracture rules apply identically regardless of source (player attack, enemy attack, or hazard).

## Player Fantasy

Feeling of tactical precision — choosing the right target, managing gear attrition, knowing when to risk a fractured unit vs pulling back. Tension from gear degradation rather than HP depletion.

## Detailed Rules

### Turn Order
1. Player turn — all player units act in any order (move + attack, either order, each once)
2. Enemy turn — Guardian → Rampaging → Tactical archetype order, 0.8s delay between each
3. Hazard resolution — units on warning tiles take damage at end of round
4. Round increments, turns refresh

### Attack Resolution
```
dmg = attacker.get_weapon_damage()           # from weapon GearItem, or 1 if no weapon
result = CombatResolver.resolve_damage(target, dmg)
```

### DamageResult Cascade (Unit.take_damage)
1. `toughness -= dmg`. If toughness > 0 → **NORMAL**
2. If toughness ≤ 0, check for Intact armor → fracture it, reset TGH → **GEAR_FRACTURED**
3. If no Intact armor, check Intact weapon → fracture it, reset TGH → **GEAR_FRACTURED**
4. If no Intact gear, check Fractured gear → break it, is_downed = true → **GEAR_BROKEN**
5. If nothing to break → is_downed = true → **DOWNED**

### Attack Range
- Chebyshev distance (max of dx, dy)
- Requires LOS (LOSCalculator.has_los)
- Adjacent (distance 1) = melee, distance > 1 = ranged (different cutaway animation)

### Field Patch
- Uses Medical Kit gear slot
- Restores one Fractured item to 50% modifier (patched_this_mission = true)
- Counts as the attack action for that turn
- Medical Kit is consumed

## Formulas

```
Chebyshev distance: max(abs(ax - tx), abs(ay - ty))
Bar width: _BAR_W * (toughness / max_toughness)
Effective combat skill: base + sum(gear.get_effective_modifier() where stat_target == "combat_skill")
Effective speed: base + sum(gear.get_effective_modifier() where stat_target == "speed")
```

## Edge Cases

- Unit with 0 gear: DOWNED immediately on first hit reaching 0 TGH
- Fractured weapon + no armor: DOWNED on next hit (Fractured weapon breaks)
- Field-patched item: modifier = base/2, still counts as Fractured for cascade
- Enemy attacks player leader: if leader_fell → immediate mission fail
- Simultaneous downed (hazard): flush_downed runs after hazard pass, leader check included

## Dependencies

- GearItem (gear state, modifiers, damage values)
- Unit (toughness, gear array, is_downed, signals)
- LOSCalculator (has_los)
- GridManager (grid_to_world_center, tile type for cover)
- CombatCutaway (visual feedback on attack)
- HazardSystem (hazard damage at end of round)

## Tuning Knobs

- `HAZARD_DAMAGE = 2` in HazardSystem.gd
- Weapon damage set per-unit in Main.gd `_spawn_units()`
- Enemy phase delay: `0.8` seconds (skippable)
- Cutaway auto-dismiss: `2.0` seconds

## Acceptance Criteria

- [x] Player can attack adjacent enemy (melee)
- [x] Player can attack ranged enemy within attack_range with LOS
- [x] Gear fracture cascade fires in correct priority order
- [x] Hazard damage applies at end of round, not during enemy turn
- [x] Mission fails immediately when leader is downed
- [x] CombatCutaway plays for every attack (unless fast-mode)
