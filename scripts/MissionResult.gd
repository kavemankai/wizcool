extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.03, 0.04)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_position(Vector2(380, 80))
	vbox.set_size(Vector2(520, 560))
	add_child(vbox)

	var ms: MissionState = get_node("/root/MissionState")

	if ms.success:
		_row(vbox, "═══════ MISSION COMPLETE ═══════")
		_row(vbox, "EXTRACTION SUCCESSFUL — EVIDENCE SECURED")
	else:
		_row(vbox, "═══════ MISSION FAILED ═══════")
		_row(vbox, "REASON: " + ms.fail_reason)

	_row(vbox, "")
	_row(vbox, "── CREW GEAR REPORT ──")

	for entry: Dictionary in ms.crew_snapshot:
		var tag: String = " [LEADER]" if entry.get("is_leader", false) else ""
		_row(vbox, entry["unit_id"] + tag)
		var gear_list: Array = entry.get("gear", [])
		if gear_list.is_empty():
			_row(vbox, "  (no gear)")
		else:
			for item: Dictionary in gear_list:
				_row(vbox, "  %-24s [%s]  %s" % [
					item["item_id"],
					item["slot"].to_upper(),
					item["state"]
				])

	if ms.loot.size() > 0:
		_row(vbox, "")
		_row(vbox, "── LOOT RECOVERED ──")
		for item_id: String in ms.loot:
			_row(vbox, "  " + item_id)

	if not ms.success:
		_row(vbox, "")
		_row(vbox, "── CONSEQUENCES ──")
		_row(vbox, "  All crew gear FRACTURED on next deployment")
		_row(vbox, "  No Danger Pay")
		_row(vbox, "  VANGUARD RANK → %d" % ms.rival_rank)

	_row(vbox, "")

	var btn := Button.new()
	btn.text = "CONTINUE"
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(_on_continue)
	vbox.add_child(btn)

func _row(parent: Control, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	parent.add_child(lbl)

func _on_continue() -> void:
	get_tree().change_scene_to_file("res://scenes/SalvageManifest.tscn")
