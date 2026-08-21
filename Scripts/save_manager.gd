extends Node

const SAVE_DIR = "user://saves/"

var current_save: int = -1
	
func _get_save_path(slot: int) -> String:
	return SAVE_DIR + "save_%d.json" % slot

func save_game(player: CharacterBody2D, slot: int):
	# создаём папку, если её нет
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_absolute(SAVE_DIR)
	
	var save_data = {
		"player": {
			"position_x": player.position.x,
			"position_y": player.position.y,
			"health": player.stats.current_health,
			"mana": player.stats.current_mana,
			"style_path": player.style_manager.style_path
		},
		"scene_path": "res://Game/WorldScenes/main_scene.tscn"
	}
	
	
	var file = FileAccess.open(_get_save_path(slot), FileAccess.WRITE)
	if file == null:
		print("Не удалось сохранить")
		return
	file.store_string(JSON.stringify(save_data))
	file.close()

func load_save(slot: int):
	var path = _get_save_path(slot)
	if not FileAccess.file_exists(path):
		return null
		
	var file = FileAccess.open(path, FileAccess.READ)
	var json_text = file.get_as_text()
	file.close()
	
	var save_data = JSON.parse_string(json_text)
	
	if save_data == null:
		return
		
	return save_data

func delete_save(slot: int):
	var path = _get_save_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func has_save(slot: int) -> bool:
	return FileAccess.file_exists(_get_save_path(slot))
