extends CharacterBody3D

var speed: float = 5.0

var id: int
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity : float = 0.1
var keys_motion : Vector2
var mouse_motion : Vector2

func _enter_tree() -> void:
	Net.on_keys_motion_packet.connect(on_keys_motion_packet)
	Net.on_mouse_motion_packet.connect(on_mouse_motion_packet)

func _exit_tree() -> void:
	Net.on_keys_motion_packet.disconnect(on_keys_motion_packet)
	Net.on_mouse_motion_packet.disconnect(on_mouse_motion_packet)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
	handle_rotation(delta)
	handle_motion()

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

	rotation.y += -mouse_motion.x * mouse_sensitivity * delta
	mouse_motion = Vector2.ZERO
	
	#print("rotation: ", rotation)
	var data: Dictionary = {
		"id": id,
		"rotation_y": rotation.y
	}
	MystixPacket.broadcast(Net.connection, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.PLAYER_ROTATION_Y, data)

func on_keys_motion_packet(peer_id: int, _keys_motion: Dictionary) -> void:
	if id != peer_id: return

	#print("keys_motion: ", _keys_motion.keys_motion)
	keys_motion = _keys_motion.keys_motion

func on_mouse_motion_packet(peer_id: int, _mouse_motion: Dictionary) -> void:
	if id != peer_id: return

	#print("mouse_motion: ", _mouse_motion.mouse_motion)
	mouse_motion = _mouse_motion.mouse_motion
