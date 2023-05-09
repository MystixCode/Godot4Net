extends Node


@rpc("reliable")
func preconfig():
	pass


@rpc("reliable")
func spawn_players_on_client():
	pass


@rpc("reliable")
func free_player_on_client():
	pass


@rpc("unreliable_ordered")
func send_output_to_client_unreliable():
	pass


@rpc("reliable")
func send_output_to_client_reliable():
	pass


@rpc("reliable")
func spawn_bullet_on_client():
	pass

