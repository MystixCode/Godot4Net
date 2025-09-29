extends Node

const PLAYER = preload("res://player.tscn")

func _ready() -> void:
	Net.handle_local_id_assignment.connect(spawn_player)
	Net.handle_remote_id_assignment.connect(spawn_player)
	Net.handle_remote_id_deassignment.connect(despawn_player)
	Net.on_disconnected_from_server.connect(despawn_all_player)

func spawn_player(id: int) -> void:
	var player : CharacterBody3D = PLAYER.instantiate()
	player.id = id
	player.name = str(id) # Optional"
	player.position = Vector3(0,10,0)
	call_deferred("add_child", player)

func despawn_player(id: int) -> void:
	print("Spawner despawn player id: ", id)
	get_node(str(id)).queue_free()

func despawn_all_player() -> void:
	print("Spawner despawn all player")
	if get_child_count() > 0:
		for player: CharacterBody3D in get_children():
			player.queue_free()
