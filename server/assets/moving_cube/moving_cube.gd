extends StaticBody3D

@export var path_speed: float = 0.5
@export var path_radius: float = 10.0
@export var wobble_amplitude: float = 3
@export var wobble_frequency: float = 5.0

var path_time: float = 0.0
var center_pos: Vector3 = Vector3(randi_range(700,720), 168, randi_range(0,20))

func _ready():
	position = center_pos + Vector3(path_radius, 0, 0)

func _process(delta):
	path_time += delta * path_speed

	# Circular path
	var path_x = cos(path_time) * path_radius
	var path_z = sin(path_time) * path_radius

	# Wobble around the path
	var wobble_x = sin(path_time * wobble_frequency) * wobble_amplitude
	var wobble_y = cos(path_time * wobble_frequency * 1.2) * wobble_amplitude * 0.7
	var wobble_z = sin(path_time * wobble_frequency * 0.8) * wobble_amplitude * 0.5

	# Combine path and wobble
	var target_pos = center_pos + Vector3(path_x + wobble_x, wobble_y, path_z + wobble_z)

	# Smooth movement
	position = position.lerp(target_pos, delta * 8.0)

	# Face movement direction
	var direction = (target_pos - position).normalized()
	if direction.length() > 0.1:
		look_at(position + direction, Vector3.UP)
