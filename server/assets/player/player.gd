extends CharacterBody3D

#Various
var client_ready: bool = false
var player_name: String 
var color: Color
var ip: String
var respawn_position: Vector3 = Vector3(randf_range(700.0, 705.0), 200.0, randf_range(5.0, 10.0))
var oldpos: Transform3D
#Movement
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var movement_speed: float = 5.0
var sprint_speed: float = 10.0
var speed: float
#Jump
var jump_force: float = 6
#Rotation
var mouse_sensitivity: float = 4.0

@onready var camera_arm =  $"SpringArm3D"
@onready var camera = camera_arm.get_node("Camera3D")
#@onready var b_res := preload("res://../assets/bullet/bullet.tscn")

func _ready():
	var mesh_instance: MeshInstance3D = $MeshInstance3D
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance.set_surface_override_material(0, material)

func _physics_process(delta):

	if client_ready == true:
		oldpos = global_transform
		
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
#			var b := b_res.instantiate()
#			b.position = $"Position3D".global_transform.origin
#			b.from_player = int(str(name))
##			#b.name = str(player_id) + "_" + str(randi()%1001+1)
#			get_node("/root/Main/BulletSpawner").add_child(b, true)

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

		# output_udp
		var newpos = global_transform
		if newpos.origin.distance_to(oldpos.origin) >0.00001 or newpos.basis != oldpos.basis:
			oldpos=newpos
			for p in get_node("/root/main/players").get_children():
				if p.get_node(str(p.name)).client_ready == true:
					var output_udp: Dictionary = {
						"id": int(str(name)),
						"position": position,
						"rotation": rotation,
						"camera_arm_rotation": camera_arm.rotation}
					var output_udp_json_string: String = JSON.stringify(output_udp)
					$/root/main/net/server_to_client.send_output_to_client_unreliable.rpc_id(int(str(p.get_name())), output_udp_json_string)
#					print("send udp: " + str(output_udp_json_string))

		#output_tcp
		if $inputs.zoom != $inputs.old_zoom:
			$inputs.old_zoom = $inputs.zoom
			for p in get_node("/root/main/players").get_children():
				if p.get_node(str(p.name)).client_ready == true:
#					Network.update_remote_states(int(str(self.name)))
					var output_tcp: Dictionary = {
						"id": int(str(name)),
						"camera_arm_scale": camera_arm.scale}
					var output_tcp_json_string: String = JSON.stringify(output_tcp)
					$/root/main/net/server_to_client.send_output_to_client_reliable.rpc_id(int(str(p.get_name())), output_tcp_json_string)
#					print("send tcp: " + str(output_tcp_json_string))

		#Reset inputs (only some, $inputs.zoom should keep its value)
		$inputs.mouse_motion = Vector2()	
		$inputs.keys_motion = Vector2()
		$inputs.sprint = false
		$inputs.jump = false
		$inputs.shoot = false
