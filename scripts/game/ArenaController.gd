extends Node2D

@onready var player_barrier: CharacterBody2D = $PlayerBarrier
@onready var enemy_barrier: CharacterBody2D = $EnemyBarrier
@onready var projectile: CharacterBody2D = $Projectile
@onready var hud = $HUD
@onready var enemy_ai = $EnemyAI

var player_hp: int = 100
var enemy_hp: int = 100
var game_active: bool = false

func _ready() -> void:
	hud.update_player_hp(player_hp)
	hud.update_enemy_hp(enemy_hp)
	# Wire enemy AI references
	enemy_ai.setup(enemy_barrier, projectile)
	# Connect projectile exit signals
	projectile.exited_left.connect(_on_projectile_exited_left)
	projectile.exited_right.connect(_on_projectile_exited_right)
	# Brief pause then start
	await get_tree().create_timer(0.8).timeout
	_start_round()

func _start_round() -> void:
	game_active = true
	projectile.reset()

func _on_projectile_exited_left() -> void:
	if not game_active:
		return
	_apply_damage("player", 10)

func _on_projectile_exited_right() -> void:
	if not game_active:
		return
	_apply_damage("enemy", 10)

func _apply_damage(target: String, amount: int) -> void:
	game_active = false
	if target == "player":
		player_hp -= amount
		player_hp = max(player_hp, 0)
		hud.update_player_hp(player_hp)
		if player_hp <= 0:
			_end_game("DEFEAT")
			return
	else:
		enemy_hp -= amount
		enemy_hp = max(enemy_hp, 0)
		hud.update_enemy_hp(enemy_hp)
		if enemy_hp <= 0:
			_end_game("VICTORY")
			return
	# Resume after short pause
	await get_tree().create_timer(0.5).timeout
	_start_round()

func _end_game(result: String) -> void:
	projectile.set_active(false)
	print(result)
	hud.show_result(result)
