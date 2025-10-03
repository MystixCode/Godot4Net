extends Node

const PLAYER = preload("res://player/player.tscn")

func _ready() -> void:
	Network.on_peer_connected.connect(spawn_player)
	Network.on_peer_disconnected.connect(despawn_player)

func spawn_player(id: int) -> void:
	var player : CharacterBody3D = PLAYER.instantiate()
	player.id = id
	player.name = str(id)
	player.position = Vector3(0,10,0)
	call_deferred("add_child", player)

func despawn_player(id: int) -> void:
	print("Spawner despawn player id: ", id)
	get_node(str(id)).queue_free()
