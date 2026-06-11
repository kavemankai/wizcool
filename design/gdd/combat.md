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

### Graze tier ladder (deterministic — no dice; pillar preserved)

Every attack lands; board conditions set its *quality*. Implemented in
`GrazeSystem.compute_tier()` / `apply_tier()`; constants in `CombatConstants`.

```
tier starts at CLEAN, modifiers apply, clamp to [CHIP .. CLEAN]:
  HEAVY cover, not flanked   → −2        LIGHT cover, not flanked  → −1
  target BRACEd              → −1        attack at max range band  → −1
                                         (only for attack_range > 1)
  adjacent (distance 1)      → +1

target gear erodes their cover discipline:
  weapon BROKEN     → cover penalty ignored entirely
  weapon FRACTURED  → cover penalty reduced by 1 (HEAVY acts as LIGHT)

damage transform:
  CLEAN  = full weapon damage           (e.g. 3 → 3)
  GRAZE  = max(1, damage − 1)           (e.g. 3 → 2, 1 → 1)
  CHIP   = 1 ("DEFLECTED")              (e.g. 3 → 1)

CORRODED (+1 incoming) applies AFTER the tier transform.
Precision Strike (flank + intact weapon + target not in heavy cover)
  = forced CLEAN + 1 bonus damage.
```

Example: PLASMA-CUTTER (3 dmg) vs target in LIGHT cover, not flanked,
mid-range → GRAZE → 2 damage. Same shot from a flank → CLEAN → 3 damage.

Pre-attack preview: first tap on a target shows the predicted tier and damage
(`HUD.set_attack_preview`); second tap commits. The preview and the resolution
call the same pure function, so they can never disagree.

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
- Graze ladder (CombatConstants): `TIER_PENALTY_LIGHT_COVER=1`,
  `TIER_PENALTY_HEAVY_COVER=2`, `TIER_PENALTY_BRACE=1`,
  `TIER_PENALTY_MAX_RANGE=1`, `TIER_BONUS_ADJACENT=1`,
  `GRAZE_DAMAGE_REDUCTION=1`, `CHIP_DAMAGE=1`
  (safe ranges: penalties 1–2; reductions 1; raising CHIP_DAMAGE above 1
  collapses the value of cover — don't)

## Acceptance Criteria

- [x] Player can attack adjacent enemy (melee)
- [x] Player can attack ranged enemy within attack_range with LOS
- [x] Gear fracture cascade fires in correct priority order
- [x] Hazard damage applies at end of round, not during enemy turn
- [x] Mission fails immediately when leader is downed
- [x] CombatCutaway plays for every attack (unless fast-mode)
