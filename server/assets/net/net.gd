extends Node


#Structure
#	net
#		server_to_client				<-- Node (just one (not for every player))
#	players								<-- Node
#		65254235						<-- Node
#			client_to_server			<-- Node (outside of the Characterbody3D to allow sending data to server before player is spawned)
#			65254235					<-- CharacterBody3D

var server: Dictionary = {
	server_name = "Godot4NetServer",
	port = 4242,  
	maxplayers = 24,
	map = "curiosity_islands",
	mode = ""
}
var peer: ENetMultiplayerPeer
var sv_tickrate: int = 66
var sv_tickid: int
var states_tcp: Dictionary
var states_udp: Dictionary

var cl_updaterate = float(20)
var cl_updaterate_timer = 0.0

@onready var b_res := preload("res://../assets/bullet/bullet.tscn")

func _ready():
	#set server tickrate -> relevant for physics_process() function --> needed for interpolation
	Engine.physics_jitter_fix = 0.0
	Engine.physics_ticks_per_second=sv_tickrate
	Engine.max_fps = sv_tickrate
	multiplayer.server_relay = false
	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	randomize()
	print_net_info()
	start_networking()


func start_networking():
	print("Start networking..")
	peer = ENetMultiplayerPeer.new()
	peer.create_server(server.port, server.maxplayers)
	multiplayer.multiplayer_peer = peer
	var map_res_path: String = "res://assets/maps/" + server.map + ".tscn"
	change_map.call_deferred(load(map_res_path))


# Call this function deferred
func change_map(scene: PackedScene):
	# Remove old map if any.
	if $/root/main/maps.get_children().size() > 0:
		for map in $/root/main/maps.get_children():
			$/root/main/maps.remove_child(map)
			map.queue_free()
	$/root/main/maps.add_child(scene.instantiate())
	print("change map " + scene.resource_path)


func _player_connected(id):	# Called on both client and server
	# Create peer nodes for client to server communication when player is not spawned because authority stuff..
	var client_to_server_node : Node = Node.new()
	client_to_server_node.name = "client_to_server"
	var input_rpc_script: Resource =  load("res://assets/net/client_to_server.gd")
	client_to_server_node.set_script(input_rpc_script)
	var peer_node : Node = Node.new()
	peer_node.name = str(id)
	peer_node.add_child(client_to_server_node)
	get_node("/root/main/players").add_child(peer_node)
	
	spawn_player_on_server(id)

	var player_name = get_node("/root/main/players/" + str(id) + "/" + str(id)).player_name
	var ip = peer.get_peer(id).get_remote_address()
	var port = peer.get_peer(id).get_remote_port()
	var server_to_client_authority = $server_to_client.get_multiplayer_authority()
	var client_to_server_authority = get_node("/root/main/players/" + str(id) + "/client_to_server").get_multiplayer_authority()
	
#	var authority = get_node("/root/main/players/" + str(id) + "/client_to_server").get_multiplayer_authority()
	if server.mode != "headless":

		#TODO: put that code into a new scene/asset and use signals for communication _on_player_connect.. 
		var grid: GridContainer = $"../ui/table/GridContainer"

		if grid.get_child_count() == 0:
			grid.columns = 7
			var head_data = [
				"id",
				"player_name",
				"ip",
				"port",
				"server_to_client_authority",
				"client_to_server_authority",
				"kick_btn"]
			for row in head_data.size():
#				print("add: " + head_data[row])
				var label: Label = Label.new()
				label.name = str(row)
				label.text = head_data[row]
				grid.add_child(label)
#				grid.move_child(label, row)

		var column_data = [
			str(id),
			str(player_name),
			str(ip),
			str(port),
			str(server_to_client_authority),
			str(client_to_server_authority)]
		for row in column_data.size():
#			print("add: " + column_data[row])
			var label: Label = Label.new()
			label.name = str(grid.get_child_count() + 1)
			label.text = column_data[row]
			grid.add_child(label)
		#TODO: button signal
		var btn: Button = Button.new()
		btn.name = str(grid.get_child_count() + 1)
		btn.text = "kick"
		grid.add_child(btn)

	$server_to_client.preconfig.rpc_id(id, server)


func _player_disconnected(id):	# Called on both client and server
	free_player(id)


func spawn_all_on_new(new_id):
	#Spawn already existing players on new client
	var data: Dictionary = {}
	for p in get_node("/root/main/players").get_children():
#		var d_main_auth = str(get_node("/root/main").get_multiplayer_authority())
#		var d_pre_auth = str(get_node("/root/main/net/client_to_server").get_multiplayer_authority())
#		var d_input_auth = str(p.get_node("client_to_server").get_multiplayer_authority())
#		print("player: " + p.player_name + ", id: " + str(p.name) + ", main_authority: " + d_main_auth + ", pre_authority: " + d_pre_auth + ", input_authority: " + d_input_auth)

		data[int(str(p.name))] = {
				"ip": p.get_node(str(p.name)).ip,
				"name": p.get_node(str(p.name)).player_name,
				"color": p.get_node(str(p.name)).color,
				"pos": p.get_node(str(p.name)).global_transform
			}

	$server_to_client.spawn_players_on_client.rpc_id(new_id, data)
	print("spawn_all_on_new: " + str(data))


func spawn_new_on_other(_id):
	var new_id = multiplayer.get_remote_sender_id()
	var new_player = get_node("/root/main/players/" + str(new_id) + "/" + str(new_id))
	var data: Dictionary = {}
	for p in get_node("/root/main/players").get_children():
		if int(str(p.get_name())) != new_id:
			data[int(new_id)] =  {
					"ip": new_player.ip,
					"name": new_player.player_name,
					"color": new_player.color,
					"pos": new_player.global_transform
				}
	for p in get_node("/root/main/players").get_children():
		if int(str(p.get_name())) != new_id:
			$server_to_client.spawn_players_on_client.rpc_id(int(str(p.get_name())), data)
			print("spawn_new_on_other: " + str(data))


func spawn_player_on_server(id):	#TODO player nur spawna wenn im sichtbereich und despawn wenn weg
#	print("spawn_player_on_server(" + str(id) + ")")	
	var player = load("res://assets/player/player.tscn").instantiate()
	player.set_name(str(id))
	player.ip = peer.get_peer(id).get_remote_address()
	player.player_name = "Spartan " + str(randi()%201+1)
	player.color = Color.from_hsv((randi() % 12) / 12.0, 1, 1)
	player.position = Vector3(randf_range(700.0, 705.0), 200.0, randf_range(5.0, 10.0))
	get_node("/root/main/players/" + str(id)).add_child(player)


func free_player(id):
	if get_node("/root/main/players").has_node(str(id)):
		print("free_player(" + str(id) + ")")
		#call free_player_on_client on all clients via server_to_client rpc
		$server_to_client.free_player_on_client.rpc(id)
		get_node("/root/main/players").remove_child(get_node("/root/main/players").get_node(str(id)))

		#remove from table
		var grid: GridContainer = get_node("../ui/table/GridContainer")
		var range_start
		var range_end
		for child in grid.get_children():
			if child.text:
				if child.text == str(id):
					range_start=int(str(child.name))
					range_end=int(str(child.name)) + grid.columns
					break
					
		for item_name in range(range_start, range_end):
			get_node("../ui/table/GridContainer/" + str(item_name)).free()


func spawn_bullet(from_player: int):
	#on server
	var b := b_res.instantiate()
	b.name = str(from_player) + "_" + str(randi()%1001+1)
	b.position = get_node("/root/main/players/" + str(from_player) + "/" + str(from_player) + "/shoot_from").global_position
	b.from_player = from_player
	$"/root/main/bullets".add_child(b)

	#on clients
	var data: Dictionary = {}
	for p in get_node("/root/main/players").get_children():
		data["name"] = b.name
		data["from_player"] = from_player
		data["position"] = get_node("/root/main/players/" + str(from_player) + "/" + str(from_player) + "/shoot_from").global_position
		$server_to_client.spawn_bullet_on_client.rpc_id(int(str(p.get_name())), data)


func free_bullet(id):
	if get_node("/root/main/bullets").has_node(str(id)):
		if states_udp.has("bullet"):
			if states_udp["bullet"].has(name):
				states_udp["bullet"].remove(name)
		get_node("/root/main/bullets/" + str(id)).queue_free()
		$server_to_client.free_bullet_on_client.rpc(id)


func print_net_info():
	print("****************************************")
	print("sv_tickrate:   " + str(sv_tickrate) + " ticks per second")
	print("sv_ticktime:   " + str(1/float(sv_tickrate)) + " seconds")
	print("****************************************")


func _physics_process(delta):
	sv_tickid += 1
	if !states_udp.is_empty() or !states_tcp.is_empty():
		
		for peer in get_node("/root/main/players").get_children():
			var p = peer.get_node(str(peer.name))
			if p.client_ready == true:
#				cl_updaterate_timer += delta
#				if cl_updaterate_timer >= 1.0/cl_updaterate:
#					cl_updaterate_timer = 0.0						#1.0/p.cl_updaterate
#					print(str(states_udp))
##					rpc_unreliable_id(int(p.get_name()), "update_states", states)
#					update_states_on_clients.rpc_id(int(str(p.name)), states)
				if !states_udp.is_empty():
					var states_udp_json_string: String = JSON.stringify(states_udp)
#					print("udp: " + states_udp_json_string)
					$/root/main/net/server_to_client.send_output_to_client_unreliable.rpc_id(int(str(p.get_name())), states_udp_json_string)
				if !states_tcp.is_empty():
					var states_tcp_json_string: String = JSON.stringify(states_tcp)
#					print("tcp: " + states_tcp_json_string)
					$/root/main/net/server_to_client.send_output_to_client_reliable.rpc_id(int(str(p.get_name())), states_tcp_json_string)
	states_udp = {}
	states_tcp = {}

#@rpc("unreliable_ordered")
#func update_states_on_clients():
#	pass
