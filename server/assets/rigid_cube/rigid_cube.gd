extends RigidBody3D


var old_position: Vector3
var old_rotation: Vector3

func _process(_delta):
	#UDP: add player_state_udp to states_udp
	var rigid_cube_state_udp: Dictionary = {}
	if position.distance_to(old_position) >0.00001: # only add if changed enough
		old_position=position
		rigid_cube_state_udp["position"] = position
	if rotation != old_rotation: # only add if changed
			old_rotation=rotation
			rigid_cube_state_udp["rotation"] = rotation
	if !rigid_cube_state_udp.is_empty(): # only add if not empty
		#if states_udp doesnt have player category add it to states_udp
		if !get_node("/root/main/net").states_udp.has("rigid_cube"):
			get_node("/root/main/net").states_udp["rigid_cube"] = {}
		# add player_state to states_udp
		get_node("/root/main/net").states_udp["rigid_cube"][name] = rigid_cube_state_udp
