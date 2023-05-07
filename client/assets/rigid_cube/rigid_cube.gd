extends RigidBody3D

var rigid_cube_state : Array

func _physics_process(_delta):
	# if category rigid_cube doesnt exist in global_state add it
#	if !get_node("/root/Main").global_state.has("rigid_cube"):
#		get_node("/root/Main").global_state["rigid_cube"] = {}
#
#	# add global rigid_cube_state into varsw
#	if get_node("/root/Main").global_state["rigid_cube"].has(name):
#		rigid_cube_state = get_node("/root/Main").global_state["rigid_cube"][name]
#		position = rigid_cube_state[0]
#		rotation = rigid_cube_state[1]
	pass
