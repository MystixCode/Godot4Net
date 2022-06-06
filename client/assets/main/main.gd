extends Node

const p_res := preload("res://../assets/player/player.tscn")
const w_res := preload("res://../assets/world/world.tscn")
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
	get_node("/root/Main/UI/VBox/Connect").connect("pressed", _on_connect_pressed )
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail, CONNECT_DEFERRED)
	multiplayer.server_disconnected.connect(_server_disconnected)

func _on_connect_pressed():
	get_node("/root/Main/UI/VBox/Connect").disabled = true
	print("Connecting..")
	var peer := ENetMultiplayerPeer.new()
	var ip : String = get_node("/root/Main/UI/VBox/IP").text
	var port : int = get_node("/root/Main/UI/VBox/Port").value
	peer.create_client(ip, port)
	multiplayer.set_multiplayer_peer(peer)

func _connected_ok():
	get_node("/root/Main/UI").hide()
	print("Connected as player: " + str(multiplayer.get_unique_id()))
	var w := w_res.instantiate()
	add_child(w, true)
	$UI/VBox.free()
func _server_disconnected():
	print("Server disconnected")

func _connected_fail():
	get_node("/root/Main/UI/VBox/Connect").disabled = false
	print("Connection failed")
	multiplayer.set_multiplayer_peer(null) # Remove peer
	print("Peer removed")

func _physics_process(_delta):
	tickid += 1
#	print("tickid: " + str(tickid))
#	print(global_state)
