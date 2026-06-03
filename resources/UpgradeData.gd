# Phase 3 — Resource class for all upgrade definitions
# Adding upgrade #50 must be a .tres data file, not new code
class_name UpgradeData
extends Resource

@export var id: String
@export var name: String
@export var description: String
@export_enum("Common", "Uncommon", "Rare") var tier: String
@export var tags: Array[String]
@export var visual_effect: String  # REQUIRED — empty string = upgrade does not ship
@export var apply_script: String   # method name in UpgradeSystem.gd
