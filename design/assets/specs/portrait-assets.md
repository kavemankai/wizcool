# Asset Specs — Portraits: All Characters

> **Source**: design/assets/entity-inventory.md, design/art/art-bible.md
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-06-08
> **Status**: 8 assets specced / 8 approved / 6 placeholder-delivered / 2 needed
>
> **Roster:** Player crew ALPHA/BRAVO/CHARLIE (ASSET-001/002/003) and the named
> Vanguard rival crew leader/soldier/tech (ASSET-006/035/036) are recurring
> *individuals* — placeholder portraits delivered and wired into the HUD inspect
> panel. SENTINEL and PRISONER (ASSET-004/005) are faceless archetype *types*
> (one face per type, many units) and are not yet produced.

---

## ASSET-001 — portrait_player_alpha.png

| Field | Value |
|---|---|
| Category | Portrait |
| Dimensions | 96×96px |
| Format | PNG, 32-bit RGBA, straight alpha |
| Color profile | sRGB, no embedded ICC profile |
| File size | ≤60 KB (typical 8–20 KB lossless) |
| Naming | `portrait_player_alpha.png` |
| Resource path | `res://assets/portraits/portrait_player_alpha.png` |
| Import preset | Standard Portrait Preset |
| TextureRect | `stretch_mode = STRETCH_KEEP_CENTERED`, `texture_filter = TEXTURE_FILTER_NEAREST` |
| LOD | None — fixed UI element, locked 1280×720 viewport |

**Visual Description:**
A chest-up institutional ID photo of a woman in her mid-forties, shot dead-frontal under flat fluorescent overhead light that washes colour evenly across her face — no dramatic shadows, no glamour. She wears a worn facility jacket in FIELDGREY with a MANDATE-brown collar patch, the fabric creased at the shoulders from long use. Her expression is contained, not hard — the face of someone who has filled out the paperwork on both sides of the desk and knows exactly what you need from her.

**Art Bible Anchors:**
- §1 Visual Identity: flat lighting and contained expression enforce "functional authority over aesthetic spectacle"
- §3 Shape Language: institutional ID badge context; chest-up crop; frontal angle; degradation readable at 96×96px via collar wear and fabric creasing
- §5 Colour Coding: PARCHMENT-register warmth dominant; FIELDGREY and MANDATE as secondary gear colours

**Generation Prompt:**
Industrial hard science fiction character portrait, ID badge photo aesthetic, institutional employee credential photograph, chest-up crop, dead-frontal angle, flat even fluorescent overhead lighting, no shadows on face, facility interior background in muted grey (#6B7280 fieldgrey), subject: woman mid-forties, weathered face with controlled expression, authority without ornamentation, worn facility jacket in military grey with bureaucratic brown collar detail (#8B5E3C), warm off-white parchment skin light register (#F2E9D8), visible fabric wear and use-history on gear, cassette-futurism industrial aesthetic, Alien Weyland-Yutani institutional document style, degradation reads as history not damage, Darkest Dungeon portrait wear-as-data approach, matte finish, no lens flare, no glow, desaturated palette with single warm parchment register, monochrome near-black background panel (#0A0A0C void), photorealistic oil-painting texture, institutional authority, functional not decorative

`--no` bright colours, purple, teal, orange, blue, dramatic lighting, heroic pose, fantasy elements, supernatural, magic, smiling, glamour, beauty lighting, rim light, lens flare, bokeh, atmospheric fog, military medals, ornaments, sci-fi glowing elements, dynamic angle, action pose, full body

**Status:** Needed

---

## ASSET-002 — portrait_player_bravo.png

| Field | Value |
|---|---|
| Category | Portrait |
| Dimensions | 96×96px |
| Format | PNG, 32-bit RGBA, straight alpha |
| Color profile | sRGB, no embedded ICC profile |
| File size | ≤60 KB (typical 8–20 KB lossless) |
| Naming | `portrait_player_bravo.png` |
| Resource path | `res://assets/portraits/portrait_player_bravo.png` |
| Import preset | Standard Portrait Preset |
| TextureRect | `stretch_mode = STRETCH_KEEP_CENTERED`, `texture_filter = TEXTURE_FILTER_NEAREST` |
| LOD | None — fixed UI element, locked 1280×720 viewport |

**Visual Description:**
A chest-up ID badge photo of a man in his early thirties, three-quarter angle so slight it barely registers — institutional, not artistic. The lighting is the same facility fluorescent register as ALPHA: flat, even, slightly cool, pulling both portraits into the same physical space. He wears a utility vest in FIELDGREY over a plain underlayer, pockets structured for carrying things rather than looking like he carries things. His expression is attentive and ready, oriented toward someone just off-frame — support posture, present without leading.

**Art Bible Anchors:**
- §1 Visual Identity: support role communicates through gear configuration and posture — function visible, no performance
- §3 Shape Language: same facility light register as ALPHA is a hard rule — crew consistency requires portraits to feel physically co-present; slight angle variation allowed but must not read as artistic intent
- §5 Colour Coding: FIELDGREY center-dot register; FIELDGREY (#6B7280) dominant

**Generation Prompt:**
Industrial hard science fiction character portrait, ID badge photo aesthetic, institutional site-access credential photograph, chest-up crop, very slight three-quarter angle barely perceptible, flat even fluorescent facility lighting matching crew light register, facility interior background plain institutional grey (#6B7280 fieldgrey), subject: man early thirties, attentive ready expression oriented slightly off-frame, utility vest in military grey with structured functional pockets (#6B7280 fieldgrey dominant), neutral support role reads from posture and gear configuration, same light register as crew leader portrait — same facility same fluorescent overhead, cassette-futurism industrial aesthetic, worn fabric visible at pocket edges and collar, no ornamentation, institutional documentary style, desaturated fieldgrey palette register, near-black background panel (#0A0A0C void), matte finish photorealistic oil-painting texture, functional working gear, degradation as history

`--no` bright colours, purple, teal, orange, warm amber tones, dramatic lighting, heroic pose, fantasy elements, supernatural, glowing equipment, different light register from crew, beauty lighting, rim light, lens flare, bokeh, atmospheric fog, medals, ornaments, dynamic angle, full body, sci-fi glowing UI elements, weapons displayed prominently

**Status:** Needed

---

## ASSET-003 — portrait_player_charlie.png

| Field | Value |
|---|---|
| Category | Portrait |
| Dimensions | 96×96px |
| Format | PNG, 32-bit RGBA, straight alpha |
| Color profile | sRGB, no embedded ICC profile |
| File size | ≤60 KB (typical 8–20 KB lossless) |
| Naming | `portrait_player_charlie.png` |
| Resource path | `res://assets/portraits/portrait_player_charlie.png` |
| Import preset | Standard Portrait Preset |
| TextureRect | `stretch_mode = STRETCH_KEEP_CENTERED`, `texture_filter = TEXTURE_FILTER_NEAREST` |
| LOD | None — fixed UI element, locked 1280×720 viewport |

**Visual Description:**
A chest-up ID badge photo of a person in their late twenties — the same crew fluorescent light as ALPHA and BRAVO, but something in their posture is slightly displaced, like they sat down a half-second before being told to. The gear is precise and lean: fewer pockets than BRAVO, but what's there is specific and chosen, not standard-issue. A slight asymmetry in how they've arranged their collar or worn their badge signals off-script energy without breaking the institutional frame.

**Art Bible Anchors:**
- §1 Visual Identity: off-script energy must be legible within the institutional frame — disruptor reads through gear specificity, not expression performance
- §3 Shape Language: distinguishing feature per archetype rule — asymmetric detail is the readable silhouette marker at 96×96px
- §5 Colour Coding: FIELDGREY crosshair register; SEAM (#1E1E24) for structural/collar lines

**Generation Prompt:**
Industrial hard science fiction character portrait, ID badge photo aesthetic, institutional site-access credential photograph, chest-up crop, slight three-quarter angle with subtle off-centre energy, flat even fluorescent facility lighting same crew light register as team leader, facility interior background plain institutional grey (#6B7280 fieldgrey), subject: person late twenties, contained but slightly displaced posture suggesting non-standard role, lean precise gear — fewer items but specifically chosen, asymmetric small detail in collar or badge placement, specialist disruptor archetype readable through equipment specificity not quantity, same facility fluorescent overhead light register as crew, cassette-futurism aesthetic, FIELDGREY dominant register (#6B7280) with near-black structural lines (#1E1E24 seam), matte finish photorealistic, worn fabric edges, institutional ID document feel, functional precision over decoration

`--no` bright colours, purple, teal, orange, warm parchment tones dominant, dramatic lighting, heroic action pose, fantasy elements, supernatural, glowing gear, weapons aggressively displayed, beauty lighting, rim light, lens flare, bokeh, atmospheric effects, medals, full body, different light register from crew

**Status:** Needed

---

## ASSET-004 — portrait_enemy_sentinel.png

| Field | Value |
|---|---|
| Category | Portrait |
| Dimensions | 96×96px |
| Format | PNG, 32-bit RGBA, straight alpha |
| Color profile | sRGB, no embedded ICC profile |
| File size | ≤60 KB (typical 8–20 KB lossless) |
| Naming | `portrait_enemy_sentinel.png` |
| Resource path | `res://assets/portraits/portrait_enemy_sentinel.png` |
| Import preset | Standard Portrait Preset |
| TextureRect | `stretch_mode = STRETCH_KEEP_CENTERED`, `texture_filter = TEXTURE_FILTER_NEAREST` |
| LOD | None — fixed UI element, locked 1280×720 viewport |

**Visual Description:**
A security-system capture — slightly off-axis, as though the camera caught the subject at the end of an escort rather than at the start of a fresh intake. The subject is a large, heavy-built person who has clearly done this before: upright, not combative, expression flat and patient in a way that reads as practiced containment of something larger underneath. Lighting is uneven, one side of the face two stops hotter than the other, throwing the jaw and brow into mild relief — the asymmetry is institutional carelessness, not dramatic intent.

**Art Bible Anchors:**
- §1 Visual Identity: cooperative but guarded — subject has a history with institutional documentation, not performing threat
- §3 Shape Language: off-axis framing and uneven lighting explicitly permitted for enemy portraits; degradation in framing itself communicates archetype
- §5 Colour Coding: SENTINEL uses double-ring in SEAM; SEAM register (#1E1E24) dominant — heavier and more institutional than player portraits

**Generation Prompt:**
Industrial hard science fiction character portrait, security system automated capture photograph, mug shot documentation aesthetic, chest-up crop, slightly off-axis framing as if automated camera caught subject mid-stop, uneven institutional lighting one side of face noticeably hotter than other, strong brow and jaw in partial relief, facility intake background in near-black void (#0A0A0C) with SEAM structural panel lines (#1E1E24), subject: large heavy-built person, flat patient expression of practiced compliance — cooperative but guarded, heavy institutional clothing SEAM dark register (#1E1E24), worn collar and cuffs showing long use, guardian archetype readable through physical mass and contained stillness, cassette-futurism Alien Weyland-Yutani document aesthetic, SEAM register dominant throughout, degradation as institutional history, photorealistic matte oil-painting texture, no glamour

`--no` bright colours, purple, teal, warm amber, parchment warmth, dramatic hero lighting, fantasy, supernatural, glowing elements, aggressive expression, action pose, dynamic angle, beauty lighting, rim light, lens flare, bokeh, atmospheric fog, medals, full body, smiling

**Status:** Needed

---

## ASSET-005 — portrait_enemy_prisoner.png

| Field | Value |
|---|---|
| Category | Portrait |
| Dimensions | 96×96px |
| Format | PNG, 32-bit RGBA, straight alpha |
| Color profile | sRGB, no embedded ICC profile |
| File size | ≤60 KB (typical 8–20 KB lossless) |
| Naming | `portrait_enemy_prisoner.png` |
| Resource path | `res://assets/portraits/portrait_enemy_prisoner.png` |
| Import preset | Standard Portrait Preset |
| TextureRect | `stretch_mode = STRETCH_KEEP_CENTERED`, `texture_filter = TEXTURE_FILTER_NEAREST` |
| LOD | None — fixed UI element, locked 1280×720 viewport |

**Visual Description:**
A mug shot of someone who did not stop moving quite in time for the shutter — a micro-blur at the jaw edge, tension visible in the neck and the set of the shoulders, the kind of physical agitation that fluorescent light makes worse. The face is younger than it should be for what's written on it, jaw clenched, eyes not meeting the camera lens but not looking away either — locked somewhere between. CAUTION amber bleeds in through the available light, as though the intake room has a hazard lamp still live in frame-left.

**Art Bible Anchors:**
- §1 Visual Identity: agitation is functional data, not spectacle — blur and tension are information about what this unit does in combat
- §3 Shape Language: blur acceptable for PRISONER specifically as motion-history; uneven lighting and off-axis framing permitted for enemies
- §5 Colour Coding: PRISONER uses CAUTION arrowhead-up mark; CAUTION amber (#D4A017) dominant, marking volatility through colour scarcity principle
- §9 Reference Direction: Darkest Dungeon — stress as visual data applied directly

**Generation Prompt:**
Industrial hard science fiction character portrait, mug shot institutional documentation photograph, chest-up crop, subject non-cooperative agitated, slight motion micro-blur at jaw or shoulder edge suggesting subject still moving at capture, physical tension visible in neck muscles and shoulder set, jaw clenched, eyes not meeting lens, facility intake background with CAUTION amber hazard light source from frame-left bleeding into portrait (#D4A017 dirty amber), contrast sharper and more volatile than guardian portrait, subject: younger person physical agitation evident, CAUTION warm amber register dominant (#D4A017) against near-black void background (#0A0A0C), rampaging archetype readable through restless energy and body tension not weapon display, cassette-futurism, Darkest Dungeon stress-as-visual-data approach, uneven harsh fluorescent intake lighting, photorealistic matte texture, institutional document aesthetic

`--no` calm expression, cooperative posture, parchment warmth, seam grey dominant, fantasy, supernatural, glowing sci-fi elements, heroic pose, dynamic action, beauty lighting, rim light, bokeh, atmospheric fog, smile, full body, weapons displayed, purple, teal, blue

**Status:** Needed

---

## VANGUARD — Named Rival Crew (ASSET-006 / 035 / 036)

> **The Vanguard are a recurring named rival crew that mirrors the player crew
> — three distinct individuals, not faceless mooks.** They map to the spawn
> code's `VANGUARD-1/2/3` units (and their per-slot gear): VANGUARD-1 = leader,
> VANGUARD-2 = soldier (carries the BALLISTIC-PLATE), VANGUARD-3 = tech (carries
> the medkit). Like the player crew, generate all three in **one session sharing
> a register** — but a *different* register from the player crew: cleaner
> **corporate personnel lighting** + **MANDATE brown**, because the Vanguard are
> the well-resourced rival company. Same-crew glue, three distinct people/roles.
> HUD maps `unit_id` → portrait, so the filenames are role-based, not numeric.

---

## ASSET-006 — portrait_enemy_vanguard_leader.png (VANGUARD-1, leader)

| Field | Value |
|---|---|
| Category | Portrait |
| Dimensions | 96×96px |
| Format | PNG, 32-bit RGBA, straight alpha |
| Color profile | sRGB, no embedded ICC profile |
| File size | ≤60 KB (typical 8–20 KB lossless) |
| Naming | `portrait_enemy_vanguard_leader.png` |
| Resource path | `res://assets/portraits/portrait_enemy_vanguard_leader.png` |
| Maps to unit | `VANGUARD-1` |
| Import preset | Standard Portrait Preset |
| TextureRect | HUD inspect panel, `STRETCH_KEEP_ASPECT_CENTERED`, `TEXTURE_FILTER_LINEAR` |

**Visual Description:**
The crew's commander — mid-fifties, calculating and patient, the face of someone who plans several moves ahead. A corporate personnel headshot: clean controlled lighting, MANDATE-brown senior authority gear, maintained not neglected. Deep charcoal VOID background. Reads as control and choice, not aggression.

**Art Bible Anchors:**
- §1 Visual Identity: the Vanguard have resources and agency the player crew does not — their cleaner corporate register encodes that
- §3 Shape Language: rival crew shares one register (like the player crew) but each member is a distinct individual/role
- §5 Colour Coding: MANDATE brown (#8B5E3C) governs the whole Vanguard crew register

**Generation Prompt:**
Industrial hard science fiction character portrait, corporate security personnel file headshot, chest-up crop, deliberate three-quarter angle, clean even corporate lighting slightly cool and well-resourced, deep charcoal void background no facility markers (#0A0A0C void to #1E1E24 seam gradient), subject: person mid-fifties, calculating controlled expression, intelligent and patient — plans several moves ahead, senior institutional authority gear in MANDATE bureaucratic brown (#8B5E3C) with maintained collar and lapel, the crew's commander, MANDATE register dominant, reads as control and choice not aggression, cassette-futurism Alien Weyland-Yutani corporate authority aesthetic, photorealistic matte oil-painting texture, even corporate light discipline, no rim, no glamour

`--no` mug shot framing, aggressive expression, motion blur, bright colours, purple, teal, blue, parchment warmth dominant, fieldgrey dominant, caution amber, fantasy, supernatural, glowing elements, medals, heroic rim-lit hero shot, dynamic angle, full body, beauty lighting, lens flare, bokeh

**Status:** Placeholder delivered (wired to HUD)

---

## ASSET-035 — portrait_enemy_vanguard_soldier.png (VANGUARD-2, soldier)

| Field | Value |
|---|---|
| Category | Portrait |
| Dimensions | 96×96px |
| Format | PNG, 32-bit RGBA, straight alpha |
| Color profile | sRGB, no embedded ICC profile |
| File size | ≤60 KB (typical 8–20 KB lossless) |
| Naming | `portrait_enemy_vanguard_soldier.png` |
| Resource path | `res://assets/portraits/portrait_enemy_vanguard_soldier.png` |
| Maps to unit | `VANGUARD-2` (carries BALLISTIC-PLATE) |
| Import preset | Standard Portrait Preset |
| TextureRect | HUD inspect panel, `STRETCH_KEEP_ASPECT_CENTERED`, `TEXTURE_FILTER_LINEAR` |

**Visual Description:**
The crew's muscle — a mid-twenties super-soldier, physically imposing (tall, heavy-shouldered, thick neck, square clean-cut jaw — Jack Reacher / John Cena physicality), short regulation haircut, calm neutral controlled expression. Heavy corporate combat gear with a visible ballistic plate, MANDATE brown. Same corporate light register as the rest of the crew. Physical certainty, not aggression.

**Art Bible Anchors:**
- §1 Visual Identity: power read as calm institutional certainty, not a magazine cover — guards against the AAA hero-render failure mode
- §5 Colour Coding: MANDATE brown (#8B5E3C) shared crew register

**Generation Prompt:**
Industrial hard science fiction character portrait, corporate security personnel file headshot, chest-up crop, slight three-quarter angle, clean even corporate lighting matching crew register, deep charcoal void background (#0A0A0C to #1E1E24), subject: man mid-twenties, physically imposing super-soldier build — tall, heavy-shouldered, thick neck, square clean-cut jaw (Jack Reacher / John Cena physicality), short regulation haircut, calm neutral controlled expression, heavy corporate combat gear with MANDATE brown collar and shoulder yoke and visible ballistic plate (#8B5E3C dominant), the crew's muscle, MANDATE register dominant, physical certainty not aggression, cassette-futurism corporate authority aesthetic, photorealistic matte oil-painting texture, even corporate light, no rim, no glamour

`--no` mug shot framing, aggressive snarl, gritted teeth, combat action pose, weapons displayed, oiled-up bodybuilder, shirtless, heroic rim-lit hero shot, bright colours, purple, teal, blue, parchment warmth, fieldgrey dominant, caution amber, motion blur, fantasy, glowing elements, medals, dynamic angle, full body, beauty lighting, lens flare, bokeh

**Status:** Placeholder delivered (wired to HUD)

---

## ASSET-036 — portrait_enemy_vanguard_tech.png (VANGUARD-3, tech)

| Field | Value |
|---|---|
| Category | Portrait |
| Dimensions | 96×96px |
| Format | PNG, 32-bit RGBA, straight alpha |
| Color profile | sRGB, no embedded ICC profile |
| File size | ≤60 KB (typical 8–20 KB lossless) |
| Naming | `portrait_enemy_vanguard_tech.png` |
| Resource path | `res://assets/portraits/portrait_enemy_vanguard_tech.png` |
| Maps to unit | `VANGUARD-3` (carries the medkit) |
| Import preset | Standard Portrait Preset |
| TextureRect | HUD inspect panel, `STRETCH_KEEP_ASPECT_CENTERED`, `TEXTURE_FILTER_LINEAR` |

**Visual Description:**
The crew's tech specialist — a wiry person, late twenties, lean and restless with quick alert intelligence: a tinkerer. MANDATE-brown corporate utility gear festooned with mechanical diagnostic tools, a magnifier loupe at the collar, cabling and hand-tools in chest straps — technical, not combat. Competence reads through equipment specificity. Same corporate light register as the crew.

**Art Bible Anchors:**
- §3 Shape Language: distinguishing marker is gear specificity (tools, loupe, cabling), not expression — readable role at a glance
- §5 Colour Coding: MANDATE brown (#8B5E3C) shared crew register; tools stay matte, no glowing sci-fi elements

**Generation Prompt:**
Industrial hard science fiction character portrait, corporate security personnel file headshot, chest-up crop, slight three-quarter angle, clean even corporate lighting matching crew register, deep charcoal void background (#0A0A0C to #1E1E24), subject: wiry person late twenties, lean and restless with quick alert intelligence — a technical tinkerer, slightly jittery focused energy, short practical hair, MANDATE brown corporate utility gear (#8B5E3C dominant) festooned with mechanical diagnostic tools, a magnifier loupe clipped at the collar, cabling and small hand-tools in chest straps — technical not combat, the crew's tech specialist, MANDATE register dominant, competence through equipment specificity, cassette-futurism Alien Weyland-Yutani aesthetic, photorealistic matte oil-painting texture, even corporate light, no rim, no glamour

`--no` glowing screens, glowing sci-fi UI, neon, holograms, cyberpunk neon, bright colours, purple, teal, blue, parchment warmth, fieldgrey dominant, caution amber, mug shot framing, aggressive expression, motion blur, heroic pose, fantasy, supernatural, medals, dynamic angle, full body, beauty lighting, rim light, lens flare, bokeh

**Status:** Placeholder delivered (wired to HUD)

---

## Shared: Common Import Preset

All 8 portraits use identical Godot import settings.

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

⚠️ **Godot 4.6 verification required:** Confirm `compress/mode = 0` maps to Lossless in the Godot 4.6 TextureImporter before shipping.

**TextureRect display size note:** Nearest-neighbour filter at a control size larger than 96×96 will produce visible pixel blocks. Confirm HUD TextureRect control dimensions are 96×96 before commissioning production art.

**Rename rule:** Assets must only be renamed inside the Godot editor (FileSystem dock) — never by renaming the file externally — so that `.import` sidecar files stay in sync.

---

## Cross-Asset Consistency Notes

**Player crew (ASSET-001–003):** All three lit from the same flat facility
fluorescent source — the shared light register is the crew's visual glue.
Register: grungy facility fluorescent, FIELDGREY-dominant.

**Vanguard rival crew (ASSET-006/035/036):** Also a crew — generate all three
in one session sharing a register, but a *different* one from the player crew:
clean corporate personnel lighting, MANDATE-brown dominant (they're the
well-resourced rival company). Three distinct individuals/roles
(leader / soldier / tech) mapping to `VANGUARD-1/2/3`. Watch-item: "super-
soldier" prompts pull toward AAA cinematic hero renders — keep the `--no` lists
on so power reads as calm institutional certainty, not a magazine cover.

**Faceless enemy types (ASSET-004–005):** SENTINEL and PRISONER are archetype
*types*, not individuals — one face represents all units of that kind. Each uses
a distinct capture context implying its relationship to institutional systems:
- SENTINEL: has been processed before (calm, experienced) — off-axis security capture, SEAM register
- PRISONER: has not accepted it (tension, motion blur) — CAUTION amber register

**Palette discipline:** No asset should introduce a hue not present in the 8 canonical colours. Skin tones are naturalistic and exempt from this rule; all fabric, background, gear, and light-source colours must map to the canonical set.
