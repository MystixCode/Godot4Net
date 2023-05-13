extends Node


# sync vars
var mouse_motion: Vector2
var keys_motion: Vector2
var sprint = false
var jump = false
var shoot = false
var zoom: float = 0
var old_zoom: float

#func _process(delta):
#	if mouse_motion != Vector2() or keys_motion != Vector2() or sprint or jump or shoot:
#		print("mouse_motion: " + str(mouse_motion) + ", keys_motion: " + str(keys_motion) + ", sprint: " + str(sprint) + ", jump: " + str(jump) + ", shoot: " + str(shoot))
#		pass
