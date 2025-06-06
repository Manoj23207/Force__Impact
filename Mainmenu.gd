extends CanvasLayer

@onready var start_button = $CenterContainer/MenuButtons/StartGame
@onready var sub_menu = $CenterContainer2/MenuButtons
@onready var play_button = sub_menu/Play
@onready var about_button = sub_menu/About
@onready var settings_button = sub_menu/Settings
@onready var quit_button = sub_menu/Quit
# Optional: If you have a settings menu and music player node
@onready var settings_menu = $SettingsMenu
@onready var music_toggle = settings_menu/VBoxContainer/MusicToggle
@onready var music_player = $MusicPlayer

func _ready():
	start_button.pressed.connect(_on_start_pressed)
	play_button.pressed.connect(_on_play_pressed)
	about_button.pressed.connect(_on_about_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	if music_toggle:
		music_toggle.toggled.connect(_on_music_toggled)

func _on_start_pressed():
	start_button.hide()
	sub_menu.show()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://YourGameScene.tscn")  # Change to your actual path

func _on_settings_pressed():
	settings_menu.show()

func _on_about_pressed():
	print("This game is made by Manoj.")

func _on_quit_pressed():
	get_tree().quit()

func _on_music_toggled(button_pressed: bool):
	if button_pressed:
		music_player.play()
	else:
		music_player.stop()
