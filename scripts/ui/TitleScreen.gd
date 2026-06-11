extends Control

## Title screen — the app entry point. CONTINUE resumes the campaign save,
## NEW JOB starts fresh (confirming if a save exists), SETTINGS opens the
## shared overlay. Android back button raises the quit confirm.

const _TITLE_ART := "res://assets/sprites/title.png"

var _quit_dialog: ConfirmationDialog
var _newjob_dialog: ConfirmationDialog

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var bg := ColorRect.new()
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.color = Color(0.03, 0.03, 0.04)
	add_child(bg)

	# Painted title art when it exists; typographic title otherwise.
	if ResourceLoader.exists(_TITLE_ART):
		var art := TextureRect.new()
		art.set_anchors_preset(Control.PRESET_FULL_RECT)
		art.texture = load(_TITLE_ART)
		art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		add_child(art)

	var title := Label.new()
	title.position = Vector2(0, 120)
	title.size = Vector2(1280, 80)
	title.text = "FRINGE LEDGER"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 64)
	title.add_theme_color_override("font_color", Color(0.85, 0.80, 0.70))
	add_child(title)

	var subtitle := Label.new()
	subtitle.position = Vector2(0, 205)
	subtitle.size = Vector2(1280, 30)
	subtitle.text = "SALVAGE · REPOSSESSION · RECOVERY"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	subtitle.add_theme_color_override("font_color", Color(0.45, 0.48, 0.52))
	add_child(subtitle)

	var y := 300.0
	if SaveManager.has_save():
		_button("CONTINUE", y, _on_continue)
		y += 86.0
	_button("NEW JOB", y, _on_new_job)
	_button("SETTINGS", y + 86.0, _on_settings)
	_button("QUIT", y + 172.0, func() -> void: _quit_dialog.popup_centered())

	_quit_dialog = ConfirmationDialog.new()
	_quit_dialog.dialog_text = "Quit Fringe Ledger?"
	_quit_dialog.confirmed.connect(func() -> void: get_tree().quit())
	add_child(_quit_dialog)

	_newjob_dialog = ConfirmationDialog.new()
	_newjob_dialog.dialog_text = "Start a new job?\nThe existing save will be erased."
	_newjob_dialog.confirmed.connect(_start_new_job)
	add_child(_newjob_dialog)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_quit_dialog.popup_centered()

func _on_continue() -> void:
	AudioManager.play_sfx("ui_click")
	get_tree().change_scene_to_file("res://scenes/ui/TerminalHub.tscn")

func _on_new_job() -> void:
	AudioManager.play_sfx("ui_click")
	if SaveManager.has_save():
		_newjob_dialog.popup_centered()
	else:
		_start_new_job()

func _start_new_job() -> void:
	SaveManager.delete_save()
	get_tree().change_scene_to_file("res://scenes/ui/TerminalHub.tscn")

func _on_settings() -> void:
	AudioManager.play_sfx("ui_click")
	add_child(SettingsMenu.new())

func _button(text: String, y: float, on_press: Callable) -> void:
	var btn := Button.new()
	btn.position = Vector2(440, y)
	btn.size = Vector2(400, 72)
	btn.text = text
	btn.add_theme_font_size_override("font_size", 24)
	btn.pressed.connect(on_press)
	add_child(btn)
