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

var position_timer := 0.0
@export var position_interval := 0.005

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
	handle_motion(delta)
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

func handle_motion(delta: float) -> void:
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

	position_timer += delta
	if position != old_position and position_timer >= position_interval:
		var data: Array = [ id, position]
		MystixPacket.broadcast(Network.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.PLAYER_POSITION, data)
		position_timer = 0.0

func handle_rotation(delta: float) -> void:
	if mouse_motion == Vector2.ZERO:
		return

	var rot : Vector3 = Vector3(mouse_motion.y, 0, mouse_motion.x) * mouse_sensitivity * delta
	rotation.y -= rot.z
	$CameraArm.rotation.x = clamp($CameraArm.rotation.x - rot.x, deg_to_rad(-70.0), deg_to_rad(50.0))
	mouse_motion = Vector2.ZERO

	var data: Array = [ id, rotation.y ]
	MystixPacket.broadcast(Network.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.PLAYER_ROTATION_Y, data)

	data = [ id, $CameraArm.rotation.x ]
	MystixPacket.broadcast(Network.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.CA_ROTATION_X, data)

func on_is_moving_left_packet(data: Array) -> void:
	if id != data[0]: return
	is_moving_left = data[1]

func on_is_moving_right_packet(_is_moving_right: Array) -> void:
	if id != _is_moving_right[0]: return
	is_moving_right = _is_moving_right[1]

func on_is_moving_forward_packet( _is_moving_forward: Array) -> void:
	if id != _is_moving_forward[0]: return
	is_moving_forward = _is_moving_forward[1]

func on_is_moving_backward_packet(_is_moving_backward: Array) -> void:
	if id != _is_moving_backward[0]: return
	is_moving_backward = _is_moving_backward[1]

func on_mouse_motion_packet(_mouse_motion: Array) -> void:
	if id != _mouse_motion[0]: return
	mouse_motion = _mouse_motion[1]

func on_is_sprinting_packet(_is_sprinting: Array) -> void:
	if id != _is_sprinting[0]: return
	is_sprinting = _is_sprinting[1]

func on_is_jumping_packet(_is_jumping: Array) -> void:
	if id != _is_jumping[0]: return
	is_jumping = _is_jumping[1]

func on_is_shooting_packet(_is_shooting: Array) -> void:
	if id != _is_shooting[0]: return
	is_shooting = _is_shooting[1]
