class_name TacticalAI
extends RefCounted

# Holds in Zone A. Advances when triggered by rank-based conditions or player weakness.
# Priority target: the leader. Tracks last known leader position.
# Does not attack Guardian or Rampaging units (faction awareness).

static func take_turn(unit: Unit, all_units: Array[Unit],
		grid: GridManager, round_num: int = 0,
		cutaway_queue: Object = null) -> Array[String]:
	var log: Array[String] = []

	# Tick handled by Main.gd (unit.tick_turn_start()) — no tick call needed here

	# Skip ability use if Overloaded
	var abilities_blocked: bool = unit.status_effects != null and unit.status_effects.blocks_abilities()

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
			var result := EnemyAI.do_attack(unit, in_range, grid, cutaway_queue)
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
			# Check whether the resulting position enables a flanking Precision Strike
			var flank_leader := _find_leader(all_units)
			if flank_leader != null and PrecisionStrike.can_use(unit, flank_leader):
				log.append("[VANGUARD] %s ADVANCES → [%d,%d] [VANGUARD] FLANKING APPROACH" % [
					unit.unit_id, dest.x, dest.y])
			else:
				log.append("[VANGUARD] %s ADVANCES → [%d,%d]" % [unit.unit_id, dest.x, dest.y])

	# 1. Check for Precision Strike opportunity — prefer flanking attack on leader
	if not unit.has_attacked and not abilities_blocked:
		var leader_ps := _find_leader(all_units)
		if leader_ps != null and PrecisionStrike.can_use(unit, leader_ps):
			var result := EnemyAI.do_attack(unit, leader_ps, grid, cutaway_queue)
			if result >= 0:
				CombatResolver.apply_status(leader_ps, StatusEffect.Type.SUPPRESSED)
				log.append("[VANGUARD] %s PRECISION → %s  [%d/%d] [SUPPRESSED]" % [
					unit.unit_id, leader_ps.unit_id,
					leader_ps.toughness, leader_ps.max_toughness])

	# 2. Check for AoE attack if unit has an AoE weapon special ready
	if not unit.has_attacked and not abilities_blocked:
		var primary_special := EnemyAI.get_special_for_slot(unit, "weapon")
		if primary_special != null and primary_special.is_ready():
			var best_aoe_target := EnemyAI.find_best_aoe_target(unit, all_units, grid)
			if best_aoe_target != null:
				var hits := AoEResolver.resolve_aoe(best_aoe_target.grid_pos, all_units, _get_weapon(unit))
				for h: Dictionary in hits:
					CombatResolver.resolve_damage(h["unit"], h["damage"])
				primary_special.activate()
				unit.has_attacked = true
				log.append("[VANGUARD] %s AoE → [%d,%d]" % [
					unit.unit_id, best_aoe_target.grid_pos.x, best_aoe_target.grid_pos.y])

	# Attack — leader first, then any player in range
	if not unit.has_attacked:
		var attack_target: Unit = null
		if leader != null and EnemyAI.can_attack(unit, leader, grid):
			attack_target = leader
		else:
			attack_target = _nearest_player_in_range(unit, all_units, grid)

		if attack_target != null:
			var result := EnemyAI.do_attack(unit, attack_target, grid, cutaway_queue)
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
	if result == Unit.DamageResult.GEAR_BROKEN or result == Unit.DamageResult.DOWNED:
		return " [DOWNED]"
	return ""

static func _get_weapon(unit: Unit) -> GearItem:
	for item: GearItem in unit.gear:
		if item.slot == "weapon":
			return item
	return null
