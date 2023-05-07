extends Node


# sync vars
var mouse_motion: Vector2
var keys_motion: Vector2
var sprint = false
var jump = false
var shoot = false
var zoom: float = 0
var old_zoom: float

var zoom_min=0
var zoom_max=5

var net_fps = 66
var net_fps_timer = 0.0

func _input(event):
	if $"../../client_to_server".is_multiplayer_authority():
		#capture mouse
		if Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			else:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		#mouse_motion
		if event is InputEventMouseMotion:
			mouse_motion = event.relative

		#keys_motion
		keys_motion = Input.get_vector("move_l", "move_r", "move_fw", "move_bw")
		keys_motion.x = clamp(keys_motion.x, -1,1)
		keys_motion.y = clamp(keys_motion.y, -1,1)
		#keys
		if event.is_action_pressed("sprint"):
			sprint = true
		if event.is_action_released("sprint"):
			sprint = false
		if event.is_action_pressed("jump"):
			jump = true
		if event.is_action_pressed("shoot"):
			shoot = true
		
		if event.is_action_pressed("zoom_in") or event.is_action_pressed("zoom_out"):
			old_zoom = zoom
			if event.is_action_pressed("zoom_in"):
				zoom -= 1.0
			if event.is_action_pressed("zoom_out"):
				zoom += 1.0

			zoom = clamp(zoom,zoom_min,zoom_max)
#			if zoom != old_zoom:
#				print("zoom: " + str(zoom))

func send_inputs():
#TODO
#	# send input vars to server every so often timer that doesnt work xD
#	net_fps_timer += delta
#	if net_fps_timer < 1.0/net_fps:
#		return
#	else:
#		net_fps_timer -= 1.0/net_fps

	#input_udp
	var input_udp: Dictionary = {}
	if mouse_motion: #only send mouse_motion if not empty
			input_udp["mouse_motion"] = mouse_motion
	if keys_motion: #only send keys_motion if not empty
			input_udp["keys_motion"] = str(keys_motion)
	if sprint: #only send sprint if not empty
			input_udp["sprint"] = str(sprint)
	#rpc
	if !input_udp.is_empty(): #only send input if not empty
		var input_udp_json_string: String = JSON.stringify(input_udp)
		$"../../client_to_server".send_input_unreliable.rpc_id(1, input_udp_json_string)
#		print(input_udp_json_string)

	#input_tcp
	var input_tcp: Dictionary = {}
	if jump: #only send jump if not empty
		input_tcp["jump"] = str(jump)
	if shoot: #only send shoot if not empty
		input_tcp["shoot"] = str(shoot)
	if zoom != old_zoom: #only send shoot if not empty
		input_tcp["zoom"] = str(zoom)
	#rpc
	if !input_tcp.is_empty(): #only send input if not empty
		var input_tcp_json_string: String = JSON.stringify(input_tcp)
		$"../../client_to_server".send_input_reliable.rpc_id(1, input_tcp_json_string)
#		print(input_tcp_json_string)
