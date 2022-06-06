extends Node

@export var input_state : Dictionary
var mouse_motion := Vector2()
var motion := Vector2()
var jump := false
var shoot := false

func _input(event):
	if event is InputEventMouseMotion:
		mouse_motion = event.relative
		#print("mouse_motion: " + str(mouse_motion))

func update(player_id):
	motion = Input.get_vector("move_forward", "move_backward", "move_left", "move_right")
	jump = Input.is_action_pressed("jump")
	shoot = Input.is_action_just_pressed("shoot")
	#print("motion: " + str(motion))
	input_state[str(player_id)] = [motion, mouse_motion, jump, shoot]
	mouse_motion = Vector2()

#func _physics_process(_delta):
#	print(input_state)
