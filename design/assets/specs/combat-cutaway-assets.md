# Asset Specs — CombatCutaway VFX & Backgrounds

> **Source**: design/art/art-bible.md §8, design/gdd/combat-cutaway.md, scripts/ui/CombatCutaway.gd
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-06-08
> **Status**: 5 assets specced / 0 approved / 0 in production / 0 done

These assets are used exclusively by `CombatCutaway.gd` (CanvasLayer layer=10).
Three are pixel-art VFX sprites; two are full-panel atmospheric background renders.
They occupy different sub-directories and have different import presets — do not mix them.

---

## Naming Convention — Confirmation

All five asset names use **hyphen-free underscore snake_case** throughout. This is
consistent with §8.3 of the art bible and with portrait assets
(`portrait_player_alpha.png`, `portrait_enemy_guardian_01.png`). The equipment card
assets (ASSET-007 through 013) are a legacy anomaly — they were specced with hyphens
inside the `[id]` segment (`item_plasma-cutter.png`) and noted as such in their spec.
No new assets after ASSET-013 carry that deviation. The five assets below follow the
canonical `[type]_[qualifier]_[id].png` pattern with underscores only.

---

## Shared: VFX Sprite Import Preset

All three VFX sprite assets (ASSET-014, 015, 016) use identical Godot import settings.
Create a named preset **"vfx-sprite"** in the Godot Import dock and apply to all three.

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
process/fix_alpha_border = false
process/premult_alpha = false
process/normal_map_invert_y = false
process/hdr_as_sRGB = false
process/hdr_clamp_exposure = false
process/size_limit = 0
detect_3d/compress_to = 0
```

**Node-level display setting (all VFX TextureRect nodes):**
```gdscript
texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
```

Set this at the node level in code — not in the import preset. The preset controls
disk storage; the node filter controls runtime sampling. Both must be set.

**Why `fix_alpha_border = false`:** VFX sprites are authored with intentional
hard pixel edges. The fix_alpha_border pass softens transparent border pixels to
reduce fringing during bilinear filtering. Since these assets always use NEAREST
filtering, the pass is unnecessary and would soften edges in the source data.

---

## Shared: Background Import Preset

Both background assets (ASSET-017, 018) use a separate preset. Create a named preset
**"cutaway-bg"** and apply to both.

```ini
[importer = "texture"]
compress/mode = 0
compress/high_quality = false
compress/lossy_quality = 0.85
compress/normal_map = 0
compress/channel_pack = 0
mipmaps/generate = false
mipmaps/limit = -1
roughness/mode = 0
roughness/src_normal = ""
process/fix_alpha_border = false
process/premult_alpha = false
process/normal_map_invert_y = false
process/hdr_as_sRGB = false
process/hdr_clamp_exposure = false
process/size_limit = 0
detect_3d/compress_to = 0
```

**Node-level display setting (background TextureRect nodes):**
```gdscript
texture_rect.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
```

**Note on `compress/lossy_quality = 0.85`:** This field is ignored when
`compress/mode = 0` (Lossless). It is kept in the preset so that if lossless is
later reconsidered (see §ASSET-017 and §ASSET-018 discussion), the quality value is
already staged. Verify `compress/mode` mapping in Godot 4.6 — see warning below.

---

> **Godot 4.6 Verification Required:** The `compress/mode` integer-to-mode mapping
> has historically been: `0=Lossless`, `1=Lossy`, `2=VRAM Compressed`,
> `3=VRAM Uncompressed`, `4=Basis Universal`. Confirm this mapping in the Godot 4.6
> Import dock before committing any `.import` files — a wrong value silently applies
> VRAM compression (which introduces DCT artifacts on pixel-art edges and destroys
> the 8-colour palette constraint on VFX sprites). The equipment-card spec carries
> the same warning.

---

## ASSET-014 — vfx_muzzle_flash (two-frame)

### Summary

Two separate PNG files representing frame 1 and frame 2 of a muzzle flash effect.
Loaded programmatically as individual textures; no AnimatedSprite2D or SpriteFrames
resource is used. Animation is driven by `CombatCutaway.gd`'s tween system.

### Files

| File | Resource Path |
|------|---------------|
| `vfx_muzzle_flash_f1.png` | `res://assets/vfx/vfx_muzzle_flash_f1.png` |
| `vfx_muzzle_flash_f2.png` | `res://assets/vfx/vfx_muzzle_flash_f2.png` |

### Technical Spec

| Field | Value |
|-------|-------|
| Category | VFX sprite — pixel art |
| Dimensions | 32×32 px per file |
| Format | PNG, RGBA 32-bit |
| Bit depth | 8 bits per channel |
| Color profile | sRGB, no embedded ICC profile |
| Alpha type | Straight alpha (not pre-multiplied) |
| Compression | Lossless (`compress/mode = 0`) |
| File size target | ≤ 4 KB each. A 32×32 RGBA PNG at 8-colour with hard edges should be ≈0.5–2 KB. Files exceeding 4 KB indicate anti-aliased edges, embedded metadata, or wrong format. |
| Import preset | "vfx-sprite" (see Shared section) |
| Texture filter | `TEXTURE_FILTER_NEAREST` (node level) |
| Mipmaps | `false` — 2D overlay, no distance scaling |
| Repeat | Disabled |
| Palette | 8 canonical colors only — CAUTION amber + MANDATE gold for flash core, VOID for transparent background. No anti-aliasing; hard pixel edges mandatory. |
| Display size | 64×64 px (2× integer scale applied at TextureRect) |
| LOD | None — single scale, no distance variation |

### Display (TextureRect settings)

```gdscript
# Applied in CombatCutaway.gd when attacker fires
var muzzle_rect := TextureRect.new()
muzzle_rect.texture = load("res://assets/vfx/vfx_muzzle_flash_f1.png")
muzzle_rect.stretch_mode = TextureRect.STRETCH_KEEP
muzzle_rect.custom_minimum_size = Vector2(64, 64)
muzzle_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
# Swap to f2 on next frame, then hide
```

### Visual Description

**Frame 1 — Starburst Flash (PARCHMENT + CAUTION)**
An 8-point starburst centred at pixel 16,16. Four cardinal rays extend 12 pixels from centre; four diagonal rays extend 8 pixels, giving a slightly asymmetric cross-hatch that reads as mechanical discharge rather than magical sparkle. The cardinal rays are 2 pixels wide at base, tapering to 1 pixel at tip. Diagonal rays are 1 pixel wide throughout. The centre 3×3 block is solid PARCHMENT. Cardinal rays are PARCHMENT for the inner 6 pixels, then CAUTION for the outer 6 pixels. Diagonal rays are CAUTION throughout. No fill between rays — fully transparent. Reads as a hard mechanical burst: bright at core, amber-ringed at edge.

**Frame 2 — Decay Haze (FIELDGREY)**
The starburst geometry collapses. A roughly circular scatter of 12–16 individual pixels in FIELDGREY, distributed within a 20×20 area centred at 16,16. No connected rays — only isolated pixel specks arranged loosely around the centre, denser toward middle and sparser at edge. The centre 2×2 block has no fill (the flash has discharged). Reads as cooling residue, gun smoke particulate, the thermal ghost of the shot.

### AI Generation Prompts

**Frame 1:**
`pixel art, 32x32 pixels, 8-point starburst muzzle flash, hard pixel edges, no anti-aliasing, no gradients, transparent background, two-color palette only: warm off-white #F2E9D8 center and inner rays, dirty amber #D4A017 outer rays, 4 wide cardinal rays tapering to point, 4 narrow diagonal rays, crisp mechanical starpoint shape, no glow, no blur, retro game sprite`

**Frame 2:**
`pixel art, 32x32 pixels, muzzle flash afterglow decay haze, hard pixel edges, no anti-aliasing, transparent background, single color palette: military grey #6B7280, 12 to 16 isolated pixel specks arranged in loose circle, denser at center sparser at edge, no connected lines, no rays, particulate scatter pattern, gun smoke residue, retro game sprite`

**Art Bible Anchors:**
- Hard pixel edges, no anti-aliasing — canonical VFX sprite rule
- CAUTION (#D4A017): "hazard / dirty amber" — appropriate for ballistic discharge energy
- FIELDGREY (#6B7280): "neutral / military grey" — decay register, cooling
- §1 Visual Identity: starburst geometry is mechanical, not decorative; 8-point count is functional, not ornamental

### Two-File vs Spritesheet — Rationale and Implications

The two frames are **separate PNG files**, not a horizontal/vertical spritesheet. This
is consistent with the art bible §8.7 prohibition on texture atlases and sprite sheets.
It is also the simplest loading path — each frame is a standalone `load()` call.

Implication for Godot loading: both files must be loaded at scene start (or at cutaway
init time), not on-demand mid-animation. Lazy loading a texture on the same frame you
need it visible will stall the render thread and cause a frame drop. Load both frames
in `_ready()` or at the earliest `CombatCutaway` initialization point and hold
references on the node.

```gdscript
# In CombatCutaway._build_ui() or _ready():
var _muzzle_f1: Texture2D = load("res://assets/vfx/vfx_muzzle_flash_f1.png")
var _muzzle_f2: Texture2D = load("res://assets/vfx/vfx_muzzle_flash_f2.png")
```

Both `.import` files will be auto-generated by Godot on first import. Commit both
`.import` files alongside the PNGs. Do not import one file without the other.

### Godot 4.6 Notes

- No AnimatedSprite2D or SpriteFrames resource. The tween in `_play_attack_animation()`
  already handles the muzzle flash timing via `flash_alpha` on `CutawayUnit`. If a
  dedicated TextureRect is added for the muzzle sprite, it should be composited above
  `_atk_sprite` in the draw order, positioned at `_ATK_HOME + Vector2(65, -3)` to
  align with where the bullet originates.
- `CutawayUnit.gd` currently draws its flash as a filled circle via `draw_circle()`
  (not a texture). If ASSET-014 replaces that programmatic flash, the `flash_alpha`
  property on `CutawayUnit` may need to be repurposed or a separate `TextureRect`
  node added as a sibling. Confirm architecture before integration.
- Texture2D loads are reference-counted in Godot 4.6. Holding both frame references
  as member variables on `CombatCutaway` is the correct pattern.

---

## ASSET-015 — vfx_impact_flash.png

### Files

| File | Resource Path |
|------|---------------|
| `vfx_impact_flash.png` | `res://assets/vfx/vfx_impact_flash.png` |

### Technical Spec

| Field | Value |
|-------|-------|
| Category | VFX sprite — pixel art |
| Dimensions | 192×192 px |
| Format | PNG, RGBA 32-bit |
| Bit depth | 8 bits per channel |
| Color profile | sRGB, no embedded ICC profile |
| Alpha type | Straight alpha (not pre-multiplied) |
| Compression | Lossless (`compress/mode = 0`) |
| File size target | ≤ 30 KB. A 192×192 RGBA PNG at 8-colour with large transparent regions should be ≈4–15 KB. Files near or above 30 KB indicate anti-aliased gradients, embedded metadata, or wrong format. |
| Import preset | "vfx-sprite" (see Shared section) |
| Texture filter | `TEXTURE_FILTER_NEAREST` (node level) |
| Mipmaps | `false` |
| Repeat | Disabled |
| Palette | 8 canonical colors only. Core: PARCHMENT near-white for the brightest flash centre. Mid-ring: CAUTION amber. Outer falloff: HOSTILE brick-red or VOID via transparent pixels — no soft gradient; use dithered or hard-step pixel rings. |
| Display size | 192×192 px — no scaling. Overlay is placed over the defender portrait panel area. |
| Display alpha | 60% modulate (`modulate.a = 0.60`) on hit frame in `_play_attack_animation()`. |
| LOD | None |

### Display

```gdscript
# Placed over _def_sprite in CombatCutaway — composited above the defender portrait
var impact_rect := TextureRect.new()
impact_rect.texture = load("res://assets/vfx/vfx_impact_flash.png")
impact_rect.stretch_mode = TextureRect.STRETCH_KEEP
impact_rect.custom_minimum_size = Vector2(192, 192)
impact_rect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
impact_rect.modulate.a = 0.0  # Hidden at rest; set to 0.60 on hit frame
```

Position centered on `_DEF_HOME` (screen pos 965, 430), so the rect origin sits at
approximately (869, 334) to center the 192×192 texture on the defender sprite anchor.

### Visual Description and Production Recommendation

**Art director recommendation: implement programmatically, not as a sprite asset.**

This effect is a solid rectangle filled with PARCHMENT (#F2E9D8) composited over the defender portrait panel at 60% alpha for one frame, then cleared. There is no internal structure, falloff, texture, or gradient — within the 8-colour hard-pixel constraint, a falloff or vignette would require dithered pixel rings that add visual noise to what should be a clean, blunt flash of force.

The effect reads correctly because its impact comes from timing (exists for one frame, then cuts), not from internal visual complexity. A `ColorRect` node with `color = Color("#F2E9D8")` and `modulate.a = 0.6` is the correct implementation. If the project pipeline requires a physical PNG file, produce it as a single solid fill of #F2E9D8, 192×192px, exported lossless. File size will be trivial.

**Art Bible Anchors:**
- PARCHMENT (#F2E9D8): "primary text, active player / off-white warm" — repurposed as flash register; warmth reads as kinetic energy rather than cold white noise
- §1 Visual Identity: "functional authority over aesthetic spectacle" — the effect is blunt and unadorned; communicates impact through timing, not decoration

### Art Direction Note

The 192×192 canvas is large relative to the sprite zone. The flash artwork should
occupy a compact inner region (60–80px radius from centre) with the remainder being
fully transparent pixels. This preserves hard-edge character without the flash
visually claiming the full 192×192 frame at rest.

### Godot 4.6 Notes

- At 192×192 with large transparent regions, the PNG will compress efficiently. If
  the artist delivers a solid-filled 192×192 (no transparency outside the flash
  shape), file size will increase but remain under 30 KB at 8-colour lossless.
- The 60% alpha is applied via `modulate.a` on the TextureRect node, not baked into
  the PNG alpha channel. Keep the PNG alpha at full (255) for the flash shape pixels.
  This separation keeps the artwork reusable at different intensities.
- `fix_alpha_border = false` in the import preset is correct here. At NEAREST
  sampling, no border-softening is needed or wanted.

---

## ASSET-016 — vfx_bullet.png

### Files

| File | Resource Path |
|------|---------------|
| `vfx_bullet.png` | `res://assets/vfx/vfx_bullet.png` |

### Technical Spec

| Field | Value |
|-------|-------|
| Category | VFX sprite — pixel art |
| Dimensions | 16×4 px |
| Format | PNG, RGBA 32-bit |
| Bit depth | 8 bits per channel |
| Color profile | sRGB, no embedded ICC profile |
| Alpha type | Straight alpha (not pre-multiplied) |
| Compression | Lossless (`compress/mode = 0`) |
| File size target | ≤ 1 KB. A 16×4 RGBA PNG at 8-colour is trivially small — ≈300–700 bytes including PNG header. Any file above 1 KB indicates metadata. |
| Import preset | "vfx-sprite" (see Shared section) |
| Texture filter | `TEXTURE_FILTER_NEAREST` (node level) |
| Mipmaps | `false` |
| Repeat | Disabled |
| Palette | 8 canonical colors only. Use MANDATE gold / CAUTION amber for the core pixels (leading edge bright, trailing edge darker). Optionally a 1–2px transparent tail. No gradients. |
| Display size | 16×4 px — no scaling. Texture replaces the current `ColorRect` bullet (`Color(0.95, 0.90, 0.40)`, `size = Vector2(14, 6)`) in `CombatCutaway.gd`. |
| LOD | None |

### Visual Description and Production Recommendation

**Art director recommendation: manually authored pixel art — no AI generation prompt.**

At 16×4px and 64 total pixels, per-pixel precision is the only viable authoring method. AI generation cannot be directed at this level of granularity.

**Pixel layout (all 4 rows identical):**
- Pixels 1–4: transparent
- Pixels 5–13: FIELDGREY (#6B7280) — trail body
- Pixels 14–16: PARCHMENT (#F2E9D8) — leading edge (bright nose of the round)

Hard cut between FIELDGREY and PARCHMENT at pixel 14 — no intermediate colour. The result is a 3-pixel bright nose and a 9-pixel grey trail. At intended in-game velocity (crossing the centre strip in 3–4 frames), the FIELDGREY smears into motion and the PARCHMENT tip reads as the point of the round.

**Manual production spec (Aseprite / LibreSprite):**
- Canvas: 16×4px, transparent background
- Fill pixels 14–16 on all 4 rows: #F2E9D8
- Fill pixels 5–13 on all 4 rows: #6B7280
- Pixels 1–4: transparent
- Export as PNG, no anti-aliasing, nearest-neighbour

**Art Bible Anchors:**
- PARCHMENT leading edge: "active player / primary" register — the lethal tip is the player's agency made visible
- FIELDGREY trail: "neutral / military grey" — spent wake of a round, neither threatening nor friendly
- §1 Visual Identity: bullet geometry is a rectangle because that is the correct tool for this resolution

### Current Implementation Context

`CombatCutaway.gd` line 379–383 creates a `ColorRect` bullet:

```gdscript
_bullet = ColorRect.new()
_bullet.size = Vector2(14.0, 6.0)
_bullet.color = Color(0.95, 0.90, 0.40)
```

ASSET-016 is the textured replacement when a sprite is desired. The ColorRect
implementation is already functional and palette-compliant; ASSET-016 is an
enhancement, not a requirement. If integrated, replace the `ColorRect` with a
`TextureRect` using `STRETCH_KEEP` and `TEXTURE_FILTER_NEAREST`. The tween in
`_play_attack_animation()` targets `position:x` on `_bullet` — this works identically
on either node type.

### Display

```gdscript
# Replacement for ColorRect _bullet in CombatCutaway._build_ui():
_bullet = TextureRect.new()
(_bullet as TextureRect).texture = load("res://assets/vfx/vfx_bullet.png")
(_bullet as TextureRect).stretch_mode = TextureRect.STRETCH_KEEP
_bullet.custom_minimum_size = Vector2(16, 4)
_bullet.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
_bullet.visible = false
_bullet.mouse_filter = Control.MOUSE_FILTER_IGNORE
root.add_child(_bullet)
```

The 16×4 px size closely matches the current 14×6 ColorRect. Adjust the bullet spawn
x-offset in `_play_attack_animation()` from `_ATK_HOME.x + 65.0` if needed to
account for the 2px width difference.

### Godot 4.6 Notes

- Very small textures (16×4) are fully resident in GPU memory at all times — no
  streaming concern.
- At NEAREST filter, the horizontal travel animation will show clean pixel-sharp
  edges at all x positions. No sub-pixel interpolation.
- The type annotation issue: `_bullet` is declared as `var _bullet: ColorRect` in
  the current script. If replaced with `TextureRect`, update the type annotation to
  `var _bullet: TextureRect` or the common base `Control`. A `Node2D` base won't
  work here since the tween targets `position:x` on a Control.

---

## ASSET-017 — cutaway_bg_player.png

### Files

| File | Resource Path |
|------|---------------|
| `cutaway_bg_player.png` | `res://assets/backgrounds/cutaway_bg_player.png` |

### Technical Spec

| Field | Value |
|-------|-------|
| Category | CombatCutaway background — atmospheric render |
| Dimensions | 640×720 px |
| Format | PNG, RGB 24-bit (no alpha required) |
| Bit depth | 8 bits per channel |
| Color profile | sRGB, no embedded ICC profile |
| Alpha type | None — RGB PNG has no alpha channel |
| Compression | See lossless assessment below |
| Import preset | "cutaway-bg" (see Shared section) |
| Texture filter | `TEXTURE_FILTER_LINEAR` (node level) |
| Mipmaps | `false` — 2D overlay at fixed display size, no mip chain needed |
| Repeat | Disabled |
| Display size | 640×720 px — no scaling. Placed as background behind the left (attacker) portrait panel. |
| LOD | None |

### Lossless PNG Assessment — ASSET-017

**Expected file size at lossless PNG:** A 640×720 RGB PNG with atmospheric content
(environmental gradients, soft lighting, film grain) will typically compress to
**300–700 KB** losslessly. Photographic or rendered images with continuous-tone
content compress poorly under PNG's DEFLATE algorithm because they lack the
repetitive scanline runs that pixel art exploits.

**Expected file size at high-quality lossy (JPEG or lossy PNG):** At quality 85–90,
the same 640×720 atmospheric render typically compresses to **40–90 KB** — a 5–8×
reduction with imperceptible quality loss on environmental backgrounds.

**Recommendation:** Use lossless PNG as specified by §8, but **flag this as a
candidate for lossy compression if total project asset budget is a concern.** For a
PC-primary target with no download size constraint, 600 KB per background panel is
acceptable — two panels total ≈1.2 MB, which is negligible against a shipped build.
The §8 lossless preference is rational here primarily because:

1. There is no loss of quality at any compression level to protect against.
2. PC distribution has no meaningful size constraint (unlike mobile or web).
3. The re-export workflow is simpler with lossless source truth.

**If lossy is adopted:** Use `compress/mode = 1` (Lossy) and `compress/lossy_quality
= 0.85` in the import preset. Do not use JPEG directly on disk — keep the source as
PNG (lossless) and let Godot's importer apply lossy compression to the internal VRAM
representation. This preserves the source file integrity while reducing VRAM
footprint.

**Conflict with §8:** §8 states lossless compression for all assets. For backgrounds,
the lossless preference is low-risk but also low-benefit at PC scale. This is flagged
as an **advisory exception candidate**, not a violation. The lead must make the call
before import presets are committed.

### Display

```gdscript
# Background TextureRect behind left panel — added before _atk_sprite in _build_ui()
var bg_player := TextureRect.new()
bg_player.texture = load("res://assets/backgrounds/cutaway_bg_player.png")
bg_player.position = Vector2(0, 0)          # Left half of 1280×720 viewport
bg_player.custom_minimum_size = Vector2(640, 720)
bg_player.stretch_mode = TextureRect.STRETCH_KEEP
bg_player.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
bg_player.mouse_filter = Control.MOUSE_FILTER_IGNORE
root.add_child(bg_player)
# Must be added before _atk_sprite and panel ColorRects so it draws behind them
```

### Visual Description

An interior bay of an industrial maintenance or operations facility. The viewing angle is slightly below eye-level, looking across a low concrete floor toward a far wall approximately 15 metres away. The architecture is utilitarian poured concrete with exposed overhead conduit runs crossing horizontally at ceiling height. Two banks of ceiling-mounted fluorescent strip lights — one left, one right of centre — provide the primary illumination, implied by two columns of warm-grey light falling on the floor and near wall. The floor shows worn grid-line scoring, possibly painted lane markings half-eroded. There is a dark doorway or access hatch in the far-left corner, slightly open, implying habitation and passage. The space reads as occupied but not populated — the crew's working environment, functional and slightly worn in.

**Palette behaviour:** Far wall and ceiling register at SEAM (#1E1E24) to near-VOID at edges; floor mid-zone catches faint OPERATIVE (#3A7CA5) from an off-screen monitor implied by a thin blue horizontal line at floor level; FIELDGREY (#6B7280) occupies the mid-register concrete surfaces.

### AI Generation Prompt

`dark industrial interior, facility operations bay, concrete floor and walls, two ceiling fluorescent strip lights casting warm grey columns of light, horizontal conduit runs at ceiling, worn painted grid lines on floor, dark access hatch in far left corner slightly ajar, slightly low camera angle, muted colour palette, near-black shadows, military grey concrete mid-tones, faint muted steel blue accent at floor level from implied monitor glow, no human figures, utilitarian architecture, atmospheric depth, photographic but desaturated, cassette futurism, retro-industrial sci-fi interior, cinematic still, 640x720 portrait orientation, dark composition suitable as background layer behind portrait overlay`

**Art Bible Anchors:**
- VOID/SEAM dominant: backgrounds must recede — predominantly dark register, low contrast at depth
- OPERATIVE accent (faint): signals player-side operational zone without asserting it
- §2 Mood: controlled, mid-register lighting, neutral-cool ambient — attacker is in a position of initiative
- §6 Environment: industrial facility grammar — horizontal, low angle, open bay communicates habitation and workflow

### Art Direction

Not subject to the 8-colour pixel-art palette constraint. This is an atmospheric
environment render. Targets the **Tactical Skirmish — Attacker** mood register (§2):
controlled, mid-register lighting, neutral-cool ambient. The image must not contain
readable faces, clear logos, or detailed text — it is environmental context for the
attacker side, not a narrative illustration.

**Tone guidance for the attacker panel:** Industrial facility, operational position,
deployment staging area. Cool-neutral light. Structured geometry (corridors, crates,
structural columns). The attacker is in a position of initiative — the space should
read as controlled and purposeful, not exposed.

### Godot 4.6 Notes

- `TEXTURE_FILTER_LINEAR` is appropriate — atmospheric renders should not show
  pixelation at 640×720 native display.
- No mipmaps needed: the image is always displayed at exactly 640×720 with no
  downscaling path in the 2D pipeline.
- Ensure draw order: background TextureRects must be added to the root Control
  *before* the dark overlay `ColorRect` and panel `ColorRect` nodes in `_build_ui()`.
  The current `_build_ui()` adds the overlay at index 0 (first child = drawn first =
  bottom of visual stack). Backgrounds should be inserted at index 0, pushing the
  overlay to index 1. Alternatively, add backgrounds via a dedicated `_build_backgrounds()`
  call at the top of `_build_ui()` before `ovr` is added.

---

## ASSET-018 — cutaway_bg_enemy.png

### Files

| File | Resource Path |
|------|---------------|
| `cutaway_bg_enemy.png` | `res://assets/backgrounds/cutaway_bg_enemy.png` |

### Technical Spec

| Field | Value |
|-------|-------|
| Category | CombatCutaway background — atmospheric render |
| Dimensions | 640×720 px |
| Format | PNG, RGB 24-bit (no alpha required) |
| Bit depth | 8 bits per channel |
| Color profile | sRGB, no embedded ICC profile |
| Alpha type | None |
| Compression | See lossless assessment (identical to ASSET-017) |
| Import preset | "cutaway-bg" (see Shared section) |
| Texture filter | `TEXTURE_FILTER_LINEAR` (node level) |
| Mipmaps | `false` |
| Repeat | Disabled |
| Display size | 640×720 px — no scaling. Placed as background behind the right (defender) portrait panel. |
| LOD | None |

### Lossless PNG Assessment — ASSET-018

Identical analysis to ASSET-017. Expected lossless size: 300–700 KB. Expected lossy
(q=85) size: 40–90 KB. The two background panels together at lossless PNG total
≈600 KB–1.4 MB — well within PC build tolerances. The §8 lossless preference
applies; flag as a low-priority exception candidate if asset budget tightens.

### Display

```gdscript
# Background TextureRect behind right panel — added before _def_sprite in _build_ui()
var bg_enemy := TextureRect.new()
bg_enemy.texture = load("res://assets/backgrounds/cutaway_bg_enemy.png")
bg_enemy.position = Vector2(640, 0)         # Right half of 1280×720 viewport
bg_enemy.custom_minimum_size = Vector2(640, 720)
bg_enemy.stretch_mode = TextureRect.STRETCH_KEEP
bg_enemy.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
bg_enemy.mouse_filter = Control.MOUSE_FILTER_IGNORE
root.add_child(bg_enemy)
```

### Visual Description

An institutional security corridor — narrow, high-ceilinged, designed for containment and surveillance rather than workflow. The viewing angle is at eye-level looking straight down the corridor axis, giving a strong vanishing-point recession with parallel walls converging toward a sealed blast door at the far end. The corridor is approximately 3 metres wide with flush wall panels — smooth, seam-marked at regular intervals — that read as armoured or hardened rather than concrete. The ceiling is lower and more oppressive than the player bay, with recessed red-register emergency strip lighting running along the wall/ceiling joint on both sides; these cast flat lateral light that produces no warmth and creates hard edge shadows. At mid-right wall there is a flush-mounted security camera housing — a rectangular protrusion with a single indicator element, implying observation. The floor is bare and clean — no markings, no wear — suggesting the space is occupied by systems, not workers. The blast door at the terminus is shut.

**Palette behaviour:** Walls and ceiling at VOID-to-SEAM gradient (darker at edges, lighter at corridor centre); security strip lighting introduces faint HOSTILE (#C0392B) register along upper wall joints — not bright, not alarming, but present and directional; floor at VOID-register with SEAM reflection from corridor lighting.

### AI Generation Prompt

`dark institutional security corridor, narrow high-ceilinged hallway, smooth armoured wall panels with regular seam lines, recessed emergency lighting strips along upper wall joints casting faint red-register lateral light, strong single-point perspective vanishing into sealed blast door at far end, flush-mounted security camera housing on right wall, bare clean floor with no markings, no human figures, oppressive geometry, hard-edged shadows, near-black palette with dark red accent lighting, cold and institutional, cassette futurism surveillance architecture, retro sci-fi containment zone, cinematic still, 640x720 portrait orientation, dark composition suitable as background layer behind portrait overlay`

**Art Bible Anchors:**
- VOID/SEAM dominant: backgrounds must recede — near-black field with structural panel lines
- HOSTILE accent (faint): introduced as institutional emergency lighting, not as a combat indicator — danger is ambient, systemic
- §2 Mood: threat register, ambient red-amber shift, lower brightness than player panel
- §6 Environment: security block grammar — vertical, vanishing-point, sealed terminus communicates containment

### Art Direction

Not subject to the 8-colour pixel-art palette constraint. Targets the **Tactical
Skirmish — Enemy Phase** mood register (§2): threat register, ambient red-amber shift,
lower brightness than the player panel. The space should read as hostile territory —
defensive position, contested ground, an environment the defender occupies by force
rather than by plan.

**Tone guidance for the defender panel:** Structural damage, security block
architecture, improvised barriers. Warm ambient shift toward CAUTION/HOSTILE register.
Where the player background reads as controlled and forward-leaning, the enemy
background reads as entrenched and pressured. The contrast between the two panels
communicates the combat stakes without any additional UI.

**Palette relationship:** While not constrained to 8 colours, the renders should
draw their dominant values from the canonical palette for visual coherence:
- Player panel dominant: near-FIELDGREY with OPERATIVE accent traces
- Enemy panel dominant: near-VOID with HOSTILE ambient, CAUTION highlights

This is aesthetic guidance, not a hard constraint. Panels that are too vibrant or
too saturated will read as incongruous against the programmatic 8-colour overlay.

### Godot 4.6 Notes

- All notes from ASSET-017 apply equally.
- When placed at `position = Vector2(640, 0)`, this panel's right edge aligns with
  the viewport right edge at x=1280. Verify against the current `_build_ui()` panel
  geometry: attacker panel is at x=60, defender at x=710 — these are the overlay
  ColorRects, not the background. The full-width backgrounds underlie the entire
  overlay, so they cover both the 640px panel zone and the 60px margins. This is
  intentional — the margin regions will show background content but will be covered
  by the dark overlay (`_OVERLAY = Color(0.03, 0.03, 0.04, 0.92)`).

---

## Directory Structure (Post-Integration)

```
res://assets/
├── backgrounds/
│   ├── cutaway_bg_player.png
│   ├── cutaway_bg_player.png.import
│   ├── cutaway_bg_enemy.png
│   └── cutaway_bg_enemy.png.import
│
├── vfx/
│   ├── vfx_muzzle_flash_f1.png
│   ├── vfx_muzzle_flash_f1.png.import
│   ├── vfx_muzzle_flash_f2.png
│   ├── vfx_muzzle_flash_f2.png.import
│   ├── vfx_impact_flash.png
│   ├── vfx_impact_flash.png.import
│   ├── vfx_bullet.png
│   └── vfx_bullet.png.import
│
├── portraits/          # Unchanged
├── fonts/              # Unchanged
└── tiles/              # Reserved, empty
```

Both `res://assets/backgrounds/` and `res://assets/vfx/` are new subdirectories.
Create them inside the Godot editor's FileSystem dock to ensure UID registration,
not in the OS file explorer.

---

## Asset Quick-Reference Table

| Asset ID | Filename(s) | Dimensions | Format | Filter | Compress | File Size Target |
|----------|-------------|------------|--------|--------|----------|-----------------|
| ASSET-014 | `vfx_muzzle_flash_f1.png`, `vfx_muzzle_flash_f2.png` | 32×32 px each | RGBA PNG | NEAREST | Lossless | ≤ 4 KB each |
| ASSET-015 | `vfx_impact_flash.png` | 192×192 px | RGBA PNG | NEAREST | Lossless | ≤ 30 KB |
| ASSET-016 | `vfx_bullet.png` | 16×4 px | RGBA PNG | NEAREST | Lossless | ≤ 1 KB |
| ASSET-017 | `cutaway_bg_player.png` | 640×720 px | RGB PNG | LINEAR | Lossless (see note) | 300–700 KB |
| ASSET-018 | `cutaway_bg_enemy.png` | 640×720 px | RGB PNG | LINEAR | Lossless (see note) | 300–700 KB |

---

## Integration Checklist

Before marking any asset Done:

**VFX sprites (ASSET-014, 015, 016):**
- [ ] Dimensions exactly as specced
- [ ] RGBA 32-bit PNG, sRGB, no embedded ICC profile
- [ ] Hard pixel edges — no anti-aliasing, no gradients
- [ ] Palette uses only canonical 8 colors
- [ ] File size within target (metadata-free)
- [ ] Import preset "vfx-sprite" applied, `.import` file committed
- [ ] `TEXTURE_FILTER_NEAREST` set at TextureRect node level
- [ ] Loads verified in-engine at 60fps without frame stall

**Backgrounds (ASSET-017, 018):**
- [ ] Dimensions exactly 640×720 px
- [ ] RGB 24-bit PNG, sRGB, no embedded ICC profile
- [ ] File size within expected range (flag if > 1 MB)
- [ ] Import preset "cutaway-bg" applied, `.import` file committed
- [ ] `TEXTURE_FILTER_LINEAR` set at TextureRect node level
- [ ] Draw order verified — backgrounds render behind overlay and panels
- [ ] Lossless vs. lossy decision documented before preset is committed
- [ ] Mood register matches §2 direction for each side (attacker / defender)
