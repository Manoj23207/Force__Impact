extends CharacterBody3D

@onready var nav_agent = $NavigationAgent3D

var SPEED = 5.0
func _physics_process(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_location()
