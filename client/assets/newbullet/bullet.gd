extends Area3D

var from_player : int
var bullet_state : Array

func _ready():
	$AudioStreamPlayer3d.play()
func _physics_process(_delta):
	# if category bullet doesnt exist in global_state add it
	if !get_node("/root/Main").global_state.has("bullet"):
		get_node("/root/Main").global_state["bullet"] = {}

	# add global bullet_state into vars
	if get_node("/root/Main").global_state["bullet"].has(name):
		bullet_state = get_node("/root/Main").global_state["bullet"][name]
		position = bullet_state[1]
