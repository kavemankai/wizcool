extends Node

## AudioManager — autoload singleton for all SFX and music playback.
## No class_name: the autoload registration already exposes `AudioManager`
## as a global, and a matching class_name would hide the autoload singleton.
## Owns all AudioStreamPlayer nodes. No game logic lives here.
## Streams are null until .wav assets arrive; all play calls guard for null.

# ---------------------------------------------------------------------------
# SFX players — keyed by slot name
# ---------------------------------------------------------------------------

var _sfx_players: Dictionary = {}

# ---------------------------------------------------------------------------
# Music players — calm and tension run simultaneously, crossfaded by volume
# ---------------------------------------------------------------------------

var _music_calm: AudioStreamPlayer
var _music_tension: AudioStreamPlayer
var _music_tween: Tween = null

const CROSSFADE_DURATION: float = 0.5

# ---------------------------------------------------------------------------
# SFX slot names → bus assignment
# ---------------------------------------------------------------------------

const _SFX_BUS_SLOTS: Array[String] = [
	"weapon_plasma_cutter",
	"weapon_impact_wrench",
	"weapon_long_bore_drill",
	"weapon_salvage_pistol",
	"gear_fracture",
	"gear_break",
	"unit_downed",
	"field_patch",
	"mission_complete",
	"mission_fail",
]

const _UI_BUS_SLOTS: Array[String] = [
	"ui_click",
	"cutaway_dismiss",
]

func _ready() -> void:
	_build_sfx_players()
	_build_music_players()
	apply_volumes()

## Apply GameState volume settings (linear 0..1) to the audio buses.
## Called at startup and live from the settings menu sliders.
func apply_volumes() -> void:
	_set_bus_linear("SFX", GameState.sfx_volume)
	_set_bus_linear("Music", GameState.music_volume)
	_set_bus_linear("UI", GameState.ui_volume)

func _set_bus_linear(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	if linear <= 0.001:
		AudioServer.set_bus_mute(idx, true)
	else:
		AudioServer.set_bus_mute(idx, false)
		AudioServer.set_bus_volume_db(idx, linear_to_db(linear))

func _build_sfx_players() -> void:
	for slot: String in _SFX_BUS_SLOTS:
		var player := AudioStreamPlayer.new()
		player.name = slot
		player.bus = &"SFX"
		player.stream = null
		add_child(player)
		_sfx_players[slot] = player

	for slot: String in _UI_BUS_SLOTS:
		var player := AudioStreamPlayer.new()
		player.name = slot
		player.bus = &"UI"
		player.stream = null
		add_child(player)
		_sfx_players[slot] = player

func _build_music_players() -> void:
	_music_calm = AudioStreamPlayer.new()
	_music_calm.name = "MusicCalm"
	_music_calm.bus = &"Music"
	_music_calm.stream = null
	_music_calm.volume_db = 0.0
	add_child(_music_calm)

	_music_tension = AudioStreamPlayer.new()
	_music_tension.name = "MusicTension"
	_music_tension.bus = &"Music"
	_music_tension.stream = null
	_music_tension.volume_db = -80.0
	add_child(_music_tension)

# ---------------------------------------------------------------------------
# Public API — SFX
# ---------------------------------------------------------------------------

## Plays a named SFX slot. Silently no-ops if the stream has not been loaded.
func play_sfx(sfx_name: String) -> void:
	if not _sfx_players.has(sfx_name):
		return
	var player: AudioStreamPlayer = _sfx_players[sfx_name]
	if player.stream == null:
		return
	player.play()

# ---------------------------------------------------------------------------
# Public API — Music
# ---------------------------------------------------------------------------

## Immediately plays calm music at full volume; tension silent.
func start_music_calm() -> void:
	_kill_tween()
	_music_calm.volume_db = 0.0
	_music_tension.volume_db = -80.0
	if _music_calm.stream != null and not _music_calm.playing:
		_music_calm.play()
	if _music_tension.stream != null and not _music_tension.playing:
		_music_tension.play()

## Crossfades from calm to tension over CROSSFADE_DURATION seconds.
func crossfade_to_tension() -> void:
	_kill_tween()
	if _music_tension.stream != null and not _music_tension.playing:
		_music_tension.play()
	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	_music_tween.tween_property(_music_calm, "volume_db", -80.0, CROSSFADE_DURATION)
	_music_tween.tween_property(_music_tension, "volume_db", 0.0, CROSSFADE_DURATION)

## Crossfades from tension back to calm over CROSSFADE_DURATION seconds.
func crossfade_to_calm() -> void:
	_kill_tween()
	if _music_calm.stream != null and not _music_calm.playing:
		_music_calm.play()
	_music_tween = create_tween()
	_music_tween.set_parallel(true)
	_music_tween.tween_property(_music_tension, "volume_db", -80.0, CROSSFADE_DURATION)
	_music_tween.tween_property(_music_calm, "volume_db", 0.0, CROSSFADE_DURATION)

## Stops both music players immediately.
func stop_music() -> void:
	_kill_tween()
	_music_calm.stop()
	_music_tension.stop()

# ---------------------------------------------------------------------------
# Internal helpers
# ---------------------------------------------------------------------------

func _kill_tween() -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = null
