extends Button

const DEBUG_WORLD_RESOURCE := preload("res://assets/maps/debug_world.tscn")
const CURIOSITY_ISLANDS_RESOURCE := preload("res://assets/maps/curiosity_islands.tscn")

# Just a quick and ugly map change test ;)

func _on_debug_world_pressed() -> void:
	var old_map = get_node("/root/Main").map
	var old_map_camel = get_node("/root/Main").camel_case_map
	var new_map = "debug_world"
	var new_map_camel = get_node("/root/Main").no_snake(new_map)
	var scene = DEBUG_WORLD_RESOURCE.instantiate()

	if old_map != new_map:
		get_node("/root/Main/Maps/").add_child(scene, true)
		get_node("/root/Main").map = new_map
		get_node("/root/Main").camel_case_map = new_map_camel
		get_node("/root/Main/Maps/" + old_map_camel).queue_free()
		
		for p in get_node("/root/Main/Players").get_children():
			print("moving player: " + str(p.name))
			#p.position = get_node("/root/Main/Maps/" + new_map_camel ).spawn_area
			p.position = Vector3(randi_range(0,8), 1, randi_range(0,8))

func _on_curiosity_islands_pressed() -> void:
	var old_map = get_node("/root/Main").map
	var old_map_camel = get_node("/root/Main").camel_case_map
	var new_map = "curiosity_islands"
	var new_map_camel = get_node("/root/Main").no_snake(new_map)
	var scene = CURIOSITY_ISLANDS_RESOURCE.instantiate()

	if old_map != new_map:
		get_node("/root/Main/Maps/").add_child(scene, true)
		get_node("/root/Main").map = new_map
		get_node("/root/Main").camel_case_map = new_map_camel
		get_node("/root/Main/Maps/" + old_map_camel).queue_free()
		
		for p in get_node("/root/Main/Players").get_children():
			print("moving player: " + str(p.name))
			#p.position = get_node("/root/Main/Maps/" + new_map_camel ).spawn_area
			p.position = Vector3(randi_range(700,720), 170, randi_range(0,20))
