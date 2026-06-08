class_name AoEResolver

## Static utility class for resolving area-of-effect blast attacks.
## Uses Chebyshev (Chessboard) distance for blast radius calculation.
## Friendly fire is intentional — all units in radius receive damage.

## Compute the effective blast radius for a weapon, reduced when fractured.
static func get_blast_radius(weapon: GearItem) -> int:
	var radius: int = CombatConstants.BLAST_RADIUS_DEFAULT
	if weapon.state == GearItem.GearState.FRACTURED:
		radius -= 1
	return maxi(radius, 1)

## Return damage value for a given distance from the blast origin.
static func get_falloff_damage(distance: int) -> int:
	match distance:
		0: return CombatConstants.BLAST_DAMAGE_CENTER
		1: return CombatConstants.BLAST_DAMAGE_MID
		2: return CombatConstants.BLAST_DAMAGE_EDGE
	return 0

## Chebyshev (chessboard) distance between two grid positions.
static func chebyshev(a: GridPos, b: GridPos) -> int:
	return maxi(absi(a.x - b.x), absi(a.y - b.y))

## Resolve an AoE blast originating at origin.
## Returns an array of Dictionaries: { "unit": Unit, "damage": int }
## Downed units are skipped. Both friendly and enemy units are included.
static func resolve_aoe(
		origin: GridPos,
		all_units: Array[Unit],
		weapon: GearItem) -> Array[Dictionary]:
	var results: Array[Dictionary] = []
	var radius: int = get_blast_radius(weapon)
	for unit: Unit in all_units:
		if unit.is_downed:
			continue
		var dist: int = chebyshev(origin, unit.grid_pos)
		if dist <= radius:
			var dmg: int = get_falloff_damage(dist)
			results.append({"unit": unit, "damage": dmg})
	return results
