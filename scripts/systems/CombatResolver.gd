class_name CombatResolver
extends RefCounted

## All damage — attacks and hazards — routes through here so gear-fracture
## rules apply identically regardless of source.
static func resolve_damage(target: Unit, amount: int) -> int:
	return target.take_damage(amount)

## Extended damage resolution with cover and status support.
## bypass_cover should be true for Precision Strike hits and AoE centre impacts.
## Returns the DamageResult int from Unit.take_damage().
static func resolve_damage_ex(
		attacker: Unit,
		target: Unit,
		raw_amount: int,
		bypass_cover: bool = false,
		grid: GridManager = null) -> int:
	var amount: int = raw_amount

	# CORRODED status adds to incoming toughness cost
	if target.status_effects != null:
		amount += target.status_effects.get_tgh_cost_modifier()

	# Cover reduction — skipped when bypassed (e.g. Precision Strike, AoE centre)
	if not bypass_cover and grid != null:
		var cover: CoverSystem.CoverType = CoverSystem.get_cover_type(target.grid_pos, grid)
		var is_flank: bool = CoverSystem.is_flanking(
				attacker.grid_pos, target.grid_pos, target.facing)
		if not is_flank:
			var gear_state: int = target.get_weapon_gear_state()
			var reduction: int = CoverSystem.get_damage_reduction(cover, gear_state)
			amount -= reduction
			amount = maxi(1, amount)  # cover reduces to minimum 1, never 0

	# BRACE — defensive stance reduces the next incoming hit (min 1)
	if target.is_braced():
		amount = maxi(1, amount - CombatConstants.BRACE_DAMAGE_REDUCTION)

	return resolve_damage(target, amount)

## Convenience helper — construct and apply a status effect to a unit.
static func apply_status(unit: Unit, type: StatusEffect.Type) -> void:
	var dur: int
	match type:
		StatusEffect.Type.SUPPRESSED: dur = CombatConstants.SUPPRESSED_DURATION
		StatusEffect.Type.CORRODED:   dur = CombatConstants.CORRODED_DURATION
		StatusEffect.Type.OVERLOADED: dur = CombatConstants.OVERLOADED_DURATION
		_:                            dur = 1
	unit.apply_status(StatusEffect.make(type, dur))
