extends Control

const FENCE_VALUE := 60
const REPAIR_COST := 80

var _credits: int = 0
var _credits_label: Label = null
var _ms: MissionState = null
var _all_crew_gear: Array = []

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.03, 0.04)
	add_child(bg)

	_ms = get_node("/root/MissionState")
	_credits = SaveData.load_credits()
	_all_crew_gear = SaveData.load_crew_gear()

	var vbox := VBoxContainer.new()
	vbox.set_position(Vector2(340, 50))
	vbox.set_size(Vector2(600, 620))
	add_child(vbox)

	_row(vbox, "═══════════ TERMINAL HUB ═══════════")
	_row(vbox, "")

	# Credits balance
	var credits_hbox := HBoxContainer.new()
	vbox.add_child(credits_hbox)
	_inline(credits_hbox, "CREDITS:  ")
	_credits_label = Label.new()
	_credits_label.text = str(_credits)
	credits_hbox.add_child(_credits_label)

	_row(vbox, "")
	_row(vbox, "── FENCE SALVAGE ──")

	if _ms.loot.is_empty():
		_row(vbox, "  (no salvage recovered)")
	else:
		for loot_item: Dictionary in _ms.loot:
			_add_fence_row(vbox, loot_item)

	_row(vbox, "")
	_row(vbox, "── REPAIR BAY ──")

	var has_broken := false
	for crew_entry: Dictionary in _all_crew_gear:
		for item_data: Dictionary in crew_entry.get("gear", []):
			if item_data.get("state", "") == "BROKEN":
				_add_repair_row(vbox, crew_entry.get("unit_id", "?"), item_data)
				has_broken = true
	if not has_broken:
		_row(vbox, "  (all gear operational)")

	_row(vbox, "")
	_row(vbox, "── CONTRACT SELECT ──")
	_row(vbox, "  [ACTIVE]  CONTAINMENT BREACH  —  Industrial Detention Facility Block 7")
	_row(vbox, "")

	var depart_btn := Button.new()
	depart_btn.text = "DEPART"
	depart_btn.custom_minimum_size = Vector2(0, 40)
	depart_btn.pressed.connect(_on_depart)
	vbox.add_child(depart_btn)

func _add_fence_row(parent: VBoxContainer, loot_item: Dictionary) -> void:
	var hbox := HBoxContainer.new()
	parent.add_child(hbox)
	var item_id: String = loot_item.get("item_id", "?")
	var slot: String = loot_item.get("slot", "?").to_upper()

	var lbl := Label.new()
	lbl.text = "  %s [%s]" % [item_id, slot]
	lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hbox.add_child(lbl)

	var val_lbl := Label.new()
	val_lbl.text = "+%d cr" % FENCE_VALUE
	hbox.add_child(val_lbl)

	var btn := Button.new()
	btn.text = "FENCE"
	btn.pressed.connect(func() -> void:
		_credits += FENCE_VALUE
		_credits_label.text = str(_credits)
		SaveData.save_credits(_credits)
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
	btn.pressed.connect(func() -> void:
		if _credits < REPAIR_COST:
			lbl.text = lbl.text + "  [INSUFFICIENT FUNDS]"
			return
		_credits -= REPAIR_COST
		_credits_label.text = str(_credits)
		SaveData.save_credits(_credits)
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
						and item_data.get("state", "") == "BROKEN":
					item_data["state"] = "INTACT"
					SaveData.save_crew_gear(_all_crew_gear)
					return

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
	get_node("/root/SceneTransition").change_to("res://scenes/SalvageManifest.tscn")
