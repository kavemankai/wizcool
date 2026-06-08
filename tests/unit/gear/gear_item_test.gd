extends SceneTree

# Tests for GearItem.get_effective_modifier()
# Run: godot --headless --script tests/unit/gear/gear_item_test.gd

var _passed: int = 0
var _failed: int = 0

func _init() -> void:
	_run_all()
	print("\n=== GEAR ITEM TESTS: %d passed, %d failed ===" % [_passed, _failed])
	quit(1 if _failed > 0 else 0)

func _run_all() -> void:
	test_intact_returns_full_modifier()
	test_fractured_unpatched_returns_zero()
	test_fractured_patched_returns_half()
	test_broken_returns_zero()
	test_fractured_odd_modifier_rounds_down()
	test_armor_intact()
	test_medical_kit_modifier_zero()

func _assert(condition: bool, name: String) -> void:
	if condition:
		print("  PASS  %s" % name)
		_passed += 1
	else:
		print("  FAIL  %s" % name)
		_failed += 1

func test_intact_returns_full_modifier() -> void:
	var g := GearItem.make_weapon("TEST", 2, 3)
	g.state = GearItem.GearState.INTACT
	_assert(g.get_effective_modifier() == 2, "intact: returns full modifier")

func test_fractured_unpatched_returns_zero() -> void:
	var g := GearItem.make_weapon("TEST", 2, 3)
	g.state = GearItem.GearState.FRACTURED
	g.patched_this_mission = false
	_assert(g.get_effective_modifier() == 0, "fractured+unpatched: returns 0")

func test_fractured_patched_returns_half() -> void:
	var g := GearItem.make_weapon("TEST", 2, 3)
	g.state = GearItem.GearState.FRACTURED
	g.patched_this_mission = true
	_assert(g.get_effective_modifier() == 1, "fractured+patched: returns modifier/2")

func test_broken_returns_zero() -> void:
	var g := GearItem.make_weapon("TEST", 2, 3)
	g.state = GearItem.GearState.BROKEN
	_assert(g.get_effective_modifier() == 0, "broken: returns 0")

func test_fractured_odd_modifier_rounds_down() -> void:
	var g := GearItem.make_weapon("TEST", 3, 2)
	g.state = GearItem.GearState.FRACTURED
	g.patched_this_mission = true
	# integer division: 3 / 2 = 1
	_assert(g.get_effective_modifier() == 1, "fractured+patched odd modifier: rounds down")

func test_armor_intact() -> void:
	var g := GearItem.make_armor("WORK-HARNESS", 1)
	g.state = GearItem.GearState.INTACT
	_assert(g.get_effective_modifier() == 1, "armor intact: returns modifier")

func test_medical_kit_modifier_zero() -> void:
	var g := GearItem.make_medical_kit("FIELD-PATCH-KIT")
	_assert(g.get_effective_modifier() == 0, "medical kit: modifier always 0")
