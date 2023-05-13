extends CharacterBody3D


#Various
var client_ready: bool = false
var player_name: String 
var color: Color
var ip: String
var respawn_position: Vector3 = Vector3(randf_range(700.0, 705.0), 200.0, randf_range(5.0, 10.0))
var old_position: Vector3
#Movement
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_speed: float = 5.0
var sprint_speed: float = 10.0
var speed: float
#Jump
var jump_force: float = 6
#Rotation
var mouse_sensitivity: float = 4.0
var old_rotation: Vector3
var old_camera_arm_rotation
#Zoom
var old_camera_arm_scale

var health: int = 100
var old_health: int
var mana: int = 100
var old_mana: int

@onready var camera_arm =  $"SpringArm3D"
@onready var camera = camera_arm.get_node("Camera3D")
#@onready var b_res := preload("res://../assets/bullet/bullet.tscn")

func _ready():
	var mesh_instance: MeshInstance3D = $MeshInstance3D
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material)


func damage(damage: int):
	health -= damage
	print(str(name) + ": health " + str(health))
	#respawn if health is zero
	if health <= 0:
		print(str(name) + "died")
		position = respawn_position
		health = 100


func _physics_process(delta):
	if client_ready == true:
#		old_position = global_transform
		
		#if u fall from map 
		if position.y < -20:
	#		$ColorRect.modulate.a = min((-17 - transform.origin.y) / 15, 1)
			# If we're below -40, respawn (teleport to the initial position).
			if position.y < -40:
	#			$ColorRect.modulate.a = 0
				position = respawn_position

		# Add the gravity.
		if not is_on_floor():
			velocity.y -= gravity * delta

		#Handle jump.
		if $inputs.jump and is_on_floor():
			velocity.y = jump_force
#			player_mana-=10
#			print(str(name) + " mana: " + str(player_mana))

		#Handle sprint.
		if $inputs.sprint:
			speed = sprint_speed
		else:
			speed = movement_speed

		#Handle shoot.
		if $inputs.shoot:
			print(name + ": shoot")
			var from_player = int(str(name))
			$"/root/main/net".spawn_bullet(from_player)
			mana -= 10
			print("mana: " + str(mana))
#			$"/root/main/net".spawn_bullet_on_clients(from_player)

		#Handle zoom
		if $inputs.zoom != $inputs.old_zoom:
#			print("zoom: " + str($inputs.zoom))
			camera_arm.scale.z = 1 + $inputs.zoom

		#Rotation
		if $inputs.mouse_motion:
			#rotate player y
			rotate_y(deg_to_rad(-$inputs.mouse_motion.x)*delta*mouse_sensitivity)
			#rotate camera_arm x
			var camera_arm_rot_x = rad_to_deg(deg_to_rad(-$inputs.mouse_motion.y)*delta*mouse_sensitivity)
			if camera_arm.rotation_degrees.x + camera_arm_rot_x > -90 and camera_arm.rotation_degrees.x + camera_arm_rot_x < 90:
				camera_arm.rotation_degrees.x += camera_arm_rot_x

		#Movement
		var direction = (transform.basis * Vector3($inputs.keys_motion.x, 0, $inputs.keys_motion.y)).normalized()
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)
		move_and_slide()

		#UDP: add player_state_udp to states_udp
		var player_state_udp: Dictionary = {}
		if position.distance_to(old_position) >0.00001: # only add if changed enough
			old_position=position
			player_state_udp["position"] = position
		if rotation != old_rotation: # only add if changed
			old_rotation=rotation
			player_state_udp["rotation"] = rotation
		if camera_arm.rotation != old_camera_arm_rotation: # only add if changed
			old_camera_arm_rotation = camera_arm.rotation
			player_state_udp["camera_arm_rotation"] = camera_arm.rotation
		if health != old_health: # only add if changed
			old_health=health
			player_state_udp["health"] = health
		if mana != old_mana: # only add if changed
			old_mana=mana
			player_state_udp["mana"] = mana
		if !player_state_udp.is_empty(): # only add if not empty
			#if states_udp doesnt have player category add it to states_udp
			if !get_node("/root/main/net").states_udp.has("player"):
				get_node("/root/main/net").states_udp["player"] = {}
			# add player_state to states_udp
			get_node("/root/main/net").states_udp["player"][name] = player_state_udp

		#TCP: add player_state_tcp to states_tcp
		var player_state_tcp: Dictionary = {}
		if camera_arm.scale != old_camera_arm_scale: # only add if changed
			old_camera_arm_scale=camera_arm.scale
			player_state_tcp["camera_arm_scale"] = camera_arm.scale
		if !player_state_tcp.is_empty(): # only add if not empty
			#if states_tcp doesnt have player category add it to states_udp
			if !get_node("/root/main/net").states_tcp.has("player"):
				get_node("/root/main/net").states_tcp["player"] = {}
			# add player_state to states_tcp
			get_node("/root/main/net").states_tcp["player"][name] = player_state_tcp

		#Reset inputs (only some, $inputs.zoom should keep its value)
		$inputs.mouse_motion = Vector2()	
		$inputs.keys_motion = Vector2()
		$inputs.sprint = false
		$inputs.jump = false
		$inputs.shoot = false
