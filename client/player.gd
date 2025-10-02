extends CharacterBody3D

var is_local_player: bool:
	get: return id == Net.id

var id: int
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed: float = 5.0
var mouse_sensitivity: float = 0.1
var keys_motion: Vector2
var mouse_motion: Vector2
var client_prediction: bool = false
var interpolation: bool = false
var interpolation_speed: float = 10.0
var server_position: Vector3
var is_sprinting: bool = false
var is_jumping: bool = false
var is_shooting: bool = false

func _enter_tree() -> void:
	Net.on_player_position_packet.connect(on_player_position_packet)
	Net.on_player_rotation_y_packet.connect(on_player_rotation_y_packet)
	Net.on_ca_rotation_x_packet.connect(on_ca_rotation_x_packet)

func _exit_tree() -> void:
	Net.on_player_position_packet.disconnect(on_player_position_packet)
	Net.on_player_rotation_y_packet.disconnect(on_player_rotation_y_packet)
	Net.on_ca_rotation_x_packet.disconnect(on_ca_rotation_x_packet)

func _ready() -> void:
	if not is_local_player: return
	Engine.physics_jitter_fix = 0.0
	$CameraArm/Camera3D.current = true
	
func _input(event: InputEvent) -> void:
	if not get_window().has_focus(): return
	if not is_local_player: return

	if event is InputEventMouseMotion:
		mouse_motion += event.relative
		if not mouse_motion == Vector2.ZERO:
			var data: Dictionary = {
				"id": id,
				"mouse_motion": mouse_motion
			}
			MystixPacket.send(Net.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.MOUSE_MOTION, data)
			mouse_motion = Vector2.ZERO

func _physics_process(delta: float) -> void:
	
	if interpolation:
		# interpolation
		if server_position != position:
			position = position.lerp(server_position, 1.0 - exp(-interpolation_speed * delta))
	
	if not is_local_player: return

	is_jumping=false
	is_shooting=false
	# TODO: brainstorming notes

	# what do i need to sync from client to server:
	# ---------------------------------------------
	# keys_motion --> Vector2D
	# mouse_motion --> Vector2D
	# is_jumping --> bool
	# is_sprinting --> bool
	# shoot --> bool
	# zoom --> float

	# what do i need to sync from server to client:
	# ---------------------------------------------
	# playername --> String
	# position --> Vector3
	# rotation --> Vector3
	# ca_rotation.y --> float
	# health = int
	# stamina = int
	# mana = int
	
	# use channel 0 for reliable, 1 for unreliable to prioritize reliable?
	# when having at same tick multiple reliable or unreliable packets, combine them into a big package
	# batch should not be bigger than 1200-byte UDP safe limit
	# So creatle multiple batches if neccessary
	
	# drop unreliable packet if old / out of order
	
	# Handle invalid packages. / improve error handling

	keys_motion = Input.get_vector("move_left", "move_right", "move_fw", "move_bw")
	if keys_motion != Vector2(0.0,0.0):
		var data: Dictionary = {
			"id": id,
			"keys_motion": keys_motion
		}
		MystixPacket.send(Net.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.KEYS_MOTION, data)


	if Input.is_action_just_pressed("sprint"):
		is_sprinting=true

		var data: Dictionary = {
			"id": id,
			"is_sprinting": is_sprinting
		}
		MystixPacket.send(Net.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_SPRINTING, data)

	if Input.is_action_just_released("sprint"):
		is_sprinting=false

		var data: Dictionary = {
			"id": id,
			"is_sprinting": is_sprinting
		}
		MystixPacket.send(Net.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_SPRINTING, data)
		
	if Input.is_action_just_pressed("jump"):
		is_jumping=true

		var data: Dictionary = {
			"id": id,
			"is_jumping": is_jumping
		}
		MystixPacket.send(Net.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_JUMPING, data)

	if Input.is_action_just_pressed("shoot"):
		is_shooting=true

		var data: Dictionary = {
			"id": id,
			"is_shooting": is_shooting
		}
		MystixPacket.send(Net.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.IS_SHOOTING, data)

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

func on_player_position_packet(player_position: Dictionary) -> void:
	if id != player_position.id: return
	#position = lerp(position,player_position.position,0.9)
	if interpolation:
		server_position = player_position.position
	else:
		position = player_position.position

func on_player_rotation_y_packet(player_rotation_y: Dictionary) -> void:
	if id != player_rotation_y.id: return
	
	#print("rotation: ", player_rotation_y.rotation_y)
	rotation.y = player_rotation_y.rotation_y

func on_ca_rotation_x_packet(ca_rotation_x: Dictionary) -> void:
	if id != ca_rotation_x.id: return
	
	#print("rotation: ", player_rotation_y.rotation_y)
	$CameraArm.rotation.x = ca_rotation_x.ca_rotation_x
