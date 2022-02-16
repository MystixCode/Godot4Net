extends Node

const Player := preload("res://Player.tscn")

func _ready():
	multiplayer.connected_to_server.connect(_connected_ok)
	multiplayer.connection_failed.connect(_connected_fail, CONNECT_DEFERRED)
	multiplayer.server_disconnected.connect(_server_disconnected)

func _on_connect_pressed():
		$"UI/VBox/Connect".disabled = true
		print("Connecting..")
		var peer := ENetMultiplayerPeer.new()
		var ip : String = $UI/VBox/IP.text
		var port : int = $UI/VBox/Port.value
		peer.create_client(ip, port)
		multiplayer.set_multiplayer_peer(peer)

func _connected_ok():
	$UI.hide()
	print("Connected as player: " + str(multiplayer.get_unique_id()))

func _server_disconnected():
	print("Server disconnected")

func _connected_fail():
	$"UI/VBox/Connect".disabled = false
	print("Connection failed")
	multiplayer.set_multiplayer_peer(null) # Remove peer
	print("Peer removed")
