extends Node

const WORLD_RESOURCE := preload("res://assets/world/world.tscn")

var peer: ENetMultiplayerPeer
#var tickrate: int = 66
var address : String
var port : int

func _ready():
	Engine.physics_jitter_fix = 0.0
	#Engine.physics_ticks_per_second=tickrate
	#Engine.max_fps = tickrate
	#multiplayer.server_relay = false
	
	get_node("/root/Main/UI/UIConnect/PanelContainer/VBox/Connect").connect("pressed", _on_connect_pressed )
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail, CONNECT_DEFERRED)
	multiplayer.server_disconnected.connect(_server_disconnected)

func _on_connect_pressed():
	get_node("/root/Main/UI/UIConnect/PanelContainer/VBox/Connect").disabled = true
	print("Connecting to game server..")
	peer = ENetMultiplayerPeer.new()
	address = get_node("/root/Main/UI/UIConnect/PanelContainer/VBox/Address").text
	port = get_node("/root/Main/UI/UIConnect/PanelContainer/VBox/Port").value
	peer.create_client(address, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer

func _connected_ok():
	print("Connected as player: " + str(multiplayer.get_unique_id()))
	var w := WORLD_RESOURCE.instantiate()
	add_child(w, true)
	get_node("/root/Main/UI/UIConnect").free()

func _player_connected(id):	# Called on both clients and server when a peer connects. 
	print("_player_connected(" + str(id) + ")")

func _player_disconnected(id):
#	free_player(id)
	print("_player_disconnected(" + str(id) + ")")

func _server_disconnected():
	print("Server disconnected")
	#get_node("/root/Main/UI/HealthBar").free()

	if has_node("World"):
		$World.queue_free()

	if get_node("UI/Debug/Window").visible:
		get_node("UI/Debug/Window").visible = false

	var ui_connect_res := preload("res://assets/ui/connect/ui_connect.tscn")
	var ui_connect := ui_connect_res.instantiate()
	get_node("/root/Main/UI/").add_child(ui_connect)
	get_node("/root/Main/UI/UIConnect/PanelContainer/VBox/Connect").connect("pressed", _on_connect_pressed )

func _connected_fail():
	get_node("/root/Main/UI/UIConnect/PanelContainer/VBox/Connect").disabled = false
	print("Connection failed")
	multiplayer.set_multiplayer_peer(null)
	print("Peer removed")
