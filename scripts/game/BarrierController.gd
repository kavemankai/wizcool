extends CharacterBody2D

@export var is_player: bool = true
@export var speed: float = 400.0

# Arena vertical bounds (top wall bottom edge, bottom wall top edge)
const ARENA_TOP: float = 20.0
const ARENA_BOTTOM: float = 700.0
const HALF_HEIGHT: float = 100.0  # Half of the 200px barrier height

func _physics_process(_delta: float) -> void:
	if is_player:
		_handle_player_input()
	# AI-controlled barrier: velocity.y is set externally by EnemyAI.gd each frame

	# Clamp so barrier never exits arena
	position.y = clamp(position.y, ARENA_TOP + HALF_HEIGHT, ARENA_BOTTOM - HALF_HEIGHT)
	velocity.x = 0.0  # Barriers only move vertically
	move_and_slide()

func _handle_player_input() -> void:
	velocity.y = 0.0
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		velocity.y = -speed
	elif Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		velocity.y = speed
