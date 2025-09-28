extends CharacterBody3D

var is_authority: bool:
	get: return owner_id == Net.id

var owner_id: int
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

var keys_motion: Vector2
var mouse_motion: Vector2

func _enter_tree() -> void:
	Net.on_player_position_packet.connect(on_player_position_packet)
	Net.on_player_rotation_packet.connect(on_player_rotation_packet)


func _exit_tree() -> void:
	Net.on_player_position_packet.disconnect(on_player_position_packet)
	Net.on_player_rotation_packet.disconnect(on_player_rotation_packet)

func _ready() -> void:
	if !is_authority: return

	$Camera3D.current = true

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and get_viewport().get_window().has_focus():
		mouse_motion += event.relative
		
		if mouse_motion != Vector2(0.0,0.0):
			#KeysMotion.create(owner_id, keys_motion).send(Net.server_peer)
			
			var data: Dictionary = {
				"id": owner_id,
				"mouse_motion": mouse_motion
			}
			MystixPacket.send(Net.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.MOUSE_MOTION, data)
			mouse_motion = Vector2.ZERO

func _physics_process(_delta: float) -> void:
	if !is_authority: return
	
	# TODO: brainstorming notes

	# what do i need to sync from client to server:
	# ---------------------------------------------
	# keys_motion --> Vector2D
	# mouse_motion --> Vector2D
	# is_jumping --> bool
	# is_sprinting --> bool
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
	
	# add if client_prediction:
	# 	and do some physics like on server

	keys_motion = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if keys_motion != Vector2(0.0,0.0):
		#KeysMotion.create(owner_id, keys_motion).send(Net.server_peer)
		
		var data: Dictionary = {
			"id": owner_id,
			"keys_motion": keys_motion
		}
		MystixPacket.send(Net.server_peer, ENetPacketPeer.FLAG_UNSEQUENCED, MystixPacket.PACKET_TYPE.KEYS_MOTION, data)


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

func on_player_position_packet(player_position: Dictionary) -> void:
	if owner_id != player_position.id: return
	position = player_position.position

func on_player_rotation_packet(player_rotation: Dictionary) -> void:
	if owner_id != player_rotation.id: return
	
	# TODO
	print("rotation: ", player_rotation.rotation)
	rotation = player_rotation.rotation
