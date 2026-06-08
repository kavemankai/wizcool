# FRINGE LEDGER — GAME CONCEPT

---

## ELEVATOR PITCH

A deterministic tactical sRPG where your crew never grows stronger — only their gear does — and every mission begins with your leader already compromised.

---

## DESIGN PILLARS

### 1. GEAR IS THE CHARACTER
Units have fixed stats. There are no levels, no skill trees, no stat upgrades. The only variable is what they're carrying and what condition it's in. A unit with broken gear is a liability; a unit with intact gear is a resource. Player growth is expressed entirely through equipment decisions, not character progression.

### 2. DETERMINISM DEMANDS MASTERY
There is no randomness. Every attack result, every movement cost, every outcome is fully calculable before the player commits. This shifts the game from probability management to pure spatial and resource reasoning — if you lose, you made the wrong call, and the game will not apologize for it.

### 3. SCARCITY IS THE PRESSURE
Credits are tight. Repair costs are real. Starting every mission with ALPHA's weapon already Fractured is a deliberate design statement: the game assumes you are already behind. Managing that deficit — choosing what to fix, what to risk, when to walk away — is the central tension at every layer of play.

---

## PLAYER FANTASY

The player is a crew boss running salvage jobs on the fringe of an industrial frontier. They feel like a tactician under pressure — not a hero. They feel clever when they neutralize a TACTICAL archetype before it can isolate ALPHA, and they feel the cost when they don't. The satisfaction is not in winning easily; it's in solving a tight resource puzzle under enemy fire and walking away with the crew intact and the gear still worth something.

---

## CORE LOOP

Each run begins with the **SALVAGE MANIFEST**: the player reviews mission parameters, enemy density, and expected danger pay against their current gear state. The **TACTICAL SKIRMISH** plays out on a fixed 12×20 grid — no camera movement, no procedural surprises, just positioning and decision-making against deterministic enemies. After the skirmish, **FRACTURED GEAR RESOLUTION** forces an immediate accounting: what broke, what held, what needs credits to restore. Back at the **TERMINAL HUB**, the player spends Danger Pay on repairs and selects the next job — always aware that VANGUARD is scaling up with every rank gained, and failure is never free.

---

## WHAT MAKES IT DIFFERENT

**No growth except gear.** Most tactical sRPGs use character leveling as the primary progression hook. Fringe Ledger removes it entirely. The crew you start with is the crew you finish with — the only question is whether their equipment is ready.

**Failure has forward consequences.** A failed mission doesn't reset the board. Intact gear degrades to Fractured, Danger Pay is forfeited, and VANGUARD's rank ticks up. Losing is not a retry screen — it is a compounding disadvantage that must be actively recovered from.

**Total determinism at every scale.** No dice. No RNG. No critical hit variance. The game's difficulty is entirely architectural — enemy positioning, gear state, credit pressure. Players who understand the system completely can always find the correct answer; the question is whether they can execute it.

---

## OUT OF SCOPE

- **Character leveling, XP, or stat growth of any kind** — units are fixed; gear is the only variable
- **Camera pan, zoom, or dynamic viewport changes** — the 12×20 grid is the entire battlefield
- **Particle effects or sprite-based art** — all rendering is code-drawn; aesthetic is intentionally flat and monospace
- **Randomized combat or movement outcomes** — no dice rolls, no hit percentages, no procedural enemy behavior
- **Story cutscenes, voiced dialogue, or narrative cinematics** — world-building is environmental and textual only
- **More than three player units** — ALPHA, BRAVO, CHARLIE; crew size is fixed by design
- **Multiplayer of any kind**
