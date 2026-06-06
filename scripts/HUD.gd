class_name HUD
extends CanvasLayer

signal end_turn_pressed
signal field_patch_pressed

const MAX_LOG := 8

var _mission_label: Label
var _phase_label: Label
var _round_label: Label
var _unit_label: Label
var _log_label: Label
var _end_turn_btn: Button
var _field_patch_btn: Button

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
	_unit_label.text = "\n".join(lines)

func log(msg: String) -> void:
	_log_lines.append(msg)
	if _log_lines.size() > MAX_LOG:
		_log_lines = _log_lines.slice(_log_lines.size() - MAX_LOG)
	_log_label.text = "\n".join(_log_lines)
