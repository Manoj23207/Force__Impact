extends CharacterBody3D

# Constants
const WALK_SPEED = 8.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.5
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
var can_shoot = true

# Signals
signal player_hit

# Weapons
enum weapons { AUTO, PISTOLS }
var weapon = weapons.AUTO

# Bullet Scenes
var bullet = load("res://Scenes/Bullet.tscn")
var bullet_trail = load("res://Scenes/BulletTrail.tscn")

# Node references
@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var aim_ray = $Head/Camera3D/AimRay
@onready var aim_ray_end = $Head/Camera3D/AimRayEnd
@onready var gun_anim = $Head/Camera3D/Rifle/AnimationPlayer
@onready var gun_barrel = $Head/Camera3D/Rifle/RayCast3D
@onready var auto_anim = $Head/Camera3D/SteampunkAuto/AnimationPlayer
@onready var auto_barrel = $Head/Camera3D/SteampunkAuto/Meshes/Barrel
@onready var weapon_switching = $Head/Camera3D/WeaponSwitching

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-70), deg_to_rad(70))

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Sprinting
	speed = SPRINT_SPEED if Input.is_action_pressed("sprint") else WALK_SPEED

	# Movement
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
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

	# FOV
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)

	# Shooting
	if Input.is_action_pressed("shoot") and can_shoot:
		match weapon:
			weapons.AUTO:
				_shoot_auto()
			weapons.PISTOLS:
				_shoot_pistols()

	# Weapon switching
	if Input.is_action_just_pressed("weapon_one") and weapon != weapons.AUTO:
		_raise_weapon(weapons.AUTO)
	if Input.is_action_just_pressed("weapon_two") and weapon != weapons.PISTOLS:
		_raise_weapon(weapons.PISTOLS)

	move_and_slide()

# Head bob effect
func _headbob(time) -> Vector3:
	return Vector3(cos(time * BOB_FREQ / 2) * BOB_AMP, sin(time * BOB_FREQ) * BOB_AMP, 0)

# Player hit reaction
func hit(dir):
	emit_signal("player_hit")
	velocity += dir * HIT_STAGGER
	if velocity.length() > SPRINT_SPEED:
		velocity = velocity.normalized() * SPRINT_SPEED

# Pistol shooting (one gun)
func _shoot_pistols():
	if !gun_anim.is_playing():
		gun_anim.play("Shoot")
		var instance = bullet.instantiate()
		instance.position = gun_barrel.global_position
		get_parent().add_child(instance)

		if aim_ray.is_colliding():
			instance.set_velocity(aim_ray.get_collision_point())
		else:
			instance.set_velocity(aim_ray_end.global_position)

# Automatic weapon shooting
func _shoot_auto():
	if !auto_anim.is_playing():
		auto_anim.play("Shoot")
		var instance = bullet_trail.instantiate()
		if aim_ray.is_colliding():
			instance.init(auto_barrel.global_position, aim_ray.get_collision_point())
			get_parent().add_child(instance)

			var target = aim_ray.get_collider()
			if target.is_in_group("enemy"):
				target.hit()
				instance.trigger_particles(aim_ray.get_collision_point(), auto_barrel.global_position, true)
			else:
				instance.trigger_particles(aim_ray.get_collision_point(), auto_barrel.global_position, false)
		else:
			instance.init(auto_barrel.global_position, aim_ray_end.global_position)
			get_parent().add_child(instance)

# Weapon switch animation logic
func _lower_weapon():
	match weapon:
		weapons.AUTO:
			weapon_switching.play("LowerAuto")
		weapons.PISTOLS:
			weapon_switching.play("LowerPistols")

func _raise_weapon(new_weapon):
	can_shoot = false
	_lower_weapon()
	await get_tree().create_timer(0.3).timeout
	match new_weapon:
		weapons.AUTO:
			weapon_switching.play_backwards("LowerAuto")
		weapons.PISTOLS:
			weapon_switching.play_backwards("LowerPistols")
	weapon = new_weapon
	can_shoot = true
