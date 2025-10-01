extends CharacterBody3D

var id: int
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed: float = 5.0
var mouse_sensitivity : float = 0.1
var keys_motion : Vector2
var mouse_motion : Vector2
var movement_speed: float = 5.0
var sprint_speed: float = 10.0
var is_sprinting: bool = false
var is_jumping: bool = false
var is_shooting: bool = false
var health : int = 200
var mana : int = 200
var stamina : int = 200
var jump_force: int = 6

@onready var camera_arm: SpringArm3D =  $CameraArm

func _enter_tree() -> void:
	Net.on_keys_motion_packet.connect(on_keys_motion_packet)
	Net.on_mouse_motion_packet.connect(on_mouse_motion_packet)
	Net.on_is_sprinting_packet.connect(on_is_sprinting_packet)
	Net.on_is_jumping_packet.connect(on_is_jumping_packet)
	Net.on_is_shooting_packet.connect(on_is_shooting_packet)

func _exit_tree() -> void:
	Net.on_keys_motion_packet.disconnect(on_keys_motion_packet)
	Net.on_mouse_motion_packet.disconnect(on_mouse_motion_packet)
	Net.on_is_sprinting_packet.disconnect(on_is_sprinting_packet)
	Net.on_is_jumping_packet.disconnect(on_is_jumping_packet)
	Net.on_is_shooting_packet.disconnect(on_is_shooting_packet)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_sprint()
	handle_jump()
	handle_shoot()
	handle_rotation(delta)
	handle_motion()
	is_jumping = false
	is_shooting = false

func handle_gravity(delta: float) -> void:
	
	# If u fall from map 
	if position.y < -20:
#		$ColorRect.modulate.a = min((-17 - transform.origin.y) / 15, 1)
		# If we're below -40, respawn (teleport to the initial position).
		if position.y < -40:
#			$ColorRect.modulate.a = 0
			print("todo: respawn player")
			#var current_map : String = get_node("/root/Main").camel_case_map
			#position = get_node("/root/Main/Maps/" + current_map).spawn_area

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

func handle_sprint() -> void:
	if is_sprinting and is_on_floor() and keys_motion != Vector2(0,0):
		if stamina >= 1:
			speed = sprint_speed
			stamina-=1
		else:
			speed = movement_speed
	else:
		speed = movement_speed

func handle_jump() -> void:
	if is_jumping and is_on_floor():
		velocity.y = jump_force
		print("jumping")

func handle_shoot() -> void:
	if is_shooting:
		if mana >= 10:
			get_node("/root/Main/BulletSpawner").spawn(id)
			mana-=10
			

func handle_motion() -> void:
	var direction := (transform.basis * Vector3(keys_motion.x, 0, keys_motion.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()
	keys_motion = Vector2()

	#PlayerPosition.create(owner_id, position).broadcast(Net.connection)
	
	var data: Dictionary = {
		"id": id,
		"position": position
	}
	MystixPacket.broadcast(Net.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.PLAYER_POSITION, data)

func handle_rotation(delta: float) -> void:
	if mouse_motion == Vector2.ZERO:
		return


	var rot : Vector3 = Vector3(mouse_motion.y, 0, mouse_motion.x) * mouse_sensitivity * delta
	rotation.y -= rot.z
	$CameraArm.rotation.x = clamp($CameraArm.rotation.x - rot.x, deg_to_rad(-70.0), deg_to_rad(30.0))

	# reset mouse motion
	mouse_motion = Vector2.ZERO
	
	var data: Dictionary = {
		"id": id,
		"rotation_y": rotation.y
	}
	MystixPacket.broadcast(Net.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.PLAYER_ROTATION_Y, data)

	data = {
		"id": id,
		"ca_rotation_x": $CameraArm.rotation.x
	}
	MystixPacket.broadcast(Net.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.CA_ROTATION_X, data)

func on_keys_motion_packet(peer_id: int, _keys_motion: Dictionary) -> void:
	if id != peer_id: return

	#print("keys_motion: ", _keys_motion.keys_motion)
	keys_motion = _keys_motion.keys_motion

func on_mouse_motion_packet(peer_id: int, _mouse_motion: Dictionary) -> void:
	if id != peer_id: return

	#print("mouse_motion: ", _mouse_motion.mouse_motion)
	mouse_motion = _mouse_motion.mouse_motion

func on_is_sprinting_packet(peer_id: int, _is_sprinting: Dictionary) -> void:
	if id != peer_id: return

	#print("is_sprinting: ", _is_sprinting.is_sprinting)
	is_sprinting = _is_sprinting.is_sprinting

func on_is_jumping_packet(peer_id: int, _is_jumping: Dictionary) -> void:
	if id != peer_id: return

	#print("is_sprinting: ", _is_sprinting.is_sprinting)
	is_jumping = _is_jumping.is_jumping

func on_is_shooting_packet(peer_id: int, _is_shooting: Dictionary) -> void:
	if id != peer_id: return

	#print("is_sprinting: ", _is_sprinting.is_sprinting)
	is_shooting = _is_shooting.is_shooting
