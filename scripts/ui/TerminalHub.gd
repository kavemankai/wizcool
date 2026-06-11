extends Control

const FENCE_VALUE := 60
const REPAIR_COST := 80

var _credits: int = 0
var _credits_label: Label = null
var _gs: Node = null
var _sm: Node = null
var _all_crew_gear: Array = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.03, 0.04)
	add_child(bg)

	_gs = GameState
	_sm = SaveManager
	_credits = _gs.credits
	_all_crew_gear = _gs.crew

	var vbox := VBoxContainer.new()
	vbox.set_position(Vector2(340, 50))
	vbox.set_size(Vector2(600, 620))
	add_child(vbox)

	_row(vbox, "═══════════ TERMINAL HUB ═══════════")
	_row(vbox, "")

	var credits_hbox := HBoxContainer.new()
	vbox.add_child(credits_hbox)
	_inline(credits_hbox, "CREDITS:  ")
	_credits_label = Label.new()
	_credits_label.text = str(_credits)
	credits_hbox.add_child(_credits_label)

	_row(vbox, "")
	_row(vbox, "── FENCE SALVAGE ──")

	if _gs.pending_loot.is_empty():
		_row(vbox, "  (no salvage recovered)")
	else:
		for gear_item: GearItem in _gs.pending_loot:
			_add_fence_row(vbox, gear_item)

	_row(vbox, "")
	_row(vbox, "── REPAIR BAY ──")

	var has_broken := false
	for crew_entry: Dictionary in _all_crew_gear:
		for item_data: Dictionary in crew_entry.get("gear", []):
			if item_data.get("state", GearItem.GearState.INTACT) == GearItem.GearState.BROKEN:
				_add_repair_row(vbox, crew_entry.get("unit_id", "?"), item_data)
				has_broken = true
	if not has_broken:
		_row(vbox, "  (all gear operational)")

	_row(vbox, "")
	_row(vbox, "── CONTRACT SELECT ──")
	# Beginner job is always open; other contracts unlock after the first
	# completed campaign. Switching contracts resets that contract to mission 1.
	var unlocked: bool = _gs.campaigns_completed >= 1
	for cid: String in CampaignData.all_campaign_ids():
		var c := CampaignData.get_campaign(cid)
		var count := CampaignData.get_mission_count(cid)
		if cid == _gs.current_campaign_id:
			var idx: int = _gs.current_mission_index
			var cur := CampaignData.get_mission(cid, idx)
			_row(vbox, "  [ACTIVE]  %s  —  MISSION %d/%d: %s" % [
					c.get("title", ""), idx + 1, count, cur.get("title", "")])
		elif cid == "colony-repossession" or unlocked:
			_add_contract_row(vbox, cid, c.get("title", ""))
		else:
			_row(vbox, "  [LOCKED]  %s  —  complete a contract to unlock" % c.get("title", ""))
	_row(vbox, "")

	var depart_btn := Button.new()
	depart_btn.text = "DEPART"
	depart_btn.custom_minimum_size = Vector2(0, 72)
	depart_btn.add_theme_font_size_override("font_size", 24)
	depart_btn.pressed.connect(_on_depart)
	vbox.add_child(depart_btn)

func _add_fence_row(parent: VBoxContainer, gear_item: GearItem) -> void:
	var hbox := HBoxContainer.new()
	parent.add_child(hbox)

	var lbl := Label.new()
	lbl.text = "  %s [%s]" % [gear_item.item_id, gear_item.slot.to_upper()]
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	var val_lbl := Label.new()
	val_lbl.text = "+%d cr" % FENCE_VALUE
	hbox.add_child(val_lbl)

	var btn := Button.new()
	btn.text = "FENCE"
	btn.custom_minimum_size = Vector2(120, 64)
	btn.pressed.connect(func() -> void:
		_credits += FENCE_VALUE
		_credits_label.text = str(_credits)
		_gs.credits = _credits
		_sm.save()
		lbl.text = lbl.text + "  [SOLD]"
		btn.disabled = true
		val_lbl.text = ""
	)
	hbox.add_child(btn)

func _add_repair_row(parent: VBoxContainer, unit_id: String, item_data: Dictionary) -> void:
	var hbox := HBoxContainer.new()
	parent.add_child(hbox)
	var item_id: String = item_data.get("item_id", "?")

	var lbl := Label.new()
	lbl.text = "  %-8s  %s  [BROKEN]" % [unit_id, item_id]
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	var cost_lbl := Label.new()
	cost_lbl.text = "-%d cr" % REPAIR_COST
	hbox.add_child(cost_lbl)

	var btn := Button.new()
	btn.text = "REPAIR"
	btn.custom_minimum_size = Vector2(120, 64)
	btn.pressed.connect(func() -> void:
		if _credits < REPAIR_COST:
			lbl.text = lbl.text + "  [INSUFFICIENT FUNDS]"
			return
		_credits -= REPAIR_COST
		_credits_label.text = str(_credits)
		_gs.credits = _credits
		_do_repair(unit_id, item_id)
		lbl.text = lbl.text.replace("[BROKEN]", "[REPAIRED]")
		btn.disabled = true
		cost_lbl.text = ""
	)
	hbox.add_child(btn)

func _do_repair(unit_id: String, item_id: String) -> void:
	for crew_entry: Dictionary in _all_crew_gear:
		if crew_entry.get("unit_id", "") == unit_id:
			for item_data: Dictionary in crew_entry.get("gear", []):
				if item_data.get("item_id", "") == item_id \
						and item_data.get("state", GearItem.GearState.INTACT) == GearItem.GearState.BROKEN:
					item_data["state"] = GearItem.GearState.INTACT
					_gs.crew = _all_crew_gear
					_sm.save()
					return

## A selectable contract row: shows the title with a TAKE button that makes
## it the active campaign (from its first mission) and saves immediately.
func _add_contract_row(parent: VBoxContainer, cid: String, title: String) -> void:
	var hbox := HBoxContainer.new()
	parent.add_child(hbox)

	var lbl := Label.new()
	lbl.text = "  %s" % title
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	var btn := Button.new()
	btn.text = "TAKE CONTRACT"
	btn.custom_minimum_size = Vector2(180, 64)
	btn.pressed.connect(func() -> void:
		AudioManager.play_sfx("ui_click")
		_gs.current_campaign_id = cid
		_gs.current_mission_index = 0
		_sm.save()
		get_tree().reload_current_scene()
	)
	hbox.add_child(btn)

func _row(parent: Control, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	parent.add_child(lbl)

func _inline(parent: Control, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	parent.add_child(lbl)

func _on_depart() -> void:
	AudioManager.play_sfx("ui_click")
	get_tree().change_scene_to_file("res://scenes/ui/ManifestScreen.tscn")

## Android back button → return to the title screen.
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().change_scene_to_file("res://scenes/ui/TitleScreen.tscn")
