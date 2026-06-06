class_name EnemyAI
extends RefCounted

# Dispatcher — routes to the correct archetype AI and provides shared helpers.

static func take_turn(unit: Unit, all_units: Array[Unit],
		grid: GridManager, round_num: int = 0) -> Array[String]:
	match unit.archetype:
		Unit.Archetype.GUARDIAN:  return GuardianAI.take_turn(unit, all_units, grid)
		Unit.Archetype.RAMPAGING: return RampagingAI.take_turn(unit, all_units, grid)
		Unit.Archetype.TACTICAL:  return TacticalAI.take_turn(unit, all_units, grid, round_num)
	return []

# Move unit to pos (teleport in Phase 3; Phase 10 adds animation).
static func move_to(unit: Unit, pos: GridPos, grid: GridManager) -> void:
	unit.place_at(pos, grid)
	unit.has_moved = true

# Apply attack. Returns Unit.DamageResult value, or -1 if attack not made.
static func do_attack(attacker: Unit, target: Unit) -> int:
	if attacker.has_attacked or target.is_downed:
		return -1
	var dmg := attacker.get_weapon_damage()
	var result := target.take_damage(dmg)
	attacker.has_attacked = true
	return result

# Find the reachable tile that minimises Chebyshev distance to target_pos.
# When respect_zone is true, only considers tiles within unit.zone_min/max_row.
# blocked_tiles are treated as impassable (used to avoid hazard warning tiles).
static func best_move_toward(unit: Unit, target_pos: GridPos,
		all_units: Array[Unit], grid: GridManager,
		respect_zone: bool = true,
		blocked_tiles: Array[GridPos] = []) -> GridPos:
	var occupied := occupied_positions(all_units, unit)
	var reachable := MovementRange.get_reachable(
		unit.grid_pos, unit.get_effective_speed(), grid, occupied, blocked_tiles)

	var best := unit.grid_pos
	var best_dist := chebyshev(unit.grid_pos, target_pos)

	for pos in reachable:
		if respect_zone and not in_zone(pos, unit):
			continue
		var d := chebyshev(pos, target_pos)
		if d < best_dist:
			best_dist = d
			best = pos

	return best

# Nearest unit to from_unit among candidates (any faction unless filtered by caller).
static func nearest_unit(from_unit: Unit, candidates: Array[Unit]) -> Unit:
	var nearest: Unit = null
	var best := 9999
	for u in candidates:
		if u == from_unit or u.is_downed:
			continue
		var d := chebyshev(from_unit.grid_pos, u.grid_pos)
		if d < best:
			best = d
			nearest = u
	return nearest

static func can_attack(attacker: Unit, target: Unit, grid: GridManager) -> bool:
	if target.is_downed:
		return false
	if chebyshev(attacker.grid_pos, target.grid_pos) > attacker.attack_range:
		return false
	return LOS.has_los(attacker.grid_pos, target.grid_pos, grid)

static func chebyshev(a: GridPos, b: GridPos) -> int:
	return max(abs(a.x - b.x), abs(a.y - b.y))

static func in_zone(pos: GridPos, unit: Unit) -> bool:
	if unit.zone_min_row < 0:
		return true
	return pos.y >= unit.zone_min_row and pos.y <= unit.zone_max_row

static func occupied_positions(all_units: Array[Unit], exclude: Unit) -> Array[GridPos]:
	var result: Array[GridPos] = []
	for u in all_units:
		if u != exclude and not u.is_downed:
			result.append(u.grid_pos)
	return result
