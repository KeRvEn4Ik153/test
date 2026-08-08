class_name StatusEffectData
extends RefCounted

var id: String = "poison"
var duration: float = 5.0
var tick_time: float = 1.0

var current_duration: float = 0.0
var time_since_last_tick: float = 0.0

# Добавляем флаг, чтобы применить стартовую логику один раз
var is_initialized: bool = false

func apply_effect(player: CharacterBody2D, delta: float) -> bool:
	# Метод для логики, которая срабатывает ОДИН раз при старте эффекта
	if not is_initialized:
		on_start(player)

		is_initialized = true

	current_duration += delta
	time_since_last_tick += delta
	
	if time_since_last_tick >= tick_time:
		on_tick(player)
		time_since_last_tick = 0.0
		
	var is_finished = current_duration >= duration
	
	# Если эффект завершился, вызываем финальный метод очистки
	if is_finished:
		on_end(player)
		
	return is_finished

# Метод вызывается один раз при наложении эффекта
func on_start(_player: CharacterBody2D) -> void:
	pass

# Метод вызывается раз в секунду
func on_tick(_player: CharacterBody2D) -> void:
	pass

# Метод вызывается один раз при исчезновении эффекта
func on_end(_player: CharacterBody2D) -> void:
	pass
