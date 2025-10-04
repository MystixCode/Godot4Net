## Class for network packet handling using ENet low-level API.
## All methods are static, no instantiation required.
class_name MystixPacket

## Custom packet types for network communication
enum PACKET_TYPE {
	ID_ASSIGNMENT = 0,      ## Assigns client ID with remote IDs
	ID_DEASSIGNMENT = 1,    ## Deassigns client ID
	IS_MOVING_LEFT = 2,     ## Keyboard movement left (bool)
	IS_MOVING_RIGHT = 3,    ## Keyboard movement right (bool)
	IS_MOVING_FORWARD = 4,  ## Keyboard movement forward (bool)
	IS_MOVING_BACKWARD = 5, ## Keyboard movement backward (bool)
	MOUSE_MOTION = 12,      ## Mouse motion (Vector2)
	IS_SPRINTING = 13,      ## Sprinting state (bool)
	IS_JUMPING = 14,        ## Jumping state (bool)
	IS_SHOOTING = 15,       ## Shooting state (bool)
	PLAYER_POSITION = 16,   ## Player position (Vector3)
	PLAYER_ROTATION_Y = 17, ## Player Y rotation (float)
	CA_ROTATION_X = 18,     ## Camera X rotation (float)
	BULLET_SPAWN = 19,      ## Bullet spawn position (Vector3)
	BULLET_DESPAWN = 20,    ## Bullet despawn by ID
	BULLET_POSITION = 21    ## Bullet position (Vector3)
}

## Encodes an 8-bit unsigned integer into a buffer at the specified offset.
static func _encode_uint8(buffer: PackedByteArray, offset: int, value: int) -> void:
	buffer.encode_u8(offset, value)

## Encodes a float into a buffer at the specified offset.
static func _encode_float(buffer: PackedByteArray, offset: int, value: float) -> void:
	buffer.encode_float(offset, value)

## Encodes a Vector2 into a buffer at the specified offset.
static func _encode_vector2(buffer: PackedByteArray, offset: int, vector: Vector2) -> void:
	_encode_float(buffer, offset, vector.x)
	_encode_float(buffer, offset + 4, vector.y)

## Encodes a Vector3 into a buffer at the specified offset.
static func _encode_vector3(buffer: PackedByteArray, offset: int, vector: Vector3) -> void:
	_encode_float(buffer, offset, vector.x)
	_encode_float(buffer, offset + 4, vector.y)
	_encode_float(buffer, offset + 8, vector.z)

## Decodes an 8-bit unsigned integer from a buffer at the specified offset.
static func _decode_uint8(buffer: PackedByteArray, offset: int) -> int:
	if offset < 0 or offset >= buffer.size():
		push_error("Invalid uint8 decode offset: %d, buffer size: %d" % [offset, buffer.size()])
		return 0
	return buffer.decode_u8(offset)

## Decodes a float from a buffer at the specified offset.
static func _decode_float(buffer: PackedByteArray, offset: int) -> float:
	if offset < 0 or offset > (buffer.size() - 4):
		push_error("Invalid float decode offset: %d, buffer size: %d" % [offset, buffer.size()])
		return 0.0
	return buffer.decode_float(offset)

## Decodes a Vector2 from a buffer at the specified offset.
## Returns the decoded Vector2 or Vector2.ZERO if invalid.
static func _decode_vector2(buffer: PackedByteArray, offset: int) -> Vector2:
	if offset < 0 or offset > (buffer.size() - 8):
		push_error("Invalid Vector2 decode offset: %d, buffer size: %d" % [offset, buffer.size()])
		return Vector2.ZERO
	return Vector2(
		_decode_float(buffer, offset),
		_decode_float(buffer, offset + 4)
	)

## Decodes a Vector3 from a buffer at the specified offset.
## Returns the decoded Vector3 or Vector3.ZERO if invalid.
static func _decode_vector3(buffer: PackedByteArray, offset: int) -> Vector3:
	if offset < 0 or offset > (buffer.size() - 12):
		push_error("Invalid Vector3 decode offset: %d, buffer size: %d" % [offset, buffer.size()])
		return Vector3.ZERO
	return Vector3(
		_decode_float(buffer, offset),
		_decode_float(buffer, offset + 4),
		_decode_float(buffer, offset + 8)
	)

## Encodes a packet based on the provided type and data.
## Returns a PackedByteArray or empty if invalid.
static func encode(packet_type: PACKET_TYPE, data: Array) -> PackedByteArray:
	if not packet_type in PACKET_TYPE.values():
		push_error("Invalid packet type: %d" % packet_type)
		return PackedByteArray()

	# Log encoding details
	var packet_name: String = PACKET_TYPE.keys()[PACKET_TYPE.values().find(packet_type)] if packet_type in PACKET_TYPE.values() else "Unknown"
	print("Encoding packet type: %s (%d), data: %s" % [packet_name, packet_type, data])

	var buffer := PackedByteArray()
	buffer.resize(1)
	_encode_uint8(buffer, 0, packet_type)

	match packet_type:
		PACKET_TYPE.ID_ASSIGNMENT:
			# Expect data as [id: int, remote_ids: Array[int]]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_ARRAY:
				push_error("Invalid ID_ASSIGNMENT data: expected [int, Array[int]], got %s" % str(data))
				return PackedByteArray()
			var remote_ids: Array[int] = data[1]
			buffer.resize(2 + remote_ids.size())
			_encode_uint8(buffer, 1, data[0])
			for i in remote_ids.size():
				_encode_uint8(buffer, 2 + i, remote_ids[i])
		PACKET_TYPE.ID_DEASSIGNMENT:
			# Expect data as [id: int]
			if data.size() != 1 or typeof(data[0]) != TYPE_INT:
				push_error("Invalid ID_DEASSIGNMENT data: expected [int], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(2)
			_encode_uint8(buffer, 1, data[0])
		PACKET_TYPE.IS_MOVING_LEFT:
			# Expect data as [id: int, is_moving_left: bool]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_BOOL:
				push_error("Invalid IS_MOVING_LEFT data: expected [int, bool], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(3)
			_encode_uint8(buffer, 1, data[0])
			_encode_uint8(buffer, 2, data[1])
		PACKET_TYPE.IS_MOVING_RIGHT:
			# Expect data as [id: int, is_moving_right: bool]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_BOOL:
				push_error("Invalid IS_MOVING_RIGHT data: expected [int, bool], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(3)
			_encode_uint8(buffer, 1, data[0])
			_encode_uint8(buffer, 2, data[1])
		PACKET_TYPE.IS_MOVING_FORWARD:
			# Expect data as [id: int, is_moving_forward: bool]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_BOOL:
				push_error("Invalid IS_MOVING_FORWARD data: expected [int, bool], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(3)
			_encode_uint8(buffer, 1, data[0])
			_encode_uint8(buffer, 2, data[1])
		PACKET_TYPE.IS_MOVING_BACKWARD:
			# Expect data as [id: int, is_moving_backward: bool]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_BOOL:
				push_error("Invalid IS_MOVING_BACKWARD data: expected [int, bool], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(3)
			_encode_uint8(buffer, 1, data[0])
			_encode_uint8(buffer, 2, data[1])
		PACKET_TYPE.MOUSE_MOTION:
			# Expect data as [id: int, mouse_motion: Vector2]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_VECTOR2:
				push_error("Invalid MOUSE_MOTION data: expected [int, Vector2], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(10)
			_encode_uint8(buffer, 1, data[0])
			_encode_vector2(buffer, 2, data[1])
		PACKET_TYPE.IS_SPRINTING:
			# Expect data as [id: int, is_sprinting: bool]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_BOOL:
				push_error("Invalid IS_SPRINTING data: expected [int, bool], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(3)
			_encode_uint8(buffer, 1, data[0])
			_encode_uint8(buffer, 2, data[1])
		PACKET_TYPE.IS_JUMPING:
			# Expect data as [id: int, is_jumping: bool]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_BOOL:
				push_error("Invalid IS_JUMPING data: expected [int, bool], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(3)
			_encode_uint8(buffer, 1, data[0])
			_encode_uint8(buffer, 2, data[1])
		PACKET_TYPE.IS_SHOOTING:
			# Expect data as [id: int, is_shooting: bool]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_BOOL:
				push_error("Invalid IS_SHOOTING data: expected [int, bool], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(3)
			_encode_uint8(buffer, 1, data[0])
			_encode_uint8(buffer, 2, data[1])
		PACKET_TYPE.PLAYER_POSITION:
			# Expect data as [id: int, position: Vector3]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_VECTOR3:
				push_error("Invalid PLAYER_POSITION data: expected [int, Vector3], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(14)
			_encode_uint8(buffer, 1, data[0])
			_encode_vector3(buffer, 2, data[1])
		PACKET_TYPE.PLAYER_ROTATION_Y:
			# Expect data as [id: int, rotation_y: float]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_FLOAT:
				push_error("Invalid PLAYER_ROTATION_Y data: expected [int, float], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(6)
			_encode_uint8(buffer, 1, data[0])
			_encode_float(buffer, 2, data[1])
		PACKET_TYPE.CA_ROTATION_X:
			# Expect data as [id: int, ca_rotation_x: float]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_FLOAT:
				push_error("Invalid CA_ROTATION_X data: expected [int, float], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(6)
			_encode_uint8(buffer, 1, data[0])
			_encode_float(buffer, 2, data[1])
		PACKET_TYPE.BULLET_SPAWN:
			# Expect data as [id: int, position: Vector3]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_VECTOR3:
				push_error("Invalid BULLET_SPAWN data: expected [int, Vector3], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(14)
			_encode_uint8(buffer, 1, data[0])
			_encode_vector3(buffer, 2, data[1])
		PACKET_TYPE.BULLET_DESPAWN:
			# Expect data as [id: int]
			if data.size() != 1 or typeof(data[0]) != TYPE_INT:
				push_error("Invalid BULLET_DESPAWN data: expected [int], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(2)
			_encode_uint8(buffer, 1, data[0])
		PACKET_TYPE.BULLET_POSITION:
			# Expect data as [id: int, position: Vector3]
			if data.size() != 2 or typeof(data[0]) != TYPE_INT or typeof(data[1]) != TYPE_VECTOR3:
				push_error("Invalid BULLET_POSITION data: expected [int, Vector3], got %s" % str(data))
				return PackedByteArray()
			buffer.resize(14)
			_encode_uint8(buffer, 1, data[0])
			_encode_vector3(buffer, 2, data[1])
		_:
			push_error("Unknown packet type: %d" % packet_type)
			return PackedByteArray()

	# Log encoded buffer
	print("Encoded packet size: %d, data: %s" % [buffer.size(), buffer.hex_encode()])
	return buffer

## Decodes a packet from the provided data.
## Returns an Array with decoded data or empty if invalid.
static func decode(data: PackedByteArray) -> Array:
	if data.is_empty():
		push_error("Received empty packet data")
		return []

	if data.size() < 1:
		push_error("Packet too small to contain type: size=%d" % data.size())
		return []

	var packet_type: int = _decode_uint8(data, 0)
	# Log packet details
	var packet_name: String = PACKET_TYPE.keys()[PACKET_TYPE.values().find(packet_type)] if packet_type in PACKET_TYPE.values() else "Unknown"
	print("Decoding packet type: %s (%d), size: %d, data: %s" % [packet_name, packet_type, data.size(), data.hex_encode()])

	var result := []

	match packet_type:
		PACKET_TYPE.ID_ASSIGNMENT:
			if data.size() < 2:
				push_error("Invalid ID_ASSIGNMENT packet size: %d, expected >= 2" % data.size())
				return []
			var id: int = _decode_uint8(data, 1)
			var remote_ids: Array[int] = []
			for i in range(2, data.size()):
				remote_ids.append(_decode_uint8(data, i))
			result = [id, remote_ids]
		PACKET_TYPE.ID_DEASSIGNMENT:
			if data.size() < 2:
				push_error("Invalid ID_DEASSIGNMENT packet size: %d, expected >= 2" % data.size())
				return []
			result = [_decode_uint8(data, 1)]
		PACKET_TYPE.IS_MOVING_LEFT:
			if data.size() < 3:
				push_error("Invalid IS_MOVING_LEFT packet size: %d, expected >= 3" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_uint8(data, 2) == 1
			]
		PACKET_TYPE.IS_MOVING_RIGHT:
			if data.size() < 3:
				push_error("Invalid IS_MOVING_RIGHT packet size: %d, expected >= 3" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_uint8(data, 2) == 1
			]
		PACKET_TYPE.IS_MOVING_FORWARD:
			if data.size() < 3:
				push_error("Invalid IS_MOVING_FORWARD packet size: %d, expected >= 3" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_uint8(data, 2) == 1
			]
		PACKET_TYPE.IS_MOVING_BACKWARD:
			if data.size() < 3:
				push_error("Invalid IS_MOVING_BACKWARD packet size: %d, expected >= 3" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_uint8(data, 2) == 1
			]
		PACKET_TYPE.MOUSE_MOTION:
			if data.size() < 10:
				push_error("Invalid MOUSE_MOTION packet size: %d, expected >= 10" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_vector2(data, 2)
			]
		PACKET_TYPE.IS_SPRINTING:
			if data.size() < 3:
				push_error("Invalid IS_SPRINTING packet size: %d, expected >= 3" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_uint8(data, 2) == 1
			]
		PACKET_TYPE.IS_JUMPING:
			if data.size() < 3:
				push_error("Invalid IS_JUMPING packet size: %d, expected >= 3" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_uint8(data, 2) == 1
			]
		PACKET_TYPE.IS_SHOOTING:
			if data.size() < 3:
				push_error("Invalid IS_SHOOTING packet size: %d, expected >= 3" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_uint8(data, 2) == 1
			]
		PACKET_TYPE.PLAYER_POSITION:
			if data.size() < 14:
				push_error("Invalid PLAYER_POSITION packet size: %d, expected >= 14" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_vector3(data, 2)
			]
		PACKET_TYPE.PLAYER_ROTATION_Y:
			if data.size() < 6:
				push_error("Invalid PLAYER_ROTATION_Y packet size: %d, expected >= 6" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_float(data, 2)
			]
		PACKET_TYPE.CA_ROTATION_X:
			if data.size() < 6:
				push_error("Invalid CA_ROTATION_X packet size: %d, expected >= 6" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_float(data, 2)
			]
		PACKET_TYPE.BULLET_SPAWN:
			if data.size() < 14:
				push_error("Invalid BULLET_SPAWN packet size: %d, expected >= 14" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_vector3(data, 2)
			]
		PACKET_TYPE.BULLET_DESPAWN:
			if data.size() < 2:
				push_error("Invalid BULLET_DESPAWN packet size: %d, expected >= 2" % data.size())
				return []
			result = [_decode_uint8(data, 1)]
		PACKET_TYPE.BULLET_POSITION:
			if data.size() < 14:
				push_error("Invalid BULLET_POSITION packet size: %d, expected >= 14" % data.size())
				return []
			result = [
				_decode_uint8(data, 1),
				_decode_vector3(data, 2)
			]
		_:
			push_error("Unknown packet type: %d" % packet_type)
			return []
	return result

## Sends a packet to a specific peer.
## [param transfer_mode]: [code]ENetPacketPeer.FLAG_RELIABLE[/code], [code]ENetPacketPeer.FLAG_UNSEQUENCED[/code].
static func send(target_peer: ENetPacketPeer, transfer_mode: int, packet_type: PACKET_TYPE, data: Array) -> void:
	var encoded := encode(packet_type, data)
	if not encoded.is_empty():
		target_peer.send(0, encoded, transfer_mode)

## Broadcasts a packet to all clients.
## [param transfer_mode]: [code]ENetPacketPeer.FLAG_RELIABLE[/code], [code]ENetPacketPeer.FLAG_UNSEQUENCED[/code].
static func broadcast(connection: ENetConnection, transfer_mode: int, packet_type: PACKET_TYPE, data: Array) -> void:
	var encoded := encode(packet_type, data)
	if not encoded.is_empty():
		connection.broadcast(0, encoded, transfer_mode)
