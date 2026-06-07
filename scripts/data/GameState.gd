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
