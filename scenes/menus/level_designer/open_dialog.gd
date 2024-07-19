extends FileDialog

@onready var save_manager = $"../../SaveManager"

func _on_OpenDialog_file_selected(path):
	save_manager.load_from_file(path)
