extends CharacterBody3D

const SPEED: float = 5.0

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

func _physics_process(delta: float) -> void:
	if !is_authority: return
	
	# TODO: brainstorming notes

	# zudem wunderi mi obs sinnvoll isch für alles einzelni packet mache. ma könnt jo au wenn mehreri pro tick sind zemafasdse zumene grössere, d frag isch wie effizient isch welli grössi vergliche zu alles einzeln sende bi udp enet library

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
	
	# use channel 0 für reliable, 1 für unreliable zum reliable priorisiere.
	# wenn mehreri reliable oder unreliable in einem tick z verarbeite sind, tun sie zemafasse immene batch.
	# batch sött nid grösser si als 1200-byte UDP safe limit
	# drumm wenn nötig mehreri batches mache.
	
	# unreliable packet verwerfe wenn älter
	
	# Handle invalid packages. / improve error handling

	var input_vector: Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	#velocity = Vector3(input_vector.x, 0, input_vector.y) * SPEED

	#handle_gravity(delta)

	#move_and_slide()

	#PlayerPosition.create(owner_id, position).send(Net.server_peer)


	var keys_motion: Vector2 = input_vector
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
	print("my id", Net.id)
	print("owner id", owner_id)
	if owner_id != player_position.id: return
	print("yoo received player pos")
	position = player_position.position
