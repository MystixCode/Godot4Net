extends Node

func _on_button_pressed():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.connect("request_completed", _http_request_completed)
	
	var username = $vbox/username.text
	var password = $vbox/password.text
	var salt = "ReplaceThis"
	var hash = Marshalls.utf8_to_base64( (password+salt).sha256_text() )
	
	var body = JSON.new().stringify({"name": username, "hash": hash})
	var error = http_request.request("https://httpbin.org/post", [], true, HTTPClient.METHOD_POST, body)
	if error != OK:
		push_error("An error occurred in the HTTP request.")

func _http_request_completed(result, response_code, headers, body):
	var my_json = JSON.new()
	var parse_result = my_json.parse(body.get_string_from_utf8())
	if parse_result != OK:
		print("Error %s reading json file." % parse_result)
		return
	var data : Dictionary = my_json.get_data()
	
#	print(data)
	print("Response Code: ", response_code)
	if data.has("headers") && data.headers != null:
		print("User-Agent: " + data["headers"]["User-Agent"])
	if data.has("json") && data.json.has("name") && data.json.name != null:
		print("Username: " + data["json"]["name"])
	if data.has("json") && data.json.has("hash") && data.json.name != null:
		print("Hash: ", data["json"]["hash"])
