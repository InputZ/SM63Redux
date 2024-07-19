extends Node

var json = JSON.new()
var items_json := {}
var save_json := {}
const version = Singleton.VERSION
var Camera

var LDRoot
var LDItem = preload("res://scenes/menus/level_designer/ld_item/ld_item.tscn").instantiate()

func write_to_file(file_path):
	
	Camera = get_tree().root.get_node("/root/Main/Camera")
	LDRoot = get_tree().root.get_node("/root/Main/Template")

	save_json.Version = Singleton.LD_VERSION
	save_json.Items = {}
	save_json.LastCameraPos = []
	#save_json.Terrain = {}

	var items = LDRoot.get_node("Items").get_children()
	#var terrain = get_tree().root.get_node("/root/Main/Template/Terrain").get_children()


	for item in items: # Item Handler
		var item_position = Vector2(item.position.x, item.position.y)
		var item_id = str(item.item_id)
		var item_data = [item.position.x, item.position.y]
		if item_id not in save_json.Items.keys():
			save_json.Items[item_id] = [item_data]
		else:
			save_json.Items[item_id].append(item_data)

	# Save Camera Pos
	save_json.LastCameraPos = [Camera.position.x, Camera.position.y]
	
	
	var save_data = json.stringify(save_json)
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	
	file.store_string(save_data)

func load_from_file(file_path):
	
	Camera = get_tree().root.get_node("/root/Main/Camera")
	LDRoot = get_tree().root.get_node("/root/Main/Template")
	var file
	var file_json
	
	
	# CHECK IF FILE EXISTS
	if FileAccess.file_exists(file_path):
		file = FileAccess.open(file_path, FileAccess.READ)
		file_json = json.parse_string(file.get_as_text())
	else:
		return "error reading file"
	
	
	# CHECK IF FILE IS VALID
	if !verify_file(file_json):
		return "error reading file"
	

	var current_items = LDRoot.get_node("Items").get_children()

	# Remove all currently existing items
	for item in current_items:
		item.free()
		
	for item_id in file_json["Items"]:
		for item in file_json["Items"][item_id]:
			spawn_item(item_id, item[0], item[1])
	
	if "LastCameraPos" in file_json.keys():
		Camera.position = Vector2(file_json.LastCameraPos[0],file_json.LastCameraPos[1])


func verify_file(file_content):
	if "Version" not in file_content.keys():
		return false

	return true

func spawn_item(id, x, y):
	var new_item = LDItem.duplicate()
	LDRoot.get_node("Items").add_child(new_item)
	new_item = LDRoot.get_node("Items/" + new_item.name)
	new_item.item_id = int(id)
	new_item.position.x = x
	new_item.position.y = y
	new_item.update_texture()
