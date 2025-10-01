extends Area3D


var from_player : int

func _enter_tree() -> void:
	Net.on_bullet_position_packet.connect(on_bullet_position_packet)

func _exit_tree() -> void:
	Net.on_bullet_position_packet.disconnect(on_bullet_position_packet)

func _ready() -> void:
	print("hello world from: " + str(name))
#	$AudioStreamPlayer3d.play()

func on_bullet_position_packet(bullet_position: Dictionary) -> void:
	get_node("/root/Main/BulletSpawner/"+str(bullet_position.id)).position = bullet_position.position
