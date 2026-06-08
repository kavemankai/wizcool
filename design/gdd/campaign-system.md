# Campaign System

> **Status**: In Design
> **Author**: kyler + Claude
> **Last Updated**: 2026-06-07
> **Implements Pillar**: SCARCITY IS THE PRESSURE (each mission compounds gear attrition)

## Overview

Fringe Ledger is structured as a series of short campaigns. Each campaign is a self-contained narrative job — a Prison Break, a Heist, a Courier Run — broken into 2 to 4 sequential missions that tell that story: gather the gear, breach the facility, fight out, get away. Missions within a campaign share a gear state: damage taken in Mission 1 enters Mission 2 unrewarded. Full Terminal Hub access is available between every mission, so the player can repair and prepare — but credits are finite, and the next mission is always coming. On mission failure the player chooses: retry freely with no penalty, or abandon the campaign and walk away with all intact gear fractured. Abandoning is a deliberate strategic exit — cut your losses before a second failure breaks gear you can't afford to replace. Completing a campaign unlocks the next one. The Vanguard rival scales with completed campaigns, not individual mission failures, so abandoning doesn't make the next campaign harder — only winning does.

## Player Fantasy

Each campaign feels like taking a job that's bigger than you thought. You scope the first mission, conserve gear, come out ahead — then the Terminal Hub reminds you there's a second mission before you get paid. The pressure isn't from a single fight; it's the knowledge that gear you spend now is gear you won't have later in the same job. Abandoning a campaign feels like a real decision: you're not quitting because the game got hard, you're making a business call — walking away from the Danger Pay to protect equipment that will matter in the next contract. Finishing a campaign feels earned. The Vanguard being tied to completions, not failures, means you're competing against your own progress — every campaign you close makes the next one harder, but that's the trade for the credits.

## Detailed Design

### Core Rules

1. The game is structured as a sequence of campaigns. Campaigns unlock sequentially; the next campaign becomes available after the previous one is completed or abandoned.
2. Each campaign contains 2–4 missions played in a fixed order. Missions within a campaign cannot be reordered or skipped.
3. Full Terminal Hub access is available between every mission in a campaign (repair gear, spend loot, review crew state).
4. On mission failure the player chooses:
   - **Retry** — re-attempt the same mission with the same gear state. No penalty. No limit on retries.
   - **Abandon** — exit the campaign. All currently Intact gear on all crew becomes Fractured. Danger Pay for the campaign is forfeited. The campaign resets to Mission 1 next time it is selected.
5. Completing all missions in a campaign pays full Danger Pay, applies any campaign reward, and unlocks the next campaign. Vanguard rank increments by 1.
6. Vanguard rank increments only on campaign completion — never on individual mission failures, retries, or abandons.

### Campaign Data Structure

Each campaign is defined as a data record:

```
campaign_id:     String           # "containment-breach", "prison-break"
title:           String           # Display name
description:     String           # One-line flavour text shown in Terminal Hub
missions:        Array[MissionDef]
danger_pay:      int              # Credits paid on completion
```

Each `MissionDef`:

```
mission_id:      String           # "containment-breach-1", "prison-break-2"
title:           String           # "Gear Run", "The Break-In"
map_id:          String           # Which tile map to load
objective:       ObjectiveType    # EXTRACTION | ELIMINATION | SURVIVAL | RETRIEVE
objective_data:  Dictionary       # Varies by type (see Objective Types below)
enemy_config:    Array[EnemyDef]  # Spawns for this specific mission
```

### Objective Types

| Type | Win Condition | Required Data |
|---|---|---|
| **EXTRACTION** | Move ALPHA to `target_tile` | `target_tile: Vector2i` |
| **ELIMINATION** | All enemies downed | *(none)* |
| **SURVIVAL** | Complete `survive_rounds` rounds without all crew down | `survive_rounds: int` |
| **RETRIEVE** | Reach `item_tile`, then reach `extract_tile` with ALPHA | `item_tile: Vector2i`, `extract_tile: Vector2i` |

RETRIEVE has two phases:
- Phase 1: ALPHA must stand on `item_tile` (auto-collected when player moves there)
- Phase 2: extraction tile activates; same EXTRACTION logic applies

### Campaign 2 (Prison Break) — Outline

| # | Title | Objective | Map | Notes |
|---|---|---|---|---|
| PB-1 | Gear Run | EXTRACTION | Map B | Retrieve contraband cache; light enemies, new layout |
| PB-2 | The Break-In | ELIMINATION | Map C | Clear the guard room before the breach team moves |
| PB-3 | Breakout | SURVIVAL (8 rounds) | Map D | Hold the corridor while the doors are cut |
| PB-4 | The Getaway | RETRIEVE | Map B (remixed) | Grab the evidence, reach the vehicle bay |

*Map B, C, D are new hand-authored 12×20 layouts. Map B remixed for PB-4 uses same tile data with different enemy placement and extraction point.*

### GameState Changes

Two new fields required on `GameState`:
- `current_campaign_id: String` — which campaign is active
- `current_mission_index: int` — which mission within the campaign (0-based)

### States and Transitions

```
[TERMINAL HUB]
    │ select campaign / continue
    ▼
[MISSION LOADING] — reads campaign_id + mission_index from GameState, loads map + enemies
    │ mission start
    ▼
[IN MISSION]
    │ win condition met ──────────────────────────────────► [POST MISSION SCREEN]
    │ all crew down / leader downed / round limit             │ success path
    ▼                                                         │ mission_index += 1
[FAILURE SCREEN]                                              │ if last mission: campaign complete
    │ Retry ──────────────────────────────────────────────► [TERMINAL HUB]
    │ Abandon ─► intact gear → fractured, campaign resets ► [TERMINAL HUB]
```

### Interactions with Other Systems

- **GameState** (Autoload): owns `current_campaign_id`, `current_mission_index`, `crew` gear state. Campaign system reads/writes these on every transition.
- **Terminal Hub**: reads `current_campaign_id` and `mission_index` to display progress and the "next mission" briefing. New screen state needed for campaign selection vs. mid-campaign Hub.
- **Main.gd**: reads `MissionDef` at load time to configure map, enemies, and objective. Win condition logic branches on `objective` type.
- **PostMissionScreen**: on success, increments `mission_index` or closes campaign. On failure, shows Retry / Abandon choice.

## Formulas

### Campaign Unlock

```
campaigns_unlocked = campaigns_completed + 1
```

The next campaign becomes available as soon as the previous one is completed. There is no unlock delay or credit gate. Campaign 1 (Containment Breach) is always available.

**Variables:**

| Variable | Type | Description |
|---|---|---|
| `campaigns_unlocked` | int | Total number of campaigns accessible to the player |
| `campaigns_completed` | int | Total campaigns finished (stored on GameState) |

There are no mathematical formulas for damage, gear, or economy in this system — those are owned by the Gear Economy and Combat GDDs. The Campaign system is structural.

## Edge Cases

- **ALPHA downed while standing on `item_tile` (RETRIEVE Phase 1):** Item is not collected. Mission fails. The downed check fires before the tile-standing check — ALPHA must be alive and on the tile simultaneously.
- **All enemies downed before SURVIVAL round limit:** Mission continues until the round limit is reached. There is no early-win for SURVIVAL — the narrative beat is holding the corridor, not clearing it.
- **ALPHA downed during RETRIEVE Phase 2 (carrying item):** Mission fails. Item is not retained. Phase 2 uses standard EXTRACTION failure logic.
- **Retry on SURVIVAL mission:** Round counter resets to 0. Gear state carries as-is (whatever it was when the failure occurred). No gear penalty on retry.
- **Abandon Campaign 1 (the first campaign):** Campaign resets to Mission 1 as normal. Gear penalty still applies — abandoning the first campaign is a valid strategic choice if gear state is critical.
- **`current_mission_index` out of range (e.g., save file corruption or bad data):** Default to 0 (Mission 1 of the active campaign) and log a warning. Never crash or produce an inaccessible state.
- **Credits below 0 mid-campaign:** Allowed. Crew works in debt. The Terminal Hub will show negative credits. Repair and purchase actions are blocked when credits are insufficient, but the game does not halt.
- **Player abandons during the last mission of a campaign:** Full Abandon penalty applies. The player forfeits Danger Pay and takes the gear penalty even though they were one mission from completing. This is intentional — abandoning the final mission is the highest-stakes version of the decision.

## Dependencies

- **GameState** *(hard)* — owns `current_campaign_id`, `current_mission_index`, `crew` gear state, `campaigns_completed`. Campaign system cannot function without it. GameState's GDD must acknowledge the campaign fields.
- **Main.gd** *(hard)* — reads `MissionDef` at load time to configure map, enemies, and objective. Win condition logic branches on `objective` type. Main.gd drives the IN MISSION state.
- **PostMissionScreen** *(hard)* — presents the Retry / Abandon choice on failure. On success, increments `mission_index` or closes the campaign and pays Danger Pay. PostMissionScreen owns the Abandon gear-penalty execution.
- **Terminal Hub** *(hard)* — reads `current_campaign_id` and `mission_index` to display campaign progress and the next mission briefing. Requires a new screen state for campaign selection vs. mid-campaign Hub.
- **SaveManager** *(hard)* — serialises `current_campaign_id`, `current_mission_index`, and `campaigns_completed` to disk. A save mid-campaign must restore all three fields correctly.
- **Gear Economy** *(soft)* — Abandon penalty transitions Intact → Fractured. The campaign system calls the gear state change; GearItem defines the valid transitions. GearItem's GDD must acknowledge the Abandon path as a valid fracture trigger.
- **Vanguard Rival** *(soft)* — Vanguard rank is incremented by the campaign completion handler, not the rival system itself. The rival system reads `vanguard_rank` from GameState; this system writes it.
- **Audio** *(soft)* — mission_complete and mission_fail signals trigger audio events. The campaign system fires these signals; AudioManager listens. Works without audio.

## Tuning Knobs

| Knob | Default | Safe Range | Effect |
|---|---|---|---|
| Missions per campaign | 2–4 | 1–6 | Shorter campaigns feel episodic; longer campaigns increase pressure and gear attrition window |
| SURVIVAL round target | 8 | 4–15 | Below 4 trivialises the objective; above 15 creates fatigue without additional tactical variation |
| Abandon gear penalty | Intact → Fractured | *(binary)* | Currently a fixed transition; no partial penalty variant is planned. Changing this changes the core risk calculus. |
| Vanguard rank increment per campaign completion | 1 | 0–2 | 0 disables Vanguard scaling entirely; 2 accelerates rival difficulty for experienced players |
| Danger Pay per campaign | Defined per campaign data record | Varies | Tune per campaign based on mission count and risk. Higher pay = stronger incentive to complete vs. abandon. |

## Acceptance Criteria

- **GIVEN** a player completes all missions in a campaign, **WHEN** PostMissionScreen processes the final mission success, **THEN** Danger Pay is added to credits, `campaigns_completed` increments by 1, Vanguard rank increments by 1, and the next campaign is unlocked in the Terminal Hub.
- **GIVEN** a mission failure, **WHEN** the player selects Retry, **THEN** the same mission reloads with the same gear state (no changes), no credits are deducted, and no gear transitions occur.
- **GIVEN** a mission failure, **WHEN** the player selects Abandon, **THEN** all Intact gear on all crew becomes Fractured, Danger Pay is not paid, `current_mission_index` resets to 0, and the player returns to the Terminal Hub.
- **GIVEN** an active campaign with `mission_index` at the final mission, **WHEN** that mission is completed, **THEN** the campaign is treated as complete (Danger Pay paid, Vanguard incremented) — not as "one more mission to go."
- **GIVEN** a SURVIVAL mission, **WHEN** all enemies are downed before the round limit, **THEN** the mission continues running until the round limit is reached. The mission does not end early.
- **GIVEN** a RETRIEVE mission, **WHEN** ALPHA moves onto `item_tile`, **THEN** the item is auto-collected and the `extract_tile` activates. Phase 1 is complete without any additional player input.
- **GIVEN** a RETRIEVE mission in Phase 2, **WHEN** ALPHA reaches `extract_tile`, **THEN** the mission ends with a success result — same as EXTRACTION win logic.
- **GIVEN** `current_mission_index` is set to a value out of range for the active campaign, **WHEN** the mission loading screen reads the campaign, **THEN** `mission_index` is clamped to 0, a warning is logged, and Mission 1 loads without a crash.

## Open Questions

[To be designed]

## Open Questions

[To be designed]
