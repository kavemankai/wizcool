extends Node

const DEBUG_MODE: bool = false

var credits: int = 0
var vanguard_rank: int = 1
var crew: Array = []
var gear_inventory: Array[GearItem] = []
var broken_inventory: Array[GearItem] = []
var fractured_inventory: Array[GearItem] = []
var last_mission_result: Dictionary = {}
var pending_loot: Array[GearItem] = []

var current_campaign_id: String = "colony-repossession"
var current_mission_index: int = 0
var campaigns_completed: int = 0

# Player settings (persisted separately via SaveManager settings ConfigFile).
# Volumes are linear 0..1; music defaults quiet (~ -12 dB).
var sfx_volume: float = 1.0
var music_volume: float = 0.25
var ui_volume: float = 1.0
var show_cutaway: bool = true
