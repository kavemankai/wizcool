class_name TacticalAI
extends RefCounted

# Holds in Zone A. Advances when any player is at ≤50% Toughness or has Fractured gear.
# Priority target: the leader. Tracks last known leader position.
# Does not attack Guardian or Rampaging units (faction awareness).

static func take_turn(unit: Unit, all_units: Array[Unit], grid: GridManager) -> Array[String]:
	var log: Array[String] = []

	# Latch advance trigger — never resets once set
	if not unit.advance_triggered and _should_advance(all_units):
		unit.advance_triggered = true
		log.append("[VANGUARD SALVAGE CO. // ADVANCING]")

	if not unit.advance_triggered:
		# Hold — still fire if a player walks into range
		var in_range := _nearest_player_in_range(unit, all_units, grid)
		if in_range != null:
			var dmg := EnemyAI.do_attack(unit, in_range)
			if dmg > 0:
				log.append("[VANGUARD] %s FIRES  %s  -%d TGH  [%d/%d]" % [
					unit.unit_id, in_range.unit_id, dmg,
					in_range.toughness, in_range.max_toughness])
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

	# Move toward leader with no zone restriction
	if not unit.has_moved:
		var dest := EnemyAI.best_move_toward(unit, target_pos, all_units, grid, false)
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
			var dmg := EnemyAI.do_attack(unit, attack_target)
			if dmg > 0:
				log.append("[VANGUARD] %s → %s  -%d TGH  [%d/%d]" % [
					unit.unit_id, attack_target.unit_id, dmg,
					attack_target.toughness, attack_target.max_toughness])

	return log

static func _should_advance(all_units: Array[Unit]) -> bool:
	for u in all_units:
		if not u.is_player or u.is_downed:
			continue
		if float(u.toughness) / float(u.max_toughness) <= 0.5:
			return true
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
