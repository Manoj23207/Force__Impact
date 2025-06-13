extends Node
@onready var music_player = $AudioStreamPlayer3D

func _ready():
	if not music_player:
		var player = AudioStreamPlayer.new()
		player.name = "AudioStreamPlayer"
		add_child(player)
		music_player = player
	music_player.bus = "Music"  # Ensure it uses the Music bus

func playMainMenuMusic():
	if music_player.stream != load("res://Audio/Zombie/background_music.wav"):  # Replace with your file
		music_player.stream = load("res://Audio/Zombie/background_music.wav")
	if !music_player.playing:
		music_player.play()

func stopMusic():
	music_player.stop()

func set_music_volume(volume):
	music_player.volume_db = linear_to_db(volume)
