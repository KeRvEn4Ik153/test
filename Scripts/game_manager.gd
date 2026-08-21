extends Node

# функция для небольшого замедления времени
func hit_stop(duration: float):
	Engine.time_scale = 0.05
	
	await get_tree().create_timer(
		duration,
		true,
		false,
		true
	).timeout
	
	Engine.time_scale = 1.0
	
func load_game(slot: int):
	var save_data = SaveManager.load_save(slot)
	if save_data == null or save_data.is_empty():
		return
	
	var player = await _wait_for_player()
	if player == null:
		push_error("Игрок так и не появился")
		return
	load_player_stats(player, save_data)

func _wait_for_player(max_tries: int = 60) -> CharacterBody2D:
	var tries = 0
	while tries < max_tries:
		var player = get_tree().get_first_node_in_group("player")
		if player != null:
			return player
		await get_tree().process_frame
		tries += 1
	return null

func load_player_stats(player: CharacterBody2D, save_data):
	player.stats.current_health = save_data["player"]["health"]
	player.stats.current_mana = save_data["player"]["mana"]
	player.position.x = save_data["player"]["position_x"]
	player.position.y = save_data["player"]["position_y"]
	if save_data["player"]["style_path"] != "":
		player.style_manager.fill_slot(save_data["player"]["style_path"])
