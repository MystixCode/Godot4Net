extends ProgressBar

func _process(_delta: float) -> void:
	value = get_parent().get_parent().get_parent().get_parent().health
