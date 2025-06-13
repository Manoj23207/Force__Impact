extends Control

var scene_path_to_load

@onready var Menu =  $Menu/Buttons
@onready var play_button = $"Menu/Buttons/Play"
@onready var about_button = $"Menu/Buttons/About"
@onready var settings_button = $"Menu/Buttons/Settings"
@onready var quit_button = $"Menu/Buttons/Quit"

func _ready():
	set_process_input(true)
	if ConfigManager.load_fullscreen_setting():
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	MusicManager.playMainMenuMusic()  # Start menu music


func _on_play_pressed():
	scene_path_to_load = "res://Scenes/World.tscn"  # Change to your actual path
	on_Button_pressed()

func _on_settings_pressed():
	scene_path_to_load = "res://settings.tscn"  # Change to your actual path
	on_Button_pressed()

func _on_about_pressed():
	scene_path_to_load = "res://settings.tscn" 
	on_Button_pressed()

func _on_quit_pressed():
	if $UISound and is_instance_valid($UISound):
		$UISound.play()
	$Menu.hide()
	$background.hide()
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()


func on_Button_pressed():
	$UISound.play()
	$FadeIn.show()
	$FadeIn.fade_in()


func _on_fade_in_fade_finished():
	get_tree().change_scene_to_file(scene_path_to_load)

func _input(event):
	if event.is_action_pressed("key_exit"):
		get_tree().quit()
