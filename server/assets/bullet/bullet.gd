extends Area3D

var from_player : int
var bullet_state : Array

var g : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity := Vector3.ZERO

@onready var player := get_node("../../MultiplayerSpawner/" + str(from_player))
@onready var camera := player.get_node("CameraArm/Camera3D")
@onready var ch_pos : Vector2 = player.get_node("Crosshair").position + player.get_node("Crosshair").size * 0.5
@onready var ray_dir : Vector3 = camera.project_ray_normal(ch_pos)
@export var bullet_velocity := 40

func _ready():
	var timer := Timer.new()
	self.add_child(timer)
	timer.connect("timeout", destroy)
	timer.set_wait_time(3)
	timer.start()

func _physics_process(delta):
	velocity.y += g * delta
	velocity=ray_dir * bullet_velocity
	global_transform.origin += velocity * delta

	#Add bullet_state to global_state after physic calculations
	bullet_state = [from_player, position]
	
	#if bullet doesnt exist add it to global_state
	if !get_node("/root/Main").global_state.has("bullet"):
		get_node("/root/Main").global_state["bullet"] = {}
	
	# add bullet_state to global_state
	get_node("/root/Main").global_state["bullet"][name] = bullet_state

func _on_bullet_body_entered(body):
	print(str(name) + " collided with " + str(body.name))
	if body is CharacterBody3D:
		body.damage(10)

	#TODO: Why doesnt it get deleted from global_state????????????
#	get_node("/root/Main/").global_state["bullet"].erase(name)
#	queue_free()

func destroy():
	get_node("/root/Main/").global_state["bullet"].erase(name)
	queue_free()
