extends CharacterBody3D

var player_id : int
var player_name : String
var player_health : int
var player_mana : int
var player_state : Array

@onready var camera : Camera3D = $CameraArm/Camera3D

# Player synchronized input.
@onready var input : MultiplayerSynchronizer = $InputSynchronizer

func _ready():
#	Engine.physics_ticks_per_second=144
	Engine.physics_jitter_fix = 0.0
	
	player_id = str(name).to_int()
	input.set_multiplayer_authority(player_id)

	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name): 
		camera.current = true

func _physics_process(_delta):
	
	# if category player doesnt exist in global_state add it
	if !get_node("/root/Main").global_state.has("player"):
		get_node("/root/Main").global_state["player"] = {}

	# add global player_state into vars
	if get_node("/root/Main").global_state["player"].has(name):
		player_state = get_node("/root/Main").global_state["player"][name]
		position = player_state[1]
		rotation.y = player_state[2].x
		$CameraArm.rotation.x = player_state[2].y
