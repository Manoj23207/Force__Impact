extends CharacterBody3D

@export var chase_range: float = 12.0
@export var retreat_range: float = 20.0
@export var attack_range: float = 2.0
@export var speed := 4.0

var player = null  # Player will be injected
var spawn_position: Vector3
var state: String = "idle"
var health = 8
var is_attacking: bool = false

signal zombie_hit

@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
var state_machine

# Dependency injection via setter
func set_player(player_node: Node3D) -> void:
	player = player_node
	if player == null:
		print("Warning: Injected player node is null!")

func _ready():
	if player == null:
		print("Error: Player must be injected before using this zombie!")
	state_machine = anim_tree.get("parameters/playback")
	spawn_position = global_position

	nav_agent.target_desired_distance = 0.1
	nav_agent.path_desired_distance = 0.2
	nav_agent.velocity_computed.connect(_on_nav_velocity_computed)

func _process(_delta):
	if health <= 0 or player == null:
		return

	var dist_to_player = global_position.distance_to(player.global_position)
	update_chase_behavior(dist_to_player)

	# State switching logic
	match state:
		"attack":
			if dist_to_player > attack_range:
				state = "chase"
		"retreat":
			if global_position.distance_to(spawn_position) < 1.5:
				state = "idle"
			elif dist_to_player < chase_range:
				state = "chase"

	# Targeting logic
	match state:
		"chase":
			nav_agent.set_target_position(player.global_position)
		"attack":
			velocity = Vector3.ZERO
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
		"retreat":
			nav_agent.set_target_position(spawn_position)
		"idle":
			velocity = Vector3.ZERO

	# Animation switching
	anim_tree.set("parameters/conditions/attack", state == "attack")
	anim_tree.set("parameters/conditions/run", state in ["chase", "retreat"])

	move_and_slide()

func update_chase_behavior(distance_to_player: float):
	if distance_to_player < chase_range and state == "idle":
		state = "chase"
	elif distance_to_player > retreat_range and state == "chase":
		state = "retreat"
	elif distance_to_player < attack_range and state == "chase" and not is_attacking:
		state = "attack"

func _on_nav_velocity_computed(safe_velocity: Vector3):
	if state in ["chase", "retreat"]:
		velocity = safe_velocity.normalized() * speed
		if velocity.length() > 0.1:
			var target_angle = atan2(-velocity.x, -velocity.z)
			rotation.y = lerp_angle(rotation.y, target_angle, 0.15)

func _target_in_range() -> bool:
	return global_position.distance_to(player.global_position) < attack_range

func _hit_finished():
	if state == "attack":
		is_attacking = false
		if _target_in_range():
			var dir = global_position.direction_to(player.global_position)
			player.hit(dir)
		state = "chase"

func _on_area_3d_body_part_hit(dam):
	health -= dam
	emit_signal("zombie_hit")
	if health <= 0:
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()

func _on_attack_animation_started():
	is_attacking = true
