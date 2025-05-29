extends CharacterBody3D

var player = null
var state_machine
var health = 5
var is_alive = true  # Track whether the zombie is alive to stop processing after death

const SPEED = 4.0
const ATTACK_RANGE = 2.0

@export var player_path := "/root/main scene/Map/NavigationRegion3D/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree

# Called when the node enters the scene tree for the first time.
func _ready():
	# Use the exported player_path to find the player node
	player = get_node(player_path)
	if not player:
		push_error("Player node not found at path: " + player_path)
		return
	
	# Initialize the state machine
	state_machine = anim_tree.get("parameters/playback")
	if not state_machine:
		push_error("AnimationTree state machine not found!")
		return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Stop processing if the zombie is dead
	if not is_alive:
		return

	# Safety check for player and state machine
	if not player or not state_machine:
		return

	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Run":
			# Navigation
			nav_agent.set_target_position(player.global_position)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_position).normalized() * SPEED
			# Smoothly rotate to face the movement direction
			if velocity.length() > 0:  # Only rotate if there's movement
				rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"Attack":
			# Face the player (keeping Y position fixed to avoid tilting)
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
	
	# Set animation conditions
	var in_range = _target_in_range()
	anim_tree.set("parameters/conditions/attack", in_range)
	anim_tree.set("parameters/conditions/run", !in_range)
	
	# Apply movement
	move_and_slide()

func _target_in_range() -> bool:
	if not player:
		return false
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _on_navigation_agent_3d_target_reached():
	print("in range")



func _hit_finished():
	if not is_alive or not player:
		return
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

func _on_area_3d_body_part_hit(dam):
	if not is_alive:
		return
	
	health -= dam
	if health <= 0:
		is_alive = false
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()
