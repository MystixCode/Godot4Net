extends Node

const PLAYER = preload("res://player.tscn")

func _ready() -> void:
	Net.on_peer_connected.connect(spawn_player)
	Net.on_peer_disconnected.connect(despawn_player)

func spawn_player(id: int) -> void:
	var player : CharacterBody3D = PLAYER.instantiate()
	player.owner_id = id
	player.name = str(id) # Optional, but it beats the name "@CharacterBody2D@2/3/4..."
	player.position = Vector3(0,10,0)
	call_deferred("add_child", player)

func despawn_player(id: int) -> void:
	print("Spawner despawn player id: ", id)
	get_node(str(id)).queue_free()
