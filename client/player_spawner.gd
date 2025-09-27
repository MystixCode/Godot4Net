extends Node

const LOW_LEVEL_NETWORK_PLAYER = preload("res://player.tscn")

func _ready() -> void:
	Net.handle_local_id_assignment.connect(spawn_player)
	Net.handle_remote_id_assignment.connect(spawn_player)
	Net.handle_remote_id_deassignment.connect(despawn_player)


func spawn_player(id: int) -> void:
	var player : CharacterBody3D = LOW_LEVEL_NETWORK_PLAYER.instantiate()
	player.owner_id = id
	player.name = str(id) # Optional, but it beats the name "@CharacterBody2D@2/3/4..."
	player.position = Vector3(0,0,0)
	call_deferred("add_child", player)

func despawn_player(id: int) -> void:
	print("spawner despawn player id: ", id)
	get_node(str(id)).queue_free()
