extends Area3D

@export var from_player: int
@export var speed: float = 40.0
@export var lifetime: float = 3.0
@export var damage: int = 10

var direction: Vector3 = Vector3.ZERO
var timer: Timer
var audio_player: AudioStreamPlayer3D

var position_timer := 0.0
@export var position_interval := 0.01

func _ready() -> void:
	if not from_player:
		push_warning("from_player not assigned!")
		queue_free()
		return

	var player: CharacterBody3D = get_node("/root/Main/PlayerSpawner/" + str(from_player))
	var shoot_from: Marker3D = player.get_node("ShootFrom")
	var camera: Camera3D = player.get_node("CameraArm/Camera3D")
	var crosshair: TextureRect = player.get_node("Crosshair")

	var ch_pos: Vector2 = crosshair.position + crosshair.size * 0.5

	var camera_ray_origin: Vector3 = camera.project_ray_origin(ch_pos)
	var camera_ray_normal: Vector3 = camera.project_ray_normal(ch_pos)

	var ray_length: float = speed * lifetime

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(camera_ray_origin, camera_ray_origin + camera_ray_normal * ray_length)
	query.exclude = [player]

	var result: Dictionary = space_state.intersect_ray(query)
	var target_position: Vector3 = result.position if result else camera_ray_origin + camera_ray_normal * ray_length

	position = shoot_from.global_transform.origin
	direction = (target_position - position).normalized()

	timer = Timer.new()
	add_child(timer)
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.connect("timeout", Callable(self, "destroy"))
	timer.start()

	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta: float) -> void:
	position += direction * speed * delta

	position_timer += delta
	if position_timer >= position_interval:
		var data: Array = [ name.to_int(), position ]
		MystixPacket.broadcast(Network.connection, ENetPacketPeer.FLAG_RELIABLE, MystixPacket.PACKET_TYPE.BULLET_POSITION, data)
		position_timer = 0.0

func _on_body_entered(body: Variant) -> void:
	if body.has_method("damage"):
		#print(str(name) + " collided with " + str(body.name))
		if body is CharacterBody3D:
			body.damage(20)
	#TODO: call audio on server instead of client and after that destroy()?
	destroy()

func destroy() -> void:
	get_parent().despawn(name.to_int())
