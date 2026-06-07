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

	var rival_rank: int = get_node("/root/GameState").vanguard_rank

	_row(vbox, "═══════════ SALVAGE MANIFEST ═══════════")
	_row(vbox, "CONTRACT   :  CONTAINMENT BREACH")
	_row(vbox, "SITE       :  Industrial Detention Facility — Block 7")
	_row(vbox, "")
	_row(vbox, "OBJECTIVE")
	_row(vbox, "  Move leader to Evidence Locker in Zone C")
	_row(vbox, "  Extraction marker — centre of Zone C [col 5, row 2]")
	_row(vbox, "")
	_row(vbox, "ZONE LAYOUT")
	_row(vbox, "  Zone A  [rows 14–18]  — Player entry, Feral Prisoners")
	_row(vbox, "  Zone B  [rows  8–12]  — Security Bot patrol, hazard tiles")
	_row(vbox, "  Zone C  [rows  1– 6]  — Evidence locker [TARGET]")
	_row(vbox, "")
	_row(vbox, "THREAT LEVEL   :  VANGUARD RANK %d" % rival_rank)
	_row(vbox, "ROUND LIMIT    :  20")
	_row(vbox, "")
	_row(vbox, "FAILURE CONDITIONS")
	_row(vbox, "  — Leader downed while gear is Fractured")
	_row(vbox, "  — All crew downed")
	_row(vbox, "  — Round 20 expires without extraction")
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
