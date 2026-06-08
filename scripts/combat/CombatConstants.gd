class_name CombatConstants

## Shared numeric constants for all combat subsystems.
## All tuning knobs live here — never hardcode these values elsewhere.

# Cover damage reduction
const COVER_REDUCTION_LIGHT: int = 1
const COVER_REDUCTION_HEAVY: int = 2
const COVER_INTEGRITY_LIGHT: int = 3
const COVER_INTEGRITY_HEAVY: int = 6
const COVER_REDUCTION_FRACTURED_PENALTY: int = 1

# AoE blast damage by zone
const BLAST_DAMAGE_CENTER: int = 3
const BLAST_DAMAGE_MID: int = 2
const BLAST_DAMAGE_EDGE: int = 1
const BLAST_RADIUS_DEFAULT: int = 2

# Precision strike
const PRECISION_BONUS_DAMAGE: int = 1

# Status effect durations and penalties
const SUPPRESSED_DURATION: int = 1
const SUPPRESSED_AP_PENALTY: int = 1
const SUPPRESSED_MOVE_PENALTY: int = 2
const CORRODED_DURATION: int = 2
const CORRODED_TGH_PENALTY: int = 1
const OVERLOADED_DURATION: int = 1

# Weapon special ability cooldowns (in turns)
const ABILITY_COOLDOWN_SUPPRESSING_FIRE: int = 2
const ABILITY_COOLDOWN_CORROSIVE_BURST: int = 3
const ABILITY_COOLDOWN_ARC_PULSE: int = 3
const ABILITY_COOLDOWN_BRACE: int = 2

# Weapon special ability base damage
const SUPPRESS_FIRE_DAMAGE: int = 1
const CORROSIVE_BURST_DAMAGE: int = 2
const ARC_SUPPRESSOR_RANGE: int = 4
const SEALANT_PACK_RANGE: int = 3

# Arc Pulse — chains SUPPRESSED to enemies within this radius of the primary target
const ARC_PULSE_DAMAGE: int = 1
const ARC_PULSE_CHAIN_RADIUS: int = 1

# Brace — flat reduction applied to the next incoming hit while braced
const BRACE_DAMAGE_REDUCTION: int = 2

# AI scoring thresholds
const AI_AOE_MIN_SCORE: int = 2
const AI_PRECISION_WEIGHT: int = 3
