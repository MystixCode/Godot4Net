extends Area3D

var from_player : int

var g : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var velocity := Vector3.ZERO

@onready var player := get_node("../../Players/" + str(from_player))
@onready var camera := player.get_node("CameraArm/Camera3D")
@onready var ch_pos : Vector2 = player.get_node("Crosshair").rect_position + player.get_node("Crosshair").rect_size * 0.5
@onready var ray_dir : Vector3 = camera.project_ray_normal(ch_pos)
@export var bullet_velocity := 40

func _ready():
	var timer := Timer.new()
	self.add_child(timer)
	timer.connect("timeout", timeout_destroy)
	timer.set_wait_time(3)
	timer.start()
	
func _physics_process(delta):
	velocity.y += g * delta
	velocity=ray_dir * bullet_velocity
	global_transform.origin += velocity * delta

func _on_area_3d_body_entered(body):
	#print("collided with " + str(body))
	if body is CharacterBody3D:
		body.damage(10)
	queue_free()
	
func timeout_destroy():
	print("destroyed after 3 sec")
	queue_free()
