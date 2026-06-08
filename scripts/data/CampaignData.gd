class_name CampaignData
extends RefCounted

enum ObjectiveType { EXTRACTION, ELIMINATION, SURVIVAL, RETRIEVE }

static func get_campaign(campaign_id: String) -> Dictionary:
	match campaign_id:
		"containment-breach": return _containment_breach()
		"prison-break":       return _prison_break()
	push_warning("CampaignData: unknown campaign '%s'" % campaign_id)
	return {}

static func get_mission(campaign_id: String, index: int) -> Dictionary:
	var camp := get_campaign(campaign_id)
	var missions: Array = camp.get("missions", [])
	if index < 0 or index >= missions.size():
		push_warning("CampaignData: index %d out of range for '%s'" % [index, campaign_id])
		return missions[0] if missions.size() > 0 else {}
	return missions[index]

static func get_mission_count(campaign_id: String) -> int:
	return get_campaign(campaign_id).get("missions", []).size()

# ---------------------------------------------------------------------------
# Campaign 1 — Containment Breach
# ---------------------------------------------------------------------------

static func _containment_breach() -> Dictionary:
	return {
		"campaign_id": "containment-breach",
		"title": "CONTAINMENT BREACH",
		"description": "Industrial Detention Facility — Block 7",
		"danger_pay": 150,
		"missions": [_cb_1()],
	}

static func _cb_1() -> Dictionary:
	return {
		"mission_id": "cb-1",
		"title": "EVIDENCE RUN",
		"map_id": "map-prototype",
		"objective": ObjectiveType.EXTRACTION,
		"objective_data": {"target_tile": Vector2i(5, 2)},
		"hud_objective": "Move ALPHA to Evidence Locker — Zone C [col 5, row 2]",
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 17)},
			{"id": "BRAVO",   "pos": Vector2i(3, 16)},
			{"id": "CHARLIE", "pos": Vector2i(7, 16)},
		],
		"enemy_config": [
			{
				"id": "SENTINEL-1", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(3, 8),
				"zone_min": 8, "zone_max": 12,
				"patrol": [Vector2i(3, 8), Vector2i(3, 11)],
				"gear": [],
			},
			{
				"id": "SENTINEL-2", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(8, 8),
				"zone_min": 8, "zone_max": 12,
				"patrol": [Vector2i(8, 8), Vector2i(8, 11)],
				"gear": [],
			},
			{
				"id": "PRISONER-1", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 3, "cs": 2, "spd": 4, "rng": 1,
				"pos": Vector2i(4, 14),
				"gear": [],
			},
			{
				"id": "PRISONER-2", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 3, "cs": 2, "spd": 4, "rng": 1,
				"pos": Vector2i(7, 14),
				"gear": [],
			},
		],
		# Vanguard are held back and cut in from the tip (top) of the site on
		# round 3 — they guard the evidence locker rather than backstabbing the
		# crew at the start line. First mission fields a single Vanguard so the
		# leader isn't overwhelmed.
		"vanguard_spawn_turn": 3,
		"vanguard_count": 1,
		"vanguard_spawns": [
			{"pos": Vector2i(3, 1), "zone_min": 1, "zone_max": 6},
			{"pos": Vector2i(8, 1), "zone_min": 1, "zone_max": 6},
			{"pos": Vector2i(6, 1), "zone_min": 1, "zone_max": 6},
		],
	}

# ---------------------------------------------------------------------------
# Campaign 2 — Prison Break
# ---------------------------------------------------------------------------

static func _prison_break() -> Dictionary:
	return {
		"campaign_id": "prison-break",
		"title": "PRISON BREAK",
		"description": "Industrial Detention Facility — Maximum Security Wing",
		"danger_pay": 350,
		"missions": [_pb_1(), _pb_2(), _pb_3(), _pb_4()],
	}

static func _pb_1() -> Dictionary:
	return {
		"mission_id": "pb-1",
		"title": "GEAR RUN",
		"map_id": "map-supply-depot",
		"objective": ObjectiveType.EXTRACTION,
		"objective_data": {"target_tile": Vector2i(5, 1)},
		"hud_objective": "Move ALPHA to loading dock — [col 5, row 1]",
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 18)},
			{"id": "BRAVO",   "pos": Vector2i(3, 17)},
			{"id": "CHARLIE", "pos": Vector2i(7, 17)},
		],
		"enemy_config": [
			{
				"id": "DEPOT-GUARD-1", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(2, 5),
				"zone_min": 3, "zone_max": 7,
				"patrol": [Vector2i(2, 3), Vector2i(2, 7)],
				"gear": [],
			},
			{
				"id": "DEPOT-GUARD-2", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(9, 5),
				"zone_min": 3, "zone_max": 7,
				"patrol": [Vector2i(9, 3), Vector2i(9, 7)],
				"gear": [],
			},
			{
				"id": "DEPOT-ENFORCER", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 4, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(5, 9),
				"gear": [],
			},
		],
		"vanguard_spawns": [
			{"pos": Vector2i(1, 17), "zone_min": 14, "zone_max": 19},
			{"pos": Vector2i(10, 17), "zone_min": 14, "zone_max": 19},
			{"pos": Vector2i(2, 18), "zone_min": 14, "zone_max": 19},
		],
	}

static func _pb_2() -> Dictionary:
	return {
		"mission_id": "pb-2",
		"title": "THE BREAK-IN",
		"map_id": "map-security-block",
		"objective": ObjectiveType.ELIMINATION,
		"objective_data": {},
		"hud_objective": "Eliminate all guards — clear the security block",
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 18)},
			{"id": "BRAVO",   "pos": Vector2i(3, 17)},
			{"id": "CHARLIE", "pos": Vector2i(7, 17)},
		],
		"enemy_config": [
			{
				"id": "GUARD-CAPTAIN", "archetype": Unit.Archetype.TACTICAL,
				"hp": 5, "cs": 3, "spd": 2, "rng": 3,
				"pos": Vector2i(5, 3),
				"gear": [],
			},
			{
				"id": "BLOCK-GUARD-1", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(2, 2),
				"zone_min": 1, "zone_max": 4,
				"patrol": [Vector2i(2, 1), Vector2i(2, 4)],
				"gear": [],
			},
			{
				"id": "BLOCK-GUARD-2", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(9, 2),
				"zone_min": 1, "zone_max": 4,
				"patrol": [Vector2i(9, 1), Vector2i(9, 4)],
				"gear": [],
			},
			{
				"id": "RIOT-1", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 4, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(3, 5),
				"gear": [],
			},
			{
				"id": "RIOT-2", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 4, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(8, 5),
				"gear": [],
			},
		],
		"vanguard_spawns": [
			{"pos": Vector2i(1, 17), "zone_min": 14, "zone_max": 19},
			{"pos": Vector2i(10, 17), "zone_min": 14, "zone_max": 19},
			{"pos": Vector2i(2, 18), "zone_min": 14, "zone_max": 19},
		],
	}

static func _pb_3() -> Dictionary:
	return {
		"mission_id": "pb-3",
		"title": "BREAKOUT",
		"map_id": "map-cell-corridor",
		"objective": ObjectiveType.SURVIVAL,
		"objective_data": {"survive_rounds": 8},
		"hud_objective": "Hold the corridor — survive 8 rounds",
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 18)},
			{"id": "BRAVO",   "pos": Vector2i(3, 17)},
			{"id": "CHARLIE", "pos": Vector2i(7, 17)},
		],
		"enemy_config": [
			{
				"id": "WARDEN", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 5, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(5, 2),
				"zone_min": 1, "zone_max": 3,
				"patrol": [Vector2i(4, 2), Vector2i(6, 2)],
				"gear": [],
			},
			{
				"id": "BLOCK-RUNNER-1", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 4, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(2, 1),
				"gear": [],
			},
			{
				"id": "BLOCK-RUNNER-2", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 4, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(9, 1),
				"gear": [],
			},
			{
				"id": "BLOCK-RUNNER-3", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 4, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(2, 3),
				"gear": [],
			},
			{
				"id": "LOCKDOWN-GUARD", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(9, 3),
				"zone_min": 1, "zone_max": 6,
				"patrol": [Vector2i(9, 1), Vector2i(9, 3)],
				"gear": [],
			},
		],
		"vanguard_spawns": [],
	}

static func _pb_4() -> Dictionary:
	return {
		"mission_id": "pb-4",
		"title": "THE GETAWAY",
		"map_id": "map-supply-depot",
		"objective": ObjectiveType.RETRIEVE,
		"objective_data": {
			"item_tile": Vector2i(5, 8),
			"extract_tile": Vector2i(5, 1),
		},
		"hud_objective": "Recover evidence [col 5, row 8] — then reach vehicle bay [col 5, row 1]",
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 18)},
			{"id": "BRAVO",   "pos": Vector2i(3, 17)},
			{"id": "CHARLIE", "pos": Vector2i(7, 17)},
		],
		"enemy_config": [
			{
				"id": "ESCAPE-GUARD-1", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(2, 2),
				"zone_min": 1, "zone_max": 4,
				"patrol": [Vector2i(2, 1), Vector2i(2, 4)],
				"gear": [],
			},
			{
				"id": "ESCAPE-GUARD-2", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(9, 2),
				"zone_min": 1, "zone_max": 4,
				"patrol": [Vector2i(9, 1), Vector2i(9, 4)],
				"gear": [],
			},
			{
				"id": "ESCAPE-ENFORCER", "archetype": Unit.Archetype.TACTICAL,
				"hp": 5, "cs": 3, "spd": 2, "rng": 3,
				"pos": Vector2i(5, 9),
				"gear": [],
			},
			{
				"id": "ESCAPE-GUARD-3", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(2, 9),
				"zone_min": 8, "zone_max": 11,
				"patrol": [Vector2i(2, 8), Vector2i(2, 10)],
				"gear": [],
			},
			{
				"id": "ESCAPE-GUARD-4", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(9, 9),
				"zone_min": 8, "zone_max": 11,
				"patrol": [Vector2i(9, 8), Vector2i(9, 10)],
				"gear": [],
			},
		],
		"vanguard_spawns": [
			{"pos": Vector2i(1, 17), "zone_min": 14, "zone_max": 19},
			{"pos": Vector2i(10, 17), "zone_min": 14, "zone_max": 19},
			{"pos": Vector2i(2, 18), "zone_min": 14, "zone_max": 19},
		],
	}
