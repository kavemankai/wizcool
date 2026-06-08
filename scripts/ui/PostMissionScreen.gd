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

	var gs := GameState
	var result: Dictionary = gs.last_mission_result
	var success: bool = result.get("success", false)
	var campaign_complete: bool = result.get("campaign_complete", false)

	if success:
		if campaign_complete:
			_row(vbox, "═══════ CAMPAIGN COMPLETE ═══════")
			_row(vbox, "DANGER PAY: +%d CREDITS" % result.get("danger_pay", 0))
			_row(vbox, "VANGUARD RANK → %d" % result.get("rival_rank", 1))
		else:
			var next_idx: int = gs.current_mission_index
			var mission_count: int = CampaignData.get_mission_count(gs.current_campaign_id)
			var next_mission: Dictionary = CampaignData.get_mission(gs.current_campaign_id, next_idx)
			_row(vbox, "═══════ MISSION COMPLETE ═══════")
			_row(vbox, "NEXT: MISSION %d/%d — %s" % [
				next_idx + 1, mission_count, next_mission.get("title", "")
			])
	else:
		_row(vbox, "═══════ MISSION FAILED ═══════")
		_row(vbox, "REASON: " + result.get("fail_reason", ""))

	_row(vbox, "")
	_row(vbox, "── CREW GEAR REPORT ──")

	for entry: Dictionary in gs.crew:
		var tag: String = " [LEADER]" if entry.get("is_leader", false) else ""
		_row(vbox, entry.get("unit_id", "?") + tag)
		for item: Dictionary in entry.get("gear", []):
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

	_row(vbox, "")

	if success:
		var proceed_btn := Button.new()
		proceed_btn.text = "PROCEED TO TERMINAL HUB"
		proceed_btn.custom_minimum_size = Vector2(0, 40)
		proceed_btn.pressed.connect(_on_continue)
		vbox.add_child(proceed_btn)
	else:
		var retry_btn := Button.new()
		retry_btn.text = "RETRY MISSION"
		retry_btn.custom_minimum_size = Vector2(0, 40)
		retry_btn.pressed.connect(_on_retry)
		vbox.add_child(retry_btn)

		_row(vbox, "")
		_row(vbox, "── ABANDON PENALTY ──")
		_row(vbox, "  All INTACT gear → FRACTURED")
		_row(vbox, "  Danger Pay forfeit")
		_row(vbox, "  Campaign resets to Mission 1")
		_row(vbox, "")

		var abandon_btn := Button.new()
		abandon_btn.text = "ABANDON CAMPAIGN"
		abandon_btn.custom_minimum_size = Vector2(0, 40)
		abandon_btn.pressed.connect(_on_abandon)
		vbox.add_child(abandon_btn)

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

func _on_retry() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_abandon() -> void:
	var gs := GameState
	var sm := SaveManager
	for entry: Dictionary in gs.crew:
		for item: Dictionary in entry.get("gear", []):
			if item.get("state", GearItem.GearState.INTACT) == GearItem.GearState.INTACT:
				item["state"] = GearItem.GearState.FRACTURED
	gs.current_mission_index = 0
	sm.save()
	get_tree().change_scene_to_file("res://scenes/ui/TerminalHub.tscn")
