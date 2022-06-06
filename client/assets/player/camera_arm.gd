extends SpringArm3D

var MaxZoom := 0.5
var MinZoom := 2.5
var ZoomFactor : float = 1
var ActualZoom : float = 1
var ZoomSpeed := 2

func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_WHEEL_UP:
				ZoomFactor -= 0.05
			MOUSE_BUTTON_WHEEL_DOWN:
				ZoomFactor += 0.05
		#print(ZoomFactor)

		ZoomFactor = clamp(ZoomFactor, MaxZoom, MinZoom)
 
func _physics_process(delta):
	#Zoom
	ActualZoom = lerp(ActualZoom, ZoomFactor, delta * ZoomSpeed)
	set_scale(Vector3(ActualZoom,ActualZoom,ActualZoom))
