extends ProgressBar

func _process(_delta: float) -> void:
	var peer = multiplayer.multiplayer_peer
	if peer != null and peer.get_connection_status() == MultiplayerPeer.CONNECTION_CONNECTED:
		if str(multiplayer.get_unique_id()) == $"../../".name:
			value = get_node("/root/Main/MultiplayerSpawner/" + str(multiplayer.get_unique_id())).health
