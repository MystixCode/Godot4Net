extends Node


var thread
var input = ""

func _notification(what):
	if (what == NOTIFICATION_WM_CLOSE_REQUEST):
		print("stopping cli")
		input="stop"
#		get_tree().quit()


func _init():
	for i in range(OS.get_cmdline_args().size()):
		var arg
		var value
		var separator = " "
		if separator in OS.get_cmdline_args()[i]: #if arg has value split arg+value
			arg = OS.get_cmdline_args()[i].split(separator, 1)[0]
			value = OS.get_cmdline_args()[i].split(separator, 1)[1]
			if arg == "--name":
				get_node("/root/main/net").server.name=value
			if arg == "--port":
				get_node("/root/main/net").server.port = value
			if arg == "--maxplayers":
				get_node("/root/main/net").server.maxplayers=value
			if arg == "--world":
				get_node("/root/main/net").server.world=value


func _ready():
	thread = Thread.new()
	thread.start(_thread_function, Thread.PRIORITY_NORMAL)


func _thread_function():
	
	while input != "stop" && input != "quit" && input != "exit":
#		printraw("gameserver$ ")
		input = OS.read_string_from_stdin().strip_edges()
#		print("You inserted: %s" % input)
		var input_array = input.split(" ", true)
		if input_array[0] == "kick":
			if range(input_array.size()).has(1):
				print("kicking todo")
			else:
				print("u forgot to add playerid")
		elif input_array[0] == "help":
			print("Show help ..todo..")
		elif input != "stop" && input != "quit" && input != "exit" && input != "":
			print("command not found")

	print("Quitting")
	get_tree().quit()


# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	thread.wait_to_finish()
