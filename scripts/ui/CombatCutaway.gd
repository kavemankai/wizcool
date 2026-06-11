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
var _tier: int = GrazeSystem.Tier.CLEAN
var _event_pending: bool = false
var _playing: bool = false
var _anim_tween: Tween = null
var _fade_tween: Tween = null

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
var _bullet: ColorRect = null

# Root control (faded for in/out transitions)
var _root: Control = null

# Gear consequence badge
var _gear_badge: ColorRect = null
var _gear_badge_label: Label = null

func _ready() -> void:
	layer = 10
	visible = false
	_build_ui()

# ---------------------------------------------------------------------------
# Public API
# ---------------------------------------------------------------------------

func queue_event(a: Unit, t: Unit, dmg: int, res: int, pre_tgh: int,
		tier: int = GrazeSystem.Tier.CLEAN) -> void:
	_attacker = a
	_target = t
	_dmg = dmg
	_result = res
	_pre_tgh = pre_tgh
	_tier = tier
	_event_pending = true

func has_pending() -> bool:
	return _event_pending

func clear_pending() -> void:
	_event_pending = false

func play_pending() -> void:
	if not _event_pending:
		return
	_playing = true
	_root.modulate.a = 0.0
	visible = true
	_populate_panels()
	_setup_sprites()
	if is_instance_valid(_fade_tween):
		_fade_tween.kill()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_root, "modulate:a", 1.0, 0.15)
	await _fade_tween.finished
	if not _playing:
		return
	_play_attack_animation()
	await get_tree().create_timer(0.85, false).timeout
	if not _playing:
		return
	_update_tgh_label()
	get_tree().create_timer(2.0, false).timeout.connect(_finish, CONNECT_ONE_SHOT)
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
	AudioManager.play_sfx("cutaway_dismiss")
	if is_instance_valid(_anim_tween):
		_anim_tween.kill()
	if is_instance_valid(_fade_tween):
		_fade_tween.kill()
	_reset_sprite_positions()
	_fade_tween = create_tween()
	_fade_tween.tween_property(_root, "modulate:a", 0.0, 0.20)
	await _fade_tween.finished
	visible = false
	_root.modulate.a = 1.0
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
			_result_label.text = "%s  ─%d TOUGHNESS  [ %d / %d ]" % [
				GrazeSystem.tier_label(_tier), _dmg,
				_target.toughness, _target.max_toughness]
		Unit.DamageResult.GEAR_FRACTURED:
			_result_label.text = "GEAR FRACTURED  ─ TOUGHNESS RESET"
		Unit.DamageResult.GEAR_BROKEN:
			_result_label.text = "GEAR BROKEN  ─ TARGET DOWNED"
		Unit.DamageResult.DOWNED:
			_result_label.text = "TARGET DOWNED"

	# Hide result label — revealed with slam animation in _update_tgh_label
	_result_label.modulate.a = 0.0
	_result_label.scale = Vector2(1.35, 1.35)
	_gear_badge.visible = false
	_gear_badge_label.visible = false

func _update_tgh_label() -> void:
	if not is_instance_valid(_target):
		return
	AudioManager.play_result(_result)
	match _result:
		Unit.DamageResult.GEAR_FRACTURED:
			_def_tgh_label.text = "TOUGHNESS  %d / %d  [RESET]" % [
				_target.toughness, _target.max_toughness]
		Unit.DamageResult.GEAR_BROKEN, Unit.DamageResult.DOWNED:
			_def_tgh_label.text = "TOUGHNESS  0 / %d  [DOWNED]" % _target.max_toughness
		_:
			_def_tgh_label.text = "TOUGHNESS  %d / %d" % [
				_target.toughness, _target.max_toughness]

	# Gear consequence badge
	if _result == Unit.DamageResult.GEAR_FRACTURED or _result == Unit.DamageResult.GEAR_BROKEN:
		var is_fractured := _result == Unit.DamageResult.GEAR_FRACTURED
		_gear_badge.color = Color(0.60, 0.28, 0.04) if is_fractured else Color(0.22, 0.05, 0.05)
		_gear_badge_label.text = "  GEAR FRACTURED" if is_fractured else "  GEAR BROKEN — DOWNED"
		var fc := Color(1.0, 0.75, 0.35) if is_fractured else Color(1.0, 0.38, 0.28)
		_gear_badge_label.add_theme_color_override("font_color", fc)
		_gear_badge.modulate.a = 0.0
		_gear_badge_label.modulate.a = 0.0
		_gear_badge.visible = true
		_gear_badge_label.visible = true
		var bt := create_tween().set_parallel(true)
		bt.tween_property(_gear_badge, "modulate:a", 1.0, 0.18)
		bt.tween_property(_gear_badge_label, "modulate:a", 1.0, 0.18)

	# Result label slam in
	var rt := create_tween().set_parallel(true)
	rt.tween_property(_result_label, "scale", Vector2.ONE, 0.18) \
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	rt.tween_property(_result_label, "modulate:a", 1.0, 0.14)

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
	if is_instance_valid(_bullet):
		_bullet.visible = false

func _play_attack_animation() -> void:
	if not is_instance_valid(_attacker) or not is_instance_valid(_target):
		return
	AudioManager.play_weapon(_attacker)

	if is_instance_valid(_anim_tween):
		_anim_tween.kill()
	_anim_tween = create_tween()
	_anim_tween.set_parallel(true)

	var post_w := 0.0
	if _result == Unit.DamageResult.NORMAL and is_instance_valid(_target):
		post_w = _BAR_W * (float(_target.toughness) / float(_target.max_toughness))

	if _is_ranged_attack():
		# --- RANGED: bullet projectile ---
		_bullet.position = Vector2(_ATK_HOME.x + 65.0, _ATK_HOME.y - 3.0)
		_bullet.visible = true

		# Attacker muzzle flash
		_anim_tween.tween_property(_atk_sprite, "flash_alpha", 0.40, 0.07)
		_anim_tween.tween_property(_atk_sprite, "flash_alpha", 0.0, 0.14).set_delay(0.07)

		# Bullet travels to defender (x only — they share the same y)
		_anim_tween.tween_property(_bullet, "position:x",
			_DEF_HOME.x - 65.0, 0.25).set_delay(0.05) \
			.set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		_anim_tween.tween_callback(func() -> void: _bullet.visible = false).set_delay(0.30)

		# Impact at t=0.30
		_anim_tween.tween_property(_def_sprite, "flash_alpha", 0.75, 0.06).set_delay(0.30)
		_anim_tween.tween_property(_def_sprite, "flash_alpha", 0.0,  0.30).set_delay(0.36)
		_anim_tween.tween_property(_def_sprite, "position:x", _DEF_HOME.x + 22.0, 0.06).set_delay(0.30)
		_anim_tween.tween_property(_def_sprite, "position:x", _DEF_HOME.x - 14.0, 0.09).set_delay(0.36)
		_anim_tween.tween_property(_def_sprite, "position:x", _DEF_HOME.x + 8.0,  0.09).set_delay(0.45)
		_anim_tween.tween_property(_def_sprite, "position:x", _DEF_HOME.x, 0.12).set_delay(0.54)
		_anim_tween.tween_property(_def_bar_fill, "size:x",
			post_w, 0.45).set_delay(0.30).set_ease(Tween.EASE_OUT)
	else:
		# --- MELEE: attacker lunges ---
		_anim_tween.tween_property(_atk_sprite, "position:x",
			_ATK_HOME.x + 105.0, 0.22).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
		_anim_tween.tween_property(_atk_sprite, "position:x",
			_ATK_HOME.x, 0.22).set_delay(0.22).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		_anim_tween.tween_property(_atk_sprite, "flash_alpha", 0.35, 0.06).set_delay(0.19)
		_anim_tween.tween_property(_atk_sprite, "flash_alpha", 0.0,  0.18).set_delay(0.25)
		_anim_tween.tween_property(_def_sprite, "flash_alpha", 0.75, 0.06).set_delay(0.19)
		_anim_tween.tween_property(_def_sprite, "flash_alpha", 0.0,  0.30).set_delay(0.25)
		_anim_tween.tween_property(_def_sprite, "position:x", _DEF_HOME.x + 22.0, 0.06).set_delay(0.19)
		_anim_tween.tween_property(_def_sprite, "position:x", _DEF_HOME.x - 14.0, 0.09).set_delay(0.25)
		_anim_tween.tween_property(_def_sprite, "position:x", _DEF_HOME.x + 8.0,  0.09).set_delay(0.34)
		_anim_tween.tween_property(_def_sprite, "position:x", _DEF_HOME.x, 0.12).set_delay(0.43)
		_anim_tween.tween_property(_def_bar_fill, "size:x",
			post_w, 0.55).set_delay(0.19).set_ease(Tween.EASE_OUT)

func _is_ranged_attack() -> bool:
	if not is_instance_valid(_attacker) or not is_instance_valid(_target):
		return false
	if _attacker.grid_pos == null or _target.grid_pos == null:
		return false
	var dx: int = abs(_attacker.grid_pos.x - _target.grid_pos.x)
	var dy: int = abs(_attacker.grid_pos.y - _target.grid_pos.y)
	return max(dx, dy) > 1

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
	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	var root := _root

	# Dark overlay
	var ovr := ColorRect.new()
	ovr.set_anchors_preset(Control.PRESET_FULL_RECT)
	ovr.color = _OVERLAY
	ovr.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(ovr)

	# Panel backgrounds (tall — cover text zone + sprite zone). Painted
	# side-backgrounds when the art exists; flat panels otherwise.
	_panel_bg(root, Vector2(60, 55), Vector2(510, 600), true)
	_panel_bg(root, Vector2(710, 55), Vector2(510, 600), false)

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
	_def_stats_label = _make_label(root, Rect2(730, 180, 470, 65), "")

	# Gear consequence badge — shown only when gear fractures or breaks
	_gear_badge = ColorRect.new()
	_gear_badge.position = Vector2(730, 250)
	_gear_badge.size = Vector2(470, 22)
	_gear_badge.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_gear_badge.visible = false
	root.add_child(_gear_badge)
	_gear_badge_label = _make_label(root, Rect2(730, 250, 470, 22), "")

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

	# Bullet projectile (hidden until a ranged attack fires)
	_bullet = ColorRect.new()
	_bullet.size = Vector2(14.0, 6.0)
	_bullet.color = Color(0.95, 0.90, 0.40)
	_bullet.visible = false
	_bullet.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_bullet)

	# === RESULT BAND (bottom) ===
	_result_label = _make_label(root, Rect2(120, 590, 1040, 40),
		"", HORIZONTAL_ALIGNMENT_CENTER)
	_result_label.add_theme_color_override("font_color", Color(0.95, 0.80, 0.20))
	_result_label.add_theme_font_size_override("font_size", 17)
	_result_label.pivot_offset = Vector2(520.0, 20.0)

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

## Side panel background: painted scene art when present, flat panel otherwise.
func _panel_bg(parent: Control, pos: Vector2, sz: Vector2, player_side: bool) -> void:
	var tex := SpriteLib.cutaway_bg(player_side)
	if tex == null:
		_bg_rect(parent, pos, sz)
		return
	var tr := TextureRect.new()
	tr.position = pos
	tr.size = sz
	tr.texture = tex
	tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	tr.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(tr)
