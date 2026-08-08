extends Player_State

func enter(_data: Dictionary = {}) -> void:
	character.velocity.x = 0
	CR.color = Color(1.0, 1.0, 1.0, 1.0)

func physics_update(delta: float) -> void:
	# активируем гравитацию
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
	
	# обработка смены направления взгляда
	if Input.is_key_pressed(KEY_A): character.player_direction = 'left'
	if Input.is_key_pressed(KEY_D): character.player_direction = 'right'
	
	# если есть direction то переключаем состояние на run
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		get_parent().change_state(self, "Run")
		
	# есть игрок нажал на клавишу прыжка то переключаем состояние на jump
	if Input.is_action_just_pressed("ui_accept") and character.is_on_floor():
		get_parent().change_state(self, "Jump")
	
	# есть игрок нажал на клавишу рывка то переключаем состояние на dash
	if Input.is_action_just_pressed("dash") and character.dash_cooldown_timer <= 0:
		character.dash_cooldown_timer = character.dash_cooldown # Запускаем откат
		get_parent().change_state(self, "Dash")
		
	character.move_and_slide()
