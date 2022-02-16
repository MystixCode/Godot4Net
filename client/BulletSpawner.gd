extends MultiplayerSpawner

func _spawn_custom(data : Array):
	#if data.size() != 2 or typeof(data[0]) != TYPE_VECTOR3 or typeof(data[1]) != TYPE_INT:
#		return null
	var bullet := preload("res://bullet.tscn").instantiate()
	bullet.position = data[0]
	bullet.from_player = data[1]
	return bullet
