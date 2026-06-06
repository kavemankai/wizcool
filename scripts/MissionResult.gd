extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.03, 0.04)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_position(Vector2(380, 80))
	vbox.set_size(Vector2(520, 600))
	add_child(vbox)

	var ms: MissionState = get_node("/root/MissionState")

	if ms.success:
		_row(vbox, "═══════ MISSION COMPLETE ═══════")
		_row(vbox, "EVIDENCE SECURED — CREW EXTRACTED")
		_row(vbox, "DANGER PAY: +%d CREDITS" % ms.danger_pay)
	else:
		_row(vbox, "═══════ MISSION FAILED ═══════")
		_row(vbox, "REASON: " + ms.fail_reason)

	_row(vbox, "")
	_row(vbox, "── CREW GEAR REPORT ──")

	for entry: Dictionary in ms.crew_snapshot:
		var tag: String = " [LEADER]" if entry.get("is_leader", false) else ""
		_row(vbox, entry.get("unit_id", "?") + tag)
		var gear_list: Array = entry.get("gear", [])
		if gear_list.is_empty():
			_row(vbox, "  (no gear)")
		else:
			for item: Dictionary in gear_list:
				_row(vbox, "  %-24s [%s]  %s" % [
					item.get("item_id", "?"),
					item.get("slot", "?").to_upper(),
					item.get("state", "?")
				])

	if ms.loot.size() > 0:
		_row(vbox, "")
		_row(vbox, "── LOOT RECOVERED ──")
		for loot_item: Dictionary in ms.loot:
			_row(vbox, "  %s [%s]" % [
				loot_item.get("item_id", "?"),
				loot_item.get("slot", "?").to_upper()
			])

	if not ms.success:
		_row(vbox, "")
		_row(vbox, "── CONSEQUENCES ──")
		_row(vbox, "  All crew gear FRACTURED on deployment")
		_row(vbox, "  No Danger Pay")
		_row(vbox, "  VANGUARD RANK → %d" % ms.rival_rank)

	_row(vbox, "")

	var btn := Button.new()
	btn.text = "PROCEED TO TERMINAL HUB"
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(_on_continue)
	vbox.add_child(btn)

func _row(parent: Control, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	parent.add_child(lbl)

func _on_continue() -> void:
	get_node("/root/SceneTransition").change_to("res://scenes/TerminalHub.tscn")
