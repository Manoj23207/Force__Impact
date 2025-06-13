extends PanelContainer

@onready var anim_player := $AnimationPlayer

func _ready():
	visible = false  # Ensure menu is hidden at start
	set_process_unhandled_input(true)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("key_exit"):
		_toggle_pause()

func _toggle_pause():
	var new_state = !get_tree().paused
	_enable(new_state)

func _enable(value: bool) -> void:
	get_tree().paused = value
	visible = value
	anim_player.play("show" if value else "hide")

func _on_resume_pressed() -> void:
	_enable(false)

func _on_restart_pressed() -> void:
	_enable(false)
	get_tree().reload_current_scene()  # safer than changing to MainMenu if you want restart

func _on_exit_pressed() -> void:
	_enable(false)
	get_tree().change_scene_to_file("res://Scenes/MainMenu.tscn")  # Replace with your actual path
