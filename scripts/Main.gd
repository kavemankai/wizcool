extends Node2D

enum GamePhase { PLAYER_TURN, ENEMY_TURN }
enum InputState { IDLE, ACTING }

@onready var grid_manager: GridManager = $GridManager
@onready var unit_layer: Node2D = $UnitLayer
@onready var hud: HUD = $HUD

var units: Array[Unit] = []
var game_phase: GamePhase = GamePhase.PLAYER_TURN
var input_state: InputState = InputState.IDLE
var active_unit: Unit = null
var move_tiles: Array[GridPos] = []
var round_number: int = 1

func _ready() -> void:
	var grid_w := GridManager.GRID_WIDTH * GridManager.TILE_SIZE
	var grid_h := GridManager.GRID_HEIGHT * GridManager.TILE_SIZE
	var vp := get_viewport_rect().size
	grid_manager.position = Vector2(
		floor((vp.x - grid_w) * 0.5),
		floor((vp.y - grid_h) * 0.5)
	)
	hud.end_turn_pressed.connect(_on_end_turn)
	_spawn_units()
	hud.log("[ROUND 1 — PLAYER TURN]")

# ---------------------------------------------------------------------------
# Unit setup
# ---------------------------------------------------------------------------

func _spawn_units() -> void:
	# Zone A = rows 14–18 (bottom) — player entry
	var alpha := _make_unit("ALPHA", true, true, 6, 2, 3, 4)
	alpha.gear.append(GearItem.make_weapon("PLASMA-CUTTER", 2, 3))
	_place(alpha, GridPos.new(5, 17))

	var bravo := _make_unit("BRAVO", true, false, 5, 2, 4, 2)
	bravo.gear.append(GearItem.make_weapon("IMPACT-WRENCH", 1, 2))
	bravo.gear.append(GearItem.make_armor("WORK-HARNESS", 1))
	_place(bravo, GridPos.new(3, 16))

	var charlie := _make_unit("CHARLIE", true, false, 4, 3, 3, 5)
	charlie.gear.append(GearItem.make_weapon("LONG-BORE-DRILL", 1, 2))
	_place(charlie, GridPos.new(7, 16))

	# Zone B = rows 8–12 (middle) — Security Bots
	var s1 := _make_unit("SENTINEL-1", false, false, 4, 2, 2, 3)
	_place(s1, GridPos.new(4, 10))

	var s2 := _make_unit("SENTINEL-2", false, false, 4, 2, 2, 3)
	_place(s2, GridPos.new(8, 10))

func _make_unit(id: String, player: bool, leader: bool,
		hp: int, cs: int, spd: int, rng: int) -> Unit:
	var u := Unit.new()
	u.unit_id = id
	u.is_player = player
	u.is_leader = leader
	u.toughness = hp
	u.max_toughness = hp
	u.combat_skill = cs
	u.speed = spd
	u.attack_range = rng
	unit_layer.add_child(u)
	units.append(u)
	return u

func _place(unit: Unit, pos: GridPos) -> void:
	unit.place_at(pos, grid_manager)

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if game_phase != GamePhase.PLAYER_TURN:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.global_position)

func _handle_click(click_pos: Vector2) -> void:
	var clicked_unit := _unit_at_screen(click_pos)
	var clicked_grid := grid_manager.world_to_grid(click_pos)

	match input_state:
		InputState.IDLE:
			if clicked_unit and clicked_unit.is_player and clicked_unit.can_act():
				_select(clicked_unit)

		InputState.ACTING:
			if clicked_unit == active_unit:
				_enter_idle()
			elif clicked_unit != null and clicked_unit.is_player and clicked_unit.can_act():
				_select(clicked_unit)
			elif clicked_unit != null and not clicked_unit.is_player and not clicked_unit.is_downed:
				if not active_unit.has_attacked and _can_attack(active_unit, clicked_unit):
					_do_attack(active_unit, clicked_unit)
					_refresh_highlights()
					if not active_unit.can_act():
						_enter_idle()
				else:
					hud.log("OUT OF RANGE")
			elif not active_unit.has_moved and _is_move_tile(clicked_grid):
				_do_move(active_unit, clicked_grid)
				_refresh_highlights()
				if not active_unit.can_act():
					_enter_idle()
			else:
				_enter_idle()

# ---------------------------------------------------------------------------
# Selection & highlights
# ---------------------------------------------------------------------------

func _select(unit: Unit) -> void:
	if active_unit and active_unit != unit:
		active_unit.deselect()
	active_unit = unit
	unit.select()
	_refresh_highlights()
	hud.show_unit(unit)
	input_state = InputState.ACTING

func _enter_idle() -> void:
	if active_unit:
		active_unit.deselect()
	active_unit = null
	move_tiles = []
	grid_manager.clear_all_highlights()
	hud.show_unit(null)
	input_state = InputState.IDLE

func _refresh_highlights() -> void:
	move_tiles = []

	if not active_unit.has_moved:
		var occupied := _occupied_positions(active_unit)
		move_tiles = MovementRange.get_reachable(
			active_unit.grid_pos,
			active_unit.get_effective_speed(),
			grid_manager,
			occupied
		)
		grid_manager.set_move_highlights(move_tiles)
	else:
		grid_manager.set_move_highlights([])

	if not active_unit.has_attacked:
		var atk_tiles: Array[GridPos] = []
		for u in units:
			if u.is_player == active_unit.is_player or u.is_downed:
				continue
			if _can_attack(active_unit, u):
				atk_tiles.append(u.grid_pos)
		grid_manager.set_attack_highlights(atk_tiles)
	else:
		grid_manager.set_attack_highlights([])

	hud.show_unit(active_unit)

func _is_move_tile(pos: GridPos) -> bool:
	for t in move_tiles:
		if t.x == pos.x and t.y == pos.y:
			return true
	return false

# ---------------------------------------------------------------------------
# Combat
# ---------------------------------------------------------------------------

func _can_attack(attacker: Unit, target: Unit) -> bool:
	if target.is_downed:
		return false
	var dx := abs(attacker.grid_pos.x - target.grid_pos.x)
	var dy := abs(attacker.grid_pos.y - target.grid_pos.y)
	if max(dx, dy) > attacker.attack_range:
		return false
	return LOS.has_los(attacker.grid_pos, target.grid_pos, grid_manager)

func _do_move(unit: Unit, pos: GridPos) -> void:
	unit.place_at(pos, grid_manager)
	unit.has_moved = true
	hud.log("%s → [%d,%d]" % [unit.unit_id, pos.x, pos.y])

func _do_attack(attacker: Unit, target: Unit) -> void:
	var dmg := attacker.get_weapon_damage()
	var downed := target.take_damage(dmg)
	attacker.has_attacked = true
	hud.log("%s → %s  -%d TGH  [%d/%d]" % [
		attacker.unit_id, target.unit_id, dmg,
		target.toughness, target.max_toughness
	])
	if downed:
		hud.log("%s DOWNED" % target.unit_id)
		target.queue_free()
		units.erase(target)
		_check_game_over()

func _check_game_over() -> void:
	var players_up := 0
	var enemies_up := 0
	for u in units:
		if u.is_player:
			players_up += 1
		else:
			enemies_up += 1
	if enemies_up == 0:
		hud.log("=== AREA CLEAR ===")
		game_phase = GamePhase.ENEMY_TURN
	elif players_up == 0:
		hud.log("=== ALL CREW DOWN — MISSION FAILED ===")
		game_phase = GamePhase.ENEMY_TURN

# ---------------------------------------------------------------------------
# Turn management
# ---------------------------------------------------------------------------

func _on_end_turn() -> void:
	if game_phase != GamePhase.PLAYER_TURN:
		return
	_enter_idle()
	_run_enemy_phase()

func _run_enemy_phase() -> void:
	game_phase = GamePhase.ENEMY_TURN
	hud.set_phase(false)
	hud.log("--- ENEMY PHASE ---")

	for u in units:
		if not u.is_player and not u.is_downed:
			hud.log("%s HOLDS" % u.unit_id)

	await get_tree().create_timer(0.8).timeout

	round_number += 1
	for u in units:
		if not u.is_downed:
			u.has_moved = false
			u.has_attacked = false
			u.queue_redraw()

	game_phase = GamePhase.PLAYER_TURN
	hud.set_phase(true)
	hud.log("--- ROUND %d — PLAYER TURN ---" % round_number)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _unit_at_screen(screen_pos: Vector2) -> Unit:
	for u in units:
		if not u.is_downed and u.contains_point(screen_pos):
			return u
	return null

func _occupied_positions(exclude: Unit) -> Array[GridPos]:
	var result: Array[GridPos] = []
	for u in units:
		if u != exclude and not u.is_downed:
			result.append(u.grid_pos)
	return result
