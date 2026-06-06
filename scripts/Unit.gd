class_name Unit
extends Node2D

enum Archetype { NONE, GUARDIAN, RAMPAGING, TACTICAL }

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

# Guardian fields
var patrol_path: Array[GridPos] = []
var patrol_index: int = 0
var zone_min_row: int = -1   # -1 = no boundary
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

const RADIUS: float = 10.0
const PLAYER_COLOR    := Color(0.22, 0.52, 0.82)
const GUARDIAN_COLOR  := Color(0.65, 0.20, 0.15)
const RAMPAGING_COLOR := Color(0.80, 0.38, 0.08)
const TACTICAL_COLOR  := Color(0.48, 0.10, 0.22)
const LEADER_RING     := Color(0.90, 0.80, 0.10)
const SELECT_RING     := Color(0.90, 0.90, 0.35)
const ALERT_RING      := Color(0.95, 0.45, 0.10)
const ADVANCE_RING    := Color(0.80, 0.10, 0.30)
const BAR_BACK        := Color(0.25, 0.08, 0.08)
const BAR_FILL        := Color(0.15, 0.75, 0.25)

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

func take_damage(amount: int) -> bool:
	toughness = max(0, toughness - amount)
	if toughness == 0:
		is_downed = true
	queue_redraw()
	return is_downed

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
	if is_downed:
		draw_circle(Vector2.ZERO, RADIUS, Color(0.28, 0.28, 0.28, 0.4))
		return

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

	# Archetype indicator for enemies
	if not is_player:
		match archetype:
			Archetype.RAMPAGING:
				# Small jagged cross
				draw_line(Vector2(-4, 0), Vector2(4, 0), Color(1, 1, 1, 0.5), 1.5)
				draw_line(Vector2(0, -4), Vector2(0, 4), Color(1, 1, 1, 0.5), 1.5)
			Archetype.TACTICAL:
				# Small diamond
				draw_line(Vector2(0, -5), Vector2(4, 0), Color(1, 1, 1, 0.5), 1.2)
				draw_line(Vector2(4, 0), Vector2(0, 5),  Color(1, 1, 1, 0.5), 1.2)
				draw_line(Vector2(0, 5), Vector2(-4, 0), Color(1, 1, 1, 0.5), 1.2)
				draw_line(Vector2(-4, 0), Vector2(0, -5),Color(1, 1, 1, 0.5), 1.2)

	if is_leader:
		draw_arc(Vector2.ZERO, RADIUS + 3.5, 0.0, TAU, 32, LEADER_RING, 1.5)

	if is_alerted:
		draw_arc(Vector2.ZERO, RADIUS + 3.5, 0.0, TAU, 16, ALERT_RING, 1.5)

	if advance_triggered:
		draw_arc(Vector2.ZERO, RADIUS + 3.5, 0.0, TAU, 16, ADVANCE_RING, 1.5)

	if is_selected:
		draw_arc(Vector2.ZERO, RADIUS + 7.0, 0.0, TAU, 32, SELECT_RING, 2.0)

	# Toughness bar
	var bw := RADIUS * 2.2
	var bx := -bw * 0.5
	var by := RADIUS + 3.5
	draw_rect(Rect2(bx, by, bw, 3.0), BAR_BACK)
	draw_rect(Rect2(bx, by, bw * (float(toughness) / float(max_toughness)), 3.0), BAR_FILL)
