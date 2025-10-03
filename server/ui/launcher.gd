extends CanvasLayer

func _ready() -> void:
	$Button.connect("pressed", _on_button_pressed)

func _on_button_pressed() -> void:
	var ip_address: String = "127.0.0.1"
	var port: int = 42069
	Network.start_server(ip_address, port)
	queue_free()
