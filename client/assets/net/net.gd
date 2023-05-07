extends Node


#Structure
#	net
#		server_to_client				<-- Node (just one (not for every player))
#	players								<-- Node
#		65254235						<-- Node
#			client_to_server			<-- Node (outside of the Characterbody3D to allow sending data to server before player is spawned)
#			65254235					<-- CharacterBody3D

var server: Dictionary = {
	ip = "localhost",
	port = 4242
}
var peer: ENetMultiplayerPeer
var peer_id: int
var cl_tickrate: int = 66
var cl_updaterate: int = 20
var cl_interp_ratio: int = 2
var cl_tickid: int
var last_sv_tickid: int
var statebuffer: Array
var cl_interp_time: float = float(cl_interp_ratio) / float(cl_updaterate)


func _ready():
	Engine.physics_jitter_fix = 0.0
	Engine.physics_ticks_per_second=cl_tickrate
	Engine.max_fps = cl_tickrate
	multiplayer.server_relay = false

	multiplayer.peer_connected.connect(_player_connected)
	multiplayer.peer_disconnected.connect(_player_disconnected)
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail, CONNECT_DEFERRED)
	multiplayer.server_disconnected.connect(_server_disconnected)
	print_net_info()


func start_networking(): # called in launcher.gd
	print("Start networking..")
	peer = ENetMultiplayerPeer.new()
	peer.create_client(server.ip, server.port)
	multiplayer.multiplayer_peer = peer
	get_node("/root/main/ui/launcher/panel/vbox/msg").text="Connecting to server"
	peer_id = multiplayer.get_unique_id()


func _player_connected(id):	# Called on both clients and server when a peer connects. 
	get_node("/root/main/ui/launcher/panel/vbox/msg").text = "Connection established: " + str(id)

	# Create peer nodes for client to server communication when player is not spawned because authority stuff..
	var client_to_server_node : Node = Node.new()
	client_to_server_node.name = "client_to_server"
	var input_rpc_script: Resource =  load("res://assets/net/client_to_server.gd")
	client_to_server_node.set_script(input_rpc_script)

	var peer_node : Node = Node.new()
	peer_node.name = str(multiplayer.get_unique_id())
	peer_node.add_child(client_to_server_node)
	get_node("/root/main/players").add_child(peer_node)
#	get_node("/root/main/players/" + str(multiplayer.get_unique_id()) + "/client_to_server").process_mode = Node.PROCESS_MODE_ALWAYS


func _player_disconnected(id):
#	free_player(id)
	print("_peer_disconnected(" + str(id) + ")")


func _connected_ok():	# Only called on clients, not server.
	pass


func _connected_fail():
	print("Connection failed")
	get_node("/root/main/ui/launcher/panel/vbox/msg").text = "Connection failed"
	get_node("/root/main/ui/launcher/panel/vbox/connect").disabled = false


func _server_disconnected():
	if $/root/main/players.get_children():
		for p in $/root/main/players.get_children():
			p.free()
	var launcher = load("res://assets/ui/launcher/launcher.tscn").instantiate()
	get_node("/root/main/ui").add_child(launcher)	
	get_node("/root/main/maps/" + server.map).free()
	get_node("/root/main/ui/launcher/panel/vbox/msg").text = "Connection lost"


func print_net_info():
	print("******************************************")
	print("cl_tickrate:     " + str(cl_tickrate) + " ticks per second")
	print("cl_updaterate:   " + str(cl_updaterate) + " snapshots per second")
	print("cl_interp_ratio: " + str(cl_interp_ratio))
	print("cl_ticktime:     " + str(1/float(cl_tickrate)) + " seconds")
	print("cl_interp_time:  " + str(cl_interp_time) + " seconds")
	print("******************************************")


#func _physics_process(delta):
#	cl_tickid += 1
#	if statebuffer.size() == cl_interp_ratio:
#		for i in statebuffer:
#			if get_node("/root/Main/Players/").has_node(str(i.playerid)):
#				var p = get_node("/root/Main/Players/" + str(i.playerid))
#				p.global_transform = p.global_transform.interpolate_with(i.pos, cl_interp_time)


#@rpc("call_remote","unreliable_ordered")
#func update_states_on_clients(states):	
#	for s in states:
#		if s.sv_tickid > cl_tickid:
#			if last_sv_tickid >= s.sv_tickid: #out of order packet.. drop
#				print("out of order packet drop!")
#				return
#			if statebuffer.size() == cl_interp_ratio: #TODO statebuffer in player verschiebe jeweils oder so
#				statebuffer.erase(0)
#			statebuffer += [{"playerid": s.playerid, "sv_tickid": s.sv_tickid, "pos": s.pos}]
#			last_sv_tickid = s.sv_tickid
