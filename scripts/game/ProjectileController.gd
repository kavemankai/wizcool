extends CharacterBody2D

signal exited_left
signal exited_right

@export var speed: float = 500.0

# Soft bounds — exits here trigger damage (slightly outside arena walls)
const EXIT_LEFT: float = -15.0
const EXIT_RIGHT: float = 1295.0
# Hard bounds for wall bounce backup (should be handled by StaticBody2D walls)
const ARENA_TOP: float = 20.0
const ARENA_BOTTOM: float = 700.0

# Tags carried by this projectile — extended by upgrade system in Phase 3
var tags: Array[String] = []

var _active: bool = false

func _ready() -> void:
	set_active(false)

func reset() -> void:
	position = Vector2(640, 360)
	tags.clear()
	set_active(true)
	_launch()

func _launch() -> void:
	# Always travel mostly horizontally with a modest vertical component
	var angle = randf_range(deg_to_rad(-30), deg_to_rad(30))
	var dir = 1 if randi() % 2 == 0 else -1
	velocity = Vector2(dir * speed * cos(angle), speed * sin(angle))

func set_active(active: bool) -> void:
	_active = active
	visible = active
	set_physics_process(active)

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())

	# Backup wall bounce in case move_and_collide misses (tunnelling guard)
	if global_position.y <= ARENA_TOP:
		global_position.y = ARENA_TOP
		velocity.y = abs(velocity.y)
	elif global_position.y >= ARENA_BOTTOM:
		global_position.y = ARENA_BOTTOM
		velocity.y = -abs(velocity.y)

	# Exit detection — triggers damage in ArenaController
	if global_position.x < EXIT_LEFT:
		set_active(false)
		exited_left.emit()
	elif global_position.x > EXIT_RIGHT:
		set_active(false)
		exited_right.emit()
