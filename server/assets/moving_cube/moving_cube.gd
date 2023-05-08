extends StaticBody3D

#var moving_cube_state  : Array
var vel = 0
var length = 0.8
var speed = 5
var accel = 0.1
var pos
var old_position: Vector3
var old_rotation: Vector3

func _ready():
	pass

func _process(delta):
	vel += delta * speed
	pos = cos(vel*length)
	position.x += pos
	
	#UDP: add player_state_udp to states_udp
	var moving_cube_state_udp: Dictionary = {}
	if position.distance_to(old_position) >0.00001: # only add if changed enough
		old_position=position
		moving_cube_state_udp["position"] = position
	if rotation != old_rotation: # only add if changed
			old_rotation=rotation
			moving_cube_state_udp["rotation"] = rotation
	if !moving_cube_state_udp.is_empty(): # only add if not empty
		#if states_udp doesnt have player category add it to states_udp
		if !get_node("/root/main/net").states_udp.has("moving_cube"):
			get_node("/root/main/net").states_udp["moving_cube"] = {}
		# add player_state to states_udp
		get_node("/root/main/net").states_udp["moving_cube"][name] = moving_cube_state_udp
	
	
#	moving_cube_state = [position]
#
#	#if moving_cube doesnt exist add it to global_state
#	if !get_node("/root/Main").global_state.has("moving_cube"):
#		get_node("/root/Main").global_state["moving_cube"] = {}
#
#	# add moving_cube_state to global_state
#	get_node("/root/Main").global_state["moving_cube"][name] = moving_cube_state
