class_name Unit
extends Node2D

enum Archetype { NONE, GUARDIAN, RAMPAGING, TACTICAL }
enum DamageResult { NORMAL, GEAR_FRACTURED, GEAR_BROKEN, DOWNED }

signal toughness_changed(unit: Unit, new_value: int)
signal unit_downed(unit: Unit)

const RADIUS: float = 10.0
const PLAYER_COLOR    := Color(0.22, 0.52, 0.82)
const GUARDIAN_COLOR  := Color(0.65, 0.20, 0.15)
const RAMPAGING_COLOR := Color(0.80, 0.38, 0.08)
const TACTICAL_COLOR  := Color(0.48, 0.10, 0.22)
const LEADER_RING     := Color(0.90, 0.80, 0.10)
const SELECT_RING     := Color(0.90, 0.90, 0.35)
const ALERT_RING      := Color(0.95, 0.45, 0.10)
const ADVANCE_RING    := Color(0.80, 0.10, 0.30)
const ACTING_RING     := Color(0.95, 0.95, 0.95, 0.85)
const BAR_BACK        := Color(0.25, 0.08, 0.08)
const BAR_FILL        := Color(0.15, 0.75, 0.25)

var unit_id: String = ""
var is_player: bool = true
var is_leader: bool = false
var grid_pos: GridPos = null

# Base stats — never change
var combat_skill: int = 2
var speed: int = 4
var attack_range: int = 3

# Toughness
var toughness: int = 5
var max_toughness: int = 5

# Gear
var gear: Array[GearItem] = []

# AI archetype (enemies only)
var archetype: int = Archetype.NONE
var vanguard_rank: int = 1

# Guardian fields
var patrol_path: Array[GridPos] = []
var patrol_index: int = 0
var zone_min_row: int = -1
var zone_max_row: int = -1
var is_alerted: bool = false

# Tactical fields
var advance_triggered: bool = false
var last_known_leader_pos: GridPos = null

# Turn state
var has_moved: bool = false
var has_attacked: bool = false
var is_downed: bool = false
var is_selected: bool = false
var is_acting: bool = false

# Combat depth fields
var facing: Vector2i = Vector2i(0, 1)              # default facing south
var cover_integrity: int = 0                        # remaining hits before cover breaks
var cover_type: CoverSystem.CoverType = CoverSystem.CoverType.NONE
var status_effects: StatusEffectManager

# Standee idle bob (sprite skin only): toggles a 1px vertical offset.
var _bob_up: bool = false

func _ready() -> void:
	status_effects = StatusEffectManager.new()
	# Crisp 2:1 downsample for the sprite skin (64px sources into 32px tiles).
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if SpriteLib.unit_texture(self) != null:
		var bob := Timer.new()
		bob.wait_time = 0.6
		bob.autostart = true
		bob.timeout.connect(func() -> void:
			_bob_up = not _bob_up
			if not is_downed:
				queue_redraw())
		add_child(bob)

func get_effective_combat_skill() -> int:
	var total := combat_skill
	for item: GearItem in gear:
		if item.stat_target == "combat_skill":
			total += item.get_effective_modifier()
	return total

func get_effective_speed() -> int:
	var total := speed
	for item: GearItem in gear:
		if item.stat_target == "speed":
			total += item.get_effective_modifier()
	return total

func get_weapon_damage() -> int:
	for item: GearItem in gear:
		if item.slot == "weapon" and item.state != GearItem.GearState.BROKEN:
			return item.damage
	return 1

func can_act() -> bool:
	return not is_downed and not (has_moved and has_attacked)

## Called at the start of each unit's turn: ticks status effects and weapon cooldowns.
func tick_turn_start() -> void:
	status_effects.tick_all()
	for item: GearItem in gear:
		if item.special != null:
			item.special.tick_cooldown()

## Apply a status effect, refreshing duration if the type is already active.
func apply_status(effect: StatusEffect) -> void:
	status_effects.apply(effect)

## Returns true if this unit currently has the given status effect type.
func has_status(type: StatusEffect.Type) -> bool:
	return status_effects.has(type)

## Effective movement range after applying any active status penalties.
func get_effective_move() -> int:
	return maxi(1, get_effective_speed() - status_effects.get_move_penalty())

## True while a BRACE weapon special is active (reduces the next incoming hit).
func is_braced() -> bool:
	for item: GearItem in gear:
		if item.slot == "weapon" and item.special != null and item.special.is_braced:
			return true
	return false

## Returns the gear state (int) of the equipped weapon, or INTACT if no weapon.
## Used by CoverSystem to determine whether cover effectiveness is penalised.
func get_weapon_gear_state() -> int:
	for item: GearItem in gear:
		if item.slot == "weapon":
			return item.state
	return GearItem.GearState.INTACT

func has_fractured_gear() -> bool:
	for item: GearItem in gear:
		if item.state == GearItem.GearState.FRACTURED:
			return true
	return false

func has_medical_kit() -> bool:
	for item: GearItem in gear:
		if item.slot == "medical":
			return true
	return false

func take_damage(amount: int) -> int:
	toughness = max(0, toughness - amount)
	toughness_changed.emit(self, toughness)
	if toughness > 0:
		queue_redraw()
		return DamageResult.NORMAL

	var intact_armor := _find_intact_gear("armor")
	if intact_armor != null:
		intact_armor.state = GearItem.GearState.FRACTURED
		toughness = max_toughness
		queue_redraw()
		return DamageResult.GEAR_FRACTURED

	var intact_weapon := _find_intact_gear("weapon")
	if intact_weapon != null:
		intact_weapon.state = GearItem.GearState.FRACTURED
		toughness = max_toughness
		queue_redraw()
		return DamageResult.GEAR_FRACTURED

	var fractured_item := _find_fractured_gear()
	if fractured_item != null:
		fractured_item.state = GearItem.GearState.BROKEN
		is_downed = true
		unit_downed.emit(self)
		queue_redraw()
		return DamageResult.GEAR_BROKEN

	is_downed = true
	unit_downed.emit(self)
	queue_redraw()
	return DamageResult.DOWNED

func _find_intact_gear(slot_name: String) -> GearItem:
	for item: GearItem in gear:
		if item.slot == slot_name and item.state == GearItem.GearState.INTACT:
			return item
	return null

func _find_fractured_gear() -> GearItem:
	for item: GearItem in gear:
		if item.slot == "armor" and item.state == GearItem.GearState.FRACTURED:
			return item
	for item: GearItem in gear:
		if item.slot == "weapon" and item.state == GearItem.GearState.FRACTURED:
			return item
	return null

func select() -> void:
	is_selected = true
	queue_redraw()

func deselect() -> void:
	is_selected = false
	queue_redraw()

func place_at(pos: GridPos, grid: GridManager) -> void:
	grid_pos = pos
	global_position = grid.grid_to_world_center(pos)

func contains_point(world_point: Vector2) -> bool:
	return global_position.distance_to(world_point) <= RADIUS + 6.0

func _draw() -> void:
	var standee := SpriteLib.unit_texture(self)

	if is_downed:
		if standee != null:
			_draw_standee(standee, Color(0.35, 0.35, 0.35, 0.5))
		else:
			draw_circle(Vector2.ZERO, RADIUS, Color(0.28, 0.28, 0.28, 0.4))
		return

	if standee != null:
		var tint := Color.WHITE
		if has_moved and has_attacked:
			tint = Color(0.55, 0.55, 0.55)  # spent units grey out, FE-style
		_draw_standee(standee, tint)
	else:
		_draw_fallback_disc()

	if is_leader:
		draw_arc(Vector2.ZERO, RADIUS + 3.5, 0.0, TAU, 32, LEADER_RING, 1.5)

	if is_alerted:
		draw_arc(Vector2.ZERO, RADIUS + 3.5, 0.0, TAU, 16, ALERT_RING, 1.5)

	if advance_triggered:
		draw_arc(Vector2.ZERO, RADIUS + 3.5, 0.0, TAU, 16, ADVANCE_RING, 1.5)

	if is_selected:
		draw_arc(Vector2.ZERO, RADIUS + 7.0, 0.0, TAU, 32, SELECT_RING, 2.0)

	if is_acting:
		draw_arc(Vector2.ZERO, RADIUS + 5.5, 0.0, TAU, 24, ACTING_RING, 2.5)

	var bw := RADIUS * 2.2
	var bx := -bw * 0.5
	var by := RADIUS + 3.5
	draw_rect(Rect2(bx, by, bw, 3.0), BAR_BACK)
	draw_rect(Rect2(bx, by, bw * (float(toughness) / float(max_toughness)), 3.0), BAR_FILL)

	var notch_x := RADIUS + 2.0
	var notch_y := -RADIUS
	for item: GearItem in gear:
		if item.slot == "medical":
			continue
		if item.state == GearItem.GearState.FRACTURED:
			draw_rect(Rect2(notch_x, notch_y, 4.0, 4.0), Color(1.0, 0.55, 0.0))
			notch_y += 6.0
		elif item.state == GearItem.GearState.BROKEN:
			draw_rect(Rect2(notch_x, notch_y, 4.0, 4.0), Color(0.25, 0.12, 0.12))
			notch_y += 6.0

## GBA-style 48x48 standee, feet anchored near the tile bottom so the body
## overflows the 32px tile upward (Fire Emblem map-sprite convention).
## Mirrored horizontally when facing left; idle bob is a 1px offset.
func _draw_standee(tex: Texture2D, tint: Color) -> void:
	var bob := -1.0 if (_bob_up and not is_downed) else 0.0
	var flip := facing.x < 0
	if flip:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))
	draw_texture_rect(tex, Rect2(-24.0, -34.0 + bob, 48.0, 48.0), false, tint)
	if flip:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

## Original programmatic disc — used whenever no standee texture exists.
func _draw_fallback_disc() -> void:
	var fill: Color
	if is_player:
		fill = PLAYER_COLOR
	else:
		match archetype:
			Archetype.GUARDIAN:  fill = GUARDIAN_COLOR
			Archetype.RAMPAGING: fill = RAMPAGING_COLOR
			Archetype.TACTICAL:  fill = TACTICAL_COLOR
			_:                   fill = GUARDIAN_COLOR

	if has_moved and has_attacked:
		fill = fill.lerp(Color(0.3, 0.3, 0.3), 0.45)

	draw_circle(Vector2.ZERO, RADIUS, fill)

	# Player crew show their callsign initial (A/B/C) inside the disc.
	if is_player and not unit_id.is_empty():
		var font: Font = ThemeDB.fallback_font
		var ch := unit_id.substr(0, 1)
		var fsize := 11
		var sz := font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, fsize)
		var baseline := (font.get_ascent(fsize) - font.get_descent(fsize)) * 0.5
		draw_string(font, Vector2(-sz.x * 0.5, baseline), ch,
				HORIZONTAL_ALIGNMENT_LEFT, -1, fsize, Color(0.96, 0.96, 0.98))

	if not is_player:
		match archetype:
			Archetype.RAMPAGING:
				draw_line(Vector2(-4, 0), Vector2(4, 0), Color(1, 1, 1, 0.5), 1.5)
				draw_line(Vector2(0, -4), Vector2(0, 4), Color(1, 1, 1, 0.5), 1.5)
			Archetype.TACTICAL:
				draw_line(Vector2(0, -5), Vector2(4, 0), Color(1, 1, 1, 0.5), 1.2)
				draw_line(Vector2(4, 0), Vector2(0, 5),  Color(1, 1, 1, 0.5), 1.2)
				draw_line(Vector2(0, 5), Vector2(-4, 0), Color(1, 1, 1, 0.5), 1.2)
				draw_line(Vector2(-4, 0), Vector2(0, -5),Color(1, 1, 1, 0.5), 1.2)
