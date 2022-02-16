extends Node

var mouseDelta := Vector2()
var motion := Vector2()
var jump := false
var shoot := false

func update():
	motion = Input.get_vector("move_forward", "move_backward", "move_left", "move_right")
	jump = Input.is_action_pressed("jump")
	shoot = Input.is_action_just_pressed("shoot")
	#print("mouseDelta: " + str(mouseDelta) + " motion: " + str(motion))

func _input(event):
	if event is InputEventMouseMotion:
		mouseDelta = event.relative
