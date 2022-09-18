extends RigidBody3D

var rigid_cube_state  : Array

func _process(_delta):
	rigid_cube_state = [position, rotation]
	
	#if rigid_cube doesnt exist add it to global_state
	if !get_node("/root/Main").global_state.has("rigid_cube"):
		get_node("/root/Main").global_state["rigid_cube"] = {}
	
	# add rigid_cube_state to global_state
	get_node("/root/Main").global_state["rigid_cube"][name] = rigid_cube_state
