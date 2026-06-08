# Asset Specs — Fonts

> **Source**: design/art/art-bible.md §7, §8
> **Art Bible**: design/art/art-bible.md
> **Generated**: 2026-06-08
> **Status**: 2 assets specced / 2 approved / 0 in production / 0 done

JetBrains Mono is the sole typeface for the entire project. Two weights. SIL Open Font License (OFL) — free for commercial use, no attribution required in-game.

---

## Download

**Official source:** https://github.com/JetBrains/JetBrainsMono/releases

Download the latest stable release `.zip`. Inside, the relevant files are:
- `fonts/ttf/JetBrainsMono-Regular.ttf` → rename to `jetbrains_mono_400.ttf`
- `fonts/ttf/JetBrainsMono-Bold.ttf` → rename to `jetbrains_mono_700.ttf`

The variable font (`.woff2` / `JetBrainsMono[wght].ttf`) is not needed. Use the static weight TTF files only.

**Rename rule:** Rename files before importing into Godot. Once the `.import` sidecar is created, rename only inside the Godot editor FileSystem dock.

---

## Godot Font Pipeline

In Godot 4.x, TTF files are imported as `FontFile` resources. The workflow is:

1. Drop the TTF file into `res://assets/fonts/`
2. Godot auto-creates a `.import` sidecar — configure import settings (see below)
3. Create a `FontFile` `.tres` resource per weight, pointing to the imported TTF
4. Reference the `.tres` resource in any Control node that needs the font

The `.tres` FontFile resource is what GDScript loads — not the `.ttf` directly.

---

## Shared: Font Import Settings

Both font files use the same Godot import settings. Create a named preset **"monospace-ui-font"** and apply to both.

```ini
[importer = "font_data_dynamic"]
antialiasing = 0
generate_mipmaps = false
multichannel_signed_distance_field = false
msdf_pixel_range = 8
msdf_size = 48
allow_system_fonts_fallback = true
force_autohinter = false
hinting = 0
subpixel_positioning = 1
keep_rounding_remainders = true
oversampling = 0.0
fixed_size = 0
compress = true
preload = []
language_support = {}
script_support = {}
opentype_features = {}
```

⚠️ **Godot 4.6 HIGH RISK — verify enum values before committing:**

| Setting | Value written | Intended meaning | Risk |
|---------|--------------|-----------------|------|
| `antialiasing` | `0` | None (crisp pixel edges) | MEDIUM — enum may have shifted in 4.4–4.6. Verify in Import dock: should show "None". |
| `hinting` | `0` | None | MEDIUM — verify shows "None" not "Light". |
| `subpixel_positioning` | `1` | Disabled | HIGH — this enum changed in 4.5. Value `1` was "Disabled" in 4.3; may be "Auto" in 4.5+. Verify the Import dock shows "Disabled". |

**Verification step:** After importing the first font file, open the `.import` sidecar in a text editor and compare the values against the Godot 4.6 Import dock display. If any value shows "Auto" or "Grayscale" when it should show "None" / "Disabled", correct the integer value and re-import.

**Why these settings:** This is a monospace terminal UI font at small sizes (8–16px). Antialiasing and subpixel rendering at small sizes produce blurring that conflicts with the game's hard-edge schematic aesthetic. Crisp pixel rendering is the correct choice — it matches the programmatic draw call style of the rest of the UI.

---

## ASSET-019 — jetbrains_mono_400.ttf

| Field | Value |
|---|---|
| Category | Font |
| Format | TrueType Font (.ttf) |
| Weight | Regular (400) |
| Source filename | `JetBrainsMono-Regular.ttf` |
| Delivery filename | `jetbrains_mono_400.ttf` |
| Resource path | `res://assets/fonts/jetbrains_mono_400.ttf` |
| FontFile resource | `res://assets/fonts/font_regular.tres` |
| License | SIL Open Font License 1.1 |
| Import preset | monospace-ui-font (see above) |

**Usage (§7):** Labels, log body text, secondary text. All text that is NOT a primary numeric value, stat number, or unit callsign.

**Size usage in UI (from art bible §7, §8):**
- 8px: dense log entries, secondary labels
- 10px: standard log text, stat labels
- 12px: primary UI labels, button text
- 16px: callsigns, mission status

**GDScript loading:**
```gdscript
var font_regular: FontFile = load("res://assets/fonts/font_regular.tres")
label.add_theme_font_override("font", font_regular)
label.add_theme_font_size_override("font_size", 12)
```

**Status:** Needed

---

## ASSET-020 — jetbrains_mono_700.ttf

| Field | Value |
|---|---|
| Category | Font |
| Format | TrueType Font (.ttf) |
| Weight | Bold (700) |
| Source filename | `JetBrainsMono-Bold.ttf` |
| Delivery filename | `jetbrains_mono_700.ttf` |
| Resource path | `res://assets/fonts/jetbrains_mono_700.ttf` |
| FontFile resource | `res://assets/fonts/font_bold.tres` |
| License | SIL Open Font License 1.1 |
| Import preset | monospace-ui-font (see above) |

**Usage (§7):** Primary numeric values, stat numbers, unit callsigns. Anything that needs to read as data-critical at a glance.

**GDScript loading:**
```gdscript
var font_bold: FontFile = load("res://assets/fonts/font_bold.tres")
label.add_theme_font_override("font", font_bold)
label.add_theme_font_size_override("font_size", 16)
```

**Status:** Needed

---

## Directory Structure

```
res://assets/fonts/
├── jetbrains_mono_400.ttf
├── jetbrains_mono_400.ttf.import
├── jetbrains_mono_700.ttf
├── jetbrains_mono_700.ttf.import
├── font_regular.tres        ← FontFile resource, weight 400
└── font_bold.tres           ← FontFile resource, weight 700
```

Create `res://assets/fonts/` inside the Godot editor FileSystem dock before importing files.

---

## Verification Checklist

- [ ] Import dock shows `antialiasing = None` (not Grayscale or LCD)
- [ ] Import dock shows `hinting = None`
- [ ] Import dock shows `subpixel_positioning = Disabled`
- [ ] Font renders crisply at 8px in a test label node — no blurring
- [ ] `font_regular.tres` and `font_bold.tres` FontFile resources created and pointing to imported TTFs
- [ ] Both `.import` sidecar files committed to version control alongside the TTFs
- [ ] License file (`OFL.txt` from the JetBrains Mono zip) included in `res://assets/fonts/` or project legal folder
