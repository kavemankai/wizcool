class_name LOS
extends RefCounted

# Returns true if there is an unobstructed line of sight between two grid positions.
# Wall tiles block LOS. Cover tiles do NOT block LOS.
# Uses parametric linear interpolation across the grid.
static func has_los(from_pos: GridPos, to_pos: GridPos, grid: GridManager) -> bool:
	var x0 := from_pos.x
	var y0 := from_pos.y
	var x1 := to_pos.x
	var y1 := to_pos.y

	if x0 == x1 and y0 == y1:
		return true

	var dx := x1 - x0
	var dy := y1 - y0
	var steps: int = maxi(absi(dx), absi(dy))

	for i in range(1, steps):
		var t := float(i) / float(steps)
		var cx := int(round(x0 + dx * t))
		var cy := int(round(y0 + dy * t))
		if grid.get_tile_type(GridPos.new(cx, cy)) == GridManager.TileType.WALL:
			return false

	return true
