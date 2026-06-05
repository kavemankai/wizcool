class_name GridManager
extends Node2D

const GRID_WIDTH: int = 12
const GRID_HEIGHT: int = 20
const TILE_SIZE: int = 32

enum TileType { FLOOR, WALL, COVER }

const TILE_COLORS: Dictionary = {
	0: Color(0.10, 0.11, 0.13),
	1: Color(0.04, 0.04, 0.06),
	2: Color(0.20, 0.15, 0.10),
}
const LINE_COLOR := Color(0.22, 0.25, 0.30, 0.55)
const HIGHLIGHT_COLOR := Color(0.30, 0.60, 0.30, 0.35)
const ZONE_LABEL_COLOR := Color(0.50, 0.45, 0.30, 0.40)

var tiles: Array = []
var _highlights: Array[GridPos] = []

func _ready() -> void:
	_init_tiles()
	_place_prototype_layout()
	queue_redraw()

func _init_tiles() -> void:
	tiles.resize(GRID_WIDTH)
	for x in GRID_WIDTH:
		tiles[x] = []
		tiles[x].resize(GRID_HEIGHT)
		for y in GRID_HEIGHT:
			tiles[x][y] = TileType.FLOOR

func _place_prototype_layout() -> void:
	# Outer walls
	for x in GRID_WIDTH:
		_set(x, 0, TileType.WALL)
		_set(x, GRID_HEIGHT - 1, TileType.WALL)
	for y in GRID_HEIGHT:
		_set(0, y, TileType.WALL)
		_set(GRID_WIDTH - 1, y, TileType.WALL)

	# Zone A/B divider at row 7 — gaps at col 4 and col 8 (corridor openings)
	for x in GRID_WIDTH:
		if x != 4 and x != 8:
			_set(x, 7, TileType.WALL)

	# Zone B/C divider at row 13 — gaps at col 3 and col 9
	for x in GRID_WIDTH:
		if x != 3 and x != 9:
			_set(x, 13, TileType.WALL)

	# Zone A cover
	_set(3, 3, TileType.COVER)
	_set(8, 3, TileType.COVER)
	_set(2, 5, TileType.COVER)
	_set(9, 5, TileType.COVER)

	# Zone B cover / cell doors
	_set(3, 9, TileType.COVER)
	_set(8, 9, TileType.COVER)
	_set(5, 10, TileType.COVER)
	_set(6, 10, TileType.COVER)
	_set(2, 11, TileType.WALL)
	_set(9, 11, TileType.WALL)

	# Zone C cover
	_set(3, 16, TileType.COVER)
	_set(8, 16, TileType.COVER)
	_set(5, 15, TileType.COVER)
	_set(6, 15, TileType.COVER)

func _set(x: int, y: int, type: int) -> void:
	if x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT:
		tiles[x][y] = type

func _draw() -> void:
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			var rect := Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			draw_rect(rect, TILE_COLORS[tiles[x][y]])
			draw_rect(rect, LINE_COLOR, false, 0.5)

	for pos in _highlights:
		var rect := Rect2(pos.x * TILE_SIZE, pos.y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
		draw_rect(rect, HIGHLIGHT_COLOR)

func get_tile_type(pos: GridPos) -> int:
	if not is_in_bounds(pos):
		return TileType.WALL
	return tiles[pos.x][pos.y]

func is_in_bounds(pos: GridPos) -> bool:
	return pos.x >= 0 and pos.x < GRID_WIDTH and pos.y >= 0 and pos.y < GRID_HEIGHT

func is_walkable(pos: GridPos) -> bool:
	return is_in_bounds(pos) and tiles[pos.x][pos.y] != TileType.WALL

func world_to_grid(world_pos: Vector2) -> GridPos:
	var local := to_local(world_pos)
	return GridPos.new(int(local.x / TILE_SIZE), int(local.y / TILE_SIZE))

func grid_to_world_center(pos: GridPos) -> Vector2:
	return to_global(Vector2(
		pos.x * TILE_SIZE + TILE_SIZE * 0.5,
		pos.y * TILE_SIZE + TILE_SIZE * 0.5
	))

func set_highlights(positions: Array[GridPos]) -> void:
	_highlights = positions
	queue_redraw()

func clear_highlights() -> void:
	_highlights = []
	queue_redraw()
