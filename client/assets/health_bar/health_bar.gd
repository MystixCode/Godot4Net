extends Control




#var healthbar_x = 500
#var healthbar_y =40
var my_health_bar_size: Vector2 = Vector2(500.0, 40.0)
#
#var otherhealthbar_x = 250
#var otherhealthbar_y =20
var other_health_bar_size: Vector2 = Vector2(250.0,20.0)

var player_id
@onready var player = get_node("../")
var lbl_nametag

var health_bar_size: Vector2

func _ready():

	#if my player
	if str(get_parent().name) == str($"/root/main/net".multiplayer.get_unique_id()):
		health_bar_size = my_health_bar_size

		print("its me :)    ---------------")
	else: #if other pplayer
		#add label
#		lbl_nametag = Label.new()
#		lbl_nametag.set_name("nametag")
#		lbl_nametag.text = "testtext"	
#		lbl_nametag.set_position(Vector2(0,-20))
#		lbl_nametag.hide()
#		add_child(lbl_nametag)
		health_bar_size = other_health_bar_size
		
#		hide()
	var image = Image.create(health_bar_size.x,health_bar_size.y,false,Image.FORMAT_RGB8)
	image.fill(Color.DIM_GRAY)
	var image_texture = ImageTexture.new()
	image_texture = ImageTexture.create_from_image(image)
	$vbox/health_bar.set_under_texture(image_texture)
	$vbox/health_bar.set_progress_texture(image_texture)
	$vbox/health_bar.set_tint_progress(Color.RED)
	set_name("healthbar_" + str(player_id))

func _physics_process(delta):
	pass
	if str(get_parent().name) == str($"/root/main/net".multiplayer.get_unique_id()):
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		$vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)

	else: #if not network master (if otherplayer)
		var healthbar_max_distance = 50

		var test_id = str(multiplayer.get_unique_id())
		var test = get_node("/root/main/players/" + str(test_id) + "/" + str(test_id))

		var distance = player.transform.origin.distance_to(test.transform.origin)
#		#TODO offset based on distance??????????????????????????????????????????????????????????????
		if distance < healthbar_max_distance:
			var camera: Camera3D = test.get_node("SpringArm3D/Camera3D")
			var healthbar_max_offset_y = 180
			var healthbar_offset_y=healthbar_max_offset_y-distance
##			var nametag_healthbar_offset = 5
			var offset = Vector2(size.x/2*get_scale().x/2,  healthbar_offset_y)														#TODO offset based on distance
##			var offset_nametag = Vector2(lbl_nametag.get_size().x * lbl_nametag.get_scale().x/2, healthbar_offset_y + get_node("healthbar_" + get_name()).get_size().y*get_node("healthbar_" + get_name()).get_scale().y/2 + nametag_healthbar_offset)														#TODO offset based on distance
#	#		if(  get_node("../../ui/healthbar_" + get_name()).get_position().x in (camera.unproject_position(get_translation()) - offset).x):
			var fovx = get_node("../SpringArm3D/Camera3D").position.x
			var fovy = get_node("../SpringArm3D/Camera3D").position.y
			var hbx = (get_node("../SpringArm3D/Camera3D").unproject_position(test.position) - offset).x
			var hby = (get_node("../SpringArm3D/Camera3D").unproject_position(test.position) - offset).y
			if(hby > 0 and hby > fovy) or (hbx > 0 and hbx > fovx) :
##				#	healthbar.set_scale(Vector2(0.5, 0.5)) #scale 50%
				if distance < 40: 
					var zwischenresultat = float(1) / healthbar_max_distance
					var distanceinprozent = distance * zwischenresultat #dreisatz 1=100%
					set_scale(Vector2(1,1) - Vector2(distanceinprozent, distanceinprozent))		# Set scale based on distance
				show()
#				lbl_nametag.text="<" + str(player.charname) + "@" + str(player.username) + ">"
				$vbox/name_tag.text="<" + str(player.player_name) + ">"
				$vbox/name_tag.show()
#				set_position(camera.unproject_position(player.position) - offset)
				set_position(camera.unproject_position(player.position))
			else:
				hide()
		else:
			hide()
