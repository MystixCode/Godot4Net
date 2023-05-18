extends Control


#TODO: this script needs some work.. just an early prototype

var my_health_bar_size: Vector2 = Vector2(500.0, 40.0)
var other_health_bar_size: Vector2 = Vector2(250.0,20.0)
var player_id
var health_bar_size: Vector2

var my_player_id
var my_player

var player

var my_camera: Camera3D

func _ready():
	#if my player
	if str(get_parent().name) == str($"/root/main/net".multiplayer.get_unique_id()):
		health_bar_size = my_health_bar_size
	#if other player	
	else: 
		health_bar_size = other_health_bar_size

	var image = Image.create(health_bar_size.x,health_bar_size.y,false,Image.FORMAT_RGB8)
	image.fill(Color.DIM_GRAY)
	var image_texture = ImageTexture.new()
	image_texture = ImageTexture.create_from_image(image)
	$vbox/health_bar.set_under_texture(image_texture)
	$vbox/health_bar.set_progress_texture(image_texture)
	$vbox/health_bar.set_tint_progress(Color.RED)
	set_name("healthbar_" + str(player_id))


func _physics_process(delta):
	if str(get_parent().name) == str($"/root/main/net".multiplayer.get_unique_id()):
		set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		$vbox.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	else: #if not network master (if otherplayer)
#		var healthbar_max_distance = 50

		#TODO..
		my_player_id = str(multiplayer.get_unique_id())
		my_player = get_node("/root/main/players/" + str(my_player_id) + "/" + str(my_player_id))

		player = get_node("../")

		my_camera = my_player.get_node("SpringArm3D/Camera3D")

		var distance = player.transform.origin.distance_to(my_player.transform.origin)
		print("distance: " + str(distance))

		var player_height= 180
		var offset_x = 0.0
		#TODO: figure out how to calculate that healthbar y position !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
		var offset_y = player_height - distance *4 #figure this out.. i just placed a 4 because it gets close to what i need im not a math guy xD
		var offset = Vector2(offset_x, offset_y)
		set_position(my_camera.unproject_position(player.position) - offset)
		#TODO only show healthbar if in camera view


#		#some old stuff / try 1
#		if distance < healthbar_max_distance:
#			var camera: Camera3D = test.get_node("SpringArm3D/Camera3D")

#			#TODO offset based on distance
##			var healthbar_offset_y=clamp(healthbar_max_offset_y-distance*4,50,180) #I dont know how to calculate the offset based on distance...TODO pls help xD
#			var healthbar_max_offset_y = 180
#			var zwischenresultat1 = float(1) / healthbar_max_distance
#			var distanceinprozent1 = distance * zwischenresultat1 #dreisatz 1=100%
#			var healthbar_offset_y = clamp(180 - 180 * distanceinprozent1,50,180)
#			var offset = Vector2(size.x/2*get_scale().x/2,  healthbar_offset_y)	
#
#			#TODO: only show if player is infront of my players camera
#	#		if(  get_node("../../ui/healthbar_" + get_name()).get_position().x in (camera.unproject_position(get_translation()) - offset).x):
#			var fovx = get_node("../SpringArm3D/Camera3D").position.x
#			var fovy = get_node("../SpringArm3D/Camera3D").position.y
#			var hbx = (get_node("../SpringArm3D/Camera3D").unproject_position(test.position) - offset).x
#			var hby = (get_node("../SpringArm3D/Camera3D").unproject_position(test.position) - offset).y
#
#			if(hby > 0 and hby > fovy) or (hbx > 0 and hbx > fovx):
###				#	healthbar.set_scale(Vector2(0.5, 0.5)) #scale 50%
#				if distance < 40: 
#					var zwischenresultat = float(1) / healthbar_max_distance
#					var distanceinprozent = distance * zwischenresultat #dreisatz 1=100%
#					set_scale(Vector2(1,1) - Vector2(distanceinprozent, distanceinprozent))		# Set scale based on distance
#				show()
#
#				#show label
##				lbl_nametag.text="<" + str(player.charname) + "@" + str(player.username) + ">"
#				$vbox/name_tag.text="<" + str(player.player_name) + ">"
#				$vbox/name_tag.show()
#
#				# set position with offset
#				set_position(camera.unproject_position(player.position) - offset)
##				set_position(camera.unproject_position(player.position))
#			else:
#				hide()
#		else:
#			hide()
