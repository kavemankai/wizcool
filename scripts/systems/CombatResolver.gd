class_name CombatResolver
extends RefCounted

# All damage — attacks and hazards — routes through here so gear-fracture
# rules apply identically regardless of source.
static func resolve_damage(target: Unit, amount: int) -> int:
	return target.take_damage(amount)
