extends Node2D
class_name EnemyEffectManager

# Ссылка на ресурс статов игрока (можно перетащить в инспекторе)
var enemy: CharacterBody2D = null
var active_effects: Array = []

func _process(delta: float) -> void:
	# Если статы еще не переданы, эффекты не обрабатываем
	if not enemy.enemy_stats or active_effects.is_empty():
		return
		
	var effects_to_remove: Array = []
	
	for effect in active_effects:
		# Передаем актуальный (возможно, дублированный) ресурс статов
		var is_finished = effect.apply_effect(enemy, delta)
		if is_finished:
			effects_to_remove.append(effect)
			
	for effect in effects_to_remove:
		active_effects.erase(effect)

func add_effect(new_effect) -> void:
	for effect in active_effects:
		if effect.id == new_effect.id:
			effect.current_duration = 0.0
			return
			
	active_effects.append(new_effect)
