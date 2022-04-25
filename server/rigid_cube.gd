extends RigidDynamicBody3D

var rigid_cube_state  : Array

func _process(delta):
	#Add moving_cube_state to global_state after physic calculations
	rigid_cube_state = [position, rotation]
	get_node("/root/Main").global_state["rigid_cube"][name] = rigid_cube_state
