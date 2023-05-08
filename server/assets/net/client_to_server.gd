extends Node


var zoom_min: float = 0
var zoom_max: float = 5

func _enter_tree():
	set_multiplayer_authority(int(str($"..".name)))

@rpc("authority", "call_remote","reliable")
func done_preconfig():
	var new_id = multiplayer.get_remote_sender_id()
	print("-------")
	print(str(new_id) + ": preconfig done")
	assert(multiplayer.is_server())
#	var ip = peer.get_peer(multiplayer.get_remote_sender_id()).get_remote_address()
#	for child in get_node("/root/main/players").get_children():
#		if child.name == str(newplayerid):
#			assert(ip == child.ip)


#	get_node("/root/main/players/" + str(new_id)).player_name = pname
#	get_node("/root/main/players/" + str(new_id)).global_position = pos
	get_node("/root/main/players/" + str(new_id) + "/" + str(new_id)).client_ready = true

	$"/root/main/net".spawn_all_on_new(new_id)
	$"/root/main/net".spawn_new_on_other(new_id)


@rpc("authority", "unreliable_ordered")
func send_input_unreliable(input_json_string: String):
	var id = multiplayer.get_remote_sender_id()
	var input: Dictionary = JSON.parse_string(input_json_string)
	if input.has("mouse_motion"):
		var mouse_motion = Vector2(str_to_var("Vector2" + input["mouse_motion"]) )
		get_node("/root/main/players/" + str(id) + "/" + str(id) + "/inputs").mouse_motion = mouse_motion
	if input.has("keys_motion"):
		var keys_motion = Vector2(str_to_var("Vector2" + input["keys_motion"]) )
		get_node("/root/main/players/" + str(id) + "/" + str(id) + "/inputs").keys_motion = keys_motion
	if input.has("sprint"):
		var sprint = true
		get_node("/root/main/players/" + str(id) + "/" + str(id) + "/inputs").sprint = sprint


@rpc("authority", "reliable")
func send_input_reliable(input_json_string: String):
	var id = multiplayer.get_remote_sender_id()
	var input: Dictionary = JSON.parse_string(input_json_string)
#	print("received_input_tcp: " + str(input))
	if input.has("jump"):
		var jump = true
		get_node("/root/main/players/" + str(id) + "/" + str(id) + "/inputs").jump = jump
	if input.has("shoot"):
		var shoot = true
		get_node("/root/main/players/" + str(id) + "/" + str(id) + "/inputs").shoot = shoot
	if input.has("zoom"):
		var zoom = float(input["zoom"])
		zoom = clamp(zoom,zoom_min,zoom_max)
		get_node("/root/main/players/" + str(id) + "/" + str(id) + "/inputs").zoom = zoom
