class_name KeysMotion extends Packet

var id: int
var keys_motion: Vector2

static func create(_id: int, _keys_motion: Vector2) -> KeysMotion:
	var info: KeysMotion = KeysMotion.new()
	info.packet_type = PACKET_TYPE.KEYS_MOTION
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = _id
	info.keys_motion = _keys_motion
	return info

static func create_from_data(data: PackedByteArray) -> KeysMotion:
	var info: KeysMotion = KeysMotion.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(10)
	data.encode_u8(1, id)
	data.encode_float(2, keys_motion.x)
	data.encode_float(6, keys_motion.y)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	keys_motion = Vector2(data.decode_float(2), data.decode_float(6))
