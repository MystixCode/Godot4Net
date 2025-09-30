## Encoding and sending or broadcasting packets
##
## Send custom packet with ENet low-level api.
## A class that has functions that can be used without instantiating because they are static.
##
class_name MystixPacket

enum PACKET_TYPE {
	ID_ASSIGNMENT = 0,
	ID_DEASSIGNMENT = 1,
	KEYS_MOTION = 11,
	MOUSE_MOTION = 12,
	IS_SPRINTING = 13,
	IS_JUMPING = 14,
	IS_SHOOTING = 15,
	PLAYER_POSITION = 16,
	PLAYER_ROTATION_Y = 17,
	CA_ROTATION_X = 18
}

## Encodes a packet based on type and provided data
static func encode(packet_type: PACKET_TYPE, data: Dictionary) -> PackedByteArray:
	var result: PackedByteArray
	
	result.resize(1)
	result.encode_u8(0, packet_type)
	
	match packet_type:
		PACKET_TYPE.ID_ASSIGNMENT:
			if not data.has("id") or not data.has("remote_ids"):
				push_error("Missing id or remote_ids for ID_ASSIGNMENT")
				return PackedByteArray()
			result.resize(2 + data["remote_ids"].size())
			result.encode_u8(1, data["id"])
			for i: int in data["remote_ids"].size():
				result.encode_u8(2 + i, data["remote_ids"][i])
		PACKET_TYPE.ID_DEASSIGNMENT:
			if not data.has("id"):
				push_error("Missing id for ID_DEASSIGNMENT")
				return PackedByteArray()
			result.resize(2)
			result.encode_u8(1, data["id"])
		PACKET_TYPE.KEYS_MOTION:
			if not data.has("id") or not data.has("keys_motion"):
				push_error("Missing id or keys_motion for KEYS_MOTION")
				return PackedByteArray()
			result.resize(10)
			result.encode_u8(1, data["id"])
			result.encode_float(2, data["keys_motion"].x)
			result.encode_float(6, data["keys_motion"].y)
		PACKET_TYPE.MOUSE_MOTION:
			if not data.has("id") or not data.has("mouse_motion"):
				push_error("Missing id or keys_motion for MOUSE_MOTION")
				return PackedByteArray()
			result.resize(10)
			result.encode_u8(1, data["id"])
			result.encode_float(2, data["mouse_motion"].x)
			result.encode_float(6, data["mouse_motion"].y)
		PACKET_TYPE.IS_SPRINTING:
			if not data.has("id") or not data.has("is_sprinting"):
				push_error("Missing id or is_sprinting for IS_SPRINTING")
				return PackedByteArray()
			result.resize(10)
			result.encode_u8(1, data["id"])
			result.encode_u8(2, data["is_sprinting"])
		PACKET_TYPE.IS_JUMPING:
			if not data.has("id") or not data.has("is_jumping"):
				push_error("Missing id or is_jumping for IS_JUMPING")
				return PackedByteArray()
			result.resize(10)
			result.encode_u8(1, data["id"])
			result.encode_u8(2, data["is_jumping"])
		PACKET_TYPE.IS_SHOOTING:
			if not data.has("id") or not data.has("is_shooting"):
				push_error("Missing id or is_sprinting for IS_SHOOTING")
				return PackedByteArray()
			result.resize(10)
			result.encode_u8(1, data["id"])
			result.encode_u8(2, data["is_shooting"])
		PACKET_TYPE.PLAYER_POSITION:
			if not data.has("id") or not data.has("position"):
				push_error("Missing id or position for PLAYER_POSITION")
				return PackedByteArray()
			result.resize(14)
			result.encode_u8(1, data["id"])
			result.encode_float(2, data["position"].x)
			result.encode_float(6, data["position"].y)
			result.encode_float(10, data["position"].z)
		PACKET_TYPE.PLAYER_ROTATION_Y:
			if not data.has("id") or not data.has("rotation_y"):
				push_error("Missing id or rotation_y for PLAYER_ROTATION_Y")
				return PackedByteArray()
			result.resize(6)
			result.encode_u8(1, data["id"])
			result.encode_float(2, data["rotation_y"])
		PACKET_TYPE.CA_ROTATION_X:
			if not data.has("id") or not data.has("ca_rotation_x"):
				push_error("Missing id or ca_rotation_x for CA_ROTATION_X")
				return PackedByteArray()
			result.resize(6)
			result.encode_u8(1, data["id"])
			result.encode_float(2, data["ca_rotation_x"])
		_:
			push_error("Unknown packet type: " + str(packet_type))
			return PackedByteArray()

	return result

## Decodes a packet based on its type and returns the data as a Dictionary
static func decode(data: PackedByteArray) -> Dictionary:
	if data.is_empty():
		push_error("Received empty packet data")
		return {}
	
	var packet_type: int = data.decode_u8(0)
	var result: Dictionary = {}
	
	match packet_type:
		PACKET_TYPE.ID_ASSIGNMENT:
			if data.size() < 2:
				push_error("Invalid ID_ASSIGNMENT packet size: " + str(data.size()))
				return {}
			var id: int = data.decode_u8(1)
			var remote_ids: Array[int] = []
			for i in range(2, data.size()):
				remote_ids.append(data.decode_u8(i))
			result = {"id": id, "remote_ids": remote_ids}
		PACKET_TYPE.ID_DEASSIGNMENT:
			if data.size() < 2:
				push_error("Invalid ID_DEASSIGNMENT packet size: " + str(data.size()))
				return {}
			result = {"id": data.decode_u8(1)}
		PACKET_TYPE.KEYS_MOTION:
			if data.size() < 10:
				push_error("Invalid KEYS_MOTION packet size: " + str(data.size()))
				return {}
			var id: int = data.decode_u8(1)
			var keys_motion: Vector2 = Vector2(
				data.decode_float(2),
				data.decode_float(6)
			)
			result = {"id": id, "keys_motion": keys_motion}
		PACKET_TYPE.MOUSE_MOTION:
			if data.size() < 10:
				push_error("Invalid MOUSE_MOTION packet size: " + str(data.size()))
				return {}
			var id: int = data.decode_u8(1)
			var mouse_motion: Vector2 = Vector2(
				data.decode_float(2),
				data.decode_float(6)
			)
			result = {"id": id, "mouse_motion": mouse_motion}
		PACKET_TYPE.IS_SPRINTING:
			if data.size() < 10:
				push_error("Invalid IS_SPRINTING packet size: " + str(data.size()))
				return {}
			var id: int = data.decode_u8(1)
			var is_sprinting: bool = data.decode_u8(2)
			result = {"id": id, "is_sprinting": is_sprinting}
		PACKET_TYPE.IS_JUMPING:
			if data.size() < 10:
				push_error("Invalid IS_JUMPING packet size: " + str(data.size()))
				return {}
			var id: int = data.decode_u8(1)
			var is_jumping: bool = data.decode_u8(2)
			result = {"id": id, "is_jumping": is_jumping}
		PACKET_TYPE.IS_SHOOTING:
			if data.size() < 10:
				push_error("Invalid IS_SHOOTING packet size: " + str(data.size()))
				return {}
			var id: int = data.decode_u8(1)
			var is_shooting: bool = data.decode_u8(2)
			result = {"id": id, "is_shooting": is_shooting}
		PACKET_TYPE.PLAYER_POSITION:
			if data.size() < 14:
				push_error("Invalid PLAYER_POSITION packet size: " + str(data.size()))
				return {}
			var id: int = data.decode_u8(1)
			var position: Vector3 = Vector3(
				data.decode_float(2),
				data.decode_float(6),
				data.decode_float(10)
			)
			result = {"id": id, "position": position}
		PACKET_TYPE.PLAYER_ROTATION_Y:
			if data.size() < 6:
				push_error("Invalid PLAYER_ROTATION_Y packet size: " + str(data.size()))
				return {}
			var id: int = data.decode_u8(1)
			var rotation_y: float = data.decode_float(2)
			result = {"id": id, "rotation_y": rotation_y}
		PACKET_TYPE.CA_ROTATION_X:
			if data.size() < 6:
				push_error("Invalid CA_ROTATION_X packet size: " + str(data.size()))
				return {}
			var id: int = data.decode_u8(1)
			var ca_rotation_x: float = data.decode_float(2)
			result = {"id": id, "ca_rotation_x": ca_rotation_x}
		_:
			push_error("Unknown packet type: " + str(packet_type))
			return {}
	
	return result

## Encodes and sends a packet
static func send(target_peer: ENetPacketPeer, transfer_mode: int, type: PACKET_TYPE, data: Dictionary) -> void:
	var encoded: PackedByteArray = encode(type, data)
	if not encoded.is_empty():
		target_peer.send(0, encoded, transfer_mode)

## Encodes and broadcasts a packet to all clients
static func broadcast(connection: ENetConnection, transfer_mode: int, type: PACKET_TYPE, data: Dictionary) -> void:
	var encoded: PackedByteArray = encode(type, data)
	if not encoded.is_empty():
		connection.broadcast(0, encoded, transfer_mode)
