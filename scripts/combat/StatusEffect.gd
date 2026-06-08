class_name StatusEffect
extends RefCounted

## A single timed status effect applied to a Unit.
## Created via StatusEffect.make(); ticked each turn start via tick().

enum Type { SUPPRESSED, CORRODED, OVERLOADED }

var type: StatusEffect.Type
var duration: int

## Factory — preferred construction path.
static func make(t: StatusEffect.Type, dur: int) -> StatusEffect:
	var e := StatusEffect.new()
	e.type = t
	e.duration = dur
	return e

## Decrement duration by one turn.
## Returns true when the effect has expired (duration <= 0).
func tick() -> bool:
	duration -= 1
	return duration <= 0

## Human-readable label for HUD display.
func get_label() -> String:
	match type:
		StatusEffect.Type.SUPPRESSED: return "SUPPRESSED"
		StatusEffect.Type.CORRODED:   return "CORRODED"
		StatusEffect.Type.OVERLOADED: return "OVERLOADED"
	return "UNKNOWN"
