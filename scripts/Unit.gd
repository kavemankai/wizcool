class_name Unit
extends Node2D

var unit_id: String = ""
var is_player: bool = true
var is_leader: bool = false
var grid_pos: GridPos = null
var is_selected: bool = false

const RADIUS: float = 10.0
const PLAYER_COLOR := Color(0.22, 0.52, 0.82)
const ENEMY_COLOR := Color(0.72, 0.22, 0.18)
const LEADER_RING_COLOR := Color(0.90, 0.80, 0.10)
const SELECT_RING_COLOR := Color(0.90, 0.90, 0.35)

func _draw() -> void:
	var fill := PLAYER_COLOR if is_player else ENEMY_COLOR
	draw_circle(Vector2.ZERO, RADIUS, fill)

	if is_leader:
		draw_arc(Vector2.ZERO, RADIUS + 3.5, 0.0, TAU, 32, LEADER_RING_COLOR, 1.5)

	if is_selected:
		draw_arc(Vector2.ZERO, RADIUS + 7.0, 0.0, TAU, 32, SELECT_RING_COLOR, 2.0)

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
