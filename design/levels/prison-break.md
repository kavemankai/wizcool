# Prison Break — Level Design
> **Campaign**: Prison Break (Campaign 2)
> **Maps**: B, C, D (+ Map B remixed for PB-4)
> **Author**: kyler + Claude
> **Last Updated**: 2026-06-07

## Overview

Prison Break consists of four sequential missions across three hand-authored maps. All maps use the standard 12×20 tile grid at 32×32 px. Tile types: FLOOR, WALL, COVER, HAZARD_ZONE.

**Shared design thread**: Every map funnels movement through a 4-tile-wide chokepoint. In Map B the chokepoint is a wall gap; in Map C it's a guarded breach; in Map D it's a narrowed corridor. The player's awareness of this pattern across the campaign creates a sense of the world closing in — by PB-4 (Map B remixed) they know the terrain and the higher enemy count is the escalation.

**Coordinate system**: x = column (0 = left), y = row (0 = top). Perimeter walls are automatic — only non-perimeter tiles are listed.

---

## Map B — Supply Depot

Used in: **PB-1 Gear Run** (EXTRACTION) and **PB-4 The Getaway** (RETRIEVE).

**Defining feature**: Two single-tile storage rack columns (x=4 and x=7, rows 3–7) split the upper zone into three lanes: left (x=1–3), center (x=5–6), right (x=8–10). A partial chokewall at row 11 blocks the left and right lanes — units crossing from the staging area to the upper zone must pass through the center gap (x=4–7). Once past the wall, they can spread into all three lanes.

```
     0  1  2  3  4  5  6  7  8  9 10 11
  0  #  #  #  #  #  #  #  #  #  #  #  #
  1  #  .  .  .  .  .  .  .  .  .  .  #
  2  #  .  C  .  .  .  .  .  .  C  .  #
  3  #  .  .  .  #  .  .  #  .  .  .  #
  4  #  .  .  .  #  .  .  #  .  .  .  #
  5  #  .  C  .  #  .  .  #  .  C  .  #
  6  #  .  .  .  #  .  .  #  .  .  .  #
  7  #  .  .  .  #  .  .  #  .  .  .  #
  8  #  .  .  .  .  .  .  .  .  .  .  #
  9  #  .  C  .  .  .  .  .  .  C  .  #
 10  #  .  .  .  .  .  .  .  .  .  .  #
 11  #  #  #  #  .  .  .  .  #  #  #  #
 12  #  .  .  .  .  .  .  .  .  .  .  #
 13  #  .  .  C  .  .  .  .  C  .  .  #
 14  #  .  .  .  .  .  .  .  .  .  .  #
 15  #  .  .  .  .  .  .  .  .  .  .  #
 16  #  .  .  .  .  .  .  .  .  .  .  #
 17  #  .  .  .  .  .  .  .  .  .  .  #
 18  #  .  .  .  .  .  .  .  .  .  .  #
 19  #  #  #  #  #  #  #  #  #  #  #  #
```

### Map B — Non-Perimeter Tile List

```gdscript
# Left storage rack
_set_tile(4, 3, TileType.WALL); _set_tile(4, 4, TileType.WALL)
_set_tile(4, 5, TileType.WALL); _set_tile(4, 6, TileType.WALL)
_set_tile(4, 7, TileType.WALL)

# Right storage rack
_set_tile(7, 3, TileType.WALL); _set_tile(7, 4, TileType.WALL)
_set_tile(7, 5, TileType.WALL); _set_tile(7, 6, TileType.WALL)
_set_tile(7, 7, TileType.WALL)

# Chokewall (left block x=1–3, right block x=8–10 at row 11)
_set_tile(1, 11, TileType.WALL); _set_tile(2, 11, TileType.WALL)
_set_tile(3, 11, TileType.WALL)
_set_tile(8, 11, TileType.WALL); _set_tile(9, 11, TileType.WALL)
_set_tile(10, 11, TileType.WALL)

# Cover
_set_tile(2, 2, TileType.COVER); _set_tile(9, 2, TileType.COVER)
_set_tile(2, 5, TileType.COVER); _set_tile(9, 5, TileType.COVER)
_set_tile(2, 9, TileType.COVER); _set_tile(9, 9, TileType.COVER)
_set_tile(3, 13, TileType.COVER); _set_tile(8, 13, TileType.COVER)
```

---

### PB-1 — Gear Run (EXTRACTION)

**Objective**: Move ALPHA to extraction tile (5, 1).
**Enemy count**: 3 — light opposition, introductory pacing.
**Tactical read**: Guardians patrol the racks, one per lane. The Rampaging enemy charges from the center gap as soon as the player crosses the chokewall. Players must choose a lane to flank with and draw fire.

#### Player Spawns

| Unit | Stats (hp/cs/spd/rng) | Position | Gear |
|---|---|---|---|
| ALPHA (Leader) | 6/2/3/4 | (5, 18) | PLASMA-CUTTER (dmg 2, rng 3), FIELD-PATCH-KIT |
| BRAVO | 5/2/4/2 | (3, 17) | IMPACT-WRENCH (dmg 1, rng 2), WORK-HARNESS (armor 1) |
| CHARLIE | 4/3/3/5 | (7, 17) | LONG-BORE-DRILL (dmg 1, rng 2) |

#### Enemy Spawns

| Unit | Archetype | Stats (hp/cs/spd/rng) | Position | Guardian Config |
|---|---|---|---|---|
| DEPOT-GUARD-1 | Guardian | 4/2/2/2 | (2, 5) | zone_min=3, zone_max=7, patrol: (2,3)↔(2,7) |
| DEPOT-GUARD-2 | Guardian | 4/2/2/2 | (9, 5) | zone_min=3, zone_max=7, patrol: (9,3)↔(9,7) |
| DEPOT-ENFORCER | Rampaging | 4/2/3/1 | (5, 9) | — |

#### Extraction Tile
`(5, 1)` — the loading dock at the top-center of the depot.

---

### PB-4 — The Getaway (RETRIEVE)

**Objective**: Phase 1 — ALPHA reaches item tile (5, 8) to collect the evidence cache. Phase 2 — ALPHA reaches extract tile (5, 1).
**Enemy count**: 5 — same map, heavier opposition.
**Tactical read**: The enemy group is now split between the upper zone (two Guardians at top) and the mid-zone (Tactical + two Guardians flanking the center gap). Phase 1 requires pushing into a contested center. Phase 2 requires a hard push to the top while enemies are already in close contact.

#### Player Spawns
Same as PB-1: ALPHA (5,18), BRAVO (3,17), CHARLIE (7,17). Gear carries forward from PB-3.

#### Enemy Spawns

| Unit | Archetype | Stats | Position | Guardian Config |
|---|---|---|---|---|
| ESCAPE-GUARD-1 | Guardian | 4/2/2/2 | (2, 2) | zone_min=1, zone_max=4, patrol: (2,1)↔(2,4) |
| ESCAPE-GUARD-2 | Guardian | 4/2/2/2 | (9, 2) | zone_min=1, zone_max=4, patrol: (9,1)↔(9,4) |
| ESCAPE-ENFORCER | Tactical | 5/3/2/3 | (5, 9) | advance_triggered=false, hunts ALPHA |
| ESCAPE-GUARD-3 | Guardian | 4/2/2/2 | (2, 9) | zone_min=8, zone_max=11, patrol: (2,8)↔(2,10) |
| ESCAPE-GUARD-4 | Guardian | 4/2/2/2 | (9, 9) | zone_min=8, zone_max=11, patrol: (9,8)↔(9,10) |

#### Objective Tiles
- Item tile (evidence cache): `(5, 8)` — center lane, below racks, above chokewall.
- Extract tile (vehicle bay): `(5, 1)` — same as PB-1 extraction.

---

## Map C — Security Block

Used in: **PB-2 The Break-In** (ELIMINATION).

**Defining feature**: Two 2-tile guard booth stubs (x=4 and x=7, rows 4–5) flank the central corridor in the upper zone. Cover pieces at (3,4) and (8,4) sit just outside the booths — enemies use them as hard points. A chokewall at row 7 (gaps at x=4–7) forces the player to compress before reaching the guard positions. All 5 enemies must be downed; there is no extraction tile.

```
     0  1  2  3  4  5  6  7  8  9 10 11
  0  #  #  #  #  #  #  #  #  #  #  #  #
  1  #  .  .  .  .  .  .  .  .  .  .  #
  2  #  .  C  .  .  .  .  .  .  C  .  #
  3  #  .  .  .  .  .  .  .  .  .  .  #
  4  #  .  .  C  #  .  .  #  C  .  .  #
  5  #  .  .  .  #  .  .  #  .  .  .  #
  6  #  .  .  .  .  .  .  .  .  .  .  #
  7  #  #  #  #  .  .  .  .  #  #  #  #
  8  #  .  .  .  .  .  .  .  .  .  .  #
  9  #  .  C  .  .  .  .  .  .  C  .  #
 10  #  .  .  .  .  .  .  .  .  .  .  #
 11  #  .  .  .  .  .  .  .  .  .  .  #
 12  #  .  .  C  .  .  .  .  C  .  .  #
 13  #  .  .  .  .  .  .  .  .  .  .  #
 14  #  .  .  .  .  .  .  .  .  .  .  #
 15  #  .  .  .  .  .  .  .  .  .  .  #
 16  #  .  .  .  .  .  .  .  .  .  .  #
 17  #  .  .  .  .  .  .  .  .  .  .  #
 18  #  .  .  .  .  .  .  .  .  .  .  #
 19  #  #  #  #  #  #  #  #  #  #  #  #
```

### Map C — Non-Perimeter Tile List

```gdscript
# Left guard booth stub
_set_tile(4, 4, TileType.WALL); _set_tile(4, 5, TileType.WALL)

# Right guard booth stub
_set_tile(7, 4, TileType.WALL); _set_tile(7, 5, TileType.WALL)

# Chokewall (left block x=1–3, right block x=8–10 at row 7)
_set_tile(1, 7, TileType.WALL); _set_tile(2, 7, TileType.WALL)
_set_tile(3, 7, TileType.WALL)
_set_tile(8, 7, TileType.WALL); _set_tile(9, 7, TileType.WALL)
_set_tile(10, 7, TileType.WALL)

# Cover
_set_tile(2, 2, TileType.COVER); _set_tile(9, 2, TileType.COVER)
_set_tile(3, 4, TileType.COVER); _set_tile(8, 4, TileType.COVER)
_set_tile(2, 9, TileType.COVER); _set_tile(9, 9, TileType.COVER)
_set_tile(3, 12, TileType.COVER); _set_tile(8, 12, TileType.COVER)
```

### PB-2 — The Break-In (ELIMINATION)

**Objective**: All enemies downed. No extraction tile.
**Enemy count**: 5 — entrenched, varied archetypes.
**Tactical read**: Two Guardians in the top-back zone provide overwatch and will alert when the player crosses the chokewall. Two Rampaging units are positioned in the booth area — they charge as soon as the player enters LOS, potentially before the player is ready to split focus. The Tactical enemy holds the center of the chokewall gap and advances only when the leader is isolated. The player must decide whether to draw the Rampaging units out before breaching, or breach hard and fight the chaos.

#### Player Spawns
Same formation: ALPHA (5,18), BRAVO (3,17), CHARLIE (7,17). Gear carries forward from PB-1.

#### Enemy Spawns

| Unit | Archetype | Stats | Position | AI Config |
|---|---|---|---|---|
| GUARD-CAPTAIN | Tactical | 5/3/2/3 | (5, 3) | advance_triggered=false |
| BLOCK-GUARD-1 | Guardian | 4/2/2/2 | (2, 2) | zone_min=1, zone_max=4, patrol: (2,1)↔(2,4) |
| BLOCK-GUARD-2 | Guardian | 4/2/2/2 | (9, 2) | zone_min=1, zone_max=4, patrol: (9,1)↔(9,4) |
| RIOT-1 | Rampaging | 4/2/3/1 | (3, 5) | — |
| RIOT-2 | Rampaging | 4/2/3/1 | (8, 5) | — |

---

## Map D — Cell Block Corridor

Used in: **PB-3 Breakout** (SURVIVAL, 8 rounds).

**Defining feature**: Rows 4–6 are almost entirely wall — the inner cell block walls at x=1–3 and x=8–10 reduce the passable corridor to exactly 4 tiles wide (x=4–7). Enemies spawned in the open top zone (rows 1–3) must funnel through this narrow corridor to reach the player. Two HAZARD_ZONE tiles at (5,11) and (6,11) mark a burst steam line — this narrows the player's safe anchor zone and creates a risk of holding the exact center of the map. Cover at (2,8) and (9,8) forms the natural defensive line just below the corridor exit.

```
     0  1  2  3  4  5  6  7  8  9 10 11
  0  #  #  #  #  #  #  #  #  #  #  #  #
  1  #  .  .  .  .  .  .  .  .  .  .  #
  2  #  .  C  .  .  .  .  .  .  C  .  #
  3  #  .  .  .  .  .  .  .  .  .  .  #
  4  #  #  #  #  .  .  .  .  #  #  #  #
  5  #  #  #  #  .  .  .  .  #  #  #  #
  6  #  #  #  #  .  .  .  .  #  #  #  #
  7  #  .  .  .  .  .  .  .  .  .  .  #
  8  #  .  C  .  .  .  .  .  .  C  .  #
  9  #  .  .  .  .  .  .  .  .  .  .  #
 10  #  .  .  .  .  .  .  .  .  .  .  #
 11  #  .  C  .  .  H  H  .  .  C  .  #
 12  #  .  .  .  .  .  .  .  .  .  .  #
 13  #  .  .  .  .  .  .  .  .  .  .  #
 14  #  .  .  C  .  .  .  .  C  .  .  #
 15  #  .  .  .  .  .  .  .  .  .  .  #
 16  #  .  .  .  .  .  .  .  .  .  .  #
 17  #  .  .  .  .  .  .  .  .  .  .  #
 18  #  .  .  .  .  .  .  .  .  .  .  #
 19  #  #  #  #  #  #  #  #  #  #  #  #
```

### Map D — Non-Perimeter Tile List

```gdscript
# Left cell block walls (rows 4–6, x=1–3)
for y in range(4, 7):
    for x in range(1, 4):
        _set_tile(x, y, TileType.WALL)

# Right cell block walls (rows 4–6, x=8–10)
for y in range(4, 7):
    for x in range(8, 11):
        _set_tile(x, y, TileType.WALL)

# Cover
_set_tile(2, 2, TileType.COVER); _set_tile(9, 2, TileType.COVER)
_set_tile(2, 8, TileType.COVER); _set_tile(9, 8, TileType.COVER)
_set_tile(2, 11, TileType.COVER); _set_tile(9, 11, TileType.COVER)
_set_tile(3, 14, TileType.COVER); _set_tile(8, 14, TileType.COVER)

# Hazard — burst steam line
_set_tile(5, 11, TileType.HAZARD_ZONE); _set_tile(6, 11, TileType.HAZARD_ZONE)
```

### PB-3 — Breakout (SURVIVAL, 8 rounds)

**Objective**: At least one crew member alive when round 9 begins.
**Enemy count**: 5 — sustained pressure, not a wave but a sustained assault.
**Tactical read**: Two Rampaging units at (2,1) and (9,1) charge immediately. The cells block their path — they must reach x=4 or x=7 before entering the corridor, so they arrive at the player zone around round 3. E4 (Rampaging at (2,3)) arrives a round later as a second wave. The two Guardians hold the top and advance methodically, providing back pressure throughout. The hazard tiles at (5,11) and (6,11) discourage retreating to the center of the lower zone — the player is pushed left or right, thinning their defensive front. The cover at (2,8) and (9,8) is the intended anchor.

The player CAN kill all 5 enemies — doing so ends the active threat but the round counter continues to 8. Victory requires outlasting, not eliminating.

#### Player Spawns
Same formation: ALPHA (5,18), BRAVO (3,17), CHARLIE (7,17). Gear carries forward from PB-2.

#### Enemy Spawns

| Unit | Archetype | Stats | Position | AI Config |
|---|---|---|---|---|
| WARDEN | Guardian | 5/2/2/2 | (5, 2) | zone_min=1, zone_max=3, patrol: (4,2)↔(6,2) |
| BLOCK-RUNNER-1 | Rampaging | 4/2/3/1 | (2, 1) | — |
| BLOCK-RUNNER-2 | Rampaging | 4/2/3/1 | (9, 1) | — |
| BLOCK-RUNNER-3 | Rampaging | 4/2/3/1 | (2, 3) | — |
| LOCKDOWN-GUARD | Guardian | 4/2/2/2 | (9, 3) | zone_min=1, zone_max=6, patrol: (9,1)↔(9,3) |

---

## Design Notes

### Chokepoint Consistency
All three maps use a 4-tile-wide chokepoint (same width as the racks' center gap in Map B, the booth wall gap in Map C, and the narrowed corridor in Map D). This is intentional — the player internalises the tactic (funnel enemies through, use the sides) and PB-4 rewards that knowledge by using the familiar Map B terrain under pressure.

### Enemy Toughness Calibration
All enemies in this campaign are stat-copied from the prototype mission enemies (toughness 4–5, combat_skill 2–3). No enemy should require more than 3 player hits to down. The threat is from positioning and volume, not individual enemy bulk.

### Gear Carry-Forward Pressure
- PB-1 (3 enemies): Player should exit with gear mostly intact — low attrition is the lesson.
- PB-2 (5 enemies, entrenched): First serious gear pressure. Players who played aggressively in PB-1 will start PB-2 with fractured gear.
- PB-3 (5 enemies, sustained pressure): Even a clean PB-2 will leave some gear fractured. The Terminal Hub between PB-2 and PB-3 is the key repair window — credits spent here are unavailable for PB-4.
- PB-4 (5 enemies, familiar terrain): Players who over-repaired before PB-3 will be underprepared here. Players who held credits will have a repair window available.

### Map B Remix Logic (PB-4)
Map B (same tile data) works for PB-4 because:
1. The player is familiar with the lanes — surprise is gone, enemy density is the escalation
2. Item tile (5,8) is in the center lane, requiring the chokewall crossing the player did in PB-1
3. Extract tile is the same (5,1) — the "get to the loading dock" logic is familiar, making the increased opposition the only new variable
4. The two flanking Guardian pairs (top + mid-zone) mean the player cannot clear the map from one side — all three lanes must be contested

---

## Implementation Reference

Map IDs to use in campaign data:
- `"map-supply-depot"` → calls `_place_map_b()` in GridManager
- `"map-security-block"` → calls `_place_map_c()`
- `"map-cell-corridor"` → calls `_place_map_d()`
- `"map-supply-depot-remixed"` → calls `_place_map_b()` (same tiles, different entity spawns)

The `MissionDef.map_id` string drives which layout function GridManager calls on `_ready()`. Each function replaces `_place_prototype_layout()` depending on the active mission.
