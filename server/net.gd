extends Node

# Signals
signal on_peer_connected(peer_id: int)
signal on_peer_disconnected(peer_id: int)

signal on_keys_motion_packet(peer_id: int, keys_motion: KeysMotion)

# General variables
var connection: ENetConnection
var available_peer_ids: Array = range(255, 1, -1) # 2-255
var client_peers: Dictionary[int, ENetPacketPeer]
var peer_ids: Array[int]

func start_server(ip_address: String = "127.0.0.1", port: int = 42069) -> void:
	connection = ENetConnection.new()
	var error: Error = connection.create_host_bound(ip_address, port)
	if error:
		print("Failed to start server: ", error_string(error))
		connection = null
		return
	print("Server started")

func _process(_delta: float) -> void:
	if connection == null:
		return

	handle_events()

func handle_events() -> void:
		var packet_event: Array = connection.service()
		var event_type: ENetConnection.EventType = packet_event[0]

		while event_type != ENetConnection.EVENT_NONE:
			var peer: ENetPacketPeer = packet_event[1]

			match event_type:
				ENetConnection.EVENT_ERROR:
					push_warning("Package resulted in unknown error!")
					return
				ENetConnection.EVENT_CONNECT:
					peer_connected(peer)
				ENetConnection.EVENT_DISCONNECT:
					peer_disconnected(peer)
				ENetConnection.EVENT_RECEIVE:
					on_packet_received(peer.get_meta("id"), peer.get_packet())
					#on_server_packet.emit(peer.get_meta("id"), peer.get_packet())

			# Call service() again to handle remaining packets in current while loop
			packet_event = connection.service()
			event_type = packet_event[0]

func peer_connected(peer: ENetPacketPeer) -> void:
	var peer_id: int = available_peer_ids.pop_back()
	peer.set_meta("id", peer_id)
	client_peers[peer_id] = peer

	print("Peer connected: ", peer_id)
	on_peer_connected.emit(peer_id) # used in spawn player
	
	peer_ids.append(peer_id)
	IDAssignment.create(peer_id, peer_ids).broadcast(Net.connection)

func peer_disconnected(peer: ENetPacketPeer) -> void:
	var peer_id: int = peer.get_meta("id")
	available_peer_ids.push_back(peer_id)
	client_peers.erase(peer_id)

	print("Peer disconnected: ", peer_id)
	on_peer_disconnected.emit(peer_id) # used in despawn player
	IDDeassignment.create(peer_id).broadcast(Net.connection)

func on_packet_received(peer_id: int, data: PackedByteArray) -> void:
	match data[0]:
		Packet.PACKET_TYPE.KEYS_MOTION:
			on_keys_motion_packet.emit(peer_id, KeysMotion.create_from_data(data))
		_:
			push_error("Packet type with index ", data[0], " unhandled!")
