class_name PlayerPosition extends PacketInfo

var id: int
var position: Vector3

static func create(_id: int, _position: Vector3) -> PlayerPosition:
	var info: PlayerPosition = PlayerPosition.new()
	info.packet_type = PACKET_TYPE.PLAYER_POSITION
	info.flag = ENetPacketPeer.FLAG_UNSEQUENCED
	info.id = _id
	info.position = _position
	return info


static func create_from_data(data: PackedByteArray) -> PlayerPosition:
	var info: PlayerPosition = PlayerPosition.new()
	info.decode(data)
	return info


func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(14)
	data.encode_u8(1, id)
	data.encode_float(2, position.x)
	data.encode_float(6, position.y)
	data.encode_float(10, position.z)
	return data


func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
	position = Vector3(data.decode_float(2), data.decode_float(6), data.decode_float(10))
