extends Player_State

var attack_timer: float = 0.0
var style_data: Dictionary = {}
var buffered_attack: Dictionary = {}
var change_attack: Dictionary = {}

var is_looping: bool = false

var anim_name: String

func enter(data: Dictionary = {}) -> void:
	style_data = data
	
	CR.color = Color()
		
	# запускаем атаку и ее анимацию
	if data.has("anim_player") and data.has("anim_name"):
		character.anim_player = data["anim_player"]
		anim_name = data["anim_name"]
		character.anim_player.play(anim_name)
		
		# если анимция зациклена то игрок будет в состоянии attack вечно
		var anim = character.anim_player.get_animation(anim_name)
		is_looping = anim.loop_mode != Animation.LOOP_NONE
		
		# запоминаем, сколько длится анимация удара, чтобы знать, когда выйти из состояния
		attack_timer = character.anim_player.current_animation_length
	else:
		# на всякий случай, если анимации нет, выходим сразу
		attack_timer = 0.1
		
	if is_looping:
		attack_timer = 99999.0

func physics_update(delta: float) -> void:
	# 1. ГРАВИТАЦИЯ (Работает всегда, когда мы в воздухе)
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta

	# 2. ПРОВЕРКА: Можно ли двигаться/прыгать?
	var dynamic_can_move = false 
	if "can_movement" in style_data:
		dynamic_can_move = style_data.can_movement

	# 3. ЛОГИКА ДВИЖЕНИЯ И ПРЫЖКА
	if dynamic_can_move:
		if Input.is_action_just_pressed("ui_accept") and character.is_on_floor():
			character.velocity.y = character.stats.jump_velocity 

		# Обычное перемещение по горизонтали
		var direction = Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			character.velocity.x = direction * character.stats.speed
		else:
			character.velocity.x = 0
	else:
		# Игрок ЗАСТЫВАЕТ во время атаки (прыгать тоже нельзя)
		if character.is_on_floor():
			character.velocity.x = 0
		else:
			# Если удар начался в воздухе и движение запрещено, персонаж плавно тормозит по горизонтали
			character.velocity.x = move_toward(character.velocity.x, 0, character.stats.speed * delta)

	# 4. ФИЗИКА (Применяем накопленные velocity.x и velocity.y)
	character.move_and_slide()
	
	# Считаем время до окончания анимации атаки
	attack_timer -= delta
	if attack_timer <= 0:
		# ПРОВЕРКА БУФЕРА: если игрок нажал еще кнопки во время анимации
		if character.buffered_attack != {}:
			var next_attack = character.buffered_attack.duplicate()
			character.buffered_attack.clear() # Очищаем буфер
			
			# Списываем ману за следующее комбо
			if next_attack["mana_cost"]:
				character.stats.current_mana -= next_attack["mana_cost"]
			
			# Перезапускаем состояние Attack с новой анимацией
			get_parent().change_state(self, "Attack", {
				"anim_player": next_attack["anim_player"],
				"anim_name": next_attack["anim_name"],
				"can_movement": next_attack["can_movement"]
			})
		else:
			# Если буфер пуст, возвращаем контроль игроку
			if character.is_on_floor():
				get_parent().change_state(self, "Idle")
			else:
				get_parent().change_state(self, "Jump")
	
	# если переменая change_animation не пустая значит отменяем текущую анимацию и запускаем новую
	if character.change_animation != {}:
		var next_attack = character.change_animation.duplicate()
		character.change_animation.clear()
		
		if next_attack["mana_cost"]:
			character.stats.current_mana -= next_attack["mana_cost"]
	
		get_parent().change_state(self, "Attack", {
				"anim_player": next_attack["anim_player"],
				"anim_name": next_attack["anim_name"],
				"can_movement": next_attack["can_movement"]
			})
	
	# если игрок нажал на кнопку рывка то отменяем анимацию атаки и переходим в состояние dash
	if Input.is_action_just_pressed("dash") and character.dash_cooldown_timer <= 0:
		character.dash_cooldown_timer = character.stats.dash_cooldown 
		character.anim_player.stop()
		get_parent().change_state(self, "Dash")
		
