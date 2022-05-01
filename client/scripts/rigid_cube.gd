extends RigidDynamicBody3D

var rigid_cube_state : Array

func _physics_process(delta):
	if get_node("/root/Main").global_state["rigid_cube"].has(name):
		rigid_cube_state = get_node("/root/Main").global_state["rigid_cube"][name]
		position = rigid_cube_state[0]
		rotation = rigid_cube_state[1]

