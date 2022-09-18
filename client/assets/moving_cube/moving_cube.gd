extends StaticBody3D


var from_player : int
var moving_cube_state : Array

func _physics_process(_delta):
	# if category moving_cube doesnt exist in global_state add it
	if !get_node("/root/Main").global_state.has("moving_cube"):
		get_node("/root/Main").global_state["moving_cube"] = {}

	# add global moving_cube_state into vars
	if get_node("/root/Main").global_state["moving_cube"].has(name):
		moving_cube_state = get_node("/root/Main").global_state["moving_cube"][name]
		position = moving_cube_state[0]
