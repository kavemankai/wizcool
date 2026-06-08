# S012 — Play Session Verification
# Sprint 001 · Phase 11 Combat Feel

**Date**: 2026-06-07
**Tester**:
**Build**: current (main branch)
**Result**: PASS

---

## Pre-Session Setup

- [ ] Open project in Godot 4.6
- [ ] Run project (`F5` or `mcp__godot__run_project`)
- [ ] Confirm no errors in Output panel on launch

---

## Test Cases

### A. Enemy Inspection

| # | Action | Expected | Pass? |
|---|--------|----------|-------|
| A1 | In IDLE state, left-click an enemy unit | HUD unit panel shows enemy name, toughness, combat stat, range | |
| A2 | In IDLE state, click empty floor | HUD unit panel clears | |
| A3 | Select a player unit (ACTING state), click an in-range enemy | Enemy stats show briefly in panel | |
| A4 | Select a player unit, click an out-of-range enemy | Enemy stats visible + "OUT OF RANGE" in log | |
| A5 | Click a downed unit | Nothing — downed units are not selectable | |

---

### B. Slow Enemy Phase + SKIP

| # | Action | Expected | Pass? |
|---|--------|----------|-------|
| B1 | End turn | SKIP ENEMY PHASE button appears | |
| B2 | Watch enemy turns | ~0.8s pause between each enemy; white acting ring visible on active enemy; enemy shown in HUD panel | |
| B3 | End turn, do NOT press skip | All enemies take their turns at ~0.8s pace; button disappears after phase ends | |
| B4 | End turn, press SKIP immediately | All enemy turns resolve instantly; no white ring animation visible | |
| B5 | After enemy phase | SKIP button disappears; input restored | |

---

### C. Combat Cutaway — Player Attacks

| # | Action | Expected | Pass? |
|---|--------|----------|-------|
| C1 | Attack an adjacent enemy | Cutaway overlays full-screen; attacker on left, target on right | |
| C2 | Cutaway visible | Clicking the grid does NOT move or select units (input blocked) | |
| C3 | Cutaway — melee attack | Attacker sprite lunges right; defender flashes + shakes | |
| C4 | Attack a ranged target (not adjacent) | Bullet travels from attacker to defender; muzzle flash + impact | |
| C5 | Health bar | Defender bar animates down from pre-attack toughness to post-attack toughness | |
| C6 | NORMAL hit | Result label slams in (scale overshoot): "HIT −N TOUGHNESS [X / Y]" | |
| C7 | GEAR_FRACTURED hit | Orange gear badge fades in: "GEAR FRACTURED"; result label slams | |
| C8 | GEAR_BROKEN / DOWNED | Dark-red gear badge: "GEAR BROKEN — DOWNED"; result label slams | |
| C9 | Click during cutaway | Cutaway dismisses immediately | |
| C10 | Wait 2 seconds without clicking | Cutaway auto-dismisses | |
| C11 | Cutaway dismisses | Fade-out plays (0.20s); combat result applied (unit downed if applicable) | |

---

### D. Cutaway Fade In/Out

| # | Action | Expected | Pass? |
|---|--------|----------|-------|
| D1 | Cutaway appears | Fades in from transparent over 0.15s (not instant pop) | |
| D2 | Cutaway dismisses | Fades out over 0.20s (not instant pop) | |

---

### E. CUTAWAY: ON/OFF Toggle

| # | Action | Expected | Pass? |
|---|--------|----------|-------|
| E1 | Locate CUTAWAY button | Button visible in HUD (above SKIP ENEMY PHASE) showing "CUTAWAY: ON" | |
| E2 | Press CUTAWAY button | Button text changes to "CUTAWAY: OFF" | |
| E3 | With CUTAWAY: OFF, attack an enemy | No cutaway overlay; combat resolves immediately | |
| E4 | End turn with CUTAWAY: OFF | Enemy attacks have no cutaway; phase runs at normal speed | |
| E5 | Press CUTAWAY button again | Returns to "CUTAWAY: ON"; subsequent attacks show cutaway | |

---

### F. Enemy Phase Cutaway

| # | Action | Expected | Pass? |
|---|--------|----------|-------|
| F1 | End turn (CUTAWAY: ON, no SKIP) | Cutaway shows for each enemy attack during slow phase | |
| F2 | Press SKIP during enemy phase | Cutaway suppressed for remaining enemy turns; phase fast-forwards | |
| F3 | CUTAWAY: OFF, end turn | No cutaway during enemy phase regardless of skip state | |

---

### G. Regression — Core Combat Loop

| # | Action | Expected | Pass? |
|---|--------|----------|-------|
| G1 | Select player unit | Blue highlight ring visible; movement range shown | |
| G2 | Move player unit | Unit moves to clicked tile; turn state updates | |
| G3 | Attack enemy, enemy hits 0 TGH with intact gear | Gear fractured; unit NOT downed | |
| G4 | Attack downed enemy | No action / no crash | |
| G5 | Round limit (20 rounds) | Mission fail triggers | |
| G6 | All crew downed | Mission fail triggers | |
| G7 | Leader downed | Mission fail with "LEADER DOWNED" message | |

---

## Bugs Found

| # | Description | Severity | Steps to Reproduce |
|---|-------------|----------|-------------------|
| | | | |

---

## Result

- [x] **PASS** — all test cases passed, no blocking bugs
- [ ] **PASS WITH NOTES** — minor issues logged, not blocking
- [ ] **FAIL** — blocking bug(s) found (list in Bugs section)

**Notes**:

---

*Update `production/sprints/sprint-001.md` S012 to DONE after a PASS result.*
