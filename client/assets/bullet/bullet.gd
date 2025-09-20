extends Area3D

@export var from_player : int

func _ready():
	$AudioStreamPlayer3d.play()

func _on_body_entered(body):
#	print(str(name) + " collided with " + str(body.name))
	if body is CharacterBody3D:
		$AudioStreamPlayer3d2.play()
