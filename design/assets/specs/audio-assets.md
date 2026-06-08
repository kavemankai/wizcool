# Asset Specs — Audio

> **Source**: design/gdd/audio.md, design/assets/entity-inventory.md
> **Generated**: 2026-06-08
> **Status**: 14 assets specced / 14 approved / 0 in production / 0 done

---

## Audio Bus Architecture

Two buses required in `Project Settings > Audio > Buses`:

| Bus | Default Volume | Used for |
|-----|---------------|----------|
| `SFX` | 0 dB | All weapon, gear, unit, and action sounds |
| `Music` | −12 dB | Ambient loops and tension layers |
| `UI` | 0 dB | Button clicks, cutaway dismiss |

Master bus routes all three. UI bus is separate from SFX so HUD interactions can be independently mixed.

---

## Shared: SFX Import Settings

All `.wav` SFX files use the same Godot import settings.

```ini
[importer = "wav"]
force/8_bit = false
force/mono = false
force/max_rate = false
force/max_rate_hz = 44100
edit/loop_mode = 0
edit/loop_begin = 0
edit/loop_end = -1
edit/normalize = false
edit/trim = false
edit/crop_begin = false
edit/crop_end = false
compress/mode = 0
```

`compress/mode = 0` = PCM (uncompressed). For short SFX under 1s this is the correct choice — decompression overhead at playback time is not worth the (small) size saving.

**Format requirements:** 44.1 kHz, 16-bit, mono. Mono is appropriate for all SFX in this game — no positional audio is currently implemented. Stereo files are accepted and will play correctly, but mono halves file size.

---

## Shared: Music Import Settings

Both `.ogg` music files use the same import settings.

```ini
[importer = "ogg_vorbis"]
loop = true
loop_offset = 0
bpm = 0
beat_count = 0
bar_beats = 4
```

`loop = true` required — both tracks are ambient loops. `loop_offset = 0` for seamless start-of-file looping. If the source file has a non-zero loop start point encoded (e.g., from a DAW export), set `loop_offset` to match.

**Format requirements:** OGG Vorbis, 44.1 kHz, stereo, quality ~0.7–0.8 (encode-time setting, not a Godot import setting). Target file size: ~300–600 KB per 40s loop at quality 0.7.

---

## ASSET-021 — sfx_weapon_plasma_cutter.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.3s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_weapon_plasma_cutter.wav` |
| Import preset | SFX preset |
| Trigger | ALPHA attacks with PLASMA-CUTTER |

**Production description:** Sharp electrical discharge — high-pitched crack (~3–5 kHz spike) with a brief buzz tail (10–15ms of electric hum decaying to silence). The leading transient must be sharp, not padded. The buzz tail distinguishes it from the SALVAGE-PISTOL's dry crack. Character: directed-energy, institutional precision.

**Status:** Needed

---

## ASSET-022 — sfx_weapon_impact_wrench.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.25s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_weapon_impact_wrench.wav` |
| Import preset | SFX preset |
| Trigger | BRAVO attacks with IMPACT-WRENCH |

**Production description:** Heavy metallic thud — low-frequency impact (200–400 Hz body) with minimal high-frequency content. Physical weight communicated through sub-bass presence and a short (~40ms) natural resonance tail. No electrical character. Must sound heavier than the SALVAGE-PISTOL and denser than the PLASMA-CUTTER. Character: blunt, mechanical, mass.

**Status:** Needed

---

## ASSET-023 — sfx_weapon_long_bore_drill.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.5s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_weapon_long_bore_drill.wav` |
| Import preset | SFX preset |
| Trigger | CHARLIE attacks with LONG-BORE-DRILL |

**Production description:** Grinding mechanical whir — sustained high-frequency rotation (motor tone ~800 Hz–2 kHz) building for ~0.3s then cutting to a heavy crunch impact at the terminal frame. The build-before-impact structure makes this the longest and most dynamic weapon sound. The crunch is physically distinct from the IMPACT-WRENCH thud — more abrasive, less sub-bass. Character: sustained penetrating force, industrial bore.

**Status:** Needed

---

## ASSET-024 — sfx_weapon_salvage_pistol.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.2s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_weapon_salvage_pistol.wav` |
| Import preset | SFX preset |
| Trigger | VANGUARD attacks with SALVAGE-PISTOL; player loot-drop attacks |

**Production description:** Ballistic crack — lightweight, dry, utilitarian. A clean transient (~1–4 kHz) with very short decay (~20ms), minimal resonance, no electrical character. Sounds like the cheapest thing in the inventory — functional but austere. Shorter and less resonant than the PLASMA-CUTTER; lighter than the IMPACT-WRENCH. Character: disposable, stripped-down, salvaged.

**Status:** Needed

---

## ASSET-025 — sfx_gear_fracture.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.4s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_gear_fracture.wav` |
| Import preset | SFX preset |
| Trigger | GEAR_FRACTURED result — played simultaneously with weapon SFX |

**Production description:** Sharp metallic crack (high-frequency stress fracture transient, ~4–8 kHz) followed by a brief stress groan (~200ms of material strain, descending pitch). The crack is short and sharp; the groan establishes consequence. When layered with the attacking weapon's SFX, the fracture crack should sit above the weapon in frequency so both are audible. Character: material failure, structural stress.

**Status:** Needed

---

## ASSET-026 — sfx_gear_break.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.5s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_gear_break.wav` |
| Import preset | SFX preset |
| Trigger | GEAR_BROKEN result — played with weapon SFX and sfx_unit_downed |

**Production description:** Heavy crunch (abrasive mid-frequency impact, ~500 Hz–2 kHz) followed by a low collapse thud (~100–200 Hz). The crunch signals the gear failure; the thud signals the unit going down. When layered with the weapon SFX and sfx_unit_downed, the crunch occupies mid-frequency and the thud occupies sub-bass — design for non-overlap with the other concurrent sounds. Character: catastrophic failure, total gear loss.

**Status:** Needed

---

## ASSET-027 — sfx_unit_downed.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.6s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_unit_downed.wav` |
| Import preset | SFX preset |
| Trigger | Unit reaches 0 toughness and is downed |

**Production description:** Heavy impact body hit (~80–120 Hz thud, ~50ms) followed by a power-down hum fade (~400ms of electrical hum descending to silence). The hum implies the unit's systems shutting off — consistent with the industrial/technological register. On GEAR_BROKEN results, this plays layered with sfx_gear_break — design for complementary frequency ranges. Character: shutdown, mechanical death.

**Status:** Needed

---

## ASSET-028 — sfx_field_patch.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.4s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_field_patch.wav` |
| Import preset | SFX preset |
| Trigger | ALPHA uses Field Patch action (FIELD-PATCH-KIT consumed) |

**Production description:** Click-hiss — a mechanical click (~5ms, sharp transient) followed by a pressurised patch kit seal hiss (~300ms of controlled gas release, descending from ~2 kHz to ~500 Hz). The click is the applicator trigger; the hiss is the sealant applying. Should sound purposeful and slightly urgent — this is a consumable action with consequence. Character: industrial medical, pressurised, decisive.

**Status:** Needed

---

## ASSET-029 — sfx_mission_complete.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~1.0s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_mission_complete.wav` |
| Import preset | SFX preset |
| Trigger | Mission success — extraction reached or all enemies downed |

**Production description:** Mission success sting — short (under 1s), restrained, not triumphant. A short rising 2–3 note musical phrase or tonal confirmation in the PARCHMENT/OPERATIVE register (warm, controlled). No fanfare, no orchestral swell. Should feel like a quiet acknowledgement, not a celebration — consistent with the game's institutional tone. Character: confirmation, earned completion, not reward.

**Status:** Needed

---

## ASSET-030 — sfx_mission_fail.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~1.5s |
| Bus | SFX |
| Resource path | `res://assets/audio/sfx/sfx_mission_fail.wav` |
| Import preset | SFX preset |
| Trigger | Mission failure — leader downed, all crew down, or round limit reached |

**Production description:** Mission failure sting — low, weighted, consequence-register. A descending phrase or heavy tonal drop in the VOID/SEAM register (cold, institutional). Longer than the success sting — the weight of failure takes time to land. No melodrama. Should feel like a system shutting down, not like losing a game. Character: consequence, institutional failure, weight.

**Status:** Needed

---

## ASSET-031 — sfx_ui_click.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.05s |
| Bus | UI |
| Resource path | `res://assets/audio/sfx/sfx_ui_click.wav` |
| Import preset | SFX preset |
| Trigger | Any HUD button press (End Turn, Field Patch, Skip Enemy Phase) |

**Production description:** Clean, mechanical, short. A single sharp transient — the acoustic equivalent of a physical button press (~2–5 kHz click, <50ms total duration). No reverb, no character — pure utility. Must not be confused with weapon SFX. Character: mechanical interface, confirmation, no personality.

**Status:** Needed

---

## ASSET-032 — sfx_cutaway_dismiss.wav

| Field | Value |
|---|---|
| Category | SFX |
| Format | WAV, 16-bit, 44.1 kHz, mono |
| Duration | ~0.15s |
| Bus | UI |
| Resource path | `res://assets/audio/sfx/sfx_cutaway_dismiss.wav` |
| Import preset | SFX preset |
| Trigger | CombatCutaway overlay dismissed (click or auto-dismiss). Suppressed when `GameState.show_cutaway = false`. |

**Production description:** Brief interface close sound — slightly longer and softer than sfx_ui_click. A short descending tone or soft whoosh (~100ms) that signals the overlay sliding away. Should be clearly distinct from sfx_ui_click (which is a press; this is a dismiss). Character: soft close, panel slide, interface departure.

**Suppression note:** Must not play when the cutaway toggle is off (`GameState.show_cutaway = false`). The CombatCutaway code must gate this SFX behind the toggle check.

**Status:** Needed

---

## ASSET-033 — music_ambient_calm.ogg

| Field | Value |
|---|---|
| Category | Music loop |
| Format | OGG Vorbis, 44.1 kHz, stereo, quality ~0.7 |
| Duration | ~40s seamless loop |
| Bus | Music (−12 dB default) |
| Resource path | `res://assets/audio/music/music_ambient_calm.ogg` |
| Import preset | Music preset (loop = true) |
| Trigger | Player turn start, mission entry, Terminal Hub |

**Production description:** Low industrial drone — a slow, evolving foundation in the 80–200 Hz range with a slow machinery pulse (1–2 BPM rhythm, implied rather than metronomic). The texture should feel like the ambient sound of a facility that is always on, not responding to the player. No melodic content. Loop point must be inaudible — the end of the loop must dissolve back into the beginning without a click or jump. At −12 dB default bus volume, this should feel present but subconscious. Character: facility ambience, institutional patience, always-on.

**Loop requirements:** ~40s minimum. Loop start and end points should be embedded in the OGG metadata or marked at the Godot import level via `loop_offset`. A click or perceivable edit point at the loop boundary is a rejection criterion.

**Status:** Needed

---

## ASSET-034 — music_ambient_tension.ogg

| Field | Value |
|---|---|
| Category | Music layer |
| Format | OGG Vorbis, 44.1 kHz, stereo, quality ~0.7 |
| Duration | ~40s seamless loop (same length as music_ambient_calm preferred) |
| Bus | Music |
| Resource path | `res://assets/audio/music/music_ambient_tension.ogg` |
| Import preset | Music preset (loop = true) |
| Trigger | Enemy phase start — crossfades over music_ambient_calm |

**Production description:** Same drone register as music_ambient_calm — built from the same harmonic foundation. A faster pulse rhythm (8–16 BPM, more metronomic than the calm layer) plus a higher-pitch sustained layer (~400–600 Hz, thin and slightly unstable) added on top. When crossfaded over the calm track, the result should feel like the same space with the tension rising — not a different piece of music. Same loop length as music_ambient_calm is strongly preferred so that crossfades can align to a consistent loop boundary. Character: same-world escalation, mechanical threat, not dramatic.

**Crossfade note:** Godot crossfade between calm and tension is implemented by playing both `AudioStreamPlayer` nodes simultaneously, fading out calm while fading in tension over a short window (~0.5–1s). Both loops must be running continuously (calm at full volume during player turn, tension at 0; swap on enemy phase start). Same loop length ensures they stay phase-aligned across multiple turns.

**Status:** Needed

---

## Directory Structure

```
res://assets/audio/
├── sfx/
│   ├── sfx_weapon_plasma_cutter.wav
│   ├── sfx_weapon_impact_wrench.wav
│   ├── sfx_weapon_long_bore_drill.wav
│   ├── sfx_weapon_salvage_pistol.wav
│   ├── sfx_gear_fracture.wav
│   ├── sfx_gear_break.wav
│   ├── sfx_unit_downed.wav
│   ├── sfx_field_patch.wav
│   ├── sfx_mission_complete.wav
│   ├── sfx_mission_fail.wav
│   ├── sfx_ui_click.wav
│   └── sfx_cutaway_dismiss.wav
└── music/
    ├── music_ambient_calm.ogg
    └── music_ambient_tension.ogg
```

Create both subdirectories inside the Godot editor FileSystem dock.

---

## Verification Checklist

**SFX (all 12):**
- [ ] WAV, 16-bit, 44.1 kHz, mono
- [ ] Duration within stated target (±20%)
- [ ] No DC offset, no clipping on peaks
- [ ] SFX bus routing confirmed in `AudioStreamPlayer` nodes
- [ ] sfx_cutaway_dismiss gated behind `GameState.show_cutaway` check

**Music (both):**
- [ ] OGG Vorbis, 44.1 kHz, stereo
- [ ] Loop point inaudible — no click or perceivable edit at boundary
- [ ] Same loop length for both (±1s tolerance)
- [ ] Music bus routing confirmed, default −12 dB
- [ ] Crossfade between calm and tension tested across 3+ enemy phase transitions
