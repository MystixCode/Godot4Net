extends CharacterBody3D

var player_id : int
var player_name : String
var player_health : int = 200
var player_mana : int = 200
var player_state : Array

var speed := 5.0
var jump_force := 4.5
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity : float = 2

@onready var camera : Camera3D = $CameraArm/Camera3D

func _ready():
#	Engine.physics_ticks_per_second=144
	Engine.physics_jitter_fix = 0.0
	
	player_id = str(name).to_int()
	$Inputs.set_multiplayer_authority(player_id)

	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name):
		camera.current = true

func _physics_process(delta):

	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if $Inputs.input_state.has(name):
		var mouse_motion = $Inputs.input_state[name][1]
		var rot : Vector3 = Vector3(mouse_motion.y, 0, mouse_motion.x) * mouse_sensitivity * delta
		mouse_motion = Vector2()

		#Handle Rotation
		$CameraArm.rotation.x -= rot.x
#		$CameraArm.rotation.x = clamp(rotation.x, -90.0, 30.0) #TODO: limit camera rotation up/down, new Vector3.limit_lengthfunction ?
		rotation.y -= rot.z

		#Handle Jump.
		var jump = $Inputs.input_state[name][2]
		if jump == true and is_on_floor():
			velocity.y = jump_force
			player_mana-=10
			print(str(name) + " mana: " + str(player_mana))

	#Handle Shoot
#	if $Inputs.shoot == true:
#		var bullet_data: Dictionary = {
#			"synced_position": $"Position3D".global_transform.origin,
#			"name": str(name).to_int()
#		}
#		get_node("../../Bullets").spawn(bullet_data)

		var motion = $Inputs.input_state[name][0]

		var direction := (transform.basis * Vector3(motion.y, 0, motion.x)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

		move_and_slide()

		#Add player_state to global_state after physic calculations
		player_state = [player_name, position, Vector2(rotation.y, $CameraArm.rotation.x), player_health, player_mana]
		get_node("/root/Main").global_state[name] = player_state

func damage(_dmg : int):
	print("dmg")
#	synced_health -= dmg
#	print(str(name) + " Health: " + str(synced_health))
