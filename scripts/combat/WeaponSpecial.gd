class_name WeaponSpecial
extends RefCounted

## Represents an activated weapon ability with cooldown tracking.
## Attached to a GearItem via GearItem.special (null when no special exists).

enum SpecialType { SUPPRESSING_FIRE, CORROSIVE_BURST, ARC_PULSE, BRACE }

var type: WeaponSpecial.SpecialType
var cooldown_max: int
var cooldown_remaining: int = 0

## Tracks whether the unit is currently braced (BRACE ability only).
var is_braced: bool = false

## Factory — sets cooldown_max from CombatConstants based on ability type.
static func make(t: WeaponSpecial.SpecialType) -> WeaponSpecial:
	var ws := WeaponSpecial.new()
	ws.type = t
	match t:
		WeaponSpecial.SpecialType.SUPPRESSING_FIRE:
			ws.cooldown_max = CombatConstants.ABILITY_COOLDOWN_SUPPRESSING_FIRE
		WeaponSpecial.SpecialType.CORROSIVE_BURST:
			ws.cooldown_max = CombatConstants.ABILITY_COOLDOWN_CORROSIVE_BURST
		WeaponSpecial.SpecialType.ARC_PULSE:
			ws.cooldown_max = CombatConstants.ABILITY_COOLDOWN_ARC_PULSE
		WeaponSpecial.SpecialType.BRACE:
			ws.cooldown_max = CombatConstants.ABILITY_COOLDOWN_BRACE
	return ws

## True when the ability can be used (not on cooldown).
func is_ready() -> bool:
	return cooldown_remaining == 0

## Mark the ability as used: start its cooldown.
## For BRACE, also sets the braced state.
func activate() -> void:
	cooldown_remaining = cooldown_max
	if type == WeaponSpecial.SpecialType.BRACE:
		is_braced = true

## Advance the cooldown by one turn.
## Clears is_braced for BRACE once the cooldown has started ticking down.
func tick_cooldown() -> void:
	if cooldown_remaining > 0:
		cooldown_remaining -= 1
	if type == WeaponSpecial.SpecialType.BRACE and cooldown_remaining < cooldown_max:
		is_braced = false

## Human-readable ability name for HUD display.
func get_label() -> String:
	match type:
		WeaponSpecial.SpecialType.SUPPRESSING_FIRE: return "SUPPRESSING FIRE"
		WeaponSpecial.SpecialType.CORROSIVE_BURST:  return "CORROSIVE BURST"
		WeaponSpecial.SpecialType.ARC_PULSE:        return "ARC PULSE"
		WeaponSpecial.SpecialType.BRACE:            return "BRACE"
	return "UNKNOWN"

## Returns "READY" when off cooldown, or "CD: N" showing remaining turns.
func get_cooldown_label() -> String:
	if cooldown_remaining == 0:
		return "READY"
	return "CD: %d" % cooldown_remaining
