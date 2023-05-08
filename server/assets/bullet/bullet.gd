extends Area3D

var from_player : int
#var bullet_state : Array
var target : Vector3

var g : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity := Vector3.ZERO

@onready var ray_dir : Vector3 = global_position.direction_to(target).normalized()
@export var bullet_velocity := 40

func _ready():
	print("hello world from: " + str(name))
#	var timer := Timer.new()
#	self.add_child(timer)
#	timer.connect("timeout", destroy)
#	timer.set_wait_time(3)
#	timer.start()

#func _physics_process(delta):
#	velocity.y += g * delta
#	velocity=ray_dir * bullet_velocity
#	global_transform.origin += velocity * delta

	#Add bullet_state to global_state after physic calculations
#	bullet_state = [from_player, position]
	
	#if bullet doesnt exist add it to global_state
#	if !get_node("/root/Main").global_state.has("bullet"):
#		get_node("/root/Main").global_state["bullet"] = {}
	
	# add bullet_state to global_state
#	get_node("/root/Main").global_state["bullet"][name] = bullet_state

func _on_body_entered(body):
	print(str(name) + " collided with " + str(body.name))
#	if body is CharacterBody3D:
#		body.damage(10)

	#TODO: Why doesnt it get deleted from global_state????????????
#	get_node("/root/Main/").global_state["bullet"].erase(name)
#	queue_free()

func destroy():
#	get_node("/root/Main/").global_state["bullet"].erase(name)
	queue_free()
