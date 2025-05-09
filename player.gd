extends RigidBody3D

var mouse_sensitivity := 0.001
var twist_input := 0.0
var pitch_input := 0.0
var jump_force := 1800.0
var is_grounded := false
var can_shoot := true
var bullet_scene := preload("res://Scenes/Bullet.tscn")

@onready var twist_pivot := $TwistPivot
@onready var pitch_pivot := $TwistPivot/PitchPivot
@onready var camera := $TwistPivot/PitchPivot/Camera3D
@onready var gun_barrel := $TwistPivot/PitchPivot/Rifle/RayCast3D
@onready var gun_anim := $TwistPivot/PitchPivot/Rifle/AnimationPlayer

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta: float) -> void:
	# Movement input
	var input := Vector3.ZERO
	input.x = Input.get_axis("move_left", "move_right")
	input.z = Input.get_axis("move_forward", "move_back")
	apply_central_force(twist_pivot.basis * input * 1200.0 * delta)

	# Jump input (only if touching the ground)
	if Input.is_action_just_pressed("jump") and is_grounded:
		apply_impulse(Vector3.UP * jump_force)
		is_grounded = false

	# Fire bullet
	if Input.is_action_pressed("shoot") and can_shoot:
		_shoot()

	# Escape: release mouse
	if Input.is_action_just_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	# Rotate based on inputs
	twist_pivot.rotate_y(twist_input)
	pitch_pivot.rotate_x(pitch_input)
	pitch_pivot.rotation.x = clamp(pitch_pivot.rotation.x, deg_to_rad(-30), deg_to_rad(30))

	# Reset input accumulators
	twist_input = 0.0
	pitch_input = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		twist_input = -event.relative.x * mouse_sensitivity
		pitch_input = -event.relative.y * mouse_sensitivity

func _integrate_forces(state):
	var query = PhysicsRayQueryParameters3D.new()
	query.from = global_transform.origin
	query.to = global_transform.origin + Vector3.DOWN * 1.1
	query.exclude = [self]  # Avoid self-hit

	var space_state = get_world_3d().direct_space_state
	var result = space_state.intersect_ray(query)

	is_grounded = result.size() > 0


func _shoot():
	can_shoot = false
	if !gun_anim.is_playing():
		gun_anim.play("Shoot")

	var bullet = bullet_scene.instantiate()
	bullet.position = gun_barrel.global_position
	bullet.transform.basis = gun_barrel.global_transform.basis
	get_tree().current_scene.add_child(bullet)

	await gun_anim.animation_finished
	can_shoot = true
