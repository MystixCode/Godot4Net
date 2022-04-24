extends StaticBody3D


var from_player : int
var moving_cube_state : Array

func _physics_process(delta):
	if get_node("/root/Main").global_state["moving_cube"].has(name):
		moving_cube_state = get_node("/root/Main").global_state["moving_cube"][name]
		position = moving_cube_state[0]
