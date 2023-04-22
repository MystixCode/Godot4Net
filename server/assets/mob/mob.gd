extends CharacterBody3D

@onready var nav_agent:NavigationAgent3D = $NavigationAgent3d
@onready var position1 = $"../Marker3d".global_position
@onready var position2 = $"../Marker3d2".global_position
@onready var position3 = $"../Marker3d3".global_position
@onready var b_res := preload("res://../assets/newbullet/bullet.tscn")

var mob_state  : Array
var mob_id : int = 666
var mob_health : int = 200
var speed = 3
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
var mode : String = "patrol"
var tick = 0
var old_tick=0
var next_position = 1
var follow_targets : Array

func _ready():
	update_target_location(position1)

func _physics_process(delta):
	tick +=1
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		move_and_slide()
	else:
#		print("next: " + str(next))
		if nav_agent.is_target_reachable() and not nav_agent.is_target_reached():
#			print("is reachable")
			var next_location = nav_agent.get_next_path_position()
			if mode == "follow":
				if !follow_targets.is_empty():
					next_location = follow_targets.front().global_position
					# shoot
					if tick > old_tick+60:
						old_tick = tick
						var b := b_res.instantiate()
						b.position = $"Position3D".global_transform.origin
						b.from_player = 666
						b.target = next_location
						get_node("/root/Main/BulletSpawner").add_child(b, true)
				else:
					mode = "patrol"
			var dir = global_position.direction_to(next_location).normalized()
			var new_velocity = dir * speed
			var vel_final = Vector3(new_velocity.x, 0, new_velocity.z)
				
			if (global_position + velocity) != global_position:
				look_at(global_position + velocity,Vector3.UP)
			
			velocity = vel_final #velocity.move_toward(new_velocity, 0.25).x
			move_and_slide()

		if nav_agent.is_target_reached():
			print("reached")
			if mode == "patrol":
				if next_position == 1:
					next_position = 2
					update_target_location(position2)
				elif next_position == 2:
					next_position = 3
					update_target_location(position3)
				elif next_position == 3:
					next_position = 1
					update_target_location(position1)
			elif mode == "follow":
				print("got you todo attack... ;)")

	# add state
	mob_state = [global_position, rotation]
	#if mob doesnt exist add it to global_state
	if !get_node("/root/Main").global_state.has("mob"):
		get_node("/root/Main").global_state["mob"] = {}
	# add mob_state to global_state
	get_node("/root/Main").global_state["mob"]["tzestname"] = mob_state

func update_target_location(target_location):
#	nav_agent.set_target_location(target_location)
	nav_agent.target_position = target_location

func _on_area_3d_body_entered(body):
#	print(body.get_path())
	if body is CharacterBody3D and body != self: #TODO better check: is player and has highest aggro
		print("i see you " + str(body))
		follow_targets.push_back(body)
		mode = "follow"

func _on_area_3d_body_exited(body):
	if body is CharacterBody3D and body != self:
		print("dont see you anymore " + str(body))
		follow_targets.erase(body)

func damage(_dmg : int):
	mob_health -= _dmg
	print(str(name) + " health: " + str(mob_health))
