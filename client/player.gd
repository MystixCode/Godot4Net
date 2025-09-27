extends CharacterBody3D

var is_authority: bool:
	get: return owner_id == Net.id

var owner_id: int
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _enter_tree() -> void:
	Net.handle_player_position.connect(handle_player_position)


func _exit_tree() -> void:
	Net.handle_player_position.disconnect(handle_player_position)


func _ready() -> void:
	if !is_authority: return

	$Camera3D.current = true

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

	var keys_motion: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	if keys_motion != Vector2(0.0,0.0):
		KeysMotion.create(owner_id, keys_motion).send(Net.server_peer)

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

func handle_player_position(player_position: PlayerPosition) -> void:
	if owner_id != player_position.id: return
	position = player_position.position
