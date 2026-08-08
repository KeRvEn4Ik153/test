extends Player_State

func enter(_data: Dictionary = {}) -> void:
	character.animation_sprites.play("walk")
	CR.color = Color(1.0, 0.0, 0.0, 1.0)

func physics_update(delta: float) -> void:
	# включаем гравитация 
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
		
	# обработка смены направления взгляда
	if Input.is_key_pressed(KEY_A): character.player_direction = 'left'
	if Input.is_key_pressed(KEY_D): character.player_direction = 'right'

	# в зависимости от нажатой клавиши меняем направление
	var direction := Input.get_axis("ui_left", "ui_right")
	# если направление есть то игрок идет иначе переключаем состояние на idle
	if direction != 0:
		character.velocity.x = direction * character.stats.speed
	else:
		get_parent().change_state(self, "Idle")
		
	# если игрок нажал на клавишу прыжка то переключаем состояние на jump
	if Input.is_action_just_pressed("ui_accept") and character.is_on_floor():
		get_parent().change_state(self, "Jump")
		
	# если игрок нажал на клавишу рывка то переключаем состояние на dash
	if Input.is_action_just_pressed("dash") and character.dash_cooldown_timer <= 0:
		character.dash_cooldown_timer = character.stats.dash_cooldown # Запускаем откат
		get_parent().change_state(self, "Dash")
		
	character.move_and_slide()
