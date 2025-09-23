extends CharacterBody3D

@export var player_name : String
@export var color : Color
@export var health : int = 200
@export var mana : int = 200
@export var stamina : int = 200
@export var mouse_motion := Vector2()
@export var keys_motion := Vector2()
@export var is_sprinting := false
@export var is_jumping := false
@export var is_shooting := false

var player_id : int
var rng : RandomNumberGenerator

var speed := 5.0
var movement_speed: float = 5.0
var sprint_speed: float = 10.0
var jump_force := 6
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mouse_sensitivity : float = 0.1

var accumulated_mana : float = 0.0
const MIN_MANA: int = 0
var max_mana: int = 200
var mana_rate: float = 10

var accumulated_stamina: float = 0.0
const MIN_STAMINA: int = 0
var max_stamina: int = 200
var stamina_rate: float = 10

@onready var camera : Camera3D = $CameraArm/Camera3D
@onready var b_res := preload("res://assets/bullet/bullet.tscn")

func _ready():
	#Engine.physics_ticks_per_second=144
	Engine.physics_jitter_fix = 0.0
	
	rng = RandomNumberGenerator.new()
	rng.randomize()

	player_id = str(name).to_int()
	$ClientToServerSynchronizer.set_multiplayer_authority(player_id)

	set_player_color()

	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name):
		camera.current = true

func _physics_process(delta):
	handle_gravity(delta)
	handle_rotation(delta)
	handle_sprint()
	handle_jump()
	handle_shoot()
	handle_motion()
	regen_mana(delta)
	regen_stamina(delta)

func set_player_color():
	var mesh_instance_body: MeshInstance3D = $MeshInstance3D
	var mesh_instance_eyes: MeshInstance3D = $MeshInstance3D/MeshInstance3D
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance_body.set_surface_override_material(0, material)
	mesh_instance_eyes.set_surface_override_material(0, material)

func handle_gravity(delta) -> void:
	
	# If u fall from map 
	if position.y < -20:
#		$ColorRect.modulate.a = min((-17 - transform.origin.y) / 15, 1)
		# If we're below -40, respawn (teleport to the initial position).
		if position.y < -40:
#			$ColorRect.modulate.a = 0
			var current_map : String = get_node("/root/Main").camel_case_map
			position = get_node("/root/Main/Maps/" + current_map).spawn_area

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

func handle_rotation(delta) -> void:
	# Early exit if no mouse motion to avoid unnecessary calculations
	if mouse_motion == Vector2.ZERO:
		return

	var rot : Vector3 = Vector3(mouse_motion.y, 0, mouse_motion.x) * mouse_sensitivity * delta
	mouse_motion = Vector2()
	#$CameraArm.rotation.x -= rot.x

	#TODO: limit camera rotation up/down, new Vector3.limit_lengthfunction?
	# $CameraArm.rotation.x = clamp(rotation.x, -90.0, 30.0)
	rotation.y -= rot.z
	$CameraArm.rotation.x = clamp($CameraArm.rotation.x - rot.x, deg_to_rad(-70.0), deg_to_rad(30.0))

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

func handle_shoot() -> void:
	if is_shooting:
		if mana >= 10:
			var b := b_res.instantiate()
			b.position = $"ShootFrom".global_transform.origin
			b.from_player = player_id
			get_node("/root/Main/BulletSpawner").add_child(b, true)
			mana-=10

func handle_motion() -> void:
	var direction := (transform.basis * Vector3(keys_motion.y, 0, keys_motion.x)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	move_and_slide()

func regen_mana(delta) -> void:
	accumulated_mana += mana_rate * delta
	if accumulated_mana >= 1.0:
		var mana_increment: int = int(accumulated_mana)
		mana += mana_increment  # Add to mana
		mana = clamp(mana, MIN_MANA, max_mana)
		accumulated_mana -= mana_increment

func regen_stamina(delta) -> void:
	accumulated_stamina += stamina_rate * delta
	if accumulated_stamina >= 1.0:
		var stamina_increment: int = int(accumulated_stamina)
		stamina += stamina_increment
		stamina = clamp(stamina, MIN_STAMINA, max_stamina)
		accumulated_stamina -= stamina_increment

func damage(_dmg : int):
	health -= _dmg
	#print(str(name) + " health: " + str(health))
	if health <= 0:
		print(str(name) + " died")
		var current_map : String = get_node("/root/Main").camel_case_map
		position = get_node("/root/Main/Maps/" + current_map).spawn_area
		health = 200
		mana = 200
		accumulated_mana = 0.0
