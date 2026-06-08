# Visual Entity & Screen Inventory

> Generated: 2026-06-08
> Sources: design/gdd/audio.md, design/gdd/campaign-system.md, design/gdd/combat-cutaway.md, design/gdd/combat.md, design/gdd/gear-economy.md, design/art/art-bible.md, design/registry/entities.yaml

---

## Entities — Characters / Protagonists

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 1 | ALPHA | Portrait 96×96 PNG | Player leader. ID badge / site-access credential photo. Frontal or slight 3/4, flat institutional lighting, worn gear visible. Parchment-gold ring unit on the tactical grid. | art-bible §3, §5 | Needed |
| 2 | BRAVO | Portrait 96×96 PNG | Player support. ID badge photo. Same crew consistency rules as ALPHA — same facility, same light register. FIELDGREY center-dot unit on grid. | art-bible §3, §5 | Needed |
| 3 | CHARLIE | Portrait 96×96 PNG | Player specialist/disruptor. ID badge photo. Same crew consistency as ALPHA/BRAVO. FIELDGREY crosshair unit on grid. | art-bible §3, §5 | Needed |

## Entities — Enemies

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 4 | SENTINEL | Portrait 96×96 PNG | Guardian archetype. Mug shot / security-system capture. Flat containment — subject has done this before, slightly off-axis framing, uneven lighting. | art-bible §3, §5 | Needed |
| 5 | PRISONER | Portrait 96×96 PNG | Rampaging archetype. Mug shot. Physical tension in jaw or neck, less cooperative framing, slight blur acceptable. Agitation markers required. | art-bible §3, §5 | Needed |
| 6 | VANGUARD | Portrait 96×96 PNG | Tactical archetype, named antagonist. Professional headshot — deliberate 3/4 angle, single soft key light upper-left or right, controlled confident expression. Dark neutral background (charcoal or deep slate). | art-bible §3, §5 | Needed |

## Equipment Cards

> Note: These are Manifest Screen and Terminal Hub illustration assets — 64×64 PNG pre-made renders,
> treated as portrait-equivalent images under art-bible §8 rules. They are NOT inline HUD icons
> (those remain programmatic schematic glyphs per §8.7). Palette must comply with the 8 canonical
> colors from §4. Style: flat schematic / technical-drawing aesthetic — no shadows, no gradients.

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 7 | PLASMA-CUTTER | Equipment card 64×64 PNG | Industrial plasma cutting tool. Weapon slot. Electrical discharge design language — sharp edges, visible emitter tip. | gear-economy.md, art-bible §4 | Needed |
| 8 | IMPACT-WRENCH | Equipment card 64×64 PNG | Heavy mechanical wrench/driver. Weapon slot. Blunt, weighted head, industrial grip. Low-frequency weight implied by silhouette. | gear-economy.md, art-bible §4 | Needed |
| 9 | LONG-BORE-DRILL | Equipment card 64×64 PNG | Extended drilling tool. Weapon slot. Long barrel geometry, rotary mechanism visible. Suggests sustained penetrating force. | gear-economy.md, art-bible §4 | Needed |
| 10 | WORK-HARNESS | Equipment card 64×64 PNG | Industrial body armor / load-bearing harness. Armor slot. Straps and structural plates, utilitarian buckle geometry. | gear-economy.md, art-bible §4 | Needed |
| 11 | FIELD-PATCH-KIT | Equipment card 64×64 PNG | Medical/repair kit. Medical slot. Pressurised canister or patch applicator. Functional, disposable appearance. | gear-economy.md, art-bible §4 | Needed |
| 12 | SALVAGE-PISTOL | Equipment card 64×64 PNG | Compact ballistic sidearm. Weapon slot. Enemy loot drop. Lightweight, stripped-down frame — cheap but functional. | gear-economy.md, art-bible §4 | Needed |
| 13 | BALLISTIC-PLATE | Equipment card 64×64 PNG | Rigid ballistic armor panel. Armor slot. Vanguard rank 2 gear. Heavier geometry than WORK-HARNESS — institutional-grade protection. | gear-economy.md, art-bible §4 | Needed |

## CombatCutaway — Animation Effects

> These are small sprite-frame PNG assets used in the CombatCutaway attack animation sequence.
> Must use only the 8 canonical palette colors. Hard edges, no anti-aliasing, no gradients.

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 14 | vfx_muzzle_flash | Sprite frame 32×32 PNG (2 frames) | Frame 1: bright starburst flash in PARCHMENT/CAUTION. Frame 2: decay haze in FIELDGREY. Used on attacker for ranged attacks. Nearest-neighbour scaled to 64×64 in cutaway. | combat-cutaway.md | Needed |
| 15 | vfx_impact_flash | Sprite frame 192×192 PNG (1 frame) | Full-portrait-panel white-to-grey flash overlay. Rendered over defender portrait panel at 60% alpha on hit frame, greyscale frame 2, then cleared. Single opaque near-white frame. | combat-cutaway.md, art-bible §3 | Needed |
| 16 | vfx_bullet | Sprite 16×4 PNG | Single-frame horizontal projectile. PARCHMENT leading edge, FIELDGREY trail. Used for ranged bullet travel across centre strip. Hard pixel edges required. | combat-cutaway.md | Needed |

## CombatCutaway — Backgrounds

> 640×720px backdrop images rendered behind portrait panels in the CombatCutaway overlay.
> These are NOT UI panels (not prohibited by §8.7) — they are narrative environment images
> placed behind portrait content. Must read as dark industrial/institutional environments.
> Palette: predominantly VOID-register darks. Accent colors from canonical 8 only.

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 17 | cutaway_bg_player | Background 640×720 PNG | Player-side backdrop. Industrial facility interior — utilitarian, functional, slightly warm-grey. Facility the crew operates in. Implied fluorescent overhead lighting, blurred depth. Palette anchored to VOID + FIELDGREY + faint OPERATIVE accent. | art-bible §2, §6 | Needed |
| 18 | cutaway_bg_enemy | Background 640×720 PNG | Enemy-side backdrop. Institutional corridor or security zone — harsher, colder, more oppressive than player side. Implies surveillance, containment. Palette anchored to VOID + SEAM + faint HOSTILE accent. Distinct from player background — must read as a different facility zone. | art-bible §2, §6 | Needed |

## Fonts

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 19 | jetbrains_mono_400 | Font .ttf | Regular weight (400). Labels, log body, secondary text. SIL Open Font License. | art-bible §7, §8 | Needed |
| 20 | jetbrains_mono_700 | Font .ttf | Bold weight (700). Primary numeric values, stat numbers, unit callsigns. SIL Open Font License. | art-bible §7, §8 | Needed |

## Audio — SFX

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 21 | sfx_weapon_plasma_cutter | SFX .wav | Sharp electrical discharge — high-pitched crack, brief buzz tail. Duration ~0.3s. SFX bus. | audio.md | Needed |
| 22 | sfx_weapon_impact_wrench | SFX .wav | Heavy metallic thud — low-frequency impact, physical weight. Duration ~0.25s. SFX bus. | audio.md | Needed |
| 23 | sfx_weapon_long_bore_drill | SFX .wav | Grinding mechanical whir — sustained build then crunch impact. Duration ~0.5s. SFX bus. | audio.md | Needed |
| 24 | sfx_weapon_salvage_pistol | SFX .wav | Ballistic crack — lightweight, dry, utilitarian. Duration ~0.2s. SFX bus. | audio.md | Needed |
| 25 | sfx_gear_fracture | SFX .wav | Sharp metallic crack + brief stress groan. Played simultaneously with weapon SFX on GEAR_FRACTURED result. SFX bus. | audio.md | Needed |
| 26 | sfx_gear_break | SFX .wav | Heavy crunch + low collapse thud. Played with weapon SFX and unit_downed on GEAR_BROKEN result. SFX bus. | audio.md | Needed |
| 27 | sfx_unit_downed | SFX .wav | Heavy impact + power-down hum fade. SFX bus. | audio.md | Needed |
| 28 | sfx_field_patch | SFX .wav | Click-hiss — pressurised patch kit sealing. SFX bus. | audio.md | Needed |
| 29 | sfx_mission_complete | SFX .wav | Mission success sting. Short, restrained — not triumphant. SFX bus. | audio.md | Needed |
| 30 | sfx_mission_fail | SFX .wav | Mission failure sting. Low, weighted, consequence-register. SFX bus. | audio.md | Needed |
| 31 | sfx_ui_click | SFX .wav | HUD button press feedback. Clean, mechanical, short. UI bus. | audio.md | Needed |
| 32 | sfx_cutaway_dismiss | SFX .wav | CombatCutaway dismissed — brief interface close sound. UI bus. Suppressed when cutaway toggle is OFF. | audio.md | Needed |

## Audio — Music

| # | Name | Type | Description | Source | Status |
|---|------|------|-------------|--------|--------|
| 33 | music_ambient_calm | Music loop .ogg | Low industrial drone, slow machinery pulse. ~40s seamless loop. Music bus at −12 dB default. Plays on player turn start, mission entry, Terminal Hub. | audio.md | Needed |
| 34 | music_ambient_tension | Music layer .ogg | Same drone register as calm, faster pulse + higher-pitch layer added. Crossfades over calm on enemy phase start. Separate stream, same loop length preferred. | audio.md | Needed |

---

## Summary

| Category | Count | Status |
|---|---|---|
| Character portraits (player) | 3 | All Needed |
| Character portraits (enemy) | 3 | All Needed |
| Equipment cards | 7 | All Needed |
| CombatCutaway effects | 3 | All Needed |
| CombatCutaway backgrounds | 2 | All Needed |
| Fonts | 2 | All Needed |
| Audio SFX | 12 | All Needed |
| Audio Music | 2 | All Needed |
| **Total** | **34** | **34 Needed** |

---

## What Is Intentionally NOT In This Inventory

All of the following are drawn programmatically and require no file assets:

- Unit circles, state rings, gear crack lines, archetype marks (Node2D `_draw()`)
- All HUD panels, buttons, stat bars, toughness bar, AP pips, log text (Control + draw calls)
- All tile highlights (move range, attack range), cover geometry, hazard zones (GridManager `_draw()`)
- Extraction marker, targeting crosshair, Precision Strike indicator (draw calls)
- CombatCutaway result label, gear badge, health bar animation (programmatic)
- All inline UI icons / gear slot icons in HUD (schematic glyphs via draw_line/draw_rect — raster icon PNGs are prohibited per art-bible §8.7)
