extends Node

var success: bool = false
var fail_reason: String = ""
# [{unit_id, is_leader, gear: [{item_id, slot, state: "INTACT"|"FRACTURED"|"BROKEN"}]}]
var crew_snapshot: Array = []
# [{item_id, slot, state: "BROKEN"}]
var loot: Array = []
var rival_rank: int = 1
var danger_pay: int = 0

func record_result(
		is_success: bool,
		reason: String,
		crew_snap: Array,
		dropped: Array,
		rank: int,
		pay: int
) -> void:
	success = is_success
	fail_reason = reason
	rival_rank = rank
	danger_pay = pay
	loot = []
	for item in dropped:
		loot.append({"item_id": item.item_id, "slot": item.slot, "state": "BROKEN"})
	crew_snapshot = []
	for entry in crew_snap:
		crew_snapshot.append(entry)
