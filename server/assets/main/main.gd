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
var camel_case_map : String

var rng: RandomNumberGenerator
var peer: ENetMultiplayerPeer

func _ready():
	camel_case_map = no_snake(map)
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

	var map_res_path: String = "res://assets/maps/" + map + ".tscn"
	# Load the scene dynamically using ResourceLoader
	var map_scene = load(map_res_path) as PackedScene
	change_map(map_scene)

func change_map(scene: PackedScene):
	# Remove old map if any.
	if $/root/Main/Maps.get_children().size() > 0:
		for m in $/root/Main/Maps.get_children():
			$/root/Main/Maps.remove_child(m)
			m.queue_free()
	$/root/Main/Maps.add_child(scene.instantiate())
	print("Change map to " + scene.resource_path)

func player_connected(id):
	print("Player connected: " + str(id))
	camel_case_map = no_snake(map)
	var p := PLAYER_RESOURCE.instantiate()
	p.player_name = "Spartan" + str(randi()%201+1)
	p.position = get_node("/root/Main/Maps/" + camel_case_map).spawn_area
	p.name = str(id)
	p.color = Color.from_hsv((rng.randi() % 12) / 12.0, 1, 1) 
	get_node("/root/Main/Players").add_child(p, true)

func player_disconnected(id):
	print("Player disconnected " + str(id))
	get_node("/root/Main/Players").get_node(str(id)).queue_free()

func no_snake(snake_str: String) -> String:
	var words = snake_str.split("_")
	var result = ""
	for word in words:
		if word.length() > 0:
			# Capitalize first letter, keep rest of the word as is
			result += word[0].to_upper() + word.substr(1).to_lower()
	return result
