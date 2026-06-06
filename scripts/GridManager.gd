class_name GridManager
extends Node2D

enum TileType { FLOOR, WALL, COVER, HAZARD_ZONE }

const GRID_WIDTH: int = 12
const GRID_HEIGHT: int = 20
const TILE_SIZE: int = 32

const TILE_COLORS: Dictionary = {
	0: Color(0.10, 0.11, 0.13),   # FLOOR
	1: Color(0.04, 0.04, 0.06),   # WALL
	2: Color(0.20, 0.15, 0.10),   # COVER
	3: Color(0.18, 0.18, 0.08),   # HAZARD_ZONE
}
const LINE_COLOR          := Color(0.22, 0.25, 0.30, 0.55)
const MOVE_HIGHLIGHT      := Color(0.25, 0.60, 0.25, 0.35)
const ATTACK_HIGHLIGHT    := Color(0.75, 0.18, 0.18, 0.40)
const WARNING_HIGHLIGHT   := Color(0.90, 0.80, 0.10, 0.45)
const EXTRACT_HIGHLIGHT   := Color(0.10, 0.80, 0.60, 0.55)

var tiles: Array = []
var _move_highlights: Array[GridPos] = []
var _attack_highlights: Array[GridPos] = []
var _warning_tiles: Array[GridPos] = []
var _extraction_tile: GridPos = null

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
	# Outer perimeter walls
	for x in GRID_WIDTH:
		_set_tile(x, 0, TileType.WALL)
		_set_tile(x, GRID_HEIGHT - 1, TileType.WALL)
	for y in GRID_HEIGHT:
		_set_tile(0, y, TileType.WALL)
		_set_tile(GRID_WIDTH - 1, y, TileType.WALL)

	# Zone C / Zone B divider at row 7 — corridor openings at col 4 and 8
	for x in GRID_WIDTH:
		if x != 4 and x != 8:
			_set_tile(x, 7, TileType.WALL)

	# Zone B / Zone A divider at row 13 — corridor openings at col 3 and 9
	for x in GRID_WIDTH:
		if x != 3 and x != 9:
			_set_tile(x, 13, TileType.WALL)

	# Zone C cover (rows 1–6) — evidence locker area
	_set_tile(3, 3, TileType.COVER)
	_set_tile(8, 3, TileType.COVER)
	_set_tile(2, 5, TileType.COVER)
	_set_tile(9, 5, TileType.COVER)

	# Zone B cover + internal walls (rows 8–12) — narrow corridors
	_set_tile(3, 9,  TileType.COVER)
	_set_tile(8, 9,  TileType.COVER)
	_set_tile(5, 10, TileType.COVER)
	_set_tile(6, 10, TileType.COVER)
	_set_tile(2, 11, TileType.WALL)
	_set_tile(9, 11, TileType.WALL)

	# Zone A cover (rows 14–18) — player entry
	_set_tile(3, 16, TileType.COVER)
	_set_tile(8, 16, TileType.COVER)
	_set_tile(5, 15, TileType.COVER)
	_set_tile(6, 15, TileType.COVER)

func _set_tile(x: int, y: int, type: int) -> void:
	if x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT:
		tiles[x][y] = type

func _draw() -> void:
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			var rect := Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			draw_rect(rect, TILE_COLORS[tiles[x][y]])
			draw_rect(rect, LINE_COLOR, false, 0.5)

	for pos in _move_highlights:
		draw_rect(Rect2(pos.x * TILE_SIZE, pos.y * TILE_SIZE, TILE_SIZE, TILE_SIZE), MOVE_HIGHLIGHT)

	for pos in _attack_highlights:
		draw_rect(Rect2(pos.x * TILE_SIZE, pos.y * TILE_SIZE, TILE_SIZE, TILE_SIZE), ATTACK_HIGHLIGHT)

	for pos in _warning_tiles:
		draw_rect(Rect2(pos.x * TILE_SIZE, pos.y * TILE_SIZE, TILE_SIZE, TILE_SIZE), WARNING_HIGHLIGHT)

	if _extraction_tile != null:
		draw_rect(
			Rect2(_extraction_tile.x * TILE_SIZE, _extraction_tile.y * TILE_SIZE, TILE_SIZE, TILE_SIZE),
			EXTRACT_HIGHLIGHT
		)

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

func set_move_highlights(positions: Array[GridPos]) -> void:
	_move_highlights = positions
	queue_redraw()

func set_attack_highlights(positions: Array[GridPos]) -> void:
	_attack_highlights = positions
	queue_redraw()

func clear_all_highlights() -> void:
	_move_highlights = []
	_attack_highlights = []
	queue_redraw()

func set_warning_tiles(positions: Array[GridPos]) -> void:
	_warning_tiles = positions
	queue_redraw()

func clear_warning_tiles() -> void:
	_warning_tiles = []
	queue_redraw()

func get_warning_tiles() -> Array[GridPos]:
	return _warning_tiles

func set_extraction_tile(pos: GridPos) -> void:
	_extraction_tile = pos
	queue_redraw()

func is_hazard_warned(pos: GridPos) -> bool:
	for p in _warning_tiles:
		if p.x == pos.x and p.y == pos.y:
			return true
	return false
