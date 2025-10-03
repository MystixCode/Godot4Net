extends Node

signal on_connected_to_server()
signal on_disconnected_from_server()

signal handle_local_id_assignment(local_id: int)
signal handle_remote_id_assignment(remote_id: int)
signal handle_remote_id_deassignment(remote_id: int)
signal on_player_position_packet(player_position: Dictionary)
signal on_player_rotation_y_packet(player_rotation_y: Dictionary)
signal on_ca_rotation_x_packet(ca_rotation_x: Dictionary)
signal on_bullet_spawn_packet(bullet_spawn: Dictionary)
signal on_bullet_despawn_packet(bullet_despawn: Dictionary)
signal on_bullet_position_packet(bullet_: Dictionary)

var connection: ENetConnection
var server_peer: ENetPacketPeer

var id: int = 1
var remote_ids: Array[int]

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
					connected_to_server()
				ENetConnection.EVENT_DISCONNECT:
					disconnected_from_server()
					return # because connection was set to null
				ENetConnection.EVENT_RECEIVE:
					on_packet_received(peer.get_packet())
					#on_client_packet.emit(peer.get_packet())

			# Call service() again to handle remaining packets in current while loop
			packet_event = connection.service()
			event_type = packet_event[0]

func start_client(ip_address: String = "127.0.0.1", port: int = 42069) -> void:
	connection = ENetConnection.new()
	var error: Error = connection.create_host(1)
	if error:
		print("Client failed to start: ", error_string(error))
		connection = null
		return

	print("Client started")
	server_peer = connection.connect_to_host(ip_address, port)

func connected_to_server() -> void:
	print("Successfully connected to server!")
	on_connected_to_server.emit()

func disconnected_from_server() -> void:
	connection = null
	remote_ids = []
	on_disconnected_from_server.emit()
	print("Successfully disconnected from server!")

func on_packet_received(data: PackedByteArray) -> void:
	var packet_type: int = data.decode_u8(0)
	match packet_type:
		MystixPacket.PACKET_TYPE.ID_ASSIGNMENT:
			add_ids(MystixPacket.decode(data))
		MystixPacket.PACKET_TYPE.ID_DEASSIGNMENT:
			remove_id(MystixPacket.decode(data))
		MystixPacket.PACKET_TYPE.PLAYER_POSITION:
			on_player_position_packet.emit(MystixPacket.decode(data))
		MystixPacket.PACKET_TYPE.PLAYER_ROTATION_Y:
			on_player_rotation_y_packet.emit(MystixPacket.decode(data))
		MystixPacket.PACKET_TYPE.CA_ROTATION_X:
			on_ca_rotation_x_packet.emit(MystixPacket.decode(data))
		MystixPacket.PACKET_TYPE.BULLET_SPAWN:
			on_bullet_spawn_packet.emit(MystixPacket.decode(data))
		MystixPacket.PACKET_TYPE.BULLET_DESPAWN:
			on_bullet_despawn_packet.emit(MystixPacket.decode(data))
		MystixPacket.PACKET_TYPE.BULLET_POSITION:
			on_bullet_position_packet.emit(MystixPacket.decode(data))
		_:
			push_error("Packet type with index ", data[0], " unhandled!")

func add_ids(data: Dictionary) -> void:
	if id == 1: # When id == 1, the id sent by the server is for us
		id = data.id
		print("New remote ids for player: ", str(id))
		handle_local_id_assignment.emit(data.id)

		remote_ids = data.remote_ids
		for remote_id in remote_ids:
			if remote_id == id: continue
			handle_remote_id_assignment.emit(remote_id)

	else: # When id != 1, we already own an id, and just append the remote ids by the sent id
		remote_ids.append(data.id)
		handle_remote_id_assignment.emit(data.id)

func remove_id(data: Dictionary) -> void:
	remote_ids.erase(data.id)
	handle_remote_id_deassignment.emit(data.id)
