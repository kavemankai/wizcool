class_name RampagingAI
extends RefCounted

# Charge the nearest unit each turn regardless of faction.
# No zone boundary. Ignores hazard warning tiles by design.

static func take_turn(unit: Unit, all_units: Array[Unit], grid: GridManager,
		cutaway_queue: Object = null) -> Array[String]:
	var log: Array[String] = []

	var target := EnemyAI.nearest_unit(unit, all_units)
	if target == null:
		log.append("%s RAMPAGES — NO TARGET" % unit.unit_id)
		return log

	# Weapon specials are intentionally ignored — Rampaging AI does not use abilities.

	# Move toward target — no zone restriction, no hazard avoidance
	if not unit.has_moved:
		# Apply Suppressed move penalty if afflicted
		var effective_move: int = unit.get_effective_speed()
		if EnemyAI.unit_has_status(unit, StatusEffect.Type.SUPPRESSED):
			effective_move = max(1, effective_move - CombatConstants.SUPPRESSED_MOVE_PENALTY)
			log.append("%s SUPPRESSED — MOVE REDUCED TO %d" % [unit.unit_id, effective_move])

		var occupied := EnemyAI.occupied_positions(all_units, unit)
		var reachable := MovementRange.get_reachable(
			unit.grid_pos, effective_move, grid, occupied)

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
		var result := EnemyAI.do_attack(unit, target, grid, cutaway_queue)
		if result >= 0:
			var suffix := ""
			if result == Unit.DamageResult.GEAR_FRACTURED:
				suffix = " [GEAR FRACTURED]"
			elif result == Unit.DamageResult.GEAR_BROKEN or result == Unit.DamageResult.DOWNED:
				suffix = " [DOWNED]"
			log.append("%s ATTACKS %s  [%d/%d]%s" % [
				unit.unit_id, target.unit_id,
				target.toughness, target.max_toughness, suffix])
	elif not unit.has_attacked:
		log.append("%s CHARGES %s — OUT OF RANGE" % [unit.unit_id, target.unit_id])

	return log
