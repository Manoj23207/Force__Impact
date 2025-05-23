extends CharacterBody3D

# Constants
const WALK_SPEED = 13.0
const SPRINT_SPEED = 12.0
const JUMP_VELOCITY = 6.0
const SENSITIVITY = 0.004
const HIT_STAGGER = 8.0
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
const BASE_FOV = 75.0
const FOV_CHANGE = 1.5

# Variables
var speed = WALK_SPEED
var t_bob = 0.0
var gravity = 9.8
var bullet = load("res://Scenes/Bullet.tscn")
var instance

# Signal
signal player_hit

# Node references
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var gun_anim = $Head/Camera3D/Rifle/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/Rifle/RayCast3D

# Initialization
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

# Mouse look
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60))

# Main physics loop
func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Sprint or walk
	speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

	# Movement input
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	# Apply movement
	if is_on_floor():
		if direction:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 15.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 15.0)
		else:
			velocity.x = lerp(velocity.x, 0.0, delta * 7.0)
			velocity.z = lerp(velocity.z, 0.0, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	# FOV adjustment
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	# Shooting
	if Input.is_action_pressed("shoot") and !gun_anim.is_playing():
		gun_anim.play("Shoot")
		instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		instance.transform.basis = gun_barrel.global_transform.basis
		get_parent().add_child(instance)

	# Apply movement
	move_and_slide()

# Head bobbing logic
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

# When player gets hit
func hit(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER


func _on_player_hit() -> void:
	pass # Replace with function body.


func _on_player_player_hit() -> void:
	pass # Replace with function body.
