class_name GrazeSystem

## Deterministic damage-tier ladder — the X-COM feel without the dice.
## Every attack lands, but conditions downgrade it: CLEAN (full damage),
## GRAZE (reduced), CHIP (minimal). The tier is a pure function of board
## state, so the pre-attack preview and the resolved attack always agree.
##
## Tier ladder (start CLEAN, apply modifiers, clamp):
##   HEAVY cover, not flanked  -> -2    LIGHT cover, not flanked -> -1
##   target BRACEd             -> -1    attack at max range band -> -1
##   adjacent (dist 1)         -> +1
## Target gear state degrades their cover discipline:
##   BROKEN weapon gear  -> cover ignored entirely
##   FRACTURED weapon    -> cover penalty reduced by 1 (HEAVY acts as LIGHT)

enum Tier { CHIP = 0, GRAZE = 1, CLEAN = 2 }

## Compute the attack tier for attacker -> target on the given grid.
## grid may be null (e.g. hazard/system damage); cover is then ignored.
static func compute_tier(attacker: Unit, target: Unit, grid: GridManager) -> int:
	var tier: int = Tier.CLEAN

	var flanking := CoverSystem.is_flanking(
			attacker.grid_pos, target.grid_pos, target.facing)

	if not flanking and grid != null:
		var cover: CoverSystem.CoverType = CoverSystem.get_cover_type(target.grid_pos, grid)
		var cover_penalty: int = 0
		match cover:
			CoverSystem.CoverType.LIGHT: cover_penalty = CombatConstants.TIER_PENALTY_LIGHT_COVER
			CoverSystem.CoverType.HEAVY: cover_penalty = CombatConstants.TIER_PENALTY_HEAVY_COVER
		# Damaged gear erodes the target's use of cover.
		match target.get_weapon_gear_state():
			GearItem.GearState.BROKEN:    cover_penalty = 0
			GearItem.GearState.FRACTURED: cover_penalty = maxi(0, cover_penalty - 1)
		tier -= cover_penalty

	if target.is_braced():
		tier -= CombatConstants.TIER_PENALTY_BRACE

	var dist: int = maxi(
			absi(attacker.grid_pos.x - target.grid_pos.x),
			absi(attacker.grid_pos.y - target.grid_pos.y))
	if attacker.attack_range > 1 and dist >= attacker.attack_range:
		tier -= CombatConstants.TIER_PENALTY_MAX_RANGE
	if dist <= 1:
		tier += CombatConstants.TIER_BONUS_ADJACENT

	return clampi(tier, Tier.CHIP, Tier.CLEAN)

## Transform raw weapon damage through a tier.
static func apply_tier(raw_dmg: int, tier: int) -> int:
	match tier:
		Tier.CLEAN: return raw_dmg
		Tier.GRAZE: return maxi(1, raw_dmg - CombatConstants.GRAZE_DAMAGE_REDUCTION)
		Tier.CHIP:  return CombatConstants.CHIP_DAMAGE
	return raw_dmg

## Short combat-log / cutaway label for a tier.
static func tier_label(tier: int) -> String:
	match tier:
		Tier.CLEAN: return "CLEAN HIT"
		Tier.GRAZE: return "GRAZE"
		Tier.CHIP:  return "DEFLECTED"
	return ""

## One-line explanation of the dominant tier factors, for the HUD preview.
## e.g. "LIGHT COVER" or "HEAVY COVER · BRACED" or "FLANKED".
static func tier_reason(attacker: Unit, target: Unit, grid: GridManager) -> String:
	var parts: Array[String] = []
	var flanking := CoverSystem.is_flanking(
			attacker.grid_pos, target.grid_pos, target.facing)

	if grid != null and CoverSystem.get_cover_type(target.grid_pos, grid) != CoverSystem.CoverType.NONE:
		if flanking:
			parts.append("FLANKED")
		else:
			var cover := CoverSystem.get_cover_type(target.grid_pos, grid)
			parts.append("HEAVY COVER" if cover == CoverSystem.CoverType.HEAVY else "LIGHT COVER")
	if target.is_braced():
		parts.append("BRACED")

	var dist: int = maxi(
			absi(attacker.grid_pos.x - target.grid_pos.x),
			absi(attacker.grid_pos.y - target.grid_pos.y))
	if attacker.attack_range > 1 and dist >= attacker.attack_range:
		parts.append("MAX RANGE")
	elif dist <= 1:
		parts.append("POINT BLANK")

	if parts.is_empty():
		return "EXPOSED"
	return " · ".join(parts)
