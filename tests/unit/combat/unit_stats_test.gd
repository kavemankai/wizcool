extends SceneTree

# Tests for Unit stat calculations: get_effective_combat_skill(), get_effective_speed(),
# get_weapon_damage()
# Run: godot --headless --script tests/unit/combat/unit_stats_test.gd

var _passed: int = 0
var _failed: int = 0

func _init() -> void:
	_run_all()
	print("\n=== UNIT STATS TESTS: %d passed, %d failed ===" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)

func _run_all() -> void:
	test_combat_skill_base_only()
	test_combat_skill_with_intact_weapon()
	test_combat_skill_with_fractured_weapon()
	test_combat_skill_with_broken_weapon()
	test_speed_base_only()
	test_speed_with_intact_armor()
	test_speed_with_fractured_armor()
	test_weapon_damage_intact()
	test_weapon_damage_fractured_still_deals_damage()
	test_weapon_damage_broken_returns_one()
	test_weapon_damage_no_gear_returns_one()

func _assert(condition: bool, name: String) -> void:
	if condition:
		print("  PASS  %s" % name)
		_passed += 1
	else:
		print("  FAIL  %s" % name)
		_failed += 1

func _make_unit() -> Unit:
	var u := Unit.new()
	u.combat_skill = 2
	u.speed = 4
	return u

func test_combat_skill_base_only() -> void:
	var u := _make_unit()
	_assert(u.get_effective_combat_skill() == 2, "combat skill: base with no gear")

func test_combat_skill_with_intact_weapon() -> void:
	var u := _make_unit()
	var g := GearItem.make_weapon("PLASMA-CUTTER", 2, 3)
	g.state = GearItem.GearState.INTACT
	u.gear.append(g)
	_assert(u.get_effective_combat_skill() == 4, "combat skill: base + intact weapon modifier")

func test_combat_skill_with_fractured_weapon() -> void:
	var u := _make_unit()
	var g := GearItem.make_weapon("PLASMA-CUTTER", 2, 3)
	g.state = GearItem.GearState.FRACTURED
	u.gear.append(g)
	_assert(u.get_effective_combat_skill() == 2, "combat skill: fractured weapon adds 0")

func test_combat_skill_with_broken_weapon() -> void:
	var u := _make_unit()
	var g := GearItem.make_weapon("PLASMA-CUTTER", 2, 3)
	g.state = GearItem.GearState.BROKEN
	u.gear.append(g)
	_assert(u.get_effective_combat_skill() == 2, "combat skill: broken weapon adds 0")

func test_speed_base_only() -> void:
	var u := _make_unit()
	_assert(u.get_effective_speed() == 4, "speed: base with no gear")

func test_speed_with_intact_armor() -> void:
	var u := _make_unit()
	var g := GearItem.make_armor("WORK-HARNESS", 1)
	g.state = GearItem.GearState.INTACT
	u.gear.append(g)
	_assert(u.get_effective_speed() == 5, "speed: base + intact armor modifier")

func test_speed_with_fractured_armor() -> void:
	var u := _make_unit()
	var g := GearItem.make_armor("WORK-HARNESS", 1)
	g.state = GearItem.GearState.FRACTURED
	u.gear.append(g)
	_assert(u.get_effective_speed() == 4, "speed: fractured armor adds 0")

func test_weapon_damage_intact() -> void:
	var u := _make_unit()
	var g := GearItem.make_weapon("PLASMA-CUTTER", 2, 3)
	g.state = GearItem.GearState.INTACT
	u.gear.append(g)
	_assert(u.get_weapon_damage() == 3, "weapon damage: intact weapon returns damage value")

func test_weapon_damage_fractured_still_deals_damage() -> void:
	var u := _make_unit()
	var g := GearItem.make_weapon("PLASMA-CUTTER", 2, 3)
	g.state = GearItem.GearState.FRACTURED
	u.gear.append(g)
	# Fractured weapon still deals damage (modifier is 0, but damage is not)
	_assert(u.get_weapon_damage() == 3, "weapon damage: fractured weapon still returns damage value")

func test_weapon_damage_broken_returns_one() -> void:
	var u := _make_unit()
	var g := GearItem.make_weapon("PLASMA-CUTTER", 2, 3)
	g.state = GearItem.GearState.BROKEN
	u.gear.append(g)
	_assert(u.get_weapon_damage() == 1, "weapon damage: broken weapon returns fallback 1")

func test_weapon_damage_no_gear_returns_one() -> void:
	var u := _make_unit()
	_assert(u.get_weapon_damage() == 1, "weapon damage: no weapon returns fallback 1")
