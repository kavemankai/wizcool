extends Node2D

enum GamePhase { PLAYER_TURN, ENEMY_TURN, GAME_OVER }
enum InputState { IDLE, ACTING, ABILITY_TARGETING }

const ROUND_LIMIT: int = 20

var _mission: Dictionary = {}
var _objective_type: int = CampaignData.ObjectiveType.EXTRACTION
var _objective_data: Dictionary = {}
var _item_collected: bool = false
var _survive_rounds: int = 8

var units: Array[Unit] = []
var game_phase: GamePhase = GamePhase.PLAYER_TURN
var input_state: InputState = InputState.IDLE
var active_unit: Unit = null
var move_tiles: Array[GridPos] = []
var round_number: int = 1
var dropped_loot: Array[GearItem] = []
var rival_rank: int = 1
var hazard_manager: HazardSystem = null
var _skip_requested: bool = false
var _show_cutaway: bool = true
var _debug_mode: bool = false

# Vanguard reinforcement timing. A mission may defer the Vanguard so they
# arrive mid-mission instead of at the start. vanguard_spawn_turn <= 1 means
# they deploy immediately (the default for most missions).
var _vanguard_spawn_turn: int = 1
var _vanguard_deployed: bool = false

# unit_id → {is_leader: bool, gear: [{item_id, slot, state: int (GearState enum)}]}
var _gear_archive: Dictionary = {}

@onready var grid_manager: GridManager = $GridManager
@onready var unit_layer: Node2D = $UnitLayer
@onready var hud: HUD = $HUD
@onready var cutaway: CombatCutaway = $CombatCutaway

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
	hud.skip_pressed.connect(func() -> void: _skip_requested = true)
	hud.ability_pressed.connect(_on_ability_pressed)
	hud.cutaway_toggled.connect(func(on: bool) -> void: _show_cutaway = on)
	hud.debug_toggled.connect(func(on: bool) -> void: _debug_mode = on)

	var gs := GameState
	_mission = CampaignData.get_mission(gs.current_campaign_id, gs.current_mission_index)
	_objective_type = _mission.get("objective", CampaignData.ObjectiveType.EXTRACTION)
	_objective_data = _mission.get("objective_data", {})
	_survive_rounds = _objective_data.get("survive_rounds", 8)

	grid_manager.load_map(_mission.get("map_id", "map-prototype"))

	match _objective_type:
		CampaignData.ObjectiveType.EXTRACTION:
			var t: Vector2i = _objective_data.get("target_tile", Vector2i(5, 2))
			grid_manager.set_extraction_tile(GridPos.new(t.x, t.y))
		CampaignData.ObjectiveType.RETRIEVE:
			var item_pos: Vector2i = _objective_data.get("item_tile", Vector2i(5, 5))
			grid_manager.set_extraction_tile(GridPos.new(item_pos.x, item_pos.y))

	hazard_manager = HazardSystem.new()
	rival_rank = gs.vanguard_rank

	_spawn_units_from_mission()

	var camp := CampaignData.get_campaign(gs.current_campaign_id)
	var mission_count := CampaignData.get_mission_count(gs.current_campaign_id)
	hud.set_round(round_number)
	hud.log("[%s — MISSION %d/%d: %s]" % [
		camp.get("title", ""),
		gs.current_mission_index + 1,
		mission_count,
		_mission.get("title", "")
	])
	hud.log("OBJECTIVE: " + _mission.get("hud_objective", ""))
	hud.log("[ROUND 1 — PLAYER TURN]")

# ---------------------------------------------------------------------------
# Unit setup
# ---------------------------------------------------------------------------

func _spawn_units_from_mission() -> void:
	var saved_gear: Array = GameState.crew
	var player_spawns: Array = _mission.get("player_spawns", [])

	var alpha_pos := _get_spawn_pos(player_spawns, "ALPHA",   Vector2i(5, 17))
	var bravo_pos := _get_spawn_pos(player_spawns, "BRAVO",   Vector2i(3, 16))
	var charlie_pos := _get_spawn_pos(player_spawns, "CHARLIE", Vector2i(7, 16))

	var alpha := _make_unit("ALPHA", true, true, 6, 2, 3, 4)
	alpha.gear.append(GearItem.make_weapon("PLASMA-CUTTER", 2, 3))
	alpha.gear.back().special = WeaponSpecial.make(WeaponSpecial.SpecialType.ARC_PULSE)
	alpha.gear.append(GearItem.make_medical_kit("FIELD-PATCH-KIT"))
	_place(alpha, GridPos.new(alpha_pos.x, alpha_pos.y))
	_apply_saved_gear(alpha, saved_gear)
	if saved_gear.is_empty():
		_apply_starting_fractured_gear(alpha)
	_archive_unit(alpha)

	var bravo := _make_unit("BRAVO", true, false, 5, 2, 4, 2)
	bravo.gear.append(GearItem.make_weapon("IMPACT-WRENCH", 1, 2))
	bravo.gear.back().special = WeaponSpecial.make(WeaponSpecial.SpecialType.BRACE)
	bravo.gear.append(GearItem.make_armor("WORK-HARNESS", 1))
	_place(bravo, GridPos.new(bravo_pos.x, bravo_pos.y))
	_apply_saved_gear(bravo, saved_gear)
	_archive_unit(bravo)

	var charlie := _make_unit("CHARLIE", true, false, 4, 3, 3, 5)
	charlie.gear.append(GearItem.make_weapon("LONG-BORE-DRILL", 1, 2))
	charlie.gear.back().special = WeaponSpecial.make(WeaponSpecial.SpecialType.CORROSIVE_BURST)
	_place(charlie, GridPos.new(charlie_pos.x, charlie_pos.y))
	_apply_saved_gear(charlie, saved_gear)
	_archive_unit(charlie)

	for ec: Dictionary in _mission.get("enemy_config", []):
		_spawn_enemy_from_config(ec)

	_vanguard_spawn_turn = _mission.get("vanguard_spawn_turn", 1)
	if _vanguard_spawn_turn <= 1:
		_spawn_vanguard()
		_vanguard_deployed = true

func _get_spawn_pos(spawns: Array, unit_id: String, default_pos: Vector2i) -> Vector2i:
	for s: Dictionary in spawns:
		if s.get("id", "") == unit_id:
			return s.get("pos", default_pos)
	return default_pos

func _spawn_enemy_from_config(ec: Dictionary) -> void:
	var e := _make_unit(ec["id"], false, false, ec["hp"], ec["cs"], ec["spd"], ec["rng"])
	e.archetype = ec["archetype"]
	match e.archetype:
		Unit.Archetype.GUARDIAN:
			e.zone_min_row = ec.get("zone_min", -1)
			e.zone_max_row = ec.get("zone_max", -1)
			for pv: Vector2i in ec.get("patrol", []):
				e.patrol_path.append(GridPos.new(pv.x, pv.y))
		Unit.Archetype.TACTICAL:
			e.advance_triggered = false
	for g: Dictionary in ec.get("gear", []):
		match g.get("slot", ""):
			"weapon":
				e.gear.append(GearItem.make_weapon(g["id"], g.get("mod", 1), g.get("rng", 2)))
				if e.archetype == Unit.Archetype.GUARDIAN:
					e.gear.back().special = WeaponSpecial.make(WeaponSpecial.SpecialType.SUPPRESSING_FIRE)
			"armor":   e.gear.append(GearItem.make_armor(g["id"], g.get("mod", 1)))
			"medical": e.gear.append(GearItem.make_medical_kit(g["id"]))
	var pos: Vector2i = ec.get("pos", Vector2i(5, 10))
	_place(e, GridPos.new(pos.x, pos.y))

func _spawn_vanguard() -> void:
	var vspawns: Array = _mission.get("vanguard_spawns", [])
	if vspawns.is_empty():
		return
	var count := 2 if rival_rank == 1 else 3
	var to_spawn := mini(count, vspawns.size())
	for i in to_spawn:
		var vs: Dictionary = vspawns[i]
		var vpos: Vector2i = vs.get("pos", Vector2i(5, 18))
		var v := _make_unit("VANGUARD-%d" % (i + 1), false, false, 5, 2, 2, 3)
		v.archetype = Unit.Archetype.TACTICAL
		v.zone_min_row = vs.get("zone_min", 14)
		v.zone_max_row = vs.get("zone_max", 18)
		v.vanguard_rank = rival_rank
		if i == 1 and rival_rank >= 2:
			v.gear.append(GearItem.make_armor("BALLISTIC-PLATE", 1))
		if i == 2 and rival_rank >= 3:
			v.gear.append(GearItem.make_medical_kit("VANGUARD-MEDKIT"))
		v.gear.append(GearItem.make_weapon("SALVAGE-PISTOL", 1, 2))
		v.gear.back().special = WeaponSpecial.make(WeaponSpecial.SpecialType.SUPPRESSING_FIRE)
		_place(v, GridPos.new(vpos.x, vpos.y))

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
	_update_unit_cover(unit)

func _update_unit_cover(unit: Unit) -> void:
	var cover := CoverSystem.get_cover_type(unit.grid_pos, grid_manager)
	if cover != unit.cover_type:
		unit.cover_type = cover
		match cover:
			CoverSystem.CoverType.LIGHT: unit.cover_integrity = CombatConstants.COVER_INTEGRITY_LIGHT
			CoverSystem.CoverType.HEAVY: unit.cover_integrity = CombatConstants.COVER_INTEGRITY_HEAVY
			_: unit.cover_integrity = 0

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

	if clicked_unit != null and not clicked_unit.is_downed:
		hud.show_unit(clicked_unit)
	elif clicked_unit == null and input_state == InputState.IDLE:
		hud.show_unit(null)

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
					await _do_attack(active_unit, clicked_unit)
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

		InputState.ABILITY_TARGETING:
			if clicked_unit != null and not clicked_unit.is_player \
					and not clicked_unit.is_downed and _can_attack(active_unit, clicked_unit):
				_do_ability(active_unit, clicked_unit)
				if game_phase == GamePhase.GAME_OVER:
					_enter_idle()
					return
				input_state = InputState.ACTING
				_refresh_highlights()
				if not active_unit.can_act():
					_enter_idle()
			else:
				# Tapped a non-target — cancel ability targeting, back to ACTING.
				hud.log("ABILITY CANCELLED")
				input_state = InputState.ACTING
				_refresh_highlights()

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
	hud.set_ability_visible(false)
	hud.set_precision_indicator(false)
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
		var any_precision := false
		for u in units:
			if u.is_player == active_unit.is_player or u.is_downed:
				continue
			if _can_attack(active_unit, u):
				atk.append(u.grid_pos)
				if PrecisionStrike.can_use(active_unit, u):
					any_precision = true
		grid_manager.set_attack_highlights(atk)
		hud.set_precision_indicator(any_precision)
	else:
		grid_manager.set_attack_highlights([])
		hud.set_precision_indicator(false)

	hud.show_unit(active_unit)
	hud.set_field_patch_visible(_can_field_patch(active_unit))
	if _can_use_ability(active_unit):
		hud.set_ability_visible(true, _get_unit_special(active_unit).get_label())
	else:
		hud.set_ability_visible(false)

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
	var old_pos := unit.grid_pos
	unit.place_at(pos, grid_manager)
	unit.has_moved = true
	# Update facing direction
	var dx := pos.x - old_pos.x
	var dy := pos.y - old_pos.y
	if dx != 0 or dy != 0:
		unit.facing = Vector2i(signi(dx), signi(dy))
	# Update cover state for new position
	_update_unit_cover(unit)
	hud.log("%s → [%d,%d]" % [unit.unit_id, pos.x, pos.y])
	if not unit.is_leader:
		return
	match _objective_type:
		CampaignData.ObjectiveType.EXTRACTION:
			var target: Vector2i = _objective_data.get("target_tile", Vector2i(-1, -1))
			if pos.x == target.x and pos.y == target.y:
				hud.log("=== EXTRACTION SUCCESSFUL ===")
				_on_mission_success()
		CampaignData.ObjectiveType.RETRIEVE:
			var item_pos: Vector2i = _objective_data.get("item_tile", Vector2i(-1, -1))
			var extract_pos: Vector2i = _objective_data.get("extract_tile", Vector2i(-1, -1))
			if not _item_collected and pos.x == item_pos.x and pos.y == item_pos.y:
				_item_collected = true
				grid_manager.set_extraction_tile(GridPos.new(extract_pos.x, extract_pos.y))
				hud.log("=== EVIDENCE RECOVERED — REACH EXTRACTION POINT ===")
			elif _item_collected and pos.x == extract_pos.x and pos.y == extract_pos.y:
				hud.log("=== VEHICLE BAY REACHED — GETAWAY SUCCESSFUL ===")
				_on_mission_success()

func _do_attack(attacker: Unit, target: Unit) -> void:
	var pre_tgh := target.toughness
	var dmg: int
	var result: int
	if _debug_mode and not target.is_player:
		dmg = target.max_toughness
		target.toughness = 0
		target.is_downed = true
		target.queue_redraw()
		result = Unit.DamageResult.DOWNED
	else:
		var is_precision := PrecisionStrike.can_use(attacker, target)
		if is_precision:
			dmg = PrecisionStrike.get_damage(attacker)
			result = CombatResolver.resolve_damage_ex(attacker, target, dmg, true, grid_manager)
			CombatResolver.apply_status(target, StatusEffect.Type.SUPPRESSED)
			hud.set_precision_indicator(false)
		else:
			dmg = attacker.get_weapon_damage()
			result = CombatResolver.resolve_damage_ex(attacker, target, dmg, false, grid_manager)
		# Chip cover integrity on each hit
		if target.cover_integrity > 0:
			target.cover_integrity -= 1
			if target.cover_integrity == 0:
				grid_manager.damage_cover_at(target.grid_pos)
				target.cover_type = CoverSystem.CoverType.NONE
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
	if _show_cutaway:
		cutaway.queue_event(attacker, target, dmg, result, pre_tgh)
		await cutaway.play_pending()
	if target.is_downed:
		var leader_fell := _flush_downed()
		if leader_fell:
			hud.log("=== LEADER DOWN — MISSION FAILED ===")
			_on_mission_fail("LEADER DOWNED")
		else:
			_check_game_over()

# ---------------------------------------------------------------------------
# Weapon special abilities (player-activated)
# ---------------------------------------------------------------------------

## Returns the equipped weapon's WeaponSpecial, or null if none.
func _get_unit_special(unit: Unit) -> WeaponSpecial:
	if unit == null:
		return null
	for item: GearItem in unit.gear:
		if item.slot == "weapon" and item.special != null:
			return item.special
	return null

## True when the unit can fire its weapon special right now.
func _can_use_ability(unit: Unit) -> bool:
	if unit == null or not unit.is_player or unit.has_attacked:
		return false
	if unit.has_status(StatusEffect.Type.OVERLOADED):
		return false
	var sp := _get_unit_special(unit)
	return sp != null and sp.is_ready()

## ABILITY button pressed. Self-target abilities fire immediately; targeted
## abilities enter ABILITY_TARGETING so the player taps a valid enemy.
func _on_ability_pressed() -> void:
	if active_unit == null or not _can_use_ability(active_unit):
		return
	var sp := _get_unit_special(active_unit)
	if sp.type == WeaponSpecial.SpecialType.BRACE:
		_do_brace(active_unit, sp)
		_refresh_highlights()
		if not active_unit.can_act():
			_enter_idle()
		return
	# Targeted ability — highlight valid enemies and wait for a tap.
	var targets: Array[GridPos] = []
	for u in units:
		if u.is_player or u.is_downed:
			continue
		if _can_attack(active_unit, u):
			targets.append(u.grid_pos)
	if targets.is_empty():
		hud.log("NO TARGET IN RANGE FOR %s" % sp.get_label())
		return
	input_state = InputState.ABILITY_TARGETING
	grid_manager.set_move_highlights([])
	grid_manager.set_attack_highlights(targets)
	hud.set_ability_visible(false)
	hud.set_field_patch_visible(false)
	hud.set_precision_indicator(false)
	hud.log("SELECT TARGET — %s" % sp.get_label())

## Dispatch a targeted ability against the tapped enemy.
func _do_ability(attacker: Unit, target: Unit) -> void:
	var sp := _get_unit_special(attacker)
	if sp == null:
		return
	match sp.type:
		WeaponSpecial.SpecialType.ARC_PULSE:
			_do_arc_pulse(attacker, target, sp)
		WeaponSpecial.SpecialType.CORROSIVE_BURST:
			_do_corrosive_burst(attacker, target, sp)
		_:
			# SUPPRESSING_FIRE or any other targeted special: damage + suppress.
			_do_arc_pulse(attacker, target, sp)
	_resolve_post_action()

func _do_arc_pulse(attacker: Unit, target: Unit, sp: WeaponSpecial) -> void:
	var dmg := CombatConstants.ARC_PULSE_DAMAGE
	CombatResolver.resolve_damage_ex(attacker, target, dmg, false, grid_manager)
	CombatResolver.apply_status(target, StatusEffect.Type.SUPPRESSED)
	var chained := 0
	for u in units:
		if u == target or u.is_player or u.is_downed:
			continue
		var d: int = maxi(absi(u.grid_pos.x - target.grid_pos.x), absi(u.grid_pos.y - target.grid_pos.y))
		if d <= CombatConstants.ARC_PULSE_CHAIN_RADIUS:
			CombatResolver.apply_status(u, StatusEffect.Type.SUPPRESSED)
			chained += 1
	attacker.has_attacked = true
	sp.activate()
	AudioManager.play_sfx("weapon_plasma_cutter")
	var suffix := "  [+%d CHAINED]" % chained if chained > 0 else ""
	hud.log("%s ARC PULSE → %s  -%d TGH  [SUPPRESSED]%s" % [
		attacker.unit_id, target.unit_id, dmg, suffix])

func _do_corrosive_burst(attacker: Unit, target: Unit, sp: WeaponSpecial) -> void:
	var dmg := CombatConstants.CORROSIVE_BURST_DAMAGE
	CombatResolver.resolve_damage_ex(attacker, target, dmg, false, grid_manager)
	CombatResolver.apply_status(target, StatusEffect.Type.CORRODED)
	attacker.has_attacked = true
	sp.activate()
	AudioManager.play_sfx("weapon_long_bore_drill")
	hud.log("%s CORROSIVE BURST → %s  -%d TGH  [CORRODED]" % [
		attacker.unit_id, target.unit_id, dmg])

func _do_brace(unit: Unit, sp: WeaponSpecial) -> void:
	sp.activate()  # sets is_braced + starts cooldown
	unit.has_attacked = true
	AudioManager.play_sfx("weapon_impact_wrench")
	hud.log("%s BRACES — NEXT INCOMING HIT REDUCED BY %d" % [
		unit.unit_id, CombatConstants.BRACE_DAMAGE_REDUCTION])

## Flush downed units and resolve mission/game-over after an offensive action.
func _resolve_post_action() -> void:
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
	AudioManager.crossfade_to_tension()
	hud.set_phase(false)
	hud.set_skip_visible(true)
	_skip_requested = false
	hud.log("--- ENEMY PHASE ---")

	var queue: Array[Unit] = []
	for archetype_val in [Unit.Archetype.GUARDIAN, Unit.Archetype.RAMPAGING, Unit.Archetype.TACTICAL]:
		for u in units:
			if not u.is_player and not u.is_downed and u.archetype == archetype_val:
				queue.append(u)

	for enemy in queue:
		if game_phase == GamePhase.GAME_OVER:
			break
		if not is_instance_valid(enemy) or enemy.is_downed:
			continue

		await get_tree().create_timer(0.0 if _skip_requested else 0.8).timeout

		if game_phase == GamePhase.GAME_OVER:
			break
		if not is_instance_valid(enemy) or enemy.is_downed:
			continue

		enemy.tick_turn_start()
		enemy.is_acting = true
		enemy.queue_redraw()
		hud.show_unit(enemy)

		var cq: Object = null if (_skip_requested or not _show_cutaway) else cutaway
		var lines: Array[String] = []
		match enemy.archetype:
			Unit.Archetype.GUARDIAN:
				lines = GuardianAI.take_turn(enemy, units, grid_manager, cq)
			Unit.Archetype.RAMPAGING:
				lines = RampagingAI.take_turn(enemy, units, grid_manager, cq)
			Unit.Archetype.TACTICAL:
				lines = TacticalAI.take_turn(enemy, units, grid_manager, round_number, cq)
		for line in lines:
			hud.log(line)

		if is_instance_valid(enemy):
			enemy.is_acting = false
			enemy.queue_redraw()

		if not _skip_requested and _show_cutaway and cutaway.has_pending():
			await cutaway.play_pending()
		elif cutaway.has_pending():
			cutaway.clear_pending()

		var leader_fell := _flush_downed()
		if leader_fell:
			hud.log("=== LEADER DOWN — MISSION FAILED ===")
			hud.set_skip_visible(false)
			_on_mission_fail("LEADER DOWNED")
			return
		_check_game_over()
		if game_phase == GamePhase.GAME_OVER:
			break

	hud.set_skip_visible(false)
	var skip_was_requested := _skip_requested
	_skip_requested = false

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

	await get_tree().create_timer(0.0 if skip_was_requested else 0.4).timeout

	round_number += 1

	if _objective_type == CampaignData.ObjectiveType.SURVIVAL and round_number > _survive_rounds:
		hud.log("=== CORRIDOR HELD — DOORS CUT — BREAKOUT SUCCESSFUL ===")
		_on_mission_success()
		return

	if round_number > ROUND_LIMIT:
		hud.log("=== ROUND LIMIT REACHED — MISSION FAILED ===")
		_on_mission_fail("ROUND LIMIT EXPIRED")
		return

	for u in units:
		if not u.is_downed:
			u.has_moved = false
			u.has_attacked = false
			if u.is_player:
				u.tick_turn_start()
			u.queue_redraw()

	# Deferred Vanguard reinforcements — they cut in from the tip of the map
	# on their scheduled round (e.g. cb-1 arrivals on round 3).
	if not _vanguard_deployed and round_number >= _vanguard_spawn_turn:
		_spawn_vanguard()
		_vanguard_deployed = true
		hud.log("[VANGUARD SALVAGE CO. // REINFORCEMENTS INBOUND — TOP OF SITE]")

	var next_zone := hazard_manager.get_active_zone(round_number)
	if next_zone.size() > 0:
		grid_manager.set_warning_tiles(next_zone)
		hud.log("[WARNING] HAZARD ZONE ACTIVE — CLEAR THE AREA")

	game_phase = GamePhase.PLAYER_TURN
	AudioManager.crossfade_to_calm()
	hud.set_phase(true)
	hud.set_round(round_number)
	hud.log("--- ROUND %d — PLAYER TURN ---" % round_number)

# Returns true if the player leader was among those flushed.
func _flush_downed() -> bool:
	var leader_fell := false
	var to_remove: Array[Unit] = []
	for u in units:
		if u.is_downed:
			if _debug_mode and u.is_player:
				u.is_downed = false
				u.toughness = u.max_toughness
				u.queue_redraw()
				hud.log("[DEBUG] %s revived" % u.unit_id)
				continue
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

	if players_up == 0:
		hud.log("=== ALL CREW DOWN — MISSION FAILED ===")
		_on_mission_fail("ALL CREW DOWN")
	elif enemies_up == 0:
		if _objective_type == CampaignData.ObjectiveType.ELIMINATION:
			hud.log("=== AREA CLEAR — ALL GUARDS ELIMINATED ===")
			_on_mission_success()
		elif _objective_type == CampaignData.ObjectiveType.SURVIVAL:
			hud.log("--- ALL ENEMIES DOWN — HOLD UNTIL DOORS CUT ---")

# ---------------------------------------------------------------------------
# Mission outcome
# ---------------------------------------------------------------------------

func _on_mission_success() -> void:
	game_phase = GamePhase.GAME_OVER
	AudioManager.play_sfx("mission_complete")
	for u in _get_player_units():
		_archive_unit(u)
	var gs := GameState
	var sm := SaveManager
	gs.crew = _build_crew_snapshot()
	gs.pending_loot = dropped_loot

	var mission_count := CampaignData.get_mission_count(gs.current_campaign_id)
	var campaign_complete: bool = (gs.current_mission_index + 1 >= mission_count)
	var danger_pay: int = 0

	if campaign_complete:
		var camp := CampaignData.get_campaign(gs.current_campaign_id)
		danger_pay = camp.get("danger_pay", 0)
		gs.credits += danger_pay
		gs.campaigns_completed += 1
		gs.vanguard_rank += 1
		rival_rank = gs.vanguard_rank
		hud.log("=== CAMPAIGN COMPLETE — DANGER PAY: +%d CR ===" % danger_pay)
		hud.log("VANGUARD RANK NOW %d" % gs.vanguard_rank)
		# Advance to next campaign
		if gs.current_campaign_id == "containment-breach":
			gs.current_campaign_id = "prison-break"
		gs.current_mission_index = 0
	else:
		gs.current_mission_index += 1

	gs.last_mission_result = {
		"success": true,
		"fail_reason": "",
		"danger_pay": danger_pay,
		"rival_rank": gs.vanguard_rank,
		"campaign_complete": campaign_complete,
	}
	sm.save()
	await get_tree().create_timer(1.5).timeout
	get_tree().change_scene_to_file("res://scenes/ui/PostMissionScreen.tscn")

func _on_mission_fail(reason: String) -> void:
	game_phase = GamePhase.GAME_OVER
	AudioManager.play_sfx("mission_fail")
	for u in _get_player_units():
		_archive_unit(u)
	var gs := GameState
	var sm := SaveManager
	gs.crew = _build_crew_snapshot()
	gs.pending_loot = dropped_loot
	# Gear fracture and rank change happen ONLY on Abandon (handled in PostMissionScreen)
	gs.last_mission_result = {
		"success": false,
		"fail_reason": reason,
		"danger_pay": 0,
		"rival_rank": gs.vanguard_rank,
		"campaign_complete": false,
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
