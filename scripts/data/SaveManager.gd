extends Node

const SAVE_PATH := "user://fringe_ledger_save.json"
const SETTINGS_PATH := "user://settings.cfg"
const STARTING_CREDITS := 200

func _ready() -> void:
	load_save()
	load_settings()

## True when a campaign save exists on disk (drives the title CONTINUE button).
func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Delete the campaign save and reset run state (title NEW JOB).
func delete_save() -> void:
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	var gs := GameState
	gs.credits = STARTING_CREDITS
	gs.vanguard_rank = 1
	gs.crew = []
	gs.pending_loot = []
	gs.last_mission_result = {}
	gs.current_campaign_id = "colony-repossession"
	gs.current_mission_index = 0
	gs.campaigns_completed = 0

## Persist player settings (volumes, cutaway toggle) to a ConfigFile —
## deliberately separate from the campaign save.
func save_settings() -> void:
	var cfg := ConfigFile.new()
	var gs := GameState
	cfg.set_value("audio", "sfx_volume", gs.sfx_volume)
	cfg.set_value("audio", "music_volume", gs.music_volume)
	cfg.set_value("audio", "ui_volume", gs.ui_volume)
	cfg.set_value("gameplay", "show_cutaway", gs.show_cutaway)
	cfg.save(SETTINGS_PATH)

func load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	var gs := GameState
	gs.sfx_volume = clampf(cfg.get_value("audio", "sfx_volume", gs.sfx_volume), 0.0, 1.0)
	gs.music_volume = clampf(cfg.get_value("audio", "music_volume", gs.music_volume), 0.0, 1.0)
	gs.ui_volume = clampf(cfg.get_value("audio", "ui_volume", gs.ui_volume), 0.0, 1.0)
	gs.show_cutaway = cfg.get_value("gameplay", "show_cutaway", gs.show_cutaway)

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
	gs.current_campaign_id = result.get("current_campaign_id", "colony-repossession")
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
