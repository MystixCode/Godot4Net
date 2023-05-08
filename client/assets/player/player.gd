extends CharacterBody3D


#various
var client_ready: bool = false
var player_name: String 
var color: Color
var client_prediction: bool = false
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

	if str(name) == str($"/root/main/net".multiplayer.get_unique_id()) : #and int(str(name)) == $"/root/main/net".peer_id
		show_debug_panel()
		$inputs.send_inputs()
		camera.current = true

		#client_prediction (simulate physics on client too, to compensate for lag)
		if client_prediction == true:
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
			#Rotation
			if $inputs.mouse_motion:
				rotate_y(deg_to_rad(-$inputs.mouse_motion.x)*delta*mouse_sensitivity)
				#TODO
#				camera_arm.rotate_x(deg_to_rad(-$inputs.mouse_motion.y)*delta*mouse_sensitivity)
			#Movement
			var direction = (transform.basis * Vector3($inputs.keys_motion.x, 0, $inputs.keys_motion.y)).normalized()
			if direction:
				velocity.x = direction.x * speed
				velocity.z = direction.z * speed
			else:
				velocity.x = move_toward(velocity.x, 0, speed)
				velocity.z = move_toward(velocity.z, 0, speed)
			move_and_slide()
#		$inputs.keys_motion = Vector2()
		$inputs.mouse_motion = Vector2()
#		$inputs.sprint = false
		$inputs.jump = false
		$inputs.shoot = false
	else:
		camera.current = false


func show_debug_panel():
	$"/root/main/ui/debug".show()
	$"/root/main/ui/debug/panel/hbox/values/id".text = str($"../client_to_server".multiplayer.get_unique_id())
	$"/root/main/ui/debug/panel/hbox/values/player_name".text = player_name
	$"/root/main/ui/debug/panel/hbox/values/mouse_motion".text = str($inputs.mouse_motion)
	$"/root/main/ui/debug/panel/hbox/values/keys_motion".text = str($inputs.keys_motion)
	$"/root/main/ui/debug/panel/hbox/values/zoom".text = str($inputs.zoom)
	$"/root/main/ui/debug/panel/hbox/values/sprint".text = str($inputs.sprint)
	$"/root/main/ui/debug/panel/hbox/values/jump".text = str($inputs.jump)
	$"/root/main/ui/debug/panel/hbox/values/shoot".text = str($inputs.shoot)
	var server_to_client_authority = str($"/root/main/net/server_to_client".get_multiplayer_authority())
	var client_to_server_authority = str($"../client_to_server".get_multiplayer_authority())
	$"/root/main/ui/debug/panel/hbox/values/server_to_client_authority".text = server_to_client_authority
	$"/root/main/ui/debug/panel/hbox/values/client_to_server_authority".text = client_to_server_authority
#	$DebugPanel/HBox/Values/peerid.text = str(Network.peerid)
#	$DebugPanel/HBox/Values/playername.text = playername
#	$DebugPanel/HBox/Values/client_prediction.text = str(client_prediction)
#	$DebugPanel/HBox/Values/fps.text = str(Engine.get_frames_per_second())
#	$DebugPanel/HBox/Values/cl_tickrate.text = str(Network.cl_tickrate)
#	$DebugPanel/HBox/Values/cl_updaterate.text = str(Network.cl_updaterate)
#	$DebugPanel/HBox/Values/cl_interp_ratio.text = str(Network.cl_interp_ratio)
#	$DebugPanel/HBox/Values/cl_interp_time.text = str(Network.cl_interp_time)
#	$DebugPanel/HBox/Values/cl_tickid.text = str(Network.cl_tickid)
#	$DebugPanel/HBox/Values/statebuffer.text = ""
#	for i in Network.statebuffer:
#		$DebugPanel/HBox/Values/statebuffer.text += str(i) + "\n"

