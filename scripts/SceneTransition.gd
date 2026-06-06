extends CanvasLayer

var _overlay: ColorRect
var _tween: Tween = null

func _ready() -> void:
	layer = 100
	_overlay = ColorRect.new()
	_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_overlay.color = Color.BLACK
	_overlay.modulate.a = 1.0
	_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_overlay)
	_start_fade_in()

func change_to(path: String) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_overlay, "modulate:a", 1.0, 0.3)
	_tween.tween_callback(get_tree().change_scene_to_file.bind(path))
	_tween.tween_interval(0.05)
	_tween.tween_property(_overlay, "modulate:a", 0.0, 0.4)

func _start_fade_in() -> void:
	if _tween:
		_tween.kill()
	_overlay.modulate.a = 1.0
	_tween = create_tween()
	_tween.tween_property(_overlay, "modulate:a", 0.0, 0.4)
