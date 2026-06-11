class_name HUD
extends CanvasLayer

signal end_turn_pressed
signal field_patch_pressed
signal skip_pressed
signal ability_pressed
signal cutaway_toggled(enabled: bool)
signal debug_toggled(enabled: bool)

# Fewer, larger log lines so the combat log stays readable on a phone.
const MAX_LOG := 5

# ---------------------------------------------------------------------------
# Canonical 8-colour palette (art-bible.md §4). No new hues introduced.
# ---------------------------------------------------------------------------
const VOID := Color(0.10, 0.10, 0.12)
const SEAM := Color(0.20, 0.20, 0.22, 0.6)
const OPERATIVE := Color(0.15, 0.55, 0.45)
const HOSTILE := Color(0.55, 0.22, 0.18)
const MANDATE := Color(0.80, 0.75, 0.60)
const CAUTION := Color(0.85, 0.80, 0.20)
const FIELDGREY := Color(0.28, 0.32, 0.35)
const PARCHMENT := Color(0.85, 0.80, 0.70)

# UI-palette derivatives (art-bible.md §4 UI Palette).
const PANEL_FILL := Color(0.08, 0.08, 0.10, 0.92)
const PANEL_BORDER := Color(0.35, 0.35, 0.38, 0.90)
const BTN_FILL := Color(0.28, 0.32, 0.35, 0.85)
const BTN_FILL_HOVER := Color(0.34, 0.39, 0.43, 0.90)
const TEXT_DARK := Color(0.10, 0.06, 0.02)

# ---------------------------------------------------------------------------
# Layout constants — landscape 1280×720. The tactical grid (≈384×640) is
# centred at x≈448–832, leaving a LEFT gutter (0–448) and RIGHT gutter
# (832–1280) for UI. Interactive controls live ONLY in the gutters and the
# bottom thumb band so taps never fall on a grid tile.
# ---------------------------------------------------------------------------
const SCREEN_W := 1280.0
const SCREEN_H := 720.0
const MARGIN := 12.0

# Primary action buttons — bottom-RIGHT thumb cluster.
const ACT_BTN_W := 220.0
const ACT_BTN_H := 80.0
const ACT_BTN_GAP := 10.0
const ACT_COL_X := SCREEN_W - MARGIN - ACT_BTN_W   # 1048
# Stack upward from the bottom edge so the dominant thumb rests on END TURN.
const ROW_END_TURN := SCREEN_H - MARGIN - ACT_BTN_H                       # 628
const ROW_FIELD_PATCH := ROW_END_TURN - (ACT_BTN_H + ACT_BTN_GAP)         # 538
const ROW_SKIP := ROW_FIELD_PATCH - (ACT_BTN_H + ACT_BTN_GAP)            # 448
const ROW_ABILITY := ROW_SKIP - (ACT_BTN_H + ACT_BTN_GAP)                # 358

# Secondary settings buttons — small, top-RIGHT corner, out of thumb zones.
const SET_BTN_W := 150.0
const SET_BTN_H := 40.0

# Font sizes (phone-legible).
const FS_TITLE := 22
const FS_PHASE := 26
const FS_ROUND := 18
const FS_UNIT := 18
const FS_LOG := 18
const FS_BTN := 24
const FS_SET := 16
const FS_INDICATOR := 20

var _mission_label: Label
var _phase_label: Label
var _round_label: Label
var _unit_label: Label
var _log_label: Label
var _end_turn_btn: Button
var _field_patch_btn: Button
var _skip_btn: Button
var _ability_btn: Button
var _cutaway_btn: Button
var _debug_btn: Button
var _cutaway_on: bool = true
var _debug_on: bool = false
var _precision_label: Label
var _aoe_label: Label
var _preview_label: Label
var _show_precision_preview: bool = false

# Player crew portraits, keyed by unit_id (ALPHA/BRAVO/CHARLIE). Empty for enemies.
var _unit_portrait: TextureRect
var _portraits: Dictionary = {}

var _log_lines: Array[String] = []

func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	# --- Top-left: mission title --------------------------------------------
	_mission_label = _label(root, Rect2(MARGIN, MARGIN, 420, 28), "CONTAINMENT BREACH",
			HORIZONTAL_ALIGNMENT_LEFT)
	_mission_label.add_theme_font_size_override("font_size", FS_TITLE)
	_mission_label.add_theme_color_override("font_color", MANDATE)

	# --- Top-centre: phase + round (above the grid, y≈6–46) -----------------
	_phase_label = _label(root, Rect2(SCREEN_W * 0.5 - 160, 4, 320, 30), "PLAYER TURN",
			HORIZONTAL_ALIGNMENT_CENTER)
	_phase_label.add_theme_font_size_override("font_size", FS_PHASE)
	_phase_label.add_theme_color_override("font_color", PARCHMENT)
	_round_label = _label(root, Rect2(SCREEN_W * 0.5 - 160, 36, 320, 22), "ROUND 1 / 20",
			HORIZONTAL_ALIGNMENT_CENTER)
	_round_label.add_theme_font_size_override("font_size", FS_ROUND)
	_round_label.add_theme_color_override("font_color", PARCHMENT * Color(1, 1, 1, 0.6))

	# --- Right gutter, top: unit inspect panel ------------------------------
	# Sits above the primary action cluster (which starts at y≈358).
	var inspect_rect := Rect2(SCREEN_W - MARGIN - 240, 96, 240, 250)
	var inspect_panel := _panel(root, inspect_rect)
	# Crew portrait — top-centre of the panel, shown only for player units that
	# have one. Linear filter: downscaled pixel-art illustrations read fine soft.
	_unit_portrait = TextureRect.new()
	_unit_portrait.set_position(Vector2(78, 6))
	_unit_portrait.set_size(Vector2(84, 84))
	_unit_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_unit_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	_unit_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_unit_portrait.visible = false
	inspect_panel.add_child(_unit_portrait)
	_unit_label = _label(inspect_panel, Rect2(10, 8, inspect_rect.size.x - 20,
			inspect_rect.size.y - 16), "")
	_unit_label.add_theme_font_size_override("font_size", FS_UNIT)
	_unit_label.add_theme_color_override("font_color", PARCHMENT)

	# Preload portraits if imported. Player crew + named Vanguard rival crew key
	# by exact unit_id; SENTINEL/PRISONER are archetype types so any unit whose
	# id starts with that name resolves to the shared face (see _portrait_key).
	var portrait_paths := {
		"ALPHA": "res://assets/portraits/portrait_player_alpha.png",
		"BRAVO": "res://assets/portraits/portrait_player_bravo.png",
		"CHARLIE": "res://assets/portraits/portrait_player_charlie.png",
		"VANGUARD-1": "res://assets/portraits/portrait_enemy_vanguard_leader.png",
		"VANGUARD-2": "res://assets/portraits/portrait_enemy_vanguard_soldier.png",
		"VANGUARD-3": "res://assets/portraits/portrait_enemy_vanguard_tech.png",
		"SENTINEL": "res://assets/portraits/portrait_enemy_sentinel.png",
		"PRISONER": "res://assets/portraits/portrait_enemy_prisoner.png",
	}
	for pid: String in portrait_paths:
		var ppath: String = portrait_paths[pid]
		if ResourceLoader.exists(ppath):
			_portraits[pid] = load(ppath)

	# --- Bottom-left: combat log --------------------------------------------
	var log_rect := Rect2(MARGIN, SCREEN_H - MARGIN - 168, 420, 168)
	var log_panel := _panel(root, log_rect)
	_log_label = _label(log_panel, Rect2(10, 8, log_rect.size.x - 20, log_rect.size.y - 16), "")
	_log_label.add_theme_font_size_override("font_size", FS_LOG)
	_log_label.add_theme_color_override("font_color", PARCHMENT)

	# --- Indicators: precision + AoE, just above the log --------------------
	_precision_label = _label(root, Rect2(MARGIN, log_rect.position.y - 28, 420, 24),
			"◆ PRECISION STRIKE")
	_precision_label.add_theme_font_size_override("font_size", FS_INDICATOR)
	_precision_label.add_theme_color_override("font_color", CAUTION)
	_precision_label.visible = false

	_aoe_label = _label(root, Rect2(MARGIN, log_rect.position.y - 54, 420, 24), "")
	_aoe_label.add_theme_font_size_override("font_size", FS_INDICATOR)
	_aoe_label.add_theme_color_override("font_color", HOSTILE)
	_aoe_label.visible = false

	# Attack preview — graze-tier prediction line, top-centre under the round
	# counter. Shown on the first tap of the two-tap attack confirm.
	_preview_label = _label(root, Rect2(SCREEN_W * 0.5 - 320, 62, 640, 26), "",
			HORIZONTAL_ALIGNMENT_CENTER)
	_preview_label.add_theme_font_size_override("font_size", FS_INDICATOR)
	_preview_label.add_theme_color_override("font_color", CAUTION)
	_preview_label.visible = false

	# --- Bottom-right thumb cluster: primary tactical actions ---------------
	# Stacked bottom-up: END TURN (anchor), FIELD PATCH, SKIP, USE ABILITY.
	_end_turn_btn = _action_button(root, Rect2(ACT_COL_X, ROW_END_TURN, ACT_BTN_W, ACT_BTN_H),
			"END TURN", OPERATIVE)
	_end_turn_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		end_turn_pressed.emit())

	_field_patch_btn = _action_button(root, Rect2(ACT_COL_X, ROW_FIELD_PATCH, ACT_BTN_W, ACT_BTN_H),
			"FIELD PATCH", OPERATIVE)
	_field_patch_btn.visible = false
	_field_patch_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		field_patch_pressed.emit())

	_skip_btn = _action_button(root, Rect2(ACT_COL_X, ROW_SKIP, ACT_BTN_W, ACT_BTN_H),
			"SKIP ENEMY PHASE", CAUTION)
	_skip_btn.visible = false
	_skip_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		skip_pressed.emit())

	# USE ABILITY — the primary tactical action. CAUTION-yellow filled so it
	# reads as the dominant button. Shown only when the selected unit has a
	# ready weapon special. Occupies its own row above SKIP (distinct rect).
	_ability_btn = Button.new()
	_ability_btn.set_position(Vector2(ACT_COL_X, ROW_ABILITY))
	_ability_btn.set_size(Vector2(ACT_BTN_W, ACT_BTN_H))
	_ability_btn.text = "USE ABILITY"
	_ability_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_ability_btn.visible = false
	_ability_btn.add_theme_font_size_override("font_size", FS_BTN)
	_ability_btn.add_theme_color_override("font_color", TEXT_DARK)
	_ability_btn.add_theme_color_override("font_hover_color", TEXT_DARK)
	_ability_btn.add_theme_color_override("font_pressed_color", TEXT_DARK)
	var ability_style := StyleBoxFlat.new()
	ability_style.bg_color = CAUTION
	ability_style.set_corner_radius_all(4)
	_ability_btn.add_theme_stylebox_override("normal", ability_style)
	_ability_btn.add_theme_stylebox_override("hover", ability_style)
	_ability_btn.add_theme_stylebox_override("pressed", ability_style)
	_ability_btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		ability_pressed.emit())
	root.add_child(_ability_btn)

	# --- Top-right corner: secondary settings (small, out of thumb zone) ----
	# CUTAWAY and DEBUG are settings, not per-turn actions, so they sit small
	# in the corner and never compete with END TURN / USE ABILITY.
	var set_x := SCREEN_W - MARGIN - SET_BTN_W
	_cutaway_btn = _settings_button(root, Rect2(set_x, MARGIN, SET_BTN_W, SET_BTN_H),
			"CUTAWAY: ON")
	_cutaway_btn.pressed.connect(_on_cutaway_btn_pressed)

	_debug_btn = _settings_button(root,
			Rect2(set_x, MARGIN + SET_BTN_H + 8, SET_BTN_W, SET_BTN_H), "DEBUG: OFF")
	_debug_btn.visible = GameState.DEBUG_MODE
	_debug_btn.pressed.connect(_on_debug_btn_pressed)

# ---------------------------------------------------------------------------
# Construction helpers
# ---------------------------------------------------------------------------

func _label(parent: Control, rect: Rect2, text: String,
		align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var lbl := Label.new()
	lbl.set_position(rect.position)
	lbl.set_size(rect.size)
	lbl.text = text
	lbl.horizontal_alignment = align
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(lbl)
	return lbl

## A schematic panel — a "hole" one step deeper than VOID with a SEAM border.
func _panel(parent: Control, rect: Rect2) -> Panel:
	var panel := Panel.new()
	panel.set_position(rect.position)
	panel.set_size(rect.size)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var style := StyleBoxFlat.new()
	style.bg_color = PANEL_FILL
	style.border_color = PANEL_BORDER
	style.set_border_width_all(1)
	style.set_corner_radius_all(0)  # hard-edge industrial aesthetic
	panel.add_theme_stylebox_override("panel", style)
	parent.add_child(panel)
	return panel

## A large primary action button with a coloured stroke on FIELDGREY fill.
func _action_button(parent: Control, rect: Rect2, text: String,
		accent: Color) -> Button:
	var btn := Button.new()
	btn.set_position(rect.position)
	btn.set_size(rect.size)
	btn.text = text
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.add_theme_font_size_override("font_size", FS_BTN)
	btn.add_theme_color_override("font_color", PARCHMENT)
	btn.add_theme_color_override("font_hover_color", PARCHMENT)
	btn.add_theme_color_override("font_pressed_color", PARCHMENT)
	var normal := StyleBoxFlat.new()
	normal.bg_color = BTN_FILL
	normal.border_color = accent
	normal.set_border_width_all(2)
	normal.set_corner_radius_all(4)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = BTN_FILL_HOVER
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	parent.add_child(btn)
	return btn

## A small secondary settings button — muted, no accent stroke.
func _settings_button(parent: Control, rect: Rect2, text: String) -> Button:
	var btn := Button.new()
	btn.set_position(rect.position)
	btn.set_size(rect.size)
	btn.text = text
	btn.mouse_filter = Control.MOUSE_FILTER_STOP
	btn.add_theme_font_size_override("font_size", FS_SET)
	btn.add_theme_color_override("font_color", PARCHMENT * Color(1, 1, 1, 0.7))
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.08, 0.08, 0.10, 0.85)
	normal.border_color = SEAM
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(2)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", normal)
	btn.add_theme_stylebox_override("pressed", normal)
	parent.add_child(btn)
	return btn

# ---------------------------------------------------------------------------
# Public API (signatures preserved — Main.gd depends on these)
# ---------------------------------------------------------------------------

func set_phase(player_turn: bool) -> void:
	_phase_label.text = "PLAYER TURN" if player_turn else "ENEMY TURN"
	_phase_label.add_theme_color_override("font_color",
			PARCHMENT if player_turn else HOSTILE)

func set_round(n: int) -> void:
	_round_label.text = "ROUND %d / 20" % n

func set_field_patch_visible(show_btn: bool) -> void:
	_field_patch_btn.visible = show_btn

func set_skip_visible(show_btn: bool) -> void:
	_skip_btn.visible = show_btn

## Resolve a unit_id to a loaded portrait key, or "" if none.
## Exact match for named crew; prefix match for archetype types (SENTINEL-1,
## PRISONER-2, … all share one face).
func _portrait_key(unit_id: String) -> String:
	if _portraits.has(unit_id):
		return unit_id
	if unit_id.begins_with("SENTINEL") and _portraits.has("SENTINEL"):
		return "SENTINEL"
	if unit_id.begins_with("PRISONER") and _portraits.has("PRISONER"):
		return "PRISONER"
	return ""

## Show/hide the USE ABILITY button and set its label to the ability name.
func set_ability_visible(show_btn: bool, label: String = "") -> void:
	_ability_btn.visible = show_btn
	if show_btn and label != "":
		_ability_btn.text = label

func _on_cutaway_btn_pressed() -> void:
	_cutaway_on = not _cutaway_on
	_cutaway_btn.text = "CUTAWAY: ON" if _cutaway_on else "CUTAWAY: OFF"
	cutaway_toggled.emit(_cutaway_on)

func _on_debug_btn_pressed() -> void:
	_debug_on = not _debug_on
	_debug_btn.text = "DEBUG: ON" if _debug_on else "DEBUG: OFF"
	debug_toggled.emit(_debug_on)

func show_unit(unit: Unit) -> void:
	if unit == null:
		_unit_label.text = ""
		_unit_portrait.visible = false
		_unit_label.position = Vector2(10, 8)
		_unit_label.size = Vector2(220, 234)
		return
	# Portrait: show it and drop the stat text below; otherwise full panel.
	var pkey := _portrait_key(unit.unit_id)
	if pkey != "":
		_unit_portrait.texture = _portraits[pkey]
		_unit_portrait.visible = true
		_unit_label.position = Vector2(10, 96)
		_unit_label.size = Vector2(220, 146)
		_unit_label.add_theme_font_size_override("font_size", 15)
	else:
		_unit_portrait.visible = false
		_unit_label.position = Vector2(10, 8)
		_unit_label.size = Vector2(220, 234)
		_unit_label.add_theme_font_size_override("font_size", FS_UNIT)
	var lines: Array[String] = []
	lines.append(("[LEADER] " if unit.is_leader else "") + unit.unit_id)
	lines.append("TOUGHNESS  %d / %d" % [unit.toughness, unit.max_toughness])
	lines.append("COMBAT %d   SPEED %d   RANGE %d" % [
		unit.get_effective_combat_skill(),
		unit.get_effective_speed(),
		unit.attack_range,
	])
	var acts: Array[String] = []
	if unit.has_moved:    acts.append("MOVED")
	if unit.has_attacked: acts.append("ATTACKED")
	if acts.size() > 0:
		lines.append("[" + "  /  ".join(acts) + "]")
	for item: GearItem in unit.gear:
		lines.append("  %s [%s]" % [item.item_id, item.state_label()])
	if unit.status_effects != null:
		for effect in unit.status_effects.get_all():
			lines.append("  [STATUS] " + effect.get_label())
	for item: GearItem in unit.gear:
		if item.special != null:
			lines.append("  [SPECIAL] " + item.special.get_label() + "  " + item.special.get_cooldown_label())
	if unit.cover_type != CoverSystem.CoverType.NONE:
		var cover_name: String = "LIGHT" if unit.cover_type == CoverSystem.CoverType.LIGHT else "HEAVY"
		lines.append("  [COVER] " + cover_name + "  INTEGRITY: " + str(unit.cover_integrity))
	_unit_label.text = "\n".join(lines)

## Shows or hides the PRECISION STRIKE indicator near the log area.
func set_precision_indicator(visible: bool) -> void:
	_precision_label.visible = visible

## Shows the graze-tier attack prediction line (empty string hides it).
func set_attack_preview(text: String) -> void:
	_preview_label.text = text
	_preview_label.visible = text != ""

## Shows or hides the AoE target preview near the log area.
func set_aoe_preview(active: bool, origin_str: String = "") -> void:
	_aoe_label.text = "AoE → " + origin_str if active else ""
	_aoe_label.visible = active

func log(msg: String) -> void:
	_log_lines.append(msg)
	if _log_lines.size() > MAX_LOG:
		_log_lines = _log_lines.slice(_log_lines.size() - MAX_LOG)
	_log_label.text = "\n".join(_log_lines)
