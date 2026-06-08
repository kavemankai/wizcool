class_name CutawayUnit
extends Node2D

const RADIUS := 60.0

const PLAYER_COLOR    := Color(0.22, 0.52, 0.82)
const GUARDIAN_COLOR  := Color(0.65, 0.20, 0.15)
const RAMPAGING_COLOR := Color(0.80, 0.38, 0.08)
const TACTICAL_COLOR  := Color(0.48, 0.10, 0.22)
const LEADER_RING     := Color(0.90, 0.80, 0.10)

var unit_ref: Unit = null

var flash_alpha: float = 0.0:
	set(val):
		flash_alpha = val
		queue_redraw()

func setup(u: Unit) -> void:
	unit_ref = u
	flash_alpha = 0.0
	queue_redraw()

func _draw() -> void:
	if not is_instance_valid(unit_ref):
		return

	var fill: Color
	if unit_ref.is_player:
		fill = PLAYER_COLOR
	else:
		match unit_ref.archetype:
			Unit.Archetype.GUARDIAN:  fill = GUARDIAN_COLOR
			Unit.Archetype.RAMPAGING: fill = RAMPAGING_COLOR
			Unit.Archetype.TACTICAL:  fill = TACTICAL_COLOR
			_:                         fill = GUARDIAN_COLOR

	draw_circle(Vector2.ZERO, RADIUS, fill)

	if not unit_ref.is_player:
		match unit_ref.archetype:
			Unit.Archetype.RAMPAGING:
				draw_line(Vector2(-24, 0), Vector2(24, 0), Color(1, 1, 1, 0.55), 7.0)
				draw_line(Vector2(0, -24), Vector2(0, 24), Color(1, 1, 1, 0.55), 7.0)
			Unit.Archetype.TACTICAL:
				draw_line(Vector2(0, -28), Vector2(24, 0),  Color(1, 1, 1, 0.55), 5.5)
				draw_line(Vector2(24, 0),  Vector2(0, 28),  Color(1, 1, 1, 0.55), 5.5)
				draw_line(Vector2(0, 28),  Vector2(-24, 0), Color(1, 1, 1, 0.55), 5.5)
				draw_line(Vector2(-24, 0), Vector2(0, -28), Color(1, 1, 1, 0.55), 5.5)

	if unit_ref.is_leader:
		draw_arc(Vector2.ZERO, RADIUS + 10.0, 0.0, TAU, 40, LEADER_RING, 3.5)

	if flash_alpha > 0.001:
		draw_circle(Vector2.ZERO, RADIUS * 1.55, Color(1.0, 1.0, 1.0, flash_alpha))
