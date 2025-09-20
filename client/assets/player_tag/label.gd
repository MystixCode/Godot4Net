extends Label

func _physics_process(_delta: float) -> void:
	text = get_node("../../../../").player_name + "\n" + str(get_node("../../../../").player_id)
