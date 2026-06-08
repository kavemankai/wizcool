# FRINGE LEDGER — Art Bible

> **Status**: Complete (all 9 sections)
> **Author**: Art Director + Claude Code
> **Last Updated**: 2026-06-08
> **Implements Pillars**: Gear Is The Character / Determinism Demands Mastery / Scarcity Is The Pressure
> **AD-ART-BIBLE**: Skipped — Lean mode

---

## 1. Visual Identity Statement

**One-Line Rule:** Every visual element is a readout, not a decoration — if it cannot be drawn with primitives and communicate functional state at a glance, it does not belong on screen.

### Principle 1: Legibility Over Atmosphere
Clarity of information is the first obligation of every visual decision. Color, shape, and contrast exist to communicate unit state, gear condition, and threat — not to create mood as an end in itself. Atmosphere is a byproduct of consistent functional design, never the goal.

**Design test:** When a color choice makes the screen feel more dramatic but makes a damaged-gear state harder to read at a glance, choose the readable color.
**Serves:** Pillar 2 — Determinism Demands Mastery

### Principle 2: Wear Is Data
The visible condition of every element on screen must reflect the mechanical condition of what it represents. A unit with broken gear looks structurally compromised — its drawn shape is degraded, its colors are desaturated or fractured — because the player must read the battlefield like a crew boss reads a work site: fast, for risk, without sentimentality.

**Design test:** When a unit's gear is critically degraded, choose a visual treatment that communicates liability (desaturated fill, broken outline geometry, reduced contrast) over one that merely looks "damaged" cinematically.
**Serves:** Pillar 1 — Gear Is The Character

### Principle 3: Scarcity In The Palette
The color palette is tight and rationed — a small set of industrial values used consistently, never expanded for novelty. New UI elements, status effects, and unit types do not introduce new hues; they reuse what exists with distinct shape or pattern. Color scarcity on screen mirrors credit scarcity in the fiction.

**Design test:** When adding a new status effect or UI element, choose a treatment that reuses an existing palette value with a distinct shape or pattern rather than introducing a new color to mark it as special.
**Serves:** Pillar 3 — Scarcity Is The Pressure

---

## 2. Mood & Atmosphere

### Terminal Hub
**Emotional target:** Controlled anxiety under maintenance pressure — the player is safe but not resting. They are making decisions with incomplete information about what comes next, balancing competing resource demands against an unseen clock. The dominant feeling is stewardship: these are the only three people you have, and the cost of every decision is visible.
**Lighting character:** Cool-neutral. Low color temperature bias (desaturated blue-grey dominant), low contrast, mid-dark brightness register. No harsh shadows — this is fluorescent-tube ambience, flat and institutional. Nothing glows unless it is broken or warning.
**Atmosphere:** Institutional decay / Inventory pressure / Quiet urgency / Functional clutter / Borrowed time
**Energy:** Contemplative

### Salvage Manifest
**Emotional target:** Deliberate pre-commitment dread — the player is reading a situation they cannot yet control. They are pattern-matching threat to resource, calculating whether the contract is survivable. The feeling is a field surgeon reviewing a case before cutting: focused, slightly cold, aware that optimism is a liability.
**Lighting character:** Cool, slightly shifted amber at the margins — the palette equivalent of a document illuminated under a single overhead lamp. High contrast between information fields and background. Brightness pulled slightly below neutral to suggest the screen is the only light source in the room.
**Atmosphere:** Intelligence briefing / Risk calculus / Mission weight / Isolated focus / Operational sobriety
**Energy:** Deliberate

### Tactical Skirmish — Player Turn
**Emotional target:** Suspended authority — the player has initiative and they know it. Time is theirs to spend. The feeling is tactical clarity with a low current of tension underneath: you are in control right now and every action is a wager on whether the plan holds. Problem-solving mode, not survival mode.
**Lighting character:** Neutral-cool with deliberate warmth on selected and active elements only. Moderate contrast — environment reads flat, active elements read bright. Brightness at mid register. The grid is a workspace; it should feel workable, not dramatic.
**Atmosphere:** Grid discipline / Measured aggression / Actionable space / Command weight / Controlled exposure
**Energy:** Measured

### Tactical Skirmish — Enemy Phase
**Emotional target:** Structural vulnerability — the player is watching a system execute against them with no ability to intervene. Control has been removed. The feeling is not panic; it is the specific stress of watching consequences unfold from decisions already made and being unable to revise them. Exposure, not chaos.
**Lighting character:** Ambient register shifts toward deep red-amber — still low saturation but color temperature drops toward threat. Higher contrast than player turn: the grid reads less as a workspace and more as a kill zone. Brightness pulled down one full register from player turn.
**Atmosphere:** Loss of initiative / Mechanical threat / Outcome unknown / Structural exposure / Enemy logic
**Energy:** Tense

### Post-Mission (Success)
**Emotional target:** Grim relief without celebration — the dominant feeling is accounting, not triumph: what did this cost, what did it return, is the ledger better than it was. Satisfaction is transactional, not emotional. Pride is quiet and provisional.
**Lighting character:** Neutral with a marginal warm shift — warmer than the Hub but not celebratory. Contrast remains low. Brightness lifts slightly above neutral, the equivalent of a room with the lights actually on rather than just functional. Nothing saturates.
**Atmosphere:** Provisional relief / Operational accounting / Earned quiet / Functional outcome / Forward lean
**Energy:** Deliberate

### Post-Mission (Failure / Abandon)
**Emotional target:** Weight of consequence — the specific cognitive state of holding a bad outcome and deciding what it means for what comes next. Loss must be legible, not softened. The feeling is: this was real and it cost something real.
**Lighting character:** Cold. Color temperature drops further than any other state — desaturated blue dominant, green cast suppressed entirely. Contrast is high but not harsh — more like reduced dynamic range than deep blacks. Brightness is the lowest register in the game.
**Atmosphere:** Operational failure / Inventory debt / Unit accountability / Cold assessment / Damage absorbed
**Energy:** Oppressive

---

## 3. Shape Language

### Unit Silhouettes

#### Base Circle Geometry

Each unit occupies a single grid tile anchored by a flat circle base (10px radius at 32px tile, 2px gap to tile boundary). A 1px structural outer stroke in near-black separates the disc from tile highlights beneath it.

**Fill:** Player units — desaturated teal `Color(0.15, 0.55, 0.45)`. Enemy units — brick-red `Color(0.55, 0.22, 0.18)`. Neutral — khaki-grey `Color(0.45, 0.42, 0.35)`.

**State rings** (drawn outside disc, 2px gap from edge):
- Idle: no ring
- Selected: full 360° ring, faction color +0.3 brightened
- Acting: three 60° arc segments at 120° intervals (triskelion) — partial consumption signal
- All AP spent: no ring, disc dims to 65% opacity
- Downed: 270° amber arc, 90° gap at bottom, sine-pulse between 80–100% opacity on 1.5s interval
- Dead: hollow circle only, dark grey, no fill
- Leader: permanent parchment-gold outer ring `Color(0.80, 0.75, 0.60)`, stacks under status ring

**Gear degradation (drawn into disc, not outside):**
- FRACTURED: single diagonal crack line across disc interior, `Color(0.0, 0.0, 0.0, 0.5)`, 1px
- BROKEN: X pattern (both diagonals) + disc fill desaturated 40% toward `Color(0.5, 0.5, 0.5)`

Draw order: fill → degradation lines → status ring → leader ring. Never reordered.

**32px readability rule:** Faction fill and ring presence must be distinguishable without zooming. BROKEN fill desaturation must read even when crack lines are too small. Downed pulse may be suppressed below 48px.

#### Portrait Panel

Opens on unit selection, docked to the right HUD edge. Internal layout: portrait on the left, stat block on the right.

**Portrait slot:** Fixed 96×96px TextureRect, no scaling. Framed with a single-pixel chamfered border (2px diagonal cut at each corner — no rounded radius) in the unit's ring color: white-grey for player, amber/red for enemy tier, cold blue-white for Vanguard. Border sits outside the image so the full 96×96px is portrait content. Missing portrait fallback: flat mid-grey fill + unit designation code centred in small type.

**Stat block:** Top-aligned to the right of portrait. Name/designation on first line. Stats as labelled monospace pairs (no icon substitutes — text only). Same panel background treatment as all other HUD panels.

**Interaction:** Panel holds while unit is selected. On deselect: hard translate off-screen right, 4–6 frames, no fade, no ease.

#### Portrait Style Direction

**Player units — ALPHA, BRAVO, CHARLIE**
Corporate ID badge / industrial site-access credential photo. Frontal or slight 3/4 angle, shoulders to top of frame. Flat institutional lighting — even, slightly cool, no directional drama. Worn gear visible at collar or shoulder. Unremarkable expression, eyes forward. Shot at a security checkpoint, not by a photographer.
*Must communicate: competence without glamour. This person does a dangerous job and it is unremarkable to them.*

**Regular enemies — Guardian and Rampaging archetypes**
Mug shot or security-system capture. Subject did not fully cooperate with framing — slight off-axis tilt, gaze not quite meeting camera. Institutional backdrop, slightly stained or unevenly lit. Implied timestamp or case reference at edge. Low production quality intentional. Guardian portraits: flat containment, the subject has done this before. Rampaging portraits: physical tension in jaw or neck, less cooperative framing.
*Must communicate: this individual was categorised by a system. The system was not thorough enough.*

**Vanguard units — Tactical archetype, named antagonists**
Self-curated professional headshot. Deliberate 3/4 angle, single soft key light (upper left or right). Controlled neutral-to-confident expression. Organisation-facing public image — the kind that ends up on a mercenary outfit's public materials. No costume theatrics. The danger is in the presentation discipline.
*Must communicate: this person decided how they would be seen. That decision was strategic.*

#### CombatCutaway Portrait Animation

Horizontal split-screen arrangement (Advance Wars structure, industrial tone). Portraits displayed at 192×192px (96px source scaled 2× nearest-neighbour to preserve hard pixel edges). Attacker panel on left, defender on right.

1. **Slide in** — portrait enters from outer edge, hard translate, no ease, 6–8 frames. 3–4px overshoot then mechanical snap-back to anchor. Feels like a clunk, not a glide.
2. **Hold** — both portraits static while attack animation plays in centre strip. 8–12 frames.
3. **Impact flash** — on hit frame: 1-frame white overlay at 60% opacity → 2-frame greyscale → return to full color. 3 frames total. Attacker portrait does not flash.
4. **Hit reaction** — defending portrait shakes: 4px right / 4px left / 2px right / return, 6 frames. Lethal hit: persistent 30% red-channel tint held until overlay dismisses.
5. **Exit** — hard translate out on respective sides, 4–6 frames, no overshoot on exit.

Tone: impact reads as instrumentation registering a hit, not spectacle. Flash is brief, shake is small. No cartoon brightness.

#### AI Generation Prompt Guidelines

**Player units**
*ID badge photograph, [gender/build descriptor], industrial worker, site-access credential photo, frontal or slight 3/4 angle, shoulders to frame top, flat institutional lighting, even cool light, no directional shadows, worn work gear visible at collar, plain neutral background, unremarkable expression, eyes forward, high-contrast matte finish, no bokeh, no cinematic framing.*
Negative: no smile, no heroic pose, no cinematic lighting, no lens flare, no military costume.
Consistency: fixed off-white or light grey background across all three player portraits — they must read as from the same facility badging system.

**Regular enemies**
*Security camera capture / mug shot, [archetype descriptor], institutional backdrop, slightly off-axis framing, subject not cooperating, uneven or underlit background, flat affect or visible tension, timestamp artifact implied at frame edge, low production quality intentional, no retouching, surveillance or booking photograph aesthetic.*
Negative: no posed expression, no professional lighting, no clean background, no sympathetic framing.
Guardian vs. Rampaging: Guardian leans flat/contained; Rampaging shows agitation markers (neck tension, slight blur).

**Vanguard units**
*Professional headshot, [specific character descriptor], deliberate self-presentation, slight 3/4 angle, single soft key light from upper left or right, controlled confident expression, organisation-facing public image, clean dark neutral background (charcoal or deep slate), high competence through presentation discipline, no obvious military signifiers.*
Negative: no mug-shot affect, no institutional flatness, no smile that reads as friendly.
Consistency: unified key-light direction and dark neutral background across all Vanguard portraits — distinguishes them visually from player (light background) and enemy (institutional) portraits.

---

### Grid Geometry

The grid is the document. Everything drawn on it is a notation on a working surface. Tiles do not have textures — they are differentiated by line work, fill, and opacity only.

**FLOOR:** Implied, not drawn. Background `Color(0.10, 0.10, 0.12)`. Grid lines: 1px at `Color(0.20, 0.20, 0.22, 0.6)`.

**WALL:** Filled rect `Color(0.22, 0.20, 0.18)` (warm dark grey) + 1px inner border `Color(0.35, 0.32, 0.28)`. Replaces grid line entirely.

**LIGHT Cover:** Floor retained beneath. 4px ochre edge bar `Color(0.40, 0.38, 0.25, 0.85)` + 1px inner face line. Improvised, partial, breakable.

**HEAVY Cover:** Same 4px geometry, cold steel grey `Color(0.28, 0.32, 0.35, 1.0)` + inner face `Color(0.45, 0.50, 0.52)`. Warm-ochre vs. cold-steel communicates material difference without a legend.

**Hazard tiles:** Floor background + `Color(0.60, 0.25, 0.10, 0.25)` wash + dashed perimeter (4px on/4px off) in `Color(0.75, 0.35, 0.15, 0.80)`. No icon, no tile text — danger without type.

**Move highlights:** `Color(0.20, 0.50, 0.40, 0.20)` fill + 1px border `Color(0.30, 0.65, 0.50, 0.60)`. Static — movement is a decision, not a prompt.

**Attack highlights:** `Color(0.55, 0.18, 0.14, 0.18)` fill + 1px border `Color(0.75, 0.28, 0.22, 0.65)`. Never simultaneous with move highlights on the same tile.

**Extraction / Objective:** Concentric non-filled diamonds in parchment-gold (outer 2px, inner 1px at 50% scale) + single "X" label at tile centre, 10px monospace. No animation.

---

### UI Shape Grammar

**Border and container style:** Hard edges everywhere. Zero rounded corners — non-negotiable. Panel border: 1px `Color(0.35, 0.35, 0.38, 0.90)`. Panel fill: `Color(0.08, 0.08, 0.10, 0.92)`. Primary panels (active unit, AP, HP): 2px border `Color(0.45, 0.45, 0.48)`. No drop shadows. No background blur.

**Button tiers:**
- **Primary** (End Turn, Confirm): filled rect + 1.5px border. Hover: border brightens. No animation between states — immediate color swap.
- **Secondary** (ability buttons): outlined only, transparent fill. Hover: border and label both brighten.
- **Tertiary** (cancel, dismiss): no border, no fill — looks like text until hovered. Low-cost actions must not demand attention at rest.

**Disabled state:** Desaturated + dimmed + single diagonal line across face in `Color(0.30, 0.30, 0.30, 0.5)`. Same vocabulary as gear FRACTURED — disabled is degraded.

**UI vs. grid relationship:** Both use hard edges (shared industrial grammar) but must never spatially align. Panel edges are deliberately offset ≥4px from grid lines. The grid is the world; the UI is the instrument panel reading it.

**Separators:** Horizontal rules at 1px `Color(0.25, 0.25, 0.28, 0.70)`, flush to panel interior. 2px gap above/below between major sections. Section labels in monospace 8px uppercase `Color(0.45, 0.45, 0.48)` — dimmest text in the system, for navigation not announcement.

---

### Visual Hierarchy

**Selected unit:** Ring geometry on unit + 2px border elevation on HUD panel, synchronised. No tile highlight under the selected unit's current position — tile highlight is reserved for move/attack range.

**Precision strike indicator:** Four `draw_line()` calls at 45° forming a static crosshair, cream near-white `Color(0.85, 0.80, 0.70)`, 1px, arms terminating 3px outside disc edge. No animation — a targeting reticle, not a video game prompt.

**Combat log:** Lowest priority. Panel fill slightly darker than other panels. Most recent line at `Color(0.72, 0.72, 0.68)`, older lines step-dim (lines 2–4 at 50% opacity, lines 5–8 at 35% opacity). Stepped dimming reads as a filed record, not a fading memory. Damage values, unit names, and outcome keywords (`FRACTURED`, `DOWNED`) rendered at full brightness via RichTextLabel BBCode. Log panel border never elevated above 1px.

---

## 4. Color System

### Primary Palette

Eight canonical colors. Every visual element in the game is drawn from this set. No new hues may be introduced at any stage of production. New content reuses these values at different opacities, stroke weights, or geometric patterns.

| Name | `Color()` Value | Role |
|---|---|---|
| **VOID** | `Color(0.10, 0.10, 0.12)` | The world's default silence — floor, background, the institutional dark everything else is read against |
| **SEAM** | `Color(0.20, 0.20, 0.22, 0.6)` | Structure underlying space — grid lines, panel borders, the ledger ruling that makes the field legible |
| **OPERATIVE** | `Color(0.15, 0.55, 0.45)` | Player unit signal — controlled, accountable, on-ledger. Cool enough to read as institutional, warm enough to distinguish from background |
| **HOSTILE** | `Color(0.55, 0.22, 0.18)` | Brick-red threat presence. Old oxidized danger — the color of an industrial warning that has been there long enough to rust |
| **MANDATE** | `Color(0.80, 0.75, 0.60)` | Parchment-gold authority. Leadership markers, objectives, anything the ledger has ratified as significant. The closest this world gets to value |
| **CAUTION** | `Color(0.85, 0.80, 0.20)` | Amber warning — the moment before something becomes irreversible. Between MANDATE gold and HOSTILE red: a negotiated zone, not a verdict |
| **FIELDGREY** | `Color(0.28, 0.32, 0.35)` | Cold steel grey. Heavy cover, structural mass, inert environmental objects. Built to last. |
| **PARCHMENT** | `Color(0.85, 0.80, 0.70)` | Cream near-white. Highest readable text, precision reticles, primary labels. Not white — white would suggest a clarity this world does not promise |

### Semantic Vocabulary

These mappings are rules, not suggestions. If a new element carries one of these meanings, it must use the assigned color.

**Danger / Threat:** HOSTILE in solid fills. CAUTION for graduated or approaching danger. Distinction: HOSTILE means *this is the enemy*; CAUTION means *this is what the enemy is about to do to you*.

**Player / Ally:** OPERATIVE exclusively. Every other element on a player unit (health arc, ring, AP pip) uses OPERATIVE at varying opacities or brightened derivatives — never a different hue.

**Objective / Reward:** MANDATE. Used sparingly — if every third element is gold, it has become wallpaper.

**Degradation / Damage:** No new color. OPERATIVE or HOSTILE receding toward VOID. Health loss is legibility loss — the hue stays recognizable; the intensity fails.

**Warning / Incoming:** CAUTION at full alpha for hard warnings (downed threshold, suppression zone). CAUTION at 0.4–0.6 alpha for soft warnings (move range limit, AP depletion approaching).

**System / Neutral Information:** SEAM for structural chrome. PARCHMENT at 0.55–0.70 opacity for secondary/tertiary text. FIELDGREY for inert environmental objects. Neutral information should feel like the form you fill in, not the news it delivers.

### State-Based Background Tints

Full-screen colored rect drawn over VOID at low alpha. Base background never replaced — it persists underneath. Tint transitions: 0.4-second lerp. No tint may exceed alpha 0.12.

| State | Tint | Alpha | Character |
|---|---|---|---|
| Terminal Hub | `Color(0.12, 0.16, 0.22)` | 0.06 | Cold blue-neutral. The facility at rest. |
| Salvage Manifest | `Color(0.22, 0.18, 0.10)` | 0.08 | Cool-amber margin. A plan being committed to. |
| Player Turn | `Color(0.10, 0.14, 0.16)` | 0.05 | Neutral trace blue. Minimal interference — the board must be readable and calm. |
| Enemy Phase | `Color(0.18, 0.06, 0.04)` | 0.10 | Red-amber ambient. The world shifting toward HOSTILE register without crossing into alarm. |
| Post-Mission (Success) | `Color(0.14, 0.16, 0.10)` | 0.07 | Slight warm green-grey lift. Relief, not celebration. |
| Post-Mission (Failure) | `Color(0.06, 0.08, 0.14)` | 0.12 | Cold blue, lowest register. OPERATIVE teal completely drained. VOID gaining ground. |

### UI Palette

The HUD draws from the same eight canonical colors — no separate UI palette. Panels are part of the world, not a layer above it.

- **Panel fill:** `Color(0.08, 0.08, 0.10, 0.92)` — one step deeper than VOID. Panels are holes, not surfaces.
- **Panel border (inactive):** `Color(0.35, 0.35, 0.38, 0.90)` — SEAM at higher weight.
- **Panel border (active/focused):** `Color(0.45, 0.45, 0.48)` — focus expressed as existing structure becoming more legible, not as a new color.
- **Primary text:** PARCHMENT `Color(0.85, 0.80, 0.70)` — anything read under stress.
- **Secondary text:** PARCHMENT at opacity 0.60.
- **Tertiary / disabled text:** SEAM at opacity 0.55.
- **Button fill (default):** FIELDGREY `Color(0.28, 0.32, 0.35, 0.85)`.
- **Button fill (hover):** FIELDGREY brightened 10% luminance, no hue change.
- **Button (confirm):** OPERATIVE stroke border on FIELDGREY fill — acknowledged by teal, not becoming teal.
- **Button (destructive):** HOSTILE stroke border on FIELDGREY fill. Same pattern, opposite signal.

### Colorblind Safety

**OPERATIVE vs. HOSTILE (highest risk — deuteranopia / protanopia)**
Required backups: unit base shape differs by faction (player = rounded-square base marker, enemy = diamond/triangle). Direction pip (PARCHMENT chevron) on player units only. Health arc direction: player CW, enemy CCW. Text tag (P/E) required in all list/panel contexts where both types appear.

**CAUTION vs. MANDATE (tritanopia risk)**
Backup: MANDATE uses static solid fills on structural shapes. CAUTION uses animated application (pulsing arcs at 0.8 Hz, strobing dashes). Motion is CAUTION's second channel. These two colors never appear adjacent on the same element simultaneously.

**FIELDGREY vs. VOID (low-vision / achromatopsia)**
Backup: cover objects always carry a SEAM-colored outline (minimum 1px). LIGHT cover uses dashed outline; HEAVY cover uses solid outline. Pattern distinguishes cover tier independent of fill color.

### Forbidden Colors

- **Saturated primaries** (pure red/blue/green above 0.7 saturation) — read as OS-convention UI affordances (error dialogs, hyperlinks). This world's danger has oxidized. It does not scream.
- **Pastels** (saturation below 0.15, luminance above 0.75) — imply softness and reversibility. Nothing in Fringe Ledger is soft.
- **Neon / luminous saturates** (colors appearing to emit light against VOID) — signal active futurity. This game's technology is old, failing, and poorly lit.
- **Pure white** `Color(1.0, 1.0, 1.0)` — the world does not offer clarity at that level. PARCHMENT is the ceiling.
- **Warm flesh tones** (approx. `Color(0.7–0.9, 0.4–0.6, 0.3–0.5)`) — units are read as map notation, not portraits. Organic warmth on the tactical field breaks the representational register.
- **Any hue not derivable from the eight canonical entries** — the master rule. Every new hue is a new cognitive debt the player must carry under stress. The palette is rationed. It stays rationed.

---

## 5. Character Design Direction

### 5.1 Visual Archetype Per Unit Type

All player units are circles. Distinction comes from **ring geometry and marker grammar**, not color variation within the faction (all three player units share the OPERATIVE fill). The established base circle rules (fill, rings, crack lines, parchment-gold outer ring for leader) are assumed here — this section defines what is added on top.

**ALPHA (Leader)**
The parchment-gold outer ring already established marks ALPHA as command. No additional geometry is added. The ring *is* the rank. ALPHA should never carry a secondary marker; clutter on the leader circle degrades the readability of the most important unit on the board.

**BRAVO (Support/Mid)**
A single inner dot rendered in FIELDGREY at the center of the fill circle. This dot is small — no larger than 20% of the circle diameter. It reads as a secondary designation without competing with ring or fill. BRAVO's role is logistics and mid-range; the quiet center dot signals a contained, deliberate unit.

**CHARLIE (Specialist/Disruptor)**
A small crosshair inscription inside the fill circle — two short perpendicular line segments centered on the circle origin, rendered in FIELDGREY. The crosshair does not reach the circumference. It signals precision and threat-axis awareness without implying "sniper" iconographically. The crosshair is purely a designation mark, not a directional indicator.

**Size:** No size variation between player units. All player circles are 20px diameter on a 32px tile. Uniform size communicates crew equality — these are peers, not a hero and sidekicks. Differentiation is grammatical (ring/mark), not dimensional.

---

### 5.2 Enemy Archetype Distinguishing Features

At 32px tile size, players must identify enemy archetype in under one second. Three features are in play: **fill shape, internal mark, and ring treatment.** Enemy fill is HOSTILE throughout. Distinction is applied to geometry inside and around the circle.

**Guardian (Patrol / Zone Control)**
No internal mark. A second concentric ring outside the base circle, rendered in MANDATE (a dim secondary band). The double ring signals containment authority — this unit claims the space around it. The outer ring is thinner than the inner (half-stroke weight). Reads as: armored, territorial, standing orders.

**Rampaging (Charge / Aggression)**
An arrowhead mark inside the fill circle, apex pointing upward (toward top of tile). The arrowhead is rendered in CAUTION. No outer ring. The CAUTION interior mark on a HOSTILE fill is the board's most visually aggressive combination — it signals momentum, not position. The arrow points "up" by convention (direction of aggression), not toward actual movement heading.

**Tactical (Hold / Hunt Leader)**
A small triangle inscribed inside the fill circle, rendered in MANDATE, apex pointing downward — inverted from Rampaging. The inverted mark signals patience, strategic orientation. Additionally, a single dashed outer ring (alternating drawn/gap segments) to distinguish from the solid Guardian outer ring. The dashed ring communicates surveillance cadence — present but not fixed.

**Summary at a glance:**
- Guardian: double solid ring, no interior mark
- Rampaging: CAUTION arrowhead (up), no ring
- Tactical: MANDATE inverted triangle, dashed ring

These three combinations are non-overlapping and distinguish themselves at minimal resolution. No enemy archetype shares more than one feature with another.

---

### 5.3 Vanguard Visual Distinction

Vanguard units are named Tactical enemies — they inherit the Tactical visual grammar (inverted triangle, dashed ring) and add a **rank indicator** as a rank-bar drawn above the circle, outside the tile boundary, overlapping the tile edge by 4px.

The rank bar is a short horizontal filled rect rendered in SEAM (not MANDATE, not CAUTION — SEAM signals something recorded, documented, dangerous in a bureaucratic sense). Bar width scales with rank tier:

- Rank 1 Vanguard: single short bar (one segment)
- Rank 2 Vanguard: two stacked horizontal bars
- Rank 3+ Vanguard: three bars, with the top bar rendered in PARCHMENT to signal maximum-threat classification

The bar sits above the circle. It does not enter the circle. It reads as a designation appended to the unit file — a label added from outside, not a property of the unit itself. This is intentional: Vanguard danger is institutional (they have records, they have rank) rather than intrinsic (they are not bigger, not differently shaped).

**No other visual element distinguishes Vanguard.** The rank bar is the entire signal. Adding a glow, a different fill, a unique ring treatment would inflate visual weight and dilute the grammar established for base archetypes. Vanguard danger should feel like seeing a known name on a wanted list — recognition, not spectacle.

---

### 5.4 LOD Philosophy

There is no camera zoom and no distance variation. Every unit is always rendered at the same visual scale. LOD here does not mean level-of-detail-by-distance — it means **level-of-detail-by-state**.

**Rule: add a mark only when a state change warrants it. Remove marks when the state clears.**

- Gear degradation crack lines appear only when a unit's equipment condition passes a defined threshold. Below threshold: no cracks. Above threshold: one or two crack lines drawn across the fill circle in SEAM.
- State rings (suppressed, overwatch, etc.) are overlaid only when the state is active. They are removed immediately when the state clears. The base circle in its neutral state should be as minimal as possible.
- Internal marks (BRAVO dot, CHARLIE crosshair, enemy archetype marks) are permanent and invariant — they are identity, not state, and are never removed.
- Vanguard rank bars are permanent once the unit is introduced.
- The ALPHA parchment-gold ring is permanent.

**The cardinal LOD rule: the more visual marks a circle carries at any one moment, the more critical the information being communicated.** A circle with three simultaneous overlays (suppressed ring, degradation cracks, health ring) is a unit in crisis. That density is earned by gameplay state, not granted decoratively. At neutral state, every circle should be readable in under half a second.

Do not add ambient or decorative marks to fill "empty" circles. An empty OPERATIVE circle is a healthy, active, uncompromised unit. That is the correct default read.

---

### 5.5 Portrait Consistency Rules

AI-generated portraits carry an inherent risk: three separately generated images that look like three separate casting calls. The following rules are applied as generation constraints and post-generation selection filters to ensure ALPHA, BRAVO, CHARLIE read as a crew.

**Lighting — single consistent source**
All three portraits must use top-left or dead-overhead lighting. Any portrait with fill lighting, beauty-dish treatment, or soft-box diffusion is rejected. The light source should imply a facility — fluorescent overhead, not natural. Shadows must be present.

**Background — institutional, identical tone register**
Backgrounds must be near-black or deep SEAM-adjacent grey. No gradient bokeh. No environmental storytelling in the background. The background is a wall, or nothing. ALPHA, BRAVO, and CHARLIE should appear to have been photographed in the same room — the ID badge convention.

**Framing — chest-up, centered, neutral expression**
All three portraits: chest-up crop, face centered in the 96×96 frame, eyes open, neutral-to-alert expression. No smiling. No heroic upward gaze. These are ID intake photographs, not character posters.

**Clothing — shared functional register**
All three must wear clothing in the same industrial-functional register: tactical wear, institutional jumpsuit, or facility workwear. Color palette of worn clothing should not exceed two values and should not include saturated primaries. The clothing does not need to match exactly — crew members are not uniformed — but must read as the same economic and occupational stratum.

**Ethnic and gender diversity is unrestricted** — the rules above are compositional, not demographic. The crew should feel like people who work together in the same building, not people who were cast to look like they work together.

**Enemy portraits (mug shot / professional headshot) are generated separately** and follow a different frame grammar — but must not accidentally match the player ID badge aesthetic. Enemy portraits should be harsher in crop (tighter, more confrontational) and in background (flatter, more institutional). Vanguard professional headshots may include slight compositional formality (more centered, more even lighting) to signal rank — they have a file, and the file was made carefully.

---

## 6. Environment Design Language

### 6.1 Grid as Environment

The 12×20 tile grid carries no texture, no elevation, no lighting gradient. World-building is transmitted through **the arrangement and density of tile types**, not the appearance of individual tiles.

The player reads the map the way an operative reads a floor plan: what is passable, what blocks, where the threats concentrate. The map *is* the intelligence briefing. Every cluster of WALL tiles should answer the question "what kind of space is this" through its shape, not through any decorative element drawn on the tile itself.

**Core reading conventions:**
- **Tight rectangular WALL clusters** (2–3 tile rooms, walls on three sides, one gap opening) = cell or containment space. Reads as purpose-built enclosure.
- **Long parallel WALL lines with a 1–2 tile gap between them** = corridor. Reads as controlled transit. High danger implication — crossing a corridor is exposure.
- **Wide open FLOOR zones with sparse WALL segments** = staging or processing areas. Industrial facilities require staging space; open floor reads as a place things happen at scale, not where people live.
- **Perpendicular WALL junctions** = structural division. Corner geometries read as institutional — this building was engineered, not grown.

**Rule: No WALL tile is decorative.** Every WALL placement either blocks movement, defines a sightline limit, or shapes a space. A WALL tile that does neither should not be placed. This is a design constraint that also enforces map readability — every solid tile has a reason, and players can infer that reason.

---

### 6.2 Environmental Storytelling Via Tile Placement

Three named map environments exist: **Industrial Facility**, **Security Block**, **Cell Corridor**. Each has a distinct tile grammar. Tile arrangements are the only world-building available — they must carry the entire environmental read.

**Industrial Facility**
Large open FLOOR zones (4+ tiles wide) interrupted by scattered HEAVY COVER placements that read as machinery or structural columns. WALL clusters are sparse and irregular — the building's internal structure is functional, not cellular. Corridors are wide. Cover is central-placed rather than wall-adjacent. The read: a working space, converted or commandeered. Things are in the middle of the floor because they were left there.

Map characteristics:
- Open staging zones at north and south ends
- 2–3 large interior WALL clusters (machinery-mass reads)
- HEAVY COVER placed in grid-center rather than at periphery
- Few corridors; what corridors exist are wide (2 tiles)

**Security Block**
Dominant WALL density — more than 40% of tiles are WALL or adjacent to WALL. Rooms are small and numerous. Multiple choke-point corridors (1-tile wide). HEAVY COVER is room-adjacent, not center-placed — it reads as fortified positions, not abandoned equipment. The read: this space was designed to be held and defended.

Map characteristics:
- Multiple sub-rooms along one axis (east or west perimeter)
- 1-tile chokepoints between rooms and the central corridor
- Guard post positions implied by HEAVY COVER at room entrances
- The extraction point is on the far side of the maximum choke density

**Cell Corridor**
Linear map organization. The primary axis runs north-south with WALL lines flanking a central corridor. Cell openings are regular intervals on one or both sides — identical rectangular recesses in the WALL line. LIGHT COVER is sparse (low tactical value; this map rewards mobility over defensive play). The read: a place of containment, uniform, surveilled, designed for mass movement in one direction.

Map characteristics:
- Strong north-south axis with minimal lateral branching
- Regular cell-opening rhythm on WALL flanks (every 2–3 tiles)
- Few or no interior sub-rooms — the corridor is the environment
- Extraction point at the corridor terminus (you came in one end, you leave the other)

---

### 6.3 Hazard Zone Visual Language

Hazard zone tile fill is defined in Section 3. This section governs **introduction, expansion, and clearance behavior** as a communication system for threat escalation.

**Introduction — entry signal, not sudden fill**
When a hazard zone first appears on the map, it occupies a minimum footprint: 1–2 tiles, placed at a logical environmental source (a structural edge, a wall-adjacent tile, the tile where a threat event was triggered). It does not appear as a large zone immediately. Small hazard reads as warning — a condition starting, not yet critical.

**Expansion — directional and readable**
Hazard zones expand one tile at a time, in directions consistent with implied source logic. Gas expands outward from origin. Fire moves along adjacencies. Structural hazard (collapse, electrification) expands along WALL adjacencies. Expansion direction should never feel random — players should be able to predict the next tile that will be affected based on the geometry of previous expansion.

**Rate and turn-economy communication:** Hazard zones that expand every player turn are existential urgency. Hazard zones that expand every 2 turns are pressure. Hazard zones that do not expand but persist are area denial. The expansion rate is visible in the game state — the player can count turns and observe growth. The visual grammar should not attempt to communicate rate (no flicker, no animated pulse) — rate is a logic fact, not a visual effect.

**Clearance — full tile, immediate**
When a hazard zone tile is cleared (by event, by player action, by turn limit), the tile returns immediately to its base state. No fade, no residue visual. The hazard is gone. This is intentional — partial clearance reads as unreliable and introduces ambiguity about whether the tile is safe. In a game where positioning is the core verb, tile safety must be binary and instantly legible.

**Maximum hazard density rule:** No map should have hazard zones covering more than 30% of passable tiles at peak escalation. Beyond 30%, the map reads as unplayable rather than pressured. Hazard is a tactical constraint, not a punishment environment.

---

### 6.4 Extraction Marker as Environmental Punctuation

The extraction marker (objective tile) must be distinguishable at all times without becoming a visual attractor during phases when the objective is not the active priority (e.g., early combat turns, repositioning phases).

**Neutral phase presentation:**
The extraction tile is marked with a single unfilled rect outline drawn in PARCHMENT, inset 4px from the tile boundary. No fill. No animation. The outline is present but quiet — it does not compete with COVER tiles, WALL tiles, or unit circles. It reads as a map notation, not a live prompt.

**Active phase presentation (when extraction is the current objective):**
The unfilled rect gains a corner-pip treatment: small filled squares (4×4px) in PARCHMENT drawn at all four tile corners. The pips are added; the outline remains. This is the only visual change. The corner pips read as "marked, confirmed, active" — they look like a targeting reticle completing itself. The corner-pip treatment should not be applied to any other tile type under any circumstances, ensuring it remains an unambiguous signal.

**When a unit is standing on the extraction tile:**
The PARCHMENT outline and corner pips remain drawn behind the unit circle. They are not occluded — unit circles should be drawn on top of the tile geometry, so the extraction outline is visible as a framing element around the unit. A unit standing in the extraction zone reads as "positioned for extraction" — the geometry confirms the state.

**Rule: the extraction marker never pulses, never changes color, never scales.** Any animation or color shift would make it read as a UI alert rather than a map element. It must remain an element of the environment — a place marked on a plan — rather than an interface button waiting to be pressed.

---

### 6.5 Negative Space Rules

FLOOR tiles carry no drawn fill. They are the absence of geometry — the board surface showing through. This is not a limitation; it is the primary readability mechanism.

**What open floor communicates:**
Open FLOOR is traversable, uncommitted, exposed space. A unit on open FLOOR has no cover and maximum mobility. Visually, a large open FLOOR zone reads as a kill zone — exposure is implied by the absence of marks. Players learn this reading quickly: if there's nothing drawn on the tile, you're visible.

**What covered/walled areas communicate:**
Density of marks (WALL, COVER, hazard) reads as complexity, danger, and tactical utility simultaneously. Dense areas are slower to traverse, harder to read at a glance, and more defensible. The visual weight of dense areas should feel heavy — the eye takes longer to process them. This is correct behavior. Dense areas deserve more cognitive time.

**Minimum open floor rule:**
A map must retain at minimum 35% open FLOOR tiles at all times (before hazard zones are applied). Below 35%, the map loses its mobility texture — every tile becomes a decision and the board reads as a puzzle rather than a tactical space. Maps approaching 35% open floor should be intentional Security Block layouts where constriction is the environmental statement.

**Maximum open floor rule:**
A map should not exceed 65% open FLOOR tiles. Above 65%, the map reads as uncharacterised — an empty grid with furniture. The tactical environment ceases to feel like a place. Industrial Facility maps are most at risk of this error; the wide staging areas must be punctuated with sufficient COVER and WALL mass to feel like a working space rather than an arena.

**The characterisation test:**
Cover a 3×3 tile section of the map mentally and ask: does the surrounding geometry suggest what kind of space this is? If the answer requires looking at the whole map rather than the local geometry, the local geometry is undercharacterised. Every zone of the map should be locally readable — a player should be able to glance at one quadrant and know whether they are in a corridor, a room, or open staging space. Local density is the mechanism. Open floor without local context is wasted space; open floor adjacent to purposeful WALL geometry is a sightline, a crossing, a danger.

---

## 7. UI / HUD Visual Direction

### 7.0 Governing Premise

Every HUD element in Fringe Ledger is an **instrument readout**, not a graphic design decision. The screen is treated as a field terminal — a hardened tactical display that an operative might actually carry. If a given element cannot be explained as data emitted by the tactical situation, it does not exist.

---

### 7.1 Diegetic vs. Screen-Space HUD

**Semi-diegetic instrument panel.** The HUD is the bezel-mounted readout layer of a field terminal device. The game world occupies the center of the screen. Panels do not float over it — they occupy dedicated border regions that function as the terminal's instrument strip. HUD panels must never overlap the tactical map except during explicitly sanctioned overlays (CombatCutaway, modal confirmations).

**Regional assignment (1280×720):**
- **Top strip:** y=0, h=28px. Full width. Mission label, phase counter, turn count.
- **Right panel:** x=1060, w=220px, y=28, h=692px. Unit detail.
- **Bottom strip:** x=0, y=624, w=1060px, h=96px. Combat log, action labels, action buttons.
- **Tactical map viewport:** x=0, y=28, w=1060px, h=596px.
- Left strip reserved; currently renders as solid VOID with no visible elements.

The 4px minimum spatial offset rule applies at all panel boundaries: the grid never aligns with any panel edge.

**Panel borders:** 2px continuous rect in SEAM at alpha 0.90. No drop shadows, no glows, no bevels. Interior background: VOID at full opacity. A 1px inner highlight at FIELDGREY alpha 0.15 runs along the top and left interior edges of each primary panel — this is the single concession to depth perception and must not be increased.

---

### 7.2 Typography Direction

**Typeface:** Geometric monospace only — JetBrains Mono (preferred), Share Tech Mono, or Roboto Mono at weight 400/700. No proportional typefaces anywhere in the HUD. No italic ever. Facts do not lean.

**Why monospace:** Numeric values are the primary payload. Proportional spacing introduces micro-jitter in numeric columns as values change — a value changing from `12` to `8` shifts surrounding text. Monospace locks all glyphs to identical cell width; readouts are stable.

**Weight hierarchy:**

| Tier | Weight | Usage |
|---|---|---|
| Primary Value | Bold 700 | HP, AP, range, turn count — any number needed under pressure |
| Label | Regular 400 | Identifying labels: "AP", "TGH", "RNG" — always smaller than its value |
| Keyword/Log | Regular 400 + MANDATE color | Keywords in combat log — same weight as label, differentiated by hue only |

No Medium 500 weight. The gap between 400 and 700 enables immediate visual parsing of label vs. value without eye movement. A 500 weight collapses this gap.

**Size hierarchy (absolute px — no scaling):**

| Tier | Size | Usage |
|---|---|---|
| Primary | 16px | Toughness value, AP count — any number read mid-action |
| Secondary | 12px | Stat labels, gear names, status effect names, button labels |
| Tertiary | 10px | Combat log body text, sub-labels, range annotations |
| Micro | 8px | Turn counter, phase label, version/debug readout |

No size below 8px. No size above 16px in the HUD proper.

**Casing rules:**

| Context | Rule |
|---|---|
| Stat labels | ALL CAPS |
| Button labels | ALL CAPS |
| Gear/item names | Title Case |
| Combat log entries | Sentence case |
| Unit names / callsigns | ALL CAPS |
| Objective text | ALL CAPS, MANDATE color |
| Status effect names | ALL CAPS abbreviated in stat block (SUPP, BRKN, PINS); full sentence case in log |

---

### 7.3 Iconography Style

**Schematic glyphs only.** Icons are the visual equivalent of circuit diagram symbols — a small number of straight lines and filled rectangles drawn with `draw_line`, `draw_rect`, and `draw_polyline`. No curves. No bezier paths. No imported SVGs with rounded paths. If an icon cannot be drawn with primitives in under 20 draw calls, it is too complex — simplify or replace with a text abbreviation.

**Icon grid:** 12×12px for inline use (aligns to 12px secondary text baseline), 16×16px for standalone use (status effect slots). All strokes 1px. No gradients.

**Color rules for icons:**

| Information type | Color |
|---|---|
| Player unit stat | OPERATIVE |
| Enemy stat / threat | HOSTILE |
| Objective | MANDATE |
| Warning / resource low | CAUTION |
| Neutral / cover / terrain | FIELDGREY |
| Disabled | FIELDGREY at 40% alpha + diagonal stroke |

Icons never use PARCHMENT (reserved for text) or VOID (it is background). Contrast is achieved via negative space.

**Status effect glyphs:** 16×16 frame, 14×14 active area. Background: FIELDGREY at 60% alpha with 1px SEAM border. Glyph in allegiance hue (OPERATIVE for friendly status, HOSTILE for debuffs, CAUTION for mixed). No curved elements. Suppressed = horizontal crosshatch (two lines). Broken = diagonal split. Pinned = downward chevron (two lines).

**Primary action buttons (End Turn, Field Patch, Skip) carry text labels only — no icons.** Primary actions must be named, not symbolised. A player reading "END TURN" understands the action immediately; a symbol requires learned association. Legibility Over Atmosphere.

---

### 7.4 Animation Feel

**Governing rule: all animation is mechanical, not organic.** No easing curves suggesting physical weight, no spring physics, no bounce. Every animated element moves at constant velocity or via discrete step. The terminal display does not breathe; it updates.

**Panel entry (scene load / first shown):**
- Slides in from its edge (right panel from right, bottom from bottom, top from top).
- Travel: full dimension on entry axis (right panel = 220px from x=1280 to x=1060).
- Duration: 6 frames at 60fps. Constant velocity.
- Overshoot: at frame 5, panel is 3px past rest. Frame 6: snaps to exact rest. Mechanical snap, not bounce.
- All panels enter simultaneously on scene load.

**Panel exit:** Hard cut. No animation. The display turns off; it does not slide away. Exception: modal dialogs fade via alpha steps (0 → 0.5 → 1.0 entry, 1.0 → 0 exit in one frame).

**Value updates (HP, AP, stats):**
- Frame 0: new value renders immediately. No digit-rolling, no count-up.
- Frames 0–3: cell background flashes CAUTION at 60% alpha if value decreased; OPERATIVE at 40% alpha if increased.
- Frame 4: cell background hard-cuts to VOID.

**Toughness bar:** Fill rect width steps at 2px per frame toward target width. This is the single interpolated readout — continuous representation earns the animation.

**AP pips:** Each pip is a hard cut (OPERATIVE fill → 1px OPERATIVE border, VOID fill). Multi-pip spend staggers by 2 frames per pip. AP refill: all pips fill simultaneously + 3-frame OPERATIVE flash. Stagger on spend communicates sequential resource consumption; simultaneous refill communicates clean reset.

**Combat log entry:** New line snaps to bottom. Existing lines shift upward by hard cut — no smooth scroll. New line at PARCHMENT full alpha. Existing lines: 15% alpha reduction per position upward, floor 30% alpha. **During enemy phase:** decay rate is halved — retain 3–5 lines at readable contrast so players can catch up on a glance when the phase ends.

**Button state transitions:**

| Transition | Behavior |
|---|---|
| Normal → Hover | Background fills to FIELDGREY 70% alpha. Instant. |
| Hover → Normal | Returns to state fill. Instant. |
| Normal → Pressed | Background fills to PARCHMENT 20% alpha + border drops to 1px for 2 frames. |
| Pressed → Normal | Returns to Normal. Instant at frame 3. |
| Normal → Disabled | Desaturated fill + 40% alpha overall + 1px diagonal SEAM stroke across face. Instant state change. |

**Button suppression during enemy phase:**
During enemy phase, all buttons except Skip Enemy Phase are visually suppressed: label text changes to FIELDGREY, background fills to SEAM at 30% alpha. Suppressed buttons remain rendered (the player can see them) but read as inactive instrument displays. If a player clicks a suppressed button during enemy phase, the button label text snaps to "ENEMY PHASE" in HOSTILE color for 60 frames (1 second), then reverts. This is a snap-state text swap — no animation. It closes the "why didn't that work" loop without feedback that is dramatic or out-of-register.

---

### 7.5 HUD Panel Layout Principles

**The Instrument Strip Doctrine:** Panels are positioned by the priority of information relative to where the player's eye will be.

- **Right panel** — most frequently consulted during selection phase. Player glances right from map center to read operative state.
- **Bottom strip** — combat log is bottom-left (eye drifts down-left after watching a result). Action buttons are bottom-right, near the right panel, minimizing travel from "reading state" to "committing action."
- **Top strip** — consulted least during combat. Peripheral placement; mission name and phase are ambient information.

**Whitespace (absolute values, no scaling):**

| Location | Value |
|---|---|
| Panel edge to first content element | 6px all sides |
| Label to value (horizontal) | 4px |
| Between stat rows (vertical) | 4px |
| Between major panel sections | 8px + 1px SEAM rule at 0.40 alpha |
| Between buttons (bottom strip) | 6px |
| Portrait to stat block (horizontal) | 8px |

No element may be closer than 4px to a panel border. If a stat label is too long to fit with 4px separation from its value, the label is abbreviated — spacing is not reduced.

**Right panel vertical rhythm:** 20px strict rhythm from y=34 (panel content origin). Every element starts at a multiple of 20px. Stat row, divider, toughness bar, AP pips, gear list, status effects — all snap to this rhythm. A programmer adding a new row picks the next 20px multiple; no design consultation needed.

**Right panel width lock:** 220px fixed. No content wrapping, word-wrap, or dynamic resize. Unit names truncate at panel edge — no ellipsis.

**Top strip content:**
- Left-aligned x=6: mission name, 10px, MANDATE, ALL CAPS.
- Center-aligned in map viewport width: phase label ("OPERATIVE PHASE" / "HOSTILE PHASE"), 10px, PARCHMENT.
- Right-aligned x=1054: turn counter ("T:04"), 10px, FIELDGREY.
- 1px SEAM rule at y=27 (full width, bottom edge of strip).

**Precision Strike and AoE labels:** These belong in the bottom strip only — never floating over the map. The map viewport is the field glass; nothing is written on the glass.
- Precision Strike: bottom strip, right-aligned, above End Turn button. 12px secondary, CAUTION, "PRECISION ACTIVE".
- AoE preview: bottom strip, left-aligned x=6. 12px secondary, HOSTILE.
- If both active simultaneously, Precision Strike renders above AoE vertically within the strip.

**Targeting crosshair (single permitted map overlay):** 12×12px, PARCHMENT, 1px lines, 4px gap at center intersection, snaps to tile center. No animation. This is a precision instrument, not a panel.

---

### 7.6 Tile Range Pattern Distinction (Colorblind Safety Addendum)

Move-range and attack-range highlights are distinguished by both color and pattern to remain readable under deuteranopia and protanopia:

- **Move-range tiles:** OPERATIVE tint fill only (no border pattern).
- **Attack-range tiles:** HOSTILE tint fill + 1px dashed perimeter on each tile edge (4px dash, 4px gap, HOSTILE at 0.65 alpha). The dashed border is static geometry — no animation.

The pattern distinction works in grayscale and under any color deficiency. This is the binding rule; color alone is not sufficient for attack-range tiles.

---

### 7.7 Affordance Grammar Summary

Four channels establish the full interactive vocabulary within the hard-edge, monospace, 8-color constraint set:

| Channel | Signals |
|---|---|
| **Geometry (borders)** | Interactivity — 1px SEAM border means the element is a button; no border means it is display |
| **Color** | State — OPERATIVE=player/friendly, HOSTILE=enemy/threat, CAUTION=warning, MANDATE=objective/selected |
| **Pattern (dashes vs. fill)** | Tile function — solid fill=move, dashed edge=attack |
| **Text** | Unavailability — "EXPENDED", "ENEMY PHASE" — used when color alone cannot communicate state |

These four channels are additive and non-overlapping. Any new HUD element introduced in production must map to one or more of these channels. Introducing a fifth channel (glow, shadow, size change, animation curve) requires an explicit override and a justified exception in the art bible.

---

## 8. Asset Standards

This section defines the complete asset specification for Fringe Ledger. Every asset type the project uses, will use, or explicitly rejects is covered here. A contractor or team member should be able to deliver a compliant asset from this section alone, without follow-up questions.

**Scope reminder:** Fringe Ledger does not use sprite sheets, animated 2D art, raster UI, or texture atlases. All gameplay visuals are programmatic (Node2D `_draw()` calls). The discrete file assets in this project are: portrait PNGs, one font family, and future tile textures (not yet implemented). Everything else is code or scene data.

---

### 8.1 Portrait Asset Specification

#### File Format

| Property | Requirement |
|---|---|
| Format | PNG (Portable Network Graphics) — no JPEG, no WebP, no TIFF |
| Color mode | RGB + Alpha (RGBA) — 32-bit PNG |
| Bit depth | 8 bits per channel (24-bit color + 8-bit alpha = 32-bit file) |
| Color profile | sRGB — no embedded ICC profiles other than sRGB. Godot 4.6 composites everything in sRGB; out-of-profile images shift visibly. |
| Alpha channel | Required. Must be fully opaque (alpha = 255) across the entire 96×96 image. No transparency. No pre-multiplied alpha. The alpha channel exists because Godot's TextureRect pipeline expects RGBA; the channel must be solid. |
| Compression | None — saved as uncompressed PNG. Godot's import pipeline applies its own compression on import; pre-compressed PNGs double-process and can introduce ringing. |
| File size ceiling | 60 KB per file. A flat-lit 96×96 PNG with no transparency should be well under 30 KB. Files above 60 KB indicate embedded metadata, wrong bit depth, or wrong format. |

#### Dimensions

**Exact size: 96 × 96 pixels.** No exceptions. Portraits are displayed in a fixed 96×96 TextureRect with no scaling. An incorrectly sized portrait will either clip or scale — both outcomes are wrong. The image must be exactly 96 pixels wide and 96 pixels tall as delivered. No cropping or resizing happens at runtime.

**For CombatCutaway display:** The same 96×96 source file is displayed at 192×192 via 2× nearest-neighbour scaling. This is applied at import/display time — the source file is always 96×96. Do not deliver a 192×192 version.

#### Content and Framing

The portrait must be cropped to chest-up, face centered in the frame, with the crown of the head 4–8 pixels from the top edge and the chin no lower than the vertical midpoint. The face must occupy a minimum of 40% of the image width at the cheekbone level. See Section 3 (Portrait Style Direction) and Section 5.5 (Portrait Consistency Rules) for aesthetic requirements. The framing specification here is a technical delivery requirement, not a substitute for those sections.

#### Color Profile Compliance

Portraits are AI-generated. AI generation tools commonly export in display P3 or AdobeRGB color spaces. These must be converted to sRGB before delivery. The conversion is done in Photoshop (Image → Mode → Convert to Profile → sRGB IEC61966-2.1) or in any tool that supports color profile conversion. Delivering a wide-gamut portrait results in oversaturated, color-shifted display in Godot — the shift is most visible in skin tones and neutral backgrounds.

#### Naming Convention

```
portrait_[faction]_[unit_id].png
```

| Token | Values |
|---|---|
| `[faction]` | `player` / `enemy` / `vanguard` |
| `[unit_id]` | Unit callsign in lowercase: `alpha`, `bravo`, `charlie`, `guardian_01`, `guardian_02`, `rampaging_01`, `tactical_01`, `rival_01` |

**Examples:**
- `portrait_player_alpha.png`
- `portrait_player_bravo.png`
- `portrait_player_charlie.png`
- `portrait_enemy_guardian_01.png`
- `portrait_enemy_rampaging_01.png`
- `portrait_vanguard_rival_01.png`

Rules: lowercase only. Underscore separators only — no hyphens, no spaces. No version suffixes (`_v2`, `_final`, `_new`) in delivered files. Version control is handled by git, not by filename.

#### Directory

```
res://assets/portraits/
```

No subdirectories. All portrait PNGs live flat in this directory. With a maximum expected count of approximately 12 portraits (3 player + 6 enemy archetypes + 3 Vanguard), directory depth adds no benefit and complicates path references in code.

Full paths follow the pattern:
```
res://assets/portraits/portrait_player_alpha.png
res://assets/portraits/portrait_enemy_guardian_01.png
```

#### Fallback Behavior

If a portrait file is missing or fails to load, the portrait slot in the detail panel renders as:
- A flat fill rect in `Color(0.20, 0.20, 0.22)` (a SEAM-adjacent dark grey, distinct from the panel background)
- The unit's designation code (`ALPHA`, `BRAVO`, `G-01`) centered in the slot, 12px monospace, PARCHMENT color

This fallback is defined in `HUD.gd` and must remain functional throughout production. Fallback portraits are not acceptable substitutes for delivered assets — they are engineering safety nets only, used during active development before portraits are generated.

#### Consistency Enforcement

Portraits are reviewed as a set, not individually. For player portraits (ALPHA, BRAVO, CHARLIE): all three must be reviewed simultaneously against the consistency rules in Section 5.5 before any are accepted. A single portrait that fails consistency rejects the batch. The same applies to enemy portraits by archetype group (all Guardians together, all Rampaging together, all Vanguard together).

Review checklist per portrait:
- [ ] 96×96 pixels exactly
- [ ] sRGB color profile
- [ ] RGBA 32-bit PNG, fully opaque alpha
- [ ] Under 60 KB
- [ ] Named per convention
- [ ] Face centered, chest-up crop
- [ ] Lighting direction matches batch (top-left or dead-overhead)
- [ ] Background tone register matches batch (faction-appropriate)
- [ ] No smile, no heroic pose, no cinematic depth-of-field

---

### 8.2 Font Asset Specification

#### Font Selection

**Primary font: JetBrains Mono**
Fallback options (in order, if JetBrains Mono is unavailable): Share Tech Mono → Roboto Mono → Space Mono.

JetBrains Mono is preferred because: zero-ambiguity numerals (no `0/O`, `1/l/I` confusion), consistent stroke weight at small sizes, excellent legibility at 8px in Godot's bitmap renderer, and permissive licensing.

**Zero proportional fonts.** No sans-serif, no serif, no display fonts. The HUD is an instrument readout; every character must occupy the same horizontal cell.

#### License Requirement

The delivered font file must be licensed for:
- Desktop use (PC application distribution)
- Embedding in a shipped binary (Godot exports embed font data)
- Commercial use (required even for indie releases)

JetBrains Mono is licensed under the SIL Open Font License 1.1 — compliant for all three. Any substituted font must carry an equivalent permissive license. Font licenses must be verified before the font file is committed. The license file (`OFL.txt` or equivalent) must be committed alongside the font file.

#### Weights

Exactly two weights are embedded:
- Weight 400 (Regular) — labels, log body, secondary text
- Weight 700 (Bold) — primary values, stat numbers, unit callsigns

No other weights. No Medium 500, no Light 300, no Black 900. If a weight file contains both 400 and 700 as a variable font, use it — but the variable font must be tested at both weight endpoints to confirm Godot 4.6 renders them correctly.

#### Format

**TrueType (.ttf) or OpenType (.otf).** Both are supported by Godot 4.6's font import pipeline. TTF preferred — wider tool support and no compatibility edge cases with Godot's text rendering. Do not use WOFF or WOFF2 (web formats, not supported natively in Godot's import pipeline).

#### Naming Convention

```
[family_name]_[weight].ttf
```

**Examples:**
- `jetbrains_mono_400.ttf`
- `jetbrains_mono_700.ttf`

Lowercase, underscore separators. Weight expressed as the numeric CSS weight value (400/700), not as a word (`regular`/`bold`). This avoids ambiguity when the pipeline adds weights.

If using a variable font that covers both weights in a single file:
```
jetbrains_mono_variable.ttf
```

#### Directory

```
res://assets/fonts/
```

License files live alongside:
```
res://assets/fonts/jetbrains_mono_400.ttf
res://assets/fonts/jetbrains_mono_700.ttf
res://assets/fonts/OFL.txt
```

#### Godot FontFile Resource

In Godot 4.6, fonts are loaded as `FontFile` resources. Two `FontFile` `.tres` resources are maintained in `res://assets/fonts/`: one for weight 400 and one for weight 700. These resources reference the `.ttf` files and are shared across all HUD scripts. Scripts reference the resource, not the raw `.ttf` — this keeps font configuration (hinting, subpixel, size) in one place.

```
res://assets/fonts/font_regular.tres   # FontFile wrapping jetbrains_mono_400.ttf
res://assets/fonts/font_bold.tres      # FontFile wrapping jetbrains_mono_700.ttf
```

#### Fallback Chain

Godot's FontFile supports fallback fonts. The fallback chain for `font_regular.tres` and `font_bold.tres` is:

1. JetBrains Mono (primary)
2. Share Tech Mono (if embedded)
3. Godot's built-in monospace fallback

The fallback is insurance against platform font substitution. Do not rely on it — the primary font must be embedded and present at runtime.

---

### 8.3 File Naming Conventions

All asset filenames follow this universal pattern:

```
[type]_[qualifier(s)]_[id].[ext]
```

- All lowercase
- Underscore separators only — no hyphens, no spaces, no dots except the extension delimiter
- No version suffixes in committed files
- No date suffixes in committed files

#### Convention Table

| Asset Type | Pattern | Example |
|---|---|---|
| Portrait | `portrait_[faction]_[unit_id].png` | `portrait_player_alpha.png` |
| Portrait (import meta) | `portrait_[faction]_[unit_id].png.import` | Auto-generated by Godot — never hand-edited |
| Font (weight-specific) | `[family]_[weight].ttf` | `jetbrains_mono_700.ttf` |
| Font (variable) | `[family]_variable.ttf` | `jetbrains_mono_variable.ttf` |
| Font resource | `font_[role].tres` | `font_regular.tres`, `font_bold.tres` |
| Font license | `[license_id].txt` | `OFL.txt` |
| Tile texture (future) | `tile_[tile_type]_[variant].png` | `tile_floor_standard.png` |
| Audio (future) | `sfx_[category]_[action].wav` | `sfx_combat_hit_toughness.wav` |

#### Forbidden Naming Patterns

The following are rejected at review and must not be committed:

- `portrait_alpha_FINAL.png` — version suffix
- `Portrait_Player_Alpha.png` — mixed case
- `portrait-player-alpha.png` — hyphen separators
- `portrait_player_alpha_v3.png` — version number
- `JetBrainsMono-Regular.ttf` — CamelCase / hyphen (acceptable only as the original downloaded filename before renaming on commit)
- `untitled_portrait.png` — non-descriptive name
- `new_portrait_2.png` — non-descriptive with number

---

### 8.4 Directory Structure

```
res://assets/
├── portraits/
│   ├── portrait_player_alpha.png
│   ├── portrait_player_bravo.png
│   ├── portrait_player_charlie.png
│   ├── portrait_enemy_guardian_01.png
│   ├── portrait_enemy_guardian_02.png
│   ├── portrait_enemy_rampaging_01.png
│   ├── portrait_enemy_rampaging_02.png
│   ├── portrait_enemy_tactical_01.png
│   └── portrait_vanguard_rival_01.png
│
├── fonts/
│   ├── jetbrains_mono_400.ttf
│   ├── jetbrains_mono_700.ttf
│   ├── OFL.txt
│   ├── font_regular.tres
│   └── font_bold.tres
│
└── tiles/                        # Reserved — currently empty
    └── (future tile textures)
```

The `res://assets/sprites/` and `res://assets/audio/` directories exist in the project structure from the template but are **intentionally empty** for Fringe Ledger. They are not removed (doing so would require template changes) but are treated as dead directories. No files are added to them.

**Root assets rule:** No asset files live in `res://assets/` directly — all assets are in a typed subdirectory. This keeps the import pipeline's auto-scan deterministic.

---

### 8.5 Godot Import Settings

#### Portrait Import Settings

Portrait files must be imported with the following settings. These are set in Godot's Import dock and written to the `.import` file alongside each PNG. A committed `.import` file with wrong settings overrides the dock and silently produces wrong output — verify on first import.

| Setting | Value | Reason |
|---|---|---|
| `compress/mode` | `0` (Lossless) | Preserves hard edges in AI-generated portraits. Lossy compression (VRAM, ETC, S3TC) introduces artifacts at color boundaries. |
| `compress/lossy_quality` | N/A (lossless) | Not applicable |
| `mipmaps/generate` | `false` | Portraits are always displayed at 96×96 or 192×192 (2× nearest-neighbour). Mipmaps are for texture-mapped 3D geometry and downscaled sprites — both inapplicable here. Mipmaps waste ~33% memory per texture. |
| `mipmaps/limit` | `-1` (default, irrelevant) | N/A |
| `filter` | `Nearest` | Portraits must not be filtered. Bilinear or trilinear filtering blurs hard pixel edges at 2× scale in CombatCutaway. Nearest-neighbour is mandatory. |
| `repeat` | `Disabled` | Portraits are never tiled. |
| `fix_alpha_border` | `false` | Alpha is fully opaque — no border artifacts possible. |
| `premultiplied_alpha` | `false` | Source PNGs are straight alpha. |
| `hdr_as_srgb` | `false` | Source PNGs are 8-bit sRGB, not HDR. |
| `texture_type` | `2D` | Not a normal map, not a 3D texture. |
| `svg/scale` | N/A | Not an SVG. |

**Import preset:** Create a single Godot import preset named `Portrait` with these settings and apply it to all portrait PNGs. This prevents per-file drift if the Import dock defaults change.

In GDScript, portraits are loaded with:
```gdscript
var tex: ImageTexture = load("res://assets/portraits/portrait_player_alpha.png")
texture_rect.texture = tex
texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
```

Use `STRETCH_KEEP_CENTERED` (not `STRETCH_KEEP`) so the portrait centers in its container if the rect ever diverges from exactly 96×96. The `TEXTURE_FILTER_NEAREST` override is belt-and-suspenders — it ensures nearest-neighbour even if the import preset is misconfigured. Both must be set.

**Rename rule:** All portrait files must be renamed inside the Godot editor's FileSystem dock, not in the OS file explorer. Renaming outside Godot severs the resource UID link and breaks all scene references silently. This applies to all assets in `res://assets/`.

#### Font Import Settings

| Setting | Value | Reason |
|---|---|---|
| `compress` | `false` | Font data is not compressed — it is already efficiently packed by TTF. |
| `hinting` | `Auto` | Godot 4.6 auto-hinting produces correct results at 8–16px. Explicit hinting is only required if auto-hinting is visibly wrong at micro sizes — verify at 8px before changing. |
| `subpixel_positioning` | `Auto` | On by default for sub-8px rendering. At 8px and above, subpixel positioning provides marginal benefit and can cause chromatic fringing on some monitors. Set to `Disabled` if fringing is observed at 8px. |
| `antialiased` | `false` | Monospace numerals at 8–16px must have hard edges. Antialiasing blurs number columns and reduces legibility at small sizes. |
| `multichannel_signed_distance_field` | `false` | MSDF is for large display text scaled at runtime. This HUD uses fixed absolute sizes — MSDF overhead is unwarranted. |
| `fixed_size` | `0` (dynamic) | Fonts are sized by `Label`/`RichTextLabel` `font_size` property at runtime — not baked to a fixed size. |
| `opentype_features` | Default | No special OpenType features required. Tabular numerals are a feature of the typeface itself (JetBrains Mono), not a feature flag. |

> **⚠️ Verification required (Godot 4.6):** The `subpixel_positioning` and `antialiasing` import field enum values changed in Godot 4.4+ due to TextServer refactors. Before committing the font `.tres` files, open the font asset in the Godot 4.6 Import dock and confirm the exact UI labels match this section's intent. The intent is: no antialiasing (hard edges at 8–12px), no subpixel positioning, full hinting. If the Import dock labels differ from the names used here, the dock values take precedence.

---

### 8.6 Future Tile Texture Standards

Tile textures are not currently implemented — tiles are flat-colored rects drawn programmatically. If tile textures are added during the polish phase, they must comply with this specification to avoid breaking the visual system.

**This section is a pre-constraint, not a wishlist.** Adding tile textures that violate this spec will require rework. Establish compliance before generation begins.

#### Specification

| Property | Requirement |
|---|---|
| Dimensions | Exactly 32 × 32 pixels (matches the grid tile size) |
| Format | PNG, RGBA 32-bit, sRGB |
| Alpha channel | Required. Fully opaque (alpha = 255) except for intentional transparency regions (see below) |
| Palette constraint | Must use ONLY the eight canonical palette colors from Section 4, at their exact `Color()` values. AI-generated or hand-painted tiles that introduce hues outside the palette are rejected. |
| Texture character | Flat, matte, no highlights, no gradients, no specular. Tiles are drawn elements of a document, not surfaces with lighting. A tile with a baked highlight reads as three-dimensional; Fringe Ledger's tiles are flat. |
| Transparency use | Only for FLOOR tiles where negative space is the correct read (see Section 6.5). WALL and COVER tile textures must be fully opaque. |
| Animation | None. Tile textures are static. Animated tiles are a prohibited asset type (see Section 8.7). |

#### Import Settings for Tile Textures

Identical to portrait import settings:
- `compress/mode`: Lossless
- `mipmaps/generate`: false
- `filter`: Nearest
- `repeat`: Disabled

Tile textures are drawn tiled across the grid but via Godot's `draw_texture_rect()` in `_draw()` calls, not via a `repeat` flag on the texture itself. The repeat mode is Disabled at the texture level.

#### Naming Convention

```
tile_[tile_type]_[variant].png
```

| Token | Values |
|---|---|
| `[tile_type]` | `floor` / `wall` / `cover_light` / `cover_heavy` / `hazard` / `extraction` |
| `[variant]` | Variant identifier if multiple textures exist per type: `standard`, `alt_01`, `alt_02` |

**Examples:**
- `tile_floor_standard.png`
- `tile_wall_standard.png`
- `tile_cover_heavy_standard.png`
- `tile_hazard_standard.png`

**Directory:** `res://assets/tiles/`

#### Visual Veto Rule

Before any tile texture is integrated into the game, the lead must verify:

1. The programmatic version (current flat rects + draw calls) is shown alongside the textured version on the same map.
2. The textured version must not reduce the legibility of unit circles, ring states, or range highlights.
3. The textured version must not introduce visual noise that competes with gear state communication.

If the textured version fails point 2 or 3, tile textures are not added — the programmatic version is retained permanently. The polish phase tile texture work is contingent on this veto check, not assumed.

---

### 8.7 Prohibition List

The following asset types are explicitly forbidden. Forbidden means: not delivered, not imported, not referenced in any script, not placed in any directory. The reasons are design-systemic, not preference.

#### Animated Sprites (GIF, APNG, SpriteFrames, AnimatedSprite2D)

**Forbidden.** All unit animation is implemented as programmatic draw-call state changes. Introducing an AnimatedSprite2D node would bypass the gear state visual system (crack lines, ring states, opacity modulation) which is drawn in `_draw()` and cannot be composited with a sprite. Additionally, animated sprites require a distinct palette that has to be authored to match the canonical eight colors — an authoring failure point that grows with every animation frame. Animated unit sprites are categorically excluded.

#### Raster UI Panels (PNG or texture-based panel backgrounds, NinePatchRect, StyleBoxTexture)

**Forbidden.** All HUD panels are drawn programmatically. Importing raster UI panels introduces a second source of truth for panel color, border weight, and alpha — one in the PNG, one in the draw calls. When the canonical color values change (e.g., SEAM alpha adjusted for legibility), programmatic panels update immediately; raster panels require re-export. The discrepancy accumulates. All panels must be drawn via `draw_rect()` and `draw_line()`.

#### Icon PNGs (raster icons for UI buttons, status effects, gear slots)

**Forbidden.** Icons are drawn as schematic glyphs using `draw_line()` and `draw_rect()` calls, as specified in Section 7.3. Raster icon PNGs at small sizes (12×12, 16×16) do not survive nearest-neighbour scaling without aliasing, must be re-exported for each size, and cannot be recolored programmatically to respond to state. Schematic glyphs are infinitely recolorable and scale-free.

#### Texture Atlases or Sprite Sheets

**Forbidden.** There are no sprites. There is no texture atlas. Attempting to pack multiple visual elements into a single texture file introduces atlas UV management, which is only warranted when draw call batching is the limiting factor. Fringe Ledger has no such constraint (no sprites, no batched quads, programmatic draw calls). An atlas in this context is engineering overhead with no benefit.

#### Multiple Typefaces

**Forbidden.** One monospace font family, two weights. No display font for titles. No serif font for the mission manifest. No condensed variant for tight spaces. If a label does not fit in its panel, the label is abbreviated — the font is not changed. Multiple typefaces introduce typographic hierarchy decisions that cannot be resolved by the existing four-tier type system and create category ambiguity between `Label` and `RichTextLabel` rendering contexts.

#### Audio Sprite Sheets (Audiosprite files)

**Forbidden as a format** (even though audio is out of scope). If audio is implemented, individual `.wav` files per event are used. Audiosprite tooling is browser/web audio API convention and has no native Godot integration.

#### Any Asset Outside the Eight Canonical Colors

**Forbidden.** If a raster asset (portrait excepted — portraits are photographic and subject to the Section 5.5 rules) contains a color not derivable from the eight canonical palette entries, it is rejected at review. The prohibition on new hues stated in Section 4 applies to raster assets as well as programmatic draw calls.

#### Pre-multiplied Alpha PNGs

**Forbidden.** Godot 4.6 expects straight alpha in PNG imports. Pre-multiplied alpha causes color fringing at transparent edges and incorrect blending when the TextureRect renders over panel backgrounds. All PNG deliveries must use straight alpha.

#### Files with Embedded Metadata (EXIF, XMP, ICC profiles other than sRGB)

**Forbidden in final deliveries.** Embedded metadata bloats file size and can carry ICC profiles that override the sRGB expectation. Strip metadata before committing. Photoshop's "Save for Web" and ExifTool (`exiftool -all= filename.png`) both strip metadata cleanly.

---

## 9. Reference Direction

This section gives contractors a precise starting point, not a mood board. Each reference was selected because it solved a specific visual problem that Fringe Ledger also has. Read the "Draw From" and "Diverge From" descriptions as hard instructions, not suggestions. The references span different media deliberately — no single source should be legible as an influence when the game is finished.

---

### 9.1 — *Darkest Dungeon* (Red Hook Studios, 2016)
**Medium:** Game

**The Problem It Solves:** How to make mechanical state (Intact/Fractured/Broken gear degradation) visually legible without adding new colors or breaking the palette.

**Draw From:** Red Hook's approach to portrait degradation — stress and affliction states are communicated through the same base portrait via overlaid geometric distortions, desaturation shifts within an already-limited palette, and positional tilting of the framing. The portrait itself is the readout. Damage is not a separate indicator layered on top; it is embedded in the presentation of the subject. Specifically: study how a High-Stress portrait reads differently from a Virtuous one using only value contrast and framing angle — no new hues are introduced.

**Diverge From:** The gothic horror line weight and organic linework. Darkest Dungeon's portraits are expressionist — exaggerated anatomy, heavy ink, emotional performance. Fringe Ledger portraits are bureaucratic documents. The degradation technique is what transfers; the rendering style does not. Treat Darkest Dungeon as a mechanical reference, not a tonal one.

**Principle Reinforced:** Wear Is Data — visible degradation equals mechanical degradation.

---

### 9.2 — *Alien* (Ridley Scott, 1979) — Weyland-Yutani Interface Screens
**Medium:** Film (production design / set dressing)

**The Problem It Solves:** How to make a monospace terminal UI read as authoritative and institutional — not retro-kitsch — when the hardware it runs on is visibly worn.

**Draw From:** The Nostromo's shipboard interfaces are amber-phosphor text on flat black — no gradients, no gloss. Information density is high but hierarchy is rigid: headers are all-caps, data rows are fixed-width, alert states are distinguished by text pattern (blinking, reversed-out blocks) rather than color changes. The interfaces look like they were designed by an engineering department that did not consult a UI designer, and that is their authority. This is exactly the register Fringe Ledger's MANDATE-colored objective panels and terminal readouts should occupy.

**Diverge From:** The amber/green phosphor hue itself. That specific color now reads as "retro aesthetic choice" rather than "institutional hardware" because it has been over-referenced in the past decade of retrofuturist games. Fringe Ledger already has PARCHMENT (cream white) as its primary text color on VOID backgrounds, which achieves the same low-glow quality without the nostalgic signal. The typographic grammar transfers; the hue does not.

**Principle Reinforced:** Monospace terminal typography only — and specifically, why that choice carries institutional weight rather than merely aesthetic weight.

---

### 9.3 — Brecht Evens, *Panther* (2014)
**Medium:** Print illustration / comics

**The Problem It Solves:** How to give the three portrait types (ID badge / mug shot / Vanguard headshot) visually distinct registers without introducing new hues.

**Draw From:** Evens works with a fixed watercolor palette across a given work and achieves radical tonal differentiation between characters not by adding colors but by varying saturation density, wash layering, and the ratio of pigment to white space within each figure. A character who occupies more of the frame's white space reads as powerful or official; a character rendered in heavy, overlapping wash reads as compromised or dense. This technique distinguishes the three portrait types: ID badge portraits should feel sparse and high-contrast (official, clinical); mug shots should feel heavy and close-valued (compressed, surveilled); Vanguard headshots should feel composed but warmer in value weight (professional, aspirational).

**Diverge From:** Evens's compositional looseness and organic figure placement. His work intentionally resists grid structure. Fringe Ledger portrait frames are fixed-dimension bureaucratic documents — the framing is rigid even when the rendering within it varies. The value and saturation grammar transfers; the compositional spontaneity does not.

**Principle Reinforced:** Portrait class distinction — three document types using the same 8 colors.

---

### 9.4 — *XCOM: Enemy Unknown* (Firaxis, 2012) — Tactical HUD Only
**Medium:** Game

**The Problem It Solves:** How to lay out a tactical grid UI so that functional information (unit state, action economy, threat range) is spatially organized without competing with the play field.

**Draw From:** XCOM's tactical HUD solved the panel-to-grid boundary problem cleanly: all persistent unit information lives in a bottom strip that does not overlap the grid, and temporary contextual information (aim percentage, cover indicator) is pinned to the unit position in the grid itself, displayed only on demand. The grid and the HUD are in separate spatial registers. Gear condition (Intact/Fractured/Broken) should follow the same rule: persistent state lives in the unit's circle mark, temporary contextual readouts appear on selection only and are pinned to the unit.

**Diverge From:** XCOM's 3D isometric perspective, dramatic camera angle, and environmental theater. None of that exists in Fringe Ledger (flat top-down grid reading as a floor plan). Also diverge from XCOM's use of a full color spectrum to signal faction — Fringe Ledger uses OPERATIVE teal and HOSTILE brick red only.

**Principle Reinforced:** Grid reads as a floor plan / intelligence briefing — the spatial discipline that keeps UI layers from collapsing into each other.

---

### 9.5 — *Bell System Technical Journal* (AT&T, 1925–1983)
**Medium:** Print / institutional document design

**The Problem It Solves:** How to make hard-edge rectangular panels and dense tabular information feel designed rather than unfinished — the risk with a no-rounded-corners, no-decoration rule is that panels read as placeholder art.

**Draw From:** The Bell System's internal technical publications developed a house style built entirely from rules, columns, and weight contrast in a single typeface family. Their page layouts use thick horizontal rules to establish hierarchy, thin rules to subdivide data, and generous but consistent internal margins to keep dense information from collapsing. The result looks intentional rather than sparse. This grammar — thick rule for section break, thin rule for row division, fixed internal padding — should govern every panel border, table, and gear readout card in Fringe Ledger. The "institutional document" feeling comes from rule weight contrast and margin discipline, not from decoration.

**Diverge From:** The warmth of the actual printing — Bell publications used cream stock, which reads as archival and nostalgic in scanned reproduction. Fringe Ledger's VOID background and SEAM border already establish the correct temperature (cold, not warm). The typographic rule grammar transfers; the warmth of the paper stock does not.

**Principle Reinforced:** All UI panels are hard-edge rects — why that constraint produces authority rather than austerity when the internal rule grammar is executed with discipline.

---

### Summary

| Reference | Medium | Specific Technique | Aspect of Fringe Ledger |
|---|---|---|---|
| *Darkest Dungeon* | Game | Degradation embedded in framing, not overlaid | Wear Is Data / gear condition readability |
| *Alien* (1979) interfaces | Film | Text pattern hierarchy, not color — all-caps, fixed-width, reversed-out alerts | Monospace terminal UI authority |
| Brecht Evens | Print / illustration | Saturation density and white-space ratio to differentiate document registers | Three portrait class distinction |
| *XCOM: EU* tactical HUD | Game | Persistent state in unit marks, contextual info grid-pinned on demand | Grid / HUD spatial discipline |
| Bell System Technical Journal | Print / institutional design | Thick/thin rule contrast and margin discipline in dense tabular layouts | Hard-edge panel grammar |

---

When in doubt, ask: does this element exist in the Bell System Journal, on the Nostromo's screen, or in a XCOM action bar? If not, it needs explicit justification before it enters a Fringe Ledger panel. The game should not look like any of these references. It should look like what happens when all five problems are solved at once.
