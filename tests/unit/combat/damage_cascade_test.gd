extends SceneTree

# Tests for Unit.take_damage() — the gear-fracture cascade
# Run: godot --headless --script tests/unit/combat/damage_cascade_test.gd

var _passed: int = 0
var _failed: int = 0

func _init() -> void:
	_run_all()
	print("\n=== DAMAGE CASCADE TESTS: %d passed, %d failed ===" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)

func _run_all() -> void:
	test_normal_hit_reduces_toughness()
	test_normal_hit_returns_normal_result()
	test_intact_armor_fractures_before_weapon()
	test_intact_weapon_fractures_when_no_intact_armor()
	test_gear_fracture_resets_toughness_to_max()
	test_fractured_gear_breaks_on_zero_toughness()
	test_unit_downed_when_fractured_gear_breaks()
	test_unit_downed_when_no_gear()
	test_downed_unit_result_is_gear_broken()
	test_no_gear_downed_result_is_downed()

func _assert(condition: bool, name: String) -> void:
	if condition:
		print("  PASS  %s" % name)
		_passed += 1
	else:
		print("  FAIL  %s" % name)
		_failed += 1

func _make_unit(toughness: int, max_tgh: int) -> Unit:
	var u := Unit.new()
	u.toughness = toughness
	u.max_toughness = max_tgh
	return u

func _add_weapon(u: Unit, state: int) -> GearItem:
	var g := GearItem.make_weapon("W", 1, 2)
	g.state = state
	u.gear.append(g)
	return g

func _add_armor(u: Unit, state: int) -> GearItem:
	var g := GearItem.make_armor("A", 1)
	g.state = state
	u.gear.append(g)
	return g

func test_normal_hit_reduces_toughness() -> void:
	var u := _make_unit(5, 5)
	u.take_damage(2)
	_assert(u.toughness == 3, "normal hit: toughness reduced by damage")

func test_normal_hit_returns_normal_result() -> void:
	var u := _make_unit(5, 5)
	var result := u.take_damage(2)
	_assert(result == Unit.DamageResult.NORMAL, "normal hit: returns NORMAL")

func test_intact_armor_fractures_before_weapon() -> void:
	var u := _make_unit(1, 5)
	_add_armor(u, GearItem.GearState.INTACT)
	_add_weapon(u, GearItem.GearState.INTACT)
	var result := u.take_damage(2)
	_assert(result == Unit.DamageResult.GEAR_FRACTURED, "armor fractures first: returns GEAR_FRACTURED")
	_assert(u.gear[0].state == GearItem.GearState.FRACTURED, "armor fractures first: armor state is FRACTURED")
	_assert(u.gear[1].state == GearItem.GearState.INTACT, "armor fractures first: weapon stays INTACT")

func test_intact_weapon_fractures_when_no_intact_armor() -> void:
	var u := _make_unit(1, 5)
	_add_weapon(u, GearItem.GearState.INTACT)
	var result := u.take_damage(2)
	_assert(result == Unit.DamageResult.GEAR_FRACTURED, "weapon fractures (no armor): returns GEAR_FRACTURED")
	_assert(u.gear[0].state == GearItem.GearState.FRACTURED, "weapon fractures (no armor): weapon state is FRACTURED")

func test_gear_fracture_resets_toughness_to_max() -> void:
	var u := _make_unit(1, 5)
	_add_armor(u, GearItem.GearState.INTACT)
	u.take_damage(2)
	_assert(u.toughness == 5, "gear fracture: toughness resets to max_toughness")

func test_fractured_gear_breaks_on_zero_toughness() -> void:
	var u := _make_unit(1, 5)
	_add_armor(u, GearItem.GearState.FRACTURED)
	var result := u.take_damage(2)
	_assert(result == Unit.DamageResult.GEAR_BROKEN, "fractured gear breaks: returns GEAR_BROKEN")
	_assert(u.gear[0].state == GearItem.GearState.BROKEN, "fractured gear breaks: state is BROKEN")

func test_unit_downed_when_fractured_gear_breaks() -> void:
	var u := _make_unit(1, 5)
	_add_armor(u, GearItem.GearState.FRACTURED)
	u.take_damage(2)
	_assert(u.is_downed, "fractured gear breaks: unit is_downed")

func test_unit_downed_when_no_gear() -> void:
	var u := _make_unit(1, 5)
	u.take_damage(2)
	_assert(u.is_downed, "no gear: unit is_downed on lethal hit")

func test_downed_unit_result_is_gear_broken() -> void:
	var u := _make_unit(1, 5)
	_add_weapon(u, GearItem.GearState.FRACTURED)
	var result := u.take_damage(2)
	_assert(result == Unit.DamageResult.GEAR_BROKEN, "fractured weapon breaks: returns GEAR_BROKEN")

func test_no_gear_downed_result_is_downed() -> void:
	var u := _make_unit(1, 5)
	var result := u.take_damage(2)
	_assert(result == Unit.DamageResult.DOWNED, "no gear + lethal: returns DOWNED")
