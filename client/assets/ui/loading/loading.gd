extends Control


var path: String
var is_loading: bool

func _process(delta):
	if is_loading:
		var progress: Array = []
		var status = ResourceLoader.load_threaded_get_status(path, progress)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			get_node("ProgressBar").value = progress[0] *100
			print("status: " + str(progress[0] *100))
			print("this should work in godot 4.1: https://github.com/godotengine/godot/pull/75644")
		elif status == ResourceLoader.THREAD_LOAD_LOADED:
			set_process(false)
			get_node("ProgressBar").value = 100
			print("loading 100%")
			change_map(ResourceLoader.load_threaded_get(path))


func change_map(resource: PackedScene):
	for item in get_node("/root/main/maps").get_children():
		item.queue_free()
	var current_node = resource.instantiate()
	get_node("/root/main/maps").add_child(current_node)
	queue_free()


func load_map(path: String):
	self.path = path
	show()
	if ResourceLoader.has_cached(path):
		ResourceLoader.load_threaded_get(path)
	else:
		#load map
		ResourceLoader.load_threaded_request(path, "", false)
		is_loading = true
