extends Node2D

enum GamePhase { PLAYER_TURN, ENEMY_TURN, GAME_OVER }
enum InputState { IDLE, ACTING }

const ROUND_LIMIT: int = 20
const EXTRACTION_POS := Vector2i(5, 2)
const DANGER_PAY := 150

var units: Array[Unit] = []
var game_phase: GamePhase = GamePhase.PLAYER_TURN
var input_state: InputState = InputState.IDLE
var active_unit: Unit = null
var move_tiles: Array[GridPos] = []
var round_number: int = 1
var dropped_loot: Array[GearItem] = []
var rival_rank: int = 1
var hazard_manager: HazardSystem = null

# unit_id → {is_leader: bool, gear: [{item_id, slot, state: int (GearState enum)}]}
var _gear_archive: Dictionary = {}

@onready var grid_manager: GridManager = $GridManager
@onready var unit_layer: Node2D = $UnitLayer
@onready var hud: HUD = $HUD

func _ready() -> void:
	var grid_w := GridManager.GRID_WIDTH * GridManager.TILE_SIZE
	var grid_h := GridManager.GRID_HEIGHT * GridManager.TILE_SIZE
	var vp := get_viewport_rect().size
	grid_manager.position = Vector2(
		floor((vp.x - grid_w) * 0.5),
		floor((vp.y - grid_h) * 0.5)
	)
	hud.end_turn_pressed.connect(_on_end_turn)
	hud.field_patch_pressed.connect(_on_field_patch)
	hazard_manager = HazardSystem.new()
	rival_rank = get_node("/root/GameState").vanguard_rank
	grid_manager.set_extraction_tile(GridPos.new(EXTRACTION_POS.x, EXTRACTION_POS.y))
	_spawn_units()
	hud.set_round(round_number)
	hud.log("[CONTAINMENT BREACH INITIATED]")
	hud.log("OBJECTIVE: Move ALPHA to Evidence Locker — Zone C [col 5, row 2]")
	hud.log("[ROUND 1 — PLAYER TURN]")

# ---------------------------------------------------------------------------
# Unit setup
# ---------------------------------------------------------------------------

func _spawn_units() -> void:
	var saved_gear: Array = get_node("/root/GameState").crew

	var alpha := _make_unit("ALPHA", true, true, 6, 2, 3, 4)
	alpha.gear.append(GearItem.make_weapon("PLASMA-CUTTER", 2, 3))
	alpha.gear.append(GearItem.make_medical_kit("FIELD-PATCH-KIT"))
	_place(alpha, GridPos.new(5, 17))
	_apply_saved_gear(alpha, saved_gear)
	_apply_starting_fractured_gear(alpha)
	_archive_unit(alpha)

	var bravo := _make_unit("BRAVO", true, false, 5, 2, 4, 2)
	bravo.gear.append(GearItem.make_weapon("IMPACT-WRENCH", 1, 2))
	bravo.gear.append(GearItem.make_armor("WORK-HARNESS", 1))
	_place(bravo, GridPos.new(3, 16))
	_apply_saved_gear(bravo, saved_gear)
	_archive_unit(bravo)

	var charlie := _make_unit("CHARLIE", true, false, 4, 3, 3, 5)
	charlie.gear.append(GearItem.make_weapon("LONG-BORE-DRILL", 1, 2))
	_place(charlie, GridPos.new(7, 16))
	_apply_saved_gear(charlie, saved_gear)
	_archive_unit(charlie)

	var s1 := _make_unit("SENTINEL-1", false, false, 4, 2, 2, 2)
	s1.archetype = Unit.Archetype.GUARDIAN
	s1.zone_min_row = 8
	s1.zone_max_row = 12
	s1.patrol_path = [GridPos.new(3, 8), GridPos.new(3, 11)]
	_place(s1, GridPos.new(3, 8))

	var s2 := _make_unit("SENTINEL-2", false, false, 4, 2, 2, 2)
	s2.archetype = Unit.Archetype.GUARDIAN
	s2.zone_min_row = 8
	s2.zone_max_row = 12
	s2.patrol_path = [GridPos.new(8, 8), GridPos.new(8, 11)]
	_place(s2, GridPos.new(8, 8))

	var p1 := _make_unit("PRISONER-1", false, false, 3, 2, 4, 1)
	p1.archetype = Unit.Archetype.RAMPAGING
	_place(p1, GridPos.new(4, 14))

	var p2 := _make_unit("PRISONER-2", false, false, 3, 2, 4, 1)
	p2.archetype = Unit.Archetype.RAMPAGING
	_place(p2, GridPos.new(7, 14))

	_spawn_vanguard()

func _spawn_vanguard() -> void:
	var count := 2 if rival_rank == 1 else 3

	var v1 := _make_unit("VANGUARD-1", false, false, 5, 2, 2, 3)
	v1.archetype = Unit.Archetype.TACTICAL
	v1.zone_min_row = 14
	v1.zone_max_row = 18
	v1.vanguard_rank = rival_rank
	v1.gear.append(GearItem.make_weapon("SALVAGE-PISTOL", 1, 2))
	_place(v1, GridPos.new(3, 18))

	var v2 := _make_unit("VANGUARD-2", false, false, 5, 2, 2, 3)
	v2.archetype = Unit.Archetype.TACTICAL
	v2.zone_min_row = 14
	v2.zone_max_row = 18
	v2.vanguard_rank = rival_rank
	if rival_rank >= 2:
		v2.gear.append(GearItem.make_armor("BALLISTIC-PLATE", 1))
	v2.gear.append(GearItem.make_weapon("SALVAGE-PISTOL", 1, 2))
	_place(v2, GridPos.new(8, 18))

	if count >= 3:
		var v3 := _make_unit("VANGUARD-3", false, false, 5, 2, 2, 3)
		v3.archetype = Unit.Archetype.TACTICAL
		v3.zone_min_row = 14
		v3.zone_max_row = 18
		v3.vanguard_rank = rival_rank
		v3.gear.append(GearItem.make_weapon("SALVAGE-PISTOL", 1, 2))
		if rival_rank >= 3:
			v3.gear.append(GearItem.make_medical_kit("VANGUARD-MEDKIT"))
		_place(v3, GridPos.new(6, 18))

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
# Gear archive helpers
# ---------------------------------------------------------------------------

func _archive_unit(unit: Unit) -> void:
	var gear_data: Array = []
	for item: GearItem in unit.gear:
		gear_data.append({"item_id": item.item_id, "slot": item.slot, "state": item.state})
	_gear_archive[unit.unit_id] = {"is_leader": unit.is_leader, "gear": gear_data}

func _apply_saved_gear(unit: Unit, saved: Array) -> void:
	for entry in saved:
		if entry.get("unit_id", "") == unit.unit_id:
			for gear_data in entry.get("gear", []):
				for item: GearItem in unit.gear:
					if item.item_id == gear_data.get("item_id", ""):
						item.state = gear_data.get("state", GearItem.GearState.INTACT)
						break
			break

func _apply_starting_fractured_gear(unit: Unit) -> void:
	var lowest_item: GearItem = null
	var lowest_mod := 9999
	for item: GearItem in unit.gear:
		if item.slot != "medical" and item.state == GearItem.GearState.INTACT:
			if item.modifier < lowest_mod:
				lowest_mod = item.modifier
				lowest_item = item
	if lowest_item != null:
		lowest_item.state = GearItem.GearState.FRACTURED

func _build_crew_snapshot() -> Array:
	var snap: Array = []
	for unit_id: String in _gear_archive:
		var entry: Dictionary = _gear_archive[unit_id]
		snap.append({
			"unit_id": unit_id,
			"is_leader": entry.get("is_leader", false),
			"gear": entry.get("gear", []).duplicate()
		})
	return snap

# ---------------------------------------------------------------------------
# Input
# ---------------------------------------------------------------------------

func _input(event: InputEvent) -> void:
	if game_phase != GamePhase.PLAYER_TURN:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_handle_click(event.global_position)

func _handle_click(click_pos: Vector2) -> void:
	var clicked_unit: Unit = _unit_at_screen(click_pos)
	var clicked_grid: GridPos = grid_manager.world_to_grid(click_pos)

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
					if game_phase == GamePhase.GAME_OVER:
						_enter_idle()
						return
					_refresh_highlights()
					if not active_unit.can_act():
						_enter_idle()
				else:
					hud.log("OUT OF RANGE")
			elif not active_unit.has_moved and _is_move_tile(clicked_grid):
				_do_move(active_unit, clicked_grid)
				if game_phase == GamePhase.GAME_OVER:
					_enter_idle()
					return
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
	hud.set_field_patch_visible(_can_field_patch(unit))
	input_state = InputState.ACTING

func _enter_idle() -> void:
	if active_unit:
		active_unit.deselect()
	active_unit = null
	move_tiles = []
	grid_manager.clear_all_highlights()
	hud.show_unit(null)
	hud.set_field_patch_visible(false)
	input_state = InputState.IDLE

func _refresh_highlights() -> void:
	move_tiles = []
	if not active_unit.has_moved:
		var occupied := _occupied_positions(active_unit)
		move_tiles = MovementRange.get_reachable(
			active_unit.grid_pos, active_unit.get_effective_speed(),
			grid_manager, occupied)
		grid_manager.set_move_highlights(move_tiles)
	else:
		grid_manager.set_move_highlights([])

	if not active_unit.has_attacked:
		var atk: Array[GridPos] = []
		for u in units:
			if u.is_player == active_unit.is_player or u.is_downed:
				continue
			if _can_attack(active_unit, u):
				atk.append(u.grid_pos)
		grid_manager.set_attack_highlights(atk)
	else:
		grid_manager.set_attack_highlights([])

	hud.show_unit(active_unit)
	hud.set_field_patch_visible(_can_field_patch(active_unit))

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
	var dx: int = absi(attacker.grid_pos.x - target.grid_pos.x)
	var dy: int = absi(attacker.grid_pos.y - target.grid_pos.y)
	if maxi(dx, dy) > attacker.attack_range:
		return false
	return LOSCalculator.has_los(attacker.grid_pos, target.grid_pos, grid_manager)

func _do_move(unit: Unit, pos: GridPos) -> void:
	unit.place_at(pos, grid_manager)
	unit.has_moved = true
	hud.log("%s → [%d,%d]" % [unit.unit_id, pos.x, pos.y])
	if unit.is_leader and pos.x == EXTRACTION_POS.x and pos.y == EXTRACTION_POS.y:
		hud.log("=== EVIDENCE SECURED — EXTRACTION SUCCESSFUL ===")
		_on_mission_success()

func _do_attack(attacker: Unit, target: Unit) -> void:
	var dmg := attacker.get_weapon_damage()
	var result := CombatResolver.resolve_damage(target, dmg)
	attacker.has_attacked = true
	match result:
		Unit.DamageResult.NORMAL:
			hud.log("%s → %s  -%d TGH  [%d/%d]" % [
				attacker.unit_id, target.unit_id, dmg,
				target.toughness, target.max_toughness])
		Unit.DamageResult.GEAR_FRACTURED:
			var item := _find_gear_by_state(target, GearItem.GearState.FRACTURED)
			var slot_name := item.slot.to_upper() if item else "GEAR"
			hud.log("%s → %s  %s FRACTURED — TGH RESET" % [
				attacker.unit_id, target.unit_id, slot_name])
		Unit.DamageResult.GEAR_BROKEN:
			var item := _find_gear_by_state(target, GearItem.GearState.BROKEN)
			var slot_name := item.slot.to_upper() if item else "GEAR"
			hud.log("%s → %s  %s BROKEN — DOWNED" % [
				attacker.unit_id, target.unit_id, slot_name])
		Unit.DamageResult.DOWNED:
			hud.log("%s → %s  -%d TGH — DOWNED" % [
				attacker.unit_id, target.unit_id, dmg])
	if target.is_downed:
		var leader_fell := _flush_downed()
		if leader_fell:
			hud.log("=== LEADER DOWN — MISSION FAILED ===")
			_on_mission_fail("LEADER DOWNED")
		else:
			_check_game_over()

# ---------------------------------------------------------------------------
# Field Patch
# ---------------------------------------------------------------------------

func _can_field_patch(unit: Unit) -> bool:
	if not unit or not unit.is_player or unit.has_attacked:
		return false
	if not unit.has_medical_kit():
		return false
	for item: GearItem in unit.gear:
		if item.slot != "medical" and item.state == GearItem.GearState.FRACTURED \
				and not item.patched_this_mission:
			return true
	return false

func _on_field_patch() -> void:
	if active_unit == null or not _can_field_patch(active_unit):
		return

	var target_item: GearItem = null
	for item: GearItem in active_unit.gear:
		if item.slot == "armor" and item.state == GearItem.GearState.FRACTURED \
				and not item.patched_this_mission:
			target_item = item
			break
	if target_item == null:
		for item: GearItem in active_unit.gear:
			if item.slot == "weapon" and item.state == GearItem.GearState.FRACTURED \
					and not item.patched_this_mission:
				target_item = item
				break
	if target_item == null:
		return

	var kit_index := -1
	for i in active_unit.gear.size():
		if active_unit.gear[i].slot == "medical":
			kit_index = i
			break
	if kit_index < 0:
		return

	target_item.patched_this_mission = true
	active_unit.gear.remove_at(kit_index)
	active_unit.has_attacked = true
	active_unit.queue_redraw()
	hud.log("%s FIELD-PATCHES %s [MODIFIER PARTIALLY RESTORED]" % [
		active_unit.unit_id, target_item.item_id])
	_refresh_highlights()
	hud.set_field_patch_visible(false)
	if not active_unit.can_act():
		_enter_idle()

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

	var queue: Array[Unit] = []
	for archetype_val in [Unit.Archetype.GUARDIAN, Unit.Archetype.RAMPAGING, Unit.Archetype.TACTICAL]:
		for u in units:
			if not u.is_player and not u.is_downed and u.archetype == archetype_val:
				queue.append(u)

	for enemy in queue:
		if game_phase == GamePhase.GAME_OVER:
			return
		if not is_instance_valid(enemy) or enemy.is_downed:
			continue

		await get_tree().create_timer(0.3).timeout

		var lines: Array[String] = []
		match enemy.archetype:
			Unit.Archetype.GUARDIAN:
				lines = GuardianAI.take_turn(enemy, units, grid_manager)
			Unit.Archetype.RAMPAGING:
				lines = RampagingAI.take_turn(enemy, units, grid_manager)
			Unit.Archetype.TACTICAL:
				lines = TacticalAI.take_turn(enemy, units, grid_manager, round_number)
		for line in lines:
			hud.log(line)

		var leader_fell := _flush_downed()
		if leader_fell:
			hud.log("=== LEADER DOWN — MISSION FAILED ===")
			_on_mission_fail("LEADER DOWNED")
			return
		_check_game_over()
		if game_phase == GamePhase.GAME_OVER:
			return

	if game_phase == GamePhase.GAME_OVER:
		return

	var warned := grid_manager.get_warning_tiles()
	if warned.size() > 0:
		for u: Unit in units.duplicate():
			if u.is_downed:
				continue
			for wp in warned:
				if u.grid_pos.equals(wp):
					var result := CombatResolver.resolve_damage(u, HazardSystem.HAZARD_DAMAGE)
					match result:
						Unit.DamageResult.NORMAL:
							hud.log("[HAZARD] %s  -%d TGH  [%d/%d]" % [
								u.unit_id, HazardSystem.HAZARD_DAMAGE,
								u.toughness, u.max_toughness])
						Unit.DamageResult.GEAR_FRACTURED:
							hud.log("[HAZARD] %s  GEAR FRACTURED — TGH RESET" % u.unit_id)
						Unit.DamageResult.GEAR_BROKEN, Unit.DamageResult.DOWNED:
							hud.log("[HAZARD] %s DOWNED" % u.unit_id)
					break
		grid_manager.clear_warning_tiles()
		var leader_fell2 := _flush_downed()
		if leader_fell2:
			hud.log("=== LEADER DOWN — MISSION FAILED ===")
			_on_mission_fail("LEADER DOWNED")
			return
		_check_game_over()
		if game_phase == GamePhase.GAME_OVER:
			return

	await get_tree().create_timer(0.4).timeout

	round_number += 1
	if round_number > ROUND_LIMIT:
		hud.log("=== ROUND LIMIT REACHED — MISSION FAILED ===")
		_on_mission_fail("ROUND LIMIT EXPIRED")
		return

	for u in units:
		if not u.is_downed:
			u.has_moved = false
			u.has_attacked = false
			u.queue_redraw()

	var next_zone := hazard_manager.get_active_zone(round_number)
	if next_zone.size() > 0:
		grid_manager.set_warning_tiles(next_zone)
		hud.log("[WARNING] HAZARD ZONE ACTIVE — CLEAR THE AREA")

	game_phase = GamePhase.PLAYER_TURN
	hud.set_phase(true)
	hud.set_round(round_number)
	hud.log("--- ROUND %d — PLAYER TURN ---" % round_number)

# Returns true if the player leader was among those flushed.
func _flush_downed() -> bool:
	var leader_fell := false
	var to_remove: Array[Unit] = []
	for u in units:
		if u.is_downed:
			to_remove.append(u)
			if u.is_player and u.is_leader:
				leader_fell = true
	for u in to_remove:
		if u.is_player:
			_archive_unit(u)
		elif u.archetype == Unit.Archetype.TACTICAL:
			for item: GearItem in u.gear:
				if item.state == GearItem.GearState.BROKEN:
					dropped_loot.append(item)
					hud.log("[LOOT] %s DROPPED" % item.item_id)
		units.erase(u)
		u.queue_free()
	return leader_fell

# ---------------------------------------------------------------------------
# Game-over detection
# ---------------------------------------------------------------------------

func _check_game_over() -> void:
	var players_up := 0
	var enemies_up := 0
	for u in units:
		if u.is_player:
			players_up += 1
		else:
			enemies_up += 1

	if enemies_up == 0:
		hud.log("=== AREA CLEAR — CONTAINMENT BREACH COMPLETE ===")
		_on_mission_success()
	elif players_up == 0:
		hud.log("=== ALL CREW DOWN — MISSION FAILED ===")
		_on_mission_fail("ALL CREW DOWN")

# ---------------------------------------------------------------------------
# Mission outcome
# ---------------------------------------------------------------------------

func _on_mission_success() -> void:
	game_phase = GamePhase.GAME_OVER
	for u in _get_player_units():
		_archive_unit(u)
	var gs: Node = get_node("/root/GameState")
	var sm: Node = get_node("/root/SaveManager")
	gs.crew = _build_crew_snapshot()
	gs.credits += DANGER_PAY
	gs.pending_loot = dropped_loot
	gs.last_mission_result = {
		"success": true,
		"fail_reason": "",
		"danger_pay": DANGER_PAY,
		"rival_rank": rival_rank,
	}
	sm.save()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/PostMissionScreen.tscn")

func _on_mission_fail(reason: String) -> void:
	game_phase = GamePhase.GAME_OVER
	rival_rank += 1
	hud.log("VANGUARD RANK NOW %d" % rival_rank)

	for u in _get_player_units():
		for item: GearItem in u.gear:
			if item.state == GearItem.GearState.INTACT:
				item.state = GearItem.GearState.FRACTURED
		_archive_unit(u)

	for unit_id: String in _gear_archive:
		for item_data: Dictionary in _gear_archive[unit_id]["gear"]:
			if item_data.get("state", GearItem.GearState.INTACT) == GearItem.GearState.INTACT:
				item_data["state"] = GearItem.GearState.FRACTURED

	var gs: Node = get_node("/root/GameState")
	var sm: Node = get_node("/root/SaveManager")
	gs.crew = _build_crew_snapshot()
	gs.vanguard_rank = rival_rank
	gs.pending_loot = dropped_loot
	gs.last_mission_result = {
		"success": false,
		"fail_reason": reason,
		"danger_pay": 0,
		"rival_rank": rival_rank,
	}
	sm.save()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/PostMissionScreen.tscn")

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

func _get_player_units() -> Array:
	var result: Array = []
	for u in units:
		if u.is_player:
			result.append(u)
	return result

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

func _find_gear_by_state(unit: Unit, state: int) -> GearItem:
	for item: GearItem in unit.gear:
		if item.state == state:
			return item
	return null
