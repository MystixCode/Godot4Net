extends MultiplayerSynchronizer

@export var input_state : Dictionary

@export var jumping := false
@export var shooting := false

@onready var player_id : int = multiplayer.get_unique_id()

var mouse_motion := Vector2()
var motion := Vector2()

#func _ready():
	# Only process for the local player.
#	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

#func _ready():
	# Only process for the local player.
#	set_process(get_multiplayer_authority() == player_id)
#	set_multiplayer_authority(player_id)

func _input(event):
	if event is InputEventMouseMotion:
		mouse_motion = event.relative
		#print("mouse_motion: " + str(mouse_motion))

@rpc("call_remote")
func jump():
	jumping = true

@rpc("call_remote")
func shoot():
	shooting = true

func _process(_delta):
	motion = Input.get_vector("move_forward", "move_backward", "move_left", "move_right")
	input_state[str(player_id)] = [motion, mouse_motion]
	mouse_motion = Vector2()
	
	# Reset jump state.
	jumping = false
	
	# Reset shoot state.
	shooting = false

	if Input.is_action_just_pressed("jump"):
		jump.rpc()

	if Input.is_action_just_pressed("shoot"):
		shoot.rpc()

#func _physics_process(_delta):
#	print(input_state)
