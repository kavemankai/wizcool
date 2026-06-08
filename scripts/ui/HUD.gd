class_name HUD
extends CanvasLayer

signal end_turn_pressed
signal field_patch_pressed
signal skip_pressed
signal cutaway_toggled(enabled: bool)
signal debug_toggled(enabled: bool)

const MAX_LOG := 8

var _mission_label: Label
var _phase_label: Label
var _round_label: Label
var _unit_label: Label
var _log_label: Label
var _end_turn_btn: Button
var _field_patch_btn: Button
var _skip_btn: Button
var _cutaway_btn: Button
var _debug_btn: Button
var _cutaway_on: bool = true
var _debug_on: bool = false
var _precision_label: Label
var _aoe_label: Label
var _show_precision_preview: bool = false

var _log_lines: Array[String] = []

func _ready() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	_mission_label = _label(root, Rect2(6, 6, 340, 20), "CONTAINMENT BREACH",
			HORIZONTAL_ALIGNMENT_LEFT)

	_phase_label = _label(root, Rect2(530, 6, 220, 20), "PLAYER TURN",
			HORIZONTAL_ALIGNMENT_CENTER)
	_round_label = _label(root, Rect2(530, 26, 220, 18), "ROUND 1 / 20",
			HORIZONTAL_ALIGNMENT_CENTER)

	_unit_label = _label(root, Rect2(908, 6, 364, 200), "")

	_log_label = _label(root, Rect2(6, 592, 434, 122), "")

	_precision_label = _label(root, Rect2(908, 210, 364, 20), "◆ PRECISION STRIKE")
	_precision_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.2))
	_precision_label.visible = false

	_aoe_label = _label(root, Rect2(6, 570, 434, 20), "")
	_aoe_label.add_theme_color_override("font_color", Color(1.0, 0.55, 0.15))
	_aoe_label.visible = false

	_end_turn_btn = Button.new()
	_end_turn_btn.set_position(Vector2(1108, 656))
	_end_turn_btn.set_size(Vector2(164, 38))
	_end_turn_btn.text = "END TURN"
	_end_turn_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_end_turn_btn.pressed.connect(func() -> void: end_turn_pressed.emit())
	root.add_child(_end_turn_btn)

	_field_patch_btn = Button.new()
	_field_patch_btn.set_position(Vector2(1108, 608))
	_field_patch_btn.set_size(Vector2(164, 38))
	_field_patch_btn.text = "FIELD PATCH"
	_field_patch_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_field_patch_btn.visible = false
	_field_patch_btn.pressed.connect(func() -> void: field_patch_pressed.emit())
	root.add_child(_field_patch_btn)

	_skip_btn = Button.new()
	_skip_btn.set_position(Vector2(1108, 560))
	_skip_btn.set_size(Vector2(164, 38))
	_skip_btn.text = "SKIP ENEMY PHASE"
	_skip_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_skip_btn.visible = false
	_skip_btn.pressed.connect(func() -> void: skip_pressed.emit())
	root.add_child(_skip_btn)

	_cutaway_btn = Button.new()
	_cutaway_btn.set_position(Vector2(1108, 512))
	_cutaway_btn.set_size(Vector2(164, 38))
	_cutaway_btn.text = "CUTAWAY: ON"
	_cutaway_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_cutaway_btn.pressed.connect(_on_cutaway_btn_pressed)
	root.add_child(_cutaway_btn)

	_debug_btn = Button.new()
	_debug_btn.set_position(Vector2(1108, 656))
	_debug_btn.set_size(Vector2(164, 38))
	_debug_btn.text = "DEBUG: OFF"
	_debug_btn.mouse_filter = Control.MOUSE_FILTER_STOP
	_debug_btn.pressed.connect(_on_debug_btn_pressed)
	root.add_child(_debug_btn)

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

func set_phase(player_turn: bool) -> void:
	_phase_label.text = "PLAYER TURN" if player_turn else "ENEMY TURN"

func set_round(n: int) -> void:
	_round_label.text = "ROUND %d / 20" % n

func set_field_patch_visible(show_btn: bool) -> void:
	_field_patch_btn.visible = show_btn

func set_skip_visible(show_btn: bool) -> void:
	_skip_btn.visible = show_btn

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
		return
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

## Shows or hides the PRECISION STRIKE indicator below the unit panel.
func set_precision_indicator(visible: bool) -> void:
	_precision_label.visible = visible

## Shows or hides the AoE target preview near the log area.
func set_aoe_preview(active: bool, origin_str: String = "") -> void:
	_aoe_label.text = "AoE → " + origin_str if active else ""
	_aoe_label.visible = active

func log(msg: String) -> void:
	_log_lines.append(msg)
	if _log_lines.size() > MAX_LOG:
		_log_lines = _log_lines.slice(_log_lines.size() - MAX_LOG)
	_log_label.text = "\n".join(_log_lines)
