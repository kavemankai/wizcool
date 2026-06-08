extends Control

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.03, 0.04)
	add_child(bg)

	var vbox := VBoxContainer.new()
	vbox.set_position(Vector2(380, 60))
	vbox.set_size(Vector2(520, 600))
	add_child(vbox)

	var gs: Node = get_node("/root/GameState")
	var camp := CampaignData.get_campaign(gs.current_campaign_id)
	var mission_count := CampaignData.get_mission_count(gs.current_campaign_id)
	var mission := CampaignData.get_mission(gs.current_campaign_id, gs.current_mission_index)

	_row(vbox, "═══════════ SALVAGE MANIFEST ═══════════")
	_row(vbox, "CONTRACT   :  %s" % camp.get("title", ""))
	_row(vbox, "SITE       :  %s" % camp.get("description", ""))
	_row(vbox, "MISSION    :  %d / %d  —  %s" % [gs.current_mission_index + 1, mission_count, mission.get("title", "")])
	_row(vbox, "")
	_row(vbox, "OBJECTIVE")
	_row(vbox, "  " + mission.get("hud_objective", ""))
	_row(vbox, "")
	_row(vbox, "THREAT LEVEL   :  VANGUARD RANK %d" % gs.vanguard_rank)
	_row(vbox, "ROUND LIMIT    :  20")
	_row(vbox, "")
	_row(vbox, "FAILURE CONDITIONS")
	_row(vbox, "  — Leader downed while gear is Fractured")
	_row(vbox, "  — All crew downed")
	_row(vbox, "  — Round 20 expires")
	_row(vbox, "")

	var btn := Button.new()
	btn.text = "BEGIN MISSION"
	btn.custom_minimum_size = Vector2(0, 40)
	btn.pressed.connect(_on_begin)
	vbox.add_child(btn)

func _row(parent: Control, text: String) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.autowrap_mode = TextServer.AUTOWRAP_WORD
	parent.add_child(lbl)

func _on_begin() -> void:
	get_tree().change_scene_to_file("res://scenes/Main.tscn")
