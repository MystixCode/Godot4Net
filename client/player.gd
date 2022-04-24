extends CharacterBody3D

var player_id : int
var player_name : String
var player_health : int
var player_mana : int
var player_state : Array

var tickrate
var replication_interval
var fraction
var tick_time

@onready var camera : Camera3D = $CameraArm/Camera3D

func _ready():
#	Engine.physics_ticks_per_second=144
	Engine.physics_jitter_fix = 0.0
	
	player_id = str(name).to_int()
	$Inputs.set_multiplayer_authority(player_id)

	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name): 
		camera.current = true

func _physics_process(_delta):
	tickrate=Engine.physics_ticks_per_second
	#replication_interval = $"MultiplayerSynchronizer".replication_interval
	fraction=Engine.get_physics_interpolation_fraction()
	tick_time = 1/float(tickrate)

	$"DebugUI/VBox/Label1".text = "fps: " + str(Engine.get_frames_per_second())
	$"DebugUI/VBox/Label2".text = "tickrate: " + str(tickrate) + " ticks per second"
	#$"DebugUI/VBox/Label3".text = "replication_interval: " + str(replication_interval)
	$"DebugUI/VBox/Label4".text = "physics_interpolation_fraction: " + str(fraction) 
	$"DebugUI/VBox/Label5".text = "tick_time: " + str(tick_time) + " seconds"
	
	$Inputs.update(player_id)

	#Set player to player_state info from server
	if get_node("/root/Main").global_state["player"].has(name):
		player_state = get_node("/root/Main").global_state["player"][name]
		position = player_state[1]
		rotation.y = player_state[2].x
		$CameraArm.rotation.x = player_state[2].y
