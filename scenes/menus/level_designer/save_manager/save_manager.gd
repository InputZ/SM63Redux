extends Node

var json = JSON.new()
var items_json := {}
var save_json := {}
const version = Singleton.VERSION
var Camera

var LDRoot
var LDItem = preload("res://scenes/menus/level_designer/ld_item/ld_item.tscn").instantiate()

var item_mapping = {
	0: "coin",
	1: "red_coin",
	2: "blue_coin",
	3: "silver_shine",
	4: "shine_sprite",
	5: "?",
	6: "log",
	7: "falling_log",
	8: "tipping_log",
	9: "cloud_middle",
	10: "wood_platform",
	11: "pipe",
	12: "goomba",
	13: "parakoopa",
	14: "koopa",
	15: "koopashell",
	16: "bobomb",
	17: "cheep_cheep",
	18: "goonie",
	19: "butterfly",
	20: "sign",
	21: "water_bottle_small",
	22: "water_bottle_big",
	23: "hover_fludd_box",
	24: "big_tree",
	25: "small_tree",
	26: "big_rock",
	27: "arrow",
	28: "twirl_heart",
	29: "breakable_box",
}

func get_key(dict, element):
	for key in dict.keys():
		if dict[key] == element: return key
	return null

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
		var item_id = item.item_id
		var item_string = item_mapping[item_id]
		var item_data = [item.position.x, item.position.y]
		if item_id not in save_json.Items.keys():
			save_json.Items[item_string] = [item_data]
		else:
			save_json.Items[item_string].append(item_data)

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
		
	for item_string in file_json["Items"]:
		var item_id = get_key(item_mapping, item_string)
		for item in file_json["Items"][item_string]:
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
