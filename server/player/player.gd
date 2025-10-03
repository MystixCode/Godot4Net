extends CharacterBody3D

var id: int
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed: float = 5.0
var mouse_sensitivity : float = 0.0005
var is_moving_left: bool = false
var is_moving_right: bool = false
var is_moving_forward: bool = false
var is_moving_backward: bool = false
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
var old_position: Vector3

@onready var camera_arm: SpringArm3D =  $CameraArm

func _enter_tree() -> void:
	Network.on_is_moving_left_packet.connect(on_is_moving_left_packet)
	Network.on_is_moving_right_packet.connect(on_is_moving_right_packet)
	Network.on_is_moving_forward_packet.connect(on_is_moving_forward_packet)
	Network.on_is_moving_backward_packet.connect(on_is_moving_backward_packet)
	Network.on_mouse_motion_packet.connect(on_mouse_motion_packet)
	Network.on_is_sprinting_packet.connect(on_is_sprinting_packet)
	Network.on_is_jumping_packet.connect(on_is_jumping_packet)
	Network.on_is_shooting_packet.connect(on_is_shooting_packet)

func _exit_tree() -> void:
	Network.on_is_moving_left_packet.disconnect(on_is_moving_left_packet)
	Network.on_is_moving_right_packet.disconnect(on_is_moving_right_packet)
	Network.on_is_moving_forward_packet.disconnect(on_is_moving_forward_packet)
	Network.on_is_moving_backward_packet.disconnect(on_is_moving_backward_packet)
	Network.on_mouse_motion_packet.disconnect(on_mouse_motion_packet)
	Network.on_is_sprinting_packet.disconnect(on_is_sprinting_packet)
	Network.on_is_jumping_packet.disconnect(on_is_jumping_packet)
	Network.on_is_shooting_packet.disconnect(on_is_shooting_packet)

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
	if is_sprinting and is_on_floor() and (is_moving_left or is_moving_right or is_moving_forward or is_moving_backward):
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

func handle_shoot() -> void:
	if is_shooting:
		if mana >= 10:
			get_node("/root/Main/BulletSpawner").spawn(id)
			mana-=10

func handle_motion() -> void:
	old_position = position
	
	var input_direction := Vector2()
	if is_moving_right:
		input_direction.x += 1
	if is_moving_left:
		input_direction.x -= 1
	if is_moving_forward:
		input_direction.y -= 1  # Forward is negative Z in 3D
	if is_moving_backward:
		input_direction.y += 1  # Backward is positive Z in 3D

	# Transform the input direction into 3D space and normalize
	var direction := (transform.basis * Vector3(input_direction.x, 0, input_direction.y)).normalized()

	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()

	if position != old_position:
		var data: Dictionary = {
			"id": id,
			"position": position
		}
		MystixPacket.broadcast(Network.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.PLAYER_POSITION, data)

func handle_rotation(delta: float) -> void:
	if mouse_motion == Vector2.ZERO:
		return

	var rot : Vector3 = Vector3(mouse_motion.y, 0, mouse_motion.x) * mouse_sensitivity * delta
	rotation.y -= rot.z
	$CameraArm.rotation.x = clamp($CameraArm.rotation.x - rot.x, deg_to_rad(-70.0), deg_to_rad(50.0))
	mouse_motion = Vector2.ZERO

	var data: Dictionary = {
		"id": id,
		"rotation_y": rotation.y
	}
	MystixPacket.broadcast(Network.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.PLAYER_ROTATION_Y, data)

	data = {
		"id": id,
		"ca_rotation_x": $CameraArm.rotation.x
	}
	MystixPacket.broadcast(Network.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.CA_ROTATION_X, data)

func on_is_moving_left_packet(peer_id: int, _is_moving_left: Dictionary) -> void:
	if id != peer_id: return
	is_moving_left = _is_moving_left.is_moving_left

func on_is_moving_right_packet(peer_id: int, _is_moving_right: Dictionary) -> void:
	if id != peer_id: return
	is_moving_right = _is_moving_right.is_moving_right

func on_is_moving_forward_packet(peer_id: int, _is_moving_forward: Dictionary) -> void:
	if id != peer_id: return
	is_moving_forward = _is_moving_forward.is_moving_forward

func on_is_moving_backward_packet(peer_id: int, _is_moving_backward: Dictionary) -> void:
	if id != peer_id: return
	is_moving_backward = _is_moving_backward.is_moving_backward

func on_mouse_motion_packet(peer_id: int, _mouse_motion: Dictionary) -> void:
	if id != peer_id: return
	mouse_motion = _mouse_motion.mouse_motion

func on_is_sprinting_packet(peer_id: int, _is_sprinting: Dictionary) -> void:
	if id != peer_id: return
	is_sprinting = _is_sprinting.is_sprinting

func on_is_jumping_packet(peer_id: int, _is_jumping: Dictionary) -> void:
	if id != peer_id: return
	is_jumping = _is_jumping.is_jumping

func on_is_shooting_packet(peer_id: int, _is_shooting: Dictionary) -> void:
	if id != peer_id: return
	is_shooting = _is_shooting.is_shooting
