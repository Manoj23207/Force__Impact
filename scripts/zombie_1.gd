extends CharacterBody3D

var current_state="idle"
var next_state="idle"
var previous_state

func _physics_process(delta):
	previous_state = current_state
	current_state = next_state
	
	match current_state:
		"idle":
			idle()
		"chase":
			chase()
		"bite":
			bite()
		
func idle():
	print("we are idle")
	if Input.is_action_just_pressed("a"):
		next_state="chase"
	
func chase():
	print("we are chasing")
	if Input.is_action_just_pressed("a"):
		next_state="idle"
	#all our movement code would be here
	
func bite():
	print("we are attacking")



func _on_area_3d_body_part_hit(dam):
	health -= dam
	if health <= 0:
		anim_tree.set("parameters/conditions/die", true)
		await get_tree().create_timer(4.0).timeout
		queue_free()
