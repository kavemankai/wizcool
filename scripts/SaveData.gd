class_name SaveData
extends RefCounted

const SAVE_PATH := "user://fringe_ledger.save"
const STARTING_CREDITS := 200

static func _read() -> Dictionary:
	if not FileAccess.file_exists(SAVE_PATH):
		return {}
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	file.close()
	if not parsed is Dictionary:
		return {}
	return parsed

static func _write(data: Dictionary) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

static func load_rival_rank() -> int:
	return int(_read().get("rival_rank", 1))

static func save_rival_rank(rank: int) -> void:
	var d := _read()
	d["rival_rank"] = rank
	_write(d)

static func load_credits() -> int:
	return int(_read().get("credits", STARTING_CREDITS))

static func save_credits(credits: int) -> void:
	var d := _read()
	d["credits"] = credits
	_write(d)

# Crew gear format:
# Array of { unit_id: String, is_leader: bool, gear: Array of { item_id, slot, state } }
# where state is "INTACT" | "FRACTURED" | "BROKEN"
static func load_crew_gear() -> Array:
	var v: Variant = _read().get("crew_gear", [])
	if v is Array:
		return v
	return []

static func save_crew_gear(crew_data: Array) -> void:
	var d := _read()
	d["crew_gear"] = crew_data
	_write(d)
