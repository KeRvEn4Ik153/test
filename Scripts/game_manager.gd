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
