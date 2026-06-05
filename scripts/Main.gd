extends Node2D

@onready var grid_manager: GridManager = $GridManager
@onready var unit_layer: Node2D = $UnitLayer

var units: Array[Unit] = []
var selected_unit: Unit = null

func _ready() -> void:
	var grid_pixel_w: float = GridManager.GRID_WIDTH * GridManager.TILE_SIZE
	var grid_pixel_h: float = GridManager.GRID_HEIGHT * GridManager.TILE_SIZE
	var vp := get_viewport_rect().size
	grid_manager.position = Vector2(
		floor((vp.x - grid_pixel_w) * 0.5),
		floor((vp.y - grid_pixel_h) * 0.5)
	)
	_spawn_player_unit()

func _spawn_player_unit() -> void:
	var leader := Unit.new()
	leader.unit_id = "leader"
	leader.is_player = true
	leader.is_leader = true
	unit_layer.add_child(leader)
	leader.place_at(GridPos.new(6, 17), grid_manager)
	units.append(leader)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.global_position)

func _handle_click(click_pos: Vector2) -> void:
	for unit in units:
		if unit.contains_point(click_pos):
			_select_unit(unit)
			return
	_deselect_all()

func _select_unit(unit: Unit) -> void:
	_deselect_all()
	selected_unit = unit
	unit.select()

func _deselect_all() -> void:
	if selected_unit:
		selected_unit.deselect()
	selected_unit = null
	grid_manager.clear_highlights()
