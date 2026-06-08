class_name GearItem
extends RefCounted

enum GearState { INTACT, FRACTURED, BROKEN }

var item_id: String = ""
var slot: String = "weapon"          # "weapon" | "armor" | "medical"
var stat_target: String = "combat_skill"  # "combat_skill" | "speed"
var modifier: int = 0
var damage: int = 2                  # weapon hit damage; ignored for non-weapons
var state: int = GearState.INTACT
var patched_this_mission: bool = false
var special: WeaponSpecial = null    # null when the weapon has no special ability

static func make_weapon(id: String, mod: int, dmg: int) -> GearItem:
	var g := GearItem.new()
	g.item_id = id
	g.slot = "weapon"
	g.stat_target = "combat_skill"
	g.modifier = mod
	g.damage = dmg
	return g

static func make_armor(id: String, mod: int) -> GearItem:
	var g := GearItem.new()
	g.item_id = id
	g.slot = "armor"
	g.stat_target = "speed"
	g.modifier = mod
	return g

func get_effective_modifier() -> int:
	match state:
		GearState.INTACT:
			return modifier
		GearState.FRACTURED:
			if patched_this_mission:
				return modifier / 2
			return 0
		GearState.BROKEN:
			return 0
	return 0

static func make_medical_kit(id: String) -> GearItem:
	var g := GearItem.new()
	g.item_id = id
	g.slot = "medical"
	g.stat_target = "combat_skill"
	g.modifier = 0
	g.damage = 0
	return g

func state_label() -> String:
	match state:
		GearState.INTACT:    return "INTACT"
		GearState.FRACTURED: return "FRACTURED"
		GearState.BROKEN:    return "BROKEN"
	return ""
