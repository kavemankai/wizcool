extends Node

const SAVE_PATH := "user://fringe_ledger_save.json"
const STARTING_CREDITS := 200

func _ready() -> void:
	load_save()

func save() -> void:
	var gs := GameState
	var crew_data: Array = []
	for entry: Dictionary in gs.crew:
		var gear_data: Array = []
		for item: Dictionary in entry.get("gear", []):
			gear_data.append({
				"item_id": item.get("item_id", ""),
				"slot": item.get("slot", ""),
				"state": _state_to_str(item.get("state", GearItem.GearState.INTACT)),
			})
		crew_data.append({
			"unit_id": entry.get("unit_id", ""),
			"is_leader": entry.get("is_leader", false),
			"gear": gear_data,
		})
	var data: Dictionary = {
		"credits": gs.credits,
		"vanguard_rank": gs.vanguard_rank,
		"current_campaign_id": gs.current_campaign_id,
		"current_mission_index": gs.current_mission_index,
		"campaigns_completed": gs.campaigns_completed,
		"crew": crew_data,
	}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify(data))
		f.close()

func load_save() -> void:
	var gs := GameState
	gs.credits = STARTING_CREDITS
	gs.vanguard_rank = 1
	gs.crew = []
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not f:
		return
	var text := f.get_as_text()
	f.close()
	var parsed: Variant = JSON.parse_string(text)
	if parsed == null or not parsed is Dictionary:
		return
	var result: Dictionary = parsed
	gs.credits = result.get("credits", STARTING_CREDITS)
	gs.vanguard_rank = result.get("vanguard_rank", 1)
	gs.current_campaign_id = result.get("current_campaign_id", "containment-breach")
	gs.current_mission_index = result.get("current_mission_index", 0)
	gs.campaigns_completed = result.get("campaigns_completed", 0)
	var raw_crew: Array = result.get("crew", [])
	for entry: Dictionary in raw_crew:
		var gear_data: Array = []
		for item: Dictionary in entry.get("gear", []):
			gear_data.append({
				"item_id": item.get("item_id", ""),
				"slot": item.get("slot", ""),
				"state": _state_from_str(item.get("state", "INTACT")),
			})
		gs.crew.append({
			"unit_id": entry.get("unit_id", ""),
			"is_leader": entry.get("is_leader", false),
			"gear": gear_data,
		})

static func _state_to_str(state: int) -> String:
	match state:
		GearItem.GearState.FRACTURED: return "FRACTURED"
		GearItem.GearState.BROKEN:    return "BROKEN"
	return "INTACT"

static func _state_from_str(s: String) -> int:
	match s:
		"FRACTURED": return GearItem.GearState.FRACTURED
		"BROKEN":    return GearItem.GearState.BROKEN
	return GearItem.GearState.INTACT
