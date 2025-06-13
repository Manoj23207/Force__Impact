extends Node

var music_volume: float = 0.0
var fullscreen_enabled: bool = false

func _ready():
	if not Engine.has_singleton("ConfigManager"):
		Engine.register_singleton("ConfigManager", self)
	load_config()

var config = ConfigFile.new()

func load_config():
	if config.load("user://audio_volumes.cfg") == OK:
		music_volume = config.get_value("volume", "music", 0.0)
	else:
		music_volume = 0.0
		save_audio_volumes()
	if config.load("user://config.cfg") == OK:
		if config.has_section_key("settings", "fullscreen_enabled"):
			fullscreen_enabled = config.get_value("settings", "fullscreen_enabled", false)
	else:
		fullscreen_enabled = false
		save_fullscreen_setting(false)
	apply_audio_volumes()

func apply_audio_volumes():
	AudioServer.set_bus_volume_db(1, linear_to_db(music_volume))
	AudioServer.set_bus_mute(1, music_volume <= -30.0)

func save_audio_volumes():
	config.set_value("volume", "music", music_volume)
	config.save("user://audio_volumes.cfg")
	apply_audio_volumes()

func load_audio_volumes():  # Added for compatibility
	load_config()  # Reuse load_config to load volumes
	return {"music": music_volume}  # Return volumes for external use

func load_fullscreen_setting() -> bool:
	if config.load("user://config.cfg") == OK:
		if config.has_section_key("settings", "fullscreen_enabled"):
			fullscreen_enabled = config.get_value("settings", "fullscreen_enabled", false)
			return fullscreen_enabled
	return false

func save_fullscreen_setting(enabled: bool):
	fullscreen_enabled = enabled
	config.set_value("settings", "fullscreen_enabled", enabled)
	config.save("user://config.cfg")
	if enabled:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
