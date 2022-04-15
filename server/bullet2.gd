extends RigidDynamicBody3D

var from_player : int
var time_alive: float = 5
var direction := Vector3()
var bullet_velocity : float = 10
var damage : int = 50
var synced_position: Vector3

@onready var player := get_node("../../Players/" + str(from_player))
@onready var camera := player.get_node("CameraArm/Camera3D")
@onready var ch_pos : Vector2 = player.get_node("Crosshair").position + player.get_node("Crosshair").size * 0.5
@onready var ray_from = player.get_node("Position3D/").global_transform.origin
@onready var ray_dir : Vector3 = camera.project_ray_normal(ch_pos)

func _ready():
#	TODO manage to hit center of crosshair somehow..
#	var shoot_target

#	var ray_params = PhysicsRayQueryParameters3D.new()
#	ray_params.from = ray_from
#	ray_params.to = ray_from + ray_dir * 100
#	ray_params.exclude = [player] #TODO exclude bullets foreach in $"..".get_children
#	ray_params.collide_with_bodies = true
	
#	var raycol = get_world_3d().direct_space_state.intersect_ray(ray_params)
#	if (raycol.is_empty()):
#		print("col empty")
#		shoot_target = ray_from + ray_dir * 100
#	else:
#		print("col not empty")
#		shoot_target = raycol.position
#	#print(str(shoot_target))
#	var shoot_dir = (shoot_target - ray_from).normalized()
#	self.global_transform.origin = ray_from
	self.direction = ray_dir 
	self.add_collision_exception_with(player)
#	$sfx/shoot.play()

func _process(delta):
	time_alive-=delta
	if (time_alive<0):
#		$anim.play("explode")
		queue_free()
	var col = move_and_collide(delta * direction * bullet_velocity)
	synced_position = position
	if (col):
#		print("collided")
		if (col.get_collider() and col.get_collider().has_method("damage")):
			col.collider.damage(damage)
		$CollisionShape3D.disabled=true
		queue_free()
#		$anim.play("explode")


func _on_bullet_body_entered(body):
	print("got into body" + str(body))
