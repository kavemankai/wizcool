extends CharacterBody2D

@export var speed: float = 400.0

const ARENA_TOP: float = 20.0
const ARENA_BOTTOM: float = 700.0
const HALF_HEIGHT: float = 100.0

# Detected in _ready from node name — no scene-file property overrides needed
var _is_player: bool = false

func _ready() -> void:
	_is_player = (name == "PlayerBarrier")

func _physics_process(_delta: float) -> void:
	if _is_player:
		_handle_player_input()
	# Enemy barrier: velocity.y is written by EnemyAI.gd each frame before this runs

	position.y = clamp(position.y, ARENA_TOP + HALF_HEIGHT, ARENA_BOTTOM - HALF_HEIGHT)
	velocity.x = 0.0
	move_and_slide()

func _handle_player_input() -> void:
	velocity.y = 0.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		velocity.y = -speed
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		velocity.y = speed
