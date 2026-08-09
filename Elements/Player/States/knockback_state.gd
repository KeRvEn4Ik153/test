extends Player_State

var knockback_timer: float = 0.0

func enter(data: Dictionary = {}) -> void:
	character.animation_sprites.play("idle") # Или анимация получения урона, если есть
	knockback_timer = 0.25
	CR.color = Color(0.955, 0.849, 0.0, 1.0)
	
	if data.has("velocity"):
		character.velocity = data["velocity"]

func physics_update(delta: float) -> void:
	# Применяем гравитацию во время отлета
	if not character.is_on_floor():
		character.velocity += character.get_gravity() * delta
		
	if character.anim_player:
		character.anim_player.stop()
	
	# Тормозим по горизонтали
	character.velocity.x = move_toward(character.velocity.x, 0, 1000.0 * delta)
	character.move_and_slide()
	
	knockback_timer -= delta
	if knockback_timer <= 0:
		# Возвращаем в нужное состояние после окончания отброса
		if character.is_on_floor():
			get_parent().change_state(self, "Idle")
		else:
			get_parent().change_state(self, "Jump")
