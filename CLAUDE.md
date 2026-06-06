# FRINGE LEDGER — Claude Code Reference

## What this is

Tactical gear-focused sRPG. Industrial hard sci-fi / cassette-futurism aesthetic. Locked orthographic grid. Characters never level up — only gear progresses. Gear has physical state: Intact → Fractured → Broken.

**Genre:** Tactical sRPG  
**Engine:** Godot 4.x, GDScript  
**Viewport:** 1280×720, locked orthographic

## Core Loop

```
[SALVAGE MANIFEST] → [TACTICAL SKIRMISH] → [FRACTURED GEAR RESOLUTION] → [TERMINAL HUB]
```

## Project Structure

```
res://
  scenes/
    Main.tscn           # Phase 1: Grid shell, unit, camera
  scripts/
    GridPos.gd          # class_name GridPos — grid coordinate value object
    GridManager.gd      # class_name GridManager — tile storage, draw, coordinate conversion
    Unit.gd             # class_name Unit — drawn unit, selection state
    Main.gd             # Root controller — input, unit spawn, selection
  assets/
    audio/
    sprites/
```

## Grid Spec

- 12 wide × 20 tall tiles
- Tile size: 32×32 px
- Three tile types: `FLOOR`, `WALL`, `COVER`
- Grid centered in viewport at runtime
- Camera2D locked — no pan, no zoom

## Key Data Structures

```gdscript
class_name GridPos          # GridPos.gd
var x: int
var y: int

enum TileType { FLOOR, WALL, COVER }    # defined in GridManager

class_name Unit             # Unit.gd — Phase 1 placeholder
var unit_id: String
var is_player: bool
var is_leader: bool
var grid_pos: GridPos
var is_selected: bool
```

## Key Rules

- `GridManager` owns all tile state and grid↔world coordinate conversion
- `Main.gd` owns input routing and scene-level state — nothing else handles input
- Units are children of `UnitLayer` (sibling of `GridManager`)
- No game logic in UI scripts
- Every phase must produce a runnable build before the next phase starts

## Phase Build Order

- **Phase 1:** ✅ Grid shell — tiles, camera, unit placement, click-to-select
- **Phase 2:** ✅ Combat core — turn order, movement, attack, Toughness, LOS
- **Phase 3:** ✅ Enemy AI — Guardian / Rampaging / Tactical archetypes
- **Phase 4:** ✅ Fractured gear economy — three-state model, field-patch, Medical slot
- **Phase 5:** ✅ Environmental hazards — warning system, pressure dump activation
- **Phase 6:** ✅ The Rival — Vanguard faction, Rival Rank persistence
- **Phase 7:** ✅ Mission loop — SalvageManifest screen, extraction tile (5,2), failure states, MissionResult screen, MissionState autoload
- **Phase 8 (current):** Terminal Hub — repair, fence, contract select, credit economy
- Phase 9: "Containment Breach" — full hand-authored prototype mission
- Phase 10: Polish & feel — terminal aesthetic, audio, animation

## Zone Layout (Containment Breach prototype)

```
Zone C (rows 14–19): Evidence locker — leader-only interaction
Zone B (rows  8–13): Security Bot patrol, narrow corridors, hazard tiles
Zone A (rows  1– 7): Player entry, Feral Prisoners, Vanguard south entry
```

## Enemy Archetypes

| Archetype | Behaviour | Prototype Unit |
|---|---|---|
| Guardian | Patrol route, engage on LOS, stay in zone | Security Bots |
| Rampaging | Charge nearest unit regardless of faction | Feral Prisoners |
| Tactical | Hold, wait for player weakness, advance, hunt leader | Vanguard Crew |

## Gear State Model (Phase 4+)

| State | Modifier | Recovery |
|---|---|---|
| Intact | Full | N/A |
| Fractured | Nullified | Field-patch (1 Combat Action, once per item per mission, restores 50%) |
| Broken | Absent, slot empty | Full repair at Terminal Hub (credit cost) |

## Failure States (Phase 7+)

- Leader Broken (0 Toughness twice with Fractured gear) → mission fail
- Round limit expires (20 rounds prototype) → mission fail
- Consequences: all crew gear Fractured, no Danger Pay, Vanguard Rank +1

## Risk Flags

**Grid centering** — computed in `Main.gd _ready()` using `get_viewport_rect().size`, not hardcoded.

**class_name forward references** — `GridPos` and `GridManager` must be parsed before scripts that reference them. Godot handles this via class_name registration; avoid circular dependencies.

**Phase creep** — do not add Phase N+1 features until Phase N acceptance criteria pass.
