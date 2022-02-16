extends CharacterBody3D
#Questions
#Should i interpolate physics or the visual representation like the smooth addon?
#Are there any godot client prediction examples or just do the same physics as on server and sync?
#How to optimize?
#Is there a way to access the current state?
#How would i optimize to sync only if value changed or is that already in this new sync code?

var clientPrediction := false
var clientInterpolation := false
var speed := 5.0
var jump_force := 4.5
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
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
	
	var rot : Vector3 = Vector3($"Inputs".mouseDelta.y, $"Inputs".mouseDelta.x, 0) * mouseSensitivity * delta
	$"Inputs".mouseDelta = Vector2()

	clientInterpolation=$"../../UI/VBox/Interpolation".button_pressed
	if clientInterpolation == true:
		if synced_position:
			var diff1 = synced_position - position
			position = position + (diff1 * fraction) 
#			position.x=lerp(position.x, synced_position.x, fraction)
#			position.y=lerp(position.y, synced_position.y, fraction)
#			position.z=lerp(position.z, synced_position.z, fraction)
		if synced_rotation_y:
			#TODO
#			rotation.y=rotation.slerp(Vector3(rotation.x,synced_rotation_y,rotation.z), fraction).y
#			var diff2 = synced_rotation_y - rotation.y
#			rotation.y=rotation.y + (diff2 * fraction)
			rotation.y=synced_rotation_y
#			rotation.y=lerp(rotation.y, synced_rotation_y, fraction)
		if synced_camera_arm_rotation_x:
			#TODO
			$CameraArm.rotation.x = synced_camera_arm_rotation_x
	else:
		if synced_position:
			position=synced_position
		if synced_rotation_y:
			rotation.y=synced_rotation_y
		if synced_camera_arm_rotation_x:
			$CameraArm.rotation.x = synced_camera_arm_rotation_x

	clientPrediction=$"../../UI/VBox/Prediction".button_pressed
	if clientPrediction == true:
		# Add the gravity.
		if not is_on_floor():
			motion_velocity.y -= gravity * delta

		# Handle Jump.
		if $Inputs.jump == true and is_on_floor():
			motion_velocity.y = jump_force
			synced_mana-=10

		#Rotation
		rotation.y -= rot.y

		var direction := (transform.basis * Vector3($Inputs.motion.y, 0, $Inputs.motion.x)).normalized()
		if direction:
			motion_velocity.x = direction.x * speed
			motion_velocity.z = direction.z * speed
		else:
			motion_velocity.x = move_toward(motion_velocity.x, 0, speed)
			motion_velocity.z = move_toward(motion_velocity.z, 0, speed)

		move_and_slide()
