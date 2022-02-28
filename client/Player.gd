extends CharacterBody3D

var mouseSensitivity : float = 2
@onready var camera := $CameraArm/Camera3D

var synced_position : Vector3
var synced_rotation_y : float
var synced_camera_arm_rotation_x : float
var synced_player_name : String
var synced_health := 100
var synced_mana := 100

var tickrate
var replication_interval
var fraction
var tick_time

func _ready():
#	Engine.physics_ticks_per_second=144 #player rotation fails with 144
	Engine.physics_jitter_fix = 0.0
	
	#Set InputSynchronizer authority to this player so that it can sync to, besides that, authoritative server
	$Inputs.set_multiplayer_authority(str(name).to_int())

	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name): 
		camera.current = true

func _physics_process(delta):
	tickrate=Engine.physics_ticks_per_second
	replication_interval = $"MultiplayerSynchronizer".replication_interval
	fraction=Engine.get_physics_interpolation_fraction()
	tick_time = 1/float(tickrate)

	$"DebugUI/VBox/Label1".text = "fps: " + str(Engine.get_frames_per_second())
	$"DebugUI/VBox/Label2".text = "tickrate: " + str(tickrate) + " ticks per second"
	$"DebugUI/VBox/Label3".text = "replication_interval: " + str(replication_interval)
	$"DebugUI/VBox/Label4".text = "physics_interpolation_fraction: " + str(fraction) 
	$"DebugUI/VBox/Label5".text = "tick_time: " + str(tick_time) + " seconds"
	
	$Inputs.update()
	
	var rot : Vector3 = Vector3($"Inputs".mouse_motion.y, $"Inputs".mouse_motion.x, 0) * mouseSensitivity * delta
	$"Inputs".mouse_motion = Vector2()

	if synced_position:
		position=synced_position
	if synced_rotation_y:
		rotation.y=synced_rotation_y
	if synced_camera_arm_rotation_x:
		$CameraArm.rotation.x = synced_camera_arm_rotation_x

