class_name EnemyAI
extends RefCounted

# Base class providing shared helpers for all AI archetypes.
# Dispatch lives in Main.gd — each archetype is self-contained.

static func move_to(unit: Unit, pos: GridPos, grid: GridManager) -> void:
	unit.place_at(pos, grid)
	unit.has_moved = true

static func do_attack(attacker: Unit, target: Unit, grid: GridManager = null, cutaway_queue: Object = null) -> int:
	if attacker.has_attacked or target.is_downed:
		return -1
	var dmg := attacker.get_weapon_damage()
	var pre_tgh := target.toughness
	var result := CombatResolver.resolve_damage_ex(attacker, target, dmg, false, grid)
	attacker.has_attacked = true
	if cutaway_queue != null:
		cutaway_queue.queue_event(attacker, target, dmg, result, pre_tgh)
	return result

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
	return LOSCalculator.has_los(attacker.grid_pos, target.grid_pos, grid)

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

## Returns net AoE score for a given origin cell:
## +1 per enemy of source in blast radius, -2 per friendly in blast radius.
static func score_aoe_cell(origin: GridPos, source: Unit, all_units: Array[Unit]) -> int:
	var score: int = 0
	for u in all_units:
		if u.is_downed:
			continue
		var dist := chebyshev(origin, u.grid_pos)
		if dist > CombatConstants.BLAST_RADIUS_DEFAULT:
			continue
		if u.is_player != source.is_player:
			score += 1  # enemy of source
		else:
			score -= 2  # friendly (heavily penalised)
	return score

## Returns the enemy unit whose position (as AoE origin) scores highest.
## Only considers cells within source.attack_range.
static func find_best_aoe_target(source: Unit, all_units: Array[Unit], grid: GridManager) -> Unit:
	var best_unit: Unit = null
	var best_score: int = CombatConstants.AI_AOE_MIN_SCORE - 1
	for u in all_units:
		if u.is_downed or u.is_player == source.is_player:
			continue
		if not can_attack(source, u, grid):
			continue
		var score := score_aoe_cell(u.grid_pos, source, all_units)
		if score > best_score:
			best_score = score
			best_unit = u
	return best_unit

## Returns true if the unit has the given StatusEffect type active.
static func unit_has_status(unit: Unit, type: StatusEffect.Type) -> bool:
	if unit.status_effects == null:
		return false
	return unit.status_effects.has(type)

## Returns the WeaponSpecial for the given gear slot, or null if none equipped.
static func get_special_for_slot(unit: Unit, slot: String) -> WeaponSpecial:
	for item: GearItem in unit.gear:
		if item.slot == slot and item.special != null:
			return item.special
	return null
