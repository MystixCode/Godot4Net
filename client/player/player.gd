extends CharacterBody3D

# TODO
# mouse_motion optimimiere eventuell per precision intervall.
# batch packages. batch should not be bigger than 1200-byte UDP safe limit. better define a much smaller limit  per batch. Creatle multiple batches if neccessary
# threading.
# send tick id from server to client with each packet and other way around.
# discard out of order packets.
# sync playername from server to client

var is_local_player: bool:
	get: return id == Network.id

var id: int
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed: float = 5.0
var mouse_sensitivity: float = 0.0005
var is_moving_left: bool = false
var is_moving_right: bool = false
var is_moving_forward: bool = false
var is_moving_backward: bool = false
var mouse_motion: Vector2
var client_prediction: bool = false
var interpolation: bool = false
var interpolation_speed: float = 10.0
var server_position: Vector3
var is_sprinting: bool = false
var is_jumping: bool = false
var is_shooting: bool = false

func _enter_tree() -> void:
	Network.on_player_position_packet.connect(on_player_position_packet)
	Network.on_player_rotation_y_packet.connect(on_player_rotation_y_packet)
	Network.on_ca_rotation_x_packet.connect(on_ca_rotation_x_packet)

func _exit_tree() -> void:
	Network.on_player_position_packet.disconnect(on_player_position_packet)
	Network.on_player_rotation_y_packet.disconnect(on_player_rotation_y_packet)
	Network.on_ca_rotation_x_packet.disconnect(on_ca_rotation_x_packet)

func _ready() -> void:
	if not is_local_player: return
	Engine.physics_jitter_fix = 0.0
	$CameraArm/Camera3D.current = true

func _physics_process(delta: float) -> void:

	if interpolation:
		# interpolation
		if server_position != position:
			position = position.lerp(server_position, 1.0 - exp(-interpolation_speed * delta))
	
	if not is_local_player: return

	is_jumping=false
	is_shooting=false


	mouse_motion = Input.get_last_mouse_velocity()
	if mouse_motion != Vector2.ZERO:
		var data: Dictionary = {
			"id": id,
			"mouse_motion": mouse_motion
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.MOUSE_MOTION, data)
		mouse_motion = Vector2.ZERO


	if Input.is_action_just_pressed("move_left"):
		is_moving_left=true

		var data: Dictionary = {
			"id": id,
			"is_moving_left": is_moving_left
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_MOVING_LEFT, data)
	if Input.is_action_just_released("move_left"):
		is_moving_left=false

		var data: Dictionary = {
			"id": id,
			"is_moving_left": is_moving_left
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_MOVING_LEFT, data)
		
	if Input.is_action_just_pressed("move_right"):
		is_moving_right=true

		var data: Dictionary = {
			"id": id,
			"is_moving_right": is_moving_right
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_MOVING_RIGHT, data)
		
	if Input.is_action_just_released("move_right"):
		is_moving_right=false

		var data: Dictionary = {
			"id": id,
			"is_moving_right": is_moving_right
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_MOVING_RIGHT, data)
		
	if Input.is_action_just_pressed("move_fw"):
		is_moving_forward=true

		var data: Dictionary = {
			"id": id,
			"is_moving_forward": is_moving_forward
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_MOVING_FORWARD, data)
		
	if Input.is_action_just_released("move_fw"):
		is_moving_forward=false

		var data: Dictionary = {
			"id": id,
			"is_moving_forward": is_moving_forward
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_MOVING_FORWARD, data)

	if Input.is_action_just_pressed("move_bw"):
		is_moving_backward=true

		var data: Dictionary = {
			"id": id,
			"is_moving_backward": is_moving_backward
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_MOVING_BACKWARD, data)
		
	if Input.is_action_just_released("move_bw"):
		is_moving_backward=false

		var data: Dictionary = {
			"id": id,
			"is_moving_backward": is_moving_backward
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_MOVING_BACKWARD, data)

	if Input.is_action_just_pressed("sprint"):
		is_sprinting=true

		var data: Dictionary = {
			"id": id,
			"is_sprinting": is_sprinting
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_SPRINTING, data)

	if Input.is_action_just_released("sprint"):
		is_sprinting=false

		var data: Dictionary = {
			"id": id,
			"is_sprinting": is_sprinting
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_SPRINTING, data)
		
	if Input.is_action_just_pressed("jump"):
		is_jumping=true

		var data: Dictionary = {
			"id": id,
			"is_jumping": is_jumping
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_JUMPING, data)

	if Input.is_action_just_pressed("shoot"):
		is_shooting=true

		var data: Dictionary = {
			"id": id,
			"is_shooting": is_shooting
		}
		MystixPacket.send(Network.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_SHOOTING, data)

	#if client_prediction:
		#handle_gravity(delta)
		#handle_rotation(delta)
		#handle_motion()

func handle_gravity(delta: float) -> void:
	
	# If u fall from map 
	if position.y < -20:
		# $ColorRect.modulate.a = min((-17 - transform.origin.y) / 15, 1)
		# If we're below -40, respawn (teleport to the initial position).
		if position.y < -40:
			# $ColorRect.modulate.a = 0
			print("todo: respawn player")
			#var current_map : String = get_node("/root/Main").camel_case_map
			#position = get_node("/root/Main/Maps/" + current_map).spawn_area

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

func handle_motion() -> void:

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

	var data: Dictionary = {
		"id": id,
		"position": position
	}
	MystixPacket.broadcast(Network.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.PLAYER_POSITION, data)

func handle_rotation(delta: float) -> void:
	if mouse_motion == Vector2.ZERO:
		return

	rotation.y += -mouse_motion.x * mouse_sensitivity * delta
	mouse_motion = Vector2.ZERO

	var data: Dictionary = {
		"id": id,
		"rotation_y": rotation.y
	}
	MystixPacket.broadcast(Network.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.PLAYER_ROTATION_Y, data)

func on_player_position_packet(player_position: Dictionary) -> void:
	if id != player_position.id: return
	if interpolation:
		server_position = player_position.position
	else:
		position = player_position.position

func on_player_rotation_y_packet(player_rotation_y: Dictionary) -> void:
	if id != player_rotation_y.id: return
	rotation.y = player_rotation_y.rotation_y

func on_ca_rotation_x_packet(ca_rotation_x: Dictionary) -> void:
	if id != ca_rotation_x.id: return
	$CameraArm.rotation.x = ca_rotation_x.ca_rotation_x
