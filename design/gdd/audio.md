# Audio System

> **Status**: Designed
> **Author**: kyler + Claude
> **Last Updated**: 2026-06-07
> **Implements Pillar**: SCARCITY IS THE PRESSURE (audio reinforces consequence and weight)

## Overview

The audio system gives every combat action a physical weight. Each weapon has a distinct industrial sound character — the plasma cutter's electrical burst sounds different from the impact wrench's heavy thud or the long-bore drill's grinding whir. Gear state is audible: an intact weapon hits clean; a fractured one sounds damaged. Fracturing gear has its own crack. Gear breaking and a unit going down have escalating consequence sounds. An industrial ambient loop runs under all of it, reinforcing the cassette-futurism aesthetic. The system is entirely event-driven — it listens to signals from Combat, Gear Economy, Mission, and HUD, and plays the appropriate sound without owning any game state. Audio runs through three buses: SFX (combat and world events), UI (buttons, cutaway), and Music (ambience loop), all under a Master bus with independent volume controls.

## Player Fantasy

Every action in Fringe Ledger is deliberate — there's no dice roll softening a bad outcome. Audio honours that: when a hit lands, it lands with weight. The crack of gear fracturing doesn't feel like a cinematic effect; it feels like something broke that's going to cost credits to fix. The long-bore drill grinding into an enemy sounds like work, not spectacle. The plasma cutter's discharge is sharp and efficient. The ambient machinery hum is constant and low — it doesn't excite, it pressures. Players should feel the industrial grind of the setting in every audio cue, and they should feel the cost of every bad outcome before the UI tells them what it was.

## Detailed Design

### Core Rules

1. Audio is entirely event-driven. The AudioManager node listens to signals; it never polls game state.
2. The AudioManager is an Autoload (`AudioManager`) so it persists across scene transitions (skirmish → Terminal Hub → skirmish).
3. One `AudioStreamPlayer` node per concurrent sound channel. Overlapping sounds (weapon hit + gear fracture in the same frame) play simultaneously on separate players.
4. Fractured weapons use the same attack SFX as intact weapons. Gear state audio plays only on fracture/break events, not on every attack.
5. Music crossfades between Calm and Tension states over 1.0 seconds. No abrupt cuts.

### Bus Layout

```
Master
├── SFX     — combat hits, gear events, mission events
├── Music   — ambient loop (calm + tension states)
└── UI      — button clicks, cutaway sounds
```

### Event Map

| Game Event | Signal Source | Sound | Bus |
|---|---|---|---|
| Attack lands — NORMAL | `Main.gd` | Weapon SFX (by slot) | SFX |
| Attack lands — GEAR_FRACTURED | `Main.gd` | Weapon SFX + `gear_fracture` | SFX |
| Attack lands — GEAR_BROKEN | `Main.gd` | Weapon SFX + `gear_break` | SFX |
| Unit downed | `Unit.unit_downed` | `unit_downed` | SFX |
| Field Patch used | `Main.gd` | `field_patch` | SFX |
| Enemy phase starts | `Main.gd` | Music → Tension | Music |
| Player turn starts | `Main.gd` | Music → Calm | Music |
| Mission complete | `Main.gd` | `mission_complete` | SFX |
| Mission fail | `Main.gd` | `mission_fail` | SFX |
| Any HUD button pressed | `HUD` (button.pressed) | `ui_click` | UI |
| Cutaway dismissed | `CombatCutaway.cutaway_dismissed` | `cutaway_dismiss` | UI |

### Per-Weapon Sound Characters

| Weapon | Slot | Sound Character | Duration |
|---|---|---|---|
| PLASMA-CUTTER | weapon | Sharp electrical discharge — high-pitched crack, brief buzz tail | Short (~0.3s) |
| IMPACT-WRENCH | weapon | Heavy metallic thud — low-frequency impact, physical weight | Short (~0.25s) |
| LONG-BORE-DRILL | weapon | Grinding mechanical whir — sustained build then crunch impact | Medium (~0.5s) |
| SALVAGE-PISTOL | weapon | Ballistic crack — lightweight, dry, utilitarian | Short (~0.2s) |

Weapons without a `damage` value (armor, medical) never trigger weapon SFX.

### Gear Event Sounds

| Event | Sound Character |
|---|---|
| `gear_fracture` | Sharp metallic crack + brief stress groan |
| `gear_break` | Heavy crunch + low collapse thud |
| `unit_downed` | Heavy impact + power-down hum fade |
| `field_patch` | Click-hiss — pressurised patch kit sealing |

### Ambience States

| State | Character | Trigger |
|---|---|---|
| **Calm** | Low industrial drone, slow machinery pulse, ~40s loop | Player turn start, mission entry, Terminal Hub |
| **Tension** | Same drone, faster pulse, higher pitch layer added | Enemy phase start |

Crossfade duration: 1.0s. The calm loop is always running; tension layers over it.

### Interactions with Other Systems

- **Combat** (`Main.gd` / `CombatResolver`): AudioManager receives attack result and attacker weapon slot to select the correct weapon SFX and any gear event sounds.
- **HUD** (`HUD.gd`): All button `pressed` signals route to `ui_click`.
- **CombatCutaway** (`CombatCutaway.gd`): `cutaway_dismissed` signal triggers `cutaway_dismiss`.
- **Mission Loop** (`Main.gd`): `mission_complete` / `mission_fail` signals trigger outcome stings and calm/tension music transitions.
- **GameState** (Autoload): AudioManager reads `show_cutaway` to suppress `cutaway_dismiss` SFX when cutaway is off.

## Formulas

### Volume Levels

All volumes expressed in dB. Godot's `AudioServer.set_bus_volume_db()` accepts linear-to-dB converted values.

| Bus | Default Volume | Range | Notes |
|---|---|---|---|
| Master | 0 dB | −∞ to 0 dB | Global mute at −80 dB |
| SFX | −3 dB | −20 to 0 dB | Slightly ducked under master to prevent clipping on layered hits |
| Music | −12 dB | −30 to 0 dB | Ambient, never competes with SFX |
| UI | −6 dB | −20 to 0 dB | Crisp but not loud |

### Music Crossfade

```
calm_volume(t)    = lerp(current_calm_db,    target_calm_db,    t / CROSSFADE_DURATION)
tension_volume(t) = lerp(current_tension_db, target_tension_db, t / CROSSFADE_DURATION)
```

**Variables:**

| Variable | Type | Range | Description |
|---|---|---|---|
| `t` | float | 0.0 – CROSSFADE_DURATION | Elapsed time in seconds since transition started |
| `CROSSFADE_DURATION` | float | 0.5 – 3.0s | Tuning knob — default 1.0s |
| `current_*_db` | float | −80 – 0 dB | Volume at transition start |
| `target_*_db` | float | −80 or −12 dB | −12 dB = audible, −80 dB = silent |

**Output:** Both streams playing simultaneously during crossfade. At `t = CROSSFADE_DURATION`, outgoing stream is at −80 dB (effectively silent).

**Example (Calm → Tension):**
- At t=0: calm=−12 dB, tension=−80 dB
- At t=0.5s: calm=−46 dB, tension=−46 dB (equal loudness midpoint)
- At t=1.0s: calm=−80 dB, tension=−12 dB

## Edge Cases

- **If a GEAR_FRACTURED attack result fires**: play weapon SFX and `gear_fracture` simultaneously on separate `AudioStreamPlayer` nodes. Do not wait for weapon SFX to finish before playing gear crack.
- **If a unit is downed with GEAR_BROKEN result**: play weapon SFX, `gear_break`, and `unit_downed` simultaneously. All three are short enough that overlap is intentional.
- **If the player presses SKIP during the enemy phase**: suppress all weapon SFX for remaining enemy turns. Gear fracture/break sounds still play (these are consequence sounds, not attack sounds).
- **If the cutaway toggle is OFF**: suppress `cutaway_dismiss` SFX since the cutaway never appeared.
- **If the same button is pressed rapidly**: `ui_click` restarts from beginning on each press — no queuing.
- **If AudioManager tries to play a sound whose file is missing**: log a warning and skip silently — missing audio is never a crash.
- **If a music transition is triggered while a crossfade is already in progress**: kill the in-progress tween and start a new one from current volumes.
- **If a unit takes damage from a hazard (not a weapon)**: play `gear_fracture` or `gear_break` as appropriate, but no weapon SFX (there is no weapon slot for hazards).

## Dependencies

- `Main.gd` *(hard)* — provides attack result signals and mission state transitions; AudioManager cannot function without it
- `Unit.gd` *(hard)* — `unit_downed` signal triggers downed SFX
- `HUD.gd` *(soft)* — button press signals for UI clicks; HUD works without audio
- `CombatCutaway.gd` *(soft)* — `cutaway_dismissed` signal; works without audio
- `GameState` autoload *(soft)* — `show_cutaway` flag to suppress cutaway_dismiss SFX

## Tuning Knobs

| Knob | Default | Safe Range | Effect |
|---|---|---|---|
| `SFX_BUS_DB` | −3 dB | −20 to 0 | Overall combat loudness |
| `MUSIC_BUS_DB` | −12 dB | −30 to 0 | Ambience presence — raise if it feels too quiet |
| `UI_BUS_DB` | −6 dB | −20 to 0 | Button feedback loudness |
| `CROSSFADE_DURATION` | 1.0s | 0.5 – 3.0s | Too fast feels jarring; too slow feels unresponsive |
| `MASTER_BUS_DB` | 0 dB | −80 to 0 | Global volume — never raise above 0 |

## Acceptance Criteria

- **GIVEN** a player attack lands with NORMAL result, **WHEN** the attack resolves, **THEN** the attacker's weapon SFX plays within one frame on the SFX bus
- **GIVEN** a GEAR_FRACTURED result, **WHEN** the attack resolves, **THEN** weapon SFX and `gear_fracture` both play simultaneously (audible overlap)
- **GIVEN** a GEAR_BROKEN result, **WHEN** the attack resolves, **THEN** weapon SFX, `gear_break`, and `unit_downed` all play simultaneously
- **GIVEN** the player ends their turn, **WHEN** the enemy phase begins, **THEN** music crossfades from Calm to Tension over 1.0s
- **GIVEN** the enemy phase ends, **WHEN** the player turn begins, **THEN** music crossfades from Tension to Calm over 1.0s
- **GIVEN** a HUD button is pressed, **WHEN** the press fires, **THEN** `ui_click` plays on the UI bus
- **GIVEN** SKIP is pressed mid-enemy-phase, **WHEN** subsequent enemy attacks resolve, **THEN** no weapon SFX plays; gear fracture/break sounds still play
- **GIVEN** an audio file is missing from `res://assets/audio/`, **WHEN** AudioManager tries to play it, **THEN** a warning is logged and no crash occurs
- **GIVEN** a crossfade is mid-progress and a new music transition fires, **WHEN** the new trigger arrives, **THEN** the old tween is killed and a new crossfade starts from current volumes

## Open Questions

[To be designed]
