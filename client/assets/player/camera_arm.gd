extends SpringArm3D

var MaxZoom := 0.5
var MinZoom := 2.5
var ZoomFactor : float = 1
var ActualZoom : float = 1
var ZoomSpeed := 4

@onready var is_local_player: bool = false
var _has_window_focus: bool = true  # Assume focus on startup

func _ready():
	var parent = get_parent()
	var synchronizer = parent.get_node("ClientToServerSynchronizer")
	is_local_player = str(synchronizer.multiplayer.get_unique_id()) == parent.name

	# Connect to window focus events
	get_window().focus_entered.connect(_on_window_focus_entered)
	get_window().focus_exited.connect(_on_window_focus_exited)
	
	# Initial focus check
	_update_mouse_mode()

func _on_window_focus_entered():
	_has_window_focus = true
	_update_mouse_mode()

func _on_window_focus_exited():
	_has_window_focus = false
	# Always release capture when losing focus to avoid conflicts
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _update_mouse_mode():
	if not is_local_player:
		return

	if _has_window_focus:
		# Capture mouse if ESC wasn't pressed to release it
		if Input.get_mouse_mode() != Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		# Release capture for inactive windows
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _input(event):
	if not is_local_player:
		return

	# Only process input if we have window focus
	if not _has_window_focus:
		return
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if Input.is_action_just_pressed("ui_cancel"):
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif Input.is_action_just_pressed("ui_cancel"):
		# Only capture if we have window focus
		if _has_window_focus:
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
