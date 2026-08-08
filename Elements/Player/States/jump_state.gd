extends Player_State

func enter(_data: Dictionary = {}) -> void:
	# если мы вошли в это состояние с земли, даем импульс вверх
	if character.is_on_floor():
		character.velocity.y = character.stats.jump_velocity
	CR.color = Color(0.0, 0.0, 1.0, 1.0)

func physics_update(delta: float) -> void:
	# включаем гравитация
	character.velocity += character.get_gravity() * delta
	
	# обработка смены направления взгляда
	if Input.is_key_pressed(KEY_A): character.player_direction = 'left'
	if Input.is_key_pressed(KEY_D): character.player_direction = 'right'

	# в зависимости от нажатой клавиши меняем направление
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		character.velocity.x = direction * character.stats.speed
	else:
		character.velocity.x = move_toward(character.velocity.x, 0, character.stats.speed)
		
	# если игрок на полу и он двигаеться то переключаем состояние на run иначе на idle
	if character.is_on_floor():
		if direction != 0:
			get_parent().change_state(self, "Run")
		else:
			get_parent().change_state(self, "Idle")
			
	# если игрок в прыжке нажал на клавишу рывка то преключаем состояние на dash
	if Input.is_action_just_pressed("dash") and character.dash_cooldown_timer <= 0:
		character.dash_cooldown_timer = character.stats.dash_cooldown # Запускаем откат
		get_parent().change_state(self, "Dash")
		
	character.move_and_slide()
