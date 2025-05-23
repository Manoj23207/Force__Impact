extends CharacterBody3D

var player = null
var state_machine
var health = 5

const SPEED = 4.0
const ATTACK_RANGE = 2.0

@export var player_path := "/root/main/Map/NavigationRegion3D/player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var progress = $"../CanvasLayer/ProgressBar"
@onready var timer = $"../Timer"

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")
	if player:
		print("Player node found: ", player, " Type: ", player.get_class())
	else:
		print("Error: Player node not found at path: ", player_path)
	if not state_machine:
		print("Error: State machine not found in AnimationTree!")

func _process(delta):
	velocity = Vector3.ZERO
	
	if not player or not player.has_method("get_global_position"):
		return
	
	match state_machine.get_current_node():
		"Run":
			# Navigation
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	move_and_slide()

func _target_in_range():
	if not player or not player.has_method("get_global_position"):
		return false
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if not player or not player.has_method("get_global_position"):
		return
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		if player.has_method("hit"):
			player.hit(dir)
		else:
			print("Error: Player does not have a 'hit' method!")

func _on_area_3d_body_part_hit(dam):
	health -= dam
	if progress:
		progress.value = health  # Update ProgressBar to reflect health (assuming max_value is 5)
	if health <= 0:
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		if timer:
			timer.start()
		else:
			print("Error: Timer node not found!")

func _on_timer_timeout():
	if progress:
		progress.value -= 10
	else:
		print("Error: ProgressBar node not found!")

func _on_zombiespawn_timer_timeout() -> void:
	pass # Replace with function body.
