extends SceneTree

# Tests for GrazeSystem — the deterministic damage-tier ladder.
# Run: godot --headless --script tests/unit/combat/graze_system_test.gd

var _passed: int = 0
var _failed: int = 0

func _init() -> void:
	_run_all()
	print("\n=== GRAZE SYSTEM TESTS: %d passed, %d failed ===" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)

func _run_all() -> void:
	test_graze_exposed_midrange_is_clean()
	test_graze_light_cover_unflanked_is_graze()
	test_graze_heavy_cover_unflanked_is_chip()
	test_graze_heavy_cover_flanked_is_clean()
	test_graze_braced_target_is_graze()
	test_graze_heavy_cover_plus_brace_clamps_to_chip()
	test_graze_adjacent_into_light_cover_is_clean()
	test_graze_max_range_exposed_is_graze()
	test_graze_melee_attacker_adjacent_is_clean()
	test_graze_broken_target_gear_nullifies_cover()
	test_graze_fractured_target_gear_downgrades_heavy_cover()
	test_graze_null_grid_ignores_cover()
	test_apply_tier_clean_full_damage()
	test_apply_tier_graze_reduces_by_one_min_one()
	test_apply_tier_chip_always_one()

func _assert(condition: bool, name: String) -> void:
	if condition:
		print("  PASS  %s" % name)
		_passed += 1
	else:
		print("  FAIL  %s" % name)
		_failed += 1

# --- fixtures ---------------------------------------------------------------

func _make_grid() -> GridManager:
	var g := GridManager.new()
	g._init_tiles()
	return g

## Target at (5,5) facing south (0,1). Attacker south of target = NOT flanking;
## attacker north of target = flanking (per CoverSystem.is_flanking dot rule).
func _make_pair(attacker_pos: GridPos, attack_range: int = 3) -> Array[Unit]:
	var attacker := Unit.new()
	attacker.grid_pos = attacker_pos
	attacker.attack_range = attack_range
	var target := Unit.new()
	target.grid_pos = GridPos.new(5, 5)
	target.facing = Vector2i(0, 1)
	return [attacker, target]

func _put_cover(g: GridManager, pos: GridPos, tier: int) -> void:
	g.set_tile(pos, GridManager.TileType.COVER)
	g.set_cover_tier(pos, tier)

func _brace(target: Unit) -> void:
	var w := GearItem.make_weapon("W", 1, 2)
	w.special = WeaponSpecial.make(WeaponSpecial.SpecialType.BRACE)
	w.special.activate()
	target.gear.append(w)

# --- tier computation -------------------------------------------------------

func test_graze_exposed_midrange_is_clean() -> void:
	var g := _make_grid()
	var pair := _make_pair(GridPos.new(5, 7))  # dist 2, range 3, no cover
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.CLEAN,
			"exposed mid-range: CLEAN")

func test_graze_light_cover_unflanked_is_graze() -> void:
	var g := _make_grid()
	_put_cover(g, GridPos.new(5, 5), 1)
	var pair := _make_pair(GridPos.new(5, 7))  # south of target = not flanking
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.GRAZE,
			"light cover unflanked: GRAZE")

func test_graze_heavy_cover_unflanked_is_chip() -> void:
	var g := _make_grid()
	_put_cover(g, GridPos.new(5, 5), 2)
	var pair := _make_pair(GridPos.new(5, 7))
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.CHIP,
			"heavy cover unflanked: CHIP")

func test_graze_heavy_cover_flanked_is_clean() -> void:
	var g := _make_grid()
	_put_cover(g, GridPos.new(5, 5), 2)
	var pair := _make_pair(GridPos.new(5, 3))  # north of target = flanking
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.CLEAN,
			"heavy cover flanked: CLEAN")

func test_graze_braced_target_is_graze() -> void:
	var g := _make_grid()
	var pair := _make_pair(GridPos.new(5, 7))
	_brace(pair[1])
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.GRAZE,
			"braced exposed target: GRAZE")

func test_graze_heavy_cover_plus_brace_clamps_to_chip() -> void:
	var g := _make_grid()
	_put_cover(g, GridPos.new(5, 5), 2)
	var pair := _make_pair(GridPos.new(5, 7))
	_brace(pair[1])
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.CHIP,
			"heavy cover + brace: clamps at CHIP")

func test_graze_adjacent_into_light_cover_is_clean() -> void:
	var g := _make_grid()
	_put_cover(g, GridPos.new(5, 5), 1)
	var pair := _make_pair(GridPos.new(5, 6))  # dist 1, south = not flanking
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.CLEAN,
			"adjacent into light cover: CLEAN (point-blank offsets cover)")

func test_graze_max_range_exposed_is_graze() -> void:
	var g := _make_grid()
	var pair := _make_pair(GridPos.new(5, 8))  # dist 3 == range 3
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.GRAZE,
			"max range exposed: GRAZE")

func test_graze_melee_attacker_adjacent_is_clean() -> void:
	var g := _make_grid()
	var pair := _make_pair(GridPos.new(5, 6), 1)  # range-1 attacker at dist 1
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.CLEAN,
			"melee attacker adjacent: CLEAN (no max-range penalty at range 1)")

func test_graze_broken_target_gear_nullifies_cover() -> void:
	var g := _make_grid()
	_put_cover(g, GridPos.new(5, 5), 2)
	var pair := _make_pair(GridPos.new(5, 7))
	var w := GearItem.make_weapon("W", 1, 2)
	w.state = GearItem.GearState.BROKEN
	pair[1].gear.append(w)
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.CLEAN,
			"broken target gear: cover nullified, CLEAN")

func test_graze_fractured_target_gear_downgrades_heavy_cover() -> void:
	var g := _make_grid()
	_put_cover(g, GridPos.new(5, 5), 2)
	var pair := _make_pair(GridPos.new(5, 7))
	var w := GearItem.make_weapon("W", 1, 2)
	w.state = GearItem.GearState.FRACTURED
	pair[1].gear.append(w)
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], g) == GrazeSystem.Tier.GRAZE,
			"fractured target gear: heavy cover acts as light, GRAZE")

func test_graze_null_grid_ignores_cover() -> void:
	var pair := _make_pair(GridPos.new(5, 7))
	_assert(GrazeSystem.compute_tier(pair[0], pair[1], null) == GrazeSystem.Tier.CLEAN,
			"null grid: cover ignored, CLEAN")

# --- damage transform -------------------------------------------------------

func test_apply_tier_clean_full_damage() -> void:
	_assert(GrazeSystem.apply_tier(3, GrazeSystem.Tier.CLEAN) == 3,
			"apply CLEAN: full damage")

func test_apply_tier_graze_reduces_by_one_min_one() -> void:
	_assert(GrazeSystem.apply_tier(3, GrazeSystem.Tier.GRAZE) == 2,
			"apply GRAZE: damage - 1")
	_assert(GrazeSystem.apply_tier(1, GrazeSystem.Tier.GRAZE) == 1,
			"apply GRAZE: never below 1")

func test_apply_tier_chip_always_one() -> void:
	_assert(GrazeSystem.apply_tier(5, GrazeSystem.Tier.CHIP) == 1,
			"apply CHIP: always 1")
