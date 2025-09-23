extends Node3D
var rng: RandomNumberGenerator
var spawn_area : Vector3 = Vector3(randi_range(0,1), 10, randi_range(0,10))

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()

func _process(_delta: float) -> void:
	spawn_area = Vector3(rng.randi_range(700,720), 170, rng.randi_range(0,20))
