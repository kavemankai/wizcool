class_name SettingsMenu
extends Control

## Reusable settings overlay — used by the title screen and the in-mission
## pause menu. Pure UI: edits GameState settings fields, applies volumes
## live via AudioManager, persists via SaveManager on close.

signal closed

const _PANEL_BG := Color(0.07, 0.07, 0.09, 0.97)
const _DIM := Color(0.0, 0.0, 0.0, 0.55)
const _TEXT := Color(0.85, 0.80, 0.70)

var _cutaway_btn: Button

func _ready() -> void:
	set_anchors_preset(Control.PRESET_FULL_RECT)
	mouse_filter = Control.MOUSE_FILTER_STOP  # swallow taps behind the panel

	var dim := ColorRect.new()
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	dim.color = _DIM
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(dim)

	var panel := Panel.new()
	panel.position = Vector2(340, 80)
	panel.size = Vector2(600, 560)
	var style := StyleBoxFlat.new()
	style.bg_color = _PANEL_BG
	style.border_color = Color(0.35, 0.35, 0.38)
	style.set_border_width_all(1)
	panel.add_theme_stylebox_override("panel", style)
	add_child(panel)

	var title := _label(panel, Rect2(0, 18, 600, 36), "SETTINGS", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	_slider_row(panel, 90, "SFX VOLUME", GameState.sfx_volume,
			func(v: float) -> void:
				GameState.sfx_volume = v
				AudioManager.apply_volumes())
	_slider_row(panel, 190, "MUSIC VOLUME", GameState.music_volume,
			func(v: float) -> void:
				GameState.music_volume = v
				AudioManager.apply_volumes())
	_slider_row(panel, 290, "UI VOLUME", GameState.ui_volume,
			func(v: float) -> void:
				GameState.ui_volume = v
				AudioManager.apply_volumes())

	_cutaway_btn = Button.new()
	_cutaway_btn.position = Vector2(50, 392)
	_cutaway_btn.size = Vector2(500, 64)
	_cutaway_btn.add_theme_font_size_override("font_size", 22)
	_refresh_cutaway_text()
	_cutaway_btn.pressed.connect(func() -> void:
		GameState.show_cutaway = not GameState.show_cutaway
		AudioManager.play_sfx("ui_click")
		_refresh_cutaway_text())
	panel.add_child(_cutaway_btn)

	var close_btn := Button.new()
	close_btn.position = Vector2(50, 472)
	close_btn.size = Vector2(500, 64)
	close_btn.text = "CLOSE"
	close_btn.add_theme_font_size_override("font_size", 24)
	close_btn.pressed.connect(_close)
	panel.add_child(close_btn)

func _close() -> void:
	AudioManager.play_sfx("ui_click")
	SaveManager.save_settings()
	closed.emit()
	queue_free()

func _refresh_cutaway_text() -> void:
	_cutaway_btn.text = "COMBAT CUTAWAY: %s" % ("ON" if GameState.show_cutaway else "OFF")

func _slider_row(parent: Control, y: float, text: String, value: float,
		on_change: Callable) -> void:
	_label(parent, Rect2(50, y, 500, 24), text, 20)
	var slider := HSlider.new()
	slider.position = Vector2(50, y + 30)
	slider.size = Vector2(500, 48)
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.05
	slider.value = value
	slider.value_changed.connect(on_change)
	parent.add_child(slider)

func _label(parent: Control, rect: Rect2, text: String, fsize: int) -> Label:
	var lbl := Label.new()
	lbl.position = rect.position
	lbl.size = rect.size
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", fsize)
	lbl.add_theme_color_override("font_color", _TEXT)
	parent.add_child(lbl)
	return lbl
