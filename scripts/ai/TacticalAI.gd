class_name TacticalAI
extends RefCounted

# Holds in Zone A. Advances when triggered by rank-based conditions or player weakness.
# Priority target: the leader. Tracks last known leader position.
# Does not attack Guardian or Rampaging units (faction awareness).

static func take_turn(unit: Unit, all_units: Array[Unit], grid: GridManager, round_num: int = 0) -> Array[String]:
	var log: Array[String] = []

	# Rank 3+: forced advance at round 3 regardless of board state
	if not unit.advance_triggered and unit.vanguard_rank >= 3 and round_num >= 3:
		unit.advance_triggered = true
		log.append("[VANGUARD SALVAGE CO. // ADVANCING — SCHEDULE OVERRIDE]")

	# Standard advance trigger — latch, never resets once set
	if not unit.advance_triggered and _should_advance(all_units, unit.vanguard_rank):
		unit.advance_triggered = true
		log.append("[VANGUARD SALVAGE CO. // ADVANCING]")

	if not unit.advance_triggered:
		# Hold — still fire if a player walks into range
		var in_range := _nearest_player_in_range(unit, all_units, grid)
		if in_range != null:
			var result := EnemyAI.do_attack(unit, in_range)
			if result >= 0:
				log.append("[VANGUARD] %s FIRES  %s  [%d/%d]%s" % [
					unit.unit_id, in_range.unit_id,
					in_range.toughness, in_range.max_toughness, _attack_suffix(result)])
		else:
			log.append("[VANGUARD] %s HOLDS" % unit.unit_id)
		return log

	# Advancing — hunt the leader
	var leader := _find_leader(all_units)
	if leader != null:
		unit.last_known_leader_pos = leader.grid_pos

	var target_pos := unit.last_known_leader_pos
	if target_pos == null:
		log.append("[VANGUARD] %s ADVANCING — LEADER NOT FOUND" % unit.unit_id)
		return log

	# Move toward leader with no zone restriction, avoiding hazard tiles
	if not unit.has_moved:
		var warning := grid.get_warning_tiles()
		var dest := EnemyAI.best_move_toward(unit, target_pos, all_units, grid, false, warning)
		if not dest.equals(unit.grid_pos):
			EnemyAI.move_to(unit, dest, grid)
			log.append("[VANGUARD] %s ADVANCES → [%d,%d]" % [unit.unit_id, dest.x, dest.y])

	# Attack — leader first, then any player in range
	if not unit.has_attacked:
		var attack_target: Unit = null
		if leader != null and EnemyAI.can_attack(unit, leader, grid):
			attack_target = leader
		else:
			attack_target = _nearest_player_in_range(unit, all_units, grid)

		if attack_target != null:
			var result := EnemyAI.do_attack(unit, attack_target)
			if result >= 0:
				log.append("[VANGUARD] %s → %s  [%d/%d]%s" % [
					unit.unit_id, attack_target.unit_id,
					attack_target.toughness, attack_target.max_toughness, _attack_suffix(result)])

	return log

static func _should_advance(all_units: Array[Unit], rank: int) -> bool:
	for u in all_units:
		if not u.is_player or u.is_downed:
			continue
		if float(u.toughness) / float(u.max_toughness) <= 0.5:
			return true
		# Rank 2+: also advances when any player gear is Fractured
		if rank >= 2:
			for item: GearItem in u.gear:
				if item.state == GearItem.GearState.FRACTURED:
					return true
	return false

static func _find_leader(all_units: Array[Unit]) -> Unit:
	for u in all_units:
		if u.is_player and u.is_leader and not u.is_downed:
			return u
	return null

static func _nearest_player_in_range(unit: Unit, all_units: Array[Unit], grid: GridManager) -> Unit:
	var nearest: Unit = null
	var best := 9999
	for u in all_units:
		if not u.is_player or u.is_downed:
			continue
		if EnemyAI.can_attack(unit, u, grid):
			var d := EnemyAI.chebyshev(unit.grid_pos, u.grid_pos)
			if d < best:
				best = d
				nearest = u
	return nearest

static func _attack_suffix(result: int) -> String:
	if result == Unit.DamageResult.GEAR_FRACTURED:
		return " [GEAR FRACTURED]"
	elif result == Unit.DamageResult.GEAR_BROKEN or result == Unit.DamageResult.DOWNED:
		return " [DOWNED]"
	return ""
