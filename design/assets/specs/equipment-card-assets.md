# Asset Specs — Equipment Cards

> **Source**: design/assets/entity-inventory.md, design/gdd/gear-economy.md, design/art/art-bible.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-06-08
> **Status**: 7 assets specced / 7 approved / 0 in production / 0 done

These are Manifest Screen and Terminal Hub illustration assets — NOT inline HUD icons. HUD icons are programmatic draw calls (prohibited from being raster PNGs per §8.7).

---

## Shared: Equipment Card Import Preset

All 7 equipment cards use identical Godot import settings. Create a named preset "equipment-card-flat" in the Godot importer and apply to all 7.

```ini
[importer = "texture"]
compress/mode = 0
compress/high_quality = false
compress/lossy_quality = 0.7
compress/normal_map = 0
compress/channel_pack = 0
mipmaps/generate = false
mipmaps/limit = -1
roughness/mode = 0
roughness/src_normal = ""
process/fix_alpha_border = true
process/premult_alpha = false
process/normal_map_invert_y = false
process/hdr_as_sRGB = false
process/hdr_clamp_exposure = false
process/size_limit = 0
detect_3d/compress_to = 0
```

⚠️ Verify `compress/mode = 0` maps to Lossless in Godot 4.6 TextureImporter before shipping.

**TextureRect display:**
- `stretch_mode = STRETCH_KEEP_CENTERED`
- `texture_filter = TEXTURE_FILTER_NEAREST` (set at node level — not in import preset)

⚠️ **Display scaling constraint:** Nearest-neighbour upscaling only produces clean results at exact integer multiples (×2 = 128×128, ×3 = 192×192). Design card slot controls at 64×64 or 128×128 only — non-integer target sizes (e.g., 80×80) will produce uneven pixel rows that destroy the schematic line aesthetic.

⚠️ **Project default filter:** Check `Project Settings > Rendering > Textures > Default Texture Filter`. If not Nearest, every card TextureRect must set `TEXTURE_FILTER_NEAREST` explicitly.

**Palette enforcement:** The 8-colour palette constraint at 64×64 with no anti-aliasing will compress extremely well — typical 1–6 KB. Any file approaching 15 KB signals unintended anti-aliased edges or embedded metadata in the source file.

**Hyphenated filenames:** `item_plasma-cutter.png` etc. are valid Godot resource paths. Hyphens are legal in filesystem paths. Concern only arises if constructing GDScript variable names directly from filenames — use string literals or a lookup table for `load()` calls.

**Production note:** Commission the three player weapons (ASSET-007/008/009) in one session and review side-by-side before finalising — silhouette differentiation (compact pistol vs. squat front-heavy head vs. full-frame horizontal length) must be clear at 64px. Same for the two armours (ASSET-010/013) — open-vs-closed negative-space contrast must read at 64px.

---

## ASSET-007 — item_plasma-cutter.png

| Field | Value |
|---|---|
| Category | Equipment card |
| Dimensions | 64×64px |
| Format | PNG, 32-bit RGBA, straight alpha, sRGB |
| File size | ≤30 KB hard max (typical 1–6 KB lossless flat schematic) |
| Naming | `item_plasma-cutter.png` |
| Resource path | `res://assets/items/item_plasma-cutter.png` |
| Import preset | Equipment Card Preset |
| Slot | weapon |
| In-game unit | ALPHA (starts each mission FRACTURED) |

**Visual Description:**
A handheld industrial plasma cutter rendered as a flat technical diagram, three-quarter side profile showing both the pistol-grip body and forward emitter assembly. The body is a compact rectangular block in FIELDGREY with SEAM grip wrap; the forward barrel tapers to a narrow emitter tip with a visible energy channel rendered as a thin OPERATIVE-blue line from power cell to tip. A hairline fracture mark on the FIELDGREY casing in SEAM communicates the FRACTURED starting state. OPERATIVE dominates the energy elements; FIELDGREY dominates the chassis.

**Art Bible Anchors:**
- §1 Visual Identity: tool reads as belonging to a system, not a hero; fracture mark communicates function state, not character
- §3 Shape Language: emitter tip and energy channel imply directed-energy damage type; silhouette clears at 64px
- §4 Palette: OPERATIVE for energy elements; FIELDGREY neutral chassis; SEAM structural lines
- §8 Reference: Bell System Technical Journal component isolation; Weyland-Yutani institutional tool aesthetic

**Generation Prompt:**
Flat technical illustration, engineering schematic style, hard-edge line art, no shading, no gradients, no ambient occlusion. Industrial plasma cutting tool, compact pistol-grip body, forward-tapered barrel ending in a narrow emitter tip, thin energy channel line running barrel length, visible power cell housing block at rear, hairline fracture mark on casing. Primary colour field FIELDGREY #6B7280 body, OPERATIVE #3A7CA5 energy channel and emitter element, SEAM #1E1E24 structural line work, VOID #0A0A0C background. Composition centred in square frame, strong silhouette legible at small size. Machine parts catalogue illustration. Bell System Technical Journal diagram aesthetic. Weyland-Yutani institutional tool design.

`--no` shadows, gradients, ambient occlusion, photorealism, 3D render, glow bloom, lens flare, decorative elements, organic shapes, hero weapon styling, ornamentation, textures, hatching

**Status:** Needed

---

## ASSET-008 — item_impact-wrench.png

| Field | Value |
|---|---|
| Category | Equipment card |
| Dimensions | 64×64px |
| Format | PNG, 32-bit RGBA, straight alpha, sRGB |
| File size | ≤30 KB (typical 1–6 KB) |
| Naming | `item_impact-wrench.png` |
| Resource path | `res://assets/items/item_impact-wrench.png` |
| Import preset | Equipment Card Preset |
| Slot | weapon |
| In-game unit | BRAVO |

**Visual Description:**
A heavy-duty impact wrench in flat side-elevation, emphasising mass in the weighted drive head at lower-left and the chunky pistol grip. The drive head is a broad hexagonal socket block in MANDATE brown — worn institutional authority — transitioning into a thick barrel body in FIELDGREY. The grip is a dense rectangular handle with implied rubber wrap shown only as a change in line weight, not texture. The overall silhouette is squat and front-heavy, communicating blunt physical mass. FIELDGREY dominates the body; MANDATE anchors the drive socket.

**Art Bible Anchors:**
- §1 Visual Identity: facility tool, not a protagonist's weapon
- §3 Shape Language: front-heavy mass distribution implies blunt impact damage; silhouette clarity primary concern at 64px
- §4 Palette: MANDATE on drive head for institutional/worn authority; FIELDGREY neutral chassis

**Generation Prompt:**
Flat technical illustration, engineering schematic style, hard-edge line art, no shading, no gradients. Heavy-duty impact wrench, side elevation view, large hexagonal drive socket head dominating left-side mass, thick barrel body, chunky rectangular pistol grip, no decorative elements, blunt heavy silhouette. Primary colour field FIELDGREY #6B7280 barrel and body, MANDATE #8B5E3C drive socket head, SEAM #1E1E24 structural outlines and internal detail lines, VOID #0A0A0C background. Composition centred in square frame, front-heavy silhouette reads clearly at 64px. Industrial tool catalogue diagram. Functional, institutional tool design.

`--no` shadows, gradients, ambient occlusion, photorealism, 3D render, decorative elements, ornamentation, chrome finish, stylised proportions, cartoon, hatching, textures

**Status:** Needed

---

## ASSET-009 — item_long-bore-drill.png

| Field | Value |
|---|---|
| Category | Equipment card |
| Dimensions | 64×64px |
| Format | PNG, 32-bit RGBA, straight alpha, sRGB |
| File size | ≤30 KB (typical 1–6 KB) |
| Naming | `item_long-bore-drill.png` |
| Resource path | `res://assets/items/item_long-bore-drill.png` |
| Import preset | Equipment Card Preset |
| Slot | weapon |
| In-game unit | CHARLIE |

**Visual Description:**
A long-barrel industrial drill in strict side elevation to maximise horizontal silhouette length — must be the longest weapon in the set, occupying the full horizontal span of the frame. Wide drive-mechanism body at rear-right in FIELDGREY; a banded rotary collar ring in MANDATE at mid-shaft; three-flute drill bit terminating in a narrow point at the left in PARCHMENT line work. The length-to-width ratio immediately distinguishes it from the IMPACT-WRENCH. FIELDGREY dominates; MANDATE marks the rotary mechanism.

**Art Bible Anchors:**
- §1 Visual Identity: extreme utilitarian length reads as purpose-built facility equipment, not carried gear
- §3 Shape Language: horizontal span is the primary silhouette signal differentiating this weapon class; drill geometry implies penetrating force
- §4 Palette: FIELDGREY chassis; MANDATE mid-shaft mechanism; PARCHMENT drill tip line work for contrast

**Generation Prompt:**
Flat technical illustration, engineering schematic style, hard-edge line art, no shading, no gradients. Extended industrial rotary drill, strict side elevation, long horizontal barrel spanning full frame width, rear drive-body housing block at right, visible banded rotary collar ring at mid-shaft, narrow three-flute drill bit point at left terminus, longest silhouette proportion of any handheld item. Primary colour field FIELDGREY #6B7280 barrel and body, MANDATE #8B5E3C mid-shaft rotary collar band, PARCHMENT #F2E9D8 for drill bit flute lines, SEAM #1E1E24 structural outlines, VOID #0A0A0C background. Full-width horizontal composition in square frame, extreme length-to-width ratio, legible at 64px. Industrial boring tool catalogue diagram.

`--no` shadows, gradients, ambient occlusion, photorealism, 3D render, decorative elements, short proportions, pistol shape, chunky silhouette, ornamentation, hatching, textures

**Status:** Needed

---

## ASSET-010 — item_work-harness.png

| Field | Value |
|---|---|
| Category | Equipment card |
| Dimensions | 64×64px |
| Format | PNG, 32-bit RGBA, straight alpha, sRGB |
| File size | ≤30 KB (typical 1–6 KB) |
| Naming | `item_work-harness.png` |
| Resource path | `res://assets/items/item_work-harness.png` |
| Import preset | Equipment Card Preset |
| Slot | armor |
| In-game unit | BRAVO |

**Visual Description:**
Front-elevation flat schematic of a load-bearing work harness — torso-shaped outline with visible shoulder straps, chest webbing, and two thin side chest panels in FIELDGREY. Lightweight and open-frame: straps render as flat lines with buckle rectangles at intersections, with visible negative space between straps. MANDATE-coloured buckles signal institutional issue. The open silhouette visually distinguishes it from the BALLISTIC-PLATE's closed mass.

**Art Bible Anchors:**
- §1 Visual Identity: standard-issue appearance, no hero customisation
- §3 Shape Language: negative space communicates lighter/speed-priority gear versus full coverage; buckle geometry is load-bearing implication
- §4 Palette: FIELDGREY for utility; MANDATE institutional buckle hardware

**Generation Prompt:**
Flat technical illustration, engineering schematic style, hard-edge line art, no shading, no gradients. Front-elevation industrial work harness, load-bearing webbing straps across shoulders and chest, rectangular buckle details at strap intersections, two thin side chest plates, open-frame silhouette with visible negative space between straps, lightweight utilitarian appearance. Primary colour field FIELDGREY #6B7280 chest plates and strap lines, MANDATE #8B5E3C buckle rectangle details, SEAM #1E1E24 structural outlines, VOID #0A0A0C background. Centred torso-form composition in square frame, open negative space visible, legible at 64px. Industrial safety equipment catalogue diagram. Lighter and more open than a ballistic plate carrier.

`--no` shadows, gradients, ambient occlusion, photorealism, 3D render, decorative elements, full-coverage plate, hero armour styling, organic shapes, ornamentation, hatching, textures, pouches, gear clutter

**Status:** Needed

---

## ASSET-011 — item_field-patch-kit.png

| Field | Value |
|---|---|
| Category | Equipment card |
| Dimensions | 64×64px |
| Format | PNG, 32-bit RGBA, straight alpha, sRGB |
| File size | ≤30 KB (typical 1–6 KB) |
| Naming | `item_field-patch-kit.png` |
| Resource path | `res://assets/items/item_field-patch-kit.png` |
| Import preset | Equipment Card Preset |
| Slot | medical |
| In-game unit | ALPHA (consumed on use; enables Field Patch action) |

**Visual Description:**
Flat side-elevation of a compact pressurised canister with applicator nozzle — the visual language of an industrial sealant or medical patch dispenser. The canister body is a vertical rounded-corner rectangle in PARCHMENT, communicating consumable/active-player item; a ribbed grip band in FIELDGREY sits mid-body; a short nozzle tip in CAUTION amber projects from the top, signalling urgency and single-use disposability. A small horizontal fill-level window cut into the canister body suggests near-empty/consumable nature.

**Art Bible Anchors:**
- §1 Visual Identity: disposable consumable; communicates function and single-use nature, not ownership
- §3 Shape Language: compact canister silhouette implies consumability; CAUTION tip implies careful handling
- §4 Palette: PARCHMENT for primary player-active item body; CAUTION on nozzle marks urgency (not HOSTILE — that is enemy-coded)

**Generation Prompt:**
Flat technical illustration, engineering schematic style, hard-edge line art, no shading, no gradients. Compact pressurised canister medical applicator, side elevation, rounded-corner rectangular cylinder body, ribbed grip band at mid-body, short nozzle tip at top, small rectangular fill-level indicator window on body, compact and disposable proportions, functional urgency implied. Primary colour field PARCHMENT #F2E9D8 canister body, CAUTION #D4A017 nozzle tip and fill-indicator border, FIELDGREY #6B7280 grip band ribs, SEAM #1E1E24 structural outlines, VOID #0A0A0C background. Vertically oriented composition centred in square frame, compact and readable at 64px. Medical/industrial supply catalogue diagram. Consumable tool aesthetic.

`--no` shadows, gradients, ambient occlusion, photorealism, 3D render, cross symbol, red cross, decorative markings, complex label text, ornamentation, hatching, textures, large proportions, hero item styling

**Status:** Needed

---

## ASSET-012 — item_salvage-pistol.png

| Field | Value |
|---|---|
| Category | Equipment card |
| Dimensions | 64×64px |
| Format | PNG, 32-bit RGBA, straight alpha, sRGB |
| File size | ≤30 KB (typical 1–6 KB) |
| Naming | `item_salvage-pistol.png` |
| Resource path | `res://assets/items/item_salvage-pistol.png` |
| Import preset | Equipment Card Preset |
| Slot | weapon |
| In-game unit | VANGUARD (drops as loot on GEAR_BROKEN result) |

**Visual Description:**
Flat side-elevation of a stripped-down compact ballistic sidearm — the smallest and cheapest-looking weapon in the inventory. The frame is skeletal: minimal rectangular slide body, thin plain barrel with no suppressor or rails, plain rectangular grip with no wrap detail. The silhouette communicates austerity — no material surplus anywhere. FIELDGREY only on the frame; SEAM lines sparse, with no detail lines that aren't structurally necessary. Must read as a parts-bin assembly, not a designed weapon, and be the least visually dense item in the weapon category.

**Art Bible Anchors:**
- §1 Visual Identity: cheapest item in inventory; visual austerity communicates tier hierarchy through visual density, not styling
- §3 Shape Language: minimal silhouette; low visual density is a deliberate signal of low item tier
- §4 Palette: FIELDGREY only — no OPERATIVE energy, no MANDATE institutional weight — it belongs to no system, it was salvaged

**Generation Prompt:**
Flat technical illustration, engineering schematic style, hard-edge line art, no shading, no gradients. Compact ballistic sidearm, side elevation, minimal stripped-down frame, skeletal slide body, thin plain barrel, rectangular grip with no wrap ornamentation, no attachment rails, no tactical accessories, bare functional silhouette. Cheapest and most austere weapon in catalogue. Primary colour field FIELDGREY #6B7280 frame and slide, SEAM #1E1E24 minimal structural outlines only, VOID #0A0A0C background. Composition centred and compact within square frame — lowest visual density of any weapon card. Industrial salvage parts catalogue diagram. Bare-minimum functional sidearm.

`--no` shadows, gradients, ambient occlusion, photorealism, 3D render, tactical accessories, rails, suppressor, decorative elements, hero weapon styling, ornamentation, hatching, textures, aggressive styling, large frame

**Status:** Needed

---

## ASSET-013 — item_ballistic-plate.png

| Field | Value |
|---|---|
| Category | Equipment card |
| Dimensions | 64×64px |
| Format | PNG, 32-bit RGBA, straight alpha, sRGB |
| File size | ≤30 KB (typical 1–6 KB) |
| Naming | `item_ballistic-plate.png` |
| Resource path | `res://assets/items/item_ballistic-plate.png` |
| Import preset | Equipment Card Preset |
| Slot | armor |
| In-game unit | VANGUARD rank 2+ only |

**Visual Description:**
Front-elevation flat schematic of a rigid ballistic plate carrier — heavier, more closed, and more coverage-dense than the WORK-HARNESS. Broad solid front chest panel in FIELDGREY, visible side continuation panels, narrow shoulder plate extensions. Compared to ASSET-010, negative space is minimal — the plates dominate the frame. A single horizontal seam line bisects the chest panel; four small MANDATE mounting bracket rectangles mark the corners, signalling institutional-grade hardware. The WORK-HARNESS feels like webbing; this must feel like armour. FIELDGREY dominates; MANDATE anchors the bracket hardware.

**Art Bible Anchors:**
- §1 Visual Identity: institutional-grade, issued to VANGUARD rank 2+ only; heavier closed silhouette communicates tiered access versus the WORK-HARNESS
- §3 Shape Language: closed silhouette and minimal negative space communicate protective coverage and weight; bracket geometry implies rigid structural mounting
- §4 Palette: FIELDGREY neutral armour field; MANDATE brackets signal regulated institutional-issue equipment — not salvage

**Generation Prompt:**
Flat technical illustration, engineering schematic style, hard-edge line art, no shading, no gradients. Front-elevation rigid ballistic plate carrier, broad solid chest panel dominating frame, side continuation panels, narrow shoulder plate extensions, single horizontal seam line across chest, four small corner mounting bracket rectangles, minimal negative space, heavy closed silhouette. Visibly heavier and more coverage-dense than a work harness. Primary colour field FIELDGREY #6B7280 plate panels, MANDATE #8B5E3C corner mounting brackets, SEAM #1E1E24 structural outlines and panel seam lines, VOID #0A0A0C background. Centred broad torso-form composition in square frame, closed silhouette with minimal gaps, legible at 64px. Institutional-grade armour catalogue diagram.

`--no` shadows, gradients, ambient occlusion, photorealism, 3D render, decorative elements, hero armour styling, open-frame webbing, organic shapes, ornamentation, hatching, textures, pouches, gear clutter, camouflage

**Status:** Needed
