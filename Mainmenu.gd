extends Control

@onready var start_button = $"CenterContainer/MenuButtons/StartGame"
@onready var sub_menu = $CenterContainer2/MenuButtons
@onready var play_button = $"CenterContainer2/MenuButtons/Play"
@onready var about_button = $"CenterContainer2/MenuButtons/About"
@onready var settings_button = $"CenterContainer2/MenuButtons/Settings"
@onready var quit_button = $"CenterContainer2/MenuButtons/Quit"
# Optional: If you have a settings menu and music player node
@onready var settings_menu = $SettingsMenu


func _ready():
	start_button.pressed.connect(_on_start_pressed)
	play_button.pressed.connect(_on_play_pressed)
	about_button.pressed.connect(_on_about_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_start_pressed():
	start_button.hide()
	sub_menu.show()

func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/World.tscn")  # Change to your actual path

func _on_settings_pressed():
	settings_menu.show()

func _on_about_pressed():
	print("This game is made by Manoj.")

func _on_quit_pressed():
	get_tree().quit()
