extends VBoxContainer

var head_data = [
	"id",
	"player_name",
	"ip",
	"port",
	"kick_btn"
]

var body_data = [[
	"110",
	"Spartan 117",
	"192.168.1.1",
	"1024"
],[
	"120",
	"Spartan 118",
	"192.168.1.2",
	"1025"
],[
	"130",
	"Spartan 119",
	"192.168.1.3",
	"1026"
]]

var column_data = [
	"add",
	"column",
	"test",
	"ok"
]

func _ready():
#	set_head(head_data)
#	set_body(body_data)
#	add_column(column_data)
	pass

func set_head(head_data: Array):
	var rows_count = head_data.size()
	for r in rows_count:
		print("add: " + head_data[r])
		var label: Label = Label.new()
		label.name = str(r)
		label.text = head_data[r]
		label.size_flags_horizontal += SIZE_EXPAND
		get_node("head/rows/").add_child(label)
		get_node("head/rows/").move_child(label, r)

func set_body(body_data: Array):
	var columns_count = body_data.size()
	var rows_count = 4
	for c in columns_count:
		#adding column
		var column_instance = preload("res://assets/ui/table/column.tscn").instantiate()
		column_instance.name = str(c)
		get_node("body/columns").add_child(column_instance)
		#adding rows to column
		for r in rows_count:
			var label: Label = Label.new()
			label.name = str(r)
			label.text = body_data[c][r]
			label.size_flags_horizontal += SIZE_EXPAND
			get_node("body/columns/" + str(c)).add_child(label)
			get_node("body/columns/" + str(c)).move_child(label, r)

func add_column(column_data: Array):
	print("todo")
	var column_instance = preload("res://assets/ui/table/column.tscn").instantiate()
	var current_column_count = get_node("body/columns/").get_child_count()
	column_instance.name = str(current_column_count+1)
	get_node("body/columns").add_child(column_instance)

	var rows_count = column_data.size()
	#adding rows to column
	for r in rows_count:
		var label: Label = Label.new()
		label.name = str(r)
		label.text = column_data[r]
		label.size_flags_horizontal += SIZE_EXPAND
		get_node("body/columns/" + str(current_column_count+1)).add_child(label)
		get_node("body/columns/" + str(current_column_count+1)).move_child(label, r)
		#adding rows to column

#TODO: remove_column()

#TODO: button signal
