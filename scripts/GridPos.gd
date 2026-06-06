class_name GridPos
extends RefCounted

var x: int
var y: int

func _init(px: int = 0, py: int = 0) -> void:
	x = px
	y = py

func equals(other: GridPos) -> bool:
	return x == other.x and y == other.y

func copy() -> GridPos:
	return GridPos.new(x, y)
