extends Node


@rpc("call_remote", "reliable")
func preconfig(info):
	print("preconfig(" + str(info) + ")")
	for key in info:	#merge info dict into serverinfo dict
		get_node("/root/main/net").server[key] = info[key]

	var map_res_path: String = "res://assets/maps/" + get_parent().server.map + ".tscn"
	get_node("/root/main/ui/loading").load_map(map_res_path)

	var id: int = multiplayer.get_unique_id()
	get_node("/root/main/players/" + str(id) + "/client_to_server").done_preconfig.rpc_id(1)


@rpc("call_remote", "reliable")
func spawn_players_on_client(data):
#	print("spawn_players_on_client: " + str(data))
	print("-------")
	for player_id in data:
		var player = preload("res://assets/player/player.tscn").instantiate()
		player.set_name(str(player_id))
		player.player_name = data[player_id]["name"]
		player.color = data[player_id]["color"]
#		var color: Color =data[player_id]["color"]
#		player.get_node("MeshInstance3D").mesh.material.albedo_color = color
		player.global_transform=data[player_id]["pos"]
		
		
		if player_id != multiplayer.get_unique_id():
			# Create peer nodes for client to server communication when player is not spawned because authority stuff..
			var client_to_server_node : Node = Node.new()
			client_to_server_node.name = "client_to_server"
			var input_rpc_script: Resource =  load("res://assets/net/client_to_server.gd")
			client_to_server_node.set_script(input_rpc_script)

			var peer_node : Node = Node.new()
			peer_node.name = str(player_id)
			peer_node.add_child(client_to_server_node)
			get_node("/root/main/players").add_child(peer_node)
		#	get_node("/root/main/players/" + str(multiplayer.get_unique_id()) + "/client_to_server").process_mode = Node.PROCESS_MODE_ALWAYS

		get_node("/root/main/players/" + str(player_id)).add_child(player)

	if get_node("/root/main/ui/").has_node("launcher"):
		get_node("/root/main/ui/launcher").free()


@rpc("call_remote", "reliable")
func free_player_on_client(id):
	if get_node("/root/main/players").has_node(str(id)):
		print("freeplayer(" + str(id) + ")")
		get_node("/root/main/players").remove_child(get_node("/root/main/players").get_node(str(id)))


@rpc("call_remote", "unreliable_ordered")
func send_output_to_client_unreliable(states_udp_json_string: String):
	var states_udp: Dictionary = JSON.parse_string(states_udp_json_string)
#	print("udp_received: " + str(states_udp))
	for id in states_udp["player"]:
		var player = get_node("/root/main/players/" + id + "/" + id)
		if states_udp["player"][id].has("rotation"):
			player.rotation = Vector3(str_to_var("Vector3" + states_udp["player"][id]["rotation"]))
		if states_udp["player"][id].has("position"):
			player.position = Vector3(str_to_var("Vector3" + states_udp["player"][id]["position"]))
		if states_udp["player"][id].has("camera_arm_rotation"):
			player.camera_arm.rotation = Vector3(str_to_var("Vector3" + states_udp["player"][id]["camera_arm_rotation"]))

#	var rotation = Vector3(str_to_var("Vector3" + output["rotation"]))
#	get_node("/root/main/players/" + str(id) + "/" + str(id)).rotation = rotation
#	var position = Vector3(str_to_var("Vector3" + output["position"]))
#	get_node("/root/main/players/" + str(id) + "/" + str(id)).position = position
#	var camera_arm_rotation = Vector3(str_to_var("Vector3" + output["camera_arm_rotation"]))
#	get_node("/root/main/players/" + str(id) + "/" + str(id) + "/SpringArm3D").rotation = camera_arm_rotation

@rpc("call_remote", "reliable")
func send_output_to_client_reliable(states_tcp_json_string: String):
	var states_tcp: Dictionary = JSON.parse_string(states_tcp_json_string)
#	print("tcp_received: " + str(states_tcp))
	for id in states_tcp["player"]:
		var player = get_node("/root/main/players/" + id + "/" + id)
		if states_tcp["player"][id].has("camera_arm_scale"):
			player.camera_arm.scale = Vector3(str_to_var("Vector3" + states_tcp["player"][id]["camera_arm_scale"]))

#	var output: Dictionary = JSON.parse_string(output_json_string)
#	var id = int(output["id"])
#	var camera_arm_scale = Vector3(str_to_var("Vector3" + output["camera_arm_scale"]))
##	print("received scale: " + str(camera_arm_scale))
#	get_node("/root/main/players/" + str(id) + "/" + str(id) + "/SpringArm3D").scale = camera_arm_scale
