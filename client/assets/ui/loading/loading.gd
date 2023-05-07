extends Control


var path: String
var is_loading: bool

@export var tips: Array = [
	"Press shift to sprint",
	"Scroll your mousewheel to zoom",
	"Press spacebar to jump",
	"Add more tips to the tips array in loading.gd"]

func _process(_delta):
	if is_loading:
		var progress: Array = []
		var status = ResourceLoader.load_threaded_get_status(path, progress)
		if status == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
		
			#this should work in godot 4.1
#			get_node("ProgressBar").value = progress[0] * 100

			#temporary workaround until fixed
			get_node("ProgressBar").value += 1
			
			print("progress: " + str(progress[0] * 100))
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


func load_map(res_path: String):
	path = res_path
	show()
	if tips != null and !tips.is_empty():
		$Control/VBoxContainer2/tip.text = tips[randi() % tips.size()]
		
	var level_name_parts: Array = path.split("/")
	var level_name_without_extension = level_name_parts[-1].split(".")[0]
	$Control/VBoxContainer/map_name.text = level_name_without_extension
	
	if ResourceLoader.has_cached(path):
		ResourceLoader.load_threaded_get(path)
	else:
		#load map
		ResourceLoader.load_threaded_request(path, "", false)
		is_loading = true
