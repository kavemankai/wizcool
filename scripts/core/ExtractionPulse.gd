class_name ExtractionPulse
extends Node2D

## Dedicated canvas item for the pulsing extraction-tile highlight.
## Kept separate from GridManager so the static 240-tile board is not
## re-rasterised every frame just to animate a single tile. This node
## redraws itself each frame; the board redraws only when it changes.

const _COLOR := Color(0.10, 0.80, 0.60, 0.55)

var _tile: GridPos = null
var _tile_size: int = 32
var _time: float = 0.0

## Set (or clear) the extraction tile. Pass null to hide the pulse.
func set_tile(tile: GridPos, tile_size: int) -> void:
	_tile = tile
	_tile_size = tile_size
	_time = 0.0
	visible = tile != null
	queue_redraw()

func _process(delta: float) -> void:
	if _tile == null:
		return
	_time += delta
	queue_redraw()

func _draw() -> void:
	if _tile == null:
		return
	var pulse := sin(_time * 2.8) * 0.18 + 0.48
	var col := _COLOR
	col.a = pulse
	draw_rect(Rect2(_tile.x * _tile_size, _tile.y * _tile_size, _tile_size, _tile_size), col)
