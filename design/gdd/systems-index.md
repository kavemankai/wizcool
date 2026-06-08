# Systems Index — Fringe Ledger

Generated from Phase 1–11 implementation. Each system links to its GDD.

## Implemented Systems

| System | File | GDD | Status |
|---|---|---|---|
| Grid | `scripts/core/GridManager.gd` | `design/gdd/grid.md` | ✅ Production |
| Unit | `scripts/units/Unit.gd` | `design/gdd/unit.md` | ✅ Production |
| Gear Economy | `scripts/units/GearItem.gd` | `design/gdd/gear-economy.md` | ✅ Production |
| Combat | `scripts/systems/CombatResolver.gd` | `design/gdd/combat.md` | ✅ Production |
| Enemy AI — Guardian | `scripts/units/ai/GuardianAI.gd` | `design/gdd/ai.md` | ✅ Production |
| Enemy AI — Rampaging | `scripts/units/ai/RampagingAI.gd` | `design/gdd/ai.md` | ✅ Production |
| Enemy AI — Tactical | `scripts/units/ai/TacticalAI.gd` | `design/gdd/ai.md` | ✅ Production |
| LOS | `scripts/core/LOSCalculator.gd` | `design/gdd/grid.md` | ✅ Production |
| Movement Range | `scripts/core/MovementRange.gd` | `design/gdd/unit.md` | ✅ Production |
| Hazard System | `scripts/systems/HazardSystem.gd` | `design/gdd/hazards.md` | ✅ Production |
| Mission Loop | `scripts/Main.gd` | `design/gdd/mission.md` | ✅ Production |
| Vanguard Rival | `scripts/Main.gd` | `design/gdd/rival.md` | ✅ Production |
| Save/Load | `scripts/data/SaveManager.gd` | `design/gdd/persistence.md` | ✅ Production |
| Terminal Hub | `scripts/ui/TerminalHub.gd` | `design/gdd/hub.md` | ✅ Production |
| HUD | `scripts/ui/HUD.gd` | — | ✅ Production |
| Combat Cutaway | `scripts/ui/CombatCutaway.gd` | `design/gdd/combat-cutaway.md` | 🔄 Phase 11 |

## Stub Systems (Signals declared, no logic)

| System | File | Notes |
|---|---|---|
| GearSystem | `scripts/systems/GearSystem.gd` | Signal: gear_state_changed |
| MissionSystem | `scripts/systems/MissionSystem.gd` | Signal: mission_complete |
| RivalSystem | `scripts/systems/RivalSystem.gd` | Placeholder |
| TurnManager | `scripts/core/TurnManager.gd` | Signals: turn_started, round_started |

## Planned Systems

| System | Priority | GDD | Notes |
|---|---|---|---|
| Audio | Phase 12 | `design/gdd/audio.md` | Designed — SFX for attacks, UI, ambience |
| Campaign System | Phase 12 | `design/gdd/campaign-system.md` | Designed — narrative arcs, 2–4 missions, retry/abandon |
| Procedural Mission Gen | Phase 13+ | — | Multiple maps, varied layouts |
