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

var tiles: Array = []
# Cover tier per cell: key = "x,y" string, value = int (1=LIGHT, 2=HEAVY, 0/absent=none)
var _cover_tiers: Dictionary = {}
var _move_highlights: Array[GridPos] = []
var _attack_highlights: Array[GridPos] = []
var _warning_tiles: Array[GridPos] = []
var _extraction_tile: GridPos = null
var _extract_overlay: ExtractionPulse = null

func _ready() -> void:
	_init_tiles()
	# Crisp 2:1 downsample for the sprite skin (64px tile art into 32px cells).
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	# Pulsing extraction marker lives in its own canvas item so the static
	# board is not redrawn every frame just to animate one tile.
	_extract_overlay = ExtractionPulse.new()
	add_child(_extract_overlay)
	queue_redraw()

func load_map(map_id: String) -> void:
	_init_tiles()
	match map_id:
		"map-prototype":       _place_map_prototype()
		"map-supply-depot":    _place_map_supply_depot()
		"map-security-block":  _place_map_security_block()
		"map-cell-corridor":   _place_map_cell_corridor()
		"map-colony-survey":   _place_map_colony_survey()
		"map-colony-depot":    _place_map_colony_depot()
		"map-colony-comms":    _place_map_colony_comms()
		"map-colony-security": _place_map_colony_security()
		"map-colony-yard":     _place_map_colony_yard()
		_:
			push_warning("GridManager: unknown map_id '%s', loading prototype" % map_id)
			_place_map_prototype()
	queue_redraw()

func _place_perimeter() -> void:
	for x in GRID_WIDTH:
		_set_tile(x, 0, TileType.WALL)
		_set_tile(x, GRID_HEIGHT - 1, TileType.WALL)
	for y in GRID_HEIGHT:
		_set_tile(0, y, TileType.WALL)
		_set_tile(GRID_WIDTH - 1, y, TileType.WALL)

# --- First Repossession campaign maps (colony) ------------------------------

## M1 SITE SURVEY — a narrow survey corridor. Deliberately tiny: teaches
## move / attack / extract with nowhere to get lost.
func _place_map_colony_survey() -> void:
	_place_perimeter()
	# Wall off the flanks: playable corridor is x 4–7.
	for y in range(1, GRID_HEIGHT - 1):
		for x in [1, 2, 3, 8, 9, 10]:
			_set_tile(x, y, TileType.WALL)
	# Three cover pieces stepping up the corridor.
	_set_cover_tile(5, 12)
	_set_cover_tile(6, 9)
	_set_cover_tile(4, 6)

## M2 ASSET TAGGING — depot aisles with cover lanes. Teaches the graze
## preview: every approach offers a covered shot and a flanking route.
func _place_map_colony_depot() -> void:
	_place_perimeter()
	# Two storage racks splitting the floor into three aisles.
	for y in range(4, 9):
		_set_tile(3, y, TileType.WALL)
		_set_tile(8, y, TileType.WALL)
	for y in range(11, 16):
		_set_tile(5, y, TileType.WALL)
		_set_tile(6, y, TileType.WALL)
	# Cover lanes — pairs the player can leapfrog between.
	_set_cover_tile(2, 13); _set_cover_tile(9, 13)
	_set_cover_tile(4, 10); _set_cover_tile(7, 10)
	_set_cover_tile(2, 7);  _set_cover_tile(9, 7)
	_set_cover_tile(5, 5); _set_cover_tile(6, 5)

## M3 CONTESTED CLAIM — comms relay plaza. Open centre with cover clusters;
## the Vanguard cut in from the top mid-mission.
func _place_map_colony_comms() -> void:
	_place_perimeter()
	# Relay building stubs left and right.
	for y in range(7, 10):
		_set_tile(2, y, TileType.WALL)
		_set_tile(9, y, TileType.WALL)
	# Central cover clusters.
	_set_cover_tile(5, 13); _set_cover_tile(6, 13)
	_set_cover_tile(3, 10); _set_cover_tile(8, 10)
	_set_cover_tile(5, 7);  _set_cover_tile(6, 7)
	_set_cover_tile(4, 4);  _set_cover_tile(7, 4)
	set_cover_tier(GridPos.new(5, 7), 2)   # heavy cover at the midline
	set_cover_tier(GridPos.new(6, 7), 2)

## M4 SECURITY LOCKOUT — the colony security wing. Chokepoints + the
## hazard rows (8–12) make the midfield dangerous ground.
func _place_map_colony_security() -> void:
	_place_perimeter()
	# Security checkpoint chokewall at row 7 with two doors.
	for x in GRID_WIDTH:
		if x != 3 and x != 8:
			_set_tile(x, 7, TileType.WALL)
	# Holding cells bottom-left / bottom-right.
	for y in range(11, 14):
		_set_tile(3, y, TileType.WALL)
		_set_tile(8, y, TileType.WALL)
	# Cover at the door approaches and inside the wing.
	_set_cover_tile(3, 9);  _set_cover_tile(8, 9)
	_set_cover_tile(2, 5);  _set_cover_tile(9, 5)
	_set_cover_tile(5, 4);  _set_cover_tile(6, 4)
	set_cover_tier(GridPos.new(5, 4), 2)
	set_cover_tier(GridPos.new(6, 4), 2)
	_set_cover_tile(4, 15); _set_cover_tile(7, 15)

## M5 FINAL NOTICE — the loading yard. Big open finale: long sightlines,
## scattered cover, the full Vanguard crew arriving early.
func _place_map_colony_yard() -> void:
	_place_perimeter()
	# Cargo stacks.
	_set_tile(3, 5, TileType.WALL);  _set_tile(4, 5, TileType.WALL)
	_set_tile(7, 11, TileType.WALL); _set_tile(8, 11, TileType.WALL)
	_set_tile(2, 14, TileType.WALL)
	# Scattered crates (cover) across the yard.
	_set_cover_tile(6, 15); _set_cover_tile(3, 12)
	_set_cover_tile(5, 10); _set_cover_tile(9, 9)
	_set_cover_tile(2, 8);  _set_cover_tile(6, 7)
	_set_cover_tile(8, 5);  _set_cover_tile(4, 3)
	set_cover_tier(GridPos.new(6, 7), 2)
	set_cover_tier(GridPos.new(4, 3), 2)

func _init_tiles() -> void:
	tiles.resize(GRID_WIDTH)
	for x in GRID_WIDTH:
		tiles[x] = []
		tiles[x].resize(GRID_HEIGHT)
		for y in GRID_HEIGHT:
			tiles[x][y] = TileType.FLOOR

func _place_map_prototype() -> void:
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
	_set_cover_tile(3, 3)
	_set_cover_tile(8, 3)
	_set_cover_tile(2, 5)
	_set_cover_tile(9, 5)

	# Zone B cover + internal walls (rows 8–12) — narrow corridors
	_set_cover_tile(3, 9)
	_set_cover_tile(8, 9)
	_set_cover_tile(5, 10)
	_set_cover_tile(6, 10)
	_set_tile(2, 11, TileType.WALL)
	_set_tile(9, 11, TileType.WALL)

	# Zone A cover (rows 14–18) — player entry
	_set_cover_tile(3, 16)
	_set_cover_tile(8, 16)
	_set_cover_tile(5, 15)
	_set_cover_tile(6, 15)

func _place_map_supply_depot() -> void:
	for x in GRID_WIDTH:
		_set_tile(x, 0, TileType.WALL); _set_tile(x, GRID_HEIGHT - 1, TileType.WALL)
	for y in GRID_HEIGHT:
		_set_tile(0, y, TileType.WALL); _set_tile(GRID_WIDTH - 1, y, TileType.WALL)
	# Left storage rack
	for y in range(3, 8):
		_set_tile(4, y, TileType.WALL)
	# Right storage rack
	for y in range(3, 8):
		_set_tile(7, y, TileType.WALL)
	# Chokewall — left block x=1–3, right block x=8–10 at row 11
	_set_tile(1, 11, TileType.WALL); _set_tile(2, 11, TileType.WALL); _set_tile(3, 11, TileType.WALL)
	_set_tile(8, 11, TileType.WALL); _set_tile(9, 11, TileType.WALL); _set_tile(10, 11, TileType.WALL)
	# Cover
	_set_cover_tile(2, 2);  _set_cover_tile(9, 2)
	_set_cover_tile(2, 5);  _set_cover_tile(9, 5)
	_set_cover_tile(2, 9);  _set_cover_tile(9, 9)
	_set_cover_tile(3, 13); _set_cover_tile(8, 13)

func _place_map_security_block() -> void:
	for x in GRID_WIDTH:
		_set_tile(x, 0, TileType.WALL); _set_tile(x, GRID_HEIGHT - 1, TileType.WALL)
	for y in GRID_HEIGHT:
		_set_tile(0, y, TileType.WALL); _set_tile(GRID_WIDTH - 1, y, TileType.WALL)
	# Left guard booth stub x=4, rows 4–5
	_set_tile(4, 4, TileType.WALL); _set_tile(4, 5, TileType.WALL)
	# Right guard booth stub x=7, rows 4–5
	_set_tile(7, 4, TileType.WALL); _set_tile(7, 5, TileType.WALL)
	# Chokewall — left block x=1–3, right block x=8–10 at row 7
	_set_tile(1, 7, TileType.WALL); _set_tile(2, 7, TileType.WALL); _set_tile(3, 7, TileType.WALL)
	_set_tile(8, 7, TileType.WALL); _set_tile(9, 7, TileType.WALL); _set_tile(10, 7, TileType.WALL)
	# Cover
	_set_cover_tile(2, 2);  _set_cover_tile(9, 2)
	_set_cover_tile(3, 4);  _set_cover_tile(8, 4)
	_set_cover_tile(2, 9);  _set_cover_tile(9, 9)
	_set_cover_tile(3, 12); _set_cover_tile(8, 12)

func _place_map_cell_corridor() -> void:
	for x in GRID_WIDTH:
		_set_tile(x, 0, TileType.WALL); _set_tile(x, GRID_HEIGHT - 1, TileType.WALL)
	for y in GRID_HEIGHT:
		_set_tile(0, y, TileType.WALL); _set_tile(GRID_WIDTH - 1, y, TileType.WALL)
	# Cell block walls — rows 4–6: left (x=1–3) and right (x=8–10)
	for y in range(4, 7):
		for x in range(1, 4):
			_set_tile(x, y, TileType.WALL)
		for x in range(8, 11):
			_set_tile(x, y, TileType.WALL)
	# Cover
	_set_cover_tile(2, 2);  _set_cover_tile(9, 2)
	_set_cover_tile(2, 8);  _set_cover_tile(9, 8)
	_set_cover_tile(2, 11); _set_cover_tile(9, 11)
	_set_cover_tile(3, 14); _set_cover_tile(8, 14)
	# Hazard — burst steam line
	_set_tile(5, 11, TileType.HAZARD_ZONE); _set_tile(6, 11, TileType.HAZARD_ZONE)

func _set_tile(x: int, y: int, type: int) -> void:
	if x >= 0 and x < GRID_WIDTH and y >= 0 and y < GRID_HEIGHT:
		tiles[x][y] = type

# Internal helper: place a COVER tile and register it with tier 1 (LIGHT) by default.
func _set_cover_tile(x: int, y: int, tier: int = 1) -> void:
	_set_tile(x, y, TileType.COVER)
	_cover_tiers["%d,%d" % [x, y]] = tier

## Set the cover tier for a position (1 = LIGHT, 2 = HEAVY).
## Call after placing a COVER tile for heavy-cover positions.
func set_cover_tier(pos: GridPos, tier: int) -> void:
	_cover_tiers["%d,%d" % [pos.x, pos.y]] = tier

## Return the cover tier at a position (0 if not registered, defaults to LIGHT treatment).
func get_cover_tier(pos: GridPos) -> int:
	return _cover_tiers.get("%d,%d" % [pos.x, pos.y], 0)

## Destroy the cover tile at pos: revert to FLOOR and remove tier data.
## Returns true (always — caller decides whether to act on integrity first).
func damage_cover_at(pos: GridPos) -> bool:
	set_tile(pos, TileType.FLOOR)
	_cover_tiers.erase("%d,%d" % [pos.x, pos.y])
	queue_redraw()
	return true

## Public tile setter (used by damage_cover_at and external systems).
func set_tile(pos: GridPos, type: int) -> void:
	_set_tile(pos.x, pos.y, type)

## Return all non-downed units within Chebyshev radius of origin.
func get_units_in_radius(origin: GridPos, radius: int, all_units: Array[Unit]) -> Array[Unit]:
	var result: Array[Unit] = []
	for u: Unit in all_units:
		if u.is_downed:
			continue
		var dist: int = maxi(absi(u.grid_pos.x - origin.x), absi(u.grid_pos.y - origin.y))
		if dist <= radius:
			result.append(u)
	return result

func _draw() -> void:
	for x in GRID_WIDTH:
		for y in GRID_HEIGHT:
			var rect := Rect2(x * TILE_SIZE, y * TILE_SIZE, TILE_SIZE, TILE_SIZE)
			var tex := SpriteLib.tile_texture(tiles[x][y], x, y)
			if tex != null:
				draw_texture_rect(tex, rect, false)
			else:
				draw_rect(rect, TILE_COLORS[tiles[x][y]])
			draw_rect(rect, LINE_COLOR, false, 0.5)

	for pos in _move_highlights:
		draw_rect(Rect2(pos.x * TILE_SIZE, pos.y * TILE_SIZE, TILE_SIZE, TILE_SIZE), MOVE_HIGHLIGHT)

	for pos in _attack_highlights:
		draw_rect(Rect2(pos.x * TILE_SIZE, pos.y * TILE_SIZE, TILE_SIZE, TILE_SIZE), ATTACK_HIGHLIGHT)

	for pos in _warning_tiles:
		draw_rect(Rect2(pos.x * TILE_SIZE, pos.y * TILE_SIZE, TILE_SIZE, TILE_SIZE), WARNING_HIGHLIGHT)

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
	_extract_overlay.set_tile(pos, TILE_SIZE)

func is_hazard_warned(pos: GridPos) -> bool:
	for p in _warning_tiles:
		if p.x == pos.x and p.y == pos.y:
			return true
	return false
