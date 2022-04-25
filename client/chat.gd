extends Node



	
func _on_input_text_submitted(new_text):
	if new_text != "":
#		var charname = get_node("/root/game/character/" + global.selected_char_id + "/").charname
#		var username = get_node("/root/game/character/" + global.selected_char_id + "/").username
#		chat(get_tree().get_network_unique_id(), charname, username, new_text)
#		rpc_id(1,"chat", global.token, charname, username, new_text) 
		$vbox/input.set_text("")
		
		#temp local test:
		get_node("/root/Main/UI/chat/vbox/output/").text += new_text + "\n"
		
		
	$vbox/input.hide()
	$vbox/input.show()
	
#remote func chat(id, charname, username, new_text):
#	get_node("/root/game/ui/chat/vbox/output/").text += str(charname) + "@" + username + ": " + new_text + "\n"
##	$notification.play()

