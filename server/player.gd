extends CharacterBody3D

var speed: float = 5.0

var owner_id: int
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var keys_motion : Vector2

func _enter_tree() -> void:
	Net.handle_keys_motion.connect(handle_keys_motion)

func _exit_tree() -> void:
	Net.handle_keys_motion.disconnect(handle_keys_motion)

func _physics_process(delta: float) -> void:
	handle_gravity(delta)
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

	PlayerPosition.create(owner_id, position).broadcast(Net.connection)

func handle_keys_motion(peer_id: int, _keys_motion: KeysMotion) -> void:
	if owner_id != peer_id: return

	print("keys_motion: ", _keys_motion.keys_motion)
	keys_motion = _keys_motion.keys_motion
