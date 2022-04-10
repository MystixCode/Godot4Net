extends MultiplayerSpawner

func _spawn_custom(data : Variant):
	#if data.size() != 2 or typeof(data[0]) != TYPE_VECTOR3 or typeof(data[1]) != TYPE_INT:
#		return null
	var bullet := preload("res://bullet.tscn").instantiate()
	bullet.position = data["synced_position"]
	#print(data["synced_position"])
	bullet.from_player = data["name"]
	return bullet

#	bullet.position = data[0]
#   bullet.from_player = data[1]
