class_name SpriteLib

## Central texture lookup for the GBA-style sprite skin. Every accessor
## returns null when the art file is absent, and callers fall back to the
## original programmatic drawing — so art can land incrementally without
## ever breaking the game.
##
## Paths:
##   units:   res://assets/sprites/units/unit_[key].png        (48x48 standees)
##   tiles:   res://assets/sprites/tiles/tile_[name].png        (64x64, drawn at 32)
##   cutaway: res://assets/sprites/cutaway/cutaway_bg_[side].png

const _UNIT_DIR := "res://assets/sprites/units/"
const _TILE_DIR := "res://assets/sprites/tiles/"
const _CUTAWAY_DIR := "res://assets/sprites/cutaway/"

## Floor tiles may ship multiple variants (tile_floor_0/1/2) to break repetition.
const _FLOOR_VARIANTS: int = 3

static var _cache: Dictionary = {}

static func _load(path: String) -> Texture2D:
	if _cache.has(path):
		return _cache[path]
	var tex: Texture2D = null
	if ResourceLoader.exists(path):
		tex = load(path)
	_cache[path] = tex
	return tex

## Standee for a unit. Named cast resolve by unit_id; generic enemies fall
## back to an archetype standee (so new campaigns get sprites for free).
static func unit_texture(u: Unit) -> Texture2D:
	var key := _unit_key(u)
	if key == "":
		return null
	return _load(_UNIT_DIR + "unit_" + key + ".png")

static func _unit_key(u: Unit) -> String:
	match u.unit_id:
		"ALPHA": return "alpha"
		"BRAVO": return "bravo"
		"CHARLIE": return "charlie"
		"VANGUARD-1": return "vanguard_leader"
		"VANGUARD-2": return "vanguard_soldier"
		"VANGUARD-3": return "vanguard_tech"
	if u.unit_id.begins_with("SENTINEL"):
		return "sentinel"
	if u.unit_id.begins_with("PRISONER"):
		return "prisoner"
	# Archetype fallback for campaign-flavoured enemy ids (WATCHMAN, LOOTER…)
	match u.archetype:
		Unit.Archetype.GUARDIAN:  return "sentinel"
		Unit.Archetype.RAMPAGING: return "prisoner"
		Unit.Archetype.TACTICAL:  return "vanguard_soldier"
	return "alpha" if u.is_player else ""

## Tile texture for a grid cell, or null. Floor picks a deterministic
## variant from the cell coordinates so the pattern never shimmers.
static func tile_texture(tile_type: int, x: int, y: int) -> Texture2D:
	match tile_type:
		GridManager.TileType.FLOOR:
			var v := (x * 7 + y * 13) % _FLOOR_VARIANTS
			var tex := _load(_TILE_DIR + "tile_floor_%d.png" % v)
			if tex == null and v != 0:
				tex = _load(_TILE_DIR + "tile_floor_0.png")
			return tex
		GridManager.TileType.WALL:
			return _load(_TILE_DIR + "tile_wall.png")
		GridManager.TileType.COVER:
			return _load(_TILE_DIR + "tile_cover.png")
		GridManager.TileType.HAZARD_ZONE:
			return _load(_TILE_DIR + "tile_hazard.png")
	return null

## Painted side-background for the combat cutaway panels.
static func cutaway_bg(is_player_side: bool) -> Texture2D:
	var side := "player" if is_player_side else "enemy"
	return _load(_CUTAWAY_DIR + "cutaway_bg_" + side + ".png")
