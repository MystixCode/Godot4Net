extends CanvasLayer

func _ready() -> void:
	$VBox/Button.connect("pressed", _on_button_pressed)

func _on_button_pressed() -> void:
	var ip_address: String = $VBox/Address.text
	var port: int = int($VBox/Port.value)
	Net.start_client(ip_address, port)
	queue_free()
