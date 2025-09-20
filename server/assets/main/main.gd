extends Node

# TODO:
# - issue uf github zum transfermode unreliable im multiplayersynchronizer
# - zerst aber lokal mit rpc umsetze wo unreliable gewünscht
# - change map

const PLAYER_RESOURCE := preload("res://assets/player/player.tscn")

var server_name: String = "Godot4Net"
var port: int = 4242
var max_clients: int = 24
#var tickrate: int = 66
var map: String = "curiosity_islands"

var rng: RandomNumberGenerator
var peer: ENetMultiplayerPeer

func _ready():
	start_server()
 
func start_server():
	print("Starting server " + server_name)
	rng = RandomNumberGenerator.new()
	rng.randomize()
	randomize()

	Engine.physics_jitter_fix = 0.0
	#Engine.physics_ticks_per_second=sv.tickrate
	#Engine.max_fps = sv.tickrate
	#multiplayer.server_relay = false

	peer = ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(self.player_connected)
	multiplayer.peer_disconnected.connect(self.player_disconnected)
	peer.create_server(port, max_clients)
	multiplayer.multiplayer_peer = peer
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return

func player_connected(id):
	print("Player connected: " + str(id))
	var p := PLAYER_RESOURCE.instantiate()
	p.player_name = "Spartan" + str(randi()%201+1)
	p.position = Vector3(rng.randi_range(700,720), 170, rng.randi_range(0,20))
	p.name = str(id)
	p.color = Color.from_hsv((rng.randi() % 12) / 12.0, 1, 1) 
	get_node("/root/Main/MultiplayerSpawner").add_child(p, true)

func player_disconnected(id):
	print("Player disconnected " + str(id))
	get_node("/root/Main/MultiplayerSpawner").get_node(str(id)).queue_free()
