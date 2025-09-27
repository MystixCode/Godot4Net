extends Button

func _ready() -> void:
	connect("pressed", _on_button_pressed)

func _on_button_pressed() -> void:
	var ip_address: String = "127.0.0.1"
	var port: int = 42069
	Net.start_client(ip_address, port)
