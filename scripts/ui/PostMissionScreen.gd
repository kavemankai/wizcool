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

	var gs: Node = get_node("/root/GameState")
	var result: Dictionary = gs.last_mission_result

	if result.get("success", false):
		_row(vbox, "═══════ MISSION COMPLETE ═══════")
		_row(vbox, "EVIDENCE SECURED — CREW EXTRACTED")
		_row(vbox, "DANGER PAY: +%d CREDITS" % result.get("danger_pay", 0))
	else:
		_row(vbox, "═══════ MISSION FAILED ═══════")
		_row(vbox, "REASON: " + result.get("fail_reason", ""))

	_row(vbox, "")
	_row(vbox, "── CREW GEAR REPORT ──")

	for entry: Dictionary in gs.crew:
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
					_state_label(item.get("state", GearItem.GearState.INTACT))
				])

	if gs.pending_loot.size() > 0:
		_row(vbox, "")
		_row(vbox, "── LOOT RECOVERED ──")
		for loot_item: GearItem in gs.pending_loot:
			_row(vbox, "  %s [%s]" % [loot_item.item_id, loot_item.slot.to_upper()])

	if not result.get("success", false):
		_row(vbox, "")
		_row(vbox, "── CONSEQUENCES ──")
		_row(vbox, "  All crew gear FRACTURED on deployment")
		_row(vbox, "  No Danger Pay")
		_row(vbox, "  VANGUARD RANK → %d" % result.get("rival_rank", 1))

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

func _state_label(state: int) -> String:
	match state:
		GearItem.GearState.INTACT:    return "INTACT"
		GearItem.GearState.FRACTURED: return "FRACTURED"
		GearItem.GearState.BROKEN:    return "BROKEN"
	return "?"

func _on_continue() -> void:
	get_tree().change_scene_to_file("res://scenes/ui/TerminalHub.tscn")
