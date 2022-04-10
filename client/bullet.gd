extends RigidDynamicBody3D

var from_player : int
var synced_position : Vector3

func _physics_process(delta):
	
	if synced_position:
		#print(synced_position)
		position=synced_position
