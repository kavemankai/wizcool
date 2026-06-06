class_name RampagingAI
extends RefCounted

# Charge the nearest unit each turn regardless of faction.
# No zone boundary. Will attack Vanguard if closer than player units.

static func take_turn(unit: Unit, all_units: Array[Unit], grid: GridManager) -> Array[String]:
	var log: Array[String] = []

	# Target nearest unit of any faction (excludes self and downed)
	var target := EnemyAI.nearest_unit(unit, all_units)
	if target == null:
		log.append("%s RAMPAGES — NO TARGET" % unit.unit_id)
		return log

	# Move toward target — no zone restriction
	if not unit.has_moved:
		var occupied := EnemyAI.occupied_positions(all_units, unit)
		var reachable := MovementRange.get_reachable(
			unit.grid_pos, unit.get_effective_speed(), grid, occupied)

		var best := unit.grid_pos
		var best_dist := EnemyAI.chebyshev(unit.grid_pos, target.grid_pos)
		for pos in reachable:
			var d := EnemyAI.chebyshev(pos, target.grid_pos)
			if d < best_dist:
				best_dist = d
				best = pos

		if not best.equals(unit.grid_pos):
			EnemyAI.move_to(unit, best, grid)
			log.append("%s CHARGES → [%d,%d]" % [unit.unit_id, best.x, best.y])

	# Attack if in range
	if not unit.has_attacked and EnemyAI.can_attack(unit, target, grid):
		var dmg := EnemyAI.do_attack(unit, target)
		if dmg > 0:
			log.append("%s ATTACKS %s  -%d TGH  [%d/%d]" % [
				unit.unit_id, target.unit_id, dmg,
				target.toughness, target.max_toughness])
	elif not unit.has_attacked:
		log.append("%s CHARGES %s — OUT OF RANGE" % [unit.unit_id, target.unit_id])

	return log
