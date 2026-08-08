extends GPUParticles2D

func _ready() -> void:
	# 1. Принудительно сбрасываем систему в ноль
	emitting = false 
	
	# 2. Перезапускаем взрыв с первого кадра
	restart() 
	emitting = true 
	
	# 3. Ждем окончания эффекта и удаляем
	await get_tree().create_timer(lifetime).timeout
	queue_free()
