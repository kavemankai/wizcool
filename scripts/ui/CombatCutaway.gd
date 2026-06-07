class_name CombatCutaway
extends CanvasLayer

signal cutaway_dismissed

const _BAR_BACK := Color(0.25, 0.08, 0.08)
const _BAR_FILL := Color(0.15, 0.75, 0.25)
const _OVERLAY  := Color(0.03, 0.03, 0.04, 0.92)
const _PANEL_BG := Color(0.06, 0.06, 0.09, 1.0)
const _BAR_W    := 220.0
const _BAR_H    := 14.0

# Sprite home positions (screen space)
const _ATK_HOME := Vector2(315.0, 430.0)
const _DEF_HOME := Vector2(965.0, 430.0)

var _attacker: Unit = null
var _target: Unit = null
var _dmg: int = 0
var _result: int = -1
var _pre_tgh: int = 0
var _event_pending: bool = false
var _playing: bool = false
var _anim_tween: Tween = null

# Text UI refs
var _atk_label: Label = null
var _def_header: Label = null
var _def_tgh_label: Label = null
var _def_bar_fill: ColorRect = null
var _def_stats_label: Label = null
var _result_label: Label = null

# Sprite refs
var _atk_sprite: CutawayUnit = null
var _def_sprite: CutawayUnit = null

func _ready() -> void:
	layer = 10
	visible = false
	_build_ui()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func queue_event(a: Unit, t: Unit, dmg: int, res: int, pre_tgh: int) -> void:
	_attacker = a
	_target = t
	_dmg = dmg
	_result = res
	_pre_tgh = pre_tgh
	_event_pending = true

func has_pending() -> bool:
	return _event_pending

func clear_pending() -> void:
	_event_pending = false

func play_pending() -> void:
	if not _event_pending:
		return
	_playing = true
	visible = true
	_populate_panels()
	_setup_sprites()
	_play_attack_animation()
	await get_tree().create_timer(0.85).timeout
	if not _playing:
		return
	_update_tgh_label()
	get_tree().create_timer(2.0).timeout.connect(_finish, CONNECT_ONE_SHOT)
	await cutaway_dismissed

# ---------------------------------------------------------------------------
# Input — block all clicks while visible and dismiss on tap
# ---------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if not visible or not _playing:
		return
	get_viewport().set_input_as_handled()
	if event is InputEventMouseButton and event.pressed:
		_finish()

func _finish() -> void:
	if not _playing:
		return
	_playing = false
	if is_instance_valid(_anim_tween):
		_anim_tween.kill()
	_reset_sprite_positions()
	visible = false
	_event_pending = false
	cutaway_dismissed.emit()

# ---------------------------------------------------------------------------
# Panel population
# ---------------------------------------------------------------------------

func _populate_panels() -> void:
	if not is_instance_valid(_attacker) or not is_instance_valid(_target):
		return

	var alines: Array[String] = []
	alines.append(("[LEADER] " if _attacker.is_leader else "") + _attacker.unit_id)
	alines.append(_archetype_str(_attacker))
	alines.append("")
	alines.append("TOUGHNESS  %d / %d" % [_attacker.toughness, _attacker.max_toughness])
	alines.append("COMBAT %d   RANGE %d" % [
		_attacker.get_effective_combat_skill(), _attacker.attack_range])
	if not _attacker.gear.is_empty():
		alines.append("")
		for item: GearItem in _attacker.gear:
			alines.append("  %s [%s]" % [item.item_id, item.state_label()])
	_atk_label.text = "\n".join(alines)

	_def_header.text = (("[LEADER] " if _target.is_leader else "") + _target.unit_id
		+ "\n" + _archetype_str(_target))

	_def_tgh_label.text = "TOUGHNESS  %d / %d" % [_pre_tgh, _target.max_toughness]
	_def_bar_fill.size.x = _BAR_W * (float(_pre_tgh) / float(_target.max_toughness))

	var slines: Array[String] = []
	slines.append("COMBAT %d   RANGE %d" % [
		_target.get_effective_combat_skill(), _target.attack_range])
	if not _target.gear.is_empty():
		slines.append("")
		for item: GearItem in _target.gear:
			slines.append("  %s [%s]" % [item.item_id, item.state_label()])
	_def_stats_label.text = "\n".join(slines)

	match _result:
		Unit.DamageResult.NORMAL:
			_result_label.text = "HIT  ─%d TOUGHNESS  [ %d / %d ]" % [
				_dmg, _target.toughness, _target.max_toughness]
		Unit.DamageResult.GEAR_FRACTURED:
			_result_label.text = "GEAR FRACTURED  ─ TOUGHNESS RESET"
		Unit.DamageResult.GEAR_BROKEN:
			_result_label.text = "GEAR BROKEN  ─ TARGET DOWNED"
		Unit.DamageResult.DOWNED:
			_result_label.text = "TARGET DOWNED"

func _update_tgh_label() -> void:
	if not is_instance_valid(_target):
		return
	match _result:
		Unit.DamageResult.GEAR_FRACTURED:
			_def_tgh_label.text = "TOUGHNESS  %d / %d  [RESET]" % [
				_target.toughness, _target.max_toughness]
		Unit.DamageResult.GEAR_BROKEN, Unit.DamageResult.DOWNED:
			_def_tgh_label.text = "TOUGHNESS  0 / %d  [DOWNED]" % _target.max_toughness
		_:
			_def_tgh_label.text = "TOUGHNESS  %d / %d" % [
				_target.toughness, _target.max_toughness]

# ---------------------------------------------------------------------------
# Sprite setup & animation
# ---------------------------------------------------------------------------

func _setup_sprites() -> void:
	_reset_sprite_positions()
	if is_instance_valid(_attacker):
		_atk_sprite.setup(_attacker)
	if is_instance_valid(_target):
		_def_sprite.setup(_target)

func _reset_sprite_positions() -> void:
	if is_instance_valid(_atk_sprite):
		_atk_sprite.position = _ATK_HOME
		_atk_sprite.flash_alpha = 0.0
	if is_instance_valid(_def_sprite):
		_def_sprite.position = _DEF_HOME
		_def_sprite.flash_alpha = 0.0

func _play_attack_animation() -> void:
	if not is_instance_valid(_attacker) or not is_instance_valid(_target):
		return

	if is_instance_valid(_anim_tween):
		_anim_tween.kill()
	_anim_tween = create_tween()
	_anim_tween.set_parallel(true)

	# Attacker lunges toward defender, then retreats
	_anim_tween.tween_property(_atk_sprite, "position:x",
		_ATK_HOME.x + 105.0, 0.22).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_anim_tween.tween_property(_atk_sprite, "position:x",
		_ATK_HOME.x, 0.22).set_delay(0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)

	# Attacker flash on impact
	_anim_tween.tween_property(_atk_sprite, "flash_alpha",
		0.35, 0.06).set_delay(0.19)
	_anim_tween.tween_property(_atk_sprite, "flash_alpha",
		0.0, 0.18).set_delay(0.25)

	# Defender flash on impact
	_anim_tween.tween_property(_def_sprite, "flash_alpha",
		0.75, 0.06).set_delay(0.19)
	_anim_tween.tween_property(_def_sprite, "flash_alpha",
		0.0, 0.30).set_delay(0.25)

	# Defender recoil shake (3 oscillations)
	_anim_tween.tween_property(_def_sprite, "position:x",
		_DEF_HOME.x + 22.0, 0.06).set_delay(0.19)
	_anim_tween.tween_property(_def_sprite, "position:x",
		_DEF_HOME.x - 14.0, 0.09).set_delay(0.25)
	_anim_tween.tween_property(_def_sprite, "position:x",
		_DEF_HOME.x + 8.0,  0.09).set_delay(0.34)
	_anim_tween.tween_property(_def_sprite, "position:x",
		_DEF_HOME.x, 0.12).set_delay(0.43)

	# Health bar drain starts at impact, runs through animation
	var post_w := 0.0
	if _result == Unit.DamageResult.NORMAL and is_instance_valid(_target):
		post_w = _BAR_W * (float(_target.toughness) / float(_target.max_toughness))
	_anim_tween.tween_property(_def_bar_fill, "size:x",
		post_w, 0.55).set_delay(0.19).set_ease(Tween.EASE_OUT)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _archetype_str(unit: Unit) -> String:
	if unit.is_player:
		return "[CREW]"
	match unit.archetype:
		Unit.Archetype.GUARDIAN:  return "[GUARDIAN]"
		Unit.Archetype.RAMPAGING: return "[RAMPAGING]"
		Unit.Archetype.TACTICAL:  return "[VANGUARD]"
	return ""

# ---------------------------------------------------------------------------
# Build UI
# ---------------------------------------------------------------------------

func _build_ui() -> void:
	var root := Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(root)

	# Dark overlay
	var ovr := ColorRect.new()
	ovr.set_anchors_preset(Control.PRESET_FULL_RECT)
	ovr.color = _OVERLAY
	ovr.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(ovr)

	# Panel backgrounds (tall — cover text zone + sprite zone)
	_bg_rect(root, Vector2(60, 55), Vector2(510, 600))
	_bg_rect(root, Vector2(710, 55), Vector2(510, 600))

	# === TEXT ZONE (top ~200px of each panel) ===

	# Attacker text
	_atk_label = _make_label(root, Rect2(80, 72, 470, 185), "")

	# VS (between text areas)
	var vs := _make_label(root, Rect2(574, 145, 132, 50), "VS", HORIZONTAL_ALIGNMENT_CENTER)
	vs.add_theme_font_size_override("font_size", 24)
	vs.add_theme_color_override("font_color", Color(0.45, 0.45, 0.45))

	# Defender text
	_def_header      = _make_label(root, Rect2(730, 72, 470, 50), "")
	_def_tgh_label   = _make_label(root, Rect2(730, 130, 460, 22), "")
	var bar_y := 157.0
	_bg_rect(root, Vector2(730, bar_y), Vector2(_BAR_W, _BAR_H), _BAR_BACK)
	_def_bar_fill = ColorRect.new()
	_def_bar_fill.position = Vector2(730, bar_y)
	_def_bar_fill.size     = Vector2(_BAR_W, _BAR_H)
	_def_bar_fill.color    = _BAR_FILL
	_def_bar_fill.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_def_bar_fill)
	_def_stats_label = _make_label(root, Rect2(730, 180, 470, 85), "")

	# === DIVIDER LINE ===
	var div := ColorRect.new()
	div.position = Vector2(60, 275)
	div.size = Vector2(1160, 1)
	div.color = Color(0.18, 0.18, 0.22)
	div.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(div)

	# === SPRITE ZONE (lower portion) ===
	# Sprites are Node2D children — added here so they draw above backgrounds
	_atk_sprite = CutawayUnit.new()
	_atk_sprite.position = _ATK_HOME
	root.add_child(_atk_sprite)

	_def_sprite = CutawayUnit.new()
	_def_sprite.position = _DEF_HOME
	root.add_child(_def_sprite)

	# === RESULT BAND (bottom) ===
	_result_label = _make_label(root, Rect2(120, 590, 1040, 40),
		"", HORIZONTAL_ALIGNMENT_CENTER)
	_result_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.20))
	_result_label.add_theme_font_size_override("font_size", 17)

	var footer := _make_label(root, Rect2(120, 642, 1040, 26),
		"CLICK TO CONTINUE", HORIZONTAL_ALIGNMENT_CENTER)
	footer.add_theme_color_override("font_color", Color(0.32, 0.32, 0.32))

func _make_label(parent: Control, rect: Rect2, text: String,
		align: int = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var lbl := Label.new()
	lbl.position = rect.position
	lbl.size = rect.size
	lbl.text = text
	lbl.horizontal_alignment = align
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(lbl)
	return lbl

func _bg_rect(parent: Control, pos: Vector2, sz: Vector2,
		col: Color = _PANEL_BG) -> void:
	var r := ColorRect.new()
	r.position = pos
	r.size = sz
	r.color = col
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(r)
