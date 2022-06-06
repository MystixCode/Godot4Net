extends Node

const p_res := preload("res://../assets/player/player.tscn")
var port := 4242
var global_states : Dictionary
@export var global_state : Dictionary = {
	"player": {},
	"bullet": {},
	"moving_cube": {},
	"rigid_cube": {},
	"other": {}
}
var tickid : int = 0

func _ready():
	start_server()

func start_server():
	print("Starting Server")
	randomize()
	var peer := ENetMultiplayerPeer.new()
	multiplayer.peer_connected.connect(self.player_connected)
	multiplayer.peer_disconnected.connect(self.player_disconnected)
	peer.create_server(port)
	multiplayer.set_multiplayer_peer(peer)

func player_connected(id):
	print("Player connected: " + str(id))
	var p := p_res.instantiate()
	p.player_name = "Spartan" + str(randi()%201+1)
	p.position = Vector3(randi_range(-3,3), 200, randi_range(-3,3))
	p.name = str(id)
	get_node("/root/Main/MultiplayerSpawner").add_child(p, true)

func player_disconnected(id):
	print("Player disconnected " + str(id))
	#remove player object
	get_node("/root/Main/MultiplayerSpawner").get_node(str(id)).queue_free()
	#remove player from global_State
	global_state["player"].erase(str(id))

func _physics_process(_delta):
	tickid += 1
#	print("tickid: " + str(tickid))
#	print(global_state)
