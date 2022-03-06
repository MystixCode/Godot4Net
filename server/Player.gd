extends CharacterBody3D

var speed := 5.0
var jump_force := 4.5
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity : float = 2
@onready var camera := $CameraArm/Camera3D

var synced_position : Vector3
var synced_rotation_y : float
var synced_camera_arm_rotation_x : float
var synced_player_name : String
var synced_health := 100
var synced_mana := 100

func _ready():
	$Inputs.set_multiplayer_authority(str(name).to_int())

	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name):
		camera.current = true

func _physics_process(delta):
	synced_position = position
	synced_rotation_y = rotation.y

	var rot : Vector3 = Vector3($"Inputs".mouse_motion.y, $"Inputs".mouse_motion.x, 0) * mouse_sensitivity * delta
	$"Inputs".mouse_motion = Vector2()
	
	$CameraArm.rotation.x-= rot.x
	synced_camera_arm_rotation_x = $CameraArm.rotation.x
#	$CameraArm.rotation.x = clamp(rotation.x, -90.0, 30.0) #TODO: limit camera rotation up/down, new Vector3.limit_lengthfunction ?
	rotation.y -= rot.y
	
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

#	#Handle Jump.
	if $Inputs.jump == true and is_on_floor():
		velocity.y = jump_force
		synced_mana-=10

	#Handle Shoot
	if $Inputs.shoot == true:
		get_node("../../Bullets").spawn([$"Position3D".global_transform.origin, str(name).to_int()])

	var direction := (transform.basis * Vector3($Inputs.motion.y, 0, $Inputs.motion.x)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()

func damage(dmg : int):
	synced_health -= dmg
	print(str(name) + " Health: " + str(synced_health))
