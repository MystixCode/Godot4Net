extends Node


func _enter_tree():
	set_multiplayer_authority(int(str($"..".name)))

@rpc("reliable")
func done_preconfig():
	pass

@rpc("unreliable_ordered")
func send_input_unreliable():
	pass

@rpc("reliable")
func send_input_reliable():
	pass
