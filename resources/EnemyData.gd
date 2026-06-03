# Phase 4 — Resource class for enemy definitions
class_name EnemyData
extends Resource

@export var id: String
@export var name: String
@export var hp: int = 100
@export var ability_script: String
@export var projectile_modifiers: Array[String]
