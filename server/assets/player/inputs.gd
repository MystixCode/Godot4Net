extends MultiplayerSynchronizer

@export var input_state : Dictionary

@export var jumping := false
@export var shooting := false

#@onready var player_id : int = multiplayer.get_remote_sender_id()

#TODO: validate / check all input
#TODO: anti hack algorithms
#TODO: create input_state_validated and use that in playerscript instead of input_state direct

#func _ready():
#	set_multiplayer_authority(multiplayer.get_remote_sender_id())

func _ready():
#	# Only process for the local player.
	set_process(get_multiplayer_authority() == multiplayer.get_unique_id())

@rpc("call_local")
func jump():
	jumping = true
	print("RPC called by: ", multiplayer.get_remote_sender_id())

@rpc("call_local")
func shoot():
	shooting = true

func _physics_process(_delta):
#	print(input_state)

	# Reset shoot state.
	shooting = false
		
	# Reset jump state.
	jumping = false
