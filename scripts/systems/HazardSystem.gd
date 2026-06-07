class_name HazardSystem
extends RefCounted

signal hazard_warning_issued(tiles: Array)
signal hazard_activated(tiles: Array)

const HAZARD_DAMAGE: int = 3
const HAZARD_INTERVAL: int = 3

var _zones: Array = []

func _init() -> void:
	_zones.resize(3)
	_zones[0] = _make_zone(1, 4, 8, 12)
	_zones[1] = _make_zone(7, 10, 8, 12)
	_zones[2] = _make_zone(4, 7, 8, 12)

func _make_zone(x_min: int, x_max: int, y_min: int, y_max: int) -> Array[GridPos]:
	var result: Array[GridPos] = []
	for x in range(x_min, x_max + 1):
		for y in range(y_min, y_max + 1):
			result.append(GridPos.new(x, y))
	return result

func get_active_zone(round_num: int) -> Array[GridPos]:
	if round_num % HAZARD_INTERVAL != 0:
		return []
	var cycle_index := ((round_num / HAZARD_INTERVAL) - 1) % 3
	var zone: Array[GridPos] = _zones[cycle_index]
	return zone
