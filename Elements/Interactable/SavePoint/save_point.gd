extends Interactable

func interact(player: CharacterBody2D):
	SaveManager.save_game(player, SaveManager.current_save)
	return end_interact
