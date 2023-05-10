extends Area3D

var from_player : int
var old_position: Vector3
#var bullet_state : Array

var g : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity := Vector3.ZERO

@onready var player: CharacterBody3D = get_node("/root/main/players/" + str(from_player) + "/" + str(from_player))
@onready var camera := player.get_node("SpringArm3D/Camera3D")
@onready var ch_pos : Vector2 = player.get_node("crosshair").position + player.get_node("crosshair").size * 0.5
@onready var ray_dir : Vector3 = camera.project_ray_normal(ch_pos)
@export var bullet_velocity := 40
#@onready var raycast: RayCast3D = player.get_node("shoot_from/RayCast3D")

var aim_direction

@export var distance_limit: float = 5.0

func _ready():
	var timer := Timer.new()
	self.add_child(timer)
	timer.connect("timeout", destroy)
	timer.set_wait_time(4)
	timer.start()

func _physics_process(delta):
	velocity.y += g * delta
	velocity= ray_dir * bullet_velocity
	global_transform.origin += velocity * delta

	#UDP: add bullet_state_udp to states_udp
	var bullet_state_udp: Dictionary = {}
	if position.distance_to(old_position) >0.00001: # only add if changed enough
		old_position=position
		bullet_state_udp["position"] = position
	if !bullet_state_udp.is_empty(): # only add if not empty
		#if states_udp doesnt have player category add it to states_udp
		if !get_node("/root/main/net").states_udp.has("bullet"):
			get_node("/root/main/net").states_udp["bullet"] = {}
		# add player_state to states_udp
		get_node("/root/main/net").states_udp["bullet"][name] = bullet_state_udp

func _on_body_entered(body):
	print(str(name) + " collided with " + str(body.name))
	if body is CharacterBody3D:
		body.damage(10)
	destroy()

func destroy():
	#maybe do some explosion animation and sound or something
	
	#remove bullet on server and clients
	get_node("/root/main/net").free_bullet(str(name))
