class_name GuardianAI
extends RefCounted

# Patrol a fixed waypoint loop. Stop and attack when a player enters LOS.
# Does not pursue or move outside zone_min_row / zone_max_row.

static func take_turn(unit: Unit, all_units: Array[Unit], grid: GridManager,
		cutaway_queue: Object = null) -> Array[String]:
	var log: Array[String] = []
	var visible := _nearest_player_in_los(unit, all_units, grid)

	if visible != null:
		unit.is_alerted = true
		_pursue_and_attack(unit, visible, all_units, grid, log, cutaway_queue)
	else:
		unit.is_alerted = false
		_patrol_step(unit, all_units, grid, log)

	return log

static func _pursue_and_attack(
		unit: Unit, target: Unit,
		all_units: Array[Unit], grid: GridManager,
		log: Array[String], cutaway_queue: Object = null) -> void:
	var warning := grid.get_warning_tiles()
	if not unit.has_moved:
		if not EnemyAI.can_attack(unit, target, grid):
			var dest := EnemyAI.best_move_toward(unit, target.grid_pos, all_units, grid, true, warning)
			if not dest.equals(unit.grid_pos):
				EnemyAI.move_to(unit, dest, grid)
				log.append("%s MOVES → [%d,%d]" % [unit.unit_id, dest.x, dest.y])

	if EnemyAI.can_attack(unit, target, grid):
		var result := EnemyAI.do_attack(unit, target, cutaway_queue)
		if result >= 0:
			log.append("%s ATTACKS %s  [%d/%d]%s" % [
				unit.unit_id, target.unit_id,
				target.toughness, target.max_toughness, _attack_suffix(result)])
	else:
		log.append("%s SIGHTS %s — OUT OF RANGE" % [unit.unit_id, target.unit_id])

static func _patrol_step(
		unit: Unit,
		all_units: Array[Unit], grid: GridManager,
		log: Array[String]) -> void:
	if unit.patrol_path.is_empty():
		log.append("%s HOLDS" % unit.unit_id)
		return

	var wp := unit.patrol_path[unit.patrol_index]

	if unit.grid_pos.equals(wp):
		unit.patrol_index = (unit.patrol_index + 1) % unit.patrol_path.size()
		wp = unit.patrol_path[unit.patrol_index]

	var warning := grid.get_warning_tiles()
	var dest := EnemyAI.best_move_toward(unit, wp, all_units, grid, true, warning)
	if not dest.equals(unit.grid_pos):
		EnemyAI.move_to(unit, dest, grid)
		log.append("%s PATROLS → [%d,%d]" % [unit.unit_id, dest.x, dest.y])

		if unit.grid_pos.equals(unit.patrol_path[unit.patrol_index]):
			unit.patrol_index = (unit.patrol_index + 1) % unit.patrol_path.size()
	else:
		log.append("%s HOLDS (BLOCKED)" % unit.unit_id)

static func _nearest_player_in_los(unit: Unit, all_units: Array[Unit], grid: GridManager) -> Unit:
	var nearest: Unit = null
	var best := 9999
	for u in all_units:
		if not u.is_player or u.is_downed:
			continue
		if LOSCalculator.has_los(unit.grid_pos, u.grid_pos, grid):
			var d := EnemyAI.chebyshev(unit.grid_pos, u.grid_pos)
			if d < best:
				best = d
				nearest = u
	return nearest

static func _attack_suffix(result: int) -> String:
	if result == Unit.DamageResult.GEAR_FRACTURED:
		return " [GEAR FRACTURED]"
	if result == Unit.DamageResult.GEAR_BROKEN or result == Unit.DamageResult.DOWNED:
		return " [DOWNED]"
	return ""
