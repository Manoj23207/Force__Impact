extends Node3D

@export var zombie_scene: PackedScene  # Assign zombie.tscn in the Inspector
@export var spawn_radius: float = 10.0  # Radius around the player to spawn zombies
@export var max_zombies: int = 5  # Maximum number of zombies at a time

var player: Node3D
@onready var spawn_timer: Timer = $ZombieSpawnTimer 

func _ready():
	# Get the player node
	player = get_node("/root/World/Map/NavigationRegion3D/Player")
	if player == null:
		print("Error: Could not find player node at /root/World/Map/NavigationRegion3D/Player!")
	
	# Ensure the timer is set up
	if spawn_timer == null:
		print("Error: SpawnTimer node not found! Please add a Timer node as a child of Spawns.")
	else:
		spawn_timer.wait_time = 5.0  # Spawn every 5 seconds
		spawn_timer.autostart = true
		spawn_timer.one_shot = false  # Keep spawning continuously

func spawn_zombie(spawn_pos: Vector3):  # Renamed parameter to avoid shadowing
	var zombie_instance = zombie_scene.instantiate()
	zombie_instance.global_position = spawn_pos
	add_child(zombie_instance)
	zombie_instance.set_player(player)

func _on_SpawnTimer_timeout():
	# Check if we have too many zombies already
	var current_zombies = get_children().filter(func(child): return child is CharacterBody3D).size()
	if current_zombies >= max_zombies:
		return

	# Spawn a zombie at a random position near the player
	if player != null:
		var spawn_pos = player.global_position + Vector3(
			randf_range(-spawn_radius, spawn_radius),
			0,
			randf_range(-spawn_radius, spawn_radius)
		)
		spawn_zombie(spawn_pos)
	else:
		print("Warning: Player node is null, cannot spawn zombie!")
