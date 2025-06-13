extends CanvasLayer

@onready var fade_rect = $"FadeRect" if has_node("FadeRect") else null
var target_scene: String

func _ready():
	if fade_rect == null:
		print("Error: FadeRect node not found!")
		return
	fade_rect.modulate.a = 0.0  # Start fully transparent
	fade_rect.visible = false

func transition_to(scene_path: String):
	target_scene = scene_path
	_start_fade_out()

func _start_fade_out():
	if fade_rect == null:
		print("Error: FadeRect is null in _start_fade_out!")
		return
	fade_rect.visible = true
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(_on_fade_out_done)

func _on_fade_out_done():
	get_tree().change_scene_to_file(target_scene)
	_start_fade_in()

func _start_fade_in():
	if fade_rect == null:
		print("Error: FadeRect is null in _start_fade_in!")
		return
	var tween = create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.finished.connect(func(): fade_rect.visible = false)
