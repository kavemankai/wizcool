# WIZARD DUEL — Claude Code Reference

## What this is

Roguelite wizard battle game. Balatro meets Pong. Horizontal arena. Player controls barrier with W/S. Projectile bounces between barriers. Miss = damage. Win = pick upgrade. Survive 10 duels + boss.

## Engine

- Godot 4.x, GDScript
- No external game engine or framework assumptions
- BulletUpHell: evaluated Phase 1 Day 1 — keep or drop based on fit

## Project Structure

```
res://
  scenes/
    Arena.tscn          # Main game scene
    Barrier.tscn        # Reusable barrier node
    Projectile.tscn     # Reusable projectile node
    UpgradeDraft.tscn   # Post-victory upgrade picker (Phase 3)
    HUD.tscn            # HP bars, duel counter
    VictoryScreen.tscn  # (Phase 2)
    DefeatScreen.tscn   # (Phase 2)
    MainMenu.tscn       # (Phase 2)
  scripts/
    game/
      ArenaController.gd    # Game loop, state, input routing
      BarrierController.gd  # Player + enemy barrier logic
      ProjectileController.gd # Movement, bounce, collision
      EnemyAI.gd            # Tracks projectile Y, scales per duel
      HUD.gd                # HP display
    systems/
      UpgradeSystem.gd      # (Phase 3) Upgrade pool, draft, stat application
      CombatSystem.gd       # (Phase 3) HP, damage, status effects
      RunManager.gd         # (Phase 2) Duel sequence, win/loss routing
      TagSystem.gd          # (Phase 3) Tag-based upgrade interaction engine
    data/
      upgrades.gd           # (Phase 3) All upgrade definitions as Resources
      enemies.gd            # (Phase 4) 4 enemy types + boss definitions
  resources/
    UpgradeData.gd          # (Phase 3) Resource class definition
    EnemyData.gd            # (Phase 4) Resource class definition
  assets/
    sprites/
    particles/
    audio/
```

## Key Rules

- Every upgrade MUST visibly change projectile behaviour — no hidden stat changes
- ArenaController.gd owns game state. UI scenes are display-only
- Upgrades are Resources (UpgradeData.gd), not hardcoded logic
- Tags drive interactions — upgrades modify tags, not specific spells
- Status effects (burn, freeze, poison) require on-screen visual indicators
- Never put game logic in UI scripts

## Arena Layout

Horizontal. Player wizard left side, enemy wizard right side. Barriers move vertically (up/down) on their respective sides. Projectile spawns centre, travels at an angle. Bounce off top/bottom walls and both barriers.

Viewport: 1280×720. Top wall y=0–20. Bottom wall y=700–720. Player barrier x≈50. Enemy barrier x≈1230.

## Controls

W / S or Up / Down — move player barrier vertically

## Upgrade Draft (Phase 3)

3 random upgrades shown after each victory. Click to choose. No duplicates per run. Weighted pool: Common 60% / Uncommon 30% / Rare 10%.

## Enemy AI

Simple tracker: move barrier toward projectile Y position each _physics_process(). Difficulty scales per duel number via `reaction_speed` and `jitter_amount` exported vars on EnemyAI.gd.

## Tag System (Phase 3 — Commercial Foundation)

Upgrades modify tags, not individual spells.
Core tags: Fire, Ice, Lightning, Poison, Bounce, Split, Critical, Arcane, Shield
Each projectile carries an Array[String] of active tags.
Interactions happen at resolution time, not authoring time.

## Upgrade Resource Shape (Phase 3)

```gdscript
class_name UpgradeData
extends Resource
@export var id: String
@export var name: String
@export var description: String
@export_enum('Common', 'Uncommon', 'Rare') var tier: String
@export var tags: Array[String]
@export var visual_effect: String  # REQUIRED — empty = do not ship
@export var apply_script: String
```

## Phase Build Order

- Phase 1 (Days 1–2): Arena + physics — CURRENT
- Phase 2 (Day 3): Run structure + enemy scaling
- Phase 3 (Days 4–6): Upgrade system (20 upgrades)
- Phase 4 (Days 7–8): Enemy types (4 + boss)
- Phase 5 (Days 9–14): Art + polish

## Risk Flags

**Collision Tunnelling** — Use CharacterBody2D + move_and_collide(). Enable Continuous CD if needed.

**BulletUpHell Mismatch** — Test Day 1. Drop if the bounce mechanic requires fighting it. A custom 150-line ProjectileController is cleaner.

**Game State in UI Nodes** — ArenaController.gd owns ALL state. UI connects to signals only.

**Upgrades Without Visual Effect** — visual_effect is required in UpgradeData. Validate on load.

**Tag Explosion** — TagSystem.gd prints tag state in debug builds on every resolution.
