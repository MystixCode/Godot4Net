extends Node

@onready var b_res := preload("res://bullet/bullet.tscn")

func _enter_tree() -> void:
	Net.on_bullet_spawn_packet.connect(on_bullet_spawn_packet)
	Net.on_bullet_despawn_packet.connect(on_bullet_despawn_packet)

func _exit_tree() -> void:
	Net.on_bullet_spawn_packet.disconnect(on_bullet_spawn_packet)
	Net.on_bullet_despawn_packet.disconnect(on_bullet_despawn_packet)

func on_bullet_spawn_packet(bullet_spawn: Dictionary) -> void:
	var b := b_res.instantiate()
	b.name = str(bullet_spawn.id)
	b.position = bullet_spawn.position
	get_node("/root/Main/BulletSpawner").add_child(b, true)

func on_bullet_despawn_packet(bullet_despawn: Dictionary) -> void:
	get_node("/root/Main/BulletSpawner/"+str(bullet_despawn.id)).queue_free()
