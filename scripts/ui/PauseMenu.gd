class_name PauseMenu
extends CanvasLayer

## In-mission pause overlay. Runs while the tree is paused
## (PROCESS_MODE_ALWAYS); Main owns the actual get_tree().paused flag.

signal resume_pressed
signal abandon_pressed

var _root: Control

func _ready() -> void:
	layer = 20
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	_root = Control.new()
	_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.0, 0.0, 0.0, 0.65)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_root.add_child(dim)

	var title := Label.new()
	title.position = Vector2(440, 140)
	title.size = Vector2(400, 48)
	title.text = "PAUSED"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 36)
	_root.add_child(title)

	_button("RESUME", 230, func() -> void:
		AudioManager.play_sfx("ui_click")
		resume_pressed.emit())
	_button("SETTINGS", 320, _open_settings)
	_button("ABANDON MISSION", 410, func() -> void:
		AudioManager.play_sfx("ui_click")
		abandon_pressed.emit())

func _open_settings() -> void:
	AudioManager.play_sfx("ui_click")
	var menu := SettingsMenu.new()
	_root.add_child(menu)

func _button(text: String, y: float, on_press: Callable) -> void:
	var btn := Button.new()
	btn.position = Vector2(440, y)
	btn.size = Vector2(400, 72)
	btn.text = text
	btn.add_theme_font_size_override("font_size", 24)
	btn.pressed.connect(on_press)
	_root.add_child(btn)
