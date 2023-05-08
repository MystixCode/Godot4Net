extends StaticBody3D

#var moving_cube_state  : Array
var vel = 0
var length = 0.8
var speed = 5
var accel = 0.1
var pos

func _ready():
	pass

func _process(delta):
	vel += delta * speed
	pos = cos(vel*length)
	position.x += pos
	
#	moving_cube_state = [position]
#
#	#if moving_cube doesnt exist add it to global_state
#	if !get_node("/root/Main").global_state.has("moving_cube"):
#		get_node("/root/Main").global_state["moving_cube"] = {}
#
#	# add moving_cube_state to global_state
#	get_node("/root/Main").global_state["moving_cube"][name] = moving_cube_state
