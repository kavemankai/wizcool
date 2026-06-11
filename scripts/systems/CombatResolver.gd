class_name CombatResolver
extends RefCounted

## All damage — attacks and hazards — routes through here so gear-fracture
## rules apply identically regardless of source.
static func resolve_damage(target: Unit, amount: int) -> int:
	return target.take_damage(amount)

## Extended damage resolution through the graze-tier ladder (see GrazeSystem).
## force_clean is true for Precision Strike hits — a guaranteed CLEAN tier.
## Returns the DamageResult int from Unit.take_damage().
static func resolve_damage_ex(
		attacker: Unit,
		target: Unit,
		raw_amount: int,
		force_clean: bool = false,
		grid: GridManager = null) -> int:
	var tier: int = GrazeSystem.Tier.CLEAN if force_clean \
			else GrazeSystem.compute_tier(attacker, target, grid)
	var amount: int = GrazeSystem.apply_tier(raw_amount, tier)

	# CORRODED status adds to incoming toughness cost after the tier transform
	if target.status_effects != null:
		amount += target.status_effects.get_tgh_cost_modifier()

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
