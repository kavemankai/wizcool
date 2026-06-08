# GDD — Combat Cutaway

## Overview

Advance Wars-style full-screen overlay that plays on every attack resolution. Shows attacker and defender as large placeholder circles with attack/defend animation. Communicates damage, gear consequence, and result before returning to the grid.

## Player Fantasy

Every attack feels like an event, not a stat subtraction. The visual consequence of gear fracturing should land with weight. Players should understand what happened to their gear without reading a log.

## Detailed Rules

### Trigger
Every call to `_do_attack()` (player) or `EnemyAI.do_attack()` (enemy, unless SKIP active or fast-mode OFF) queues a cutaway event via `cutaway.queue_event(attacker, target, dmg, result, pre_tgh)`.

### Layout
- Full-screen dark overlay (Color 0.03, 0.03, 0.04, 0.92)
- Left panel: attacker (text + CutawayUnit sprite at y=430, x=315)
- Right panel: defender (text + CutawayUnit sprite at y=430, x=965)
- Divider at y=275 separating text zone from sprite zone
- Result band at y=590
- Footer "CLICK TO CONTINUE" at y=642

### Animation Sequence
1. **Fade in** — `_root.modulate.a` 0→1 over 0.15s
2. **Attack animation** (parallel tween):
   - Melee: attacker lunges +105px, defender flash + 4-step shake
   - Ranged: muzzle flash on attacker, bullet travels to defender, impact flash + shake
3. **t=0.85s reveal:**
   - Health bar already tweened (started at impact)
   - Result label slams in (scale 1.35→1.0 TRANS_BACK, modulate fade)
   - Gear badge fades in if GEAR_FRACTURED (orange) or GEAR_BROKEN (dark red)
4. **Dismiss:** click or 2s auto-timer → fade out 1→0 over 0.20s → emit `cutaway_dismissed`

### Fast Mode
CUTAWAY: ON/OFF toggle in HUD. When OFF, `_show_cutaway = false` in Main.gd — no events queued, no awaiting. Turn resolves instantly.

### SKIP Integration
During enemy phase, SKIP button sets `_skip_requested = true`. Cutaway is suppressed for the rest of that enemy phase (`cq = null` passed to AI).

## Formulas

```
Bar width: _BAR_W * (toughness / max_toughness)   (_BAR_W = 220.0)
Ranged detection: max(abs(attacker.grid_pos.x - target.grid_pos.x),
                      abs(attacker.grid_pos.y - target.grid_pos.y)) > 1
```

## Edge Cases

- Click during fade-in (0.15s): `_playing = false`, fade-in tween killed, fade-out starts, signal emits, Main.gd continues
- Auto-dismiss races with click: `_playing` guard prevents double-fire; `CONNECT_ONE_SHOT` cleans up timer
- `CanvasLayer` has no `modulate` — fade targets `_root: Control` child
- Unit freed before cutaway plays: `is_instance_valid()` guards on `_attacker`/`_target`

## Dependencies

- Unit (toughness, gear, archetype, grid_pos, is_leader)
- CutawayUnit (draws unit circle with archetype marks, flash_alpha setter triggers queue_redraw)
- Main.gd (_do_attack, _run_enemy_phase)
- HUD (CUTAWAY: ON/OFF button → cutaway_toggled signal)
- GameState (show_cutaway could persist — not yet wired to save)

## Tuning Knobs

- Fade in duration: 0.15s
- Fade out duration: 0.20s
- Animation wait before reveal: 0.85s
- Auto-dismiss timer: 2.0s
- Bullet travel time: 0.25s (delay 0.05s, arrives t=0.30)
- Melee lunge distance: +105px from ATK_HOME.x
- Result label slam scale: 1.35 start, TRANS_BACK easing

## Acceptance Criteria

- [x] Overlay appears on every attack (player and enemy)
- [x] Melee vs ranged animation branches correctly on Chebyshev distance
- [x] Health bar animates in sync with impact
- [x] Result label appears with slam animation at t=0.85s
- [x] Gear badge appears for GEAR_FRACTURED and GEAR_BROKEN results
- [x] Click dismisses at any point after fade-in
- [x] Auto-dismiss fires after 2s if no click
- [x] All grid input blocked while cutaway is visible
- [x] CUTAWAY OFF toggle skips cutaway entirely for player attacks
- [x] SKIP suppresses cutaway for entire enemy phase
- [ ] Verify no regression in play session (Sprint 001 S012)
