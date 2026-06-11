class_name CoverSystem

## Static utility class for cover type queries, damage reduction, and flank checks.
## No instances — all methods are static.

enum CoverType { NONE, LIGHT, HEAVY }

## Determine the cover type at a grid position.
## Checks get_cover_tier() on GridManager when available;
## defaults to LIGHT for any COVER tile without explicit tier data.
static func get_cover_type(pos: GridPos, grid: GridManager) -> CoverSystem.CoverType:
	if grid.get_tile_type(pos) != GridManager.TileType.COVER:
		return CoverSystem.CoverType.NONE
	var tier: int = grid.get_cover_tier(pos)
	match tier:
		2:    return CoverSystem.CoverType.HEAVY
		1:    return CoverSystem.CoverType.LIGHT
		_:    return CoverSystem.CoverType.LIGHT  # default for unregistered COVER tiles

## Returns true if the attacker is flanking the target.
## Flanking occurs when the attacker is beside or behind the target's facing direction.
## A target with a zero facing vector (uninitialised) is never considered flanked.
static func is_flanking(
		attacker_pos: GridPos,
		target_pos: GridPos,
		target_facing: Vector2i) -> bool:
	if target_facing == Vector2i.ZERO:
		return false
	var raw: Vector2i = Vector2i(
		attacker_pos.x - target_pos.x,
		attacker_pos.y - target_pos.y
	)
	# Normalise to unit direction vector (each component clamped to -1/0/1)
	var dir: Vector2i = Vector2i(
		clampi(raw.x, -1, 1),
		clampi(raw.y, -1, 1)
	)
	# Dot product <= 0 means attacker is to the side or behind the facing direction
	return (dir.x * target_facing.x + dir.y * target_facing.y) <= 0
