extends Area3D

var from_player : int
var bullet_state : Array

func _physics_process(delta):
	if get_node("/root/Main").global_state["bullet"].has(name):
		bullet_state = get_node("/root/Main").global_state["bullet"][name]
		position = bullet_state[1]
