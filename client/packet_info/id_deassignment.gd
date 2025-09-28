class_name IDDeassignment extends Packet

var id: int

static func create(peer_id: int) -> IDDeassignment:
	var info: IDDeassignment = IDDeassignment.new()
	info.packet_type = PACKET_TYPE.ID_DEASSIGNMENT
	info.flag = ENetPacketPeer.FLAG_RELIABLE
	info.id = peer_id
	return info

static func create_from_data(data: PackedByteArray) -> IDDeassignment:
	var info: IDDeassignment = IDDeassignment.new()
	info.decode(data)
	return info

func encode() -> PackedByteArray:
	var data: PackedByteArray = super.encode()
	data.resize(2)
	data.encode_u8(1, id)
	return data

func decode(data: PackedByteArray) -> void:
	super.decode(data)
	id = data.decode_u8(1)
