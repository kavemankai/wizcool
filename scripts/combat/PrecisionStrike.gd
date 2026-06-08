class_name PrecisionStrike

## Static utility class for precision strike eligibility and damage calculation.
## Precision strikes require flanking position, intact weapon, and target not in heavy cover.

## Returns true when the attacker is eligible to perform a precision strike on the target.
## Conditions:
##   - Attacker has an INTACT weapon.
##   - Attacker is flanking the target (relative to target's facing).
##   - Target is not in HEAVY cover.
static func can_use(attacker: Unit, target: Unit) -> bool:
	# Require an intact weapon
	var weapon: GearItem = _get_weapon(attacker)
	if weapon == null:
		return false
	if weapon.state != GearItem.GearState.INTACT:
		return false

	# Require flanking position
	if not CoverSystem.is_flanking(attacker.grid_pos, target.grid_pos, target.facing):
		return false

	# Blocked by heavy cover
	if target.cover_type == CoverSystem.CoverType.HEAVY:
		return false

	return true

## Compute precision strike damage from the attacker's weapon.
## Intact weapon gets the precision bonus; fractured weapon fires at base damage.
## Broken weapon returns 0 (can_use() prevents reaching this path in normal flow).
static func get_damage(attacker: Unit) -> int:
	var weapon: GearItem = _get_weapon(attacker)
	if weapon == null:
		return 0
	match weapon.state:
		GearItem.GearState.INTACT:
			return weapon.damage + CombatConstants.PRECISION_BONUS_DAMAGE
		GearItem.GearState.FRACTURED:
			return weapon.damage
		GearItem.GearState.BROKEN:
			return 0
	return 0

## Helper: return the first weapon-slot GearItem, or null if none equipped.
static func _get_weapon(unit: Unit) -> GearItem:
	for item: GearItem in unit.gear:
		if item.slot == "weapon":
			return item
	return null
