extends CharacterBody3D

var player = null
var state_machine
var health = 8
var is_dying = false

signal zombie_hit

const SPEED = 4.5
const ATTACK_RANGE = 2.0
const DEATH_DELAY = 0.5  # Delay before death sound, adjust based on animation length

@export var player_path := "/root/World/Map/NavigationRegion3D/Player"

@onready var nav_agent = $NavigationAgent3D
@onready var anim_tree = $AnimationTree
@onready var attack_sound = $AttackSound
@onready var death_sound = $DeathSound

func _ready():
	player = get_node(player_path)
	state_machine = anim_tree.get("parameters/playback")

func _process(delta):
	velocity = Vector3.ZERO
	
	match state_machine.get_current_node():
		"Run":
			nav_agent.set_target_position(player.global_transform.origin)
			var next_nav_point = nav_agent.get_next_path_position()
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED
			rotation.y = lerp_angle(rotation.y, atan2(-velocity.x, -velocity.z), delta * 10.0)
		"Attack":
			look_at(Vector3(player.global_position.x, global_position.y, player.global_position.z), Vector3.UP)
			if state_machine.get_current_node() == "Attack" and !attack_sound.playing:  # Play on enter
				attack_sound.play()
	
	anim_tree.set("parameters/conditions/attack", _target_in_range())
	anim_tree.set("parameters/conditions/run", !_target_in_range())
	
	move_and_slide()

func _target_in_range():
	return global_position.distance_to(player.global_position) < ATTACK_RANGE

func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player.hit(dir)

func _on_area_3d_body_part_hit(dam):
	health -= dam
	emit_signal("zombie_hit")
	if health <= 0 and !is_dying:
		is_dying = true
		anim_tree.set("parameters/conditions/die", true)
		# Play groan sound at the start of Die (Getup backward)
		if !death_sound.playing:
			death_sound.play()
		await anim_tree.animation_finished
		queue_free()
