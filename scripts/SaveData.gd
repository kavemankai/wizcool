class_name SaveData
extends RefCounted

const SAVE_PATH := "user://fringe_ledger.save"

static func load_rival_rank() -> int:
	if not FileAccess.file_exists(SAVE_PATH):
		return 1
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return 1
	var json_str := file.get_as_text()
	file.close()
	var parsed := JSON.parse_string(json_str)
	if parsed == null or not parsed is Dictionary:
		return 1
	return int(parsed.get("rival_rank", 1))

static func save_rival_rank(rank: int) -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	file.store_string(JSON.stringify({"rival_rank": rank}))
	file.close()
