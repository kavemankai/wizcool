extends Node

var success: bool = false
var fail_reason: String = ""
var crew_snapshot: Array[Dictionary] = []
var loot: Array[String] = []
var rival_rank: int = 1

func record_result(
		is_success: bool,
		reason: String,
		crew: Array,
		dropped: Array,
		rank: int
) -> void:
	success = is_success
	fail_reason = reason
	rival_rank = rank
	loot = []
	for item in dropped:
		loot.append(item.item_id)
	crew_snapshot = []
	for u in crew:
		var entry: Dictionary = {"unit_id": u.unit_id, "is_leader": u.is_leader, "gear": []}
		for item in u.gear:
			entry["gear"].append({
				"item_id": item.item_id,
				"slot": item.slot,
				"state": item.state_label()
			})
		crew_snapshot.append(entry)
