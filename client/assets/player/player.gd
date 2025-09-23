extends CharacterBody3D

@export var player_name : String
@export var color : Color
@export var health : int
@export var mana : int
@export var stamina : int
@export var mouse_motion := Vector2()
@export var keys_motion := Vector2()
@export var is_sprinting := false
@export var is_jumping := false
@export var is_shooting := false

@onready var camera : Camera3D = $CameraArm/Camera3D

const PLAYER_TAG_RESOURCE := preload("res://assets/player_tag/player_tag.tscn")
const HEALTH_BAR_RESOURCE := preload("res://assets/ui/health_bar/health_bar.tscn")
const MANA_BAR_RESOURCE := preload("res://assets/ui/mana_bar/mana_bar.tscn")
const STAMINA_BAR_RESOURCE := preload("res://assets/ui/stamina_bar/stamina_bar.tscn")
var player_id : int


func _input(event):
	if event is InputEventMouseMotion and get_viewport().get_window().has_focus():
		mouse_motion += event.relative

func _ready():
	player_id = str(name).to_int()
	$ClientToServerSynchronizer.set_multiplayer_authority(player_id)

	set_player_color()

	if str(multiplayer.get_unique_id()) == str(name):
		load_player_ui()
	else:
		load_player_tag()

	get_node("/root/Main/UI/SkillBar").show()


	if multiplayer.multiplayer_peer == null or str(multiplayer.get_unique_id()) == str(name): 
		camera.current = true


func _physics_process(_delta):
	if str(multiplayer.get_unique_id()) == str(name): 
		is_jumping=false
		is_shooting=false
		handle_input()
		show_debug_panel()

		mouse_motion = Vector2()

func set_player_color():
	var mesh_instance_body: MeshInstance3D = $MeshInstance3D
	var mesh_instance_eyes: MeshInstance3D = $MeshInstance3D/MeshInstance3D
	var material = StandardMaterial3D.new()
	material.albedo_color = color
	mesh_instance_body.set_surface_override_material(0, material)
	mesh_instance_eyes.set_surface_override_material(0, material)

func load_player_ui():
	var health_bar := HEALTH_BAR_RESOURCE.instantiate()
	add_child(health_bar, true)
	var mana_bar := MANA_BAR_RESOURCE.instantiate()
	add_child(mana_bar, true)
	var stamina_bar := STAMINA_BAR_RESOURCE.instantiate()
	add_child(stamina_bar, true)

func load_player_tag():
	var player_tag := PLAYER_TAG_RESOURCE.instantiate()
	add_child(player_tag, true)

func handle_input() -> void:
		keys_motion = Input.get_vector("move_forward", "move_backward", "move_left", "move_right")
		if Input.is_action_just_pressed("sprint"):
			is_sprinting=true
		if Input.is_action_just_released("sprint"):
			is_sprinting=false
		if Input.is_action_just_pressed("jump"):
			is_jumping=true
		if Input.is_action_just_pressed("shoot"):
			is_shooting=true

func show_debug_panel():
	var server_authority = str($ServerToClientSynchronizer.get_multiplayer_authority())
	var client_authority = str($ClientToServerSynchronizer.get_multiplayer_authority())
	$"/root/Main/UI/Debug/Window".show()
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/Id".text = str(multiplayer.get_unique_id())
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/PlayerName".text = player_name
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/Position".text = str(position)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/Rotation".text = str(rotation)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/CARotation".text = str($CameraArm.rotation)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/Health".text = str(health)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/Mana".text = str(mana)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/Stamina".text = str(stamina)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/MouseMotion".text = str(mouse_motion)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/KeysMotion".text = str(keys_motion)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/CAZoom".text = str($CameraArm.ActualZoom)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/IsSprinting".text = str(is_sprinting)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/IsJumping".text = str(is_jumping)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/IsShooting".text = str(is_shooting)
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/ServerAuthority".text = server_authority
	$"/root/Main/UI/Debug/Window/PanelContainer/Panel/HBox/Values/ClientAuthority".text = client_authority
