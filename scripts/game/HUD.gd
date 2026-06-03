extends CanvasLayer

@onready var player_hp_label: Label = $PlayerHP
@onready var enemy_hp_label: Label = $EnemyHP
@onready var result_label: Label = $ResultLabel

func update_player_hp(hp: int) -> void:
	player_hp_label.text = "Player  %d / 100" % hp

func update_enemy_hp(hp: int) -> void:
	enemy_hp_label.text = "%d / 100  Enemy" % hp

func show_result(text: String) -> void:
	result_label.text = text
	result_label.visible = true
