extends FileDialog

@onready var save_manager = $"../../SaveManager"

func _on_SaveDialog_file_selected(path):
	save_manager.write_to_file(path)
	#var serializer = Serializer.new()
	#var buffer = serializer.generate_level_binary($"/root/Main/Template/Items".get_children(), $"/root/Main/Template/Terrain".get_children(), main)
	#var file = FileAccess.open(path, FileAccess.WRITE)
	#file.store_buffer(buffer)
	#file.close()
