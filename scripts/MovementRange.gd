class_name MovementRange
extends RefCounted

# BFS flood-fill to find all tiles reachable within range_val cardinal steps.
# Excludes wall tiles and tiles occupied by other units.
static func get_reachable(
		origin: GridPos,
		range_val: int,
		grid: GridManager,
		occupied: Array[GridPos]) -> Array[GridPos]:

	var visited: Dictionary = {}
	var frontier: Array[GridPos] = [origin]
	var result: Array[GridPos] = []

	visited[Vector2i(origin.x, origin.y)] = 0

	while frontier.size() > 0:
		var next: Array[GridPos] = []
		for pos in frontier:
			var dist: int = visited[Vector2i(pos.x, pos.y)]
			if dist >= range_val:
				continue
			for nb in _neighbors(pos):
				var key := Vector2i(nb.x, nb.y)
				if key in visited:
					continue
				if not grid.is_walkable(nb):
					continue
				if _is_occupied(nb, occupied):
					continue
				visited[key] = dist + 1
				result.append(nb)
				next.append(nb)
		frontier = next

	return result

static func _neighbors(pos: GridPos) -> Array[GridPos]:
	return [
		GridPos.new(pos.x + 1, pos.y),
		GridPos.new(pos.x - 1, pos.y),
		GridPos.new(pos.x, pos.y + 1),
		GridPos.new(pos.x, pos.y - 1),
	]

static func _is_occupied(pos: GridPos, occupied: Array[GridPos]) -> bool:
	for p in occupied:
		if p.x == pos.x and p.y == pos.y:
			return true
	return false
