extends Node3D

const Player := preload("res://Player.tscn")
var port := 4242

func _ready():
	print("Starting Server")
	randomize()

	var peer := ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(self.player_connected)
	multiplayer.peer_disconnected.connect(self.player_disconnected)
	peer.create_server(port)
	multiplayer.set_multiplayer_peer(peer)
	print("is_server: " + str(multiplayer.is_server()))

func player_connected(id):
	print("Player connected: " + str(id))
	var p := Player.instantiate()
	p.synced_player_name = "Player " + str(id)
	p.position = Vector3(randi_range(-3,3), 5, randi_range(-3,3))
	p.name = str(id)
	$Players.add_child(p) #Could probably do it via spawn func?

func player_disconnected(id):
	print("Player disconnected " + str(id))
	$Players.get_node(str(id)).queue_free()
