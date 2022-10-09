extends CharacterBody3D

var from_player : int
var mob_state : Array

func _physics_process(_delta):
	# if category moving_cube doesnt exist in global_state add it
	if !get_node("/root/Main").global_state.has("mob"):
		get_node("/root/Main").global_state["mob"] = {}

	# add global moving_cube_state into vars
	if get_node("/root/Main").global_state["mob"].has("tzestname"):
		mob_state = get_node("/root/Main").global_state["mob"]["tzestname"]
		print("---------------------------------------------------------")
		print(mob_state[0])
		position = mob_state[0]
		rotation = mob_state[1]
		print("position: " + str(position))
