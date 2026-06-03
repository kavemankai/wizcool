extends Node

# Scale these per duel number in Phase 2 via RunManager
@export var reaction_speed: float = 250.0
@export var jitter_amount: float = 35.0

var _barrier: CharacterBody2D
var _projectile: CharacterBody2D

func setup(barrier: CharacterBody2D, projectile: CharacterBody2D) -> void:
	_barrier = barrier
	_projectile = projectile

func _physics_process(_delta: float) -> void:
	if not is_instance_valid(_barrier) or not is_instance_valid(_projectile):
		return
	if not _projectile.visible:
		_barrier.velocity.y = 0.0
		return

	# Track projectile Y with a randomised offset to simulate imperfect reaction
	var target_y = _projectile.global_position.y + randf_range(-jitter_amount, jitter_amount)
	var diff = target_y - _barrier.global_position.y

	# Dead zone so the barrier doesn't jitter on spot
	if abs(diff) > 10.0:
		_barrier.velocity.y = sign(diff) * reaction_speed
	else:
		_barrier.velocity.y = 0.0
