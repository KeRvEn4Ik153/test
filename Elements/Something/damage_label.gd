extends Label

func _ready() -> void:
	# Генерируем случайное смещение по X на старте
	var random_x = randf_range(-25, 25)
	
	# Создаем Tween ОДИН раз при появлении надписи
	var tween = create_tween()
	
	# Включаем параллельный режим, чтобы движение и прозрачность работали одновременно
	tween.set_parallel(true)
	
	# Настраиваем конечную точку полета (вбок на random_x и вверх на 35 пикселей)
	var target_position = global_position + Vector2(random_x, -35)
	
	# Запускаем плавное движение (используем глобальную позицию для точности)
	tween.tween_property(self, "global_position", target_position, 0.4)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)
		
	# Запускаем плавное растворение в воздухе
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	
	# Как только ОБЕ анимации выше завершатся, вызываем удаление узла из памяти
	tween.chain().tween_callback(queue_free)
