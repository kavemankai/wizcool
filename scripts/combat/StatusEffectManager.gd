class_name StatusEffectManager
extends RefCounted

## Owns and manages all active StatusEffects for a single Unit.
## One instance is created in Unit._ready() and stored as Unit.status_effects.

var _effects: Array[StatusEffect] = []

## Apply an effect. If an effect of the same type already exists it is
## replaced (refreshed), otherwise the new effect is appended.
func apply(effect: StatusEffect) -> void:
	for i: int in _effects.size():
		if _effects[i].type == effect.type:
			_effects[i] = effect
			return
	_effects.append(effect)

## Returns true if the unit currently has an effect of the given type.
func has(type: StatusEffect.Type) -> bool:
	for e: StatusEffect in _effects:
		if e.type == type:
			return true
	return false

## Returns a copy of the active effects array for read-only iteration.
func get_all() -> Array[StatusEffect]:
	return _effects.duplicate()

## Advance all effects by one turn and remove any that have expired.
func tick_all() -> void:
	var still_active: Array[StatusEffect] = []
	for e: StatusEffect in _effects:
		if not e.tick():
			still_active.append(e)
	_effects = still_active

## Extra movement tiles lost while SUPPRESSED (0 if not suppressed).
func get_move_penalty() -> int:
	if has(StatusEffect.Type.SUPPRESSED):
		return CombatConstants.SUPPRESSED_MOVE_PENALTY
	return 0

## Extra AP lost while SUPPRESSED (0 if not suppressed).
func get_ap_penalty() -> int:
	if has(StatusEffect.Type.SUPPRESSED):
		return CombatConstants.SUPPRESSED_AP_PENALTY
	return 0

## Bonus incoming damage from gear corrosion while CORRODED (0 if not corroded).
func get_tgh_cost_modifier() -> int:
	if has(StatusEffect.Type.CORRODED):
		return CombatConstants.CORRODED_TGH_PENALTY
	return 0

## Returns true when OVERLOADED is active, blocking special ability use.
func blocks_abilities() -> bool:
	return has(StatusEffect.Type.OVERLOADED)

## Remove all active effects immediately (e.g. on mission end or cleanse).
func clear() -> void:
	_effects.clear()
