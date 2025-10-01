extends Node
var available_bullet_ids: Array = range(5, -1, -1) # 0-255
var bullet_ids: Array[int]

@onready var b_res := preload("res://bullet/bullet.tscn")
	
func spawn(player_id: int) -> void:
	print("todo bullet shoot from and crosshair and sync bullet pos and damage func")
	
	if available_bullet_ids.is_empty():
		push_warning("No available bullet IDs.")
		return
	
	var b := b_res.instantiate()
	
	var bullet_id: int = available_bullet_ids.pop_back()
	b.set_meta("id", bullet_id)
	b.name = str(bullet_id)
	b.position = get_node("/root/Main/PlayerSpawner/" + str(player_id) + "/ShootFrom").global_transform.origin
	b.from_player = player_id
	get_node("/root/Main/BulletSpawner").add_child(b, true)
	bullet_ids.append(bullet_id)
	
	
	var data: Dictionary = {
		"id": bullet_id,
		"position": b.position
		
	}
	MystixPacket.broadcast(Net.connection, ENetPacketPeer.FLAG_RELIABLE, MystixPacket.PACKET_TYPE.BULLET_SPAWN, data)

func despawn(bullet_id: int) -> void:	
	bullet_ids.erase(bullet_id)
	get_node("/root/Main/BulletSpawner/"+str(bullet_id)).queue_free()
	available_bullet_ids.push_back(bullet_id)
	
	var data: Dictionary = {
		"id":bullet_id	
	}
	MystixPacket.broadcast(Net.connection, ENetPacketPeer.FLAG_RELIABLE, MystixPacket.PACKET_TYPE.BULLET_DESPAWN, data)
