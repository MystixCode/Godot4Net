extends SpringArm3D

var MaxZoom := 0.5
var MinZoom := 2.5
var ZoomFactor : float = 1
var ActualZoom : float = 1
var ZoomSpeed := 4

func _input(event):
	if str(get_parent().get_node("ClientToServerSynchronizer").multiplayer.get_unique_id()) == get_parent().name:
		if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			if Input.is_action_just_pressed("ui_cancel"):
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.is_action_just_pressed("ui_cancel"):
			if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

		if event is InputEventMouseButton:
			match event.button_index:
				MOUSE_BUTTON_WHEEL_UP:
					ZoomFactor -= 0.5
				MOUSE_BUTTON_WHEEL_DOWN:
					ZoomFactor += 0.5
				#ZoomFactor = clamp(ZoomFactor, MaxZoom, MinZoom)

func _physics_process(delta):
	if str(get_parent().get_node("ClientToServerSynchronizer").multiplayer.get_unique_id()) == get_parent().name:
		ActualZoom = lerp(ActualZoom, ZoomFactor, delta * ZoomSpeed)
		ActualZoom = clamp(ActualZoom, MaxZoom, MinZoom)
		if abs(ActualZoom - ZoomFactor) < 0.001:
			ActualZoom = ZoomFactor
		set_scale(Vector3(ActualZoom,ActualZoom,ActualZoom))
