class_name CampaignData
extends RefCounted

enum ObjectiveType { EXTRACTION, ELIMINATION, SURVIVAL, RETRIEVE }

static func get_campaign(campaign_id: String) -> Dictionary:
	match campaign_id:
		"colony-repossession": return _colony_repossession()
		"containment-breach":  return _containment_breach()
		"prison-break":        return _prison_break()
	push_warning("CampaignData: unknown campaign '%s'" % campaign_id)
	return {}

## All campaigns in hub display order. The first is the beginner job;
## the rest unlock as bonus contracts once a campaign has been completed.
static func all_campaign_ids() -> Array[String]:
	return ["colony-repossession", "containment-breach", "prison-break"]

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
# Campaign 0 — First Repossession (the beginner job)
# Employer: Meridian Recovery Group. A frontier colony has defaulted on its
# corporate lease; the crew is contracted to reclaim company property.
# The Vanguard Salvage Co. is working the same default for a rival creditor.
# Missions ramp one mechanic at a time — taught by design, not popups.
# ---------------------------------------------------------------------------

static func _colony_repossession() -> Dictionary:
	return {
		"campaign_id": "colony-repossession",
		"title": "FIRST REPOSSESSION",
		"description": "Meridian Recovery Group — Kestrel's Rest Colony, defaulted lease",
		"danger_pay": 200,
		"missions": [_cr_1(), _cr_2(), _cr_3(), _cr_4(), _cr_5()],
	}

static func _cr_1() -> Dictionary:
	return {
		"mission_id": "cr-1",
		"title": "SITE SURVEY",
		"map_id": "map-colony-survey",
		"objective": ObjectiveType.EXTRACTION,
		"objective_data": {"target_tile": Vector2i(5, 1)},
		"hud_objective": "Walk the site — move ALPHA to the survey marker [col 5, row 1]",
		"briefing_tips": [
			"TIP: Tap a crew member, then tap a green tile to move.",
			"TIP: Tap an enemy once to preview the shot, tap again to fire.",
			"TIP: Reach the pulsing marker with ALPHA to finish the job.",
		],
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 17)},
			{"id": "BRAVO",   "pos": Vector2i(4, 17)},
			{"id": "CHARLIE", "pos": Vector2i(6, 17)},
		],
		"enemy_config": [
			{
				"id": "LOOTER-1", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 2, "cs": 1, "spd": 3, "rng": 1,
				"pos": Vector2i(5, 9),
				"gear": [],
			},
			{
				"id": "LOOTER-2", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 2, "cs": 1, "spd": 3, "rng": 1,
				"pos": Vector2i(6, 5),
				"gear": [],
			},
		],
		"vanguard_spawns": [],
	}

static func _cr_2() -> Dictionary:
	return {
		"mission_id": "cr-2",
		"title": "ASSET TAGGING",
		"map_id": "map-colony-depot",
		"objective": ObjectiveType.RETRIEVE,
		"objective_data": {
			"item_tile": Vector2i(5, 3),
			"extract_tile": Vector2i(6, 17),
		},
		"hud_objective": "Tag the company asset [col 5, row 3], then haul it to the dock [col 6, row 17]",
		"briefing_tips": [
			"TIP: Cover downgrades incoming hits — CLEAN beats GRAZE beats DEFLECTED.",
			"TIP: Flank around cover to land CLEAN hits; watch the shot preview.",
			"TIP: Watchmen patrol fixed routes until they see you.",
		],
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 17)},
			{"id": "BRAVO",   "pos": Vector2i(3, 17)},
			{"id": "CHARLIE", "pos": Vector2i(8, 17)},
		],
		"enemy_config": [
			{
				"id": "WATCHMAN-1", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 3, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(2, 6),
				"zone_min": 4, "zone_max": 10,
				"patrol": [Vector2i(2, 4), Vector2i(2, 9)],
				"gear": [],
			},
			{
				"id": "WATCHMAN-2", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 3, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(9, 6),
				"zone_min": 4, "zone_max": 10,
				"patrol": [Vector2i(9, 4), Vector2i(9, 9)],
				"gear": [],
			},
		],
		"vanguard_spawns": [],
	}

static func _cr_3() -> Dictionary:
	return {
		"mission_id": "cr-3",
		"title": "CONTESTED CLAIM",
		"map_id": "map-colony-comms",
		"objective": ObjectiveType.EXTRACTION,
		"objective_data": {"target_tile": Vector2i(5, 1)},
		"hud_objective": "Secure the comms relay — move ALPHA to the uplink [col 5, row 1]",
		"briefing_tips": [
			"TIP: A rival crew is working this claim — expect company at round 3.",
			"TIP: When gear FRACTURES, toughness resets but the modifier is gone.",
			"TIP: ALPHA's FIELD PATCH partially restores one fractured item.",
		],
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 17)},
			{"id": "BRAVO",   "pos": Vector2i(3, 16)},
			{"id": "CHARLIE", "pos": Vector2i(7, 16)},
		],
		"enemy_config": [
			{
				"id": "WATCHMAN-3", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 3, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(5, 8),
				"zone_min": 6, "zone_max": 11,
				"patrol": [Vector2i(4, 8), Vector2i(7, 8)],
				"gear": [],
			},
			{
				"id": "LOOTER-3", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 3, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(3, 5),
				"gear": [],
			},
			{
				"id": "LOOTER-4", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 3, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(8, 5),
				"gear": [],
			},
		],
		"vanguard_spawn_turn": 3,
		"vanguard_count": 2,
		"vanguard_spawns": [
			{"pos": Vector2i(3, 1), "zone_min": 1, "zone_max": 8},
			{"pos": Vector2i(8, 1), "zone_min": 1, "zone_max": 8},
		],
	}

static func _cr_4() -> Dictionary:
	return {
		"mission_id": "cr-4",
		"title": "SECURITY LOCKOUT",
		"map_id": "map-colony-security",
		"objective": ObjectiveType.ELIMINATION,
		"objective_data": {},
		"hud_objective": "Colony security won't honour the writ — clear the wing",
		"briefing_tips": [
			"TIP: USE ABILITY fires your weapon special — ARC PULSE chains SUPPRESSED.",
			"TIP: Amber warning tiles vent at end of round — clear the area.",
			"TIP: BRAVO's BRACE downgrades every incoming hit one tier.",
		],
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 17)},
			{"id": "BRAVO",   "pos": Vector2i(3, 16)},
			{"id": "CHARLIE", "pos": Vector2i(7, 16)},
		],
		"enemy_config": [
			{
				"id": "SECURITY-1", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(3, 5),
				"zone_min": 1, "zone_max": 6,
				"patrol": [Vector2i(3, 3), Vector2i(3, 6)],
				"gear": [{"slot": "weapon", "id": "STUN-BATON", "mod": 1, "rng": 2}],
			},
			{
				"id": "SECURITY-2", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(8, 5),
				"zone_min": 1, "zone_max": 6,
				"patrol": [Vector2i(8, 3), Vector2i(8, 6)],
				"gear": [{"slot": "weapon", "id": "STUN-BATON", "mod": 1, "rng": 2}],
			},
			{
				"id": "SECURITY-CAPTAIN", "archetype": Unit.Archetype.TACTICAL,
				"hp": 5, "cs": 3, "spd": 2, "rng": 3,
				"pos": Vector2i(5, 3),
				"gear": [{"slot": "armor", "id": "RIOT-PLATE", "mod": 1}],
			},
			{
				"id": "ENFORCER-1", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 4, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(5, 10),
				"gear": [],
			},
		],
		"vanguard_spawns": [],
	}

static func _cr_5() -> Dictionary:
	return {
		"mission_id": "cr-5",
		"title": "FINAL NOTICE",
		"map_id": "map-colony-yard",
		"objective": ObjectiveType.RETRIEVE,
		"objective_data": {
			"item_tile": Vector2i(5, 2),
			"extract_tile": Vector2i(5, 17),
		},
		"hud_objective": "Recover the lease core [col 5, row 2] and reach the hauler [col 5, row 17]",
		"briefing_tips": [
			"TIP: The Vanguard crew arrives in force at round 2 — move fast or dig in.",
			"TIP: Downed Vanguard drop broken gear — fence it at the Terminal Hub.",
			"TIP: Danger Pay lands when the contract closes. Finish the job.",
		],
		"player_spawns": [
			{"id": "ALPHA",   "pos": Vector2i(5, 17)},
			{"id": "BRAVO",   "pos": Vector2i(3, 16)},
			{"id": "CHARLIE", "pos": Vector2i(7, 16)},
		],
		"enemy_config": [
			{
				"id": "WATCHMAN-4", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(3, 4),
				"zone_min": 1, "zone_max": 7,
				"patrol": [Vector2i(3, 2), Vector2i(3, 6)],
				"gear": [],
			},
			{
				"id": "WATCHMAN-5", "archetype": Unit.Archetype.GUARDIAN,
				"hp": 4, "cs": 2, "spd": 2, "rng": 2,
				"pos": Vector2i(8, 4),
				"zone_min": 1, "zone_max": 7,
				"patrol": [Vector2i(8, 2), Vector2i(8, 6)],
				"gear": [],
			},
			{
				"id": "ENFORCER-2", "archetype": Unit.Archetype.RAMPAGING,
				"hp": 4, "cs": 2, "spd": 3, "rng": 1,
				"pos": Vector2i(6, 9),
				"gear": [],
			},
		],
		"vanguard_spawn_turn": 2,
		"vanguard_count": 3,
		"vanguard_spawns": [
			{"pos": Vector2i(2, 1), "zone_min": 1, "zone_max": 18},
			{"pos": Vector2i(9, 1), "zone_min": 1, "zone_max": 18},
			{"pos": Vector2i(5, 1), "zone_min": 1, "zone_max": 18},
		],
	}

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
