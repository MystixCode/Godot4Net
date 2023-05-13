extends CanvasLayer


func _on_connect_pressed():
	get_node("/root/main/net").server.ip = $panel/vbox/server_ip.text
	get_node("/root/main/net").server.port = $panel/vbox/server_port.value
	get_node("/root/main/net").start_networking()
	$panel/vbox/connect.disabled = true
