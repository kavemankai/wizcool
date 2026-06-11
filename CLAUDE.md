# FRINGE LEDGER — Claude Code Reference

> **First session in a new context?** Run `/start` to orient, or `/sprint-status` to see current work.

## What this is

Tactical gear-focused sRPG. Industrial hard sci-fi / cassette-futurism aesthetic. Locked orthographic grid. Characters never level up — only gear progresses. Gear has physical state: Intact → Fractured → Broken.

**Genre:** Tactical sRPG
**Engine:** Godot 4.6, GDScript
**Viewport:** 1280×720, locked orthographic

## Core Loop

```
[SALVAGE MANIFEST] → [TACTICAL SKIRMISH] → [FRACTURED GEAR RESOLUTION] → [TERMINAL HUB]
```

## Configuration References

@.claude/docs/directory-structure.md
@.claude/docs/technical-preferences.md
@.claude/docs/coordination-rules.md
@.claude/docs/coding-standards.md
@.claude/docs/context-management.md

## Engine Version

@docs/engine-reference/godot/VERSION.md

## Project Structure

```
res://
  scenes/
    Main.tscn               # Skirmish scene root
    ui/
      ManifestScreen.tscn
      PostMissionScreen.tscn
      TerminalHub.tscn
  scripts/
    Main.gd                 # Input routing, turn loop, AI dispatch
    core/
      GridPos.gd | GridManager.gd | LOSCalculator.gd | MovementRange.gd
    units/
      Unit.gd | GearItem.gd
      ai/  EnemyAI.gd | GuardianAI.gd | RampagingAI.gd | TacticalAI.gd
    systems/
      CombatResolver.gd | HazardSystem.gd
      (stubs) GearSystem.gd | HazardSystem.gd | MissionSystem.gd | RivalSystem.gd
    ui/
      HUD.gd | CombatCutaway.gd | CutawayUnit.gd
      ManifestScreen.gd | PostMissionScreen.gd | TerminalHub.gd
    data/
      GameState.gd (AUTOLOAD) | SaveManager.gd (AUTOLOAD)
```

## Autoloads

Exactly two autoloads:
- `GameState` — credits, vanguard_rank, crew, gear/broken/fractured inventory, last_mission_result, pending_loot, show_cutaway
- `SaveManager` — `save()` and `load_save()` only; JSON serialisation

## Grid Spec

- 12 wide × 20 tall tiles, 32×32 px, centred in viewport at runtime
- Three tile types: FLOOR, WALL, COVER
- Camera2D locked — no pan/zoom

## Key Data Structures

```gdscript
enum Archetype { NONE, GUARDIAN, RAMPAGING, TACTICAL }
enum DamageResult { NORMAL, GEAR_FRACTURED, GEAR_BROKEN, DOWNED }
enum GearState { INTACT, FRACTURED, BROKEN }    # in GearItem

var unit_id: String
var is_player: bool | is_leader: bool
var grid_pos: GridPos          # GridPos.x / GridPos.y (int)
var toughness / max_toughness: int
var gear: Array[GearItem]
var archetype: int             # enemies only
```

## Phase Build Order

- **Phase 1–12:** ✅ Complete — full prototype: grid → combat → AI → gear economy → hazards → rival crew → mission loop → hub → polish → combat depth (cover/precision/AoE/specials/status) → audio foundation
- **v1.0 Release Plan** (mobile game, see `.claude/plans` / git history):
  - **R1 Graze combat** ✅ — deterministic CLEAN/GRAZE/DEFLECTED tier ladder, two-tap attack preview, tier-aware AI
  - **R2 Sprite tech** ✅ — textured _draw with full programmatic fallbacks (SpriteLib; art lands incrementally)
  - **R3 Art generation** ⏳ — unit standees, tileset, title/icons (SpriteCook plugin or Flow pipeline)
  - **R4 App shell** ✅ — TitleScreen (main_scene), SettingsMenu (user://settings.cfg), PauseMenu, Android back button
  - **R5 Audio** ✅ SFX (procedural, tools/generate_sfx.py) / ⏳ chiptune music loops (user-approved CC0 download)
  - **R6 Campaign** ✅ — "First Repossession" 5-mission beginner job (colony-repossession, default campaign); old campaigns are unlockable bonus contracts via hub contract select
  - **R7 Android export** ✅ config (gl_compatibility, export_presets.cfg, docs/release/android.md) / ⏳ user-manual SDK+keystore+device test
  - **R8 Release QA** ⏳ — store assets, device checklist, full playthrough

## Enemy Archetypes

| Archetype | Behaviour |
|---|---|
| Guardian | Patrol route, engage on LOS, stay in zone |
| Rampaging | Charge nearest unit regardless of faction |
| Tactical | Hold, wait for weakness, advance, hunt leader |

## Gear State Model

| State | Modifier | Recovery |
|---|---|---|
| Intact | Full | N/A |
| Fractured | Nullified (50% if field-patched) | Field-patch (once per item per mission) |
| Broken | Absent | Full repair at Terminal Hub (credits) |

## Failure States

- Leader downed (0 TGH with Fractured gear) → mission fail
- Round limit 20 → mission fail
- All crew down → mission fail
- Penalty: all Intact gear → Fractured, no Danger Pay, Vanguard Rank +1

## Risk Flags

- **Grid centering** — `get_viewport_rect().size` in `Main.gd _ready()`, not hardcoded
- **class_name forward refs** — GridPos/GridManager must parse before dependents
- **Async turn loop** — `_do_attack()` and `_run_enemy_phase()` use `await`; callers must `await` them
- **CombatResolver** — ALL damage routes through `CombatResolver.resolve_damage()` — never call `unit.take_damage()` directly

## GodotPrompter Skills (project-scoped v1.9.0)

| When working on… | Skill |
|---|---|
| Tweens, easing, motion sequences | `/tween-animation` |
| GDScript typing, coroutines, await | `/gdscript-patterns` |
| Turn state machine, phase transitions | `/state-machine` |
| SaveManager, GameState, JSON | `/save-load` |
| HUD layout, Control nodes, buttons | `/godot-ui` or `/hud-system` |
| Enemy AI, pathfinding | `/ai-navigation` |
| Adding audio (not yet implemented) | `/audio-system` |
| 2D rendering, CanvasLayer, draw calls | `/2d-essentials` |
| Scene tree / node composition | `/scene-organization` |
| Signal architecture | `/event-bus` |
| Performance profiling | `/godot-optimization` |
| Debugging signals / remote debugger | `/godot-debugging` |

## Studio Workflow Skills

| Task | Skill |
|---|---|
| Start or resume a session | `/start` |
| Plan the current sprint | `/sprint-plan` |
| Check sprint progress | `/sprint-status` |
| Implement a story | `/dev-story` |
| Mark a story complete | `/story-done` |
| Review code | `/code-review` |
| File a bug | `/bug-report` |
| Triage bugs | `/bug-triage` |
| Check phase gate readiness | `/gate-check` |
| Design a new system | `/design-system` |
| Technical debt review | `/tech-debt` |
| Security audit | `/security-audit` |

## Agents

Spawn via the Agent tool. Key agents for this project:

| Agent | Use for |
|---|---|
| `godot-gdscript-specialist` | All `.gd` implementation work |
| `godot-specialist` | Scene files, project config, Godot-specific issues |
| `lead-programmer` | Cross-system decisions, code review, story routing |
| `technical-director` | Architecture decisions, ADRs, system design |
| `gameplay-programmer` | Combat system, AI, gear economy logic |
| `systems-designer` | Balance, game feel, mechanic design |
| `ui-programmer` | HUD, CombatCutaway, Control tree |
| `producer` | Sprint planning, milestone tracking |
| `qa-lead` | Test planning, bug triage |
| `performance-analyst` | Profiling, optimisation |
